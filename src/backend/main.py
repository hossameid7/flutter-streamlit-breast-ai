import streamlit as st
from PIL import Image
import numpy as np
import tensorflow as tf
from tensorflow.keras.models import load_model
import cv2
import matplotlib.pyplot as plt

CLASS_IMG_SIZE = (224, 224)
SEG_IMG_SIZE = (256, 256)

@st.cache_resource
def load_models():
    breast_tumor_detector = load_model("models/breast_classification_model.keras")  
    breast_segmentor = load_model("models/final_breast_seg_model.keras")                     
    return  breast_tumor_detector, breast_segmentor


def preprocess_rgb(img, size=CLASS_IMG_SIZE, norm = True):
    img = img.resize(size).convert('RGB')
    if norm:
        img = np.array(img) / 255.0
    return np.expand_dims(img, axis=0)

# segmentation
def show_segmentation_result(original, mask, size=(224, 224)):
    predicted_mask = mask[0, :, :, 0]
    binary_mask = (predicted_mask > 0.5).astype(np.uint8) * 255

    original_resized = np.array(original.resize(size))
    if original_resized.ndim == 2 or original_resized.shape[2] == 1:
        original_resized = cv2.cvtColor(original_resized, cv2.COLOR_GRAY2RGB)

    mask_colored = cv2.applyColorMap(binary_mask, cv2.COLORMAP_JET)
    overlay = cv2.addWeighted(original_resized, 0.6, mask_colored, 0.4, 0)

    
    fig, ax = plt.subplots(1, 3, figsize=(12, 4))
    ax[0].imshow(original_resized)
    ax[0].set_title("Input Image")
    ax[0].axis("off")

    ax[1].imshow(predicted_mask, cmap='gray')
    ax[1].set_title("Predicted Mask")
    ax[1].axis("off")

    ax[2].imshow(overlay)
    ax[2].set_title("Overlay")
    ax[2].axis("off")

    st.pyplot(fig)

st.title("Breast Detection & Segmentation")

uploaded_file = st.file_uploader("Upload a breast scan image", type=["jpg", "jpeg", "png"])

if uploaded_file:
    image = Image.open(uploaded_file).convert('RGB')
    st.image(image, caption="Uploaded Image", use_column_width=True)

    st.write("Processing...")

    breast_detector, breast_segmentor = load_models()

    image_for_classification = preprocess_rgb(image)

    #Breast tumor detection
    image_for_detection = preprocess_rgb(image, norm = False)
    prediction = breast_detector.predict(image_for_detection)
    predicted_class = np.argmax(prediction[0])
    class_names = ['Benign', ' Malignant', ' Normal']
    st.write(f"**Breast Tumor Type:** {class_names[predicted_class]}")
    st.write(f"**{class_names[predicted_class]} Probability:** `{prediction[0][predicted_class]:.2f}`")
    if predicted_class in [0, 1]:
            if st.checkbox("Run Breast Tumor Segmentation"):
                input_size = breast_segmentor.input_shape[1:3]
                image_for_segment = preprocess_rgb(image, size=input_size)
                mask = breast_segmentor.predict(image_for_segment)
                show_segmentation_result(image, mask, size=input_size)
