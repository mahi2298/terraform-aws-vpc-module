locals {
    common_tags = {
        project = var.project
        environment = var.environment
    }
    availability_zone_names = slice(data.aws_availability_zones.available.names,0,2) # to get first 2 regions names we are filtering it split and here available.name->inside this only regions are there)
}