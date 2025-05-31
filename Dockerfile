FROM runpod/worker-comfyui:5.1.0-base

WORKDIR /ComfyUI/custom_nodes

RUN git clone https://github.com/spinagon/ComfyUI-seamless-tiling.git
RUN git clone https://github.com/Fannovel16/ComfyUI-iTools.git
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git

RUN pip install --no-cache-dir opencv-python-headless || echo "OpenCV install failed, continuing..."
RUN pip install --no-cache-dir matplotlib || echo "Matplotlib install failed, continuing..."

RUN for dir in */; do \
    if [ -f "$dir/requirements.txt" ]; then \
        echo "Installing requirements for $dir"; \
        pip install --no-cache-dir -r "$dir/requirements.txt" || echo "Failed to install $dir requirements, continuing..."; \
    fi; \
done

WORKDIR /
