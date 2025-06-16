FROM runpod/worker-comfyui:5.1.0-base

# Install SeamlessTile custom node
WORKDIR /comfyui/custom_nodes
RUN git clone https://github.com/spinagon/ComfyUI-seamless-tiling.git

# Install dependencies
RUN pip install --no-cache-dir opencv-python-headless

# Ensure extra_model_paths.yaml points to network volume
RUN echo "comfyui:" > /comfyui/extra_model_paths.yaml && \
    echo "    base_path: /runpod-volume/" >> /comfyui/extra_model_paths.yaml && \
    echo "    checkpoints: models/checkpoints/" >> /comfyui/extra_model_paths.yaml && \
    echo "    loras: models/loras/" >> /comfyui/extra_model_paths.yaml && \
    echo "    vae: models/vae/" >> /comfyui/extra_model_paths.yaml

# Return to default working directory
WORKDIR /
