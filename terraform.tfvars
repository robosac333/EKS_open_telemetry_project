vpc_cidr           = "10.60.0.0/16"
vpc_name           = " EKS-client-vpc"
# cidr_public_subnet = ["10.0.1.0/24"]
# eu_availability_zone = ["us-east-1a"]
# cidr_private_subnet  = ["10.0.2.0/24"]
cidr_public_subnet = ["10.60.1.0/24", "10.60.2.0/24"]
cidr_private_subnet  = ["10.60.3.0/24", "10.60.4.0/24"]
eu_availability_zone = ["us-west-2a", "us-west-2b", "us-west-2c"]

aws_access_key_id     = ""
aws_secret_access_key = ""
aws_region            = "us-west-2"