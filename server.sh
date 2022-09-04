#!/bin/bash

#install nala
echo "deb http://deb.volian.org/volian/ scar main" | sudo tee /etc/apt/sources.list.d/volian-archive-scar-unstable.list
wget -qO - https://deb.volian.org/volian/scar.key | sudo tee /etc/apt/trusted.gpg.d/volian-archive-scar-unstable.gpg
sudo apt update 
sudo apt -y install nala

#install wego terminal weather
sudo nala install golang-go -y
sudo export GOPATH=/home/$USER/gocode
go install github.com/schachmat/wego@latest

#setup wego
/home/$USER/gocode/bin/wego
sudo sed -i 's/location=40.748,-73.985/location=Dorog/' /home/$USER/.wegorc
sudo sed -i 's/owm-api-key=/owm-api-key=c4b0ce26404190e1c66c88d5c9f80c66/' /home/$USER/.wegorc
sudo sed -i 's/backend=forecast.io/backend=openweathermap/' /home/$USER/.wegorc
sudo sed -i 's/owm-lang=en/owm-lang=hu/' /home/$USER/.wegorc
/home/$USER/gocode/bin/wego

#make startup script
sudo echo '#!/bin/bash' > /etc/profile.d/startup.sh
sudo echo -e "clear\n/home/$USER/gocode/bin/wego\nneofetch" >> /etc/profile.d/startup.sh

#install supervisor
sudo nala install supervisor -y

#upgrade
sudo nala update
sudo nala upgrade -y