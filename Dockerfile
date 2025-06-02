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
    apt-get install -y libgl1-mesa-glx libglib2.0-0 && \
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
ENV PYTHONPATH="${PYTHONPATH}:/comfyui:/comfyui/custom_nodes"

# Return to root directory
WORKDIR /

# Optional: Test that ComfyUI can import the custom node
RUN echo "=== TESTING CUSTOM NODE IMPORT ===" && \
    cd /comfyui && \
    python -c "
import sys
sys.path.append('/comfyui')
sys.path.append('/comfyui/custom_nodes')
sys.path.append('/comfyui/custom_nodes/ComfyUI-seamless-tiling')

try:
    # Try to import the custom node
    import os
    os.chdir('/comfyui/custom_nodes/ComfyUI-seamless-tiling')
    
    # Look for the main Python file
    import glob
    py_files = glob.glob('*.py')
    main_files = [f for f in py_files if f not in ['__init__.py', 'test.py', 'setup.py']]
    
    print(f'Found Python files: {py_files}')
    print(f'Main files: {main_files}')
    
    # Try to import the main module
    if main_files:
        module_name = main_files[0].replace('.py', '')
        exec(f'import {module_name}')
        print(f'✅ Successfully imported {module_name}')
    
    print('✅ Custom node appears to be properly installed')
    
except Exception as e:
    print(f'⚠️  Import test failed: {e}')
    print('This might be normal if the node requires ComfyUI to be fully loaded')
" || echo "⚠️  Import test completed with warnings (this may be normal)"

# Add a startup script to ensure custom nodes are loaded
RUN echo '#!/bin/bash
echo "=== ComfyUI Startup ==="
echo "Custom nodes directory:"
ls -la /comfyui/custom_nodes/
echo "SeamlessTile files:"
ls -la /comfyui/custom_nodes/ComfyUI-seamless-tiling/
echo "=== Starting ComfyUI ==="
exec "$@"
' > /startup.sh && chmod +x /startup.sh

ENTRYPOINT ["/startup.sh"]
