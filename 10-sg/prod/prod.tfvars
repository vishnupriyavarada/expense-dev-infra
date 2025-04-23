projectname = "expense"
environment = "production"
vpc_cidr="10.0.0.0/16"  
common_tags={
    Project = "Expense"
    Environment = "Production"
    Terraform = "True"
}

# public_subnet_cidr = ["10.0.1.0/24", "10.0.2.0/24"]
# private_subnet_cidr = ["10.0.11.0/24", "10.0.12.0/24"]
# database_subnet_cidr = ["10.0.21.0/24", "10.0.22.0/24"]

sg_db_name="mysql"  
sg_db_description="security group created for mysql instance for expense project"

sg_backend_name="backend"  
sg_backend_description="security group created for backend instance for expense project"

sg_frontend_name="frontend"  
sg_frontend_description="security group created for frontend instance for expense project"