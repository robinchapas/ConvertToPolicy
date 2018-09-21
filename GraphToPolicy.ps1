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
    echo $policyRule
    az policy definition create --rules ""$policyRule"" -n ""$CreatePolicy"" --display-name ""$CreatePolicy""
}

function CallAzureResourceGraph
{	
	$response = & $ArmClientPath post "/providers/Microsoft.ResourceGraph/resources/policy?api-version=2018-09-01-preview&effect=$Effect" $Query
	return $response[1..$response.Length]
}

function DownloadArmClient
{    
    if([environment]::OSVersion.Platform -eq "Win32NT"){
        $ArmClientPath = "armclient"
    }
    else{
        $ArmClientPath = "./armclient"
        $path = "./DownloadArmClient.sh"
        $check = Test-Path($ArmClientPath)
        if( $check-eq $false){
            # file with path $path doesn't exist
            # let's create and run it
            echo 'curl -sL https://github.com/yangl900/armclient-go/releases/download/v0.2.3/armclient-go_linux_64-bit.tar.gz | tar -xz' > $path
            bash $path
        }        
    }    
    # Find a way to avoid this warning
    if(![System.IO.File]::Exists($ArmClientPath)){
        Write-Warning "Unable to download ArmClient, the script may not work"
        #throw [System.IO.FileNotFoundException] "armclient does not exists."
    }
}

DownloadArmClient
#echo $ArmClientPath

$resp = CallAzureResourceGraph

if($CreatePolicy -ne ""){
    CreateNewPolicy
} else {
    echo $resp
}
 