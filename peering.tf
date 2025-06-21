# creating 1st vpc to 2nd vpc making vpc peering
resource "aws_vpc_peering_connection" "default" {
    count = var.is_vpc_peering ? 1 : 0 # checking the condition
    peer_vpc_id   = data.aws_vpc.default.id # another vpc id (2nd one)
    vpc_id        = aws_vpc.main.id # first vpc id (1st one)
    accepter {
        allow_remote_vpc_dns_resolution = true
    }

    requester {
        allow_remote_vpc_dns_resolution = true
    }

    auto_accept = true
    tags = merge(
        var.vpc_peering_tags,
        local.common_tags,
        {
            Name = "${var.project}.${var.environment}-default"
        }
    )
 }

# adding 2nd vpc id in 1st vpc public route table
 resource "aws_route" "public_peering" {
    count = var.is_vpc_peering ? 1 : 0 # checking the condition
    route_table_id = aws_route_table.public.id  # taking public route table id
    destination_cidr_block = data.aws_vpc.default.cidr_block # taking default vpc cidr range
    vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id #vpc peering connection id
 }

# adding 2nd vpc id in 1st vpc private route table
 resource "aws_route" "private_peering" {
    count = var.is_vpc_peering ? 1 : 0 # checking the condition
    route_table_id = aws_route_table.private.id # taking private route table id
    destination_cidr_block = data.aws_vpc.default.cidr_block # taking default vpc cidr range
    vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id #vpc peering connection id
 }

# adding 1st vpc id in 2nd vpc default route table
 resource "aws_route" "default_peering" {
    count = var.is_vpc_peering ? 1 : 0 # checking the condition
    route_table_id = data.aws_route_table.main.id # taking default vpc route table id
    destination_cidr_block = var.cidr_block # taking roboshop vpc cidr range
    vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id # vpc peering connection id
 }