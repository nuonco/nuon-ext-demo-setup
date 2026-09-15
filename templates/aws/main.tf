terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
    stack = {
      source  = "nuonco/stack"
      version = ">= 0.9.0"
    }
  }
}

variable "install_id" {
  type = string
}

variable "region" {
  type = string
}

variable "nuon_runner_api_url" {
  type = string
}

provider "aws" {
  region = var.region
}

provider "stack" {
  api_url = var.nuon_runner_api_url
}

module "stack" {
  source  = "nuonco/stack/aws"
  version = "~> 1.4.2"

  install_id               = var.install_id
  enable_telemetry_ingress = false
}

output "vpc_id" {
  value = module.stack.vpc_id
}

output "runner_asg_name" {
  value = module.stack.runner_asg_name
}
