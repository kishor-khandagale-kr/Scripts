#! /bin/bash
##############################################################################################################
# Script to update EventHub configuration
# Replace <service-principal> and <service-credential> value
# Replace <input-file> name. Expected file in 'namespace|eventhub' format
##############################################################################################################

AZ_SERVICE_PRINCIPAL='<service-principal>'
AZ_SERVICE_CREDENTIALS='<service-credential>'
AZ_TENENT='8331e14a-9134-4288-bf5a-5e2c8412f074'
AZ_RESOURCE_GROUP='rg-4620-desp-stg'
AZ_NONPROD_SUBSCRIPTION='60b60000-6cbd-4c1b-94b3-2440bd6bbe00'

echo "Login to az cli" 
az login --service-principal -u $AZ_SERVICE_PRINCIPAL -p $AZ_SERVICE_CREDENTIALS --tenant $AZ_TENENT
az account set --subscription $AZ_NONPROD_SUBSCRIPTION

retVal=$?
if [ $retVal -ne 0 ]; then
    echo "failed to login az cli"
    exit 1
fi

#read file line by line 
while IFS= read -r line; do
    namespace=$(echo $line | cut -d '|' -f1)
    eventhub=$(echo $line | cut -d '|' -f2)

    #update EventHub skipemptyarchive property
    az eventhubs eventhub update \
        --resource-group $AZ_RESOURCE_GROUP \
        --namespace-name $namespace \
        --name $eventhub \
        --skip-empty-archives true

    retVal=$?
    if [ $retVal -ne 0 ]; then
        echo "failed to update skip-empty-archives property for namespace:$namespace and eventhub:$eventhub"
        echo "namespace:$namespace and eventhub:$eventhub" >> failed_records.txt
    fi    

done < <input-file.txt>

echo "logout az"
az logout

exit 0