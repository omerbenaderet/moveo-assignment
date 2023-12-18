variable "region" {
  type        = string
  default     = "us-east-1"
  description = "region"
}

variable "env" {
  type       = string
  default    = "dev"
  description = "env"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
  description = "VPC cidr"
}

locals {
  subnets = [module.vpc.public_subnets[0], module.vpc.public_subnets[1], module.vpc.public_subnets[2], module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
}