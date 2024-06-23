#!/bin/bash

sudo sudo apt install nfs-common
sudo mkdir /opt/sclinica
sudo mount 192.168.1.184:/sistema_clinica /opt/sclinica
sudo ln -s /opt/sclinica $HOME/Desktop 