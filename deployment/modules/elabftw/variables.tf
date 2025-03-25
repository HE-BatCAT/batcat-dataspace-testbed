variable "namespace" {
  description = "Kubernetes namespace where the ElabFTW instance is deployed."
}

variable "elabftw-port" {
  description = "ElabFTW http port"
  default = 443
}

variable "elabftw-image" {
  description = "The docker image tag of the ElabFTW build you want to be loaded."
  default = "elabftw/elabimg:stable"
}

variable "mysql-port" {
  description = "The port of the MySQL database."
}

variable "mysql-host" {
  description = "The host of the MySQL database."
}
