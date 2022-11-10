data "vault_policy_document" "ca-client-policy" {
  rule {
    path = "pki/${var.ca_name}/issue/client"
    capabilities = ["create", "update"]
    description = "allow client to issue a client cert"
  }
}

data "vault_policy_document" "ca-server-policy" {
  rule {
    path = "pki/${var.ca_name}/issue/server"
    capabilities = ["create", "update"]
    description = "allow server to issue a server cert"
  }
}

data "vault_policy_document" "ca-dual-policy" {
  rule {
    path = "pki/${var.ca_name}/issue/dual"
    capabilities = ["create", "update"]
    description = "allow dual to issue a dual cert"
  }
}

