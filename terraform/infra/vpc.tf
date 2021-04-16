# AWS EKS deploys the Kubernetes control plane in to a VPC
# of your choosing. That VPC needs to have public and private subnets.
#
# The VPC being configured here has public and private subnets across
# two AZs


resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  # The VPC must DNS support and DNS hostnames enabled
  # https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = merge(var.tags, {
    Name = "${var.deploy_env}-eks-vpc"
  })
}

resource "aws_eip" "cluster_ip" {
  vpc = true
  tags = merge(var.tags, {
    Name = "${var.deploy_env}-eks-cluster-ip"
  })
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name = "${var.deploy_env}-internet-gateway"
  })
}

resource "aws_nat_gateway" "nat_gateway" {
  # NAT gateway must have a public IP for internet egress
  # https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
  allocation_id = aws_eip.cluster_ip.id
  depends_on = [aws_internet_gateway.internet_gateway, aws_subnet.subnets]

  # NAT gateway must reside in a public subnet so as
  # to have a route to the internet gateway
  subnet_id = local.public_subnets[0].id

  tags = merge(var.tags, {
    Name = "${var.deploy_env}-nat"
  })
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name = "${var.deploy_env}-public-route-table"
  })
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name = "${var.deploy_env}-private-route-table"
  })
}

# Subnets are divided in to 4 equal segments.
# The first two are for Z1, the second are for Z2.
# Within the pairs, the first is public and the second is private.
#
# | AZ | Type    | CIDR block    |
# |----|---------|---------------|
# | 1  | Public  | 10.0.0.0/18   |
# | 1  | Private | 10.0.64.0/18  |
# | 2  | Public  | 10.0.128.0/18 |
# | 2  | Private | 10.0.192.0/18 |
data "aws_availability_zones" "zones" {
  state = "available"
}

locals {
  # Subnets should have tags to aid EKS in placing load balancers
  # https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
  subnet_config = {
    "z1-public" = {
      cidr_block = "10.0.0.0/18",
      zone_index = 0,
      public = true,
      tags = {
        "kubernetes.io/cluster/${local.eks_cluster_name}" = "owned",
        "kubernetes.io/role/elb" = "1"
      }
    },
    "z1-private" = {
      cidr_block = "10.0.64.0/18",
      zone_index = 0,
      public = false,
      tags = {
        "kubernetes.io/cluster/${local.eks_cluster_name}" = "owned",
        "kubernetes.io/role/internal-elb" = "1"
      }
    },
    "z2-public" = {
      cidr_block = "10.0.128.0/18",
      zone_index = 1,
      public = true,
      tags = {
        "kubernetes.io/cluster/${local.eks_cluster_name}" = "owned",
        "kubernetes.io/role/elb" = "1"
      }
    },
    "z2-private" = {
      cidr_block = "10.0.192.0/18",
      zone_index = 1,
      public = false,
      tags = {
        "kubernetes.io/cluster/${local.eks_cluster_name}" = "owned",
        "kubernetes.io/role/internal-elb" = "1"
      }
    },
  }
}

resource "aws_subnet" "subnets" {
  for_each = local.subnet_config
  vpc_id = aws_vpc.vpc.id

  cidr_block = each.value.cidr_block
  availability_zone = data.aws_availability_zones.zones.names[each.value.zone_index]

  tags = merge(var.tags, each.value.tags, {
    Name = "${var.deploy_env}-${each.key}"
  })
}

locals {
  ## Local variables helping to find public and private subnets
  public_subnets = [for k, v in local.subnet_config: aws_subnet.subnets[k] if v.public == true]
  private_subnets = [for k, v in local.subnet_config: aws_subnet.subnets[k] if v.public == false]
}

resource "aws_route" "internet_egress_from_public" {
  route_table_id = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.internet_gateway.id
}

resource "aws_route" "internet_egress_from_private" {
  route_table_id = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gateway.id
}

resource "aws_route_table_association" "public_route_associations" {
  for_each = { for k, v in local.subnet_config: k => v if v.public == true }

  route_table_id = aws_route_table.public_route_table.id
  subnet_id = aws_subnet.subnets[each.key].id
}

resource "aws_route_table_association" "private_route_associations" {
  for_each = { for k, v in local.subnet_config: k => v if v.public == false }

  route_table_id = aws_route_table.private_route_table.id
  subnet_id = aws_subnet.subnets[each.key].id
}
