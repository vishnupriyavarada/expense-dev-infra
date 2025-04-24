data "aws_ssm_parameter" "mysql_sg_id" {
  name  = "/${var.projectname}/${var.environment}/mysql_sg_id"
}

# data "aws_ssm_parameter" "public_subnet_ids" {
#   name = "/${var.projectname}/${var.environment}/public_subnet_ids"
# }

