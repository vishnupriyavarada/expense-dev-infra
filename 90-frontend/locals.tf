locals {
  ami-id = data.aws_ami.mydevops.id
  //AWS stores all subnets in a string in parameter store with coma separator. use split function to convert string to list(string)
  public_subnet_ids = split(",", data.aws_ssm_parameter.public_subnet_ids.value) 

  resource_name= "${var.projectname}-${var.environment}-frontend"

  vpc_id = data.aws_ssm_parameter.vpc_id.value

  frontend_sg_id = data.aws_ssm_parameter.backend_sg_id.value
} 