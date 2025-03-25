variable "database-port" {
  default = 3306
}

variable "init-sql-configs" {
  description = "Name of config maps with init sql scripts"
  default     = []
}

variable "namespace" {
  description = "Kubernetes namespace where the MySQL instance is deployed."
}
