# Interpretacion de Resultados

Guia para entender los outputs generados por nf-core/bacass.

## Estructura de salida

```
results/
  trimming/shortreads/       # Reads despues del trimming
  FastQC/                    # Reportes de calidad de reads
  Unicycler/                 # Ensamblajes
  QUAST/report/              # Metricas del ensamblaje
  busco/                     # Completitud del genoma
  Bakta/                     # Anotacion funcional
  kraken2/                   # Contaminacion (si se activo)
  multiqc/                   # Reporte agregado
  pipeline_info/             # Info de ejecucion
```

## 1. MultiQC Report (lo primero que revisar)

**Archivo:** `results/multiqc/multiqc_report.html`

Abrir en navegador:
```bash
open results/multiqc/multiqc_report.html
```

Este reporte HTML agrega todos los resultados de QC en un solo lugar. Incluye graficas interactivas de FastQC, trimming stats, metricas de ensamblaje y mas. **Es el mejor punto de partida para evaluar tus resultados.**

## 2. FastQC - Calidad de reads

**Directorio:** `results/FastQC/`

Cada muestra genera un reporte HTML. Indicadores clave:

| Metrica | Bueno | Preocupante |
|---------|-------|-------------|
| Per base sequence quality | Verde (>Q30) | Rojo (<Q20) |
| Per sequence quality scores | Pico >Q30 | Pico <Q20 |
| Sequence duplication levels | <20% duplicados | >50% duplicados |
| Adapter content | <5% | >10% |
| GC content | Distribucion normal | Multiples picos (contaminacion) |

**Q30** significa 1 error cada 1000 bases. Es el umbral minimo aceptable para la mayoria de analisis.

## 3. FastP - Trimming

**Directorio:** `results/trimming/shortreads/`

FastP genera reportes JSON y HTML con:
- Reads antes vs despues del trimming
- Porcentaje de reads que pasaron el filtro
- Bases y reads eliminados

**Valores esperados:**
- >90% de reads pasan el filtro
- Si <80% pasan, posible problema de calidad en la secuenciacion

## 4. Unicycler/Dragonflye - Ensamblaje

**Directorio:** `results/Unicycler/` o `results/Dragonflye/`

Archivos principales:
- `*.fasta` - El ensamblaje (contigs/scaffolds)
- `*.gfa` - Grafo de ensamblaje (visualizable con Bandage)

## 5. QUAST - Metricas del ensamblaje

**Directorio:** `results/QUAST/report/`

Abrir `report.html` para visualizacion interactiva. Metricas clave:

| Metrica | Descripcion | Valor ideal (bacteria) |
|---------|-------------|----------------------|
| # contigs | Numero de fragmentos del ensamblaje | <100 (idealmente <20) |
| Largest contig | Tamano del contig mas grande | >500 kb |
| Total length | Tamano total del ensamblaje | Similar al genoma esperado |
| N50 | 50% del ensamblaje esta en contigs >= este tamano | >100 kb |
| GC (%) | Contenido de GC | Coherente con la especie |

**Interpretacion del N50:**
- N50 alto = ensamblaje mas continuo (mejor)
- N50 bajo = ensamblaje mas fragmentado (peor)
- Para bacterias, N50 > 100 kb es bueno, N50 > 1 Mb es excelente

## 6. BUSCO - Completitud del genoma

**Directorio:** `results/busco/`

BUSCO evalua cuantos genes conservados esperados estan presentes en el ensamblaje.

| Categoria | Significado |
|-----------|-------------|
| Complete (C) | Genes encontrados completos |
| Single-copy (S) | Genes en una sola copia (lo esperado) |
| Duplicated (D) | Genes duplicados (posible contaminacion) |
| Fragmented (F) | Genes parcialmente encontrados |
| Missing (M) | Genes no encontrados |

**Valores esperados para bacterias:**
- Complete > 95% = Ensamblaje de alta calidad
- Complete 90-95% = Aceptable
- Complete < 90% = Posible problema (genoma incompleto o contaminado)
- Duplicated > 5% = Sospecha de contaminacion

## 7. Bakta - Anotacion funcional

**Directorio:** `results/Bakta/`

Archivos principales por muestra:
- `*.gff3` - Anotaciones en formato GFF3 (abrir con IGV o similar)
- `*.faa` - Secuencias de proteinas predichas
- `*.txt` - Resumen de la anotacion

El resumen (`.txt`) muestra:
- Numero de CDS (genes codificantes) predichos
- tRNAs y rRNAs encontrados
- Elementos regulatorios
- Otros features genomicos

**Valores tipicos para bacterias:**
- ~1 gen por cada 1 kb de genoma (ej: *E. coli* ~4600 genes en 4.6 Mb)

## 8. Kraken2 - Contaminacion

**Directorio:** `results/kraken2/` (solo si se activo con `--kraken2db`)

El reporte muestra la clasificacion taxonomica de los reads. Indicadores:

- **>90% reads clasificados como la especie esperada**: Muestra limpia
- **Multiples especies con >5%**: Posible contaminacion
- **<50% clasificados**: Base de datos incompleta o organismo no representado

## Flujo de trabajo para evaluar resultados

```
1. Abrir MultiQC report (vision general)
   |
2. Revisar FastQC (calidad de reads)
   |-- Si baja calidad → problema en secuenciacion
   |
3. Revisar QUAST (calidad del ensamblaje)
   |-- Si N50 bajo → reads cortos o baja cobertura
   |-- Si muchos contigs → genoma fragmentado
   |
4. Revisar BUSCO (completitud)
   |-- Si <90% complete → genoma incompleto
   |-- Si alto % duplicated → contaminacion
   |
5. Revisar Kraken2 (contaminacion)
   |-- Si multiples especies → contaminacion
   |
6. Revisar Bakta (anotacion)
   |-- Verificar numero de genes vs esperado
```
