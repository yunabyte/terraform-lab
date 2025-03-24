output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "public_subnets" {
  value = [aws_subnet.pub_sub_1.id, aws_subnet.pub_sub_2.id]
}

output "private_subnets" {
  value = [aws_subnet.prv_sub_1.id, aws_subnet.prv_sub_2.id]
}