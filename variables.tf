variable "vpc_cidr" {
   description = "The CIDR block for the VPC"
   type        = string
}
variable "project_name" {
  description = "The name of the project"
  type        = string
}
variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
}
variable "ssh_key_name" {
  description = "The name of the SSH key pair"
  type        = string
}
variable "public_subnet_cidrs"{
    description = "List of public subnet CIDR blocks"
    type        = list(string)
}
variable "private_subnet_cidrs"{
    description = "List of private subnet CIDR blocks"
    type        = list(string)
}
variable "availability_zones" {
    description = "List of availability zones"
    type        = list(string)
}
variable "k8s_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
}
variable "node_desired_size" {
  description = "The desired number of worker nodes"
  type        = number
}
variable "node_max_size" {
  description = "The maximum number of worker nodes"
  type        = number
}
variable "node_min_size" {
  description = "The minimum number of worker nodes"
  type        = number
}
variable "node_instance_type" {
  description = "The instance type for the worker nodes"
  type        = list(string)
} 
variable "disk_size" {
  description = "The volume size for the worker nodes (in GB)"
  type        = number
}
variable "athena_database_name" {
  default = "monitoring_db"
}
variable "athena_table_name" {
  default = "iot_events"
}
