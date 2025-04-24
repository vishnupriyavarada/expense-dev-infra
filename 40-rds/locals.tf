locals {
  resource_name = "${var.projectname}-${var.environment}"
  mysql_sg_id = data.aws_ssm_parameter.mysql_sg_id.value
} 