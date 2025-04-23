projectname = "expense"
environment = "production"
vpc_cidr="10.0.0.0/16"  
common_tags={
    Project = "Expense"
    Environment = "Production"
    Terraform = "True"
}

public_subnet_cidr = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidr = ["10.0.11.0/24", "10.0.12.0/24"]
database_subnet_cidr = ["10.0.21.0/24", "10.0.22.0/24"]