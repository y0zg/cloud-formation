#!/bin/bash
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/home/ec2-user/istio-init.log 2>&1

export ISTIO_VER=1.0.5

wget https://github.com/istio/istio/releases/download/${ISTIO_VER}/istio-${ISTIO_VER}-linux.tar.gz
tar zxvf istio-${ISTIO_VER}-linux.tar.gz
rm istio-${ISTIO_VER}-linux.tar.gz

kubectl create namespace istio-system

helm template istio-${ISTIO_VER}/install/kubernetes/helm/istio \
  --set global.mtls.enabled=false \
  --set tracing.enabled=true \
  --set kiali.enabled=true \
  --set grafana.enabled=true \
  --namespace istio-system > istio.yaml

kubectl apply -f istio.yaml

sleep 30s

kubectl label namespace default istio-injection=enabled

kubectl apply -f /home/ec2-user/config/k8s/istio-ingress