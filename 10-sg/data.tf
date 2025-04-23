data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.projectname}/${var.environment}/vpc_id" // Name of the parameter. for us the name is /expense/dev/vpc_id
}

