# ConvertToPolicy
This tool converts a Azure Resource Graph query into a policy rule.

You can do the following :

- Pass what action to take in the policy
- Create a policy by passing a policy name to the script.

To run this tool, you'll need to setup the environment
1. Download setupCloudShellEnvironment.sh into cloud shell environment or your shell environement.
2. run "source ./setupCloudShellEnvironment.sh"
3. This will set up an alias and also install armclient in your shell.

## Usage
You can run commands using *graph2policy* or *./GraphToPolicy* script.

## Examples
1. Generate the policy rule from Graph query with a "deny" action.

*graph2policy -q "where type contains 'compute'" -e "deny"*

2. Create a policy for a given graph query

*graph2policy -q "where type =~ 'microsoft.compute/virtualmachines' and isempty(aliases['Microsoft.Compute/virtualMachines/storageProfile.osDisk.managedDisk.id'])|summarize count()" --effect "audit" --create "AuditNonManagedDiskPolicy"*
