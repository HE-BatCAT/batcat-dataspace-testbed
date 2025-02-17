resource "kubernetes_deployment" "mariadb" {
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
          image = local.mariadb-image
          name  = local.app-name

          env_from {
            config_map_ref {
              name = kubernetes_config_map.mariadb-env.metadata[0].name
            }
          }
          port {
            container_port = 3306
            name           = "mariadb-port"
          }

          liveness_probe {
            tcp_socket {
              port = 3306
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

resource "kubernetes_config_map" "mariadb-env" {
  metadata {
    name      = "${local.app-name}-env"
    namespace = var.namespace
  }

  data = {
    MYSQL_ROOT_PASSWORD = "caosdb1234"
  }
}

resource "kubernetes_service" "mariadb-service" {
  metadata {
    name      = "${local.app-name}-service"
    namespace = var.namespace
  }
  spec {
    selector = {
      App = kubernetes_deployment.mariadb.spec.0.template.0.metadata[0].labels.App
    }
    port {
      name        = "mariadb-port"
      port        = var.database-port
      target_port = var.database-port
    }
  }
}

locals {
  app-name = "mariadb"
  mariadb-image = "mariadb:10.11"
  db-ip    = kubernetes_service.mariadb-service.spec.0.cluster_ip
  db-url   = "${kubernetes_service.mariadb-service.metadata[0].name}:${var.database-port}"
  db-host  = kubernetes_service.mariadb-service.metadata[0].name
}
