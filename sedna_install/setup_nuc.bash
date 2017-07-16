#!/bin/bash
# This scripts provides a basic setup for NUCs that are used for ceres robots
# network fix, tmux Also see:

echo ""
echo "Install tmux"
sudo apt-get install tmux

echo ""
echo "Disable network manager"
sudo systemctl disable networking
sudo systemctl stop networking
sudo systemctl restart ssh.service
