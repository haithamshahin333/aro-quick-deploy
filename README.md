# aro-quick-deploy

Create `.env` with following values:

```bash
#Basic ARO Parameters
export ARO_RG=aro-demo-cluster
export ARO_LOCATION=eastus
export ARO_NAME=aro-cluster

#Network ARO Parameters
export VNET_RG="$ARO_RG"
export VNET=aro-vnet
export VNET_ADDRESS="10.0.0.0/16"
export CONTROL_PLANE_SUBNET="$VNET-control-plane"
export CONTROL_PLANE_SUBNET_ADDRESS="10.0.0.0/24"
export WORKER_SUBNET="$VNET-worker"
export WORKER_SUBNET_ADDRESS="10.0.1.0/24"
export ARO_VISIBILITY=Public
# export ARO_DOMAIN=examplehsdomain.com

#ARO Worker Node Specs
export ARO_WORKER_NODE_SIZE=Standard_D4s_v3
export ARO_WORKER_NODE_COUNT=3
```

Run `set -a; source .env; set +a`.

Run `./deploy.sh`.