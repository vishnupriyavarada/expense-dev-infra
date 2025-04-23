module "vpc" {
  # source               = "../terraform-aws-vpc" // this method is used when your code is in local
  source               = "git::https://github.com/vishnupriyavarada/terraform-aws-vpc.git?ref=main"
  projectname          = var.projectname
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  common_tags          = var.common_tags
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidr  = var.private_subnet_cidr
  database_subnet_cidr = var.database_subnet_cidr
  is_peering_required  = true
}

# This can be included in module
resource "aws_db_subnet_group" "expense" {
  name       = "${var.projectname}-${var.environment}"
  subnet_ids = module.vpc.database_subnet_ids
  tags = merge(
    var.common_tags,
    {
      Name = "${var.projectname}-${var.environment}"
    }
  )
}