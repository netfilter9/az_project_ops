how to move with this codes follow steps below.


to make terminal more readable
type below:
function prompt { "current> " }

to generate ssh-keys in windows 
ssh-keygen -t ed25519


-=-=-=-=-=
az commands administration
-=-=-==-=-=
Azure Administrator Daily Tasks Cheat Sheet

1. Login & Subscription
az login
az account show
az account set --subscription <subscription_id>
az account list --output table
az account set --subscription "Target-Subscription-Name-or-ID"
az account show

sign using managed identity 
az login --identity 

2. Resource Group Management
az group list -o table
az group create --name rg-demo --location westeurope
az group delete --name rg-demo

3. Virtual Machines
az vm list -o table
az vm start --name myVM --resource-group rg-demo
az vm stop --name myVM --resource-group rg-demo
az vm restart --name myVM --resource-group rg-demo

#can also be like for restart
az vm restart -g rg-prod -n sles-vm-01

4. Networking
az network vnet list -o table
az network nsg list -o table
az network public-ip list -o table

5. Storage
az storage account list -o table
az storage blob list --account-name <account> --container-name <container>

6. Monitoring
az monitor activity-log list --max-events 10
az monitor metrics list --resource <resource_id>

7. User & Access (IAM)
az role assignment list -o table
az ad user list

8. Cost Management
az consumption usage list --top 10

9. Kubernetes (AKS)
az aks list -o table
az aks get-credentials --name myAKS --resource-group rg-demo
kubectl get nodes
kubectl get pods

10. Backup & Recovery
az backup vault list
az backup job list

11. Security
az security assessment list
az security alert list

12. Automation
az automation account list
az automation job list

13. Troubleshooting
az vm get-instance-view --name myVM --resource-group rg-demo
az network watcher test-connectivity --source-resource <vm_id> --dest-address 8.8.8.8


AZ CLI 
DISK Extension via cli and linux suse

az disk update  -g rg-vcsi-dev-weu-sapk-001  -n disk-vicdevsapkpi01-002 --size-gb 256

echo 1 > /sys/class/block/sdc/device/rescan
# check devices 
lsblk | grep sdc
#resize the disk 
pvresize /dev/sdc
#resize the logical volume
lvextend -r -l +100%FREE /dev/VGSAP/lv_usrsap
#verify 
Df -h 
vgs 
lvs

-=-=-=-=
Check available sku
-=-=-=-

az vm list-skus \
  --location westeurope \
  --resource-type virtualMachines \
  --size Standard_E4ds_v6 \
  --all \
  -o table
