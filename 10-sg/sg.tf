module "mysql_sg" {
  #source = "../terraform-aws-securitygroup" // this method is used when your code is in local
  source = "git::https://github.com/vishnupriyavarada/terraform-aws-securitygroup.git?ref=main" 
  environment    = var.environment
  sg_description = var.sg_db_description
  sg_name        = var.sg_db_name
  project_name   = var.projectname
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  common_tags    = var.common_tags
}

module "backend_sg" {
  #source = "../terraform-aws-securitygroup" // this method is used when your code is in local
  source = "git::https://github.com/vishnupriyavarada/terraform-aws-securitygroup.git?ref=main" 
  environment    = var.environment
  sg_description = var.sg_backend_description
  sg_name        = var.sg_backend_name
  project_name   = var.projectname
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  common_tags    = var.common_tags
}

module "frontend_sg" {
  #source = "../terraform-aws-securitygroup" // this method is used when your code is in local
  source = "git::https://github.com/vishnupriyavarada/terraform-aws-securitygroup.git?ref=main" 
  environment    = var.environment
  sg_description = var.sg_frontend_description
  sg_name        = var.sg_frontend_name
  project_name   = var.projectname
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  common_tags    = var.common_tags
}

//-------------- Bastion SG ------------------

module "bastion_sg" {
  #source = "../terraform-aws-securitygroup" // this method is used when your code is in local
  source = "git::https://github.com/vishnupriyavarada/terraform-aws-securitygroup.git?ref=main" 
  environment    = var.environment
  sg_description = var.sg_bastion_description
  sg_name        = var.sg_bastion_name
  project_name   = var.projectname
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  common_tags    = var.common_tags
}

//-------------- VPN SG ------------------
#ports 22, 443, 1194, 943 --> VPN Ports
module "vpn_sg" {
  source = "git::https://github.com/vishnupriyavarada/terraform-aws-securitygroup.git?ref=main" 
  environment    = var.environment
  sg_description = var.sg_vpn_description
  sg_name        = var.sg_vpn_name
  project_name   = var.projectname
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  common_tags    = var.common_tags
}

//-------------- Backend ALB SG ------------------

module "app_alb_sg" {
  #source = "../terraform-aws-securitygroup" // this method is used when your code is in local
  source = "git::https://github.com/vishnupriyavarada/terraform-aws-securitygroup.git?ref=main" 
  environment    = var.environment
  sg_description = var.sg_app_alb_description
  sg_name        = var.sg_app_alb_name
  project_name   = var.projectname
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  common_tags    = var.common_tags
}

//-------------- Frontend ALB SG ------------------

module "web_alb_sg" {
  #source = "../terraform-aws-securitygroup" // this method is used when your code is in local
  source = "git::https://github.com/vishnupriyavarada/terraform-aws-securitygroup.git?ref=main" 
  environment    = var.environment
  sg_description = var.sg_web_alb_description
  sg_name        = var.sg_app_alb_name
  project_name   = var.projectname
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  common_tags    = var.common_tags
}

// -------------- Security group Rules for App ALB ----------------------

# APP ALB accepting the traffic from bastion
resource "aws_security_group_rule" "alb_bastion" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  #cidr_blocks       = [aws_vpc.example.cidr_block] - CIDR is not required here as we are not giving any IP address
  source_security_group_id =  [module.bastion_sg.sg_id ] # accept the traffic from bastion host which is coming on port 80
  security_group_id = module.app_alb_sg.sg_id # To which sg we are setting this rule? Its for app_alb
}

# APP ALB accepting the traffic from frontend
resource "aws_security_group_rule" "app_alb_frontend" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id =  module.frontend_sg.sg_id # accept the traffic from frontend on port 80
  security_group_id = module.app_alb_sg.sg_id # To which sg we are setting this rule? Its for app_alb
}


// -------------- Security group Rules for Web ALB / Frontend ALB ----------------------

# Web ALB accepting https traffic from internet
resource "aws_security_group_rule" "web_alb_https" {
  type              = "ingress"
  from_port         = 443 # Traffic from internet. HTTPS
  to_port           = 443
  protocol          = "tcp"  
  source_security_group_id =  [ "0.0.0.0/0" ] # from internet
  security_group_id = module.web_alb_sg.sg_id # To which sg we are setting this rule? Its for web_alb
}

# frontend accepting traffic from web_alb
resource "aws_security_group_rule" "frontend_web_alb" {
  type              = "ingress"
  from_port         = 80 # Traffic is from Web_alb to frontend hence port is 80
  to_port           = 80
  protocol          = "tcp"  
  source_security_group_id =  module.web_alb_sg.sg_id # from web_alb
  security_group_id = module.frontend_sg.sg_id # To which sg we are setting this rule? Its for frontend servers
}

//--------------- security group rule for bastion host -----------------
resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # In org, we will have restricted IP address range and we give that here
                                    # now we don't have that so we give home Ip address range or allowing internet
  security_group_id = module.app_alb_sg.sg_id # To which sg we are setting this rule? Its for app_alb
}

//--------------- security group rule for VPN -----------------
resource "aws_security_group_rule" "vpn_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  # usually it should be a static IP
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.sg_id # To which sg we are setting this rule? Its for vpn
}
resource "aws_security_group_rule" "vpn_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  # usually it should be a static IP
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.sg_id # To which sg we are setting this rule? Its for vpn
}
resource "aws_security_group_rule" "vpn_1194" {
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  # usually it should be a static IP
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.sg_id # To which sg we are setting this rule? Its for vpn
}
resource "aws_security_group_rule" "943" {
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  # usually it should be a static IP
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.sg_id # To which sg we are setting this rule? Its for vpn
}


// --- Add VPN security group rule to private ALB -----
resource "aws_security_group_rule" "app_alb_vpn" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id =  module.vpn_sg.sg_id
  security_group_id = module.app_alb_sg.sg_id # To which sg we are setting this rule? Its for app_alb
}

//--------------- mysql ----------------------------

// --- security group rule for mysql accepting connections from bastion host -----
resource "aws_security_group_rule" "mysql_bastion" {
  type              = "ingress"
  from_port         = 3306 # AWS will not give the port 22 (ssh) for us as they handle the RDS
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id =  module.bastion_sg.sg_id
  security_group_id = module.mysql_sg.sg_id # To which sg we are setting this rule? Its for app_alb
}

# mysql accepting traffic from backend on port number 3306
resource "aws_security_group_rule" "mysql_backend" {
  type              = "ingress"
  from_port         = 3306 
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id =  module.backend_sg.sg_id
  security_group_id = module.mysql_sg.sg_id # To which sg we are setting this rule? Its for app_alb
}

// --- security group rule for mysql accepting connections from vpn -----
resource "aws_security_group_rule" "mysql_vpn" {
  type              = "ingress"
  from_port         = 3306 # AWS will not give the port 22 (ssh) for us as they handle the RDS
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id =  module.vpn_sg.sg_id
  security_group_id = module.mysql_sg.sg_id # To which sg we are setting this rule? Its for app_alb
}

//------------------ backend --------------------------------------------
// --- security group rule for backend accepting connections from vpn -----
resource "aws_security_group_rule" "backend_vpn" {
  type              = "ingress"
  from_port         = 22 # SSH port
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id =  module.vpn_sg.sg_id
  security_group_id = module.backend_sg.sg_id # To which sg we are setting this rule? Its for app_alb
}

resource "aws_security_group_rule" "backend_vpn_http" {
  type              = "ingress"
  from_port         = 8080 # Developers to access through API
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id =  module.vpn_sg.sg_id
  security_group_id = module.backend_sg.sg_id # To which sg we are setting this rule? Its for app_alb
}
# --- backend should allow connection from app_alb on port 8080 -----------
resource "aws_security_group_rule" "backend_app_alb" {
  type              = "ingress"
  from_port         = 8080 # Developers to access through API
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id =  module.app_alb_sg.sg_id
  security_group_id = module.backend_sg.sg_id # To which sg we are setting this rule? Its for app_alb
}