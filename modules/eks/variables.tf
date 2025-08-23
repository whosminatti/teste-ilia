variable "project_name" {
  type = string
}

variable "cluster_role_arn" {
  type = string
}

variable "k8s_version" {
  type    = string
  default = "1.27"
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "node_role_arn" {
  type = string
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 5
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "disk_size" {
  type    = number
  default = 20
}

variable "ssh_key_name" {
  type = string
}