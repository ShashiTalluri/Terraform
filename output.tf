output "vpc" {
    value = aws_vpc.name.id
}
output "vpc_cidr" {
    value = aws_vpc.name.cidr_block
}

output "natgw_eip" {
    value = aws_eip.natgw.public_ip
}