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
- `/specs/` — Product requirements and specifications (PRD, Data Spec, DoD).
- `/src/` — Application source code (Flutter mobile application and Python Streamlit server).
- `/tests/` — Evaluation datasets (`test_images`) and behavioral testing resources.
- `/pipelines/` — Experimental Jupyter notebooks for model training and baseline evaluation.
- `/reports/` — Model Registry containing compiled `.keras` and `.tflite` artifacts.

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

    A([Upload Image <br> JPG, JPEG, PNG]) ::: input --> B[Preprocess for Classification <br> Resize to 224x224, No Norm] ::: process
    B --> C[Classification Model <br> breast_classification_model.keras] ::: model
    C --> D([Display Result <br> Type & Probability]) ::: output
    
    D --> E{Is Tumor Detected? <br> Class: 0, 1, 2} ::: decision
    E -- Normal (2) --> F([Process Complete]) ::: output
    
    E -- Benign (0) / Malignant (1) --> G[Prompt for Segmentation <br> 'Run Segmentation' Flag] ::: input
    
    G --> H{Segmentation Requested?} ::: decision
    H -- No --> F
    
    H -- Yes --> I[Preprocess for Segmentation <br> Resize & Normalize] ::: process
    I --> J[Segmentation Model <br> final_breast_seg_model.keras] ::: model
    J --> K[Generate Overlay <br> Original + Mask + Heatmap] ::: process
    K --> L([Display Output Plot <br> 3 Images Side-by-Side]) ::: output
```

### 5.2 Mobile Application Flow (Flutter Client)

```mermaid
graph TD
    classDef startEnd fill:#1ED760,stroke:#000,stroke-width:2px,color:#fff,font-weight:bold;
    classDef decision fill:#FFD700,stroke:#000,stroke-width:2px,color:#000;
    classDef screen fill:#E1F5FE,stroke:#0277BD,stroke-width:2px,color:#000;
    classDef aiAction fill:#D1C4E9,stroke:#512DA8,stroke-width:3px,color:#000,font-weight:bold;

    A([Launch Application]) ::: startEnd --> B{Authentication Valid? <br> Firebase Auth} ::: decision
    
    subgraph Identity & Access
        B -- No --> C[Login / Registration Interface] ::: screen
    end
    
    B -- Yes --> D[Primary Diagnostic Dashboard] ::: screen
    C --> D
    
    D --> H[User Profile Management] ::: screen
    H --> D
    
    subgraph Diagnostic Process
        D --> E[Image Acquisition <br> Camera / Storage] ::: screen
        E --> F[Execute AI Analysis <br> Inference API Request] ::: aiAction
        F --> G([Render Diagnostic Results <br> Classification & Segmentation]) ::: startEnd
    end
```

---

## 6. Setup & Installation

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Latest stable release)
- [Python 3.9+](https://www.python.org/downloads/)
- [Firebase account](https://firebase.google.com/) structured with an active project

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd flutter-streamlit-breast-ai
   ```

2. **Initialize the Analysis Server (Streamlit):**
   ```bash
   cd src/streamlit_server 
   pip install -r requirements.txt
   streamlit run app.py
   ```

3. **Bootstrap the Mobile Client (Flutter):**
   ```bash
   cd src/Breast-App-main
   flutter pub get
   flutter run
   ```