%%%-----------------------------------
%%% @Module  : cg_gatesvr_sup
%%% @Description: 监控树
%%%-----------------------------------
-module(cg_gatesvr_sup).
-behaviour(supervisor).

-export([start_link/1]).
-export([init/1]).

-include("common.hrl").

start_link([Ip, Port, ServerId]) ->
    supervisor:start_link({local,?MODULE}, ?MODULE, [Ip, Port, ServerId]).

init([Ip, Port, ServerId]) ->
    Children =
        [
            {
                cg_gatesvr,
                {cg_gatesvr, start_link, [Port]},
                permanent,
                10000,
                supervisor,
                [cg_gatesvr]
            }
        ],

    {ok,
        {
            {one_for_one, 10, 10},
            Children
        }
    }.
