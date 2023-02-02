<!-- ABOUT THE PROJECT -->
# About The Project
This project contains resources, documentation, infrastructure as code, and guidelines for best practices deploying a customized Sitecore 10 application into AKS and Azure SQL Database. Documenation for this process is shared across existing accelerators and documentation provided by Sitecore on best practices for deploying containerized version of Sitecore 10.

## Contents

| folder    | description |
| --------- | ----------- |
| bootstrap | bootstrap the terraform by creating a storage account for tfstate |
| src       | the source code including any yaml for kubernetes |
| terraform | the terraform for creating infrastructure |


## Core Prerequisites

Download the "Installation Guide for Production Environment with Kubernetes" document from [dev.sitecore.net](https://dev.sitecore.net/Downloads/Sitecore_Experience_Platform/103/Sitecore_Experience_Platform_103.aspx)

You will need to download submodules in order to get the files referenced in the submodules. 

```
# run this after you run git clone
git submodule update --init --recursive
```

* Install [Helm](https://helm.sh/docs/intro/install)
* Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/#install-nonstandard-package-tools)
* Install [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
* Install [terraform](https://developer.hashicorp.com/terraform/downloads?ajs_aid=e7cb18f6-0e91-46ef-b3af-d22a83181326&product_intent=terraform)

```
choco install helm kubectl azure-cli terraform -y
```

## Installation

### Bootstrap terraform by creating support infrastructure

Login to the azure cli

```
az login
```

Run the bootstrap terraform script. You will only need to run this one time. 

```
# run from the repository root
cd bootstrap
terraform init
terraform plan -var="name=sitecore" -var="location=South Central US"
terraform apply -var="name=sitecore" -var="location=South Central US" -auto-approve
```

### Create Azure Infrastructure

Run terraform init and specify the backend configuration. We are using Azure Blob Storage to store the shared state for the terraform. You can configure your backend using the following documentation https://developer.hashicorp.com/terraform/language/settings/backends/azurerm

> bash

```bash
NAME=sitecore
location="South Central US"
ARM_RESOURCE_GROUP="${NAME}-tfstate"
storage_account_name=      # you need to supply a value here
container_name="tfstate"
key="terraform.tfstate"
ARM_ACCESS_KEY=            # you need to supply a value here

terraform init \
-backend-config "container_name=${container_name}" \
-backend-config "key=${key}" \
-backend-config "storage_account_name=${storage_account_name}"

terraform plan -var="name=${NAME}" -var="location=${location}"
terraform apply -var="name=${NAME}" -var="location=${location}" -auto-approve
```

> powershell

```powershell
$location="South Central US"
$name="sitecore"
$env:ARM_RESOURCE_GROUP=""
$env:ARM_STORAGE_ACCOUNT_NAME=""
$env:ARM_CONTAINER_NAME="tfstate"
$env:ARM_KEY="terraform.tfstate"
$env:ARM_ACCESS_KEY=""

terraform init `
-backend-config "container_name=$env:ARM_CONTAINER_NAME" `
-backend-config "key=$env:ARM_KEY" `
-backend-config "storage_account_name=$env:ARM_STORAGE_ACCOUNT_NAME"

terraform plan -var="name=${name}" -var="location=${location}"
terraform apply -var="name=${name}" -var="location=${location}" -auto-approve
```

### Connect to AKS and deploy sitecore yaml

```bash
# assumes the $name variable is set from the shell above
az login
az account set --subscription "" # put your subscription here
az aks get-credentials --resource-group ${name} --name ${name} # replace with your resource group name and cluster name
```

### Deploy Ingress Helm Chart

```bash
# add the nginx helm repo
helm repo add stable https://kubernetes.github.io/ingress-nginx
helm repo update
```

> bash

```bash
# install the nginx chart
helm install ingress-nginx stable/ingress-nginx \
 --set controller.replicaCount=2 \
 --set controller.nodeSelector."kubernetes\.io/os"=linux \
 --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux \
 --set controller.admissionWebhooks.patch.nodeSelector."kubernetes\.io/os"=linux
```

> powershell

```powershell
# install the nginx chart
helm install ingress-nginx stable/ingress-nginx `
 --set controller.replicaCount=2 `
 --set controller.nodeSelector."kubernetes\.io/os"=linux `
 --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux `
 --set controller.admissionWebhooks.patch.nodeSelector."kubernetes\.io/os"=linux
```

### Deploy the Secrets

```powershell
# change into secrets working directory
cd src\github.com\sitecore\container-deployment\k8s\sxp\10.3\ltsc2019\xm1\secrets

# generate all secrets
kubectl apply -k ./secrets/
```

## Addons

## Security

## Testing

## Retail Materials

## Architecture

### AKS Reference Architecture

[see](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks)

![AKS Reference Architecture](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/images/baseline-architecture.svg)


## Solution Components

### Trademarks

Trademarks This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow Microsoft’s Trademark & Brand Guidelines. Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party’s policies.
