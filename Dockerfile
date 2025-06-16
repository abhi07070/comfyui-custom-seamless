FROM runpod/worker-comfyui:5.1.0-base

# Install SeamlessTile custom node
WORKDIR /comfyui/custom_nodes
RUN git clone https://github.com/spinagon/ComfyUI-seamless-tiling.git

# Install dependencies
RUN pip install --no-cache-dir opencv-python-headless

# Return to default working directory
WORKDIR /
