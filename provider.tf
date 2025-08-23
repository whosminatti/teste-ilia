terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "create_eks" {
  type    = bool
  default = true
}

data "aws_eks_cluster" "cluster" {
  count = var.create_eks ? 1 : 0
  name  = var.project_name
}

data "aws_eks_cluster_auth" "cluster" {
  count = var.create_eks ? 1 : 0
  name  = var.project_name
}

provider "kubernetes" {
  host                   = var.create_eks ? data.aws_eks_cluster.cluster[0].endpoint : ""
  cluster_ca_certificate = var.create_eks ? base64decode(data.aws_eks_cluster.cluster.certificate_authority.data) : ""
  token                  = var.create_eks ? data.aws_eks_cluster_auth.cluster.token : ""
}

