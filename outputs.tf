output "this" {
  value = azurerm_key_vault.this
}

output "secrets" {
  value = azurerm_key_vault_secret.this
}

output "kubernetes_secret_provider_class_manifest" {
  value = { for k, v in var.getters : k => {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "${var.name}-${k}"
      namespace = var.kubernetes_manifest_namespace
    }
    spec = {
      provider = "azure"
      parameters = {
        usePodIdentity = "false"
        keyvaultName   = azurerm_key_vault.this.name
        clientID       = v.client_id
        tenantId       = v.tenant_id
        cloudName      = ""
        objects = yamlencode({
          array = [for k, v in var.secrets : yamlencode({ objectName = k, objectType = "secret" })]
        })
      }
    }
  } }
}

output "helm_release_values" {
  value = { for k, v in var.getters : k => {
    volumes = [{
      name = "${var.name}-${k}"
      csi = {
        driver           = "secrets-store.csi.k8s.io"
        readOnly         = true
        volumeAttributes = { secretProviderClass = "${var.name}-${k}" }
      }
    }]
    volumeMounts = [{
      name      = "${var.name}-${k}"
      mountPath = var.kubernetes_pod_mount_path
      readOnly  = true
    }]
  } }
}