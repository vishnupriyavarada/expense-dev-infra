module "db" {
  source = "terraform-aws-modules/rds/aws"
  identifier = local.resource_name #expense-dev

  engine            = "mysql"
  engine_version    = "8.0.40"
  instance_class    = "db.t4g.micro"
  allocated_storage = 20

  db_name  = "transactions" # this is expense database. AWS will automatically create this schema when creating rds
  username = "root"
  password = "ExpenseApp1"
  port     = "3306"

  vpc_security_group_ids = [local.mysql_sg_id]

  tags = merge(
    var.common_tags,
    {
        Name = "${var.projectname}-${var.environment}-rds"
    }
  )
  # DB subnet group
  create_db_subnet_group = false # false because we already created db_subnet_group
  db_subnet_group_name  = d

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Database Deletion Protection
  deletion_protection = true

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}

