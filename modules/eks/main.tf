resource "aws_eks_cluster" "this" {
  name     = var.project_name
  role_arn = var.cluster_role_arn
  version  = var.k8s_version

  vpc_config {
    subnet_ids             = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = var.security_group_ids
  }

}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  instance_types = var.instance_types
  disk_size      = var.disk_size

  remote_access {
    ec2_ssh_key = var.ssh_key_name
  }

  tags = {
    Name = "${var.project_name}-node-group"
  }
}

resource "kubernetes_persistent_volume_claim" "pvc" {
  metadata {
    name      = "grafana-pvc"
    namespace = "monitoring"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "20Gi"
      }
    }

    storage_class_name = "gp3" # StorageClass padrão no EKS com EBS
  }
}


