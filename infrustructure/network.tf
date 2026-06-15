# 1. The Virtual Private Cloud (VPC) Boundary

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "threat-detection-vpc"
  }
}

# 2. Internet Gateway (The Edge Router for Public Traffic)

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "threat-detection-igw"
  }
}

# 3. Public Subnets (For External Load Balancers)

resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name                     = "threat-detection-public-1"
    "kubernetes.io/role/elb" = "1" # Crucial tag: Tells Kubernetes it can deploy public load balancers here
  }
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name                     = "threat-detection-public-2"
    "kubernetes.io/role/elb" = "1"
  }
}

# 4. Private Subnets (Isolated Vault for Kubernetes Worker Nodes)

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name                              = "threat-detection-private-1"
    "kubernetes.io/role/internal-elb" = "1" # Crucial tag: For internal microservice load balancers
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name                              = "threat-detection-private-2"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# 5. NAT Gateway (Allows isolated nodes outbound access to pull updates, without allowing inbound attacks)

resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "threat-detection-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id # Must sit in a public subnet to reach the IGW

  tags = {
    Name = "threat-detection-nat"
  }
}

# 6. Route Tables & Associations

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "threat-detection-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "threat-detection-private-rt"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}