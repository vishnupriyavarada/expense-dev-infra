#This code is from open source module
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  # expense-dev-web-alb
  name     = "${var.projectname}-${var.environment}-web-alb"
  internal = false
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
  # private subnets. creating backend ALB 
  subnets = local.public_subnet_ids
  # create your own security group hence it's false
  create_security_group      = false
  security_groups            = [local.web_alb_sg_id]
  enable_deletion_protection = false # If set true, deletion of ALB will be disabled via the AWS API. This prevents TF from deleting ALB
  tags = merge(
    var.common_tags,
    {
      Name = "${var.projectname}-${var.environment}-web-alb"
    }
  )
}


resource "aws_lb_listener" "https" {
  load_balancer_arn =  module.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.web_alb_certificate_arn

  # frontend is not yet created hence giving fixed_responser for testing alb listener
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "<h1> Hello, I am from frontend web ALB with Https </h1>"
      status_code  = "200"
    }
  }
}


//--------------- Route 53 record ------------------------

resource "aws_route53_record" "web_alb" {
  zone_id = var.zone_id
  name    = "*.${var.domain_name}" 
  type    = "A"
  # These are ALB DNS name and zone information
  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = false
  }
}