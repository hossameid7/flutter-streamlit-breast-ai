# Model Artifacts

Due to GitHub file-size limitations, trained model weights are **not committed** to this repository.  
They are stored externally on Google Drive.

## Download Link

**Google Drive folder:**  
<https://drive.google.com/drive/folders/1b_76X1dxtyZUJ4Kuqg6MH9oTr7mSUjmA?usp=sharing>

## Expected Files

| Filename | Purpose | Runtime |
|----------|---------|---------|
| `breast_classification_model.keras` | 3-class classification (benign / malignant / normal) | Streamlit API |
| `final_breast_seg_model.keras` | Binary tumor segmentation | Streamlit API |
| `breast_classification_model.tflite` | Classification (edge) | Flutter / TFLite |
| `breast_segmentation_model.tflite` | Segmentation (edge) | Flutter / TFLite |

## Setup

1. Download all `.keras` files from the link above.
2. Place them in this directory:

```text
reports/models/breast_classification_model.keras
reports/models/final_breast_seg_model.keras
```

3. For the Streamlit server, also copy (or symlink) `.keras` weights into:

```text
src/streamlit/models/
```

4. `.tflite` weights are used by the Flutter mobile client and should be placed according to its asset configuration.
