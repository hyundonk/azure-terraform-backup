
# Get recovery points
az backup recoverypoint list \
    --resource-group backup_testrg \
		--vault-name recovery-vault112 \
		--backup-management-type AzureIaasVM \
		--container-name vmorig \
		--item-name vmorig \
		--query [0].name \
		--output tsv

# Restore to managed-disk
$ az backup restore restore-disks \
>     --resource-group backup_testrg \
>     --vault-name recovery-vault112 \
>     --container-name vmorig \
>     --item-name vmorig \
>     --storage-account restore112 \
>     --rp-name 40923384183042 \
>     --target-resource-group backup_testrg-restore

