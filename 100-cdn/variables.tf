# setting mandatory because this is my org standards
variable "projectname" {
  type = string
}

# setting mandatory because this is my org standards
variable "environment" {
  type = string
}

variable "common_tags" {
  type = map(any)
  default = {
    ProjectName = "expense"
    Environment = "dev"
    Terraform   = "True"
  }
}

# Route 53 - Hosted zone id
variable "zone_id" {
  default = "Z09859442XBHBSN9FNQ5B"  
}

variable "domain_name" {
  default = "vishnudevopsaws.online"  
}
