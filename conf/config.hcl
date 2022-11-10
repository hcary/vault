storage "raft" {
  path    = "/Users/hcary/database/vault/data"
  node_id = "node1"
}

// storage "postgresql" {
//   connection_url = "postgres://user123:secret123!@localhost:5432/vault"
// }

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = "true"
}

api_addr = "http://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"
ui = true

