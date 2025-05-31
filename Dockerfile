FROM runpod/worker-comfyui:5.1.0-base

WORKDIR /ComfyUI/custom_nodes

# Install SeamlessTile node only
RUN git clone https://github.com/spinagon/ComfyUI-seamless-tiling.git

# Install any dependencies
RUN pip install --no-cache-dir opencv-python-headless || true

# Install requirements if they exist
RUN cd ComfyUI-seamless-tiling && \
    if [ -f requirements.txt ]; then \
        pip install --no-cache-dir -r requirements.txt || true; \
    fi

WORKDIR /
