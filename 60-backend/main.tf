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

# ------ Take the ami of the backend server ----
resource "aws_ami_from_instance" "backend" {
  name               = local.resource_name
  source_instance_id = aws_instance.backend.id
  depends_on = [ aws_ec2_instance_state.backend ] # take ami of the backend server only when ec2 instance is stopped
}

# ------ Terminate Ec2 instance when the ami of the backend server ----
resource "null_resource" "backend" {
  provisioner "local-exec" {
    command =     aws_ami_from_instance
  }
  depends_on = [ aws_ami_from_instance.backend ] # take ami of the backend server only when ec2 instance is stopped
}

