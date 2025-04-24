data "aws_ssm_parameter" "mysql_sg_id" {
  name  = "/${var.projectname}/${var.environment}/mysql_sg_id"
}

data "aws_ssm_parameter" "db_subnet_group_name" {
  name = "/${var.projectname}/${var.environment}/database_subnet_group_name"
}

