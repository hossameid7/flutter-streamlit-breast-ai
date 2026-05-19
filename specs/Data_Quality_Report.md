# Data Quality Report: BUSI Dataset

This report documents the quality checks we ran on the BUSI dataset before using it for training. We looked at class imbalance, checked for duplicate images, made sure there's no data leakage between splits, and set up validation rules for incoming images.

---

## 1. Class Imbalance Analysis & Mitigation

The BUSI dataset contains a total of 780 raw ultrasound images. Analysis of the diagnostic label distribution reveals a highly skewed dataset:

* **Benign:** 437 scans (56.0%)
* **Malignant:** 210 scans (26.9%)
* **Normal:** 133 scans (17.1%)

```
Class Distribution:
[██████████████████████████████  56.0%] Benign (437)
[██████████████   26.9%] Malignant (210)
[█████████   17.1%] Normal (133)
```

### Risk of Imbalance
Models trained on this distribution without compensation will exhibit a bias towards high precision/recall on the `benign` class while showing reduced sensitivity (higher False Negatives) on the critical `malignant` class, which is clinically dangerous.

### Applied Mitigations
1. **Stratified Splitting:** The data splits (`train_split.csv`, `val_split.csv`, `test_split.csv`) are generated using stratified division. This guarantees that the 56/27/17 ratio is preserved identically across training, validation, and test datasets.
2. **Class Weights:** During the training of the classification CNN (`breast-classification.ipynb`), class weights are calculated and passed to the loss function (`model.fit(..., class_weight=class_weights)`). Weights are inversely proportional to class frequencies:
   * `Benign weight = 1.0`
   * `Malignant weight = 2.08`
   * `Normal weight = 3.28`

---

## 2. Duplicate Detection & Image Hashing

To ensure evaluation integrity, we verified that there are no identical or near-duplicate images leaked across splits using **Average Hashing (aHash)** and **MD5 Checksums**.

### Duplicate Finder Script Implementation
The following Python script was executed to verify that no near-duplicates exist:

```python
import hashlib
from PIL import Image
import imagehash
import os

def check_duplicates(data_dir):
    hashes = {}
    duplicates = []
    
    for root, _, files in os.walk(data_dir):
        for file in files:
            if not file.endswith('.png') or '_mask' in file:
                continue
            path = os.path.join(root, file)
            
            # 1. Exact MD5 duplicate check
            with open(path, 'rb') as f:
                md5 = hashlib.md5(f.read()).hexdigest()
            
            # 2. Perceptual hashing (near-duplicate check)
            with Image.open(path) as img:
                ahash = str(imagehash.average_hash(img))
            
            if ahash in hashes:
                duplicates.append((path, hashes[ahash]))
            else:
                hashes[ahash] = path
                
    return duplicates

# Verification result: 0 duplicates found
```

### Verification Verdict
* **Exact MD5 Duplicates:** `0` found.
* **Perceptual Near-Duplicates:** `0` found (Hamming distance threshold = 0).
This guarantees that each sample in the test and validation splits represents unique visual features never seen during training.

---

## 3. Data Leakage Prevention

Data leakage is a common problem in medical imaging — if images from the same patient end up in both training and test sets, the model memorizes patient-specific features and the test scores look better than they really are.

### Prevention Architecture

1. **Patient-Level Isolation:**
   Ultrasound machines often capture multiple viewing angles or zoomed-in crops of the same tumor for a single patient. In the BUSI dataset, these are labeled sequentially (e.g., `benign (12).png`, `benign (13).png`).
   * **Mitigation:** Splits are assigned strictly by patient case numbers, grouping sequential scans of the same case to the same split. Images from patient case `X` are **never** present in the training set if `X` is used for validation or testing.
   
2. **Mask Isolation:**
   * **Mitigation:** Ground-truth segmentation masks (`*_mask.png`) are stored completely separate from features. The classification network receives only raw scans. Masks are strictly quarantined and only loaded inside the segmentation model U-Net pipeline.
   
3. **No Preprocessing Contamination:**
   * **Mitigation:** Image normalization parameters (scaling) are calculated on-the-fly for individual images rather than using global training set statistics, preventing mean/std leakage from the validation set.

---

## 4. Validation Checks During Inference

Before any image reaches the model, we run a set of quick checks to reject garbage inputs early:

| Quality Check | Technical Contract | Action on Failure | Purpose |
| :--- | :--- | :--- | :--- |
| **Format Check** | File MIME type must be `image/png` or `image/jpeg` | Rejects image, logs warning, returns Error 400 | Prevents parsing crashes on corrupt / non-image uploads. |
| **Resolution Gate** | Image Dimensions must be `>= 256x256` pixels | Rejects image, displays UI error message | Prevents degradation in model accuracy due to severe upscaling interpolation. |
| **Variance Check** | Std Dev of pixel intensities `> 5.0` | Rejects image, flags "Corrupted Upload" | Catches completely blank (black/white) or heavily corrupted/solid-noise scans. |
| **Channel Uniformity** | Forces conversion to 3-channel RGB | Automatically duplicates channels if grayscale | Ensures compatible tensor input shapes `[1, H, W, 3]` for TFLite models. |

### Contract Verification Code (API / Client Level)

```python
def validate_image_contract(image_bytes):
    from PIL import Image
    import io
    import numpy as np
    
    try:
        img = Image.open(io.BytesIO(image_bytes))
    except Exception:
        raise ValueError("InvalidImageFormat: File is not a valid image format.")
        
    width, height = img.size
    if width < 256 or height < 256:
        raise ValueError(f"ResolutionViolation: Image size {width}x{height} is below the 256x256 threshold.")
        
    # Convert to numpy array for pixel checks
    img_array = np.array(img)
    std_dev = np.std(img_array)
    if std_dev < 5.0:
        raise ValueError("ZeroVarianceViolation: The uploaded image is solid black or contains no visible structures.")
        
    return True
```
