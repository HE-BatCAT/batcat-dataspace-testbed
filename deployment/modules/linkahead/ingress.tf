resource "kubernetes_ingress_v1" "linkahead-ingress" {
  metadata {
    name      = "linkahead-ingress"
    namespace = var.namespace
    annotations = {
      "nginx.ingress.kubernetes.io/use-regex"      = "true"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path = "/linkahead(/|$)(.*)"
          backend {
            service {
              name = kubernetes_service.linkahead-service.metadata.0.name
              port {
                number = var.linkahead-port
              }
            }
          }
        }
      }
    }
  }
}
