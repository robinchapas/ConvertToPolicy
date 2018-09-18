#!/bin/bash

curl -sL https://github.com/yangl900/armclient-go/releases/download/v0.2.3/armclient-go_linux_64-bit.tar.gz | tar -xz

echo '#!/bin/bash

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -q|--q|--query)
    QUERY="$2"
    shift # past argument
    shift # past value
    ;; 
    -e|--e|--effect)
    EFFECT="$2"
    shift # past argument
    shift # past value
    ;;
	-c|--c|--create)
    POLICY="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ -z $POLICY ]
then
eval ./armclient post '"'"'"/providers/Microsoft.ResourceGraph.PPE/resources/policy?api-version=2017-10-05-preview&effect='"'\${EFFECT:-audit}'"'"'"'" "'"'"'"'\${QUERY}'"'"'"'| sed '1 d'"'
else
p=$(eval ./armclient post '"'"'"/providers/Microsoft.ResourceGraph.PPE/resources/policy?api-version=2017-10-05-preview&effect='"'\${EFFECT:-audit}'"'"'"'" "'"'"'"'\${QUERY}'"'"'"'| sed '1 d'"')
az policy definition create --rules "${p: 18:-1}" -n $POLICY --display-name $POLICY
fi
' > GraphToPolicy 

sed -ie "/^# some more/a alias graph2policy='. ./GraphToPolicy' " .bashrc

alias graph2policy='. ./GraphToPolicy'
