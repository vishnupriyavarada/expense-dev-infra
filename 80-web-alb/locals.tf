locals {
  //AWS stores all subnets in a string in parameter store with coma separator. use split function to convert string to list(string)
  public_subnet_ids = split(",", data.aws_ssm_parameter.public_subnet_ids.value)
  web_alb_sg_id      = data.aws_ssm_parameter.web_alb_sg_id.value
} 