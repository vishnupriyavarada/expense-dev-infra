resource "aws_instance" "backend" {
  ami                    = local.ami-id
  instance_type          = var.instance_type
  subnet_id = local.private_subnet_ids[0]// getting first subnet id from the list
  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]
  tags = merge(
    var.common_tags,
    {
        Name = "${var.projectname}-${var.environment}-backend"
    }
  )
  
}

resource "null_resource" "backend" {
  # Changes to any instance of the cluster(group of instances) requires re-provisioning
  triggers = {
    instance_id = aws_instance.backend.id
  }

  # Connecting to backend instance
  connection {
    host = aws_instance.backend.private_ip
    type = "ssh"
    user =  "ec2-user1"
    password = "DevOps321"
  }

  provisioner "file" {
    source      = "backend.sh"
    destination = "/tmp/backend.sh"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/backend.sh", # changing the permissions of backend.sh
      "sudo sh /tmp/backend.sh ${var.environment}" # executing the backend.sh in server with sudo access

    ]
  }
}

# ----- Stop the ec2 instance ---------
resource "aws_ec2_instance_state" "backend" {
  instance_id = aws_instance.backend.id
  state       = "stopped"
  depends_on = [ null_resource.backend ] # Stop ec2 instance only when null_resource provisioner tasks are completed
}

# ------ 1 . AMI - Take the ami of the backend server ----
resource "aws_ami_from_instance" "backend" {
  name               = local.resource_name
  source_instance_id = aws_instance.backend.id
  depends_on = [ aws_ec2_instance_state.backend ] # take ami of the backend server only when ec2 instance is stopped
}

# ------ Terminate Ec2 instance when the ami of the backend server is completed ----
resource "null_resource" "backend_terminate_ec2" {
  # trigger everytime when AMI is taken and instance changes
  triggers = {
    instance_id = aws_instance.backend.id
  }

  provisioner "local-exec" {
    command =     aws_ami_from_instance
  }
  depends_on = [ aws_ami_from_instance.backend ] # terminate backend ec2 instance only when ami is taken
}

# -------- 2. Target Group - create TG -------------------

resource "aws_lb_target_group" "backend" {
  name     = local.resource_name
  port     = 8080
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5 # wait time in between the request
    protocol = "HTTP"
    port = 8080
    path = "/health"
    matcher = "200-299" # success code range
    interval = 10 # how often the health check has to be done
  }
}

# ---------- 3 . Launch template -------------------

resource "aws_launch_template" "backend" {
  name = local.resource_name
  image_id = aws_ami_from_instance.backend.id
  instance_initiated_shutdown_behavior = "terminate" # if ASG reduces the instance than it should terminate the instances
  instance_type = "t3.micro"
  update_default_version = true # every time you go for a new release, launch template picks that latest version for launching ec2
  vpc_security_group_ids = [local.backend_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = local.resource_name
    }
  }

}

# ---------- 4 . Create Auto scaling group -----------

resource "aws_autoscaling_group" "backend" {
  name                      = local.resource_name
  max_size                  = 10
  min_size                  = 2
  health_check_grace_period = 60 # with in 60 sec it has to do health check
  health_check_type         = "ELB"
  desired_capacity          = 2
  target_group_arns = [aws_lb_listener_rule.backend.arn] # 2. which target group the instance should be placed

  launch_template {
    id      = aws_launch_template.backend.id # 1. we created launch template above
    version = "$Latest"
  }

  vpc_zone_identifier       = [local.private_subnet_ids]

  # Rolling update - when old instance is deleted and new instance is created
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = [launch_template] # everytime launch templates changes, trigger's the instance refresh. When will launch template change ? when AMI changes.
  }

  timeouts {
    delete = "5m" # with in 5minutes of time if the instance is not up then it will delete the instance
  }

  tag {
    key                 = "Name"
    value               = local.resource_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "expense"
    propagate_at_launch = false
  }

  tag {
    key                 = "Environment"
    value               = "dev"
    propagate_at_launch = false
  }
 
}

# --------- 5. ALB listener rule ---------------
resource "aws_lb_listener_rule" "backend" {
  listener_arn = data.aws_ssm_parameter.app_alb_listener_arn.value
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    host_header {
      values = ["backend.app-${var.environment}.${var.domain_name}"]
    }
  }
}



