resource "kubernetes_deployment" "linkahead" {
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
          image = local.linkahead-image
          name  = local.app-name

          env_from {
            config_map_ref {
              name = kubernetes_config_map.linkahead-env.metadata[0].name
            }
          }
          port {
            container_port = 10080
            name           = "linkahead-port"
          }

          liveness_probe {
            tcp_socket {
              port = var.linkahead-port
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

resource "kubernetes_config_map" "linkahead-env" {
  metadata {
    name      = "${local.app-name}-env"
    namespace = var.namespace
  }

  data = {
    CAOSDB_CONFIG_AUTH_OPTIONAL = "TRUE"
    CAOSDB_CONFIG_MYSQL_HOST = var.mariadb-host
    CAOSDB_CONFIG_MYSQL_PORT = var.mariadb-port
    NO_TLS = "1"
    DEBUG = "1"
  }
}

resource "kubernetes_service" "linkahead-service" {
  metadata {
    name      = "${local.app-name}-service"
    namespace = var.namespace
  }
  spec {
    selector = {
      App = kubernetes_deployment.linkahead.spec.0.template.0.metadata[0].labels.App
    }
    port {
      name        = "linkahead-port"
      port        = var.linkahead-port
    }
    type = "NodePort"
  }
}

locals {
  app-name = "linkahead"
  linkahead-image = var.linkahead-image
}
