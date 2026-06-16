# Breast Cancer Diagnosis and Tumor Segmentation System

A comprehensive software solution (mobile application and backend inference server) for automated classification (benign, malignant, normal) and segmentation of breast tumors from ultrasound images. The project prioritizes clinical workflow simulation, product metrics, and strict quality control standards.

## 1. Project Team
1. **Karim Gallyamov** — System Architecture
2. **Mansur Zakirov** — Backend Development (API Server)
3. **Ramil Zaripov** — Mobile Development (Flutter Client)
4. **Ilyas Kalimullin** — Data Engineering (Data Preparation & Processing)
5. **Ivan Kosach** — Scrum Master (Documentation & Agile Process)
6. **Hossam Mohamed Eid** — Machine Learning Engineering (Model Architecture, Training & ML Ops)

---

## 2. Technology Stack

- **Client Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [BLoC / Cubit](https://pub.dev/packages/flutter_bloc)
- **Backend & Identity**: [Firebase](https://firebase.google.com/) (Auth, Firestore)
- **AI Inference Engine**: [TensorFlow Lite (TFLite)](https://pub.dev/packages/tflite_flutter) & Streamlit (API Server)
- **Dependency Injection**: [GetIt](https://pub.dev/packages/get_it)
- **Functional Programming**: [Dartz](https://pub.dev/packages/dartz) (Error handling abstraction)
- **UI Components**: `flutter_screenutil`, `awesome_snackbar_content`, `image_picker`

---

## 3. Repository Structure

The repository follows standard software engineering practices for AI feature integration:
- `/specs/` — Product requirements and specifications (PRD, Data Spec, DoD, Data Quality Report, Dataset Card).
- `/src/` — Application source code (`src/mobile-app/` Flutter client, `src/backend/` Python Streamlit server).
- `/tests/` — Behavioral test images plus verification scripts (`verify_quality_gates.py`, `deployment_smoke_test.py`).
- `/pipelines/` — Data/annotation notebook (`HW2.ipynb`) and executable pipelines (data integrity, retraining CI, MLflow store generator).
- `/notebooks/` — Jupyter notebooks for model training and experimentation (classification + segmentation).
- `/reports/` — Experiment report, evidence package, confusion matrix, and the MLflow run manifest.
- `/mlruns/` — Real MLflow file-store (runs + registered models); open with `mlflow ui --backend-store-uri ./mlruns`.
- `/monitoring/` — Monitoring stack: `feedback_handler.py`, `prometheus.yml`, `grafana_dashboard.json`.
- `/tasks/` — Deployment doc, monitoring doc, and the final release decision.
- `/data/` — Versioned dataset (DVC) and the `train/val/test` split files.

> **Homework deliverables index:** see [HOMEWORK_VERIFICATION.md](HOMEWORK_VERIFICATION.md) for a per-assignment
> map of each instructor comment → artifact → exact command to reproduce the evidence.

---

## 3.1 Model Artifacts (External Storage)

Due to GitHub size limitations, trained model weights are stored externally and **not committed** to this repository.

- **Google Drive folder with models**:  
  `https://drive.google.com/drive/folders/1b_76X1dxtyZUJ4Kuqg6MH9oTr7mSUjmA?usp=sharing`

Expected filenames:
- `breast_classification_model.keras`
- `final_breast_seg_model.keras`

To run the Streamlit server locally, download these files and place them under:

```text
src/backend/models/breast_classification_model.keras
src/backend/models/final_breast_seg_model.keras
```

---

## 4. System Architecture

The application architecture enforces separation of concerns through a modular, Clean Architecture approach:
- **Presentation Layer**: Independent UI components bounded to state controllers.
- **Domain Layer**: Business logic encapsulation using BLoC/Cubit.
- **Data Layer**: Repository pattern implementation for Firebase operations and AI inference routing.
- **Dependency Management**: Centralized service locator (GetIt) for predictable dependency resolution.

---

## 5. Execution Flow

### 5.1 Inference Pipeline (Streamlit API)

```mermaid
graph TD
    classDef input fill:#E1F5FE,stroke:#0277BD,stroke-width:2px,color:#000;
    classDef process fill:#FFF9C4,stroke:#FBC02D,stroke-width:2px,color:#000;
    classDef model fill:#D1C4E9,stroke:#512DA8,stroke-width:3px,color:#000,font-weight:bold;
    classDef decision fill:#FFCCBC,stroke:#D84315,stroke-width:2px,color:#000;
    classDef output fill:#C8E6C9,stroke:#388E3C,stroke-width:2px,color:#000;

    A(["Upload Image <br> JPG, JPEG, PNG"]):::input --> B["Preprocess for Classification <br> Resize to 224x224, No Norm"]:::process
    B --> C["Classification Model <br> breast_classification_model.keras"]:::model
    C --> D(["Display Result <br> Type & Probability"]):::output
    
    D --> E{"Is Tumor Detected? <br> Class: 0, 1, 2"}:::decision
    E -- Normal (2) --> F(["Process Complete"]):::output
    
    E -- Benign (0) / Malignant (1) --> G["Prompt for Segmentation <br> 'Run Segmentation' Flag"]:::input
    
    G --> H{"Segmentation Requested?"}:::decision
    H -- No --> F
    
    H -- Yes --> I["Preprocess for Segmentation <br> Resize & Normalize"]:::process
    I --> J["Segmentation Model <br> final_breast_seg_model.keras"]:::model
    J --> K["Generate Overlay <br> Original + Mask + Heatmap"]:::process
    K --> L(["Display Output Plot <br> 3 Images Side-by-Side"]):::output
```

### 5.2 Mobile Application Flow (Flutter Client)

```mermaid
graph TD
    classDef startEnd fill:#1ED760,stroke:#000,stroke-width:2px,color:#fff,font-weight:bold;
    classDef decision fill:#FFD700,stroke:#000,stroke-width:2px,color:#000;
    classDef screen fill:#E1F5FE,stroke:#0277BD,stroke-width:2px,color:#000;
    classDef aiAction fill:#D1C4E9,stroke:#512DA8,stroke-width:3px,color:#000,font-weight:bold;

    A(["Launch Application"]):::startEnd --> B{"Authentication Valid? <br> Firebase Auth"}:::decision
    
    subgraph Identity & Access
        B -- No --> C["Login / Registration Interface"]:::screen
    end
    
    B -- Yes --> D["Primary Diagnostic Dashboard"]:::screen
    C --> D
    
    D --> H["User Profile Management"]:::screen
    H --> D
    
    subgraph Diagnostic Process
        D --> E["Image Acquisition <br> Camera / Storage"]:::screen
        E --> F["Execute AI Analysis <br> Inference API Request"]:::aiAction
        F --> G(["Render Diagnostic Results <br> Classification & Segmentation"]):::startEnd
    end
```

---

## 6. Quick Start (Makefile)

The project includes a `Makefile` for one-command reproducibility:

| Command | Description |
|---------|-------------|
| `make install` | Install Python dependencies for Streamlit server |
| `make train` | Execute training notebooks (classification + segmentation) |
| `make eval` | Run behavioral evaluation on test images in `/tests/` |
| `make serve` | Start the Streamlit inference server |
| `make flutter-run` | Build and run the Flutter mobile client |
| `make clean` | Remove cached / temporary files |

Run `make help` to see all available targets.

---

## 7. How to Run the Streamlit App (Server & Web Sandbox)

> **Deployment Architecture:** The system employs a **Dual-Deployment Architecture**. The **primary target** is **local Edge inference** (on-device TFLite) embedded within the Flutter client to guarantee patient data privacy and offline operational capability. The **Streamlit Server** serves as a vital secondary architecture, functioning as a high-fidelity web-based demonstration sandbox, development playground, and a cloud-based backup API.

### 7.1. Prerequisites
- [Python 3.9+](https://www.python.org/downloads/)
- `pip` installed

### 7.2. Clone the repository

1. Clone and enter the project:
   ```bash
   git clone <repository-url>
   cd flutter-streamlit-breast-ai
   ```

### 7.3. Install Python dependencies and run Streamlit

2. Go to the backend (Streamlit) folder and install dependencies from `requirements.txt`:
   ```bash
   cd src/backend
   pip install -r requirements.txt   # install all packages needed by main.py
   ```

3. Download model files from Google Drive and place them in `src/backend/models/` as described above.

4. Run the Streamlit app:
   ```bash
   streamlit run main.py
   ```

---

## 8. Flutter Mobile Client (Edge Production Target)

The Flutter mobile client is a **fully integrated and functional core production artifact**. It implements **local Edge inference (TFLite)** to perform diagnostic classification and tumor segmentation directly on the user's mobile device.

### Features:
- **Local TFLite Inference**: Direct execution of classification (`breast_classification_model.tflite`) and segmentation (`breast_segmentation_model.tflite`) models on-device using GPU acceleration.
- **Secure Identity & Access**: Integration with Firebase Authentication for doctor profile management.
- **Firestore Telemetry**: Securely synchronizes clinical feedback and low-confidence prediction events to Firebase for centralized monitoring.

### Setup and Local Execution:

```bash
cd src/mobile-app
flutter pub get
flutter run
```

---

## 9. Homework Deliverables & Verification

Every instructor comment (HW2–HW8) is addressed by a runnable artifact. The full map
(comment → artifact → command) is in **[HOMEWORK_VERIFICATION.md](HOMEWORK_VERIFICATION.md)**.

Reproduce all evidence from the repo root:

```bash
python pipelines/check_data_integrity.py     # HW4: data leakage / duplicates / class balance
python pipelines/generate_mlruns.py          # HW5: (re)build the real MLflow store in ./mlruns
python tests/deployment_smoke_test.py        # HW6: real inference forward pass + run log
python pipelines/retrain_ci.py               # HW7: challenger-vs-champion quality gates
python tests/verify_quality_gates.py         # HW8: recompute metrics + re-check dataset
mlflow ui --backend-store-uri ./mlruns       # HW5: browse the logged runs
```