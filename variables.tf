variable "name" {}

variable "randomize_name" {
  default  = true
  nullable = false
}

variable "rg" {
  type = object({
    name     = string
    location = string
  })
}

variable "tenant_id" {}

variable "enable_rbac_authorization" {
  default  = false
  nullable = false
}

variable "sku_name" {
  default  = "standard"
  nullable = false
}

variable "admins" {
  type     = set(string)
  default  = []
  nullable = false
}

variable "getters" {
  type = map(object({
    client_id    = string
    principal_id = string
    tenant_id    = string
  }))
  default  = {}
  nullable = false
}

variable "secrets" {
  type     = map(string)
  default  = {}
  nullable = false
}

variable "kubernetes_manifest_namespace" {
  default  = "default"
  nullable = false
}

variable "kubernetes_pod_mount_path" {
  default  = "/app/config"
  nullable = false
}