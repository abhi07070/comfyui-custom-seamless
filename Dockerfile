FROM runpod/worker-comfyui:5.1.0-base

# Install SeamlessTile custom node
WORKDIR /comfyui/custom_nodes
RUN git clone https://github.com/spinagon/ComfyUI-seamless-tiling.git

# Install dependencies
RUN pip install --no-cache-dir opencv-python-headless

# Fix the model paths to point to network volume (CORRECTED)
RUN echo "comfyui:" > /comfyui/extra_model_paths.yaml && \
    echo "    base_path: /runpod-volume/" >> /comfyui/extra_model_paths.yaml && \
    echo "    checkpoints: ComfyUI/models/checkpoints/" >> /comfyui/extra_model_paths.yaml && \
    echo "    loras: ComfyUI/models/loras/" >> /comfyui/extra_model_paths.yaml && \
    echo "    vae: ComfyUI/models/vae/" >> /comfyui/extra_model_paths.yaml

WORKDIR /
