# Criar namespace de monitoring primeiro
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# PVC para Grafana
resource "kubernetes_persistent_volume_claim" "grafana_pvc" {
  depends_on = [kubernetes_namespace.monitoring]
  
  metadata {
    name      = "grafana-pvc"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = var.grafana_storage_size
      }
    }

    storage_class_name = var.storage_class_name
  }
}