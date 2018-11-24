%%%-----------------------------------
%%% @Module  : cg_gatesvr_app
%%% @Description: 打包程序
%%%-----------------------------------
-module(cg_gatesvr_app).
-behaviour(application).

-export([start/2, stop/1]).

-include("common.hrl").

start(_Type, _Args) ->
    lib_global_data:init(),
    [Ip, Port, ServerId] = init:get_plain_arguments(),
    {ok, SupPid} = cg_gatesvr_sup:start_link([Ip, list_to_integer(Port), list_to_integer(ServerId)]),
    try
        ok = start_tick_sup()
    catch
        _:Err ->
            ?ERR("server starting error=~p, stack=~p~n", [Err, erlang:get_stacktrace()]),
            throw(server_starting_error)
    end,
    ?INFO("server ready.~n", []),
    {ok, SupPid}.

stop(_State) ->
    void.

start_tick_sup() ->
    {ok, _} = supervisor:start_child(
                cg_gatesvr_sup,
                {cg_gatesvr_tick_sup,
                {cg_gatesvr_tick_sup, start_link, []},
                permanent, 10000, supervisor, [cg_gatesvr_tick_sup]}),
    lib_tick:start_tick_workers(<<"eat_chicken">>),
    ok.
