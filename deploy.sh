#!/usr/bin/env bash
set -e

echo "🚀 Starting Autonomous Game Studio Deployment..."

############################
# NAMESPACES
############################
kubectl create namespace game-factory || true
kubectl create namespace monitoring || true

############################
# REDIS
############################
cat <<EOF | kubectl apply -n game-factory -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7
        ports:
        - containerPort: 6379
---
apiVersion: v1
kind: Service
metadata:
  name: redis
spec:
  selector:
    app: redis
  ports:
  - port: 6379
EOF

############################
# API GATEWAY
############################
cat <<EOF | kubectl apply -n game-factory -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: game-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: game-api
  template:
    metadata:
      labels:
        app: game-api
    spec:
      containers:
      - name: api
        image: game-factory/api:latest
        ports:
        - containerPort: 8000
        env:
        - name: REDIS_URL
          value: redis://redis:6379
---
apiVersion: v1
kind: Service
metadata:
  name: game-api
spec:
  selector:
    app: game-api
  ports:
  - port: 80
    targetPort: 8000
EOF

############################
# WORKERS (GEN + PLAYTEST + EVOLVE)
############################
cat <<EOF | kubectl apply -n game-factory -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: game-worker
spec:
  replicas: 4
  selector:
    matchLabels:
      app: game-worker
  template:
    metadata:
      labels:
        app: game-worker
    spec:
      containers:
      - name: worker
        image: game-factory/worker:latest
        env:
        - name: REDIS_URL
          value: redis://redis:6379
EOF

############################
# AUTOSCALER (HPA)
############################
cat <<EOF | kubectl apply -n game-factory -f -
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: game-worker-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: game-worker
  minReplicas: 2
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
EOF

############################
# PROMETHEUS
############################
cat <<EOF | kubectl apply -n monitoring -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus
        ports:
        - containerPort: 9090
EOF

############################
# GRAFANA
############################
cat <<EOF | kubectl apply -n monitoring -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana
        ports:
        - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: grafana
spec:
  selector:
    app: grafana
  ports:
  - port: 3000
    targetPort: 3000
EOF

############################
# STATUS CHECK
############################
echo "📊 Waiting for system stabilization..."

kubectl get pods -n game-factory
kubectl get pods -n monitoring

echo "✅ Autonomous Game Studio deployed successfully"
echo "🎮 API: kubectl port-forward svc/game-api 8000:80 -n game-factory"
echo "📊 Grafana: kubectl port-forward svc/grafana 3000:3000 -n monitoring"
