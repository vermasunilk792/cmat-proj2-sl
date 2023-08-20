# Main Terraform configuration file

# Define the local variables for the root module
locals {
  ami_id = "ami-0261755bbcb8c4a84"
  ssh_user = "ubuntu"
  key_name = "wpserver"
  private_key_path = "${path.module}/wpserver.pem"
}



# This creates the EC2 instance and makes an initial SSH connection.
resource "aws_instance" "wpserver" {
  ami = var.aws_ami_id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.skv-terra.id]
  key_name = "key-tfnew"

  tags = {
    Name = "WordPress Server"
  }

  connection {
    type = "ssh"
    host = self.public_ip
    user = local.ssh_user
    private_key = file(var.ssh_key_pair)
    timeout = "4m"
  }

  provisioner "remote-exec" {
    inline = [
      "touch /home/ubuntu/demo-file-from-terraform.txt"
    ]
  }
}

# Creating a local hosts file for Ansible to use
resource "local_file" "hosts" {
  content = templatefile("${path.module}/templates/hosts",
    {
      public_ipaddr = aws_instance.wpserver.public_ip
      key_path = var.ssh_key_pair
      ansible_user = local.ssh_user
    }
  )
  filename = "${path.module}/hosts"
}

# We will use a null resource to execute the playbook with a local-exec provisioner.

resource "null_resource" "run_playbook" {
  depends_on = [

    # Running of the playbook depends on the successfull creation of the EC2
    # instance and the local inventory file.

    aws_instance.wpserver,
    local_file.hosts,
  ]

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i hosts --private-key ${var.ssh_key_pair} -e 'pub_key=${var.ssh_key_pair_pub}' playbook.yml"
  }
}
