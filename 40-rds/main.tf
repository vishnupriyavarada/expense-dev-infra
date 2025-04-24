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
  manage_master_user_password = false # We don't want AWS RDS to manage pwd as we have our own password
  port     = "3306"

  vpc_security_group_ids = [local.mysql_sg_id]

  # DB subnet group
  create_db_subnet_group = false # false because we already created db_subnet_group
  db_subnet_group_name  = local.db_subnet_group_name

  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version = "8.0"

  # Database Deletion Protection
  deletion_protection = false # keeping it false else we can not delete it from TF. 
                              #usually in projects this will be true so that no one is allowed to delete from console

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

  tags = merge(
    var.common_tags,
    {
        Name = local.resource_name
    }
  )
}


# ------------ Route 53 record for RDS mysql --------------------

resource "aws_route53_record" "mysql-dev" {
  zone_id = var.zone_id
  name    = "${local.resource_name}.${var.domain_name}" #expense-dev.domain_name
  type    = "CNAME"
  ttl     = 1
  records = [module.db.db_instance_address]
}

