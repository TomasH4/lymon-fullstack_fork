param(
    [string]$ArgoCDVersion = "v2.14.3",
    [string]$ArgoCDPassword = "lymon-admin",
    [switch]$SkipInstall
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ArgoCD Installation Script - Lymon" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "[1/6] Checking prerequisites..." -ForegroundColor Yellow
$hasKubectl = Get-Command kubectl -ErrorAction SilentlyContinue
$hasMinikube = Get-Command minikube -ErrorAction SilentlyContinue
$hasHelm = Get-Command helm -ErrorAction SilentlyContinue

if (-not $hasKubectl) {
    Write-Host "ERROR: kubectl not found. Please install kubectl first." -ForegroundColor Red
    exit 1
}
Write-Host "  [OK] kubectl" -ForegroundColor Green

if (-not $hasMinikube) {
    Write-Host "WARNING: minikube not found. Will proceed assuming cluster is already running." -ForegroundColor Yellow
}

if (-not $hasHelm) {
    Write-Host "  Installing Helm..." -ForegroundColor Yellow
    winget install helm.helm --silent --accept-package-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  Please install Helm manually from https://helm.sh/docs/intro/install/" -ForegroundColor Red
        exit 1
    }
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Write-Host "  [OK] Helm installed" -ForegroundColor Green
} else {
    Write-Host "  [OK] helm" -ForegroundColor Green
}

# Ensure Minikube is running
if ($hasMinikube) {
    Write-Host "[2/6] Ensuring Minikube is running..." -ForegroundColor Yellow
    $minikubeStatus = minikube status --format "{{.Host}}" 2>$null
    if ($minikubeStatus -ne "Running") {
        Write-Host "  Starting Minikube..." -ForegroundColor Yellow
        minikube start --cpus 4 --memory 8192
    }
    Write-Host "  [OK] Minikube is running" -ForegroundColor Green
}

# Verify kubectl can connect
Write-Host "[3/6] Verifying cluster connection..." -ForegroundColor Yellow
kubectl cluster-info --request-timeout=5s
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Cannot connect to Kubernetes cluster." -ForegroundColor Red
    exit 1
}
Write-Host "  [OK] Connected to cluster" -ForegroundColor Green

# Install ArgoCD
Write-Host "[4/6] Installing ArgoCD ($ArgoCDVersion)..." -ForegroundColor Yellow
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

helm repo add argo https://argoproj.github.io/argo-helm 2>$null
helm repo update

helm upgrade --install argocd argo/argo-cd `
    --version $ArgoCDVersion `
    --namespace argocd `
    --set server.service.type=NodePort `
    --set server.service.nodePortHttp=30080 `
    --set server.service.nodePortHttps=30443 `
    --set configs.params."server\.insecure"=true `
    --set configs.secret.argocdServerAdminPassword="$ArgoCDPassword" `
    --wait

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: ArgoCD installation failed." -ForegroundColor Red
    exit 1
}
Write-Host "  [OK] ArgoCD installed" -ForegroundColor Green

# Wait for ArgoCD pods
Write-Host "[5/6] Waiting for ArgoCD pods to be ready..." -ForegroundColor Yellow
kubectl wait --namespace argocd `
    --for=condition=Ready pods `
    --all `
    --timeout=180s

Write-Host "  [OK] ArgoCD pods are ready" -ForegroundColor Green

# Apply the Application manifests
Write-Host "[6/6] Applying Lymon Application manifests..." -ForegroundColor Yellow
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$argocdManifests = Join-Path $scriptDir "..\k8s\argocd"

Get-ChildItem -Path $argocdManifests -Filter "*.yaml" | ForEach-Object {
    Write-Host "  Applying $($_.Name)..." -ForegroundColor Gray
    kubectl apply -f $_.FullName
}

Write-Host "  [OK] Application manifests applied" -ForegroundColor Green

# Get Minikube IP and ArgoCD URL
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ArgoCD Installation Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($hasMinikube) {
    $minikubeIp = minikube ip
    Write-Host "ArgoCD URL: http://$minikubeIp`:30080" -ForegroundColor Green
} else {
    Write-Host "ArgoCD URL: http://localhost:30080 (after port-forward)" -ForegroundColor Green
}

Write-Host ""
Write-Host "Login credentials:" -ForegroundColor Cyan
Write-Host "  User:     admin" -ForegroundColor White
Write-Host "  Password: $ArgoCDPassword" -ForegroundColor White
Write-Host ""
Write-Host "Quick login via CLI:" -ForegroundColor Cyan
Write-Host "  argocd login --insecure --username admin <server-ip>:30080" -ForegroundColor White
Write-Host ""
Write-Host "Applications deployed:" -ForegroundColor Cyan
Write-Host "  - lymon-backend          (path: k8s/backend)" -ForegroundColor White
Write-Host "  - lymon-frontend         (path: k8s/frontend)" -ForegroundColor White
Write-Host "  - lymon-infrastructure   (path: k8s/infra)" -ForegroundColor White
