#!/bin/bash

source hcv-pki.cfg

NAME=$1
# PKIPATH=/mesh-poc/pki/poc-ca-root-${NAME}

set -e
set -x

DIR=cert-$NAME
mkdir -p $DIR

vault write -format=json ${inter_path}/issue/rc3labs \
  common_name="${NAME}.${domain}" ttl="4368h"| tee ${DIR}/${NAME}.json

cd $DIR
jq -r .data.private_key < ${NAME}.json > ${NAME}.key
jq -r .data.certificate < ${NAME}.json > ${NAME}.crt
jq -r .data.issuing_ca < ${NAME}.json > ${NAME}.issuing_ca
