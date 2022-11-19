resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = var.validation_method

  tags = {
    Environment = var.tag_environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "this_zone" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "this_route53_record" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.this_zone.zone_id
}
