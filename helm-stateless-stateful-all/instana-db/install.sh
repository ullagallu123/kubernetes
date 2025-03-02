#!/bin/bash

kubectl create ns instana
kubectl apply -f ~/kubernetes/k8s-volumes/dynamic-volume/instana.yaml
install_or_upgrade() {
    RELEASE_NAME=$1
    CHART_PATH=$2
    VALUES_FILE=$3
    NAMESPACE=$4

    if helm list -n "$NAMESPACE" | grep -q "^$RELEASE_NAME"; then
        echo "Upgrading $RELEASE_NAME..."
        helm upgrade "$RELEASE_NAME" "$CHART_PATH" -f "$VALUES_FILE" -n "$NAMESPACE"
    else
        echo "Installing $RELEASE_NAME..."
        helm install "$RELEASE_NAME" "$CHART_PATH" -f "$VALUES_FILE" -n "$NAMESPACE"
    fi
}

NAMESPACE="instana"

install_or_upgrade "mongo" "." "dev/mongo.yaml" "$NAMESPACE"
sleep 30
install_or_upgrade "mysql" "." "dev/mysql.yaml" "$NAMESPACE"
sleep 10
install_or_upgrade "rabbitmq" "." "dev/rabbitmq.yaml" "$NAMESPACE"
sleep 5
install_or_upgrade "redis" "." "dev/redis.yaml" "$NAMESPACE"

    