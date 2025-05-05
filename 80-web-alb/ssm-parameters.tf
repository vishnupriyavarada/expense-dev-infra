resource "aws_ssm_parameter" "web_alb_listener_arn" {
  name  = "/${var.projectname}/${var.environment}/web_alb_listener_arn"
  type  = "String"
  value = aws_lb_listener.https.arn
}
