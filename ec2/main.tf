variable "vpc_name" {}
variable "subnet_id" {
  description = "ID of the public subnet where the EC2 instance will be placed"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

# ================================================================

# Security Group for EC2 instance
resource "aws_security_group" "ecommerce_sg" {
  name        = "${var.vpc_name}-security-group"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = var.vpc_id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # HTTPS access
  # ingress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  #   description = "HTTPS access"
  # }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "ecommerce-sg"
    Project = "ecommerce-app"
  }
}

# EC2 Instance
resource "aws_instance" "ecommerce_instance" {
  ami                    = "ami-0622e1ae83ac88c02"  # Update to new AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ecommerce_sg.id]
  key_name               = "midterm"
  subnet_id              = var.subnet_id
  associate_public_ip_address = true

  tags = {
    Name = "ecommerce-instance"
    Project = "ecommerce-app"
  }

  # User data script to install dependencies and configure EKS cluster communication
  user_data = <<-EOF
  #!/bin/bash
  set -e  # Exit on error
  exec > >(tee /var/log/user-data.log) 2>&1  # Log everything

  # Update and install dependencies
  sudo apt update -y
  sudo apt install -y unzip curl jq

  # Install AWS CLI v2
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  rm awscliv2.zip

  # Install kubectl
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm kubectl

  # Install eksctl
  curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
  sudo mv /tmp/eksctl /usr/local/bin
  
  # Create directories and set permissions
  mkdir -p /home/ubuntu/.kube
  mkdir -p /home/ubuntu/.aws
  chown -R ubuntu:ubuntu /home/ubuntu/.kube
  chown -R ubuntu:ubuntu /home/ubuntu/.aws

  EOF

  # Make sure the instance has an Elastic IP (optional but recommended)
  root_block_device {
    volume_size = 16  # Changed from 8 to 16 to meet minimum AMI requirement
    volume_type = "gp2"
    delete_on_termination = true
  }
}

# Elastic IP for the EC2 instance (optional but recommended)
resource "aws_eip" "ecommerce_eip" {
  instance = aws_instance.ecommerce_instance.id
  domain   = "vpc"

  tags = {
    Name = "ecommerce-eip"
    Project = "ecommerce-app"
  }
}

# ================================================================

# Output the public IP and DNS of the instance
output "instance_public_ip" {
  value       = aws_eip.ecommerce_eip.public_ip
  description = "The public IP address of the ecommerce instance"
}

# output "instance_public_dns" {
#   value       = aws_instance.ecommerce_instance.public_dns
#   description = "The public DNS of the ecommerce instance"
# }

output "security_group_id" {
  value       = aws_security_group.ecommerce_sg.id
  description = "The ID of the EC2 security group"
}

output "instance_id" {
  value       = aws_instance.ecommerce_instance.id
  description = "The ID of the EC2 instance"
}
