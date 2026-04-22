output "volumes" {
  value = [
    {
      name = "ssh-keys"
      secret = jsonencode({
        secret_name  = local.k8s_secret_name
        default_mode = "0444"
        items = [
          for t in var.key_types : {
            key  = local.key_file_names[t]
            path = local.key_file_names[t]
            mode = "0444"
          }
        ]
      })
    }
  ]
}

output "volume_mounts" {
  value = [
    {
      name       = "ssh-keys"
      mount_path = var.mount_dir
      read_only  = true
    }
  ]
}
