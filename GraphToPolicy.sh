#!/bin/bash

if [ ! -f armclient ]; then     echo "Please get Armclient using the following command: curl -sL https://github.com/yangl900/armclient-go/releases/download/v0.2.3/armclient-go_linux_64-bit.tar.gz | tar -xz"; else

QUERY=()
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
    *)    # unknown option
    QUERY+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${QUERY[@]}" # restore positional parameters

# Armclient is echoing the post data. using sed to remove
eval ./armclient post '"/providers/Microsoft.ResourcesTopology.PPE/resources/policy?api-version=2017-10-05-preview&effect='${EFFECT:-audit}'"' '"'${QUERY}'"|sed "1 d"'

fi
