FROM ls250824/run-comfyui-image:24032026

ENV DEBIAN_FRONTEND=noninteractive
ENV COMFYUI_DIR=/workspace/ComfyUI

RUN apt-get update -qq && apt-get install -y -qq git wget && \
    pip install -q gdown && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${COMFYUI_DIR}/custom_nodes \
             ${COMFYUI_DIR}/user/default/workflows

# ── Custom Nodes ──────────────────────────────────────────────────────────────
RUN cd ${COMFYUI_DIR}/custom_nodes && \
    git clone --depth=1 https://github.com/rgthree/rgthree-comfy && \
    git clone --depth=1 https://github.com/ltdrdata/ComfyUI-Impact-Pack && \
    git clone --depth=1 https://github.com/cubiq/ComfyUI_essentials && \
    git clone --depth=1 https://github.com/city96/ComfyUI-GGUF && \
    git clone --depth=1 https://github.com/ltdrdata/ComfyUI-Impact-Subpack && \
    git clone --depth=1 https://github.com/chrisgoringe/cg-use-everywhere

RUN for dir in rgthree-comfy ComfyUI-Impact-Pack ComfyUI_essentials ComfyUI-GGUF ComfyUI-Impact-Subpack cg-use-everywhere; do \
      REQ="${COMFYUI_DIR}/custom_nodes/${dir}/requirements.txt"; \
      if [ -f "$REQ" ]; then pip install -q -r "$REQ"; fi; \
    done

# ── Workflow ───────────────────────────────────────────────────────────────────
COPY workflow.json ${COMFYUI_DIR}/user/default/workflows/workflow.json

# ── Startup script ────────────────────────────────────────────────────────────
COPY setup_models.sh /setup_models.sh
RUN chmod +x /setup_models.sh

# ── Cleanup login ─────────────────────────────────────────────────────────────
RUN rm -rf ${COMFYUI_DIR}/ComfyUI-Login \
           ${COMFYUI_DIR}/ComfyUI-login

EXPOSE 8188
