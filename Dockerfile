FROM runpod/worker-comfyui:5.1.0-base

# Use the correct custom_nodes path
WORKDIR /comfyui/custom_nodes

# Install SeamlessTile node with better error handling
RUN echo "Installing SeamlessTile custom node..." && \
    git clone https://github.com/spinagon/ComfyUI-seamless-tiling.git && \
    echo "Clone completed successfully"

# Install dependencies
RUN echo "Installing opencv..." && \
    pip install --no-cache-dir opencv-python-headless

# Install requirements if they exist
RUN cd ComfyUI-seamless-tiling && \
    echo "Current directory: $(pwd)" && \
    echo "Files in directory:" && \
    ls -la && \
    if [ -f requirements.txt ]; then \
        echo "Installing requirements..." && \
        pip install --no-cache-dir -r requirements.txt; \
    else \
        echo "No requirements.txt found"; \
    fi

# More comprehensive debug info
RUN echo "=== COMPREHENSIVE DEBUG INFO ===" && \
    echo "Contents of /comfyui/:" && \
    ls -la /comfyui/ && \
    echo "" && \
    echo "Contents of /comfyui/custom_nodes/:" && \
    ls -la /comfyui/custom_nodes/ && \
    echo "" && \
    echo "Contents of SeamlessTile directory:" && \
    ls -la /comfyui/custom_nodes/ComfyUI-seamless-tiling/ && \
    echo "" && \
    echo "Python files in SeamlessTile:" && \
    find /comfyui/custom_nodes/ComfyUI-seamless-tiling/ -name "*.py" && \
    echo "" && \
    echo "Check for NODE_CLASS_MAPPINGS:" && \
    find /comfyui/custom_nodes/ComfyUI-seamless-tiling/ -name "*.py" -exec grep -l "NODE_CLASS_MAPPINGS" {} \; && \
    echo "" && \
    echo "Check for __init__.py:" && \
    find /comfyui/custom_nodes/ComfyUI-seamless-tiling/ -name "__init__.py"

WORKDIR /
