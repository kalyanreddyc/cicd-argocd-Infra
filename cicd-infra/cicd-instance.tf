resource "aws_security_group" "sg_dev_infra" {
  name = "sg_dev"
  vpc_id = "${var.vpc}"
  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port   = 9000
      to_port     = 9000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_instance" "ec2_instance" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet
  vpc_security_group_ids = [aws_security_group.sg_dev_infra.id] 
  key_name               = var.key_name
  # user_data            = file("install_cicd.sh")

  tags = {
    Terraform = "true"
    Environment = "dev-cicd"
  }
}

# an empty resource block
resource "null_resource" "name" {

  # ssh into the ec2 instance 
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("kalyancisco.pem")
    host        = aws_instance.ec2_instance.public_ip
  }

  # copy the install_cicd.sh file from your computer to the ec2 instance 
  provisioner "file" {
    source      = "install_cicd.sh"
    destination = "/tmp/install_cicd.sh"
  }

  # set permissions and run the install_cicd.sh file
  provisioner "remote-exec" {
    inline = [ 
        "sudo chmod +x /tmp/install_cicd.sh",
        "bash /tmp/install_cicd.sh",
    ]
  }

  # wait for ec2 to be created
  depends_on = [aws_instance.ec2_instance]
}

# print the url of the cicd server
output "website_url" {
  value     = join ("", ["http://", aws_instance.ec2_instance.public_dns, ":", "8080"])
}
