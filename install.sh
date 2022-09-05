#!/bin/bash
# https://www.xmodulo.com/create-dialog-boxes-interactive-shell-script.html

BASEDIR=$(dirname "$0")

dialog_install(){
    if command -v "whiptail" &> /dev/null
    then
        return
    fi

    read -p "whiptail is not installed. Insall dialog (request for install)? " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]];
    then
        sudo apt -y install whiptail
    else
        exit
    fi
}


app_install(){
    app=$1
    if command -v "nala" &> /dev/null
    then
        sudo nala install "$app" -y
    else
        sudo apt -y install "$app"
    fi
}

wego() {
    {
        echo 0
        app_install golang-go
        echo 30
        export GOPATH=/home/user/gocode #test it sudo?
        echo 35
        go install github.com/schachmat/wego@latest
        echo 45
        /home/user/gocode/bin/wego
        echo 50
        API=$(whiptail --title "OpenWeather API" --inputbox "Please insert your OW API key?" 10 60 3>&1 1>&2 2>&3)
        sudo sed -i 's/location=40.748,-73.985/location=Dorog/' /home/user/.wegorc
        sudo sed -i "s/owm-api-key=/owm-api-key=$API/" /home/user/.wegorc
        sudo sed -i 's/backend=forecast.io/backend=openweathermap/' /home/user/.wegorc
        sudo sed -i 's/owm-lang=en/owm-lang=hu/' /home/user/.wegorc
        echo 100
        /home/user/gocode/bin/wego
    } | whiptail --gauge "Please wait while installing" 6 60 0

    menu
}

update_upgrade(){
    msgs=("Update Packages..."
        "Upgrade packages..."
        )
    commands=("sudo apt-get update -y"
            "sudo apt-get upgrade -y"
            )

    n=${#commands[@]}
    i=0
    while [ "$i" -lt "$n" ]; do
        pct=$(( i * 100 / n ))
        echo XXX
        echo $i
        echo "${msgs[i]}"
        echo XXX
        echo "$pct"
        eval "${commands[i]}"
        i=$((i + 1))
        sleep 1
    done | whiptail --title "Update and Upgrade" --gauge "Preparing install..." 10 60 0

    menu
}

update(){
    if command -v "nala" &> /dev/null
    then
        sudo nala update
    else
        sudp apt update
    fi  
    menu
}

nala_install(){
    echo "deb http://deb.volian.org/volian/ scar main" | sudo tee /etc/apt/sources.list.d/volian-archive-scar-unstable.list
    wget -qO - https://deb.volian.org/volian/scar.key | sudo tee /etc/apt/trusted.gpg.d/volian-archive-scar-unstable.gpg
    sudo apt update 
    sudo apt -y install nala
    menu
}

startup(){
    FILE=/etc/profile.d/startup.sh
    if test -f "$FILE"; then
        echo "$FILE exists."
        read -p "startup.sh file is exist, remove the file?? " -n 1 -r
        echo    # (optional) move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            sudo rm -r /etc/profile.d/startup.sh
        else
            return
        fi
    fi
    sudo echo '#!/bin/bash' > /etc/profile.d/startup.sh
    sudo echo 'clear' >> /etc/profile.d/startup.sh

    if command -v "go" &> /dev/null
    then
        sudo echo '/home/user/gocode/bin/wego' >> /etc/profile.d/startup.sh
    fi

    if ! command -v "neofetch" &> /dev/null
    then
        read -p "neofetch is not installed, want to install?? " -n 1 -r
        echo    # (optional) move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            neofetch
            sudo echo 'neofetch' >> /etc/profile.d/startup.sh
        fi
    else
        sudo echo 'neofetch' >> /etc/profile.d/startup.sh
    fi
    menu
}

supervisor(){
    app_install supervisor
    menu
}

progress(){

    argv=("${@}")                           # All arguments in one big array
    len_1=${argv[0]}                        # Length of first array passad
    msgs=("${argv[@]:1:$len_1}")           # First array
    len_2=${argv[(len_1 + 1)]}              # Length of second array passad
    commands=("${argv[@]:(len_1 + 2):$len_2}") # Second array

    n=${#commands[@]}
    i=0
    while [ "$i" -lt "$n" ]; do
        pct=$(( i * 100 / n ))
        echo XXX
        echo $i
        echo "${msgs[i]}"
        echo XXX
        echo "$pct"
        eval "${commands[i]}"
        i=$((i + 1))
        sleep 2
    done | whiptail --title "Auto install" --gauge "Preparing install..." 10 60 0
# array_one=( "Installing nala..." "Installing wego..." )
# array_two=( "echo 'clear22' >> \"$BASEDIR\"/test.txt" "echo 'clear2332' >> \"$BASEDIR\"/test.txt" )
# progress \
#   "${#array_one[@]}" "${array_one[@]}" \
#   "${#array_two[@]}" "${array_two[@]}"   
}

autoinstall(){
    msgs=("Installing nala..."
        "Installing wego..."
        "Installing neofetch..."
        "Installing supervisor..."
        "Configurate startup script..."
        )
    commands=("nala_install"
            "wego"
            "neofetch"
            "supervisor"
            "startup"
            )

    n=${#commands[@]}
    i=0
    while [ "$i" -lt "$n" ]; do
        pct=$(( i * 100 / n ))
        echo XXX
        echo $i
        echo "${msgs[i]}"
        echo XXX
        echo "$pct"
        eval "${commands[i]}"
        i=$((i + 1))
        sleep 1
    done | whiptail --title "Auto install" --gauge "Preparing install..." 10 60 0
    menu
}

reboot(){
    sudo reboot
}

shutdown(){
    sudo shutdown -n now
}

edge(){
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list'
    sudo rm microsoft.gpg
    update
    app_install microsoft-edge-stable
    menu
}

neofetch(){
    app_install neofetch
    sudo sed -i 's/disk_display="off"/disk_display="infobar"/' /home/user/.config/neofetch/config.conf
    sudo sed -i 's/memory_display="off"/memory_display="infobar"/' /home/user/.config/neofetch/config.conf
    sudo sed -i 's/cpu_display="off"/cpu_display="infobar"/' /home/user/.config/neofetch/config.conf
    sudo sed -i 's/disk_subtitle="mount"/disk_subtitle="dir"/' /home/user/.config/neofetch/config.conf
    sudo sed -i "s/disk_show=('\/')/disk_show=('\/' '\/dev\/sda3')/" /home/user/.config/neofetch/config.conf
    sudo sed -i 's/de_version="on"/de_version="off"/' /home/user/.config/neofetch/config.conf
    sudo sed -i 's/cpu_temp="off"/cpu_temp="C"/' /home/user/.config/neofetch/config.conf
    sudo sed -i 's/speed_shorthand="off"/speed_shorthand="on"/' /home/user/.config/neofetch/config.conf
    sudo sed -i 's/memory_unit="mib"/memory_unit="gib"/' /home/user/.config/neofetch/config.conf
    sudo sed -i 's/memory_percent="off"/memory_percent="on"/' /home/user/.config/neofetch/config.conf
    sudo sed -i 's/info cols/\# info cols/' /home/user/.config/neofetch/config.conf
    sudo sed -i 's/\# info "Public IP" public_ip/info "Public IP" public_ip/' /home/user/.config/neofetch/config.conf
    sudo sed -i 's/\# info "Local IP" local_ip/info "Local IP" local_ip/' /home/user/.config/neofetch/config.conf
    sudo sed -i 's/\# info "Disk" disk/info "Disk" disk/' /home/user/.config/neofetch/config.conf
    sudo sed -i 's/info "Packages" packages/\# info "Packages" packages/' /home/user/.config/neofetch/config.conf
    menu
}

ascii(){
    clear
    jp2a --output=ascii.txt --colors ascii.jpg --width=100 -v
    cat ascii.txt
    menu
}

lsd(){
    # sudo nala fonts-hack-ttf
    if ! command -v "lsd" &> /dev/null
    then
        wget https://github.com/Peltoche/lsd/releases/download/0.22.0/lsd_0.22.0_amd64.deb
        sudo dpkg -i lsd_0.22.0_amd64.deb
        rm -R lsd_0.22.0_amd64.deb
        if ! grep -Fxq "alias ls='lsd -l'" /home/user/.bashrc
        then
            sudo sed -i "s/\# some more ls aliases/\# some more ls aliases\nalias ls='lsd -l'/" /home/user/.bashrc
        fi
    fi

    FILE=/home/user/.config/lsd
    if test -f "$FILE"/config.yaml;
    then
        echo "$FILE exists."
        read -p "config.yaml file is exist, remove the file?? " -n 1 -r
        echo    # (optional) move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            sudo rm -r "$FILE"/config.yaml
        else
            return
        fi
    fi

    if ! test -d "$FILE";
    then
        mkdir "$FILE"
    fi

    cp "$BASEDIR"/LSD_config.yaml "$FILE"/config.yaml

    if [ ! -d /home/user/.local/share/fonts/ ];
    then
        mkdir -p /home/user/.local/share/fonts
    fi

    if [ ! -f /home/user/.local/share/fonts/Hack\ Regular\ Nerd\ Font\ Complete.ttf ];
    then
        mkdir -p /home/user/.local/share/fonts
        wget https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf
        mv Hack\ Regular\ Nerd\ Font\ Complete.ttf /home/user/.local/share/fonts/Hack\ Regular\ Nerd\ Font\ Complete.ttf
        fc-cache -fv
        echo "done!"
    else
        read -p "Do you want reinstall and refresh all fonts?? " -n 1 -r
        echo    # (optional) move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            wget https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf
            mv Hack\ Regular\ Nerd\ Font\ Complete.ttf /home/user/.local/share/fonts/Hack\ Regular\ Nerd\ Font\ Complete.ttf
            fc-cache -fv
            echo "done!"
        fi
    fi

    #cd /home/user/.local/share/fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf
    menu

}

_update(){
    echo "Update packages"
    if command -v "nala" &> /dev/null
    then
        sudo nala update
    else
        sudp apt update
    fi
    menu
}
makesomething(){
    echo "start"
    echo 'clear' > "$BASEDIR"/test.txt
    echo "done"
}
menu(){
    OPTION=$(whiptail --title "Matteo ubuntu installer tool" --menu "Choose your option" 25 85 16 \
    "1" "Auto install (nala, wego, neofetch, startup setup, supervisor, upgrade)" \
    "2" "Install nala" \
    "3" "Install wego (terminal weather)" \
    "4" "Install Supervisor" \
    "5" "Install DE Microsoft Edge" \
    "6" "Install neofetch" \
    "7" "Install lolcat (colored text)" \
    "8" "Install figlet (ascii art text)" \
    "9" "Install ncdu (disk usage viewer)" \
    "10" "Install ranger (Console File Manager with VI Key Bindings)" \
    "11" "Install bpytop (Resource monitor)" \
    "12" "Install lsd (File manager)" \
    "13" "Create a startup file (neofetch and wego)" \
    "14" "Update and upgrade" \
    "15" "Update" \
    3>&1 1>&2 2>&3)

    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case $OPTION in
            1) autoinstall;;
            2) nala_install;;
            3) wego;;
            4) supervisor;;
            5) edge;;
            6) neofetch;;
            7) app_install lolcat;;
            8) app_install figlet;;
            9) app_install ncdu;;
            10) app_install ranger;;
            11) app_install bpytop;;
            12) lsd;;
            13) startup;;
            14) update_upgrade;;
            15) _update;;
        esac
    else
        clear
    fi
}

dialog_install
menu