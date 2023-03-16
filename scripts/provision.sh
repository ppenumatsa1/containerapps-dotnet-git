
# The script assumes you already have an image checked into ACR 

# Variable block
let "randomIdentifier=$RANDOM*$RANDOM"
LOCATION="southcentralus"
RESOURCE_GROUP="rg-bloyal"
REGISTRY_NAME="bloyalpocreg$randomIdentifier"
REGISTRY_USERNAME="regadmin$randomIdentifier"
REGISTRY_PASSWORD=
IMAGE_NAME="aspnetapp"
CONTAINERAPP_NAME="bloyal-ca-$randomIdentifier"
CONTAINERAPPS_ENVIRONMENT="bloyal-poc-containerapp-env-$randomIdentifier"
IDENTITY="container-apps-uaid-$randomIdentifier"

# AZ CLI Login 

#az login

# Add Container Apps Extension to AZ ClI (This one time task)

#az extension add --name containerapp --upgrade

# Register APP and Operation Insighths Namespaces (This one time task)

#az provider register --namespace Microsoft.App
#az provider register --namespace Microsoft.OperationalInsights
#az provider register --namespace Microsoft.ContainerRegistry


# Create a resource group
echo "Creating Resoruce Group $RESOURCE_GROUP in "$LOCATION"..."
az group create --name $RESOURCE_GROUP --location "$LOCATION" 

# Create Conatiner Registry and push the Image
echo "Creating Conatiner Registry $REGISTRY_NAME  in "$LOCATION"..."

az acr create --resource-group $RESOURCE_GROUP \
  --name $REGISTRY_NAME --sku Basic \
  --admin-enabled true

az acr login -n $REGISTRY_NAME

docker tag aspnetapp:latest $REGISTRY_NAME.azurecr.io/$IMAGE_NAME:v2

docker push $REGISTRY_NAME.azurecr.io/$IMAGE_NAME:v2


# Create Container APP Environment
echo "Creating Container APP Environment $CONTAINERAPPS_ENVIRONMENT in "$LOCATION"..."
az containerapp env create \
  --name $CONTAINERAPPS_ENVIRONMENT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

 
# Create Contianer APP (Manually add the $IDENTITY_ID and make it work) - Automation is not working as of 03/15/2023
echo "Creating Contianer APP $CONTAINERAPP_NAME in "$LOCATION"..."

az containerapp create \
  --name $CONTAINERAPP_NAME \
  --resource-group $RESOURCE_GROUP \
  --environment $CONTAINERAPPS_ENVIRONMENT \
  --registry-server "$REGISTRY_NAME.azurecr.io" \
  --registry-username $REGISTRY_USERNAME \
  --registry-password $REGISTRY_PASSWORD \
  --image "$REGISTRY_NAME.azurecr.io/$IMAGE_NAME:v1" \
  --target-port 80 \
  --ingress external 

# Delete Resource Group
# az group delete --name $RESOURCE_GROUP