# CropDoc PyTorch backend

This small Python service loads the `e3_full` checkpoint (`best.pt`) and its
59-class OOD statistics (`ood_stats.pt`) from the project root. It implements
the Flutter app's `GET /v1/health` and `POST /v1/predict` endpoints without an
additional web framework. It permits local Flutter web requests for
development.

## Run on Windows

From the project root, install backend packages if they are missing and start
the service:

```powershell
python -m pip install -r backend/requirements.txt
python backend/server.py
```

The server listens on port 8000. Android emulator users can set the app's API
URL to `http://10.0.2.2:8000`. A physical phone and the computer must share a
network; use the computer's LAN IP (for example, `http://192.168.1.20:8000`).
Set the URL in CropDoc's developer settings after tapping the version label
seven times and turning off mock predictions.

The server accepts an `image` field in `multipart/form-data`, limited to 5 MB.
Optional environment variables are `CROPDOC_CHECKPOINT`, `CROPDOC_OOD_STATS`,
`CROPDOC_HOST`, `CROPDOC_PORT`, and `CROPDOC_DEVICE`.

## Bangladesh rice model

Rice images are routed through a second EfficientNet-B0 classifier fine-tuned
from the supplied `best.pt` backbone. It recognizes five field-rice classes:
blast, healthy, narrow brown spot, sheath blight, and tungro. The model and its
class map are stored in `backend/artifacts/rice_leaf_b0.pt`; the original OOD
guard remains active. A high rice-model score alone does not override that
guard.

The training source is RiceLeafBD v1, collected in Dhaka under field conditions
and released under CC BY 4.0: [dataset DOI](https://doi.org/10.17632/sjkptpgv79.1).
Credit the dataset authors when redistributing the model. The included PDF says
2,545 images, but the downloaded archive contains 3,150 JPGs. Exact duplicate
checking removed 3, leaving 3,147 images used. The training report documents
the observed counts and split. Images with timestamps in the same five-minute
window stay in one split to reduce burst-photo leakage.

To retrain after extracting the archive into `data/riceleafbd/extracted/RiceLeafBD`:

```powershell
python backend/train_rice_model.py --epochs 15 --batch-size 16
```

The script picks the checkpoint with the best validation macro-F1 and reports
metrics on a held-out capture-window test split. The current run's metrics are
in `backend/artifacts/rice_leaf_training_report.json`. That split is from the
same dataset; it is not an independent field trial.

The model wrapper uses 224×224 RGB images with ImageNet normalization, a
standard EfficientNet-B0 inference transform. The training transform config
was not included with the supplied files, so this preprocessing is the
available best-fit assumption.

## Important model-label limitation

The supplied training output gives the 17 crop names and order. The checkpoint
also stores the crop index for every disease output, so the API can report the
crop and a stable `class_00`–`class_58` identifier. It does not include the
disease `class_to_idx` mapping. Until that mapping is available, predictions
remain `uncertain` (or `unknown` when an OOD threshold fires), and the app
does not show treatment advice for these class IDs. The backend validates
checkpoint dimensions and OOD statistics at startup to prevent pairing
incompatible files.

This label limitation applies to the original multi-crop head; rice requests
use the separate RiceLeafBD model above. Other crops still need the original
59-class mapping and field-domain validation before disease names can be shown.

The pasted evaluation reports strong in-domain results but weak cross-dataset
macro-F1. Treat this model as an experimental aid and confirm crop disease
diagnoses with a local agricultural extension officer.
