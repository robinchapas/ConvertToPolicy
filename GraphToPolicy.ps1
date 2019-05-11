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
	[string]$CreatePolicy = "",
	[Parameter(Mandatory=$False)]
	[string]$ManagementGroupName = ""
)

function CreateNewPolicy
{
    param(
        [string]
        $ManagementGroupName
    )
	echo "Creating policy '$CreatePolicy' ..."
    $resp = $resp -join ""
    $policyRule = $resp[17..($resp.Length-2)]
    $policyRule = $policyRule -join ""
    $policyRule = $policyRule -replace " ","" -replace """","'"
    if($ManagementGroupName) {
        #echo $policyRule
        az policy definition create --rules ""$policyRule"" --name ""$CreatePolicy"" --display-name ""$CreatePolicy"" --management-group ""$ManagementGroupName""
    } else {
        #echo $policyRule
        az policy definition create --rules ""$policyRule"" --name ""$CreatePolicy"" --display-name ""$CreatePolicy""
    }
}

function CallAzureResourceGraph
{	
    & $ArmClientPath token *>$null
	if (-not ($?))
	{
		& $ArmClientPath login *>$null
	}
	$response = & $ArmClientPath post "/providers/Microsoft.ResourceGraph/resources/policy?api-version=2018-09-01-preview&effect=$Effect" $Query
    if($response[0] -eq "{") {
        return $response
    }
	return $response[1..$response.Length]
}

function DownloadArmClient
{    
    if([environment]::OSVersion.Platform -eq "Win32NT"){     
        $global:ArmClientPath = ".\armclient.exe"        
        $check = Test-Path($global:ArmClientPath)           
        if( $check-eq $false){            
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest "http://github.com/projectkudu/ARMClient/releases/download/v1.3/ARMClient.zip" -OutFile ArmClient.zip
            Expand-Archive .\ArmClient.zip -DestinationPath .
        }
    }
    else{
        $global:ArmClientPath = "./armclient"
        $path = "./DownloadArmClient.sh"
        $check = Test-Path($global:ArmClientPath)
        if( $check-eq $false){
            # file with path $path doesn't exist
            # let's download and run it
            echo 'curl -sL https://github.com/yangl900/armclient-go/releases/download/v0.2.3/armclient-go_linux_64-bit.tar.gz | tar -xz' > $path
            bash $path
        }        
    }    
    # Find a way to avoid this warning
    if(-not (Test-Path $ArmClientPath)){
        Write-Error "Unable to find ArmClient, the script would not work"
        throw [System.IO.FileNotFoundException] "armclient does not exists."
    }
}

DownloadArmClient
#echo $ArmClientPath
$resp = CallAzureResourceGraph

if($CreatePolicy -ne ""){
    CreateNewPolicy -ManagementGroupName $ManagementGroupName
} else {
    echo $resp
}
