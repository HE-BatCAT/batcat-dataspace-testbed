resource "kubernetes_deployment" "elabftw" {
  metadata {
    name      = local.app-name
    namespace = var.namespace
    labels = {
      App = local.app-name
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = local.app-name
      }
    }
    template {
      metadata {
        labels = {
          App = local.app-name
        }
      }
      spec {
        container {
          image = local.elabftw-image
          name  = local.app-name

          env_from {
            config_map_ref {
              name = kubernetes_config_map.elabftw-env.metadata[0].name
            }
          }
          port {
            container_port = 443
            name           = "elabftw-port"
          }

          liveness_probe {
            tcp_socket {
              port = var.elabftw-port
            }
            failure_threshold = 10
            period_seconds    = 5
            timeout_seconds   = 30
          }
        }

      }
    }
  }
}

resource "kubernetes_config_map" "elabftw-env" {
  metadata {
    name      = "${local.app-name}-env"
    namespace = var.namespace
  }

  data = {
    DB_HOST = var.mysql-host
    DB_PORT = var.mysql-port
    DB_NAME = "elabftw"
    DB_USER = "elabftw"
    DB_PASSWORD = "elabftw"
    SECRET_KEY = "def00000ac655b9b510f30de68d0d6048a2f68792f92a2582fee9628875639680a96d26721885e9ba45416451845af8678417485801a0b0c6e161ae34814ebfd8c7f83a7"
    SITE_URL = "https://localhost:8081/"
    SERVER_NAME = "localhost"
    ALLOW_ORIGIN = "*"
    AUTO_DB_INIT = "true"
  }
}

resource "kubernetes_service" "elabftw-service" {
  metadata {
    name      = "${local.app-name}-service"
    namespace = var.namespace
  }
  spec {
    selector = {
      App = kubernetes_deployment.elabftw.spec.0.template.0.metadata[0].labels.App
    }
    port {
      name        = "elabftw-port"
      port        = var.elabftw-port
      node_port = 30001
    }
    type = "NodePort"

  }
}

locals {
  app-name = "elabftw"
  elabftw-image = var.elabftw-image
}
