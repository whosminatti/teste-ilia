output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = var.project_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "node_group_arn" {
  description = "ARN of the EKS node group"
  value       = module.eks.node_group_arn
}