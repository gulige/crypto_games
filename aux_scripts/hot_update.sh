#!/bin/sh

echo "####################################################################"
echo "getting source code......"
echo "####################################################################"
dir0=`pwd`
cd ..
git pull
cd $dir0

echo "####################################################################"
echo "compiling source code......"
echo "####################################################################"
./safe_make_no_nif.sh

echo "####################################################################"
echo "hot updating......"
echo "####################################################################"
erl_call -a 'u u' -name gate10000@127.0.0.1 -c crypto_games_1
