provider "aws" {
  region = "ap-northeast-2"  
}

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