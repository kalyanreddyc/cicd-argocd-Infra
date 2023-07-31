sudo usermod -aG docker jenkins
sudo service jenkins restart
sudo chgrp docker /var/run/docker.sock
sudo chmod 660 /var/run/docker.sock
sudo usermod -aG docker jenkins
sudo service jenkins restart
