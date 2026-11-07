"""Fine-tune a rice classifier from the supplied CropDoc backbone.

Input is the extracted RiceLeafBD class-folder archive. The split groups
nearby capture timestamps so burst photos do not cross train/validation/test.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import random
import re
from collections import Counter, defaultdict
from datetime import datetime
from pathlib import Path

import torch
import torch.nn as nn
from PIL import Image
from timm import create_model
from torch.utils.data import DataLoader, Dataset
from torchvision import transforms


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_DATA = ROOT / "data" / "riceleafbd" / "extracted" / "RiceLeafBD"
SOURCE_CHECKPOINT = ROOT / "best.pt"
OUTPUT_DIR = ROOT / "backend" / "artifacts"
OUTPUT_MODEL = OUTPUT_DIR / "rice_leaf_b0.pt"
OUTPUT_REPORT = OUTPUT_DIR / "rice_leaf_training_report.json"
CLASS_NAMES = {
    "Blast": "blast",
    "Narrow_Brown_Spot": "narrow_brown_spot",
    "Normal_Leaf": "healthy",
    "Sheath_Blight": "sheath_blight",
    "Tungro": "tungro",
}
MEAN = (0.485, 0.456, 0.406)
STD = (0.229, 0.224, 0.225)


def capture_group(path: Path) -> str:
    digits = "".join(char for char in path.stem if char.isdigit())
    try:
        capture_time = datetime.strptime(digits[:14], "%Y%m%d%H%M%S")
    except ValueError:
        try:
            capture_time = datetime.strptime(digits[:12], "%Y%m%d%H%M")
        except ValueError:
            return path.stem.rsplit("_", 1)[0]
    # Group images captured within the same five-minute window.
    minute_bin = capture_time.minute // 5
    return capture_time.strftime("%Y%m%d%H") + f"{minute_bin:02d}"


def collect_records(data_dir: Path) -> tuple[list[dict], dict[str, int], int]:
    records: list[dict] = []
    counts: dict[str, int] = {}
    hashes: set[str] = set()
    duplicate_count = 0
    for folder, label in CLASS_NAMES.items():
        class_dir = data_dir / folder
        if not class_dir.is_dir():
            raise FileNotFoundError(f"Missing class folder: {class_dir}")
        paths = sorted(p for p in class_dir.iterdir() if p.suffix.lower() in {".jpg", ".jpeg", ".png"})
        counts[label] = 0
        for path in paths:
            digest = hashlib.sha256(path.read_bytes()).hexdigest()
            if digest in hashes:
                duplicate_count += 1
                continue
            hashes.add(digest)
            records.append({
                "path": path,
                "label": label,
                "group": capture_group(path),
            })
            counts[label] += 1
    if min(counts.values(), default=0) < 8:
        raise ValueError(f"Too few unique samples in at least one class: {counts}")
    return records, counts, duplicate_count


def grouped_split(records: list[dict], seed: int) -> dict[str, list[dict]]:
    rng = random.Random(seed)
    splits: dict[str, list[dict]] = {"train": [], "val": [], "test": []}
    by_class_group: dict[str, dict[str, list[dict]]] = defaultdict(lambda: defaultdict(list))
    for row in records:
        by_class_group[row["label"]][row["group"]].append(row)

    ratios = {"train": 0.70, "val": 0.15, "test": 0.15}
    for label, group_map in by_class_group.items():
        groups = list(group_map.items())
        rng.shuffle(groups)
        groups.sort(key=lambda item: len(item[1]), reverse=True)
        target = {name: sum(len(rows) for _, rows in groups) * ratio for name, ratio in ratios.items()}
        assigned = Counter()
        for group_name, rows in groups:
            candidates = [name for name in ratios if assigned[name] == 0]
            if not candidates:
                candidates = list(ratios)
            destination = max(candidates, key=lambda name: target[name] - assigned[name])
            splits[destination].extend(rows)
            assigned[destination] += len(rows)
        print(f"split {label}: {dict(assigned)} across {len(groups)} capture groups")
    for rows in splits.values():
        rng.shuffle(rows)
    return splits


class LeafDataset(Dataset):
    def __init__(self, rows: list[dict], labels: dict[str, int], training: bool):
        self.rows = rows
        self.labels = labels
        if training:
            self.transform = transforms.Compose([
                transforms.RandomResizedCrop(224, scale=(0.78, 1.0), ratio=(0.88, 1.12)),
                transforms.RandomHorizontalFlip(),
                transforms.RandomRotation(12),
                transforms.ColorJitter(brightness=0.15, contrast=0.15, saturation=0.12, hue=0.02),
                transforms.ToTensor(),
                transforms.Normalize(MEAN, STD),
            ])
        else:
            self.transform = transforms.Compose([
                transforms.Resize((224, 224)),
                transforms.ToTensor(),
                transforms.Normalize(MEAN, STD),
            ])

    def __len__(self) -> int:
        return len(self.rows)

    def __getitem__(self, index: int) -> tuple[torch.Tensor, int]:
        row = self.rows[index]
        with Image.open(row["path"]) as image:
            image = image.convert("RGB")
            return self.transform(image), self.labels[row["label"]]


def macro_f1(logits: torch.Tensor, targets: torch.Tensor, class_count: int) -> float:
    predicted = logits.argmax(dim=1)
    matrix = torch.bincount(
        targets * class_count + predicted,
        minlength=class_count * class_count,
    ).reshape(class_count, class_count).float()
    true_positive = matrix.diag()
    precision = true_positive / matrix.sum(dim=0).clamp_min(1)
    recall = true_positive / matrix.sum(dim=1).clamp_min(1)
    return float((2 * precision * recall / (precision + recall).clamp_min(1e-12)).mean())


@torch.inference_mode()
def evaluate(model: nn.Module, loader: DataLoader, device: torch.device, class_count: int) -> dict:
    model.eval()
    logits_list, target_list = [], []
    for images, targets in loader:
        logits_list.append(model(images.to(device)).float().cpu())
        target_list.append(targets)
    logits = torch.cat(logits_list)
    targets = torch.cat(target_list)
    predicted = logits.argmax(dim=1)
    return {
        "count": int(targets.numel()),
        "accuracy": float((predicted == targets).float().mean()),
        "macro_f1": macro_f1(logits, targets, class_count),
        "confusion_matrix": torch.bincount(
            targets * class_count + predicted,
            minlength=class_count * class_count,
        ).reshape(class_count, class_count).tolist(),
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--data-dir", type=Path, default=DEFAULT_DATA)
    parser.add_argument("--epochs", type=int, default=15)
    parser.add_argument("--batch-size", type=int, default=16)
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    if not SOURCE_CHECKPOINT.is_file():
        raise FileNotFoundError(f"Backbone checkpoint not found: {SOURCE_CHECKPOINT}")
    random.seed(args.seed)
    torch.manual_seed(args.seed)
    if torch.cuda.is_available():
        torch.cuda.manual_seed_all(args.seed)
        torch.backends.cudnn.benchmark = True

    records, observed_counts, duplicates = collect_records(args.data_dir)
    label_names = sorted({row["label"] for row in records})
    labels = {name: index for index, name in enumerate(label_names)}
    split = grouped_split(records, args.seed)
    split_counts = {
        name: dict(Counter(row["label"] for row in rows))
        for name, rows in split.items()
    }
    if any(any(count == 0 for count in row.values()) for row in split_counts.values()):
        raise ValueError(f"A class is missing from a split: {split_counts}")

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"device={device}; unique_images={len(records)}; exact_duplicates_removed={duplicates}")
    print(f"observed_class_counts={observed_counts}")
    print(f"split_class_counts={split_counts}")

    loaders = {
        "train": DataLoader(LeafDataset(split["train"], labels, True), batch_size=args.batch_size,
                            shuffle=True, num_workers=0, pin_memory=device.type == "cuda"),
        "val": DataLoader(LeafDataset(split["val"], labels, False), batch_size=args.batch_size,
                          shuffle=False, num_workers=0, pin_memory=device.type == "cuda"),
        "test": DataLoader(LeafDataset(split["test"], labels, False), batch_size=args.batch_size,
                            shuffle=False, num_workers=0, pin_memory=device.type == "cuda"),
    }

    model = create_model("efficientnet_b0", pretrained=False, num_classes=len(label_names))
    source = torch.load(SOURCE_CHECKPOINT, map_location="cpu", weights_only=True)["model"]
    backbone = {
        key.removeprefix("backbone."): value
        for key, value in source.items()
        if key.startswith("backbone.") and not key.startswith("backbone.classifier.")
    }
    load_result = model.load_state_dict(backbone, strict=False)
    if not load_result.missing_keys or any(not key.startswith("classifier.") for key in load_result.missing_keys):
        raise RuntimeError(f"Unexpected missing backbone parameters: {load_result.missing_keys}")
    print(f"initialized backbone from best.pt; new head parameters: {load_result.missing_keys}")
    model.to(device)

    counts = torch.tensor([observed_counts[name] for name in label_names], dtype=torch.float32)
    class_weights = torch.sqrt(counts.sum() / counts)
    class_weights = class_weights / class_weights.mean()
    criterion = nn.CrossEntropyLoss(weight=class_weights.to(device))
    optimizer = torch.optim.AdamW([
        {"params": [p for n, p in model.named_parameters() if not n.startswith("classifier.")], "lr": 1.5e-4},
        {"params": model.get_classifier().parameters(), "lr": 8e-4},
    ], weight_decay=1e-4)
    scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=args.epochs)
    scaler = torch.amp.GradScaler("cuda", enabled=device.type == "cuda")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    best_f1 = -1.0
    best_epoch = 0
    history = []
    for epoch in range(1, args.epochs + 1):
        model.train()
        loss_sum, seen = 0.0, 0
        for images, targets in loaders["train"]:
            images, targets = images.to(device), targets.to(device)
            optimizer.zero_grad(set_to_none=True)
            with torch.amp.autocast("cuda", enabled=device.type == "cuda"):
                logits = model(images)
                loss = criterion(logits, targets)
            scaler.scale(loss).backward()
            scaler.unscale_(optimizer)
            nn.utils.clip_grad_norm_(model.parameters(), 2.0)
            scaler.step(optimizer)
            scaler.update()
            loss_sum += float(loss.detach()) * targets.size(0)
            seen += targets.size(0)

        val_metrics = evaluate(model, loaders["val"], device, len(label_names))
        scheduler.step()
        record = {
            "epoch": epoch,
            "train_loss": loss_sum / max(1, seen),
            "val": {key: value for key, value in val_metrics.items() if key != "confusion_matrix"},
        }
        history.append(record)
        print(f"epoch={epoch:02d} loss={record['train_loss']:.4f} "
              f"val_acc={val_metrics['accuracy']:.4f} val_macro_f1={val_metrics['macro_f1']:.4f}",
              flush=True)
        if val_metrics["macro_f1"] > best_f1:
            best_f1 = val_metrics["macro_f1"]
            best_epoch = epoch
            torch.save({
                "model": model.state_dict(),
                "classes": label_names,
                "epoch": epoch,
                "val_metrics": val_metrics,
                "input_size": 224,
                "mean": MEAN,
                "std": STD,
                "source_checkpoint": "best.pt backbone, e3_full epoch 8",
                "dataset": "RiceLeafBD v1, DOI 10.17632/sjkptpgv79.1",
                "class_to_idx": labels,
            }, OUTPUT_MODEL)

    best = torch.load(OUTPUT_MODEL, map_location=device, weights_only=True)
    model.load_state_dict(best["model"])
    test_metrics = evaluate(model, loaders["test"], device, len(label_names))
    report = {
        "dataset": "RiceLeafBD v1 (CC BY 4.0)",
        "doi": "10.17632/sjkptpgv79.1",
        "archive_reported_image_count": 2545,
        "archive_extracted_image_count": sum(observed_counts.values()) + duplicates,
        "unique_images_used": len(records),
        "exact_duplicates_removed": duplicates,
        "observed_class_counts": observed_counts,
        "split_class_counts": split_counts,
        "label_to_index": labels,
        "capture_grouping": "same 5-minute filename timestamp bucket",
        "seed": args.seed,
        "best_epoch": best_epoch,
        "best_val_macro_f1": best_f1,
        "history": history,
        "test": test_metrics,
        "test_confusion_matrix_labels": label_names,
        "backbone_source": "best.pt e3_full epoch 8 EfficientNet-B0 backbone",
        "notes": [
            "Archive file counts do not match the included PDF counts; actual extracted counts are reported separately.",
            "Test split groups nearby capture times, but still comes from the same dataset and is not an independent field trial.",
        ],
    }
    OUTPUT_REPORT.write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(f"best_epoch={best_epoch}; test={json.dumps({k: v for k, v in test_metrics.items() if k != 'confusion_matrix'})}")
    print(f"saved {OUTPUT_MODEL} and {OUTPUT_REPORT}")


if __name__ == "__main__":
    main()
