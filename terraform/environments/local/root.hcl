# Root Terragrunt configuration for local environment

locals {
  environment    = "local"
  region         = "local"
  project_id     = "local-123"

  cluster_name     = "default"
}

# Generate providers for child modules
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "kubernetes" {
      config_path = "${get_repo_root()}/k3s-in-orbstack/kubeconfig"
    }

    provider "helm" {
      kubernetes = {
        config_path = "${get_repo_root()}/k3s-in-orbstack/kubeconfig"
      }
    }
  EOF
}
