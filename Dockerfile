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

# DEBUG: Show what we actually installed
RUN echo "=== DEBUGGING SEAMLESS TILE INSTALLATION ===" && \
    echo "Contents of custom_nodes:" && \
    ls -la /ComfyUI/custom_nodes/ && \
    echo "" && \
    echo "Contents of ComfyUI-seamless-tiling:" && \
    ls -la /ComfyUI/custom_nodes/ComfyUI-seamless-tiling/ && \
    echo "" && \
    echo "Python files in seamless-tiling:" && \
    find /ComfyUI/custom_nodes/ComfyUI-seamless-tiling -name "*.py" && \
    echo "" && \
    echo "Checking for NODE_CLASS_MAPPINGS:" && \
    grep -r "NODE_CLASS_MAPPINGS" /ComfyUI/custom_nodes/ComfyUI-seamless-tiling/ || echo "No NODE_CLASS_MAPPINGS found"

# Test if ComfyUI can see the nodes
RUN cd /ComfyUI && python -c "import sys, os; sys.path.append('/ComfyUI'); seamless_path = '/ComfyUI/custom_nodes/ComfyUI-seamless-tiling'; print('SeamlessTile directory exists:', os.path.exists(seamless_path)); files = os.listdir(seamless_path) if os.path.exists(seamless_path) else []; print('Python files:', [f for f in files if f.endswith('.py')])"

WORKDIR /
