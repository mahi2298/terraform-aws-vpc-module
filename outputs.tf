output "vpc_id" {
    value = aws_vpc.main.id # getting the vpcid from vpc.tf
}

output "public_subnet_id" {
    value = aws_subnet.public[*].id # getting the vpcid from vpc.tf
}

output "private_subnet_id" {
    value = aws_subnet.private[*].id # getting the vpcid from vpc.tf
}