output "vpn_ip" {
    value = aws_instance.openvpn.public_ip  
}