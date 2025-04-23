locals {
  ami-id = data.aws_ami.mydevops.id
  //Bastion server is always configured in public subnet id. we need public subnet id from ssm parameter store
  //AWS stores all subnets in a string in parameter store with coma separator. use split function to convert string to list(string)
  bastion_public_subnetid = split("," , data.aws_ssm_parameter.public_subnet_ids.value)
} 