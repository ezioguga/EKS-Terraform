resource "aws_vpc" "my-vpc-us-east-1" {
  cidr_block = "10.0.0.0/16"

  tags = tomap({
    "Name"                                      = "terraform-eks-node",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}

resource "aws_subnet" "my-subnet-us-east-1" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.my-vpc-us-east-1.id

  tags = tomap({
    "Name"                                      = "terraform-eks-node",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}

resource "aws_internet_gateway" "my_IGW" {
  vpc_id = aws_vpc.my-vpc-us-east-1.id

  tags = {
    Name = "terraform-eks-IGW"
  }
}

resource "aws_route_table" "my_RT" {
  vpc_id = aws_vpc.my-vpc-us-east-1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_IGW.id
  }
}

resource "aws_route_table_association" "RTA" {
  count = 2

  subnet_id      = aws_subnet.my-subnet-us-east-1[count.index].id
  route_table_id = aws_route_table.my_RT.id
}
