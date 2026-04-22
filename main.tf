locals {
  tls_algorithm = {
    rsa     = "RSA"
    ecdsa   = "ECDSA"
    ed25519 = "ED25519"
  }
}

ephemeral "tls_private_key" "host_key" {
  for_each = local.key_types

  algorithm   = local.tls_algorithm[each.value]
  rsa_bits    = each.value == "rsa" ? var.rsa_bits : null
  ecdsa_curve = each.value == "ecdsa" ? "P521" : null
}

resource "google_secret_manager_secret" "host_key" {
  for_each = local.key_types

  secret_id = lower(replace("${local.resource_name}_${each.key}", "/[^a-zA-Z_0-9]/", "_"))
  labels    = local.labels

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "host_key" {
  for_each = local.key_types

  secret                 = google_secret_manager_secret.host_key[each.key].id
  secret_data_wo         = ephemeral.tls_private_key.host_key[each.key].private_key_openssh
  secret_data_wo_version = var.key_version
}

resource "google_secret_manager_secret_iam_member" "sa_access" {
  for_each = local.key_types

  secret_id = google_secret_manager_secret.host_key[each.value].secret_id
  project   = local.project_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.service_account_email}"
}
