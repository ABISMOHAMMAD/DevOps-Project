
resource "random_string" "random" {
  length  = 6
  special = false
}



######################################
# Cluster Role
######################################
resource "aws_iam_role" "cluster_role" {
  name = "${local.cluster_name}-role-${random_string.random.result}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}



######################################
# Cluster Node Role
######################################



resource "aws_iam_role" "node_role" {
  name = "${local.cluster_name}-node-role-${random_string.random.result}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_role.name
}


######################################
# Bastion Node Role
######################################

resource "aws_iam_role" "bastion_ec2_role" {
  name = "${local.cluster_name}-bastion-node-role-${random_string.random.result}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}


data "aws_caller_identity" "current" {
}
resource "aws_iam_role_policy" "bastion_permissions" {
  name = "${local.cluster_name}-bastion-access-policy-${random_string.random.result}"
  role = aws_iam_role.bastion_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEKSDescribeCluster"
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowPassNodeRole"
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.cluster_name}-node-role-*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "node_AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.bastion_ec2_role.name
}

resource "aws_iam_role_policy_attachment" "bastion_eks_cluster_policy" {
  role       = aws_iam_role.bastion_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "bastion_eks_service_policy" {
  role       = aws_iam_role.bastion_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}



resource "aws_iam_instance_profile" "bastion_ec2_profile" {
  name = "${local.cluster_name}-bastion-instance-profile-${random_string.random.result}"
  role = aws_iam_role.bastion_ec2_role.name
}

################################################################################################
# Role for EKS to manage AWS Services using OIDC
################################################################################################


data "tls_certificate" "oidc_tls" {
  url        = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  depends_on = [aws_eks_cluster.cluster]

}

resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc_tls.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer

  depends_on = [aws_eks_cluster.cluster, ]
}

data "aws_iam_policy_document" "oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "oidc_role" {
  assume_role_policy = data.aws_iam_policy_document.oidc_assume_role_policy.json
  name               = "${local.cluster_name}-oidc-role-${random_string.random.result}"

  depends_on = [
    aws_iam_openid_connect_provider.oidc
  ]
}
