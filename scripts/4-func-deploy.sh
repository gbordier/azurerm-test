#!/bin/bash
if [ -z "$core_function_name" ]; then
    echo "run ./0-init-vars.sh script first to set core_function_name"
    exit 1
fi
func=$core_function_name

pushd ../../../src/Guardian.Backend/Guardian.Backend.Function/src

func azure functionapp publish $func --dotnet-isolated
popd
