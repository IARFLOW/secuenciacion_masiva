#!/bin/bash
# =============================================================================
# run_bacass.sh - Ejecutar nf-core/bacass v2.5.0 en macOS Apple Silicon
#
# Uso:
#   bash scripts/run_bacass.sh <samplesheet.tsv> <output_dir> [assembly_type]
#
# Ejemplos:
#   bash scripts/run_bacass.sh samplesheets/mi_samplesheet.tsv ./results
#   bash scripts/run_bacass.sh samplesheets/mi_samplesheet.tsv ./results long
# =============================================================================

set -euo pipefail

SAMPLESHEET="${1:?Error: proporciona la ruta al samplesheet como primer argumento}"
OUTDIR="${2:?Error: proporciona el directorio de salida como segundo argumento}"
ASSEMBLY_TYPE="${3:-short}"

# Directorio del script (para encontrar configs)
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="${SCRIPT_DIR}/configs/custom_macos.config"

# Verificar que Docker esta corriendo
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker no esta corriendo. Abre Docker Desktop primero."
    exit 1
fi

# Verificar que el samplesheet existe
if [ ! -f "$SAMPLESHEET" ]; then
    echo "Error: No se encuentra el samplesheet: $SAMPLESHEET"
    exit 1
fi

# Detectar arquitectura
PROFILE="docker"
if [ "$(uname -m)" = "arm64" ]; then
    PROFILE="docker,arm"
fi

echo "============================================="
echo " nf-core/bacass v2.5.0"
echo " Samplesheet: $SAMPLESHEET"
echo " Output: $OUTDIR"
echo " Assembly: $ASSEMBLY_TYPE"
echo " Profile: $PROFILE"
echo " Anotacion: Bakta"
echo "============================================="

nextflow run nf-core/bacass \
    -r 2.5.0 \
    -profile "$PROFILE" \
    -c "$CONFIG" \
    --input "$(realpath "$SAMPLESHEET")" \
    --assembly_type "$ASSEMBLY_TYPE" \
    --annotation_tool bakta \
    --outdir "$OUTDIR" \
    -resume
