variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
}

variable "node_group_instance_types" {
  description = "EC2 instance types for node group"
  type        = list(string)
}

variable "node_group_desired_size" {
  description = "Desired number of nodes"
  type        = number
}

variable "node_group_min_size" {
  description = "Minimum number of nodes"
  type        = number
}

variable "node_group_max_size" {
  description = "Maximum number of nodes"
  type        = number
}
