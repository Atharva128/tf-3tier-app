var.environment = "dev"
var.region = "us-east-1"
vpc-cidr_block = "10.0.0.0/16"
var.availability_zones = [ "us-east-1a", "us-east-1b" ]
public_subnet.cidr_block = [ "10.0.1.0/24" , "10.0.10.0/24"]
frontend.cidr_block = [ "10.0.2.0/24" , "10.0.20.0/24"]
backend.cidr_block = [ "10.0.3.0/24" , "10.0.30.0/24"]
database.cidr_block = [ "10.0.4.0/24" , "10.0.40.0/24"]