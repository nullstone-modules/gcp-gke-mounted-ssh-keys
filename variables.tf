variable "app_metadata" {
  description = <<EOF
Nullstone automatically injects metadata from the app module into this module through this variable.
This variable is a reserved variable for capabilities.
EOF

  type    = map(string)
  default = {}
}

variable "key_types" {
  type        = list(string)
  default     = ["rsa", "ecdsa", "ed25519"]
  description = <<EOF
The SSH host key types to generate.
Supported values are "rsa", "ecdsa", and "ed25519".
EOF

  validation {
    condition     = length(var.key_types) > 0
    error_message = "key_types must contain at least one host key type."
  }

  validation {
    condition     = alltrue([for t in var.key_types : contains(["rsa", "ecdsa", "ed25519"], t)])
    error_message = "key_types may only contain \"rsa\", \"ecdsa\", or \"ed25519\"."
  }

  validation {
    condition     = length(var.key_types) == length(toset(var.key_types))
    error_message = "key_types must not contain duplicates."
  }
}

variable "rsa_bits" {
  type        = number
  default     = 4096
  description = "Number of bits used to generate the RSA host key."
}

variable "key_version" {
  type        = number
  default     = 1
  description = <<EOF
Bump this integer to force regeneration of all SSH host keys on the next apply.
Maps directly to `secret_data_wo_version` on each GSM secret version, which is how
write-only attributes signal that the underlying value should be re-materialized.
Rotating host keys will cause connecting clients to see a host-key-changed warning.
EOF
}

variable "mount_dir" {
  type        = string
  description = <<EOF
Directory where keys will be mounted as files.
Each key will be mounted at <mount_dir>/id_<type>.
EOF
}

locals {
  service_account_email = var.app_metadata["service_account_email"]
  secret_store_name     = var.app_metadata["secret_store_name"]
  key_types             = toset(var.key_types)
}
