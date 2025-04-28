variable "vpc_cidr" {}
variable "vpc_name" {}
variable "cidr_public_subnet" {}
variable "eu_availability_zone" {}
variable "cidr_private_subnet" {}

# ================================================================

# Setup VPC
resource "aws_vpc" "ecommerce_project_vpc_us_east_1" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

# Setup public subnet
resource "aws_subnet" "ecommerce_project_public_subnets" {
  count             = length(var.cidr_public_subnet)
  vpc_id            = aws_vpc.ecommerce_project_vpc_us_east_1.id
  cidr_block        = element(var.cidr_public_subnet, count.index)
  availability_zone = element(var.eu_availability_zone, count.index)

  tags = {
    Name = "ecommerce-public-subnet-${count.index + 1}"
  }
}

# Setup private subnet
resource "aws_subnet" "ecommerce_project_private_subnets" {
  count             = length(var.cidr_private_subnet)
  vpc_id            = aws_vpc.ecommerce_project_vpc_us_east_1.id
  cidr_block        = element(var.cidr_private_subnet, count.index)
  availability_zone = element(var.eu_availability_zone, count.index)

  tags = {
    Name = "ecommerce-private-subnet-${count.index + 1}"
  }
}

# Setup Internet Gateway
resource "aws_internet_gateway" "ecommerce_public_internet_gateway" {
  vpc_id = aws_vpc.ecommerce_project_vpc_us_east_1.id
  tags = {
    Name = "ecommerce-igw"
  }
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.ecommerce_public_internet_gateway]
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.ecommerce_project_public_subnets[0].id

  tags = {
    Name = "ecommerce-nat-gateway"
  }

  depends_on = [aws_internet_gateway.ecommerce_public_internet_gateway]
}

# Public Route Table
resource "aws_route_table" "ecommerce_public_route_table" {
  vpc_id = aws_vpc.ecommerce_project_vpc_us_east_1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecommerce_public_internet_gateway.id
  }
  tags = {
    Name = "ecommerce-public-rt"
  }
}

# Public Route Table and Public Subnet Association
resource "aws_route_table_association" "ecommerce_public_rt_subnet_association" {
  count          = length(aws_subnet.ecommerce_project_public_subnets)
  subnet_id      = aws_subnet.ecommerce_project_public_subnets[count.index].id
  route_table_id = aws_route_table.ecommerce_public_route_table.id
}

# Private Route Table
resource "aws_route_table" "ecommerce_private_route_table" {
  vpc_id = aws_vpc.ecommerce_project_vpc_us_east_1.id
  
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "ecommerce-private-rt"
  }
}

# Private Route Table and private Subnet Association
resource "aws_route_table_association" "ecommerce_private_rt_subnet_association" {
  count          = length(aws_subnet.ecommerce_project_private_subnets)
  subnet_id      = aws_subnet.ecommerce_project_private_subnets[count.index].id
  route_table_id = aws_route_table.ecommerce_private_route_table.id
}

# ================================================================

# Get outputs from your networking setup
output "private_subnet_ids" {
  value = aws_subnet.ecommerce_project_private_subnets.*.id
}

output "public_subnet_ids" {
  value = aws_subnet.ecommerce_project_public_subnets.*.id
}

output "ecommerce_vpc_id" {
  value = aws_vpc.ecommerce_project_vpc_us_east_1.id
}

output "ecommerce_public_subnets" {
  value = aws_subnet.ecommerce_project_public_subnets.*.id
}

output "public_subnet_cidr_block" {
  value = aws_subnet.ecommerce_project_public_subnets.*.cidr_block
}

output "public_subnet_id" {
  value = aws_subnet.ecommerce_project_public_subnets[0].id
  description = "ID of the first public subnet"
}
