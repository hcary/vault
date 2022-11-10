#!/bin/bash

function  gen_root() {

    echo "##################################################"
    echo "Enable secrets engine @ ${root_path}..."
    echo "##################################################"

    vault secrets enable -path=$root_path pki

    # 10yr TTL for root 
    vault secrets tune -max-lease-ttl=87600h $root_path

    # Generate the root certificate and save the certificate X.crt.
    vault write -field=certificate $root_path/root/generate/internal \
        common_name="${domain}" \
        ttl=87600h > $root_ca_cert

    # Configure the CA and CRL URLs.
    # vault write root_path/config/urls \
    #     issuing_certificates="${VAULT_ADDR}/v1/${root_path}/ca" \
    #     crl_distribution_points="${VAULT_ADDR}/v1/${root_path}/crl"


}

function gen_intermediate() {

    echo "##################################################"
    echo "Enable secrets engine @ ${inter_path}..."
    echo "##################################################"

    vault secrets enable -path=$inter_path pki

    # 10yr TTL for root 
    echo "Tune secrets agent..."
    vault secrets tune -max-lease-ttl=8760h $inter_path

    # Execute the following command to generate an intermediate and save the CSR as pki_intermediate.csr
    echo "Generate Intermediate..."
    vault write -format=json $inter_path/intermediate/generate/internal \
     common_name="${domain} Intermediate Authority" \
     | jq -r '.data.csr' > $inter_ca_cert.csr

    # Sign the intermediate certificate with the root CA private key, 
    # and save the generated certificate as intermediate.cert.pem
    echo "Generate Intermediate PEM..."
    vault write -format=json $root_path/root/sign-intermediate csr=@$inter_ca_cert.csr \
        format=pem_bundle ttl="43800h" \
        | jq -r '.data.certificate' > $inter_ca_cert.cert.pem

    # Once the CSR is signed and the root CA returns a certificate, it can be imported back into Vault.
    echo "Write sign cert..."
    vault write $inter_path/intermediate/set-signed certificate=@$inter_ca_cert.cert.pem

    vault write $inter_path/roles/${env_name} \
        allowed_domains="${domain}" \
        allow_subdomains=true \
        max_ttl="8760"

    echo "##################################################"
    echo "Generating policy ${signer_role}..."
    echo "##################################################"
    # Create policy allowing a service to generate 2nd level intermediates
    vault policy write $signer_role - <<EOF
    path "${inter_path}/root/sign-intermediate" {
        capabilities = ["create", "update"]
    }
EOF

    vault token create -policy=$signer_role

}

function gen_app() {

    echo "##################################################"
    echo "Enabling app role ${app_role}..."
    echo "##################################################"
    vault auth enable approle

    # Add policy path to issue statement
    vault write auth/approle/role/$app_role \
        secret_id_ttl=0 \
        token_num_uses=0 \
        token_ttl=0 \
        token_max_ttl=0 \
        secret_id_num_uses=0 \
        token_policies="$signer_role"
        # pki-int-haloe-az/issue/demo-app.local

    vault read auth/approle/role/$app_role/role-id

    vault write -f auth/approle/role/$app_role/secret-id

}

# function gen_policy() {

#     echo "##################################################"
#     echo "Generating policy ${signer_role}..."
#     echo "##################################################"
#     # Create policy allowing a service to generate 2nd level intermediates
#     vault policy write $signer_role - <<EOF
#     path "${inter_path}/root/sign-intermediate" {
#         capabilities = ["create", "update"]
#     }
# EOF

# }

# set -e

env_name=devel
option=$1

numargs=$#
for ((i=1 ; i <= numargs ; i++))
do
    var=$1
    case $var in
        -e|--env)
            shift
            env_name=$1
            shift
            ;;
        
        -c|--config)
            shift
            config=$1
            shift
            if [ -f $config ];
            then 
                config_flag=true
            fi
            ;;

        -t|--test)
            flag_test=true
            ;;

        -r|--root)
            flag_root=true
            ;;

        -i|--int)
            flag_int=true
            ;;

        -a|--app)
            flag_app=true
            ;;

        # -p|--policy)
        #     flag_policy=true
        #     ;;

        --all)
            flag_all=true
            ;;

        *)
            shift
            ;;

    esac
done


if [ "$config_flag" == true ];
then
    source $config
fi

echo ""
echo "vault_addr: $VAULT_ADDR"
echo "vault_namespace: $VAULT_NAMESPACE"
echo "env_name: $env_name"
echo "pki_path: $pki_path"                      
echo "root_path: $root_path"
echo "root_ca_cert: $root_ca_cert"
echo "inter_path: $inter_path"
echo "inter_ca_cert: $inter_ca_cert"
echo "app_role: $app_role"
echo "signer_role: $signer_role"
echo "domain: $domain"
echo "------------------------------------------------------------------"
echo ""

if [ "$flag_test" == true ];
then
    echo "true"
    exit
fi


if [ "$flag_root" == true ];
then
    gen_root
fi

if [ "$flag_int" == true ];
then
    gen_intermediate
fi

# if [ "$flag_policy" == true ];
# then
#     gen_policy
# fi

if [ "$flag_app" == true ];
then
    gen_app
fi

if [ "$flag_all" == true ];
then
        gen_root
        gen_intermediate
        # gen_policy
        gen_app    
fi


