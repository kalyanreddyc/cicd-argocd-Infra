#!/bin/bash
sudo yum update –y
sudo yum install wget -y
sudo echo "*******INSTALLING OPENJDK11 MAVEN GIT**********"
sudo yum install java-11-openjdk -y
sudo yum install maven -y
sudo mvn -version
sudo yum install git -y
sudo echo "*******INSTALLING and starting JENKINS**********"
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins > /tmp/jenkins_status.txt
sudo echo "*************JENKINS STATUS can be seen below *****************"
sudo cat /tmp/jenkins_status.txt
sudo echo "*************JENKINS Initial admin password can be seen below *****************"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
sudo echo "*************JENKINS Initial admin password can be seen Above *****************"
sudo yum update -y
sudo echo "*******INSTALLING AWS CLI **********"
sudo python3 --version
sudo yum install python3-pip -y
sudo pip3 install awscli
aws --version
sudo echo "*******INSTALLING and starting SONARQUBE **********"
sudo mkdir -p /opt/sonarqube
sudo wget -P /opt/sonarqube/  https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.6.1.59531.zip?_gl=1*kyj9w1*_gcl_au*MTMzNDYwODY1MC4xNjg3MTk5MzEz*_ga*NDQ5Mzk2Njk4LjE2ODcxOTkzMTM.*_ga_9JZ0GZ5TC6*MTY4NzI3NDY2Ni40LjEuMTY4NzI3NDk2Ni42MC4wLjA.
sudo mv /opt/sonarqube/sonarqube-9.6.1.59531.zip\?_gl\=1\*kyj9w1\*_gcl_au\*MTMzNDYwODY1MC4xNjg3MTk5MzEz\*_ga\*NDQ5Mzk2Njk4LjE2ODcxOTkzMTM.\*_ga_9JZ0GZ5TC6\*MTY4NzI3NDY2Ni40LjEuMTY4NzI3NDk2Ni42MC4wLjA. /opt/sonarqube/sonarqube-9.6.1.zip
sudo yum install -y unzip
sudo unzip /opt/sonarqube/sonarqube-9.6.1.zip -d /opt/sonarqube/
sudo mv /opt/sonarqube/sonarqube-9.6.1.59531 /opt/sonarqube/sonarqube-9.6.1
sudo rm -rf /opt/sonarqube/sonarqube-9.6.1.zip
sudo useradd sonar
sudo chown -R sonar:sonar /opt/sonarqube
sudo su - sonar -c "/opt/sonarqube/sonarqube-9.6.1/bin/linux-x86-64/sonar.sh start"
sudo su - sonar -c "/opt/sonarqube/sonarqube-9.6.1/bin/linux-x86-64/sonar.sh status"
sudo echo "*******INSTALLING and starting DOCKER **********"
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io -y
sudo systemctl enable docker
sudo systemctl start docker
sudo docker --version
sudo echo "*******INSTALLING and starting Terraform **********"
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
sudo terraform -version
sudo echo "*******INSTALLING and starting ANSIBLE **********"
sudo python3 -m pip -V
sudo wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
sudo yum install epel-release-latest-9.noarch.rpm -y
sudo yum install ansible -y
ansible --version