data "aws_availability_zones" "available" {
  state = "available"
}

# output "azs_info" {
#     value = data.aws_availability_zones.available
# }

#fetching default vpc id
data "aws_vpc" "default" {
  default = true
}

#default vpc route table
data "aws_route_table" "main" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name = "association.main"
    values = ["true"]
  }
}