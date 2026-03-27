# Security layer - Local secrets, KMS simulation

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
  merge_strategy = "deep"
}

terraform {
  source = "../../../modules/backend"
}

dependency "critical-addons" {
  config_path = "../01-k8s-critical-addons"
}

inputs = {
  environment       = include.root.locals.environment
  chart_path        = "${get_repo_root()}/helm-charts/demo-app"
}
