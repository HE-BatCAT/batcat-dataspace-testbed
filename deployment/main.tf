# Mariadb database as linkahead's backend
module "mariadb" {
  source = "./modules/mariadb"
  namespace = kubernetes_namespace.ns.metadata.0.name
}

# MySQL database as ElabFTW's backend
module "mysql" {
  source = "./modules/mysql"
  namespace = kubernetes_namespace.ns.metadata.0.name
}

module "elabftw" {
  source = "./modules/elabftw"
  namespace = kubernetes_namespace.ns.metadata.0.name
  elabftw-image = var.elabftw-image
  mysql-host = module.mysql.database-host
  mysql-port = module.mysql.database-port
}

module "linkahead" {
  source = "./modules/linkahead"
  namespace = kubernetes_namespace.ns.metadata.0.name
  linkahead-image = var.linkahead-image
  mariadb-host = module.mariadb.database-host
  mariadb-port = module.mariadb.database-port
}

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = "batcat"
  }
}
