module "eks" {
  source                 = "./modules"
  cidr                   = var.cidr
  env                    = var.env
  private_subnets_cidr   = var.private_subnets_cidr
  public_subnets_cidr    = var.public_subnets_cidr
  azs                    = var.azs
  project                = var.project
  cluster_name           = var.cluster_name
  instance_type          = var.instance_type
  ami                    = var.ami
  max_unavailable_node   = var.max_unavailable_node
  min_size_node_size     = var.min_size_node_size
  max_size_node_size     = var.max_size_node_size
  desired_size_node_size = var.desired_size_node_size
  addons                 = var.addons
  node_instance_types    = var.node_instance_types
  capacity_type          = var.capacity_type
}



