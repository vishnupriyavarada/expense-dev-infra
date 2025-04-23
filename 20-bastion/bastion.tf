resource "aws_instance" "bastion" {
  ami                    = local.ami-id
  instance_type          = var.instance_type
  //Bastion server is always configured in public subnet id. we need public subnet id from ssm parameter store
  //AWS stores all subnets in a string in parameter store with coma separator. use split function to convert string to list(string)
  subnet_id = local.bastion_public_subnetid[0] // getting first subnet id from the list
  vpc_security_group_ids = [data.aws_ssm_parameter.bastion_sg_id.value]
  tags = merge(
    var.common_tags,
    {
        Name = "${var.projectname}-${var.environment}-bastion"
    }
  )
  
}