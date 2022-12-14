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
## locals                                            ##
#######################################################

locals {
  test_subnet_b = {
    Name = "test_subnet-b"
    Terraform = "true"
    availability_zone = "ap-northeast-2b"
  }

  test_subnet_c = {
    Name = "test_subnet-c"
    Terraform = "true"
    availability_zone = "ap-northeast-2c"
  }

  test_subnet_d = {
  Name = "test_subnet-d"
  Terraform = "true"
  availability_zone = "ap-northeast-2d"
  }

  test_ec2_cont = {
    Name = "k8s_ec2_cont"
    role = "cont_server"
    Terraform = "true"
    availability_zone = "ap-northeast-2a"
  }

  test_ec2_node = {
    Name = "k8s_ec2_node"
    role = "node_server"
    Terraform = "true"
    availability_zone = "ap-northeast-2a"
  }
  
  test_import_ec2 = {
    Name = "import_test_ec2"
    role = "test_server"
    Terraform = "true"
    availability_zone = "ap-northeast-2b"
  }

  test_ebs = {
    Name = "enc_test_ebs"
    role = "test_ebs"
    Terraform = "true"
    availability_zone = "ap-northeast-2a"
  }
}


#######################################################
## vpc                                               ##
#######################################################

data "aws_vpc" "vpc-test" {
  id = "vpc-00bb4e7b1764e3235"
}

data "aws_subnet" "sub-test1" {
  filter {
    name = "tag:Name"
    values = ["test-sub-a"]
  }
}

resource "aws_subnet" "sub-test2" {
  vpc_id = data.aws_vpc.vpc-test.id
  availability_zone = "ap-northeast-2b"
  cidr_block = "10.0.2.0/24"

  tags = local.test_subnet_b
}

resource "aws_subnet" "sub-test3" {
  vpc_id = data.aws_vpc.vpc-test.id
  availability_zone = "ap-northeast-2c"
  cidr_block = "10.0.3.0/24"

  tags = local.test_subnet_c
}

resource "aws_subnet" "sub-test4" {
  vpc_id = data.aws_vpc.vpc-test.id
  availability_zone = "ap-northeast-2b"
  cidr_block = "10.0.4.0/24"

  tags = local.test_subnet_d
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
  from_port = 0
  to_port = 0
  protocol = "-1"
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
  from_port = 30000
  to_port = 32494
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
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.k8s-sg.id
}

# resource "aws_instance" "k8s-cont" {
#   ami = "ami-0ea5eb4b05645aa8a"
#   instance_type = "t3.small"
#   key_name = data.aws_key_pair.key.key_name
#   monitoring = true
#   availability_zone = "ap-northeast-2a"
#   subnet_id = data.aws_subnet.sub-test1.id
#   security_groups = [data.aws_security_group.k8s-sg.id]
#   associate_public_ip_address = true

#   tags = local.test_ec2_cont
# }

# resource "aws_instance" "k8s-node1" {
#   ami = "ami-0ea5eb4b05645aa8a"
#   instance_type = "t3.small"
#   key_name = data.aws_key_pair.key.key_name
#   monitoring = true
#   availability_zone = "ap-northeast-2a"
#   subnet_id = data.aws_subnet.sub-test1.id
#   security_groups = [data.aws_security_group.k8s-sg.id]
#   associate_public_ip_address = true

#   tags = local.test_ec2_node
# }

# resource "aws_instance" "k8s-node2" {
#   ami = "ami-0ea5eb4b05645aa8a"
#   instance_type = "t3.small"
#   key_name = data.aws_key_pair.key.key_name
#   monitoring = true
#   availability_zone = "ap-northeast-2a"
#   subnet_id = data.aws_subnet.sub-test1.id
#   security_groups = [data.aws_security_group.k8s-sg.id]
#   associate_public_ip_address = true
  
#   tags = local.test_ec2_node
# }

#######################################################
## remote shell script                               ##
#######################################################


## control plane 
# resource "null_resource" "control_install" {

#   connection {
#     user = "ubuntu"
#     type = "ssh"
#     host = aws_instance.k8s-cont.public_ip
#     private_key = file("./aws_k8s_test.pem")
#     timeout = "5m"
#   }

#   provisioner "remote-exec" {
#     script = "./controlplane.sh"
#   }
# }

## worker node1
# resource "null_resource" "node1_install" {

#   connection {
#     user = "ubuntu"
#     type = "ssh"
#     host = aws_instance.k8s-node1.public_ip
#     private_key = file("./aws_k8s_test.pem")
#     timeout = "5m"
#   }

#   provisioner "remote-exec" {
#     script = "./workernode1.sh"
#   }
# }

## worker node2
# resource "null_resource" "node2_install" {
#   connection {
#     user = "ubuntu"
#     type = "ssh"
#     host = aws_instance.k8s-node2.public_ip
#     private_key = file("./aws_k8s_test.pem")
#     timeout = "5m"
#   }

#   provisioner "remote-exec" {
#     script = "./workernode2.sh"
#   }
# }

#######################################################
## ebs volume enc test                               ##
#######################################################

# resource "aws_ebs_volume" "enc_test_ebs1" {
#   availability_zone = "ap-northeast-2a"
#   size = 1

#   tags = local.test_ebs
# }

# resource "aws_ebs_volume" "enc_test_ebs2" {
#   availability_zone = "ap-northeast-2a"
#   size = 1

#   tags = local.test_ebs
# }

#######################################################
## terraform import test                             ##
#######################################################

# resource "aws_elasticache_replication_group" "redis_import3" {
#   replication_group_id = "import-test-3"
#   replication_group_description = "import-test"
#   node_type = "cache.t2.micro"
#   port = 6379
#   parameter_group_name = "default.redis5.0"
#   automatic_failover_enabled = true
#   security_group_ids = ["sg-09788cd4f94065f43"]
#   subnet_group_name = "import-test-redis-sub"
#   number_cache_clusters = 2 # ??? node ????????????
#   engine_version = "5.0.6"
#   snapshot_retention_limit = 1
#   tags = {
#     Name = "import1"
#   }
# }

#######################################################
## terraform backend test                           ##
#######################################################

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "sangun-company-preprod"
    
    workspaces {
      name = "tfcloud-test_firsttest"
    }
  }
}