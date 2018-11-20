echo "stopping servers......"
erl_call -a 'cg gatesvr_stop' -name gate10000@127.0.0.1 -c crypto_games_1
sleep 2
ps -ef | grep "beam" | grep -v grep
