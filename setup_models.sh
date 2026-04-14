#!/bin/bash
# =============================================================================
# setup_models.sh — Descarga modelos al Network Volume de RunPod
# Se ejecuta una vez al arrancar el pod. Si los archivos ya existen, los salta.
# =============================================================================

HF_TOKEN="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"
COMFYUI_DIR="/workspace/ComfyUI"

echo "================================================"
echo " ComfyUI Model Setup — jayman0602"
echo "================================================"

# Función: descarga solo si el archivo NO existe o está incompleto
download_if_missing() {
    local url="$1"
    local dest="$2"
    local auth="$3"

    if [ -f "$dest" ] && [ -s "$dest" ]; then
        echo "  ✓ Ya existe: $(basename $dest)"
        return 0
    fi

    echo "  ↓ Descargando: $(basename $dest)"
    if [ -n "$auth" ]; then
        wget -q --show-progress --header="Authorization: Bearer $auth" -O "$dest" "$url"
    else
        wget -q --show-progress -O "$dest" "$url"
    fi

    if [ $? -eq 0 ]; then
        echo "  ✅ OK: $(basename $dest)"
    else
        echo "  ❌ ERROR: $(basename $dest)"
    fi
}

# Crear carpetas
mkdir -p ${COMFYUI_DIR}/models/loras
mkdir -p ${COMFYUI_DIR}/models/checkpoints
mkdir -p ${COMFYUI_DIR}/models/diffusion_models
mkdir -p ${COMFYUI_DIR}/models/text_encoders
mkdir -p ${COMFYUI_DIR}/models/vae
mkdir -p ${COMFYUI_DIR}/models/sam3

# ── LoRAs ─────────────────────────────────────────────────────────────────────
echo ""
echo "[ LoRAs ]"
cd ${COMFYUI_DIR}/models/loras && rm -rf split_files/

download_if_missing \
    "https://huggingface.co/exjadev/ayman0602-lora-SDXL/resolve/main/gjayman0602-000018.safetensors" \
    "${COMFYUI_DIR}/models/loras/gjayman0602-000018.safetensors"

# Google Drive LoRAs
if [ ! -f "${COMFYUI_DIR}/models/loras/lora_drive1.safetensors" ] || [ ! -s "${COMFYUI_DIR}/models/loras/lora_drive1.safetensors" ]; then
    echo "  ↓ Descargando lora_drive1 desde Google Drive"
    gdown "https://drive.google.com/uc?id=1sBZqIw3xgpXt8XYy6IB_vCarU3QtFj1i" -O "${COMFYUI_DIR}/models/loras/lora_drive1.safetensors"
fi

if [ ! -f "${COMFYUI_DIR}/models/loras/lora_drive2.safetensors" ] || [ ! -s "${COMFYUI_DIR}/models/loras/lora_drive2.safetensors" ]; then
    echo "  ↓ Descargando lora_drive2 desde Google Drive"
    gdown "https://drive.google.com/uc?id=1jfnA4BTH-N99Sye4iOfq6QJx3CiFRzVd" -O "${COMFYUI_DIR}/models/loras/lora_drive2.safetensors"
fi

if [ ! -f "${COMFYUI_DIR}/models/loras/z_image_lora.safetensors" ] || [ ! -s "${COMFYUI_DIR}/models/loras/z_image_lora.safetensors" ]; then
    echo "  ↓ Descargando z_image_lora desde Google Drive"
    gdown "https://drive.google.com/uc?id=1ts-Ucv_fLsoPkJS_uahZpcfJJsznysK3" -O "${COMFYUI_DIR}/models/loras/z_image_lora.safetensors"
fi

# ── Checkpoint ────────────────────────────────────────────────────────────────
echo ""
echo "[ Checkpoints ]"
cd ${COMFYUI_DIR}/models/checkpoints && rm -rf split_files/

if [ ! -f "${COMFYUI_DIR}/models/checkpoints/checkpoint_main.safetensors" ] || [ ! -s "${COMFYUI_DIR}/models/checkpoints/checkpoint_main.safetensors" ]; then
    echo "  ↓ Descargando checkpoint desde Google Drive"
    gdown "https://drive.google.com/uc?id=13czw4KRrCdzWb3bM_3AZj2V3kwfBlilj" -O "${COMFYUI_DIR}/models/checkpoints/checkpoint_main.safetensors"
fi

# ── Diffusion Models ──────────────────────────────────────────────────────────
echo ""
echo "[ Diffusion Models ]"
cd ${COMFYUI_DIR}/models/diffusion_models && rm -rf split_files/

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
cd ${COMFYUI_DIR}/models/text_encoders && rm -rf split_files/

download_if_missing \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors" \
    "${COMFYUI_DIR}/models/text_encoders/qwen_3_4b.safetensors"

download_if_missing \
    "https://huggingface.co/Comfy-Org/vae-text-encorder-for-flux-klein-9b/resolve/main/split_files/text_encoders/qwen_3_8b_fp8mixed.safetensors" \
    "${COMFYUI_DIR}/models/text_encoders/qwen_3_8b_fp8mixed.safetensors" \
    "$HF_TOKEN"

# ── VAE ───────────────────────────────────────────────────────────────────────
echo ""
echo "[ VAE ]"
cd ${COMFYUI_DIR}/models/vae && rm -rf split_files/

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
echo " ✅ Modelos listos. Iniciando ComfyUI..."
echo "================================================"

exec python ${COMFYUI_DIR}/main.py --listen 0.0.0.0 --port 8188
