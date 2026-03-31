# Instalacion en macOS

Guia paso a paso para configurar el entorno de bioinformatica en macOS (Intel y Apple Silicon).

## Requisitos previos

| Componente | Version minima | Como verificar |
|------------|---------------|----------------|
| macOS | 14 (Sonoma) o superior | `sw_vers` |
| Java | 17 o superior | `java -version` |
| Docker Desktop | Cualquier version reciente | `docker --version` |
| Git | Cualquier version | `git --version` |

## Paso 1: Instalar Java (si no esta instalado)

Verificar si ya tienes Java:

```bash
java -version
```

Si no esta instalado, descargar desde [Adoptium](https://adoptium.net/) (recomendado) o con Homebrew:

```bash
brew install openjdk@21
```

## Paso 2: Instalar Docker Desktop

1. Descargar Docker Desktop desde [docker.com](https://www.docker.com/products/docker-desktop/)
   - **Apple Silicon** (M1/M2/M3/M4): Descargar version "Apple Silicon"
   - **Intel**: Descargar version "Intel chip"
2. Instalar arrastrando a Aplicaciones
3. Abrir Docker Desktop
4. Configurar recursos: **Settings > Resources**
   - Memory: **8 GB minimo** (10 GB recomendado)
   - CPUs: **4 minimo**
   - Disk: 50 GB minimo

Verificar que Docker funciona:

```bash
docker info
```

## Paso 3: Instalar Rosetta 2 (solo Apple Silicon)

Solo necesario en Macs con chip M1/M2/M3/M4. Permite ejecutar contenedores x86 en ARM:

```bash
softwareupdate --install-rosetta --agree-to-license
```

## Paso 4: Instalar Nextflow

```bash
# Descargar Nextflow
curl -s https://get.nextflow.io | bash

# Hacer ejecutable
chmod +x nextflow

# Mover al PATH (elegir una opcion)

# Opcion A: Directorio local del usuario (recomendado)
mkdir -p $HOME/.local/bin
mv nextflow $HOME/.local/bin/

# Opcion B: Directorio del sistema
sudo mv nextflow /usr/local/bin/
```

Si usas la Opcion A, asegurarte de que `$HOME/.local/bin` esta en tu PATH. Anadir a `~/.zshrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Verificar la instalacion:

```bash
nextflow -version
# Debe mostrar version >= 24.10.5
```

## Paso 5: Descargar el pipeline bacass

```bash
nextflow pull nf-core/bacass -r 2.5.0
```

Esto descarga el pipeline en `~/.nextflow/assets/nf-core/bacass/`.

## Paso 6: Verificar la instalacion

Ejecutar el test integrado del pipeline:

```bash
# Para Apple Silicon (M1/M2/M3/M4):
nextflow run nf-core/bacass \
    -r 2.5.0 \
    -profile test,docker,arm \
    --annotation_tool bakta \
    --outdir ./test_results

# Para Intel Mac:
nextflow run nf-core/bacass \
    -r 2.5.0 \
    -profile test,docker \
    --annotation_tool bakta \
    --outdir ./test_results
```

**Importante:**
- La primera ejecucion tarda 15-45 minutos (descarga imagenes Docker)
- Si falla por memoria, anadir `-resume` para reintentar desde el ultimo paso exitoso
- El perfil `arm` es **obligatorio** en Apple Silicon, fuerza emulacion x86 para contenedores

Al finalizar, abrir el reporte MultiQC:

```bash
open test_results/multiqc/multiqc_report.html
```

## Resumen de comandos

```bash
# Instalacion completa en un Mac nuevo
softwareupdate --install-rosetta --agree-to-license  # Solo Apple Silicon
curl -s https://get.nextflow.io | bash
chmod +x nextflow && mv nextflow $HOME/.local/bin/
nextflow pull nf-core/bacass -r 2.5.0
nextflow run nf-core/bacass -r 2.5.0 -profile test,docker,arm --annotation_tool bakta --outdir ./test_results
```
