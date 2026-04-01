# Pipeline Manual con Docker (sin nf-core/bacass)

Guia para analizar muestras Illumina short-read paired-end ejecutando cada herramienta individualmente con Docker. Util cuando se quiere control total sobre los parametros o se trabaja con muestras sueltas.

## Imagenes Docker necesarias

```bash
quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0
community.wave.seqera.io/library/fastp:0.24.0--62c97b06e8447690
community.wave.seqera.io/library/unicycler:0.5.1--b9d21c454db1e56b
quay.io/biocontainers/quast:5.2.0--py39pl5321h2add14b_1
community.wave.seqera.io/library/busco_sepp:f2dbc18a2f7a5b64
quay.io/biocontainers/bakta:1.9.3--pyhdfd78af_0
quay.io/biocontainers/multiqc:1.19--pyhdfd78af_0
```

## Estructura de directorios

```
BioInformatica_proyecto/
  <muestra>_R1_001.fastq.gz       # Reads crudas R1
  <muestra>_R2_001.fastq.gz       # Reads crudas R2
  test_results/
    FastQC/
      raw_<muestra>/               # FastQC de reads crudas
      trim_<muestra>/              # FastQC post-trimming
    trimming/
      <muestra>/                   # Reads limpias + informes fastp
    Unicycler/
      <muestra>/                   # Ensamblado
    QUAST/
      <muestra>/                   # Metricas del ensamblado
    busco/
      <muestra>-bacteria_odb10-busco/
    Bakta/
      <muestra>/                   # Anotacion funcional
    multiqc/
      <muestra>/                   # Informe agregado final
```

## Paso 1 — FastQC en reads crudas

```bash
mkdir -p test_results/FastQC/raw_<muestra>

docker run --rm \
  -v $(pwd):/data \
  quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0 \
  fastqc \
  /data/<muestra>_R1_001.fastq.gz \
  /data/<muestra>_R2_001.fastq.gz \
  -o /data/test_results/FastQC/raw_<muestra>/ \
  -t 2

open test_results/FastQC/raw_<muestra>/<muestra>_R1_001_fastqc.html
open test_results/FastQC/raw_<muestra>/<muestra>_R2_001_fastqc.html
```

## Paso 2 — Trimming exhaustivo con fastp

```bash
mkdir -p test_results/trimming/<muestra>

docker run --rm \
  -v $(pwd):/data \
  community.wave.seqera.io/library/fastp:0.24.0--62c97b06e8447690 \
  fastp \
  -i /data/<muestra>_R1_001.fastq.gz \
  -I /data/<muestra>_R2_001.fastq.gz \
  -o /data/test_results/trimming/<muestra>/<muestra>_R1_trimmed.fastq.gz \
  -O /data/test_results/trimming/<muestra>/<muestra>_R2_trimmed.fastq.gz \
  -j /data/test_results/trimming/<muestra>/fastp.json \
  -h /data/test_results/trimming/<muestra>/fastp.html \
  --cut_front \
  --cut_tail \
  --cut_mean_quality 20 \
  --qualified_quality_phred 20 \
  --unqualified_percent_limit 20 \
  --length_required 50 \
  --trim_front1 15 \
  --trim_front2 15 \
  --thread 4

open test_results/trimming/<muestra>/fastp.html
```

### Parametros clave explicados

| Parametro | Valor | Razon |
|-----------|-------|-------|
| `--trim_front1/2` | 15 | Elimina artefacto de random hexamer priming en las primeras bases |
| `--cut_front` / `--cut_tail` | - | Ventana deslizante que recorta extremos de baja calidad |
| `--cut_mean_quality` | 20 | Calidad minima de la ventana deslizante |
| `--qualified_quality_phred` | 20 | Calidad minima por base individual |
| `--unqualified_percent_limit` | 20 | Maximo 20% de bases por debajo del umbral |
| `--length_required` | 50 | Descartar reads que queden muy cortas tras el corte |

### Valores esperados tras el trimming

- R1: Q20 > 97%, Q30 > 90%
- R2: Q20 > 85%, Q30 > 70% (siempre peor que R1, es normal en Illumina)
- Reads conservadas: ~50-60% con trimming exhaustivo es aceptable

## Paso 3 — FastQC post-trimming

```bash
mkdir -p test_results/FastQC/trim_<muestra>

docker run --rm \
  -v $(pwd):/data \
  quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0 \
  fastqc \
  /data/test_results/trimming/<muestra>/<muestra>_R1_trimmed.fastq.gz \
  /data/test_results/trimming/<muestra>/<muestra>_R2_trimmed.fastq.gz \
  -o /data/test_results/FastQC/trim_<muestra>/ \
  -t 2

open test_results/FastQC/trim_<muestra>/<muestra>_R1_trimmed_fastqc.html
open test_results/FastQC/trim_<muestra>/<muestra>_R2_trimmed_fastqc.html
```

### FAILs esperados y no preocupantes

- **Per base sequence content**: Normal en Illumina, artefacto de primeras bases.
- **Per sequence GC content**: Depende del organismo. No es problema tecnico.
- **Per base sequence quality en R2**: La cola 3' siempre degrada en Illumina.

## Paso 4 — Ensamblado con Unicycler

```bash
mkdir -p test_results/Unicycler/<muestra>

docker run --rm \
  -v $(pwd):/data \
  community.wave.seqera.io/library/unicycler:0.5.1--b9d21c454db1e56b \
  unicycler \
  -1 /data/test_results/trimming/<muestra>/<muestra>_R1_trimmed.fastq.gz \
  -2 /data/test_results/trimming/<muestra>/<muestra>_R2_trimmed.fastq.gz \
  -o /data/test_results/Unicycler/<muestra>/ \
  --threads 4
```

Tarda entre 15-40 minutos. El resultado principal es `assembly.fasta`.

**Nota:** Con solo short-reads el ensamblado quedara siempre `incomplete` (fragmentado en contigs). Es normal. Para cerrar el genoma se necesitarian long-reads (Nanopore/PacBio).

## Paso 5 — QUAST (calidad del ensamblado)

```bash
mkdir -p test_results/QUAST/<muestra>

docker run --rm \
  -v $(pwd):/data \
  quay.io/biocontainers/quast:5.2.0--py39pl5321h2add14b_1 \
  quast.py \
  /data/test_results/Unicycler/<muestra>/assembly.fasta \
  -o /data/test_results/QUAST/<muestra>/ \
  --threads 4

open test_results/QUAST/<muestra>/report.html
```

### Valores de referencia para bacterias

| Metrica | Bueno | Aceptable |
|---------|-------|-----------|
| N50 | > 400 kb | > 100 kb |
| L50 | < 10 contigs | < 30 contigs |
| Contigs totales | < 100 | < 300 |
| GC% | Coherente con la especie | - |

## Paso 6 — BUSCO (completitud genica)

```bash
docker run --rm \
  -v $(pwd):/data \
  community.wave.seqera.io/library/busco_sepp:f2dbc18a2f7a5b64 \
  busco \
  -i /data/test_results/Unicycler/<muestra>/assembly.fasta \
  -o <muestra>-bacteria_odb10-busco \
  --out_path /data/test_results/busco/ \
  -m genome \
  -l bacteria_odb10 \
  --offline \
  --download_path /data/test_results/busco/busco_downloads \
  --cpu 4
```

### Interpretacion

| Resultado | Significado |
|-----------|-------------|
| C > 98% | Ensamblado excelente |
| C 95-98% | Muy bueno |
| C 90-95% | Aceptable |
| C < 90% | Posible problema |
| D > 5% | Sospechar contaminacion |

## Paso 7 — Anotacion con Bakta

```bash
# Base de datos light en: work/90/2ec70e2e779bfd598d5b87d4998e37/db-light/

docker run --rm \
  -v $(pwd):/data \
  quay.io/biocontainers/bakta:1.9.3--pyhdfd78af_0 \
  bakta \
  /data/test_results/Unicycler/<muestra>/assembly.fasta \
  --db /data/work/90/2ec70e2e779bfd598d5b87d4998e37/db-light \
  --output /data/test_results/Bakta/<muestra>/ \
  --prefix <muestra> \
  --force \
  --threads 4

open test_results/Bakta/<muestra>/<muestra>.png
```

### Archivos de salida principales

| Archivo | Uso |
|---------|-----|
| `<muestra>.gbff` | GenBank — abrir en Geneious/Artemis |
| `<muestra>.gff3` | Anotaciones para IGV u otras herramientas |
| `<muestra>.tsv` | Tabla de genes — abrir en Excel |
| `<muestra>.faa` | Proteinas predichas en FASTA |
| `<muestra>.png` | Mapa circular del genoma |
| `<muestra>.txt` | Resumen de la anotacion |

### Valores tipicos bacterias

- ~1 gen por kb (ej: 6 Mb → ~6000 CDSs)
- Hipoteticos < 15% es bueno
- tRNAs: 40-90, rRNAs: 3-15

## Paso 8 — MultiQC (informe final agregado)

```bash
docker run --rm \
  -v $(pwd):/data \
  quay.io/biocontainers/multiqc:1.19--pyhdfd78af_0 \
  multiqc \
  /data/test_results/FastQC/raw_<muestra>/ \
  /data/test_results/FastQC/trim_<muestra>/ \
  /data/test_results/trimming/<muestra>/ \
  -o /data/test_results/multiqc/<muestra>/ \
  --force

open test_results/multiqc/<muestra>/multiqc_report.html
```

## Archivos para entregar

Archivos esenciales para compartir con el equipo:

```
test_results/
  multiqc/<muestra>/multiqc_report.html    # Informe QC completo
  QUAST/<muestra>/report.html              # Calidad del ensamblado
  QUAST/<muestra>/report.pdf
  busco/<muestra>-bacteria_odb10-busco/    # Completitud genica
  Bakta/<muestra>/<muestra>.gbff           # Anotacion (GenBank)
  Bakta/<muestra>/<muestra>.gff3           # Anotacion (GFF3)
  Bakta/<muestra>/<muestra>.tsv            # Tabla de genes
  Bakta/<muestra>/<muestra>.png            # Mapa circular
  Bakta/<muestra>/<muestra>.txt            # Resumen anotacion
  Unicycler/<muestra>/assembly.fasta       # Genoma ensamblado
```
