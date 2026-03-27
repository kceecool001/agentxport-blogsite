include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  cluster_name = "agentxport-eks-prod"
  vpc_cidr     = "10.2.0.0/16"
  environment  = "prod"
}
