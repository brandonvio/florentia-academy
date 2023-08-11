provider "aws" {
  region = "us-west-2"
}

resource "aws_route53_zone" "florentia_zone" {
  name = "florentia.academy"
}

output "zone_id" {
  value       = aws_route53_zone.florentia_zone.zone_id
  description = "The ID of the hosted zone"
}

output "name_servers" {
  value       = aws_route53_zone.florentia_zone.name_servers
  description = "The name servers for the hosted zone"
}

