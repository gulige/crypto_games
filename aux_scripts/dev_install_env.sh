#!/bin/sh

OTP_VER=21.1
ERLIN_VER=3.10.4

echo "####################################################################"
echo "crypto_games server environment setting up (on CentOS 6)......"
echo "####################################################################"

echo "####################################################################"
echo "1) Installing Erlang......"
echo "####################################################################"

cd /opt/
if [ ! -f otp_src_${OTP_VER}.tar.gz ]; then
  echo "####################################################################"
  echo "downloading otp_src_${OTP_VER}......"
  echo "####################################################################"
  wget http://www.erlang.org/download/otp_src_${OTP_VER}.tar.gz
fi

tar -zxvf otp_src_${OTP_VER}.tar.gz
cd otp_src_${OTP_VER}

echo "####################################################################"
echo "setting up otp build environment......"
echo "####################################################################"
yum -y install kernel-devel ncurses-devel
yum -y install openssl openssl-devel
yum -y install unixODBC unixODBC-devel
yum -y install m4 make gcc gcc-c++

echo "####################################################################"
echo "building and installing otp......"
echo "####################################################################"
./configure --prefix=/usr/local/erlang --enable-hipe --enable-threads --enable-smp-support --enable-kernel-poll --enable-native-libs --with-ssl
make && make install

rm -f /usr/bin/erl_call
ln -s /usr/local/erlang/lib/erlang/lib/erl_interface-${ERLIN_VER}/bin/erl_call /usr/bin/erl_call

echo "####################################################################"
echo "setting up environment vars......"
echo "####################################################################"
echo "
ERL_HOME=/usr/local/erlang
PATH=\$ERL_HOME/bin:\$PATH
export ERL_HOME PATH
" >> /etc/profile
. /etc/profile


echo "#############################D-O-N-E################################"