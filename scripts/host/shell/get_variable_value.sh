#!/usr/bin/env bash

parse_yaml() {
    # src: https://gist.github.com/pkuczynski/8665367
    local prefix=$2
    local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
    sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
    awk -F$fs '{
        indent = length($1)/2;
        vname[indent] = $2;
        for (i in vname) {if (i > indent) {delete vname[i]}}
        if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
        }
    }'
}

vagrant_dir=$(cd "$(dirname "$0")/../../.."; pwd)
variable_name=$1

# Enable trace printing and exit on the first error
set -ex

# Read configs
eval $(parse_yaml "${vagrant_dir}/local.config/config.yaml.dist")
eval $(parse_yaml "${vagrant_dir}/local.config/config.yaml")

echo ${!variable_name}