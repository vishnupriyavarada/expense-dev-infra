resource "aws_ssm_parameter" "web_alb_certificate_arn" {
  name  = "/${var.projectname}/${var.environment}/web_alb_certificate_arn"
  type  = "String"
  value = aws_acm_certificate.expense.arn
}
