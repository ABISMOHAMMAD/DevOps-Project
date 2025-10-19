resource "aws_instance" "bastion_host" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet[0].id
  key_name               = aws_key_pair.bastion_key_pair.key_name
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


resource "aws_key_pair" "bastion_key_pair" {

  key_name   = "${local.project}-bastion-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDSbS7aX/hdlX/ebmv1DdssSHM7/6YH+WSF0vGsCG/L22NJJC4Qq5N4WuqCoeos7lWMJF0+RNY3aFXAwKeL0aNGPfW9cpbRmoA1mhXHF5bQLNUYr8Ou1bNHAQ2AFFoH2bUrvSEmmr4dVtRZVaadW7GMFq7UCLvNxBdnLIGP8alX+8R1L3SJ0vieLzL6szdukWLhyZW5JGgdqA8OddBQkV54hd0QfY+zdQ85Ny9T+11RBpyyZbEIfWXpV5lb1xrD0ZYZdXyp8xVTTZ3KYJF4NSYmOL9h4tlk/eKV8ouYHaQfLF/0tAs1SntcmdGlXbpkzLfKWgGx1H3B5ZQB+0GFbsga6cQknJ1qQOxfhwG4QzaVbI2J6M+Wf755dIIkL+ZSLagS1i5/EdEni4fcYwYdMqm8s1gNX8j672HokWPcEqLwMGZYMC9/E1NLfQwTfQL/rg0+7KRoUT9psrW/svF73g36kYm2olCp+nSvPSVej8v/LSS+aV+QQaGWuoZzEnayhfc= mohammadabis@mohammads-MacBook-Air.local"

}


