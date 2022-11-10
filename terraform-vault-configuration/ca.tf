resource "vault_mount" "ca" {
  path = "pki/${ var.ca_name }"
  type = "pki"
  description = var.description
  default_lease_ttl_seconds = var.default_lease
  #max_lease_ttl_seconds = var.maximum_lease
  # 100 years - otherwise the CA will expire too soon
  max_lease_ttl_seconds = 60 * 60 * 24 * 365 * 100
}

resource "vault_pki_secret_backend_config_urls" "ca" {
  backend              = vault_mount.ca.path
  issuing_certificates = [
    "${var.pki_aia_basepath}/ca/${vault_mount.ca.path}"
  ]
  crl_distribution_points = [
    "${var.pki_aia_basepath}/crl/${vault_mount.ca.path}"
  ]
}

resource "vault_pki_secret_backend_crl_config" "ca" {
  backend = vault_mount.ca.path
  expiry = var.crl_time
  disable = false
}

resource "vault_pki_secret_backend_root_cert" "ca" {
  backend = vault_mount.ca.path
  type = "internal"

  common_name = "Vault CA - ${var.ca_name}"
  # 100 years
  ttl = 60 * 60 * 24 * 365 * 10
  key_type = "rsa"
  key_bits = 4096
  exclude_cn_from_sans = false
  max_path_length = 1
}

resource "vault_pki_secret_backend_role" "ca-client" {
  backend = vault_mount.ca.path
  name = "client"
  client_flag = true
  server_flag = false
  allow_localhost = false
  allow_ip_sans = false
  allowed_domains_template = true
  allow_bare_domains = true
  allowed_domains = [
    "{{ identity.entity.metadata.hostname }}"
  ]
  key_usage  = [
    "DigitalSignature",
    "KeyAgreement",
    "KeyEncipherment"
  ]
  key_type = "ec"
  key_bits = 384
  ttl = var.default_lease
  max_ttl = var.maximum_lease
}

resource "vault_policy" "ca-client" {
  name = "ca-${var.ca_name}-client"
  policy = data.vault_policy_document.ca-client-policy.hcl
}

resource "vault_pki_secret_backend_role" "ca-server" {
  backend = vault_mount.ca.path
  name = "server"
  client_flag = false
  server_flag = true
  allow_localhost = true
  # No checks are performed on IP sans.....
  allow_ip_sans = true
  allowed_domains_template = true
  allow_bare_domains = true
  allowed_domains = [
    "{{ identity.entity.metadata.hostname }}",
    "{{ identity.entity.metadata.san0 }}",
    "{{ identity.entity.metadata.san1 }}",
    "{{ identity.entity.metadata.san2 }}",
    "{{ identity.entity.metadata.san3 }}"
  ]
  key_usage  = [
    "DigitalSignature",
    "KeyAgreement",
    "KeyEncipherment"
  ]
  key_type = "ec"
  key_bits = 384
  ttl = var.default_lease
  max_ttl = var.maximum_lease
}

resource "vault_policy" "ca-server" {
  name = "ca-${var.ca_name}-server"
  policy = data.vault_policy_document.ca-server-policy.hcl
}

resource "vault_pki_secret_backend_role" "ca-dual" {
  backend = vault_mount.ca.path
  name = "dual"
  client_flag = true
  server_flag = true
  allow_localhost = true
  # No checks are performed on IP sans.....
  allow_ip_sans = true
  allowed_domains_template = true
  allow_bare_domains = true
  allowed_domains = [
    "{{ identity.entity.metadata.hostname }}",
    "{{ identity.entity.metadata.san0 }}",
    "{{ identity.entity.metadata.san1 }}",
    "{{ identity.entity.metadata.san2 }}",
    "{{ identity.entity.metadata.san3 }}"
  ]
  key_usage  = [
    "DigitalSignature",
    "KeyAgreement",
    "KeyEncipherment"
  ]
  key_type = "ec"
  key_bits = 384
  ttl = var.default_lease
  max_ttl = var.maximum_lease
}

resource "vault_policy" "ca-dual" {
  name = "ca-${var.ca_name}-dual"
  policy = data.vault_policy_document.ca-dual-policy.hcl
}