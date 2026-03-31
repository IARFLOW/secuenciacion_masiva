# Uso del pipeline nf-core/bacass

Guia para ejecutar el pipeline bacass con datos reales de secuenciacion.

## Tipos de analisis soportados

| Tipo | Descripcion | Parametro |
|------|-------------|-----------|
| Short reads | Illumina paired-end (R1 + R2) | `--assembly_type short` |
| Long reads | Oxford Nanopore (ONT) | `--assembly_type long` |
| Hibrido | Illumina + ONT combinados | `--assembly_type hybrid` |

## Ejecucion basica

### 1. Preparar el samplesheet

Crear un archivo TSV (separado por tabulaciones) con las muestras. Ver [formato samplesheet](04_formato_samplesheet.md) para detalles.

### 2. Ejecutar el pipeline

**Short reads (Illumina):**

```bash
nextflow run nf-core/bacass \
    -r 2.5.0 \
    -profile docker,arm \
    --input samplesheet.tsv \
    --assembly_type short \
    --annotation_tool bakta \
    --outdir ./results \
    -resume
```

**Long reads (ONT):**

```bash
nextflow run nf-core/bacass \
    -r 2.5.0 \
    -profile docker,arm \
    --input samplesheet.tsv \
    --assembly_type long \
    --annotation_tool bakta \
    --outdir ./results \
    -resume
```

**Hibrido (Illumina + ONT):**

```bash
nextflow run nf-core/bacass \
    -r 2.5.0 \
    -profile docker,arm \
    --input samplesheet.tsv \
    --assembly_type hybrid \
    --annotation_tool bakta \
    --outdir ./results \
    -resume
```

### 3. Parametros importantes

| Parametro | Descripcion | Valor por defecto |
|-----------|-------------|-------------------|
| `--input` | Ruta al samplesheet TSV | Obligatorio |
| `--outdir` | Directorio de salida | `./results` |
| `--assembly_type` | Tipo de ensamblaje: `short`, `long`, `hybrid` | `short` |
| `--annotation_tool` | Herramienta de anotacion: `bakta`, `prokka`, `dfast` | `prokka` |
| `--kraken2db` | Ruta a base de datos Kraken2 (contaminacion) | Desactivado |
| `--baktadb` | Ruta a base de datos Bakta (anotacion) | Usa test DB |
| `-resume` | Reiniciar desde ultimo paso exitoso | Desactivado |
| `-profile` | Perfiles de ejecucion | Obligatorio |

### 4. Perfiles disponibles

Siempre usar al menos `docker` (o `singularity`). En Apple Silicon anadir `arm`:

```bash
# macOS Apple Silicon
-profile docker,arm

# macOS Intel o Windows (WSL2)
-profile docker

# Servidor con Singularity
-profile singularity
```

## Activar deteccion de contaminacion (Kraken2)

Kraken2 necesita una base de datos. Descargar la version mini (~8 GB):

```bash
mkdir -p databases
cd databases
wget https://genome-idx.s3.amazonaws.com/kraken/minikraken2_v1_8GB.tar.gz
tar -xzf minikraken2_v1_8GB.tar.gz
```

Luego usar:

```bash
nextflow run nf-core/bacass \
    -r 2.5.0 \
    -profile docker,arm \
    --input samplesheet.tsv \
    --assembly_type short \
    --annotation_tool bakta \
    --kraken2db /ruta/completa/a/minikraken2_v1_8GB \
    --outdir ./results \
    -resume
```

## Base de datos Bakta (para datos reales)

El test profile incluye una DB de prueba, pero para datos reales necesitas la base de datos completa:

```bash
# Descargar DB light (~1.4 GB, suficiente para la mayoria de analisis)
# Desde: https://zenodo.org/records/10522951
mkdir -p databases/bakta
cd databases/bakta
wget https://zenodo.org/records/10522951/files/db-light.tar.gz
tar -xzf db-light.tar.gz
```

Luego usar con `--baktadb /ruta/completa/a/databases/bakta/db-light`.

## Usar configuracion personalizada

Para limitar los recursos (importante en equipos con poca RAM):

```bash
nextflow run nf-core/bacass \
    -r 2.5.0 \
    -profile docker,arm \
    -c configs/custom_macos.config \
    --input samplesheet.tsv \
    --annotation_tool bakta \
    --outdir ./results \
    -resume
```

## Script wrapper

Para simplificar la ejecucion, usar el script incluido:

```bash
bash scripts/run_bacass.sh samplesheet.tsv ./results
```

Ver [scripts/run_bacass.sh](../scripts/run_bacass.sh) para detalles.

## Flag -resume

El flag `-resume` es fundamental. Si el pipeline falla a mitad de ejecucion:
- Sin `-resume`: empieza todo de nuevo desde cero
- Con `-resume`: continua desde el ultimo paso exitoso

Siempre usar `-resume` a menos que quieras forzar una ejecucion limpia.

## Monitorizar la ejecucion

Mientras el pipeline se ejecuta, Nextflow muestra el progreso en la terminal. Al finalizar genera:
- `results/pipeline_info/execution_report*.html` - Reporte detallado de ejecucion
- `results/pipeline_info/execution_timeline*.html` - Linea temporal de cada proceso
- `results/pipeline_info/execution_trace*.txt` - Trazas de recursos utilizados
