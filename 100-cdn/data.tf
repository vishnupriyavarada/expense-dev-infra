data "aws_cloudfront_cache_policy" "noCache" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_cache_policy" "cacheEnabled" {
  name = "Managed-CachingOptimized"
}

data "aws_ssm_parameter" "web_alb_certificate_arn" {
  name = "/${var.projectname}/${var.environment}/web_alb_certificate_arn"
}
