// The app module (gcp-gke-service / gcp-gke-job) already owns a SecretStore configured
// with workload identity for the app's k8s ServiceAccount. Its name is exposed through
// `app_metadata.secret_store_name`, so this capability just attaches an ExternalSecret
// to it rather than standing up a parallel store.
locals {
  k8s_secret_name = local.resource_name
  key_file_names  = { for t in local.key_types : t => "id_${t}" }
}

resource "kubernetes_manifest" "external_secret" {
  depends_on = [
    google_secret_manager_secret_version.host_key,
    google_secret_manager_secret_iam_member.sa_access,
  ]

  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"

    metadata = {
      name      = local.k8s_secret_name
      namespace = local.kubernetes_namespace
      labels    = local.labels
    }

    spec = {
      secretStoreRef = {
        kind = "SecretStore"
        name = local.secret_store_name
      }

      target = {
        name = local.k8s_secret_name
      }

      data = [
        for t in var.key_types : {
          secretKey = local.key_file_names[t]
          remoteRef = {
            key = google_secret_manager_secret.host_key[t].secret_id
          }
        }
      ]
    }
  }
}
