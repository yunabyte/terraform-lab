provider "aws" {
  region = "ap-northeast-2"
  
  default_tags {
    tags = {
      Name    = "student0"
      Subject = "cloud-programming"
      Chapter = "practice3"
    }
  }
}

module "vpc" {
  source       = "./modules/vpc"
  vpc_main_cidr = var.vpc_main_cidr
}

module "cluster" {
  source                 = "./modules/cluster"
  vpc_id                 = module.vpc.vpc_id
  public_subnets         = module.vpc.public_subnets
  private_subnets        = module.vpc.private_subnets
  server_port            = var.server_port
  alb_security_group_name = var.alb_security_group_name
  alb_name               = var.alb_name
}