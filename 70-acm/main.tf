resource "aws_acm_certificate" "expense" {
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"

  tags = merge(
    var.common_tags,
    {
        Name = "${var.projectname}-${var.environment}"
    }
  )
}

# ---------- creating DNS record ----------------
resource "aws_route53_record" "expense" {
  for_each = {
    for dvo in aws_acm_certificate.expense.domain_validation_options : dvo.domain_name => {
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
  zone_id         = aws_route53_zone.expense.zone_id
}

# ----------- Validating domain (DNS) 