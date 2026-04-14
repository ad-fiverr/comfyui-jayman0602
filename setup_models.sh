#!/bin/bash
# =============================================================================
# setup_models.sh — Startup script para RunPod + ComfyUI
# Copia ComfyUI desde /opt si el Network Volume no lo tiene,
# descarga modelos faltantes, y lanza ComfyUI.
# =============================================================================

set -e

HF_TOKEN="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"
COMFYUI_DIR="/workspace/ComfyUI"
OPT_COMFYUI="/opt/ComfyUI"

echo ""
echo "================================================"
echo " ComfyUI Model Setup — jayman0602"
echo "================================================"

# ── PASO 1: Asegurar que ComfyUI existe en /workspace ─────────────────────────
# El Network Volume monta en /workspace y OCULTA lo que estaba en la imagen.
# Por eso instalamos ComfyUI en /opt y lo copiamos al arrancar.
if [ ! -f "${COMFYUI_DIR}/main.py" ]; then
    echo ""
    echo "[ ComfyUI no encontrado en /workspace — copiando desde /opt... ]"
    mkdir -p /workspace
    rsync -a --progress ${OPT_COMFYUI}/ ${COMFYUI_DIR}/
    echo "[ ✅ ComfyUI copiado a ${COMFYUI_DIR} ]"
else
    echo "[ ✓ ComfyUI ya existe en ${COMFYUI_DIR} ]"
fi

# ── PASO 2: Crear carpetas de modelos ─────────────────────────────────────────
mkdir -p ${COMFYUI_DIR}/models/loras
mkdir -p ${COMFYUI_DIR}/models/checkpoints
mkdir -p ${COMFYUI_DIR}/models/diffusion_models
mkdir -p ${COMFYUI_DIR}/models/text_encoders
mkdir -p ${COMFYUI_DIR}/models/vae
mkdir -p ${COMFYUI_DIR}/models/sam3

# ── Función de descarga ───────────────────────────────────────────────────────
download_if_missing() {
    local url="$1"
    local dest="$2"
    local auth="$3"

    if [ -f "$dest" ] && [ -s "$dest" ]; then
        echo "  ✓ Ya existe $(basename $dest)"
        return 0
    fi

    echo "  ↓ Descargando $(basename $dest)..."
    if [ -n "$auth" ]; then
        wget -q --show-progress --header="Authorization: Bearer $auth" -O "$dest" "$url" || {
            echo "  ❌ ERROR descargando $(basename $dest) (puede requerir aceptar términos en HuggingFace)"
            rm -f "$dest"
        }
    else
        wget -q --show-progress -O "$dest" "$url" || {
            echo "  ❌ ERROR descargando $(basename $dest)"
            rm -f "$dest"
        }
    fi

    if [ -f "$dest" ] && [ -s "$dest" ]; then
        echo "  ✅ OK $(basename $dest)"
    fi
}

download_gdrive_if_missing() {
    local gdrive_id="$1"
    local dest="$2"

    if [ -f "$dest" ] && [ -s "$dest" ]; then
        echo "  ✓ Ya existe $(basename $dest)"
        return 0
    fi

    echo "  ↓ Descargando $(basename $dest) desde Google Drive..."
    gdown "https://drive.google.com/uc?id=${gdrive_id}" -O "$dest" || {
        echo "  ❌ ERROR en Google Drive $(basename $dest) — puede tener límite de descargas, intenta más tarde"
        rm -f "$dest"
    }

    if [ -f "$dest" ] && [ -s "$dest" ]; then
        echo "  ✅ OK $(basename $dest)"
    fi
}

# ── LoRAs ─────────────────────────────────────────────────────────────────────
echo ""
echo "[ LoRAs ]"
rm -rf ${COMFYUI_DIR}/models/loras/split_files/

download_if_missing \
    "https://huggingface.co/exjadev/ayman0602-lora-SDXL/resolve/main/gjayman0602-000018.safetensors" \
    "${COMFYUI_DIR}/models/loras/gjayman0602-000018.safetensors"

download_gdrive_if_missing "1sBZqIw3xgpXt8XYy6IB_vCarU3QtFj1i" \
    "${COMFYUI_DIR}/models/loras/lora_drive1.safetensors"

download_gdrive_if_missing "1jfnA4BTH-N99Sye4iOfq6QJx3CiFRzVd" \
    "${COMFYUI_DIR}/models/loras/lora_drive2.safetensors"

download_gdrive_if_missing "1ts-Ucv_fLsoPkJS_uahZpcfJJsznysK3" \
    "${COMFYUI_DIR}/models/loras/z_image_lora.safetensors"

# ── Checkpoints ───────────────────────────────────────────────────────────────
echo ""
echo "[ Checkpoints ]"
rm -rf ${COMFYUI_DIR}/models/checkpoints/split_files/

download_gdrive_if_missing "13czw4KRrCdzWb3bM_3AZj2V3kwfBlilj" \
    "${COMFYUI_DIR}/models/checkpoints/checkpoint_main.safetensors"

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

# NOTA: flux-2-klein-9b-fp8 requiere aceptar términos en:
# https://huggingface.co/black-forest-labs/FLUX.2-klein-9b-fp8
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

# sam3.pt requiere acceso aprobado a facebook/sam3 — se omite si falla
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
echo ""

exec python /workspace/ComfyUI/main.py --listen 0.0.0.0 --port 8188
