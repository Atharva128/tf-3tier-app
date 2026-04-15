resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc-cidr_block
  tags = {
    Name = "${var.environment}-my-vpc-3tier"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.my-vpc.id
  count = length(var.public_subnet.cidr_block)
  cidr_block = var.public_subnet.cidr_block[count.index]
  map_public_ip_on_launch = true
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.environment}-public_subnet-${count.index}"
  }
}

resource "aws_subnet" "frontend" {
  vpc_id = aws_vpc.my-vpc.id
  count = length(var.frontend.cidr_block)
  cidr_block = var.frontend.cidr_block[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.environment}-frontend-${count.index}"
  }
}

resource "aws_subnet" "backend" {
  vpc_id = aws_vpc.my-vpc.id
  count = length(var.backend.cidr_block)
  cidr_block = var.backend.cidr_block[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.environment}-backend-${count.index}"
  }
}

resource "aws_subnet" "database" {
  vpc_id = aws_vpc.my-vpc.id
  count = length(var.database.cidr_block)
  cidr_block = var.database.cidr_block[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.environment}-database-${count.index}"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "${var.environment}-ig"
  }
}

resource "aws_eip" "eip-nat" {
  count  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0
  domain = "vpc"

  tags = {
    Name = "${var.environment}-eip"
  }
  depends_on = [ aws_internet_gateway.ig ]
}

resource "aws_nat_gateway" "natgate" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0
  allocation_id = aws_eip.eip-nat[count.index].id
  subnet_id = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "${var.environment}-nat-gateway"
  }

  depends_on = [ aws_internet_gateway.ig ]
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    Name = "${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public-rta" {
  gateway_id = aws_internet_gateway.ig.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table" "frontend-rt" {
  count = var.enable_nat_gateway ? length(var.availability_zones) : 0
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "${var.environment}-frontend-rt"
  }
}

resource "aws_route" "frontend-route" {
  count                  = var.enable_nat_gateway ? length(var.availability_zones) : 0
  route_table_id         = aws_route_table.frontend-rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.single_nat_gateway ? aws_nat_gateway.natgate[0].id : aws_nat_gateway.natgate[count.index].id
}

resource "aws_route_table_association" "frontend-rta" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.frontend[count.index].id
  route_table_id = var.enable_nat_gateway ? aws_route_table.frontend-rt[count.index].id : null
}

resource "aws_route_table" "backend-rt" {
  count  = var.enable_nat_gateway ? length(var.availability_zones) : 0
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "${var.environment}-backend-rt"
  }
}

resource "aws_route" "backend_nat" {
  count                  = var.enable_nat_gateway ? length(var.availability_zones) : 0
  route_table_id         = aws_route_table.backend-rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.single_nat_gateway ? aws_nat_gateway.natgate[0].id : aws_nat_gateway.natgate[count.index].id
}

resource "aws_route_table_association" "backend-rta" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.backend[count.index].id
  route_table_id = var.enable_nat_gateway ? aws_route_table.backend-rt[count.index].id : null
}


resource "aws_route_table" "database-rt" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "${var.environment}-database-rt"
  }
}

resource "aws_route_table_association" "database-rta" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database-rt.id
}