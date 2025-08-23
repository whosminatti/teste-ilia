module "vpc" {
  source                = "./modules/vpc"
  cidr_block            = var.vpc_cidr
  project_name          = var.project_name
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  availability_zones    = var.availability_zones
}

module "security_groups" {
  source                = "./modules/security_groups"
  depends_on            = [module.vpc]
  vpc_id                = module.vpc.vpc_id
  project_name          = "${var.project_name}-eks"
}

module "iam" {
  source                = "./modules/iam"
  depends_on            = [module.vpc]
  project_name          = "${var.project_name}-eks"
}

module "eks" {
  source                = "./modules/eks"
  depends_on            = [module.iam, module.vpc, module.security_groups]
  project_name          = var.project_name
  cluster_role_arn      = module.iam.eks_cluster_role_arn
  k8s_version           = var.k8s_version
  subnet_ids            = module.vpc.private_subnet_ids
  node_role_arn         = module.iam.eks_node_role_arn
  security_group_ids    = [module.security_groups.eks_cluster_security_group_id]
  node_desired_size     = var.node_desired_size
  node_max_size         = var.node_max_size
  node_min_size         = var.node_min_size
  instance_types        = var.node_instance_type
  disk_size             = var.disk_size
  ssh_key_name          = "teste-ilia-eks" 
}

# Módulo kubernetes_resources removido - gerenciado via kubectl no GitHub Actions