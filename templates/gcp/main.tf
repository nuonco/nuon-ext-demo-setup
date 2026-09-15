terraform {
  required_version = ">= 1.9"

  required_providers {
    google = {
      source  = "hashicorp/google"
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

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "nuon_runner_api_url" {
  type = string
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "stack" {
  api_url = var.nuon_runner_api_url
}

module "stack" {
  source  = "nuonco/stack/gcp"
  version = "~> 1.3"

  install_id = var.install_id
}

output "network_name" {
  value = module.stack.network_name
}

output "runner_instance_group" {
  value = module.stack.runner_instance_group
}
