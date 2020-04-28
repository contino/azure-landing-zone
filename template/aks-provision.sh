# Create Resource Group
aksrg='vp-aks'
location='uksouth'

az group create -n $aksrg -l $location

# Create the AKS cluster
clusterName='vpAKS'
az aks create -g $aksrg -n $clusterName --node-count 3 --generate-ssh-keys \
              --service-principal 'f62a2e0f-d1d0-413c-9d2a-e59498b0aee1' \
              --client-secret '433d9848-20b0-4f17-9fa5-f06a26b8b029'

