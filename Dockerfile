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
RUN cd /ComfyUI && python -c "
import sys
import os
sys.path.append('/ComfyUI')
sys.path.append('/ComfyUI/custom_nodes/ComfyUI-seamless-tiling')

print('Testing ComfyUI node discovery...')

# Check if the main files exist
seamless_path = '/ComfyUI/custom_nodes/ComfyUI-seamless-tiling'
if os.path.exists(seamless_path):
    files = os.listdir(seamless_path)
    print(f'Files in seamless-tiling: {files}')
    
    # Look for the main node file
    for file in files:
        if file.endswith('.py') and file != '__init__.py':
            print(f'Found Python file: {file}')
            
            # Try to read and check for SeamlessTile class
            try:
                with open(os.path.join(seamless_path, file), 'r') as f:
                    content = f.read()
                    if 'SeamlessTile' in content:
                        print(f'✓ SeamlessTile found in {file}')
                    if 'NODE_CLASS_MAPPINGS' in content:
                        print(f'✓ NODE_CLASS_MAPPINGS found in {file}')
            except Exception as e:
                print(f'Error reading {file}: {e}')
else:
    print('❌ SeamlessTile directory not found!')
"

WORKDIR /
