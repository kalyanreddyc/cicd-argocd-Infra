#!/bin/bash
sudo yum update -y
sudo yum install wget -y
sudo echo "*******INSTALLING OPENJDK11 **********"
sudo yum install java-11-openjdk -y
sudo echo "*******INSTALLING and starting DOCKER **********"
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io -y
sudo usermod -aG docker $USER
echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/docker, /usr/bin/systemctl start docker" | sudo tee -a /etc/sudoers
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker > /dev/null
sleep 10s
sudo docker --version
sudo echo "*********INSTALLING kubectl*************************"
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
sudo yum install -y kubectl
kubectl version --client --output=yaml
sudo echo "*******INSTALLING and starting Minikube **********"
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
sudo chmod +x minikube-latest.x86_64.rpm
sudo rpm -Uvh minikube-latest.x86_64.rpm
minikube start
kubectl get po -A
sudo echo "*******INSTALLING and starting ArgoCD **********"
curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.25.0/install.sh | bash -s v0.25.0
kubectl create -f https://operatorhub.io/install/argocd-operator.yaml
sleep 40s
kubectl get po -n operators
kubectl get csv -n operators
# Content of the YAML file
cat <<EOF > argocd.yaml
apiVersion: argoproj.io/v1alpha1
kind: ArgoCD
metadata:
  name: dev-argocd
  labels:
    example: basic
spec: {}
EOF

sudo echo "YAML content written to argocd.yaml"
kubectl create ns argocd
kubectl apply -f argocd.yaml -n argocd
sudo chmod +x argocd.yaml
sleep 30s
kubectl get po -n argocd
kubectl get svc -n argocd
current_yaml=$(kubectl get svc dev-argocd-server -n argocd -o yaml)
modified_yaml=$(echo "$current_yaml" | sed 's/type: ClusterIP/type: NodePort/')
echo "$modified_yaml" | kubectl apply -n argocd -f -
kubectl get svc -n argocd
minikube service dev-argocd-server -n argocd
minikube service list 
current_secret=$(kubectl get secret dev-argocd-cluster -n argocd -o json)
modified_secret=$(echo "$current_secret" | jq '.data["admin.password"] = "'"YWRtaW5ANzgzMw=="'"')
echo "$modified_secret" | kubectl apply -n argocd -f -
sudo yum install -y jq
sudo echo "***********ArgoCD admin password!*************"
#echo "$(kubectl get secret argocd-initial-admin-secret -n argocd -o json | jq -r '.data.password' | base64 -d)"
echo "$(kubectl get secret dev-argocd-cluster -n argocd -o json | jq -r '.data["admin.password"]' | base64 --decode)"
sudo echo "***********Forwarding the port*************"
service_port=$(kubectl get svc dev-argocd-server -n argocd -o jsonpath='{.spec.ports[0].nodePort}')
sudo echo "$service_port"
sudo echo "***************Port to be fowarded*****************"
nohup kubectl port-forward --address 0.0.0.0 svc/dev-argocd-server -n argocd "$service_port":80 > /dev/null 2>&1 &
sleep 30s