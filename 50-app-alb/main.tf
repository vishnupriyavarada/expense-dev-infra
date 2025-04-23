#This code is from open source module
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  # expense-dev-app-alb
  name     = "${var.projectname}-${var.environment}-app-alb"
  internal = true #define the alb is internal or private or backend
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
  # private subnets. creating backend ALB 
  subnets = local.private_subnet_ids
  # create your own security group hence it's false
  create_security_group      = false
  security_groups            = [local.app_alb_sg_id]
  enable_deletion_protection = true # If set true, deletion of ALB will be disabled via the AWS API. This prevents TF from deleting ALB
  tags = merge(
    var.common_tags,
    {
      Name = "${var.projectname}-${var.environment}-app-alb"
    }
  )
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = module.alb.arn
  port              = "80"
  protocol          = "HTTP"
    #backend is not yet created hence giving fixed_responser for testing alb listener
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "<h1> Hello, I am from backend app ALB </h1>"
      status_code  = "200"
    }
  }
  
}


//--------------- Route 53 record ------------------------

resource "aws_route53_record" "www" {
  zone_id = var.zone_id
  name    = "*.app-dev.${var.domain_name}" 
  type    = "A"
  # These are ALB DNS name and zone information
  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = false
  }
}