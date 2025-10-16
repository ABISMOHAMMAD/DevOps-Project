### Variable for the VPC

variable "project" {
  description = "Project name"
}

variable "cidr" {
  description = "CIDR Block of vpc"
  type        = string
}

variable "env" { type = string }
variable "public_subnets_cidr" {

  type        = list(string)
  description = "CIDR Block of Public Subnets"

}

variable "private_subnets_cidr" {

  type        = list(string)
  description = "CIDR Block of Private Subnets"

}
variable "azs" {

  type        = list(string)
  description = "Availability Zones for the VPC"

}




### Variable for the EKS

variable "cluster_name" {
}



variable "desired_size_node_size" {
  type = string
}

variable "min_size_node_size" {
  type = string
}
variable "max_size_node_size" {
  type = string
}
variable "max_unavailable_node" {
  type = string
}


variable "addons" {
  description = "Map of EKS add-ons and their versions"
  type        = map(string)
}

variable "node_instance_types" {

  type        = list(string)
  description = "Instance types for the nodes"

}


variable "capacity_type" {
  type = string
}

### Variable for the Bastion Host

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}
