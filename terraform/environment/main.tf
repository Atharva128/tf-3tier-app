module "vpc" {
  source = "../../module/vpc"
  environment = var.environment
  vpc-cidr_block = var.vpc-cidr_block
  public_subnet_cidr_block = var.public_subnet.cidr_block
  frontend_cidr_block = var.frontend.cidr_block
  backend_cidr_block = var.backend.cidr_block
  database_cidr_block = var.database.cidr_block
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
}