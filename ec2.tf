resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "Allow SSH"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "Allow SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh"
  }
}

resource "aws_security_group" "http" {
  name        = "http"
  description = "Allow HTTP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "Allow HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "http"
  }
}

resource "aws_security_group" "nodeport" {
  name        = "nodeport"
  description = "Allow NodePort"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "Allow HTTP"
    from_port        = 30080
    to_port          = 30080
    protocol         = "tcp"
    security_groups = [
      "${aws_security_group.http.id}",
    ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nodeport"
  }
}

resource "aws_instance" "minikube" {
    ami = "<env_ami>"
    instance_type = "t2.medium"
    subnet_id = "${module.vpc.private_subnets[0]}"
    vpc_security_group_ids = ["${aws_security_group.nodeport.id}"]
    associate_public_ip_address = true
    key_name = "Default"
    user_data = <<EOF
#!/bin/bash
sudo minikube start --vm-driver=none --kubernetes-version=v1.21.5
sudo kubectl apply -f /home/ubuntu/nginx.yaml
EOF
    tags = {
        Name        = "Minikube"
        Terraform   = true
        Environment = var.env
    }
}

module "nginx-alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "nginx-alb"

  load_balancer_type = "application"

  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = ["${aws_security_group.http.id}"]

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 30080
      target_type      = "instance"
      targets = [
        {
          target_id = "${aws_instance.minikube.id}"
          port = 30080
        }
      ]
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = var.env
  }
}