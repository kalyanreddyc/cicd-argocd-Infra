# AWS Security Group for Minikube
resource "aws_security_group" "sg_minikube" {
  name = "sg_minikube"
  vpc_id = var.vpc

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
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
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

# EC2 Instance for Minikube
resource "aws_instance" "minikube_instance" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet
  vpc_security_group_ids = [aws_security_group.sg_minikube.id] 
  key_name               = var.key_name


  tags = {
    Terraform    = "true"
    Environment  = "dev-minikube"
    name         = var.instance_name

  }
}

  # an empty resource block
  resource "null_resource" "minikube" { 
    # ssh into the ec2 instance
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("kalyancisco.pem")
      host        = aws_instance.minikube_instance.public_ip
  }
  # copy the install_cicd.sh file from your computer to the ec2 instance 
  provisioner "file" {
    source      = "minikube_install.sh"
    destination = "/tmp/minikube_install.sh"
  }

  # set permissions and run the install_cicd.sh file
  provisioner "remote-exec" {
    inline = [ 
        "sudo chmod +x /tmp/minikube_install.sh",
        "bash /tmp/minikube_install.sh",
    ]
  }

  # wait for ec2 to be created
  depends_on = [aws_instance.minikube_instance]
  }

# Output URL for Minikube
output "minikube_url" {
  value     = join ("", ["http://", aws_instance.minikube_instance.public_dns, ":", ""])
}