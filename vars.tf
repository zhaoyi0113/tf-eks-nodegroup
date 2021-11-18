variable "eks_cluster_name" {
  type    = string
  default = "elk"
}

variable "component_name" {
  type        = string
  description = "Component name"
  default     = "elk"
}

variable "region" {
  type    = string
  default = "ap-southeast-2"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "api_name" {
  type    = string
  default = "elk"
}

variable "node_size" {
  type    = list
  default = ["t3.large"]
}
