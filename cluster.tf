// We still need a kubernetes provider to create the ExternalSecret manifest below.
// Cluster endpoint/CA/namespace come from the app's cluster-namespace connection.
data "ns_app_connection" "cluster_namespace" {
  name     = "cluster-namespace"
  contract = "cluster-namespace/gcp/k8s:gke"
}

locals {
  cluster_endpoint       = data.ns_app_connection.cluster_namespace.outputs.cluster_endpoint
  cluster_ca_certificate = data.ns_app_connection.cluster_namespace.outputs.cluster_ca_certificate
  kubernetes_namespace   = data.ns_app_connection.cluster_namespace.outputs.kubernetes_namespace
}

provider "kubernetes" {
  host                   = "https://${local.cluster_endpoint}"
  token                  = data.google_client_config.this.access_token
  cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
}
