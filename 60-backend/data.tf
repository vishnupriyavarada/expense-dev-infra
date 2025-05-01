data "aws_ami" "mydevops"{
    most_recent = true
    owners = ["973714476881"] //owner of the ami. don't change this

   filter {
    name   = "name"
    values = ["RHEL-9-DevOps-Practice"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ssm_parameter" "backend_sg_id" {
  name = "/${var.projectname}/${var.environment}/vpc_id"
}

data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/${var.projectname}/${var.environment}/private_subnet_ids"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.projectname}/${var.environment}/vpc_id"
}

data "aws_ssm_parameter" "app_alb_listener_arn"{
  name = "/${var.projectname}/${var.environment}/app_alb_listener_arn"
}