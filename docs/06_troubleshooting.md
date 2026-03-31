# Troubleshooting

Problemas comunes y sus soluciones al usar nf-core/bacass.

## Errores de instalacion

### "command not found: nextflow"

Nextflow no esta en el PATH. Soluciones:

```bash
# Verificar donde esta instalado
which nextflow
ls $HOME/.local/bin/nextflow

# Si no esta en PATH, anadir a ~/.zshrc (macOS) o ~/.bashrc (Linux/WSL2)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### "Cannot connect to the Docker daemon"

Docker Desktop no esta corriendo:

```bash
# macOS
open -a Docker

# Verificar que arranco
docker info
```

En Windows, abrir Docker Desktop desde el menu Inicio y esperar a que el icono muestre "Running".

### "Java version not found" o version incorrecta

```bash
java -version
# Si muestra < 17, instalar version nueva:

# macOS con Homebrew
brew install openjdk@21

# WSL2/Linux
sudo apt install -y default-jre
```

## Errores durante la ejecucion

### Pipeline falla a mitad de ejecucion

Usar `-resume` para continuar desde el ultimo paso exitoso:

```bash
nextflow run nf-core/bacass -r 2.5.0 -profile test,docker,arm --annotation_tool bakta --baktadb_download true --outdir ./test_results -resume
```

### Error de memoria: "Process exceeded memory limit"

El proceso necesita mas RAM de la disponible. Opciones:

1. **Aumentar memoria en Docker Desktop**: Settings > Resources > Memory
2. **Usar config personalizada** que limita recursos:

```bash
nextflow run nf-core/bacass -r 2.5.0 \
    -profile docker,arm \
    -c configs/custom_macos.config \
    --input samplesheet.tsv \
    --annotation_tool bakta \
    --outdir ./results \
    -resume
```

3. **Cerrar otras aplicaciones** para liberar RAM

### Error ARM/x86: contenedor falla en Apple Silicon

Verificar:

1. Rosetta 2 esta instalada:
```bash
softwareupdate --install-rosetta --agree-to-license
```

2. Usar perfil `arm`:
```bash
-profile docker,arm
```

3. Docker Desktop tiene la emulacion activada:
   Settings > General > "Use Rosetta for x86_64/amd64 emulation on Apple Silicon" debe estar activado

### "No such file: samplesheet.tsv"

Usar ruta absoluta al samplesheet:

```bash
# Mal
--input samplesheet.tsv

# Bien
--input /Users/nombre/proyecto/samplesheet.tsv
```

### Error en Bakta: "Database not found"

Para datos reales, necesitas descargar la base de datos de Bakta:

```bash
mkdir -p databases/bakta
cd databases/bakta
wget https://zenodo.org/records/10522951/files/db-light.tar.gz
tar -xzf db-light.tar.gz
```

Luego usar `--baktadb /ruta/completa/databases/bakta/db-light`.

El test profile incluye una DB de prueba que se descarga automaticamente.

## Problemas de rendimiento

### La ejecucion es muy lenta

- **Primera ejecucion**: Es normal que tarde 15-45 min (descarga imagenes Docker)
- **Apple Silicon**: La emulacion x86 es ~2-3x mas lenta que nativo
- **Poca RAM**: Si Docker tiene <8 GB, los procesos se ejecutan mas lento

### El disco se llena

El directorio `work/` acumula archivos intermedios. Limpiar tras una ejecucion exitosa:

```bash
# Ver tamano
du -sh work/

# Limpiar archivos intermedios (solo si el pipeline termino exitosamente)
nextflow clean -f
```

## Problemas con el samplesheet

### "Malformed samplesheet"

Verificar:
- Separadores son tabulaciones (Tab), NO espacios
- Sin espacios en nombres de muestra
- Valores vacios son `NA`, no celdas vacias
- La cabecera es exactamente: `ID	R1	R2	LongFastQ	Fast5	GenomeSize`

```bash
# Ver si hay tabulaciones
cat -A mi_samplesheet.tsv
# ^I = tabulacion, $ = fin de linea
```

### Archivos FASTQ no encontrados

- Verificar que las rutas son absolutas
- Verificar que los archivos existen: `ls -la /ruta/al/archivo.fastq.gz`
- Verificar permisos: `chmod 644 /ruta/al/archivo.fastq.gz`

## Contacto y ayuda adicional

- **Documentacion oficial**: https://nf-co.re/bacass/2.5.0
- **GitHub issues**: https://github.com/nf-core/bacass/issues
- **Slack nf-core**: https://nf-co.re/join (canal #bacass)
