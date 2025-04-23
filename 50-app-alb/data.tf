data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.projectname}/${var.environment}/vpc_id" // Name of the parameter. for us the name is /expense/dev/vpc_id
}

data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/${var.projectname}/${var.environment}/private_subnet_ids"
}

data "aws_ssm_parameter" "app_alb_sg_id" {
  name = "/${var.projectname}/${var.environment}/app_alb_sg_id"
}