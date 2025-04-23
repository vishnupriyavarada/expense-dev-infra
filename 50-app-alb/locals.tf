locals {
  //AWS stores all subnets in a string in parameter store with coma separator. use split function to convert string to list(string)
  private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  app_alb_sg_id      = data.aws_ssm_parameter.app_alb_sg_id.value
} 