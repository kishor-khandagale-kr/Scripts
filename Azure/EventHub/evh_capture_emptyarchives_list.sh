#! /bin/bash
##############################################################################################################
# DMP team request to find all non production DESP EventHubs with capture missing skipEmptyArchives option.
# Replace <service-credentails> value
##############################################################################################################

AZ_SERVICE_PRINCIPAL='7096287e-1d17-46e8-b898-5d76a033c675'
AZ_SERVICE_CREDENTIALS='<service-credentails>'
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

echo "Get list of all evenhub namespaces under resource-group $AZ_RESOURCE_GROUP" 
evh_namespaces=$(az eventhubs namespace list --resource-group $AZ_RESOURCE_GROUP | jq -rc '. [] | .name')
echo "namespaces list : $evh_namespaces"

for i in $evh_namespaces
do
    echo "namespace: $i"

    az eventhubs eventhub list --resource-group $AZ_RESOURCE_GROUP --namespace-name $i \
    | jq -rc --arg namespace "$i" '. [] 
    | select((.captureDescription != null) and (.captureDescription.skipEmptyArchives==null)) | ($namespace + "|" + .name )' \
    >> eventhubs_capture_skipemptyarchive_disable.txt

done

az logout