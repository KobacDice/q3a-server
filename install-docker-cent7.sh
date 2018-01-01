sudo yum remove docker docker-common docker-selinux docker-engine
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum -y makecache fast
sudo yum -y install docker-ce-17.06.0.ce-1.el7.centos
sudo yum -y install docker-ce
sudo systemctl start docker
sudo systemctl enable docker

