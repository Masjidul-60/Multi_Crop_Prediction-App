"""Small stdlib HTTP server implementing CropDoc's /v1 API."""

from __future__ import annotations

import json
import os
import threading
from email.parser import BytesParser
from email.policy import default
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any

import torch

from model_service import InvalidImageError, ModelService


MAX_IMAGE_BYTES = 5 * 1024 * 1024
model = ModelService()
model_lock = threading.Lock()


class Handler(BaseHTTPRequestHandler):
    server_version = "CropDocModel/1.0"

    def _json(self, status: int, payload: dict[str, Any]) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Accept")
        self.end_headers()
        self.wfile.write(body)

    def do_OPTIONS(self) -> None:  # noqa: N802
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Accept")
        self.send_header("Access-Control-Max-Age", "86400")
        self.end_headers()

    def do_GET(self) -> None:  # noqa: N802
        if self.path != "/v1/health":
            self._json(404, {"error_code": "NOT_FOUND", "message": "Endpoint not found"})
            return
        self._json(200, {
            "status": "ok",
            "model_version": f"e3_full-epoch{model.epoch}",
            "service": "CropDoc PyTorch backend",
            "device": str(torch.device(os.environ.get("CROPDOC_DEVICE", "cuda" if torch.cuda.is_available() else "cpu"))),
            "classes": 59,
            "class_names_available": False,
            "rice_model": {
                "loaded": model.rice_model is not None,
                "model_version": f"riceleafbd-v1-e{model.rice_epoch}" if model.rice_model else None,
                "classes": model.rice_classes,
            },
        })

    def do_POST(self) -> None:  # noqa: N802
        if self.path != "/v1/predict":
            self._json(404, {"error_code": "NOT_FOUND", "message": "Endpoint not found"})
            return
        content_type = self.headers.get("Content-Type", "")
        if not content_type.lower().startswith("multipart/form-data;"):
            self._json(400, {"error_code": "INVALID_IMAGE", "message": "Expected multipart/form-data with an image field"})
            return

        length = int(self.headers.get("Content-Length", "0"))
        if length <= 0:
            self._json(400, {"error_code": "INVALID_IMAGE", "message": "Image upload is empty"})
            return
        if length > MAX_IMAGE_BYTES + 64 * 1024:
            self._json(413, {"error_code": "IMAGE_TOO_LARGE", "message": "Image must be smaller than 5 MB"})
            return

        raw = self.rfile.read(length)
        message = BytesParser(policy=default).parsebytes(
            b"MIME-Version: 1.0\r\nContent-Type: " + content_type.encode("ascii", "replace") + b"\r\n\r\n" + raw
        )
        image_bytes = None
        if message.is_multipart():
            for part in message.iter_parts():
                if part.get_param("name", header="content-disposition") == "image":
                    image_bytes = part.get_payload(decode=True)
                    break
        if not image_bytes:
            self._json(400, {"error_code": "INVALID_IMAGE", "message": "Missing image field"})
            return
        if len(image_bytes) > MAX_IMAGE_BYTES:
            self._json(413, {"error_code": "IMAGE_TOO_LARGE", "message": "Image must be smaller than 5 MB"})
            return

        try:
            with model_lock:
                result = model.predict(image_bytes)
            self._json(200, result)
        except InvalidImageError as error:
            self._json(400, {"error_code": "INVALID_IMAGE", "message": str(error)})
        except ValueError as error:
            self._json(422, {"error_code": "NO_LEAF_DETECTED", "message": str(error)})
        except Exception as error:  # keep model errors in a valid API response
            self.log_error("prediction failed: %s", error)
            self._json(500, {"error_code": "SERVER_ERROR", "message": "Model inference failed"})

    def log_message(self, format: str, *args: Any) -> None:
        print(f"[{self.log_date_time_string()}] {format % args}")


if __name__ == "__main__":
    host = os.environ.get("CROPDOC_HOST", "0.0.0.0")
    port = int(os.environ.get("CROPDOC_PORT", "8000"))
    print(f"CropDoc model service listening on http://{host}:{port}")
    ThreadingHTTPServer((host, port), Handler).serve_forever()
