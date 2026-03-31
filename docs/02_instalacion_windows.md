# Instalacion en Windows

Nextflow **no funciona nativamente en Windows**. Requiere un entorno POSIX (Linux/macOS). La solucion oficial es **WSL2** (Windows Subsystem for Linux).

## Que es WSL2

WSL2 es un subsistema ligero de Linux integrado en Windows. **No es lo mismo** que instalar Ubuntu completo:
- Se ejecuta como una pestana mas dentro de Windows Terminal
- Comparte el sistema de archivos con Windows (acceso desde `/mnt/c/`)
- Usa muy pocos recursos cuando esta inactivo
- Se instala con un solo comando

## Requisitos previos

- Windows 10 version 2004+ o Windows 11
- Al menos 16 GB de RAM (recomendado)
- Al menos 50 GB de disco libre
- Virtualizacion habilitada en BIOS/UEFI

## Paso 1: Instalar WSL2

Abrir **PowerShell como Administrador** y ejecutar:

```powershell
wsl --install
```

Esto instala WSL2 con Ubuntu por defecto. Reiniciar el PC cuando lo pida.

Tras reiniciar, abrir "Ubuntu" desde el menu Inicio. Se pedira crear un usuario y contrasena para Linux.

Verificar la instalacion:

```powershell
wsl --list --verbose
```

Debe mostrar Ubuntu con VERSION 2.

## Paso 2: Instalar Docker Desktop

1. Descargar Docker Desktop desde [docker.com](https://www.docker.com/products/docker-desktop/)
2. Durante la instalacion, marcar **"Use WSL 2 based engine"**
3. Tras instalar, ir a **Settings > Resources > WSL Integration**
4. Activar la integracion con la distribucion Ubuntu

Verificar desde la terminal Ubuntu (WSL2):

```bash
docker info
```

## Paso 3: Instalar Java y Nextflow en WSL2

Abrir la terminal Ubuntu (WSL2) desde Windows Terminal y ejecutar:

```bash
# Actualizar paquetes
sudo apt update && sudo apt upgrade -y

# Instalar Java
sudo apt install -y default-jre

# Verificar Java
java -version

# Instalar Nextflow
curl -s https://get.nextflow.io | bash
chmod +x nextflow
sudo mv nextflow /usr/local/bin/

# Verificar Nextflow
nextflow -version
```

## Paso 4: Descargar el pipeline

```bash
nextflow pull nf-core/bacass -r 2.5.0
```

## Paso 5: Verificar la instalacion

```bash
# En Windows NO se usa el perfil 'arm' (es arquitectura x86_64)
nextflow run nf-core/bacass \
    -r 2.5.0 \
    -profile test,docker \
    --annotation_tool bakta \
    --outdir ./test_results
```

## Trabajar con archivos entre Windows y WSL2

Los archivos de Windows son accesibles desde WSL2 en `/mnt/c/`:

```bash
# Acceder a Descargas de Windows
ls /mnt/c/Users/TuUsuario/Downloads/

# Acceder a una carpeta de proyecto en Windows
cd /mnt/c/Users/TuUsuario/BioInformatica_proyecto/
```

**Recomendacion:** Para mejor rendimiento, guardar los datos de secuenciacion **dentro** del sistema de archivos de Linux (por ejemplo, en `~/data/`) en lugar de en `/mnt/c/`.

## Diferencias con macOS

| Aspecto | macOS | Windows (WSL2) |
|---------|-------|----------------|
| Perfil Docker | `-profile docker,arm` (Apple Silicon) | `-profile docker` |
| Terminal | Terminal.app o iTerm2 | Windows Terminal > pestana Ubuntu |
| Rutas de archivos | `/Users/nombre/...` | `/home/nombre/...` o `/mnt/c/...` |
| Docker | Docker Desktop nativo | Docker Desktop con backend WSL2 |

## Resumen de comandos

```powershell
# En PowerShell (Admin)
wsl --install
# Reiniciar PC
```

```bash
# En terminal Ubuntu (WSL2)
sudo apt update && sudo apt install -y default-jre
curl -s https://get.nextflow.io | bash
chmod +x nextflow && sudo mv nextflow /usr/local/bin/
nextflow pull nf-core/bacass -r 2.5.0
nextflow run nf-core/bacass -r 2.5.0 -profile test,docker --annotation_tool bakta --outdir ./test_results
```
