# Formato del Samplesheet

El samplesheet es el archivo de entrada que indica al pipeline que muestras procesar y donde estan los archivos de secuenciacion.

## Formato

- Archivo **TSV** (separado por tabulaciones, NO comas)
- Extension `.tsv`
- Primera linea: cabecera con nombres de columnas
- Sin espacios en los nombres de muestra

## Columnas

| Columna | Obligatoria | Descripcion |
|---------|-------------|-------------|
| `ID` | Si | Nombre de la muestra (sin espacios) |
| `R1` | No | Ruta al archivo FASTQ R1 (forward reads). Usar `NA` si no aplica |
| `R2` | No | Ruta al archivo FASTQ R2 (reverse reads). Usar `NA` si no aplica |
| `LongFastQ` | No | Ruta al archivo FASTQ de long reads (ONT). Usar `NA` si no aplica |
| `Fast5` | No | Ruta al directorio de archivos Fast5. Usar `NA` si no aplica |
| `GenomeSize` | No | Tamano estimado del genoma (ej: `4.6m`). Solo necesario para Canu. Usar `NA` si no aplica |

## Ejemplos

### Short reads (Illumina paired-end)

```
ID	R1	R2	LongFastQ	Fast5	GenomeSize
ecoli_01	/ruta/datos/ecoli01_R1.fastq.gz	/ruta/datos/ecoli01_R2.fastq.gz	NA	NA	NA
ecoli_02	/ruta/datos/ecoli02_R1.fastq.gz	/ruta/datos/ecoli02_R2.fastq.gz	NA	NA	NA
staph_01	/ruta/datos/staph01_R1.fastq.gz	/ruta/datos/staph01_R2.fastq.gz	NA	NA	NA
```

### Long reads (Oxford Nanopore)

```
ID	R1	R2	LongFastQ	Fast5	GenomeSize
ecoli_01	NA	NA	/ruta/datos/ecoli01_ont.fastq.gz	NA	4.6m
ecoli_02	NA	NA	/ruta/datos/ecoli02_ont.fastq.gz	NA	4.6m
```

### Hibrido (Illumina + ONT)

```
ID	R1	R2	LongFastQ	Fast5	GenomeSize
ecoli_01	/ruta/datos/ecoli01_R1.fastq.gz	/ruta/datos/ecoli01_R2.fastq.gz	/ruta/datos/ecoli01_ont.fastq.gz	NA	4.6m
```

## Reglas importantes

1. **Rutas absolutas**: Siempre usar rutas completas (`/Users/nombre/datos/...`), no relativas
2. **Sin espacios**: Los nombres de muestra NO pueden contener espacios
3. **Archivos gzipped**: Los FASTQ deben tener extension `.fastq.gz` o `.fq.gz`
4. **Usar NA**: Para columnas que no aplican, escribir exactamente `NA` (en mayusculas)
5. **Tabulaciones**: Separar columnas con Tab, NO con espacios ni comas

## Como crear el samplesheet

### Opcion 1: Copiar un template

Copiar uno de los templates incluidos y editarlo:

```bash
cp samplesheets/ejemplo_short_reads.tsv mi_samplesheet.tsv
# Editar con tu editor preferido
nano mi_samplesheet.tsv
```

### Opcion 2: Crear desde Excel/Sheets

1. Abrir Excel o Google Sheets
2. Crear las columnas: ID, R1, R2, LongFastQ, Fast5, GenomeSize
3. Rellenar los datos
4. Guardar como "Texto delimitado por tabulaciones (.tsv)"

### Verificar el formato

Para comprobar que el TSV es correcto:

```bash
# Ver el contenido
cat mi_samplesheet.tsv

# Contar columnas (debe ser 6 en cada linea)
awk -F'\t' '{print NF}' mi_samplesheet.tsv
```

## Tamanos de genoma comunes

| Bacteria | Tamano aproximado |
|----------|-------------------|
| *Escherichia coli* | 4.6m |
| *Staphylococcus aureus* | 2.8m |
| *Pseudomonas aeruginosa* | 6.3m |
| *Klebsiella pneumoniae* | 5.3m |
| *Salmonella enterica* | 4.8m |
| *Streptococcus pneumoniae* | 2.1m |
| *Mycobacterium tuberculosis* | 4.4m |
| *Bacillus subtilis* | 4.2m |
