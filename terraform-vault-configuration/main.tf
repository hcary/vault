resource "vault_auth_backend" "rc3labs" {
    type = "userpass"

    tune {
        max_lease_ttl      = "90000s"
        listing_visibility = "unauth"
    }

}

resource "vault_generic_endpoint" "harvey" {
  depends_on           = [vault_auth_backend.rc3labs]
  path                 = "auth/userpass/users/harvey"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["admins", "eaas-client"],
  "password": "changeme"
}
EOT
}

resource "vault_policy" "admin_policy" {
  name   = "admins"
  policy = file("policies/admin_policy.hcl")
}

resource "vault_mount" "rc3labs" {
  path        = "kv/${var.base_path}"
  type        = "kv-v2"
  description = "KV2 Secrets Engine for rc3labs."
}

# resource "vault_mount" "operations" {
#   path        = "operations"
#   type        = "kv-v2"
#   description = "KV2 Secrets Engine for Operations."
# }

resource "vault_generic_secret" "developer_sample_data" {
  path = "${vault_mount.rc3labs.path}/rc3labs"

  data_json = <<EOT
{
  "username": "rc3labs",
  "password": "passwd"
}
EOT
}