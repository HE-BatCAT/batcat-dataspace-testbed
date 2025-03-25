resource "kubernetes_deployment" "mysql" {
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
          image = local.mysql-image
          name  = local.app-name

          env_from {
            config_map_ref {
              name = kubernetes_config_map.mysql-env.metadata[0].name
            }
          }
          port {
            container_port = 3306
            name           = "mysql-port"
          }

          readiness_probe {
            exec {
              command = [
                "/usr/bin/mysql",
                "--user=elabftw",
                "--password=elabftw",
                "--execute",
                "SHOW DATABASES;",
              ]
            }
            initial_delay_seconds = 5
            failure_threshold = 10
            period_seconds    = 2
            timeout_seconds   = 1
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

resource "kubernetes_config_map" "mysql-env" {
  metadata {
    name      = "${local.app-name}-env"
    namespace = var.namespace
  }

  data = {
    MYSQL_ROOT_PASSWORD = "Pu87cw5dhoSGRboI7R1ClmJQruB2kYs"
    MYSQL_DATABASE = "elabftw"
    MYSQL_USER = "elabftw"
    MYSQL_PASSWORD = "elabftw"
    TZ = "Europe/Berlin"
  }
}

resource "kubernetes_service" "mysql-service" {
  metadata {
    name      = "${local.app-name}-service"
    namespace = var.namespace
  }
  spec {
    selector = {
      App = kubernetes_deployment.mysql.spec.0.template.0.metadata[0].labels.App
    }
    port {
      name        = "mysql-port"
      port        = var.database-port
      target_port = var.database-port
    }
  }
}

locals {
  app-name = "mysql"
  mysql-image = "mysql:8.0"
  database-host  = kubernetes_service.mysql-service.metadata[0].name
}
