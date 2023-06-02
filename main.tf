provider "aws" {
  region = "us-west-2" // set the region
}

// create first VPC
resource "aws_vpc" "vpc1" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "VPC1"
  }
}

// create second VPC
resource "aws_vpc" "vpc2" {
  cidr_block       = "172.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "VPC2"
  }
}

// create internet gateway for VPC1
resource "aws_internet_gateway" "gw1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "vpc1-gw"
  }
}

// create internet gateway for VPC2
resource "aws_internet_gateway" "gw2" {
  vpc_id = aws_vpc.vpc2.id

  tags = {
    Name = "vpc2-gw"
  }
}

// create first private subnet for VPC1
resource "aws_subnet" "subnet1" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.vpc1.id

  tags = {
    Name = "subnet1"
  }
}

// create second private subnet for VPC2
resource "aws_subnet" "subnet2" {
  cidr_block = "172.0.1.0/24"
  vpc_id     = aws_vpc.vpc2.id

  tags = {
    Name = "subnet2"
  }
}

// create first security group for VPC1 instance
resource "aws_security_group" "sg1" {
  name_prefix = "sg1"
  vpc_id      = aws_vpc.vpc1.id

  // allow SSH access from any source
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg1"
  }
}

// create second security group for VPC2 instance
resource "aws_security_group" "sg2" {
  name_prefix = "sg2"
  vpc_id      = aws_vpc.vpc2.id

  // allow SSH access from any source
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg2"
  }
}

resource "aws_subnet" "publicsubnet1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.0.0/24"
  /* tags = {
    Name = publicsubnet-1
  } */
}

resource "aws_route_table" "PublicRT1" {
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw1.id
  }
  /* tags = {
    Name = publicRT1
  } */
}

resource "aws_route_table" "PrivateRT1" {
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATgw1.id
  }
  /* tags = {
    Name = privateroutetablename1
  } */
}

resource "aws_route_table_association" "PublicRTassociation1" {
  subnet_id      = aws_subnet.publicsubnet1.id
  route_table_id = aws_route_table.PublicRT1.id
}

resource "aws_route_table_association" "PrivateRTassociation1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.PrivateRT1.id
}
resource "aws_eip" "nateIP1" {
  vpc = true
  /* tags = {
    Name = eip1
  } */
}

resource "aws_nat_gateway" "NATgw1" {
  allocation_id = aws_eip.nateIP1.id
  subnet_id     = aws_subnet.publicsubnet1.id
  /* tags = {
    Name = natgatewayname1
  } */
}

resource "aws_subnet" "publicsubnet2" {
  vpc_id     = aws_vpc.vpc2.id
  cidr_block = "172.0.0.0/24"
  /* tags = {
    Name = publicsubnet2
  } */
}

resource "aws_route_table" "PublicRT2" {
  vpc_id = aws_vpc.vpc2.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw2.id
  }
  /* tags = {
    Name = publicRT2
  } */
}

resource "aws_route_table" "PrivateRT2" {
  vpc_id = aws_vpc.vpc2.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATgw2.id
  }
  /* tags = {
    Name = privateRT2
  } */
}

resource "aws_route_table_association" "PublicRTassociation2" {
  subnet_id      = aws_subnet.publicsubnet2.id
  route_table_id = aws_route_table.PublicRT2.id
}

resource "aws_route_table_association" "PrivateRTassociation2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.PrivateRT2.id
}
resource "aws_eip" "nateIP2" {
  vpc = true
  /* /* tags = {
    Name = eip2
  } */
}

resource "aws_nat_gateway" "NATgw2" {
  allocation_id = aws_eip.nateIP2.id
  subnet_id     = aws_subnet.publicsubnet2.id
  /* tags = {
    Name = natgatewayname2
  } */
}
resource "aws_rds_cluster" "postgresql" {
  cluster_identifier      = "aurora-cluster-demo"
  engine                  = "aurora-postgresql"
  availability_zones      = ["us-west-2a"]
  database_name           = "mydb1"
  master_username         = "mydb1234"
  master_password         = "mydb1234"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = false
  final_snapshot_identifier = "example-cluster-final-snapshot"
}
resource "aws_rds_cluster" "postgresql-new" {
  cluster_identifier      = "aurora-cluster-demo"
  engine                  = "aurora-postgresql"
  availability_zones      = ["us-west-2a"]
  database_name           = "mydb2"
  master_username         = "mydb1234"
  master_password         = "mydb1234"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = false
  final_snapshot_identifier = "example-cluster-final-snapshot1"
}
resource "aws_vpc_peering_connection" "peering" {
  vpc_id      = aws_vpc.vpc1.id
  peer_vpc_id = aws_vpc.vpc2.id
  auto_accept = true

  tags = {
    Name = "vpc1-to-vpc2"
  }
}
resource "aws_route_table" "peering_route_table" {
vpc_id = aws_vpc.vpc1.id

route {
cidr_block = aws_vpc.vpc2.cidr_block
vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

tags = {
Name = "vpc1-to-vpc2-route-table"
} 
 } 