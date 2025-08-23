variable "vpc_cidr" {
   description = "The CIDR block for the VPC"
   type        = string
   default     = "10.0.0.0/16"
 }
variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "teste-ilia"
}
variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}
variable "ssh_key_name" {
  description = "The name of the SSH key pair"
  type        = string
  default     = "my-ssh-key"
}
variable "public_subnet_cidrs"{
    description = "List of public subnet CIDR blocks"
    type        = list(string)
    default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "private_subnet_cidrs"{
    description = "List of private subnet CIDR blocks"
    type        = list(string)
    default     = ["10.0.3.0/24", "10.0.4.0/24"]
}
variable "availability_zones" {
    description = "List of availability zones"
    type        = list(string)
    default     = ["us-east-1a", "us-east-1b"]
}
variable "k8s_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"
}
variable "node_desired_size" {
  description = "The desired number of worker nodes"
  type        = number
  default     = 2
}
variable "node_max_size" {
  description = "The maximum number of worker nodes"
  type        = number
  default     = 3
}
variable "node_min_size" {
  description = "The minimum number of worker nodes"
  type        = number
  default     = 1
}
variable "node_instance_type" {
  description = "The instance type for the worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
} 
variable "disk_size" {
  description = "The volume size for the worker nodes (in GB)"
  type        = number
  default     = 20
}