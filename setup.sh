#!/bin/bash
latestVersion=$(curl -s https://api.github.com/repos/AsamK/signal-cli/releases/latest | grep -o '"tag_name": ".*"' | sed 's/"tag_name": "//;s/"//')
echo "Latest signal-cli Version: $latestVersion"

sudo apt update

sudo apt install python-3 phython-matplotlib -y

sudo apt install openjdk-18-jre -y

wget https://github.com/AsamK/signal-cli/releases/download/$latestVersion/signal-cli-${latestVersion#v}.tar.gz
sudo tar xf signal-cli-${latestVersion#v}.tar.gz -C /opt
sudo ln -sf /opt/signal-cli-${latestVersion#v}/bin/signal-cli /usr/local/bin/

sudo apt install screen -y

git clone https://github.com/The-Bug-Bashers/VaGABfS.git
wget https://cdn.pixabay.com/photo/2022/01/30/13/33/github-6980894_1280.png

mv ~/VaGABfS/* ~/

echo "Installation finished."