variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "cidr_public_subnet" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "eu_availability_zone" {
  description = "Availability zones"
  type        = list(string)
}

variable "cidr_private_subnet" {
  description = "CIDR block for private subnet"
  type        = list(string)
}


variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}