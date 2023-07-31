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
  }

  provisioner "remote-exec" {
    inline = [
      "sudo curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64",
      "sudo chmod +x minikube",
      "sudo mv minikube /usr/local/bin/",
      "sudo sysctl fs.protected_regular=0", # Allows Minikube to work with some Linux distributions
    ]
  }
}

# null_resource for Jenkins
resource "null_resource" "jenkins_setup" {
  # Your existing provisioner code for Jenkins installation goes here
}

# Output URL for Jenkins
output "jenkins_url" {
  value     = join ("", ["http://", aws_instance.ec2_instance.public_dns, ":", "8080"])
}

# Output URL for Minikube
output "minikube_url" {
  value     = join ("", ["http://", aws_instance.minikube_instance.public_dns, ":", "8080"])
}
