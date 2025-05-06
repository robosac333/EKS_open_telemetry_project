variable "vpc_name" {}
variable "subnet_id" {
  description = "ID of the public subnet where the EC2 instance will be placed"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "aws_access_key_id" {}

variable "aws_secret_access_key" {}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
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

  # Modified user data script without credentials
  user_data = <<-EOF
  #!/bin/bash
  set -e  # Exit on error
  exec > >(tee /var/log/user-data.log) 2>&1  # Log everything

  while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    echo "Waiting for other apt processes to finish..."
    sleep 5
  done

  set -e  # Exit on error
  exec > >(tee /var/log/user-data.log) 2>&1  # Log everything

  # Update and install dependencies
  sudo apt update -y
  sudo apt install -y unzip curl jq

  # Install AWS CLI v2
  sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  rm awscliv2.zip

  # Install kubectl
  sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm kubectl

  # Install eksctl
  sudo curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
  sudo mv /tmp/eksctl /usr/local/bin
  
  
  # Create directories and set permissions
  mkdir -p /home/ubuntu/.kube
  mkdir -p /home/ubuntu/.aws
  chown -R ubuntu:ubuntu /home/ubuntu/.kube
  chown -R ubuntu:ubuntu /home/ubuntu/.aws
  chmod 700 /home/ubuntu/.aws

  # Create credentials file
  sudo -u ubuntu bash -c 'cat > /home/ubuntu/.aws/credentials << EOT
  [default]
  aws_access_key_id=${var.aws_access_key_id}
  aws_secret_access_key=${var.aws_secret_access_key}
  region=us-west-2
  output=json
  EOT'

  # Create config file
  sudo -u ubuntu bash -c 'cat > /home/ubuntu/.aws/config << EOT
  [default]
  region=us-west-2
  output=json
  EOT'

  # Set proper permissions
  sudo chmod 600 /home/ubuntu/.aws/credentials /home/ubuntu/.aws/config
  sudo chown ubuntu:ubuntu /home/ubuntu/.aws/credentials /home/ubuntu/.aws/config

  # Verify AWS CLI can access credentials
  sudo -u ubuntu aws sts get-caller-identity

  # Run all subsequent AWS commands as ubuntu user
  sudo -u ubuntu bash -c '
    # Update kubeconfig
    aws eks update-kubeconfig --region us-west-2 --name opentelemetry-cluster
    sleep 10
  '
  sudo snap install helm --classic
  sleep 5

  # Run Helm commands as ubuntu user
  sudo -u ubuntu bash -c '
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update

    helm install prometheus-operator prometheus-community/kube-prometheus-stack \
      --namespace monitoring \
      --create-namespace \
      --wait
  '

  sleep 10  # Wait for Prometheus to initialize
  
  sudo -u ubuntu bash -c '
    helm install grafana-release grafana/grafana \
      --namespace monitoring \
      --wait
  '
  sudo -u ubuntu bash -c '
    # Clone repo and apply kubernetes config
    cd /home/ubuntu
    git clone https://github.com/robosac333/opentelemetry-demo.git
    kubectl apply -f /home/ubuntu/opentelemetry-demo/kubernetes/opentelemetry-demo.yaml -n otel-demo --validate=false
  '
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
