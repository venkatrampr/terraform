resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr
    tags = {
    Name= "vpc"
  }
}

resource "aws_subnet" "pub_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.pub_subnet_cidrs[count.index]
  count = 2
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "pub_subnet${count.index}"
  }
}

resource "aws_subnet" "pri_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.pri_subnet_cidrs[count.index]
  count = 2
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "pri_subnet${count.index}"
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "gw"
  }
}

resource "aws_nat_gateway" "nat" {
  count = 2
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.pub_subnet[count.index].id

  tags = {
    Name = "NAT${count.index}"
  }
}

resource "aws_eip" "eip" {
    count = 2
}

resource "aws_route_table" "pub_route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table_association" "pub_route_table_association" {
  count = 2
  subnet_id      = aws_subnet.pub_subnet[count.index].id
  route_table_id = aws_route_table.pub_route.id
}

resource "aws_route_table" "pri_route" {
  vpc_id = aws_vpc.vpc.id
  count = 2
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "private_route_table${count.index}"
  }
}

resource "aws_route_table_association" "pri_route_table_association" {
  count = 2
  subnet_id      = aws_subnet.pri_subnet[count.index].id
  route_table_id = aws_route_table.pri_route[count.index].id
}
