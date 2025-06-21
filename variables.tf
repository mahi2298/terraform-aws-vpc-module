variable "project" {
    type = string
}

variable "environment" {
    type = string
}

variable "cidr_block" {
    type = string
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    type = list(string)
}

variable "private_subnet_cidr" {
    type = list(string)
}

variable "vpc_tags" {
    type = map(string)
    default = {}
}


variable "igw_tags" {
    type = map(string)
    default = {}
}


variable "public_subnet_tags" {
    type = map(string)
    default = {}
}

variable "private_subnet_tags" {
    type = map(string)
    default = {}
}

variable "eip_tags" {
    type = map(string)
    default = {}
}

variable "nat_gateway_tags" {
    type = map(string)
    default = {}
}

variable "public_route_table_tags" {
    type = map(string)
    default = {}
}

variable "private_route_table_tags" {
    type = map(string)
    default = {}
}


variable "is_vpc_peering" {
    default = false
}


variable "vpc_peering_tags" {
    type = map(string)
    default = {}
}
