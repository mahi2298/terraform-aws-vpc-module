# create vpc
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"

  tags = merge(
    var.vpc_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    }
  )
}

# create internet gateway and attach it to vpc

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id # associating the vpc
    tags = merge(
      var.igw_tags,
      local.common_tags,
      {
          Name = "${var.project}-${var.environment}"
      }
    )
}

#creating public subnets in 2 availability zone

resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidr)
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr[count.index]
    availability_zone = local.availability_zone_names[count.index] # it will list availability zones
    map_public_ip_on_launch = true
    tags = merge(
      var.public_subnet_tags,
      local.common_tags,
      {
          Name = "${var.project}-${var.environment}-public-${local.availability_zone_names[count.index]}"
      }
  )
}

#creating private subnets in 2 availability zone
resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidr)
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidr[count.index]
    availability_zone = local.availability_zone_names[count.index]
    tags = merge(
      var.private_subnet_tags,
      local.common_tags,
      {
          Name = "${var.project}-${var.environment}-private-${local.availability_zone_names[count.index]}"
      }
    )
}

#creating Database private subnets in 2 availability zone
resource "aws_subnet" "Database" {
    count = length(var.database_private_subnet_cidr)
    vpc_id = aws_vpc.main.id
    cidr_block = var.database_private_subnet_cidr[count.index]
    availability_zone = local.availability_zone_names[count.index]
    tags = merge(
      var.database_subnet_tags,
      local.common_tags,
      {
          Name = "${var.project}-${var.environment}-Database-${local.availability_zone_names[count.index]}"
      }
    )
}

# creating Elastic ip for nat gateway
resource "aws_eip" "main" {
  domain = "vpc"
  tags = merge(
      var.eip_tags,
      local.common_tags,
      {
          Name = "${var.project}-${var.environment}"
      }
    )
}

# creating the NAT gateway
resource "aws_nat_gateway" "main" {
    allocation_id = aws_eip.main.id # getting the elastic ip and assinging to NAT Gateway
    subnet_id = aws_subnet.public[0].id # getting the public subnet id bcoz nat gateway will be created in public subnet
    tags = merge(
        var.nat_gateway_tags,
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}"
        }
      )
    depends_on = [aws_internet_gateway.main] # to expose to internet internet gateway is used
}

# creating the public route table
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    tags = merge(
        var.public_route_table_tags,
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-public"
        }
      )
}

# creating the private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = merge(
      var.private_route_table_tags,
      local.common_tags,
        {
            Name = "${var.project}-${var.environment}-private"
        }
    )
}

# creating the database route table
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id
  tags = merge(
      var.database_route_table_tags,
      local.common_tags,
        {
            Name = "${var.project}-${var.environment}-database"
        }
    )
}

#assign Internet gateway to public route table bcoz it is exposed to internet

resource "aws_route" "public" {
    route_table_id = aws_route_table.public.id  # getting the public route table id
    destination_cidr_block = "0.0.0.0/0" # internet gateway id
    gateway_id = aws_internet_gateway.main.id # internet gateway name
}

#assign Nat gateway to private route bcoz it is not exposed to internet and to install 
#some dependencies in private subnet we should use nat gateway and private subnet will allow
#only outgoing traffic
resource "aws_route" "private" {
    route_table_id = aws_route_table.private.id # getting the private route table id
    destination_cidr_block = "0.0.0.0/0" # NAT gateway id
    nat_gateway_id = aws_nat_gateway.main.id # NAT gateway name
}

resource "aws_route" "database" {
    route_table_id = aws_route_table.database.id # getting the private route table id
    destination_cidr_block = "0.0.0.0/0" # NAT gateway id
    nat_gateway_id = aws_nat_gateway.main.id # NAT gateway name
}

# Assigning public subnet to public route table
resource "aws_route_table_association" "public" {
    count = length(var.public_subnet_cidr)
    subnet_id = aws_subnet.public[count.index].id # assigning public subnet to public route table
    route_table_id = aws_route_table.public.id # getting the public route table id
}

#assigning private subnet to private route table
resource "aws_route_table_association" "private" { 
    count = length(var.private_subnet_cidr)
    subnet_id = aws_subnet.private[count.index].id # assigning private subnet to private route table
    route_table_id = aws_route_table.private.id  # getting the private route table id
}


resource "aws_route_table_association" "database" { 
    count = length(var.database_private_subnet_cidr)
    subnet_id = aws_subnet.database[count.index].id # assigning private subnet to private route table
    route_table_id = aws_route_table.database.id  # getting the private route table id
}
