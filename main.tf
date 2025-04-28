terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.24"
    }
  }

  cloud {
    organization = "Ecommerce_Deployment"
    workspaces {
      name = "Ecommerce_Platform"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

module "networking" {
  source               = "./networking"
  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  cidr_public_subnet   = var.cidr_public_subnet
  eu_availability_zone = var.eu_availability_zone
  cidr_private_subnet  = var.cidr_private_subnet
}

module "ec2" {
  source    = "./ec2"
  subnet_id = module.networking.public_subnet_id
  vpc_id    = module.networking.ecommerce_vpc_id
  vpc_name  = var.vpc_name
}

# This module configures monitoring and auto-scaling alarms for the application
# module "cloudwatch" {
#   source                  = "./cloudwatch"
#   prefix                  = "ecommerce"
#   aws_region              = "us-east-1"
#   autoscaling_group_name  = module.loadbalancer.autoscaling_group_name
#   scale_out_policy_arn    = module.loadbalancer.scale_out_policy_arn
#   scale_in_policy_arn     = module.loadbalancer.scale_in_policy_arn
#   load_balancer_arn_suffix = module.loadbalancer.load_balancer_arn_suffix

#   # Alarm thresholds
#   high_cpu_threshold      = 70
#   low_cpu_threshold       = 30
#   high_network_threshold  = 5000000
#   high_request_count_threshold = 1000
#   high_response_time_threshold = 1

#   # Evaluation settings
#   evaluation_periods      = 2
#   period                  = 300

#   # Enable/disable specific alarms
#   enable_network_alarms   = true
#   enable_request_count_alarm = true
#   enable_response_time_alarm = true

#   # Create a dashboard
#   create_dashboard        = true
  
#   tags = {
#     Project = "ecommerce-app"
#   }
# }

# ================================================================

# Output values from the module
output "instance_public_ip" {
  value = module.ec2.instance_public_ip
}

# output "website_url" {
#   value = module.ec2.website_url
# }

# Add CloudWatch outputs
# output "high_cpu_alarm_arn" {
#   value       = module.cloudwatch.high_cpu_alarm_arn
#   description = "ARN of the high CPU utilization alarm"
# }

# output "low_cpu_alarm_arn" {
#   value       = module.cloudwatch.low_cpu_alarm_arn
#   description = "ARN of the low CPU utilization alarm"
# }

# output "autoscaling_group_name" {
#   value       = module.loadbalancer.autoscaling_group_name
#   description = "Name of the Auto Scaling Group"
# }

# output "cloudwatch_dashboard_arn" {
#   value       = module.cloudwatch.dashboard_arn
#   description = "ARN of the CloudWatch dashboard"
# }
