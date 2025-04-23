//----------- common variables ---------------------------------------

# setting mandatory because this is my org standards
variable "projectname" {
  type = string
}

# setting mandatory because this is my org standards
variable "environment" {
  type = string
}

# usually for comman tags, we give project name, environment and Is from Terraform or not
variable "common_tags" {
  type = map(any)
}

//--------------- db variables --------
variable "sg_db_description" {
  type = string
}

variable "sg_db_name" {
  type = string
}

//--------------- backend variables --------
variable "sg_backend_description" {
  type = string
}

variable "sg_backend_name" {
  type = string
}

//--------------- frontend variables --------
variable "sg_frontend_description" {
  type = string
}

variable "sg_frontend_name" {
  type = string
}

//--------------- bastion variables --------
variable "sg_bastion_description" {
  type = string
}

variable "sg_bastion_name" {
  type = string
}
//--------------- app-alb variables --------
variable "sg_app_alb_description" {
  type = string
}

variable "sg_app_alb_name" {
  type = string
}

//--------------- vpn variables --------
variable "sg_vpn_description" {
  type = string
}

variable "sg_vpn_name" {
  type = string
}


