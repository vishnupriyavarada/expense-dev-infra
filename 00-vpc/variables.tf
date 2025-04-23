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
//------------ vpc variables --------------------------------------------
# when variable left empty it's mandatory
variable "vpc_cidr" {
  type = string
}
variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

//------------ public subnet variables -----------------------------------------
variable "public_subnet_cidr" {
  type = list(string)
}

variable "public_subnet_tags" {
  type    = map(any)
  default = {}
}
//------------ private subnet variables -----------------------------------------
variable "private_subnet_cidr" {
  type = list(string)
}

variable "private_subnet_tags" {
  type    = map(any)
  default = {}
}

//------------ database subnet variables -----------------------------------------
variable "database_subnet_cidr" {
  type = list(string)
}

variable "database_subnet_tags" {
  type    = map(any)
  default = {}
}
//---------- NAT Gateway variables ----------------------------------------
variable "nat_gateway_tags" {
  type    = map(any)
  default = {}
}
//----------VPC Peering variables ----------------------------------------

variable "is_peering_required" {
  type    = bool
  default = false
}

variable "vpc_peering_tags" {
  type    = map(any)
  default = {}
}
