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