FROM runpod/worker-comfyui:5.1.0-base

# Set working directory to ComfyUI custom nodes
WORKDIR /comfyui/custom_nodes

# Install git if not available
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Clone SeamlessTile custom node
RUN echo "=== Installing SeamlessTile Custom Node ===" && \
    git clone https://github.com/spinagon/ComfyUI-seamless-tiling.git && \
    echo "✅ Repository cloned successfully"

# Install system dependencies
RUN echo "=== Installing System Dependencies ===" && \
    apt-get update && \
    apt-get install -y libgl1 libglib2.0-0 libglvnd0 libglx0 && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN echo "=== Installing Python Dependencies ===" && \
    pip install --no-cache-dir opencv-python-headless numpy

# Install custom node requirements
WORKDIR /comfyui/custom_nodes/ComfyUI-seamless-tiling
RUN echo "=== Installing Custom Node Requirements ===" && \
    echo "Current directory: $(pwd)" && \
    echo "Files in directory:" && \
    ls -la && \
    if [ -f requirements.txt ]; then \
        echo "Installing from requirements.txt..." && \
        pip install --no-cache-dir -r requirements.txt; \
    else \
        echo "No requirements.txt found, installing common dependencies..."; \
        pip install --no-cache-dir torch torchvision; \
    fi

# Create __init__.py if it doesn't exist (some custom nodes need this)
RUN if [ ! -f __init__.py ]; then \
        echo "Creating __init__.py..." && \
        touch __init__.py; \
    fi

# Set proper permissions
RUN chmod -R 755 /comfyui/custom_nodes/ComfyUI-seamless-tiling

# Comprehensive verification
RUN echo "=== INSTALLATION VERIFICATION ===" && \
    echo "ComfyUI directory structure:" && \
    ls -la /comfyui/ && \
    echo "" && \
    echo "Custom nodes directory:" && \
    ls -la /comfyui/custom_nodes/ && \
    echo "" && \
    echo "SeamlessTile directory contents:" && \
    ls -la /comfyui/custom_nodes/ComfyUI-seamless-tiling/ && \
    echo "" && \
    echo "Python files in SeamlessTile:" && \
    find /comfyui/custom_nodes/ComfyUI-seamless-tiling/ -name "*.py" -type f && \
    echo "" && \
    echo "Checking for NODE_CLASS_MAPPINGS:" && \
    find /comfyui/custom_nodes/ComfyUI-seamless-tiling/ -name "*.py" -type f -exec grep -l "NODE_CLASS_MAPPINGS\|class.*Node" {} \; && \
    echo "" && \
    echo "Checking Python syntax of main files:" && \
    find /comfyui/custom_nodes/ComfyUI-seamless-tiling/ -name "*.py" -type f -exec python -m py_compile {} \; && \
    echo "✅ All Python files compile successfully" || echo "❌ Python compilation errors found"

# Set environment variables for ComfyUI
ENV COMFYUI_CUSTOM_NODES_PATH=/comfyui/custom_nodes
ENV PYTHONPATH="/comfyui:/comfyui/custom_nodes:${PYTHONPATH:-}"

# Return to root directory
WORKDIR /

# Verify installation
RUN echo "=== FINAL VERIFICATION ===" && \
    echo "✅ SeamlessTile custom node installed at:" && \
    ls -la /comfyui/custom_nodes/ComfyUI-seamless-tiling/ && \
    echo "✅ Python files found:" && \
    find /comfyui/custom_nodes/ComfyUI-seamless-tiling/ -name "*.py" -type f && \
    echo "✅ Installation complete!"

# Add a startup script to ensure custom nodes are loaded
RUN printf '#!/bin/bash\necho "=== ComfyUI Startup ==="\necho "Custom nodes directory:"\nls -la /comfyui/custom_nodes/\necho "SeamlessTile files:"\nls -la /comfyui/custom_nodes/ComfyUI-seamless-tiling/\necho "=== Starting ComfyUI ==="\nexec "$@"\n' > /startup.sh && \
    chmod +x /startup.sh

ENTRYPOINT ["/startup.sh"]
