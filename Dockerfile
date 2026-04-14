FROM ls250824/run-comfyui-image:24032026

ENV DEBIAN_FRONTEND=noninteractive
ENV COMFYUI_DIR=/workspace/ComfyUI
ENV OPT_COMFYUI=/opt/ComfyUI

RUN apt-get update -qq && apt-get install -y -qq git wget curl rsync && \
    pip install -q gdown && \
    rm -rf /var/lib/apt/lists/*

# ── Instalar ComfyUI en /opt (no en /workspace para evitar que el Network Volume lo oculte) ──
RUN git clone --depth=1 https://github.com/comfyanonymous/ComfyUI ${OPT_COMFYUI} && \
    pip install -q -r ${OPT_COMFYUI}/requirements.txt

# ── Custom Nodes ──────────────────────────────────────────────────────────────
RUN cd ${OPT_COMFYUI}/custom_nodes && \
    git clone --depth=1 https://github.com/rgthree/rgthree-comfy && \
    git clone --depth=1 https://github.com/ltdrdata/ComfyUI-Impact-Pack && \
    git clone --depth=1 https://github.com/cubiq/ComfyUI_essentials && \
    git clone --depth=1 https://github.com/city96/ComfyUI-GGUF && \
    git clone --depth=1 https://github.com/ltdrdata/ComfyUI-Impact-Subpack && \
    git clone --depth=1 https://github.com/chrisgoringe/cg-use-everywhere

RUN for dir in rgthree-comfy ComfyUI-Impact-Pack ComfyUI_essentials ComfyUI-GGUF ComfyUI-Impact-Subpack cg-use-everywhere; do \
      REQ="${OPT_COMFYUI}/custom_nodes/${dir}/requirements.txt"; \
      if [ -f "$REQ" ]; then pip install -q -r "$REQ"; fi; \
    done

# ── Cleanup login ─────────────────────────────────────────────────────────────
RUN rm -rf ${OPT_COMFYUI}/ComfyUI-Login \
           ${OPT_COMFYUI}/ComfyUI-login

# ── Workflow ───────────────────────────────────────────────────────────────────
RUN mkdir -p ${OPT_COMFYUI}/user/default/workflows
COPY workflow.json ${OPT_COMFYUI}/user/default/workflows/workflow.json

# ── Startup script ────────────────────────────────────────────────────────────
COPY setup_models.sh /setup_models.sh
RUN chmod +x /setup_models.sh

EXPOSE 8188

CMD ["/setup_models.sh"]
