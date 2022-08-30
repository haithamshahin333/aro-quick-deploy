if [ -n "$(az provider show -n Microsoft.Compute -o table | grep -E '(Unregistered|NotRegistered)')" ]; then
    echo "The Azure Compute resource provider has not been registered for your subscription $SUBID."
    echo -n "I will attempt to register the Azure Compute RP now (this may take a few minutes)..."
    az provider register -n Microsoft.Compute --wait > /dev/null
    az provider register -n Microsoft.Storage --wait > /dev/null
    echo "done."
    echo -n "Verifying the Azure Compute RP is registered..."
    if [ -n "$(az provider show -n Microsoft.Compute -o table | grep -E '(Unregistered|NotRegistered)')" ]; then
        echo "error! Unable to register the Azure Compute RP. Please remediate this."
        exit 1
    fi
    echo "done."
fi

if [ -n "$(az provider show -n Microsoft.RedHatOpenShift -o table | grep -E '(Unregistered|NotRegistered)')" ]; then
    echo "The ARO resource provider has not been registered for your subscription $SUBID."
    echo -n "I will attempt to register the ARO RP now (this may take a few minutes)..."
    az provider register -n Microsoft.RedHatOpenShift --wait > /dev/null
    echo "done."
    echo -n "Verifying the ARO RP is registered..."
    if [ -n "$(az provider show -n Microsoft.RedHatOpenShift -o table | grep -E '(Unregistered|NotRegistered)')" ]; then
        echo "error! Unable to register the ARO RP. Please remediate this."
        exit 1
    fi
    echo "done."
fi

az group create \
    --location $ARO_LOCATION \
    --name $ARO_RG

az network vnet create \
    --resource-group $ARO_RG \
    --name $VNET \
    --address-prefixes $VNET_ADDRESS

az network vnet subnet create \
    --resource-group $ARO_RG \
    --vnet-name $VNET \
    --name $CONTROL_PLANE_SUBNET \
    --address-prefixes $CONTROL_PLANE_SUBNET_ADDRESS

az network vnet subnet create \
    --resource-group $ARO_RG \
    --vnet-name $VNET \
    --name $WORKER_SUBNET \
    --address-prefixes $WORKER_SUBNET_ADDRESS

az network vnet subnet update \
    --resource-group $ARO_RG \
    --vnet-name $VNET \
    --name $CONTROL_PLANE_SUBNET \
    --disable-private-link-service-network-policies true

az aro create \
    --name $ARO_NAME \
    --resource-group $ARO_RG \
    --location $ARO_LOCATION \
    --vnet-resource-group $VNET_RG \
    --vnet $VNET \
    --master-subnet $CONTROL_PLANE_SUBNET \
    --worker-subnet $WORKER_SUBNET \
    --location $ARO_LOCATION \
    --apiserver-visibility $ARO_VISIBILITY \
    --ingress-visibility $ARO_VISIBILITY \
    --worker-vm-size $ARO_WORKER_NODE_SIZE \
    --worker-count $ARO_WORKER_NODE_COUNT \
    --pull-secret=$(cat pull-secret.txt)