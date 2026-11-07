# RiceLeafBD v1 download

- Dataset: RiceLeafBD: A Field-Collected Rice Leaf Disease Dataset from Bangladesh
- DOI: https://doi.org/10.17632/sjkptpgv79.1
- License: Creative Commons Attribution 4.0 International (CC BY 4.0)
- Required attribution: Islam, M. N., Habib, M. N. H., Hasan, S., & Mojumdar, M. U. (2026). RiceLeafBD, V1. Mendeley Data. https://doi.org/10.17632/sjkptpgv79.1
- Downloaded archive: `riceleafbd_v1.zip` (21,504,156 bytes)

The included dataset PDFs state 2,545 images, but the archive extracts to 3,150
JPG files in five class folders. The training script removes 3 exact duplicates
and writes the actual counts and held-out metrics to
`backend/artifacts/rice_leaf_training_report.json`. Images from the same
five-minute filename timestamp window are assigned to the same split.

The dataset is retained here for local reproducible training and is not bundled
into the Flutter application.
