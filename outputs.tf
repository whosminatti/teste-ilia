output "cluster_name" {
  description = "Nome do EKS"
  value       = var.project_name
}

output "cluster_endpoint" {
  description = "Endpoint do EKS"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID do EKS"
  value       = module.eks.cluster_security_group_id
}

output "node_group_arn" {
  description = "ARN do node group"
  value       = module.eks.node_group_arn
}