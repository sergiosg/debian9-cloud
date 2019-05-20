#!/usr/bin/env bash

grep -qxF 'ID=ubuntu' /etc/os-release && export DISTRO=ubuntu
grep -qxF 'ID=debian' /etc/os-release && export DISTRO=debian

sudo apt-get update
sudo apt-get install -y \
    unzip \
    git \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

#JAVA & PYTHON
sudo apt-get install -y openjdk-8-jdk python3-pip

#GRADLE
if [[ ! -d /opt/gradle ]]
then
    echo "Installing gradle..."
    wget https://services.gradle.org/distributions/gradle-5.4.1-bin.zip -P /tmp
    sudo unzip -d /opt/gradle -o /tmp/gradle-5.4.1-bin.zip
    rm /tmp/gradle-5.4.1-bin.zip
    printf "export GRADLE_HOME=/opt/gradle/gradle-5.4.1\nexport PATH=\${GRADLE_HOME}/bin:\${PATH}" | sudo tee /etc/profile.d/gradle.sh
    sudo chmod +x /etc/profile.d/gradle.sh
fi

#AWS Cli 
if [[ ! -e /usr/local/bin/aws ]]
then
    echo "Installing Awscli..."
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
    unzip awscli-bundle.zip
    sudo python3 awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
    rm awscli-bundle.zip -f
fi

if [[ ! -e /usr/local/bin/session-manager-plugin ]]
then
    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
    sudo dpkg -i session-manager-plugin.deb
    rm session-manager-plugin.deb -f
fi


###############################################################################
#Install ec2sh
#Ref: https://github.schibsted.io/scmspain/tools-common--awesome/tree/master/ec2sh

#AWLESS https://github.com/wallix/awless
if [[ ! -e /opt/awless/bin ]]
then
    echo "Installing Awless..."
    curl https://raw.githubusercontent.com/wallix/awless/master/getawless.sh | bash
    sudo mkdir -p /opt/awless/bin
    sudo mv awless /opt/awless/bin
    printf "export PATH=/opt/awless/bin:\${PATH}" | sudo tee /etc/profile.d/awless.sh
    sudo chmod +x /etc/profile.d/awless.sh
fi    


#SBT
if [[ ! -e /usr/bin/sbt ]]
then
    echo "Installing SBT..."
    wget https://dl.bintray.com/sbt/debian/sbt-1.2.8.deb
    sudo dpkg -i sbt-1.2.8.deb
    rm sbt-1.2.8.deb -f
fi

#gimme-aws-creds
if [[ ! -e /usr/local/bin/gimme-aws-creds ]]; then
    echo "Installing gimme-aws-creds..."
    sudo pip3 install --upgrade gimme-aws-creds

    if [[ $DISTRO == "debian" ]]; then
        sudo pip3 install --upgrade keyrings.alt
    fi
fi


#Docker
if [[ $DISTRO == "ubuntu" ]]
then
    echo "Installing docker..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo apt-key fingerprint 0EBFCD88
    sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

elif [[ $DISTRO == "debian" ]]
then
    echo "Installing docker..."
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    sudo apt-key fingerprint 0EBFCD88
    sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/debian \
        $(lsb_release -cs) \
        stable"


fi

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER


echo "Installing kubectl..."
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl


#Clean and remove history
sudo apt-get clean
cat /dev/null > ~/.bash_history && history -c && exit
