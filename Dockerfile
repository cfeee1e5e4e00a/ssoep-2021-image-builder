FROM scratch

# ADD root.tar.xz /
# ADD boot.tar.xz /boot

# SHELL ["/bin/bash", "-c"]
# ARG DEBIAN_FRONTEND=noninteractive
# # ARG package="makedeb"

# # RUN apt-get update && apt-get full-upgrade -y && apt-get install build-essential wget curl jq gpg git ssh sudo python3 python3-pip zsh htop mc -y
# # RUN sed -i "s/buster/bullseye/g" /etc/apt/sources.list && sed -i "s/buster/bullseye/g" /etc/apt/sources.list.d/raspi.list
# RUN apt-get update && apt-get full-upgrade -y && apt-get install build-essential wget curl jq gpg git ssh sudo python3 python3-pip zsh htop mc cmake doxygen libsystemd-dev libglib2.0-dev -y


# RUN wget -qO - 'https://proget.hunterwittenborn.com/debian-feeds/makedeb.pub' | gpg --dearmor | tee /usr/share/keyrings/makedeb-archive-keyring.gpg &> /dev/null && \
#     echo 'deb [signed-by=/usr/share/keyrings/makedeb-archive-keyring.gpg arch=all] https://proget.hunterwittenborn.com/ makedeb main' | tee /etc/apt/sources.list.d/makedeb.list && \
#     apt-get update && apt-get install "makedeb" -y
# # TODO: change compile flags
# RUN sed -i 's/CARCH/#CARCH/g; s/CHOST/#CHOST/g; s/x86-64/armv7/g; s/ -mtune=generic//g; s/ -fcf-protection//g; 5iMAKEFLAGS="j13"' /etc/makepkg.conf 

# ADD packages /home/pi/packages
# RUN chown -R pi:pi /home/pi/packages && su -l -c /home/pi/packages/install pi

ADD alarm.tar.gz /
ENV MAKEFLAGS="-j12"
RUN pacman-key --init && pacman-key --populate archlinuxarm
RUN sed -i '1iServer = http://de.mirror.archlinuxarm.org/$arch/$repo' /etc/pacman.d/mirrorlist && pacman -Syyu --noconfirm && pacman -S --noconfirm base-devel mc htop zsh networkmanager python wget sudo git python-pip python-gobject
RUN sed -i '5iMAKEFLAGS="j13"' /etc/makepkg.conf 
RUN useradd -m -U -G wheel pi && echo $'root:root\npi:pi' | chpasswd && chsh -s /bin/zsh pi && su -l -c ' wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh && sh install.sh --unattended && sed -i "s/robbyrussell/dstufft/" ~/.zshrc' pi
RUN sed -i '1i%wheel ALL=(ALL) NOPASSWD: ALL' /etc/sudoers
RUN systemctl enable sshd && systemctl enable NetworkManager
RUN CFLAGS=-fcommon pip install rpi_ws281x adafruit-circuitpython-neopixel dbus-python RPi.GPIO
# todo: fix bluetooth

ADD repo-key /home/pi/.ssh/id_rsa
RUN chown -R pi:pi /home/pi/.ssh && su -l -c 'touch ~/.ssh/known_hosts && ssh-keyscan github.com >> ~/.ssh/known_hosts' pi

ADD packages /home/pi/packages
RUN pacman -Sy && chown -R pi:pi /home/pi/packages && su -l -c /home/pi/packages/install pi
RUN systemctl enable cppuni && systemctl enable bluetooth && rm -rvf /home/pi/.ssh $$ rm /.dockerenv
RUN ln -sf /usr/share/zoneinfo/Asia/Novosibirsk /etc/localtime
RUN sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen && echo "LANG=en_US.UTF-8" > /etc/locale.conf && sed -i '$ s/$/ audit=0/' /boot/cmdline.txt && sed -i -e '$ahdmi_force_hotplug=1\ndtparam=krnbt=on' /boot/config.txt