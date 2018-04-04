#!/bin/bash

GNUSTEP_MAKE_VERSION=2.7.0
GNUSTEP_BASE_VERSION=1.25.0
GNUSTEP_GUI_VERSION=0.25.1
GNUSTEP_BACK_VERSION=0.25.1

# Set clang as compiler
export CC=/usr/bin/clang-4.0
export CXX=/usr/bin/clang++-4.0

# Install Requirements
sudo apt update

echo -e "\n\n${GREEN}Installing dependencies...${NC}"

#sudo dpkg --add-architecture i386  # Enable 32-bit repos for libx11-dev:i386
sudo apt-get update
sudo apt -y install cmake libffi-dev libxml2-dev \
libgnutls28-dev libicu-dev libblocksruntime-dev libkqueue-dev libpthread-workqueue-dev autoconf libtool \
libjpeg-dev libtiff-dev libffi-dev libcairo-dev libxt-dev libxft-dev 

sudo apt-get purge gcc clang-3.8 clang++-3.8 gcc-5 -y 
sudo apt-get autoremove -y
 
# Create build directory
mkdir GNUstep-build

#fetch gnustep
wget ftp://ftp.gnustep.org/pub/gnustep/core/gnustep-make-$GNUSTEP_MAKE_VERSION.tar.gz
wget ftp://ftp.gnustep.org/pub/gnustep/core/gnustep-base-$GNUSTEP_BASE_VERSION.tar.gz
wget ftp://ftp.gnustep.org/pub/gnustep/core/gnustep-gui-$GNUSTEP_GUI_VERSION.tar.gz
wget ftp://ftp.gnustep.org/pub/gnustep/core/gnustep-back-$GNUSTEP_BACK_VERSION.tar.gz
#untar sources
tar xf gnustep-make-$GNUSTEP_MAKE_VERSION.tar.gz -C GNUstep-build 
tar xf gnustep-base-$GNUSTEP_BASE_VERSION.tar.gz -C GNUstep-build
tar xf gnustep-gui-$GNUSTEP_GUI_VERSION.tar.gz -C GNUstep-build
tar xf gnustep-back-$GNUSTEP_BACK_VERSION.tar.gz -C GNUstep-build

#change directory
cd GNUstep-build

# Checkout sources
echo -e "\n\n${GREEN}Checking out sources...${NC}"
git clone -b 1.8.1 https://github.com/gnustep/libobjc2.git

# Build libobjc2
echo -e "\n\n"
echo -e "${GREEN}Building libobjc2...${NC}"
cd libobjc2
rm -Rf build
mkdir build && cd build
export CC=clang-4.0;export CXX=clang++-4.0;cmake .. -DLLVM_OPTS=off
make
sudo -E make install
rc=$?
if [[ rc == 0 ]]; then echo -e "Exit error when building libobjc2"; exit; fi
sudo ldconfig


# Build GNUstep make 
echo -e "\n\n"
echo -e "${GREEN}Building GNUstep-make for the second time...${NC}"
cd ../../gnustep-make-$GNUSTEP_MAKE_VERSION
export CC=clang-4.0;export CXX=clang++-4.0;./configure;make;sudo make install
if [[ rc == 0 ]]; then echo -e "Exit error when building gnustep-make"; exit; fi
sudo ldconfig

# Build GNUstep base
echo -e "\n\n"
echo -e "${GREEN}Building GNUstep-base...${NC}"
cd ../gnustep-base-$GNUSTEP_BASE_VERSION
export CC=clang-4.0;export CXX=clang++-4.0;./configure;make;sudo make install
if [[ rc == 0 ]]; then echo -e "Exit error when building gnustep-base"; exit; fi
sudo ldconfig

# Build GNUstep GUI
echo -e "\n\n"
echo -e "${GREEN} Building GNUstep-gui...${NC}"
cd ../gnustep-gui-$GNUSTEP_GUI_VERSION
export CC=clang-4.0;export CXX=clang++-4.0;./configure;make;sudo make install
if [[ rc == 0 ]]; then echo -e "Exit error when building gnustep-gui"; exit; fi

sudo ldconfig

# Build GNUstep back
echo -e "\n\n"
echo -e "${GREEN}Building GNUstep-back...${NC}"
cd ../gnustep-back-$GNUSTEP_BACK_VERSION
export CC=clang-4.0;export CXX=clang++-4.0;./configure;make;sudo make install
if [[ rc == 0 ]]; then echo -e "Exit error when building gnustep-back"; exit; fi
sudo ldconfig

echo -e "${GREEN}Exiting `pwd` and Cleaning...${NC}"
cd ../..
rm gnustep-make-$GNUSTEP_MAKE_VERSION.tar.gz
rm gnustep-base-$GNUSTEP_BASE_VERSION.tar.gz 
rm gnustep-gui-$GNUSTEP_GUI_VERSION.tar.gz 
rm gnustep-back-$GNUSTEP_BACK_VERSION.tar.gz

echo -e "\n\n"
echo -e "${GREEN}Install is done. Open a new terminal to start using.${NC}"
