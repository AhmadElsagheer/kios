include "root" {
  path           = find_in_parent_folders("root.hcl")
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "../../../modules/monitoring"
}

inputs = {
  environment  = include.root.locals.environment
  cluster_name = include.root.locals.cluster_name
}
