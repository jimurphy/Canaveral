#!
# Simple setup script for Tangle client.
# Please place this in Tangle client src directory.
clear
echo " $(tput setaf 3)"
echo "   ___  ___  __  __  ___  __ __  ____ ____   ___  __   ";
echo "  //   // \\ ||\ || // \\ || || ||    || \\ // \\ ||   ";
echo " ((    ||=|| ||\\|| ||=|| \\ // ||==  ||_// ||=|| ||   ";
echo "  \\__ || || || \|| || ||  \V/  ||___ || \\ || || ||__|";
echo "                                                       ";
echo "$(tput setaf 2)"
echo "See https://github.com/jimurphy/Canaveral for more info"
echo "$(tput sgr 0)"

cd ~/Canaveral/canaveral_chuck

echo "Launching the chuck OSC server in 3... 2... 1..."
chuck canaveral_chuck.ck