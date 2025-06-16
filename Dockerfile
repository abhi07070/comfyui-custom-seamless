# Use the official RunPod ComfyUI worker base
FROM runpod/worker-comfyui:5.1.0-base

# Install SeamlessTile custom node
WORKDIR /comfyui/custom_nodes
RUN git clone https://github.com/spinagon/ComfyUI-seamless-tiling.git

# Install dependencies for SeamlessTile
RUN pip install --no-cache-dir opencv-python-headless

# Create proper extra_model_paths.yaml configuration
RUN echo "comfyui:" > /comfyui/extra_model_paths.yaml && \
    echo "    base_path: /runpod-volume/" >> /comfyui/extra_model_paths.yaml && \
    echo "    checkpoints: models/checkpoints/" >> /comfyui/extra_model_paths.yaml && \
    echo "    vae: models/vae/" >> /comfyui/extra_model_paths.yaml && \
    echo "    loras: models/loras/" >> /comfyui/extra_model_paths.yaml && \
    echo "    embeddings: models/embeddings/" >> /comfyui/extra_model_paths.yaml && \
    echo "    controlnet: models/controlnet/" >> /comfyui/extra_model_paths.yaml && \
    echo "    unet: models/unet/" >> /comfyui/extra_model_paths.yaml && \
    echo "    clip_vision: models/clip_vision/" >> /comfyui/extra_model_paths.yaml

# Set proper working directory
WORKDIR /

# Download required checkpoint model
RUN wget -O /comfyui/models/checkpoints/realisticVisionV60B1_v51HyperVAE.safetensors \
    "https://huggingface.co/SG161222/Realistic_Vision_V6.0_B1_noVAE/resolve/main/Realistic_Vision_V6.0_NV_B1_fp16.safetensors"
