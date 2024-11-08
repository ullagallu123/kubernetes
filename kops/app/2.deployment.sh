#!/bin/bash

# Function to print messages
print_message() {
    echo "=================================================================="
    echo "$1"
    echo "=================================================================="
}

# Function to apply Kubernetes manifests with error checking
apply_kubectl() {
    local file_path=$1
    local namespace=$2

    kubectl apply -f "$file_path" -n "$namespace"
    if [ $? -eq 0 ]; then
        print_message "Successfully applied $file_path in namespace $namespace."
    else
        print_message "Failed to apply $file_path in namespace $namespace."
        exit 1
    fi
}

# Function to install or upgrade Helm charts dynamically based on file path
install_or_upgrade_helm_chart() {
    local file_path=$1
    local namespace=$2
    local release_name

    # Extracting release name from the file path
    release_name=$(basename "$file_path" | cut -d. -f1)

    # Check if the Helm release already exists
    if helm ls -n "$namespace" | grep -q "^$release_name"; then
        # If release exists, perform an upgrade
        helm upgrade "$release_name" "$file_path" -n "$namespace"
        if [ $? -eq 0 ]; then
            print_message "Successfully upgraded Helm chart $release_name in namespace $namespace."
        else
            print_message "Failed to upgrade Helm chart $release_name in namespace $namespace."
            exit 1
        fi
    else
        # If release does not exist, install a new release
        helm install "$release_name" "$file_path" -n "$namespace"
        if [ $? -eq 0 ]; then
            print_message "Successfully installed Helm chart $release_name in namespace $namespace."
        else
            print_message "Failed to install Helm chart $release_name in namespace $namespace."
            exit 1
        fi
    fi
}

# Function for sleep with a message
pause() {
    local duration=$1
    print_message "Pausing Deployment for $duration seconds..."
    sleep "$duration"
}

HOME_FOL="/home/ubuntu/kubernetes"
EXPENSE_KUBE="$HOME_FOL/expense"
INSTANA_KUBE="$HOME_FOL/instana"
KOPS_HOME="$HOME_FOL/kops/app"

EXPENSE_HELM="$HOME_FOL/expense-helm"
INSTANA_HELM="$HOME_FOL/instana-helm"

NS1="instana"
NS2="expense"
#NS3="monitoring"

# Storage Class Creation
print_message "Creating Storage Classes for Instana and Expense"
kubectl apply -f "$HOME_FOL/k8s-volumes/dynamic-volume/instana.yaml"
kubectl apply -f "$HOME_FOL/k8s-volumes/dynamic-volume/expense.yaml"

# Namespace Creation
print_message "Creating Namespaces for Instana and Expense"
kubectl get ns "$NS1" &>/dev/null || kubectl create ns "$NS1"
kubectl get ns "$NS2" &>/dev/null || kubectl create ns "$NS2"
#kubectl get ns "$NS3" &>/dev/null || kubectl create ns "$NS3"

# # Metrics Server Deployment
# print_message "Deploying Metrics Server"
# kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

deployment_method=$1

# Prompt for deployment method if not provided as an argument
if [[ -z "$deployment_method" ]]; then
    echo "Choose deployment method (type 'helm' for Helm or 'kubectl' for Kubernetes manifests):"
    read -r deployment_method
fi

if [[ "$deployment_method" == "helm" ]]; then
    # Helm Deployment for Instana Namespace
    
    print_message "Deploying Services in Instana Namespace using Helm: Mongo"
    install_or_upgrade_helm_chart "$INSTANA_HELM/mongo" "$NS1"
    print_message "Deploying Services in Instana Namespace using Helm: MySQL"
    install_or_upgrade_helm_chart "$INSTANA_HELM/mysql" "$NS1"
    print_message "Deploying Services in Instana Namespace using Helm: Rabbit"
    install_or_upgrade_helm_chart "$INSTANA_HELM/rabbit" "$NS1"
    print_message "Deploying Services in Instana Namespace using Helm: Redis"
    install_or_upgrade_helm_chart "$INSTANA_HELM/redis" "$NS1"
    pause 60

    print_message "Deploying Services in Instana Namespace: Catalogue"
    install_or_upgrade_helm_chart "$INSTANA_HELM/catalogue" "$NS1"
    print_message "Deploying Services in Instana Namespace: User"
    install_or_upgrade_helm_chart "$INSTANA_HELM/user" "$NS1"
    print_message "Deploying Services in Instana Namespace: Cart"
    install_or_upgrade_helm_chart "$INSTANA_HELM/cart" "$NS1"
    pause 40

    print_message "Deploying Services in Instana Namespace: shipping"
    install_or_upgrade_helm_chart "$INSTANA_HELM/shipping" "$NS1"
    pause 20

    print_message "Deploying Services in Instana Namespace: Payment"
    install_or_upgrade_helm_chart "$INSTANA_HELM/payment" "$NS1"
    pause 10

    print_message "Deploying Services in Instana Namespace: Web"
    install_or_upgrade_helm_chart "$INSTANA_HELM/web" "$NS1"

else
    # Kubectl Deployment for Instana Namespace
    print_message "Deploying Services in Instana Namespace using helm: Mongo"
    apply_kubectl "$INSTANA_KUBE/mongo" "$NS1"
    pause 15

    print_message "Deploying Services in Instana Namespace using helm: MySQL"
    apply_kubectl "$INSTANA_KUBE/mysql" "$NS1"
    pause 25

    print_message "Deploying Services in Instana Namespace using helm: Rabbit"
    apply_kubectl "$INSTANA_KUBE/rabbit" "$NS1"
    pause 15


    print_message "Deploying Services in Instana Namespace using helm: Redis"
    apply_kubectl "$INSTANA_KUBE/redis" "$NS1"
    pause 10

    print_message "Deploying Services in Instana Namespace: Catalogue"
    apply_kubectl "$INSTANA_KUBE/catalogue" "$NS1"
    pause 10

    print_message "Deploying Services in Instana Namespace: User"
    apply_kubectl "$INSTANA_KUBE/user" "$NS1"
    pause 10

    print_message "Deploying Services in Instana Namespace: Cart"
    apply_kubectl "$INSTANA_KUBE/cart" "$NS1"
    pause 10

    print_message "Deploying Services in Instana Namespace: Shipping"
    apply_kubectl "$INSTANA_KUBE/shipping" "$NS1"
    pause 30

    print_message "Deploying Services in Instana Namespace: Payment"
    apply_kubectl "$INSTANA_KUBE/payment" "$NS1"
    pause 30

    print_message "Deploying Services in Instana Namespace: Web"
    apply_kubectl "$INSTANA_KUBE/web" "$NS1"
fi

# Expense Namespace Deployments
print_message "Deploying Services in Expense Namespace: MySQL"
apply_kubectl "$EXPENSE_KUBE/mysql" "$NS2"
pause 30

print_message "Deploying Backend Service in Expense Namespace"
apply_kubectl "$EXPENSE_KUBE/backend" "$NS2"
pause 20

print_message "Deploying Frontend Service in Expense Namespace"
apply_kubectl "$EXPENSE_KUBE/frontend" "$NS2"

# Final message
print_message "All Deployments Have Been Successfully Applied!"




#helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
#helm repo update



#helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring -f "$KOPS_HOME/custom.yaml"

# admin
# prom-operator

# 6781