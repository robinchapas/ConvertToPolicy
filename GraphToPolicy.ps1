<#
.SYNOPSIS
Converts an Azure Resource Graph query into a policy rule.

.PARAMETER Query
Azure Resource Graph Query which needs to be converted to the policy rule

.PARAMETER Effect
Optional parameter for setting the policy effect. Default value is "audit"

.PARAMETER CreatePolicy
Optional parameter to create the policy and use the value as the policy name.

.EXAMPLE
./GraphToPolicy -Query "where type =~ 'microsoft.compute/virtualmachines' and isempty(aliases['Microsoft.Compute/virtualMachines/storageProfile.osDisk.managedDisk.id'])|summarize count()" -Effect "audit" -CreatePolicy "AuditNonManagedDiskPolicy"
#>

Param(
	[Parameter(Mandatory=$True)]
	[string]$Query,
	[Parameter(Mandatory=$False)]
	[string]$Effect = "audit",
	[Parameter(Mandatory=$False)]
	[string]$CreatePolicy = ""	
)

function CreateNewPolicy
{
	echo "Creating policy '$CreatePolicy' ..."
    $resp = $resp -join ""
    $policyRule = $resp[17..($resp.Length-2)]
    $policyRule = $policyRule -join ""
    $policyRule = $policyRule -replace " ","" -replace """","'"    
    az policy definition create --rules ""$policyRule"" -n ""$CreatePolicy"" --display-name ""$CreatePolicy""
}

function CallAzureResourceGraph
{	
	$response = armclient post "/providers/Microsoft.ResourceGraph/resources/policy?api-version=2018-09-01-preview&effect=$Effect" $Query
	return $response
}

function DownloadArmClient
{
    curl -sL "https://github.com/chiragg4u/ConvertToPolicy/blob/master/armclient.tar.gz" | tar -xz    
}

$resp = CallAzureResourceGraph

if($CreatePolicy -ne ""){
    CreateNewPolicy
} else {
    echo $resp
}
 