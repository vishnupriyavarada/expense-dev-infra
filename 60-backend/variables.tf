# setting mandatory because this is my org standards
variable "projectname" {
  type = string
}

# setting mandatory because this is my org standards
variable "environment" {
  type = string
}

variable "instance_type" {
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