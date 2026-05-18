# ──────────────────────────────────────────────
# Breast Cancer Diagnosis — Makefile
# ──────────────────────────────────────────────

.PHONY: help install train eval serve flutter-run clean

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# ── Environment ──────────────────────────────
install: ## Install Python dependencies for Backend API server
	pip install -r src/backend/requirements.txt

# ── Training Pipelines ───────────────────────
train: ## Run training notebooks (classification + segmentation)
	jupyter nbconvert --to notebook --execute pipelines/breast-classification.ipynb --output breast-classification.ipynb
	jupyter nbconvert --to notebook --execute pipelines/breast-segmentation.ipynb --output breast-segmentation.ipynb

# ── Evaluation ───────────────────────────────
eval: ## Evaluate model on test images in /tests/
	@echo "Running behavioral evaluation on test images..."
	python -c "\
	import os, tensorflow as tf, numpy as np;\
	model = tf.keras.models.load_model('src/backend/models/breast_classification_model.keras');\
	classes = ['Benign', 'Malignant', 'Normal'];\
	for f in sorted(os.listdir('tests')):\
	    if not f.endswith('.png'): continue;\
	    img = tf.keras.utils.load_img(os.path.join('tests', f), target_size=(224,224));\
	    arr = np.expand_dims(tf.keras.utils.img_to_array(img), 0);\
	    pred = model.predict(arr, verbose=0);\
	    print(f'{f:20s} -> {classes[np.argmax(pred)]:10s} (conf: {np.max(pred):.2%})');\
	"

serve: ## Start the Backend API server
	cd src/backend && python main.py

# ── Flutter ───────────────────────────────────
flutter-run: ## Build and run the Flutter mobile client
	cd src/mobile-app && flutter pub get && flutter run

# ── Cleanup ───────────────────────────────────
clean: ## Remove cached / temporary files
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name '*.pyc' -delete 2>/dev/null || true
