#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

ips=$(hostname -I)
first_ip=$(echo $IP | cut -d' ' -f1)

pod_network="172.16.0.0/16"
service_network="10.96.0.0/12"

cluster_domain="zackshomelab.com"
cluster_name="pluto"
cluster_namespace="default"

hostname=$(hostname | tr '[:upper:]' '[:lower:]')
user_id=$(id -u)

if [ $user_id -ne 0 ]; then$
    echo "Need to run with sudo privilege"
    exit 1
fi

# Determine our package provider
os_type=$(grep ^ID_LIKE /etc/os-release | cut -f2 -d=)
if [ "$os_type" = "debian" ]; then

  # Check if apt is installed
  get_package_provider=$(command -v apt)
  if [ -n "$($get_package_provider | tr -d '[:space:]')" ]; then
    package_provider="apt"
  else

    # Check if apt-get is installed
    get_package_provider=$(command -v apt-get)
    if [ -n "$($get_package_provider | tr -d '[:space:]')" ]; then
      package_provider="apt-get"
    else

      # Neither apt or apt-get exist
      echo "upgrade_packages: Can not find 'apt' or 'apt-get'"
      exit 1
    fi
  fi
fi

function upgrade_packages() {

  case $package_provider in
    apt)
        apt -qqy upgrade
      ;;

    apt-get)
        apt-get -qqy upgrade
      ;;

    *)
      echo "upgrade_packages: Unknown package provider."
      exit 1
      ;;
  esac

  if [ $? -ne 0 ]; then
    echo "upgrade_packages: 'apt' failed upgrading with exit code '$?'"
    exit 1
  fi
}

function update_packages() {

  case $package_provider in
    apt)
        apt -qqy update
      ;;

    apt-get)
        apt-get -qqy update
      ;;

    *)
      echo "update_packages: Unknown package provider."
      exit 1
      ;;
  esac

  if [ $? -ne 0 ]; then
    echo "update_packages: '$package_provider' failed updating with exit code '$?'"
    exit 1
  fi
}

function install_packages() {
  packages=$(printf "%s " "$@")

  case $package_provider in
    apt)
        apt -qqy install $packages
      ;;

    apt-get)
        apt-get -qqy install $packages
      ;;

    *)
      echo "install_packages: Unknown package provider."
      exit 1
      ;;
  esac

  if [ $? -ne 0 ]; then
    echo "install_packages: '$package_provider' failed installing packages with exit code '$?'"
    exit 1
  fi
}

function remove_packages() {
  packages=$(printf "%s " "$@")

  case $package_provider in
    apt)
        apt -qqy remove $packages
      ;;

    apt-get)
        apt-get -qqy remove $packages
      ;;

    *)
      echo "remove_packages: Unknown package provider."
      exit 1
      ;;
  esac

  if [ $? -ne 0 ]; then
    echo "remove_packages: '$package_provider' failed removing packages with exit code '$?'"
    exit 1
  fi

  os_type=$(grep ^ID_LIKE /etc/os-release | cut -f2 -d=)
}

function prepare_env() {
  # Install / Upgrade packages
  echo "prepare_env: Performing updates/upgrades..."

  update_packages
  upgrade_packages

  # Install required packages
  echo "prepare_env: Installing required packages..."
  install_packages curl gnupg lsb-release git wget jq

  # Disable Swap
  echo "prepare_env: Disabling swap..."
  swapoff -a
  sed -i 's/^\/swap/#\/swap/' /etc/fstab
}

function install_docker() {
  # Remove currently installed docker packages
  echo "install_docker: Removing installed docker packages..."
  remove_packages docker.io docker-doc docker-compose podman-docker containerd runc

  # Prepare apt-cache for docker packages
  echo "install_docker: Installing docker's keyring..."
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Install docker
  echo "install_docker: Installing docker..."
  update_packages
  install_packages docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

function install_docker_runtime() {
  initial_dir=$(pwd)

  cd /tmp
  wget https://storage.googleapis.com/golang/getgo/installer_linux
  chmod +x ./installer_linux
  ./installer_linux
  source ~/.bash_profile

  # Download the runtime
  git clone https://github.com/Mirantis/cri-dockerd.git

  # Prepare docker runtime
  cd cri-dockerd
  mkdir bin
  go build -o bin/cri-dockerd

  # Install docker runtime
  install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd

  # Prepare docker runtime with systemd
  cp -a packaging/systemd/* /etc/systemd/system
  sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
  systemctl daemon-reload
  systemctl enable cri-docker.service
  systemctl enable --now cri-docker.socket

  cd $initial_dir

  # Cleanup time
  rm -rf /tmp/installer_linux /tmp/cri-dockerd
}

function install_k8() {
  # Prepare apt to download Kubeadm, Kubectl, and Kubelet
  curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | \
    tee /etc/apt/sources.list.d/kubernetes.list

  update_packages
  install_packages kubelet kubeadm kubectl
}

function init_control_node() {
  kubeadm init \
    --pod-network-cidr=$pod_network \
    --service-cidr=$service_network \
    --service-dns-domain=$cluster_domain \
        --token "8d2hil.y25jurafkn12t41c" \
    --token-ttl 0 \
        --cri-socket=unix:///var/run/cri-dockerd.sock

  if [ "$user_id" -ne 0 ]; then
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
  else
    export KUBECONFIG=/etc/kubernetes/admin.conf
  fi
}

function init_pod_network() {
  kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
}

function deploy_on_control_plane() {
  kubectl taint nodes $hostname node-role.kubernetes.io/control-plane:NoSchedule --overwrite
}

function deploy_on_master() {
  kubectl taint nodes $hostname node-role.kubernetes.io/master=:NoSchedule --overwrite
}

prepare_env
install_docker
install_docker_runtime
install_k8
#init_control_node
#init_pod_network
#deploy_on_control_plane
