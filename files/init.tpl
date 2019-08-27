echo "=== Waiting 30 sec. for package managers ..."
sleep 30

echo "=== Install Docker ${DOCKER_VERSION}"
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
sudo apt-get update
sudo apt list docker-ce -a
sudo apt-get install -y docker-ce=${DOCKER_VERSION}~ce-0~ubuntu-$(lsb_release -cs)

echo "=== Install open-iscsi needed for longhorn"
sudo apt-get install -y open-iscsi
