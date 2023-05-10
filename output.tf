output "server_public_ip_1" {
  value = aws_eip.one.public_ip
}

output "public_subnets-1" {
  value = [aws_subnet.public_subnet-1.id]
}

output "server_public_ip_2" {
  value = aws_eip.two.public_ip
}

output "public_subnets-2" {
  value = [aws_subnet.public_subnet-2.id]
}