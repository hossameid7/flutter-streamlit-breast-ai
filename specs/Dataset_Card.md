# Dataset Card: BUSI (Breast Ultrasound Images)

This is the main dataset we used for training and evaluating our models. Below are the key details about where it comes from, how it's structured, and the known limitations.

---

## 1. Dataset Overview

* **Dataset Name:** Breast Ultrasound Images Dataset (BUSI)
* **Authors:** Walid Al-Dhabyani, Muhammad Gahan, et al.
* **Release Date:** 2020
* **Source Platform:** Kaggle
* **Direct Link:** [Kaggle BUSI Dataset](https://www.kaggle.com/datasets/sabahesaraki/breast-ultrasound-images-dataset/data)
* **License:** Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International ([CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/))

---

## 2. Dataset Structure & Schema

The dataset is partitioned into three clinical diagnostic categories, containing raw ultrasound scans and corresponding ground-truth tumor masks.

| Category (Class) | Raw Scans | Ground-Truth Mask Images | Total Files | Description |
| :--- | :--- | :--- | :--- | :--- |
| **Benign** | 437 | 437 (some multiple views) | 874 | Scans with non-cancerous tumors (fibroadenomas, cysts) |
| **Malignant** | 210 | 210 (some multiple views) | 420 | Scans with malignant cancerous tumors (carcinomas) |
| **Normal** | 133 | 0 (no masks) | 133 | Scans of healthy breast tissue with no tumors |
| **Total** | **780** | **647** | **1427** | **Entire Dataset Collection** |

### File Naming Convention
* **Raw Image:** `[class]/[class] (index).png` (e.g., `benign/benign (12).png`)
* **Segmentation Mask:** `[class]/[class] (index)_mask.png` (e.g., `benign/benign (12)_mask.png`)
* *Note:* Some cases with multiple tumors contain secondary mask files: `[class] (index)_mask_1.png`.

---

## 3. Data Characteristics & Technical Specs

* **Image Format:** PNG
* **Color Channels:** Grayscale (stored as 3-channel RGB in file metadata)
* **Resolution Distribution:** Average dimension of 500x500 pixels (width ranges 350-700px, height ranges 300-600px).
* **Patient Metadata:** Fully anonymized (PII free). Images were captured from 600 female patients aged 25 to 75.

---

## 4. Preprocessing & Augmentation Pipeline

To prepare the dataset for TFLite on-device models, images are processed as follows:

1. **Classification Pipeline:**
   * **Inference Input Size:** Resized to `224x224` pixels.
   * **Normalization:** Non-normalized pixel ranges (0-255) for standard CNN.
2. **Segmentation Pipeline:**
   * **Inference Input Size:** Resized to `256x256` pixels.
   * **Normalization:** Scaled to `[0.0, 1.0]` for U-Net architecture.
3. **Data Augmentation (Training Only):**
   * Applied horizontal/vertical flips, minor rotations (+-15 degrees), and zoom changes to prevent model overfitting due to dataset size constraints.

---

## 5. Intended Use & Limitations

### Intended Use:
* Diagnostic support ("second opinion" Copilot) for radiologists.
* Educational tool for ultrasound scanning assessment.
* Open-source benchmark for medical image segmentation architectures.

### Limitations:
* **Demographics:** Collected from a specific regional demographic cohort; model generalization across global populations needs wider verification.
* **Equipment Bias:** Scans were acquired using LOGIQ E9 and LOGIQ E9 Compact ultrasound systems; performance under other manufacturer scanners must be monitored.
