
output "monitoring_namespace" {
  description = "Name of the monitoring namespace"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "grafana_pvc_name" {
  description = "Name of the Grafana PVC"
  value       = kubernetes_persistent_volume_claim.grafana_pvc.metadata[0].name
}