locals {
  ami-id = data.aws_ami.openvpn.id // this ami is openvpn ami created openvpn team which as automatically opnvpn is installed

  //vpn server is always configured in public subnet id. we need public subnet id from ssm parameter store
  //AWS stores all subnets in a string in parameter store with coma separator. use split function to convert string to list(string)
  vpn_public_subnet_id = split("," , data.aws_ssm_parameter.public_subnet_ids.value)
} 