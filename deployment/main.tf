# Mariadb database as linkahead's backend
module "mariadb" {
  source = "./modules/mariadb"
  namespace = kubernetes_namespace.ns.metadata.0.name
}

module "linkahead" {
  source = "./modules/linkahead"
  namespace = kubernetes_namespace.ns.metadata.0.name
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
