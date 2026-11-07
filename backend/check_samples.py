"""Run all local image-picker samples through the configured model."""

import json
from pathlib import Path

from model_service import ModelService


folder = Path(__file__).resolve().parents[1] / "assets" / "test_images"
service = ModelService()
for image_path in sorted(folder.iterdir()):
    if image_path.suffix.lower() not in {".jpg", ".jpeg", ".png"}:
        continue
    try:
        result = service.predict(image_path.read_bytes())
        print(json.dumps({
            "image": image_path.name,
            "crop": result["crop"],
            "status": result["status"],
            "reasons": result["reasons"],
            "predictions": result["predictions"],
        }, ensure_ascii=False))
    except Exception as error:
        print(json.dumps({"image": image_path.name, "error": str(error)}, ensure_ascii=False))
