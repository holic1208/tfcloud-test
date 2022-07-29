provider "aws" {
  region = "ap-northeast-2"  
}


#######################################################
## Keypair                                           ##
#######################################################

data "aws_key_pair" "key" { 
  key_name = "aws_k8s_test"
  include_public_key = true
}


#######################################################
## vpc                                               ##
#######################################################

data "aws_vpc" "vpc-test" {
  id = "vpc-00bb4e7b1764e3235"
}

resource "aws_subnet" "sub-test2" {
  vpc_id = data.aws_vpc.vpc-test.id
  availability_zone = "ap-northeast-2b"
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "test-sub-b"
  }
}

resource "aws_subnet" "sub-test3" {
  vpc_id = data.aws_vpc.vpc-test.id
  availability_zone = "ap-northeast-2c"
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "test-sub-c"
  }
}

resource "aws_subnet" "sub-test4" {
  vpc_id = data.aws_vpc.vpc-test.id
  availability_zone = "ap-northeast-2b"
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "test-sub-d"
  }
}


#######################################################
## Security group & EC2                              ##
#######################################################

data "aws_security_group" "k8s-sg" {
  id = "sg-0957b2f892bab58ad"
}

resource "aws_security_group_rule" "k8s-sg-Bastion1" {
  description = "first connection"
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "TCP"
  cidr_blocks = ["58.151.93.20/32"]
  security_group_id = data.aws_security_group.k8s-sg.id
}

resource "aws_security_group_rule" "k8s-sg-Bastion2" {
  description = "connection port"
  type = "ingress"
  from_port = 2022
  to_port = 2022
  protocol = "TCP"
  cidr_blocks = ["58.151.93.20/32"]
  security_group_id = data.aws_security_group.k8s-sg.id
}

resource "aws_security_group_rule" "k8s-sg-echo" {
  description = "ICMP"
  type = "ingress"
  from_port = -1
  to_port = -1
  protocol = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.k8s-sg.id
}

resource "aws_security_group_rule" "k8s-sg-web" {
  description = "web port"
  type = "ingress"
  from_port = 8080
  to_port = 8080
  protocol = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.k8s-sg.id
}

resource "aws_security_group_rule" "k8s-sg-k8s_Cni" {
  description = "CNI-Weave API"
  type = "ingress"
  from_port = 6783
  to_port = 6783
  protocol = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.k8s-sg.id
}

resource "aws_security_group_rule" "k8s-sg-k8s_Api1" {
  description = "k8s API"
  type = "ingress"
  from_port = 6443
  to_port = 6443
  protocol = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.k8s-sg.id
}

resource "aws_security_group_rule" "k8s-sg-k8s_Api2" {
  description = "kubelet"
  type = "ingress"
  from_port = 10250
  to_port = 10250
  protocol = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.k8s-sg.id
}

resource "aws_security_group_rule" "k8s-sg-Api4" {
  description = "controller manager"
  type = "ingress"
  from_port = 10257
  to_port = 10257
  protocol = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.k8s-sg.id
}

resource "aws_security_group_rule" "k8s-sg-Api3" {
  description = "kube-schedular"
  type = "ingress"
  from_port = 10259
  to_port = 10259
  protocol = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.k8s-sg.id
}

resource "aws_security_group_rule" "k8s-sg-Nodeport" {
  description = "NodePort Port"
  type = "ingress"
  from_port = 30000-32494
  to_port = 30000-32494
  protocol = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.k8s-sg.id
}

resource "aws_security_group_rule" "k8s-sg-outbound" {
  description = "outbound rule"
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = -1
  security_group_id = data.aws_security_group.k8s-sg.id
}