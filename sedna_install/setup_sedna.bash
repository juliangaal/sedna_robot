#!/bin/bash
# This scripts initializes the catkin workspace and runs a rosinstall file to install 
# sick_tim, uos_tools, pico_flexx_drivers, volksbot driver and more. Also see:

echo ""
echo "Complete ros setup"
cd $HOME

echo ""
echo "Set correct hostname for connect.rc script to work"
host=$(hostname)
if [[ $host != *"funky.uos.de"* ]]; then
  sudo hostname $host.funky.uos.de
fi

echo ""
echo "Install wstool and use it to start .rosinstall process"
sudo apt install python-wstool
mkdir -p ~/sedna_ws
cd ~/sedna_ws

echo ""
echo "Pulling .rosinstall script"
# Pull rosinstall file and executes it
wstool init src https://raw.githubusercontent.com/juliangaal/sedna_robot/kinetic/sedna_install/sedna.rosinstall
wstool update -t src 

echo ""
echo "Copying the libroyale SDK to the pico_flexx_driver:"
# Installation instructions can be found at github.com/juliangaal/pico_flexx_driver
cd ~/sedna_ws/src/pico_flexx_driver/royale
cp ~/Downloads/libroyale.zip .
unzip libroyale.zip
# Needs to be hardcoded (for now)
unzip 20*_royale_*.zip
unzip libroyale-*-LINUX-x86-64Bit.zip
rm *.zip
rm *.exe

echo ""
echo "Setting up USB details"
sudo cp libroyale-*-LINUX-x86-64Bit/driver/udev/10-royale-ubuntu.rules /etc/udev/rules.d
sudo cp ~/sedna_ws/src/sick_tim/udev/81-sick-tim3xx.rules /etc/udev/rules.d
sudo cp ~/sedna_ws/src/phidgets_drivers/phidgets_api/share/udev/99-phidgets.rules /etc/udev/rules.d

echo ""
echo "catkin_make to apply changes"
cd ~/sedna_ws/
source /opt/ros/kinetic/setup.bash
catkin_make

echo ""
echo "Setup bashrc to include devel/setup.bash and ceres.rc"
bashrc_file="$HOME/.bashrc"

if ! grep -q 'sedna.rc' "${bashrc_file}" ; then
  echo 'export SEDNA_WORKSPACE="/home/robot/sedna_ws"' >> ~/.bashrc
  echo '. ${SEDNA_WORKSPACE}/src/sedna_robot/sedna_install/sedna.rc' >> ~/.bashrc
fi

if ! grep -q 'devel/setup.bash' "${bashrc_file}"; then 
  echo 'source ${SEDNA_WORKSPACE}/devel/setup.bash' >> ~/.bashrc
fi
#echo 'export SEDNA_WORKSPACE="sedna_ws"' >> ~/.bashrc
#echo '. ${SEDNA_WORKSPACE}/src/sedna_robot/sedna_install/sedna.rc' >> ~/.bashrc
#echo '' >> ~/.bashrc
#echo 'source ~/${SEDNA_WORKSPACE}/devel/setup.bash' >> ~/.bashrc
source ~/.bashrc

echo ""
echo "Completed! Rebooting in"
echo "3"
sleep 1
echo "2"
sleep 1
echo "1"
sleep 1
sudo reboot

