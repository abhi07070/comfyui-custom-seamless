FROM runpod/worker-comfyui:5.1.0-base

# Use the correct custom_nodes path (lowercase)
WORKDIR /comfyui/custom_nodes

# Install SeamlessTile node
RUN git clone https://github.com/spinagon/ComfyUI-seamless-tiling.git

# Install dependencies
RUN pip install --no-cache-dir opencv-python-headless || true

# Install requirements if they exist
RUN cd ComfyUI-seamless-tiling && \
    if [ -f requirements.txt ]; then \
        pip install --no-cache-dir -r requirements.txt || true; \
    fi

# Debug: Show installation
RUN echo "=== DEBUG INFO ===" && \
    echo "Contents of /comfyui/custom_nodes/:" && \
    ls -la /comfyui/custom_nodes/ && \
    echo "" && \
    echo "Contents of SeamlessTile:" && \
    ls -la /comfyui/custom_nodes/ComfyUI-seamless-tiling/ && \
    echo "" && \
    echo "Check for NODE_CLASS_MAPPINGS:" && \
    grep -r "NODE_CLASS_MAPPINGS" /comfyui/custom_nodes/ComfyUI-seamless-tiling/ || echo "Not found"

WORKDIR /
