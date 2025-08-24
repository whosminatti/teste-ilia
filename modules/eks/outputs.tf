output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.this.id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID vinculado ao EKS"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "Certificado em Base64 do EKS"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "node_group_arn" {
  description = "Amazon Resource Name (ARN) do Node Group"
  value       = aws_eks_node_group.this.arn
}