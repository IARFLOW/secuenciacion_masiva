# Secuenciacion Masiva - Pipelines de Bioinformatica

Repositorio de documentacion y configuracion para el analisis de secuenciacion de genoma completo de bacterias usando pipelines de [nf-core](https://nf-co.re/).

## Pipeline principal: nf-core/bacass v2.5.0

[nf-core/bacass](https://nf-co.re/bacass/2.5.0) es un pipeline para el ensamblaje de genomas bacterianos que incluye:

| Paso | Herramienta | Descripcion |
|------|-------------|-------------|
| QC de reads | FastQC | Control de calidad de las lecturas crudas |
| Trimming | FastP | Recorte de adaptadores y filtrado por calidad |
| Ensamblaje | Unicycler / Dragonflye | Ensamblaje de novo del genoma |
| Contaminacion | Kraken2 / KmerFinder | Deteccion de contaminacion taxonomica |
| Calidad ensamblaje | QUAST / BUSCO | Metricas de calidad y completitud del ensamblaje |
| Anotacion | **Bakta** | Anotacion funcional del genoma |
| Reporte | MultiQC | Reporte agregado de todos los pasos |

## Requisitos del sistema

- **Nextflow** >= 24.10.5
- **Java** >= 17
- **Docker Desktop** (para ejecutar las herramientas en contenedores)
- **macOS** (nativo) o **Windows** (requiere WSL2)

> No se necesita Conda. Todas las herramientas se ejecutan dentro de contenedores Docker.

## Quick Start (macOS)

```bash
# 1. Instalar Nextflow
curl -s https://get.nextflow.io | bash
chmod +x nextflow
mv nextflow $HOME/.local/bin/

# 2. Descargar el pipeline
nextflow pull nf-core/bacass -r 2.5.0

# 3. Ejecutar test de verificacion
nextflow run nf-core/bacass \
    -r 2.5.0 \
    -profile test,docker,arm \
    --annotation_tool bakta \
    --baktadb_download true \
    --outdir ./test_results

# 4. Ejecutar con datos reales
nextflow run nf-core/bacass \
    -r 2.5.0 \
    -profile docker,arm \
    --input samplesheet.tsv \
    --annotation_tool bakta \
    --assembly_type short \
    --outdir ./results
```

## Documentacion

| Documento | Descripcion |
|-----------|-------------|
| [Instalacion macOS](docs/01_instalacion_macos.md) | Guia paso a paso para macOS |
| [Instalacion Windows](docs/02_instalacion_windows.md) | Guia para Windows con WSL2 |
| [Uso del pipeline](docs/03_uso_pipeline_bacass.md) | Como ejecutar bacass con datos reales |
| [Formato samplesheet](docs/04_formato_samplesheet.md) | Como crear el archivo de entrada |
| [Interpretacion resultados](docs/05_interpretacion_resultados.md) | Que significan los outputs |
| [Troubleshooting](docs/06_troubleshooting.md) | Problemas comunes y soluciones |

## Estructura del repositorio

```
secuenciacion_masiva/
  docs/                  # Documentacion detallada
  samplesheets/          # Templates de samplesheets
  configs/               # Configuraciones de Nextflow personalizadas
  scripts/               # Scripts wrapper para ejecutar pipelines
```
