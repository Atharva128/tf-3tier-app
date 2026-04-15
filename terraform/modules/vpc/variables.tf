variable "environment" {
  description = "Environment"
  type = string
}

variable "region" {
    description = "AWS region"
    type = string
}

variable "availability_zones" {
  description = "AZ for subnet & EC2"
  type = list(string)
}

variable "vpc-cidr_block" {
  description = "CIDR Block for VPC"
}

variable "public_subnet.cidr_block" {
  description = "CIDR Block for VPC"
  type = list(string)
}

variable "frontend.cidr_block" {
  description = "CIDR Block for VPC"
  type = list(string)
}

variable "backend.cidr_block" {
  description = "CIDR Block for VPC"
  type = list(string)
}

variable "database.cidr_block" {
  description = "CIDR Block for VPC"
  type = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets (cost optimization)"
  type        = bool
  default     = false
}