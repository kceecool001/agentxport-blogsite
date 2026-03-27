include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  cluster_name = "agentxport-eks-staging"
  vpc_cidr     = "10.1.0.0/16"
  environment  = "staging"
}
