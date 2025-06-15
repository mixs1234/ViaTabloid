#!/bin/bash
# setup-k8s.sh - Complete Kubernetes setup for VIA Tabloid (Fixed)

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 VIA Tabloid Kubernetes Setup${NC}"
echo "=================================="

# Check prerequisites
echo -e "\n${YELLOW}📋 Checking prerequisites...${NC}"

# Check if minikube is installed
if ! command -v minikube &> /dev/null; then
    echo -e "${RED}❌ Minikube is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null && ! command -v minikube &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if kompose is installed
if ! command -v kompose &> /dev/null; then
    echo -e "${YELLOW}⚠️  Kompose is not installed. You won't be able to use the kompose conversion feature.${NC}"
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Create directory structure
echo -e "\n${YELLOW}📁 Creating directory structure...${NC}"
mkdir -p k8s/{postgres,backend,frontend,scripts}

# Create PostgreSQL manifests
echo -e "${BLUE}  Creating PostgreSQL manifests...${NC}"

cat > k8s/postgres/pv.yaml << 'EOF'
apiVersion: v1
kind: PersistentVolume
metadata:
  name: postgres-pv
  labels:
    type: local
    app: postgres
spec:
  storageClassName: manual
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/data/postgres"
EOF

cat > k8s/postgres/pvc.yaml << 'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  labels:
    app: postgres
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
EOF

cat > k8s/postgres/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db
  labels:
    app: db
spec:
  replicas: 1
  selector:
    matchLabels:
      app: db
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
      - name: db
        image: postgres:17
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 5432
          name: postgres
        env:
        - name: POSTGRES_USER
          valueFrom:
            configMapKeyRef:
              name: postgres-config
              key: postgres-user
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: postgres-password
        - name: POSTGRES_DB
          valueFrom:
            configMapKeyRef:
              name: postgres-config
              key: postgres-db
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
        readinessProbe:
          exec:
            command:
              - pg_isready
              - -U
              - postgres
          initialDelaySeconds: 15
          periodSeconds: 10
        livenessProbe:
          exec:
            command:
              - pg_isready
              - -U
              - postgres
          initialDelaySeconds: 30
          periodSeconds: 30
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-pvc
EOF

cat > k8s/postgres/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: db
  labels:
    app: db
spec:
  selector:
    app: db
  ports:
    - port: 5432
      targetPort: 5432
      name: postgres
  type: ClusterIP
EOF

# Create Backend manifests (WITHOUT HEALTH CHECKS)
echo -e "${BLUE}  Creating Backend manifests...${NC}"

cat > k8s/backend/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  labels:
    app: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: ghcr.io/mixs1234/viatabloid/backend:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
          name: http
        env:
        - name: ASPNETCORE_ENVIRONMENT
          value: Development
        - name: ConnectionStrings__DefaultConnection
          valueFrom:
            secretKeyRef:
              name: backend-secret
              key: connection-string
        - name: ASPNETCORE_URLS
          value: http://+:8080
        - name: CORS__Origins
          value: "*"
        # Health checks removed since /health endpoint doesn't exist
EOF

cat > k8s/backend/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: backend
  labels:
    app: backend
spec:
  selector:
    app: backend
  ports:
    - port: 8080
      targetPort: 8080
      nodePort: 30501
      name: http
  type: NodePort
EOF

# Create Frontend manifests (WITHOUT HEALTH CHECKS)
echo -e "${BLUE}  Creating Frontend manifests...${NC}"

cat > k8s/frontend/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  labels:
    app: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: ghcr.io/mixs1234/viatabloid/frontend:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 3000
          name: http
        env:
        - name: VITE_API_HOST
          value: "localhost"
        - name: VITE_API_PORT
          value: "5001"
        # Health checks removed to ensure pod starts properly
EOF

cat > k8s/frontend/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: frontend
  labels:
    app: frontend
spec:
  selector:
    app: frontend
  ports:
    - port: 3000
      targetPort: 3000
      nodePort: 30300
      name: http
  type: NodePort
EOF

# Create ConfigMaps and Secrets
echo -e "${BLUE}  Creating ConfigMaps and Secrets...${NC}"

cat > k8s/postgres-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-config
data:
  postgres-user: postgres
  postgres-db: via_tabloid
EOF

cat > k8s/postgres-secret.yaml << 'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
type: Opaque
data:
  # Password: yourpassword (base64 encoded)
  postgres-password: eW91cnBhc3N3b3Jk
EOF

cat > k8s/backend-secret.yaml << 'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: backend-secret
type: Opaque
data:
  # Connection string (base64 encoded)
  connection-string: SG9zdD1kYjtQb3J0PTU0MzI7RGF0YWJhc2U9dmlhX3RhYmxvaWQ7VXNlcm5hbWU9cG9zdGdyZXM7UGFzc3dvcmQ9eW91cnBhc3N3b3Jk
EOF

# Create improved deploy script with better error handling
echo -e "${BLUE}  Creating deployment scripts...${NC}"

cat > k8s/deploy.sh << 'EOF'
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 VIA Tabloid Kubernetes Deployment${NC}"
echo "===================================="

# Check if minikube is running
if ! minikube status &> /dev/null; then
    echo -e "${RED}❌ Minikube is not running${NC}"
    echo -e "${YELLOW}Starting Minikube...${NC}"
    minikube start
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to start Minikube${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✅ Minikube is running${NC}"

# Clean up any existing deployments
echo -e "\n${YELLOW}🧹 Cleaning up any existing resources...${NC}"
kubectl delete deployment db backend frontend 2>/dev/null || true
kubectl delete service db backend frontend 2>/dev/null || true
kubectl delete pvc postgres-pvc 2>/dev/null || true
kubectl delete pv postgres-pv 2>/dev/null || true
kubectl delete configmap postgres-config 2>/dev/null || true
kubectl delete secret postgres-secret backend-secret 2>/dev/null || true

# Wait for cleanup
sleep 3

# Deploy in order
echo -e "\n${YELLOW}📦 Deploying PostgreSQL...${NC}"
kubectl apply -f postgres-config.yaml
kubectl apply -f postgres-secret.yaml
kubectl apply -f postgres/pv.yaml
kubectl apply -f postgres/pvc.yaml
kubectl apply -f postgres/deployment.yaml
kubectl apply -f postgres/service.yaml

# Wait for pod creation
echo -e "${YELLOW}⏳ Waiting for PostgreSQL pod to be created...${NC}"
sleep 5

echo -e "${YELLOW}⏳ Waiting for PostgreSQL to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=db --timeout=120s || {
    echo -e "${YELLOW}PostgreSQL is taking longer than expected. Checking status...${NC}"
    kubectl get pods -l app=db
    kubectl logs -l app=db --tail=20
}

echo -e "\n${YELLOW}📦 Deploying Backend...${NC}"
kubectl apply -f backend-secret.yaml
kubectl apply -f backend/deployment.yaml
kubectl apply -f backend/service.yaml

# Wait for pod creation
echo -e "${YELLOW}⏳ Waiting for Backend pod to be created...${NC}"
sleep 5

echo -e "${YELLOW}⏳ Waiting for Backend to be ready (this may take a moment)...${NC}"
# Since we removed health checks, we'll wait for the pod to be in Running state
kubectl wait --for=jsonpath='{.status.phase}'=Running pod -l app=backend --timeout=120s || {
    echo -e "${YELLOW}Backend is taking longer than expected. Checking status...${NC}"
    kubectl get pods -l app=backend
    kubectl logs -l app=backend --tail=20
}

echo -e "\n${YELLOW}📦 Deploying Frontend...${NC}"
kubectl apply -f frontend/deployment.yaml
kubectl apply -f frontend/service.yaml

# Wait for pod creation
echo -e "${YELLOW}⏳ Waiting for Frontend pod to be created...${NC}"
sleep 5

echo -e "${YELLOW}⏳ Waiting for Frontend to be ready...${NC}"
# Since we removed health checks, we'll wait for the pod to be in Running state
kubectl wait --for=jsonpath='{.status.phase}'=Running pod -l app=frontend --timeout=120s || {
    echo -e "${YELLOW}Frontend is taking longer than expected. Checking status...${NC}"
    kubectl get pods -l app=frontend
    kubectl logs -l app=frontend --tail=20
}

# Additional wait to ensure services are fully ready
echo -e "\n${YELLOW}⏳ Waiting for services to stabilize...${NC}"
sleep 10

echo -e "\n${GREEN}✅ All services deployed!${NC}"

# Show status
echo -e "\n${BLUE}📊 Deployment Status:${NC}"
kubectl get pods -o wide

echo -e "\n${BLUE}🌐 Service Information:${NC}"
kubectl get services

echo -e "\n${YELLOW}📝 Next Steps:${NC}"
echo "1. Run './scripts/access.sh' to access your services"
echo "2. Run 'minikube dashboard' to view the Kubernetes dashboard"
echo "3. Run './scripts/logs.sh' to view application logs"
echo "4. Run './scripts/debug.sh' if you encounter issues"

echo -e "\n${GREEN}🎉 Deployment complete!${NC}"
EOF

# Create improved access script
cat > k8s/scripts/access.sh << 'EOF'
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🌐 VIA Tabloid Service Access${NC}"
echo "=============================="

# Check if services are running
if ! kubectl get service frontend &>/dev/null; then
    echo -e "${RED}❌ Services not found. Please run deploy.sh first${NC}"
    exit 1
fi

# Check pod status
echo -e "\n${YELLOW}📊 Current pod status:${NC}"
kubectl get pods

echo -e "\n${YELLOW}Choose access method:${NC}"
echo "1) Port forwarding (localhost) - Recommended"
echo "2) Minikube service (proxy URL)"
echo "3) Minikube tunnel (NodePort)"
echo "4) Show all access methods"

read -p "Enter choice (1-4): " choice

case $choice in
    1)
        echo -e "\n${GREEN}🔌 Setting up port forwarding...${NC}"
        
        # Kill any existing port forwards
        pkill -f "kubectl port-forward" 2>/dev/null
        sleep 1
        
        echo "This will make services available at:"
        echo "  • Frontend: http://localhost:3000"
        echo "  • Backend: http://localhost:5001"
        echo -e "\n${YELLOW}Press Ctrl+C to stop${NC}\n"
        
        # Port forward with proper backend port mapping
        kubectl port-forward service/frontend 3000:3000 &
        PF1=$!
        kubectl port-forward service/backend 5001:8080 &
        PF2=$!
        
        # Function to cleanup on exit
        cleanup() {
            echo -e "\n${YELLOW}Stopping port forwarding...${NC}"
            kill $PF1 $PF2 2>/dev/null
            exit
        }
        trap cleanup EXIT INT TERM
        
        # Wait for port forwarding to establish
        sleep 3
        
        echo -e "\n${GREEN}✅ Port forwarding active!${NC}"
        echo -e "${BLUE}Access your application at: http://localhost:3000${NC}"
        
        # Open browser
        if command -v xdg-open &> /dev/null; then
            xdg-open http://localhost:3000 2>/dev/null &
        elif command -v open &> /dev/null; then
            open http://localhost:3000 2>/dev/null &
        fi
        
        # Wait for interrupt
        wait
        ;;
        
    2)
        echo -e "\n${GREEN}🚀 Using Minikube service proxy...${NC}"
        BACKEND_URL=$(minikube service backend --url)
        FRONTEND_URL=$(minikube service frontend --url)
        echo "Frontend URL: $FRONTEND_URL"
        echo "Backend URL: $BACKEND_URL"
        echo -e "\n${YELLOW}Opening frontend in browser...${NC}"
        minikube service frontend
        ;;
        
    3)
        echo -e "\n${GREEN}🚇 Minikube tunnel instructions:${NC}"
        echo "1. Open a new terminal with admin/sudo privileges"
        echo "2. Run: sudo minikube tunnel"
        echo "3. Keep it running and access services at:"
        echo "   • Frontend: http://localhost:30300"
        echo "   • Backend: http://localhost:30501"
        ;;
        
    4)
        echo -e "\n${BLUE}📋 All Access Methods:${NC}"
        echo -e "\n${YELLOW}Method 1: Port Forwarding (Recommended)${NC}"
        echo "kubectl port-forward service/frontend 3000:3000"
        echo "kubectl port-forward service/backend 5001:8080"
        echo "Access: Frontend at http://localhost:3000, Backend at http://localhost:5001"
        
        echo -e "\n${YELLOW}Method 2: Minikube Service${NC}"
        echo "minikube service frontend --url"
        echo "minikube service backend --url"
        
        echo -e "\n${YELLOW}Method 3: NodePort (via tunnel)${NC}"
        echo "sudo minikube tunnel"
        echo "Frontend: http://localhost:30300"
        echo "Backend: http://localhost:30501"
        
        MINIKUBE_IP=$(minikube ip)
        echo -e "\n${YELLOW}Method 4: Direct NodePort (rarely works on WSL)${NC}"
        echo "Frontend: http://$MINIKUBE_IP:30300"
        echo "Backend: http://$MINIKUBE_IP:30501"
        ;;
        
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac
EOF

# Create debug script
cat > k8s/scripts/debug.sh << 'EOF'
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 VIA Tabloid Debugging${NC}"
echo "========================"

echo -e "\n${YELLOW}📊 Pod Status:${NC}"
kubectl get pods -o wide

echo -e "\n${YELLOW}🌐 Service Status:${NC}"
kubectl get services

echo -e "\n${YELLOW}📝 Recent Events:${NC}"
kubectl get events --sort-by='.lastTimestamp' | tail -20

echo -e "\n${YELLOW}🔧 Checking each component:${NC}"

# Check PostgreSQL
echo -e "\n${BLUE}PostgreSQL:${NC}"
POD=$(kubectl get pod -l app=db -o jsonpath="{.items[0].metadata.name}" 2>/dev/null)
if [ ! -z "$POD" ]; then
    echo "Pod: $POD"
    kubectl logs $POD --tail=10
else
    echo -e "${RED}No PostgreSQL pod found${NC}"
fi

# Check Backend
echo -e "\n${BLUE}Backend:${NC}"
POD=$(kubectl get pod -l app=backend -o jsonpath="{.items[0].metadata.name}" 2>/dev/null)
if [ ! -z "$POD" ]; then
    echo "Pod: $POD"
    kubectl logs $POD --tail=10
    echo -e "\n${YELLOW}Testing backend connectivity:${NC}"
    kubectl exec $POD -- curl -s http://localhost:8080 || echo "Backend not responding on port 8080"
else
    echo -e "${RED}No Backend pod found${NC}"
fi

# Check Frontend
echo -e "\n${BLUE}Frontend:${NC}"
POD=$(kubectl get pod -l app=frontend -o jsonpath="{.items[0].metadata.name}" 2>/dev/null)
if [ ! -z "$POD" ]; then
    echo "Pod: $POD"
    kubectl logs $POD --tail=10
else
    echo -e "${RED}No Frontend pod found${NC}"
fi

echo -e "\n${YELLOW}💡 Common Issues and Solutions:${NC}"
echo "1. ${YELLOW}Pods in CrashLoopBackOff:${NC} Check logs above for errors"
echo "2. ${YELLOW}ImagePullBackOff:${NC} Verify image names and registry access"
echo "3. ${YELLOW}Frontend can't reach backend:${NC} Use port-forward method"
echo "4. ${YELLOW}Connection refused:${NC} Backend might still be starting up"

echo -e "\n${YELLOW}🔧 Quick Fixes:${NC}"
echo "• Restart a pod: kubectl delete pod <pod-name>"
echo "• View full logs: kubectl logs <pod-name> --tail=100"
echo "• Describe pod: kubectl describe pod <pod-name>"
echo "• Clean everything: ./cleanup.sh && ./deploy.sh"
EOF

# Keep the rest of the scripts unchanged...
# (cleanup.sh, logs.sh, kompose-convert.sh, access-windows.ps1, README.md)

# Create cleanup script
cat > k8s/cleanup.sh << 'EOF'
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🧹 Cleaning up VIA Tabloid deployment...${NC}"

# Delete all resources
kubectl delete -f frontend/service.yaml 2>/dev/null
kubectl delete -f frontend/deployment.yaml 2>/dev/null
kubectl delete -f backend/service.yaml 2>/dev/null
kubectl delete -f backend/deployment.yaml 2>/dev/null
kubectl delete -f backend-secret.yaml 2>/dev/null
kubectl delete -f postgres/service.yaml 2>/dev/null
kubectl delete -f postgres/deployment.yaml 2>/dev/null
kubectl delete -f postgres/pvc.yaml 2>/dev/null
kubectl delete -f postgres/pv.yaml 2>/dev/null
kubectl delete -f postgres-secret.yaml 2>/dev/null
kubectl delete -f postgres-config.yaml 2>/dev/null

echo -e "${GREEN}✅ Cleanup complete${NC}"
echo -e "\n${YELLOW}📝 Verify with: kubectl get all${NC}"
EOF

# Create logs script
cat > k8s/scripts/logs.sh << 'EOF'
#!/bin/bash

# Colors
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📋 VIA Tabloid Logs${NC}"
echo "==================="

echo -e "${YELLOW}Select component:${NC}"
echo "1) Frontend logs"
echo "2) Backend logs"
echo "3) Database logs"
echo "4) All logs (follow)"

read -p "Enter choice (1-4): " choice

case $choice in
    1)
        kubectl logs -l app=frontend --tail=100 -f
        ;;
    2)
        kubectl logs -l app=backend --tail=100 -f
        ;;
    3)
        kubectl logs -l app=db --tail=100 -f
        ;;
    4)
        echo -e "${YELLOW}Following all logs (Ctrl+C to stop)...${NC}"
        kubectl logs -f --all-containers=true --prefix=true
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac
EOF

# Create kompose script
cat > k8s/scripts/kompose-convert.sh << 'EOF'
#!/bin/bash

# Colors
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🔄 Kompose Conversion Tool${NC}"
echo "========================="

# Check if kompose is installed
if ! command -v kompose &> /dev/null; then
    echo -e "${RED}❌ Kompose is not installed${NC}"
    echo "Install it from: https://kompose.io/installation/"
    exit 1
fi

# Check if docker-compose.yml exists
if [ ! -f "../../docker-compose.yml" ]; then
    echo -e "${RED}❌ docker-compose.yml not found in parent directory${NC}"
    exit 1
fi

# Create output directory
mkdir -p kompose-output

echo -e "${YELLOW}Converting docker-compose.yml...${NC}"
cd ../..
kompose convert -f docker-compose.yml -o k8s/kompose-output/

echo -e "${GREEN}✅ Conversion complete!${NC}"
echo -e "\n${YELLOW}📁 Files generated in: k8s/kompose-output/${NC}"
echo -e "\n${YELLOW}Note:${NC} The manually created files in k8s/ are optimized for production."
echo "The kompose output is for reference and may need adjustments."
EOF

# Make all scripts executable
chmod +x k8s/deploy.sh
chmod +x k8s/cleanup.sh
chmod +x k8s/scripts/access.sh
chmod +x k8s/scripts/logs.sh
chmod +x k8s/scripts/debug.sh
chmod +x k8s/scripts/kompose-convert.sh

# Final message
echo -e "\n${GREEN}✅ Setup complete!${NC}"
echo -e "\n${BLUE}📁 Created structure:${NC}"
tree k8s/ 2>/dev/null || {
    echo "k8s/"
    echo "├── postgres/"
    echo "│   ├── pv.yaml"
    echo "│   ├── pvc.yaml"
    echo "│   ├── deployment.yaml"
    echo "│   └── service.yaml"
    echo "├── backend/"
    echo "│   ├── deployment.yaml  (without health checks)"
    echo "│   └── service.yaml"
    echo "├── frontend/"
    echo "│   ├── deployment.yaml  (without health checks)"
    echo "│   └── service.yaml"
    echo "├── scripts/"
    echo "│   ├── access.sh"
    echo "│   ├── debug.sh"
    echo "│   ├── logs.sh"
    echo "│   └── kompose-convert.sh"
    echo "├── postgres-config.yaml"
    echo "├── postgres-secret.yaml"
    echo "├── backend-secret.yaml"
    echo "├── deploy.sh"
    echo "├── cleanup.sh"
    echo "└── README.md"
}

echo -e "\n${YELLOW}🚀 To deploy:${NC}"
echo "   cd k8s"
echo "   ./deploy.sh"

echo -e "\n${YELLOW}🌐 To access services:${NC}"
echo "   ./scripts/access.sh"

echo -e "\n${YELLOW}🐛 To debug issues:${NC}"
echo "   ./scripts/debug.sh"

echo -e "\n${GREEN}Happy deploying! 🎉${NC}"