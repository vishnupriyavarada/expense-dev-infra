resource "aws_instance" "frontend" {
  ami                    = local.ami-id # Org's golden AMI - This will get continuosly updated
  instance_type          = var.instance_type
  subnet_id = local.private_subnet_ids[0]// getting first subnet id from the list
  vpc_security_group_ids = [data.aws_ssm_parameter.frontend_sg_id.value]
  tags = merge(
    var.common_tags,
    {
        Name = "${var.projectname}-${var.environment}-frontend"
    }
  )
  
}

resource "null_resource" "frontend" {
  # Changes to any instance of the cluster(group of instances) requires re-provisioning
  triggers = {
    instance_id = aws_instance.frontend.id
  }

  # Connecting to frontend instance
  connection {
    host = aws_instance.frontend.public_ip # we can give private_ip but we need to start vpn. hence giving public_ip
    type = "ssh"
    user =  "ec2-user1"
    password = "DevOps321"
  }

  provisioner "file" {
    source      = "frontend.sh"
    destination = "/tmp/frontend.sh"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/frontend.sh", # changing the permissions of frontend.sh
      "sudo sh /tmp/frontend.sh ${var.environment}" # executing the frontend.sh in server with sudo access

    ]
  }
}

# ----- Stop the ec2 instance ---------
resource "aws_ec2_instance_state" "frontend" {
  instance_id = aws_instance.frontend.id
  state       = "stopped"
  depends_on = [ null_resource.frontend ] # Stop ec2 instance only when null_resource provisioner tasks are completed
}

# ------ 1 . AMI - Take the ami of the frontend server ----
resource "aws_ami_from_instance" "frontend" {
  name               = local.resource_name
  source_instance_id = aws_instance.frontend.id
  depends_on = [ aws_ec2_instance_state.frontend ] # take ami of the frontend server only when ec2 instance is stopped
}

# ------ Terminate Ec2 instance when the ami of the frontend server is completed ----
resource "null_resource" "frontend_terminate_ec2" {
  # trigger everytime when AMI is taken and instance changes
  triggers = {
    instance_id = aws_instance.frontend.id
  }

  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.frontend}"
  }
  depends_on = [ aws_ami_from_instance.frontend ] # terminate frontend ec2 instance only when ami is taken
}

# -------- 2. Target Group - create TG -------------------

resource "aws_lb_target_group" "frontend" {
  name     = local.resource_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id
    deregistration_delay = 60 # 1 min - Amount of time for ALB to wait before changing the state of a deregistering target from draining to unused

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5 # wait time in between the request
    protocol = "HTTP"
    port = 80
    path = "/"
    matcher = "200-299" # success code range
    interval = 10 # how often the health check has to be done
  }
}

# ---------- 3 . Launch template -------------------

resource "aws_launch_template" "frontend" {
  name = local.resource_name
  image_id = aws_ami_from_instance.frontend.id
  instance_initiated_shutdown_behavior = "terminate" # if ASG reduces the instance than it should terminate the instances
  instance_type = "t3.micro"
  update_default_version = true # every time you go for a new release, launch template picks that latest version for launching ec2
  vpc_security_group_ids = [local.frontend_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = local.resource_name
    }
  }

}

# ---------- 4 . Create Auto scaling group -----------

resource "aws_autoscaling_group" "frontend" {
  name                      = local.resource_name
  max_size                  = 10
  min_size                  = 1
  health_check_grace_period = 60 # with in 60 sec it has to do health check
  health_check_type         = "ELB"
  desired_capacity          = 1
  target_group_arns = [aws_lb_listener_rule.frontend.arn] # 2. which target group the instance should be placed

  launch_template {
    id      = aws_launch_template.frontend.id # 1. we created launch template above
    version = "$Latest"
  }

  vpc_zone_identifier       = [local.public_subnet_ids]

  # Rolling update - when old instance is deleted and new instance is created
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = [launch_template] # everytime launch templates changes, trigger's the instance refresh. When will launch template change ? when AMI changes.
  }

  timeouts {
    delete = "10m" # with in 5minutes of time if the instance is not up then it will delete the instance
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

# --------- 5. Auto scaling policy  ---------------
resource "aws_autoscaling_policy" "expense" {
  name                   = "${local.resource_name}-frontend"
  policy_type            = "TargetTrackingScaling" # this policy type tracks the targets and scales
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.frontend.name}"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }
}

# --------- 6. ALB listener rule ---------------
resource "aws_lb_listener_rule" "frontend" {
  listener_arn = data.aws_ssm_parameter.web_alb_listener_arn.value
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    host_header {
      values = ["expense-${var.environment}.${var.domain_name}"] # dev - expense-dev.daws82s.online ;qa - expense-devqa.daws82s.online 
      # prod - daws82s.online
    }
  }
}



