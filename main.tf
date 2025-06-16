terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "5.100.0"
        }
    }
    backend "s3" {  
        bucket         = "my-eks-bucket"
        key            = "terraform/eks/terraform.tfstate"
        region         = "us-east-1"
        dynamodb_table = "terraform-eks-statelocks"
      
    }
}
provider "aws" {
    region = "us-east-1"
}  

module "vpc"     {
    source = "eks/modules/vpc"

    vpc_cidr              = var.vpc_cidr
    availability_zones   = var.availability_zones
    public_subnet_cidrs  = var.public_subnet_cidrs
    private_subnet_cidrs = var.private_subnet_cidrs
    cluster_name         = var.cluster_name

}

module "eks" {
    source = "eks/modules/eks"

    cluster_name         = var.cluster_name
    vpc_id               = module.vpc.vpc_id
    subnet_ids           = module.vpc.private_subnet_ids
    cluster_version      = var.cluster_version
    node_groups = var.node_groups
}   