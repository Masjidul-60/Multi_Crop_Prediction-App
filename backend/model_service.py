"""Inference wrapper for the CropDoc e3_full checkpoint.

The training notebook included with this project records the 17-crop order,
and the checkpoint stores the disease-to-crop relationship. It does not store
the human-readable 59 disease labels, so this service exposes stable class IDs
and keeps the Flutter result in the uncertain state until labels are supplied.
"""

from __future__ import annotations

import io
import os
import time
import uuid
from pathlib import Path
from typing import Any

import torch
import torch.nn as nn
from PIL import Image, UnidentifiedImageError
from timm import create_model
from torchvision import transforms


ROOT = Path(__file__).resolve().parents[1]
CHECKPOINT_PATH = Path(os.environ.get("CROPDOC_CHECKPOINT", ROOT / "best.pt"))
OOD_PATH = Path(os.environ.get("CROPDOC_OOD_STATS", ROOT / "ood_stats.pt"))
RICE_CHECKPOINT_PATH = Path(
    os.environ.get(
        "CROPDOC_RICE_CHECKPOINT",
        Path(__file__).resolve().parent / "artifacts" / "rice_leaf_b0.pt",
    )
)
CROPS = [
    "apple", "blueberry", "cherry", "corn", "grape", "mango", "orange",
    "peach", "pepper", "potato", "raspberry", "rice", "soybean", "squash",
    "strawberry", "tomato", "wheat",
]
DEVICE = torch.device(
    os.environ.get("CROPDOC_DEVICE", "cuda" if torch.cuda.is_available() else "cpu")
)


class InvalidImageError(ValueError):
    pass


class CropDocNet(nn.Module):
    """EfficientNet-B0 plus the crop and disease heads stored in best.pt."""

    def __init__(self, state: dict[str, torch.Tensor]) -> None:
        super().__init__()
        self.backbone = create_model("efficientnet_b0", pretrained=False, num_classes=0)
        self.crop_head = nn.Linear(1280, 17)
        self.crop_embed = nn.Parameter(torch.empty(17, 64))
        self.disease_head = nn.Sequential(
            nn.Dropout(0.2),
            nn.Linear(1344, 512),
            nn.ReLU(inplace=True),
            nn.Dropout(0.2),
            nn.Linear(512, 59),
        )
        self.register_buffer("crop_of_class", torch.empty(59, dtype=torch.long))
        self.register_buffer("member", torch.empty(59, 17))
        self.register_buffer("log_member", torch.empty(59, 17))
        self.load_state_dict(state, strict=True)

    def forward(self, images: torch.Tensor) -> tuple[torch.Tensor, ...]:
        features = self.backbone(images)
        crop_logits = self.crop_head(features)
        crop_probabilities = crop_logits.softmax(dim=1)
        crop_embedding = crop_probabilities @ self.crop_embed
        disease_logits = self.disease_head(torch.cat((features, crop_embedding), dim=1))
        # e3_full is the conditioned experiment. Each disease score receives
        # the log probability of its crop according to the checkpoint mask.
        crop_log_probabilities = crop_logits.log_softmax(dim=1)
        crop_condition = torch.logsumexp(
            crop_log_probabilities[:, None, :] + self.log_member[None, :, :], dim=2
        )
        return features, crop_logits, disease_logits + crop_condition


class ModelService:
    def __init__(self) -> None:
        if not CHECKPOINT_PATH.is_file() or not OOD_PATH.is_file():
            raise FileNotFoundError("best.pt and ood_stats.pt must be present in the project root")

        checkpoint = torch.load(CHECKPOINT_PATH, map_location="cpu", weights_only=True)
        stats = torch.load(OOD_PATH, map_location="cpu", weights_only=True)
        state: dict[str, torch.Tensor] = checkpoint["model"]
        if state["disease_head.4.weight"].shape[0] != 59:
            raise ValueError("The selected checkpoint is not the 59-class e3_full run")
        if state["crop_head.weight"].shape[0] != len(CROPS):
            raise ValueError("Checkpoint crop count does not match the training log")
        if stats["maha"]["mus"].shape[0] != 59:
            raise ValueError("OOD statistics do not match the selected checkpoint")

        self.model = CropDocNet(state).to(DEVICE).eval()
        self.epoch = int(checkpoint.get("epoch", 8))
        self.maha_mus = stats["maha"]["mus"].to(DEVICE)
        self.maha_precision = stats["maha"]["precision"].to(DEVICE)
        self.thresholds = {key: float(value) for key, value in stats["thr"].items()}
        self.transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize(mean=(0.485, 0.456, 0.406), std=(0.229, 0.224, 0.225)),
        ])
        self.rice_model: nn.Module | None = None
        self.rice_classes: list[str] = []
        self.rice_epoch = 0
        if RICE_CHECKPOINT_PATH.is_file():
            rice_checkpoint = torch.load(
                RICE_CHECKPOINT_PATH, map_location="cpu", weights_only=True
            )
            self.rice_classes = list(rice_checkpoint["classes"])
            rice_model = create_model(
                "efficientnet_b0", pretrained=False, num_classes=len(self.rice_classes)
            )
            rice_model.load_state_dict(rice_checkpoint["model"], strict=True)
            self.rice_model = rice_model.to(DEVICE).eval()
            self.rice_epoch = int(rice_checkpoint["epoch"])

    @torch.inference_mode()
    def predict(self, image_bytes: bytes) -> dict[str, Any]:
        started = time.perf_counter()
        try:
            image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        except (UnidentifiedImageError, OSError) as error:
            raise InvalidImageError("The uploaded image could not be decoded") from error

        tensor = self.transform(image).unsqueeze(0).to(DEVICE)
        features, crop_logits, disease_logits = self.model(tensor)
        crop_probabilities = crop_logits.softmax(dim=1)[0]
        disease_probabilities = disease_logits.softmax(dim=1)[0]
        crop_confidence, crop_index = crop_probabilities.max(dim=0)

        top = torch.topk(disease_probabilities, k=3)
        best_index = int(top.indices[0])
        delta = features[0].unsqueeze(0) - self.maha_mus
        distances = ((delta @ self.maha_precision) * delta).sum(dim=1).clamp_min(0)
        maha = float(distances.min())
        msp = float(top.values[0])
        energy = float(-torch.logsumexp(disease_logits[0], dim=0))
        reasons: list[str] = []
        if msp < self.thresholds["msp"]:
            reasons.append("low_msp")
        if energy > self.thresholds["energy"]:
            reasons.append("energy")
        if maha > self.thresholds["maha"]:
            reasons.append("maha")

        # Rice field images have their own fine-tuned head and explicit labels.
        # Retain the original OOD guard: high-confidence rice-head outputs on
        # unrelated web images are not enough to claim a disease diagnosis.
        crop_name = CROPS[int(crop_index)]
        if crop_name == "rice" and self.rice_model is not None:
            rice_probabilities = self.rice_model(tensor).softmax(dim=1)[0]
            rice_top = torch.topk(rice_probabilities, k=min(3, len(self.rice_classes)))
            rice_predictions = []
            for score, index_tensor in zip(rice_top.values, rice_top.indices):
                disease = self.rice_classes[int(index_tensor)]
                rice_predictions.append({
                    "label": f"rice/{disease}",
                    "crop": "rice",
                    "disease": disease,
                    "confidence": float(score),
                })

            rice_confidence = float(rice_top.values[0])
            rice_margin = rice_confidence - float(rice_top.values[1]) if len(rice_top.values) > 1 else rice_confidence
            rice_reasons = [reason for reason in reasons if reason == "maha"]
            if rice_reasons:
                status = "unknown"
            elif rice_confidence < 0.55 or float(crop_confidence) < 0.6:
                status = "uncertain"
                rice_reasons.append("low_confidence")
            # This deliberately conservative cutoff is based on validation:
            # >=0.99 retained ~91% of validation samples at ~97.8% accuracy.
            # External web samples still require the independent Mahalanobis
            # guard because this classifier can be confidently wrong off-domain.
            elif rice_confidence >= 0.99 and rice_margin >= 0.2:
                status = "confident"
            else:
                status = "uncertain"
                rice_reasons.append("borderline_confidence")

            return {
                "request_id": f"req_{uuid.uuid4().hex[:16]}",
                "crop": {"name": "rice", "confidence": float(crop_confidence)},
                "predictions": rice_predictions,
                "status": status,
                "reasons": rice_reasons,
                "model_version": f"riceleafbd-v1-e{self.rice_epoch}",
                "inference_ms": int((time.perf_counter() - started) * 1000),
            }

        predictions = []
        for score, index_tensor in zip(top.values, top.indices):
            class_index = int(index_tensor)
            crop = CROPS[int(self.model.crop_of_class[class_index])]
            # Class names are intentionally represented as IDs: the 59-entry
            # class_to_idx mapping is not included in the supplied artifacts.
            disease = f"class_{class_index:02d}"
            predictions.append({
                "label": f"{crop}/{disease}",
                "crop": crop,
                "disease": disease,
                "confidence": float(score),
            })

        # No human-readable disease map was supplied, so never present the
        # raw class ID as a confirmed diagnosis or attach treatment guidance.
        status = "unknown" if reasons else "uncertain"
        if not reasons:
            reasons.append("class_labels_unavailable")
        return {
            "request_id": f"req_{uuid.uuid4().hex[:16]}",
            "crop": {"name": CROPS[int(crop_index)], "confidence": float(crop_confidence)},
            "predictions": predictions,
            "status": status,
            "reasons": reasons,
            "model_version": f"e3_full-epoch{self.epoch}",
            "inference_ms": int((time.perf_counter() - started) * 1000),
        }
