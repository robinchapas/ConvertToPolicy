"# ConvertToPolicy" 
Download setupCloudShellEnvironment.sh into cloud shell environment or your shell environement
run "source ./setupCloudShellEnvironment.sh"
This will set up an alias and get armclient for you.

You can also get armclient on your own here "https://github.com/yangl900/armclient-go/releases/download/v0.2.3/armclient-go_linux_64-bit.tar.gz"

Run commands using graph2policy or ./GraphToPolicy script.

Run the query you want to convert.
Example: 
graph2policy -q "where type contains 'compute'" -e "deny"
