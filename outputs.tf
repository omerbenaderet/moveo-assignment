output "region" {
  description = "AWS region"
  value       = var.region
}

output "sg_ssh_id" {
  description = "Security Group ID"
  value = aws_security_group.ssh.id
}

output "public_subnets_ids" {
  description = "VPC Subnet IDs"
  value = module.vpc.public_subnets
}

output "public_subnet" {
  description = "VPC Subnet ID"
  value = module.vpc.public_subnets[0]
}

output "minikube_ami" {
  description = "Minikube instance AMI"
  value = aws_instance.minikube.ami
}

output "alb_dns" {
  description = "ALB DNS name"
  value = module.nginx-alb.lb_dns_name
}