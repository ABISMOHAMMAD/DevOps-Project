# Variable values for the VPC

project                = "EKS"
cidr                   = "10.0.0.0/16"
public_subnets_cidr    = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets_cidr   = ["10.0.3.0/24", "10.0.4.0/24"]
azs                    = ["ap-south-1a", "ap-south-1b"]
env                    = "Dev"
region                 = "ap-south-1"
cluster_name           = "Demo-eks"
ami                    = "ami-07f07a6e1060cd2a8"
instance_type          = "t2.micro"
desired_size_node_size = "1"
min_size_node_size     = "1"
max_size_node_size     = "2"
max_unavailable_node   = "1"
addons = {
  vpc-cni    = "v1.19.6-eksbuild.1"
  coredns    = "v1.11.4-eksbuild.22"
  kube-proxy = "v1.31.9-eksbuild.2"
}

node_instance_types = ["t3.medium", "t3a.medium"]
capacity_type       = "SPOT"
