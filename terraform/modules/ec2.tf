resource "aws_instance" "bastion_host" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet[0].id
  iam_instance_profile   = aws_iam_instance_profile.bastion_ec2_profile.name
  vpc_security_group_ids = [aws_security_group.security_group.id]


  user_data = <<-EOF
    #!/bin/bash

    # Update and install dependencies
    apt-get update -y
    apt-get install -y unzip curl jq

    # Install AWS CLI v2
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install
    ln -s /usr/local/bin/aws /usr/bin/aws

    # Install kubectl
    curl -o /usr/local/bin/kubectl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x /usr/local/bin/kubectl
    ln -s /usr/local/bin/kubectl /usr/bin/kubectl


  EOF

  tags = {
    Name = "${local.project}-bastion-host"
    Env  = "${var.env}"
  }


  depends_on = [aws_eks_node_group.node_group_eks, ]
}





