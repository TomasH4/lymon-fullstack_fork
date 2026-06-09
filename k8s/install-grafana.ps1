# ============================================================
#  Script de instalacion de Grafana + Prometheus en Minikube
#  Proyecto: Lymon Fullstack
# ============================================================
#  USO: Ejecutar con Docker Desktop y Minikube corriendo.
#       .\install-grafana.ps1
# ============================================================

$ErrorActionPreference = "Stop"

function Write-Step([string]$Message) {
    Write-Host ""
    Write-Host ">>> $Message" -ForegroundColor Cyan
}

function Write-Ok([string]$Message) {
    Write-Host "OK  $Message" -ForegroundColor Green
}

function Write-Fail([string]$Message) {
    Write-Host "ERR $Message" -ForegroundColor Red
}

# ----------------------------------------------------------
# 1. Verificar Docker
# ----------------------------------------------------------
Write-Step "Verificando Docker..."
try {
    docker info | Out-Null
    Write-Ok "Docker esta corriendo."
} catch {
    Write-Fail "Docker Desktop no esta corriendo. Por favor abrelo y espera que arranque."
    exit 1
}

# ----------------------------------------------------------
# 2. Verificar Minikube
# ----------------------------------------------------------
Write-Step "Verificando Minikube..."
$minikubeStatus = (minikube status --format="{{.Host}}" 2>&1)
if ($minikubeStatus -ne "Running") {
    Write-Host "Minikube no esta corriendo. Iniciando..." -ForegroundColor Yellow
    minikube start --memory=4096 --cpus=2
    Write-Ok "Minikube iniciado."
} else {
    Write-Ok "Minikube ya esta corriendo."
}

# ----------------------------------------------------------
# 3. Instalar Helm (si no esta instalado)
# ----------------------------------------------------------
Write-Step "Verificando Helm..."
$helmCmd = Get-Command helm -ErrorAction SilentlyContinue
if (-not $helmCmd) {
    Write-Host "Helm no encontrado. Instalando via winget..." -ForegroundColor Yellow
    winget install Helm.Helm --accept-package-agreements --accept-source-agreements
    # Recargar PATH para que helm sea reconocido en esta sesion
    $machinePath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
    $userPath    = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    $env:PATH    = $machinePath + ";" + $userPath
    Write-Ok "Helm instalado."
} else {
    $helmVer = helm version --short
    Write-Ok "Helm ya esta instalado: $helmVer"
}

# ----------------------------------------------------------
# 4. Agregar repositorio de Prometheus
# ----------------------------------------------------------
Write-Step "Configurando repositorio de Helm (prometheus-community)..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>&1 | Out-Null
helm repo update
Write-Ok "Repositorio listo."

# ----------------------------------------------------------
# 5. Instalar el stack (Grafana + Prometheus)
# ----------------------------------------------------------
Write-Step "Desplegando Grafana + Prometheus (puede tardar 2-4 min)..."

$valuesFile = Join-Path $PSScriptRoot "grafana-values.yaml"

helm upgrade --install grafana-stack prometheus-community/kube-prometheus-stack `
    --values $valuesFile `
    --wait `
    --timeout 10m

Write-Ok "Stack de monitoreo desplegado exitosamente."

# ----------------------------------------------------------
# 6. Verificar pods del monitoreo
# ----------------------------------------------------------
Write-Step "Verificando pods del monitoreo..."
kubectl get pods -l "release=grafana-stack"

# ----------------------------------------------------------
# 7. Instrucciones finales
# ----------------------------------------------------------
Write-Host ""
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "  Instalacion completada! Proximos pasos:" -ForegroundColor Magenta
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "1. En una TERMINAL SEPARADA, ejecuta:" -ForegroundColor White
Write-Host "      kubectl port-forward svc/grafana-stack-grafana 3000:80" -ForegroundColor Yellow
Write-Host ""
Write-Host "2. Abre tu navegador en:" -ForegroundColor White
Write-Host "      http://localhost:3000" -ForegroundColor Yellow
Write-Host ""
Write-Host "3. Credenciales:" -ForegroundColor White
Write-Host "      Usuario  : admin" -ForegroundColor Yellow
Write-Host "      Password : lymon-admin" -ForegroundColor Yellow
Write-Host ""
Write-Host "Dashboards recomendados para la exposicion:" -ForegroundColor White
Write-Host "   - Kubernetes / Compute Resources / Cluster" -ForegroundColor Yellow
Write-Host "   - Kubernetes / Compute Resources / Pod" -ForegroundColor Yellow
Write-Host "   - Node Exporter / Nodes" -ForegroundColor Yellow
Write-Host ""
