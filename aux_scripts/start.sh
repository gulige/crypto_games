#!/bin/sh
cd ../ebin
echo "starting server......"
erl -hidden +P 1024000 +K true -smp -name gate10000@127.0.0.1 -setcookie crypto_games_1 -boot start_sasl -config 10000 -s cg gatesvr_start -extra 127.0.0.1 52919 10000
