#!/bin/sh


echo "####################################################################"
echo "crypto_games server deploying (on CentOS 6.6)......"
echo "####################################################################"

which git > /dev/null 2>&1
if [ $? != 0 ]; then
    echo "####################################################################"
    echo "git does not exist, installing it......"
    echo "####################################################################"
    yum -y install autoconf
    yum -y install perl-ExtUtils-MakeMaker
    yum -y install tk gettext-devel curl-devel
    wget -O git.zip https://github.com/git/git/archive/master.zip
    unzip git.zip
    cd git-master
    autoconf
    ./configure --prefix=/usr/local
    make && make install
    rm /usr/bin/git
    ln -s /usr/local/bin/git /usr/bin/git
    cd ..
fi

echo "####################################################################"
echo "getting source code......"
echo "####################################################################"
if [ ! -d crypto_games ]; then
    git clone https://gitlab.com/gulige/crypto_games.git
else
    cd crypto_games
    git pull
    cd ..
fi

echo "####################################################################"
echo "stopping crypto_games servers......"
echo "####################################################################"
cd crypto_games/aux_scripts
./stop.sh

echo "####################################################################"
echo "compiling source code......"
echo "####################################################################"
source /etc/profile
./make.sh

echo "####################################################################"
echo "starting crypto_games servers......"
echo "####################################################################"
./start.sh

echo "#############################D-O-N-E################################"
