#!/bin/bash
# =============================================================================
# setup_models.sh
# Imagen base: ls250824/run-comfyui-image:24032026
# ComfyUI en imagen: /ComfyUI
# Network Volume: /workspace (persiste entre reinicios)
# =============================================================================

HF_TOKEN="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"
COMFYUI_DIR="/workspace/ComfyUI"

echo ""
echo "================================================"
echo "  ComfyUI Model Setup — jayman0602"
echo "================================================"

# PASO 1: Copiar ComfyUI al Network Volume si no tiene main.py
if [ ! -f "${COMFYUI_DIR}/main.py" ]; then
    echo "[ Copiando ComfyUI desde /ComfyUI → ${COMFYUI_DIR} ]"
    mkdir -p ${COMFYUI_DIR}
    cp -rn /ComfyUI/* ${COMFYUI_DIR}/
    echo "[ OK ComfyUI listo en ${COMFYUI_DIR} ]"
else
    echo "[ OK ComfyUI ya existe en ${COMFYUI_DIR} ]"
fi

# PASO 2: Crear carpetas de modelos
mkdir -p ${COMFYUI_DIR}/models/loras
mkdir -p ${COMFYUI_DIR}/models/checkpoints
mkdir -p ${COMFYUI_DIR}/models/diffusion_models
mkdir -p ${COMFYUI_DIR}/models/text_encoders
mkdir -p ${COMFYUI_DIR}/models/vae
mkdir -p ${COMFYUI_DIR}/models/sam3
mkdir -p ${COMFYUI_DIR}/models/ultralytics/bbox
mkdir -p ${COMFYUI_DIR}/models/ultralytics/segm

# ── Funciones ─────────────────────────────────────────────────────────────────
download_if_missing() {
    local url="$1"
    local dest="$2"
    local auth="$3"
    if [ -f "$dest" ] && [ -s "$dest" ]; then
        echo "  OK ya existe: $(basename $dest)"
        return 0
    fi
    echo "  Descargando: $(basename $dest)"
    if [ -n "$auth" ]; then
        wget -q --show-progress --header="Authorization: Bearer $auth" -O "$dest" "$url"
    else
        wget -q --show-progress -O "$dest" "$url"
    fi
    if [ $? -eq 0 ] && [ -s "$dest" ]; then
        echo "  OK: $(basename $dest)"
    else
        echo "  ERROR: $(basename $dest)"
        rm -f "$dest"
    fi
}

download_gdrive_if_missing() {
    local gdrive_id="$1"
    local dest="$2"
    if [ -f "$dest" ] && [ -s "$dest" ]; then
        echo "  OK ya existe: $(basename $dest)"
        return 0
    fi
    echo "  Google Drive: $(basename $dest)"
    gdown "https://drive.google.com/uc?id=${gdrive_id}" -O "$dest"
    if [ $? -eq 0 ] && [ -s "$dest" ]; then
        echo "  OK: $(basename $dest)"
    else
        echo "  ERROR: $(basename $dest)"
        rm -f "$dest"
    fi
}

download_civitai_if_missing() {
    local url="$1"
    local dest="$2"
    if [ -f "$dest" ] && [ -s "$dest" ]; then
        echo "  OK ya existe: $(basename $dest)"
        return 0
    fi
    echo "  CivitAI: $(basename $dest)"
    wget -q --show-progress -L -O "$dest" "$url"
    if [ $? -eq 0 ] && [ -s "$dest" ]; then
        echo "  OK: $(basename $dest)"
    else
        echo "  ERROR: $(basename $dest)"
        rm -f "$dest"
    fi
}

# ── LoRAs ─────────────────────────────────────────────────────────────────────
echo ""
echo "[ LoRAs ]"
rm -rf ${COMFYUI_DIR}/models/loras/split_files/

download_if_missing \
    "https://huggingface.co/exjadev/ayman0602-lora-SDXL/resolve/main/gjayman0602-000018.safetensors" \
    "${COMFYUI_DIR}/models/loras/gjayman0602-000018.safetensors"

download_gdrive_if_missing "1jfnA4BTH-N99Sye4iOfq6QJx3CiFRzVd" \
    "${COMFYUI_DIR}/models/loras/lora_v1_000002600.safetensors"

download_gdrive_if_missing "1ts-Ucv_fLsoPkJS_uahZpcfJJsznysK3" \
    "${COMFYUI_DIR}/models/loras/z_image_lora.safetensors"

# ── Checkpoints ───────────────────────────────────────────────────────────────
echo ""
echo "[ Checkpoints ]"
rm -rf ${COMFYUI_DIR}/models/checkpoints/split_files/

download_civitai_if_missing \
    "https://civitai.com/api/download/models/2755468?type=Model&format=SafeTensor&size=full&fp=fp16&token=e3a803e3831ec4832fd75d014b2d385e" \
    "${COMFYUI_DIR}/models/checkpoints/sdxl_nsfw.safetensors"

# ── Diffusion Models ──────────────────────────────────────────────────────────
echo ""
echo "[ Diffusion Models ]"
rm -rf ${COMFYUI_DIR}/models/diffusion_models/split_files/

download_if_missing \
    "https://huggingface.co/vantagewithai/Z-Image-Turbo-GGUF/resolve/main/z_image_turbo-bf16.gguf" \
    "${COMFYUI_DIR}/models/diffusion_models/z_image_turbo-bf16.gguf"

download_if_missing \
    "https://huggingface.co/vantagewithai/Z-Image-Turbo-GGUF/resolve/main/z_image_turbo-Q4_K_M.gguf" \
    "${COMFYUI_DIR}/models/diffusion_models/z_image_turbo-Q4_K_M.gguf"

download_if_missing \
    "https://huggingface.co/black-forest-labs/FLUX.2-klein-9b-fp8/resolve/main/flux-2-klein-9b-fp8.safetensors" \
    "${COMFYUI_DIR}/models/diffusion_models/flux-2-klein-9b-fp8.safetensors" \
    "$HF_TOKEN"

# ── Text Encoders ─────────────────────────────────────────────────────────────
echo ""
echo "[ Text Encoders ]"
rm -rf ${COMFYUI_DIR}/models/text_encoders/split_files/

download_if_missing \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors" \
    "${COMFYUI_DIR}/models/text_encoders/qwen_3_4b.safetensors"

download_if_missing \
    "https://huggingface.co/Comfy-Org/vae-text-encorder-for-flux-klein-9b/resolve/main/split_files/text_encoders/qwen_3_8b_fp8mixed.safetensors" \
    "${COMFYUI_DIR}/models/text_encoders/qwen_3_8b_fp8mixed.safetensors" \
    "$HF_TOKEN"

# ── BBOX Ultralytics ──────────────────────────────────────────────────────────
echo ""
echo "[ BBOX Ultralytics ]"

download_if_missing \
    "https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt" \
    "${COMFYUI_DIR}/models/ultralytics/bbox/face_yolov8m.pt"

# ── VAE ───────────────────────────────────────────────────────────────────────
echo ""
echo "[ VAE ]"
rm -rf ${COMFYUI_DIR}/models/vae/split_files/

download_if_missing \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors" \
    "${COMFYUI_DIR}/models/vae/ae.safetensors"

download_if_missing \
    "https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors" \
    "${COMFYUI_DIR}/models/vae/flux2-vae.safetensors"

# ── SAM3 ──────────────────────────────────────────────────────────────────────
echo ""
echo "[ SAM3 ]"

download_if_missing \
    "https://huggingface.co/facebook/sam3/resolve/main/sam3.pt" \
    "${COMFYUI_DIR}/models/sam3/sam3.pt" \
    "$HF_TOKEN"

download_if_missing \
    "https://huggingface.co/1038lab/sam3/resolve/main/sam3.safetensors" \
    "${COMFYUI_DIR}/models/sam3/sam3.safetensors"

# ── Lanzar ComfyUI ────────────────────────────────────────────────────────────
echo ""
echo "================================================"
echo "  Setup completo. Iniciando ComfyUI..."
echo "================================================"

exec python /workspace/ComfyUI/main.py --listen 0.0.0.0 --port 8188