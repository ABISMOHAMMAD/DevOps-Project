locals {
  cluster_name = var.cluster_name
}

resource "aws_eks_cluster" "cluster" {
  name = "${local.cluster_name}-cluster-${random_string.random.result}"

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.cluster_role.arn
  version  = "1.31"

  vpc_config {

    endpoint_private_access = true
    endpoint_public_access  = false
    subnet_ids = [
      aws_subnet.private_subnet[0].id,
      aws_subnet.private_subnet[1].id
    ]
    security_group_ids = [aws_security_group.security_group.id, ]


  }


  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]

  tags = {
    Name = "${local.project}-cluster"
    Env  = "${var.env}"
  }


}


resource "aws_security_group" "eks_security_group" {
  name        = "${local.project}-eks-sg-vpc"
  description = "Allow inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc.id


  tags = {
    Name = "${local.project}-eks-sg"
    Env  = "${var.env}"
  }

  depends_on = [aws_eks_cluster.cluster, ]
}

resource "aws_vpc_security_group_ingress_rule" "allow_from_bastion_node" {
  security_group_id            = aws_security_group.eks_security_group.id
  referenced_security_group_id = aws_security_group.security_group.id
  ip_protocol                  = "-1"
}


resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.eks_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}




resource "aws_eks_node_group" "node_group_eks" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${local.cluster_name}-node-group-${random_string.random.result}"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = aws_subnet.private_subnet[*].id


  scaling_config {
    desired_size = var.desired_size_node_size
    max_size     = var.max_size_node_size
    min_size     = var.min_size_node_size
  }


  instance_types = var.node_instance_types
  capacity_type  = var.capacity_type

  update_config {
    max_unavailable = var.max_unavailable_node
  }

  depends_on = [
    aws_eks_cluster.cluster,
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]
}


resource "aws_eks_addon" "addons" {
  for_each = var.addons

  cluster_name  = aws_eks_cluster.cluster.name
  addon_name    = each.key
  addon_version = each.value

  depends_on = [
    aws_eks_node_group.node_group_eks,
  ]
}


resource "aws_eks_access_entry" "admin_access" {
  cluster_name  = aws_eks_cluster.cluster.name
  principal_arn = aws_iam_role.bastion_ec2_role.arn
  type          = "STANDARD"

  depends_on = [aws_eks_node_group.node_group_eks, ]
}

resource "aws_eks_access_policy_association" "admin_access_assoc" {
  cluster_name  = aws_eks_cluster.cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.admin_access.principal_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admin_access]
}
