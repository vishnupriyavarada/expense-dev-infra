//----- create a key pair to openvpn ec2 instance ----

resource "aws_key_pair" "openvpnas" {
  key_name   = "openvpnas"
  public_key =  file("c:\\devops\\daws-82s\\openvpnas.pub")
}

resource "aws_instance" "openvpn" {
  ami                    = local.ami-id
  key_name = aws_key_pair.openvpnas.key_name
  instance_type          = var.instance_type

  //VPN server is always configured in public subnet id. we need public subnet id from ssm parameter store
  //AWS stores all subnets in a string in parameter store with coma separator. use split function to convert string to list(string)
  subnet_id = local.vpn_public_subnet_id[0] // getting first subnet id from the list
  vpc_security_group_ids = [data.aws_ssm_parameter.vpn_sg_id.value]

  user_data = file("user-data.sh")
  tags = merge(
    var.common_tags,
    {
        Name = "${var.projectname}-${var.environment}-openvpn"
    }
  )
  
}