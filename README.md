# Hashicorp Vault

### Start Vault

vault server -config=$HOME/devel/hc-vault/conf/config.hcl

export VAULT_ADDR='http://127.0.0.1:8200'

### Run one time to initialize vault
vault operator init

Unseal Key 1: 30ZoEtsnTXBJg79dVOyUJZ5itB+7UG38nE1rg3hHMAbu
Unseal Key 2: QAt0e6JFwExgTt8h6zILzgwOwoCrDvRptyv6NDpyxRJF
Unseal Key 3: OGPlLHQeE8wsXhUq2r70R08qZsE8P8ue3Cj63Es9BXNV
Unseal Key 4: qATWMt+C+5k3WaU/rTVmDhJvxphiLd7nN6Ta1DsTUNgx
Unseal Key 5: OnQ0HlUgWk9ud7swmyZTXNO6WRfgrPVyC+jyy+5aJcgi

Initial Root Token: s.T4sJwnsbbhKJ0JQB4LRzrwRp


### Unseal the vault using 3 of the 5 Unseal keys
vault operator unseal

export VAULT_TOKEN='s.T4sJwnsbbhKJ0JQB4LRzrwRp'

vault login $VAULT_TOKEN

### Enable Secrets Engine
vault secrets enable -path=rc3labs kv-v2
vault secrets enable -path=project1 kv-v2
vault secrets enable -path=project2 kv-v2
vault secrets enable -path=astra kv-v2
vault secrets enable -path=nacd kv-v2
vault secrets enable -path=vortex kv-v2


vault kv put rc3labs/db/admin_passwd value='password'
vault kv put rc3labs/db/admin_name value='dba_rc3labs@mydatabase.com'

vault secrets list

vault secrets enable -path=astra_db database

vault write astra_db/config/Azure-MySQL \
    plugin_name=mysql-database-plugin \
    allowed_roles="astra_dba" \
    connection_url="user:password@tcp(localhost:3306)/test" \
    tls_certificate_key=@/path/to/client.pem \
    tls_ca=@/path/to/client.ca

vault write astra_db/roles/db-reader \
    db_name=my-mysql-database \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';" \
    default_ttl="1h" \
    max_ttl="24h"