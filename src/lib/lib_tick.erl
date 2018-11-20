%%%--------------------------------------
%%% @Module  : lib_tick
%%% @Description: tick相关处理
%%%--------------------------------------
-module(lib_tick).

-export([start_one_tick_worker/2, do_game/2]).

-include("common.hrl").

% lib_tick:start_one_tick_worker(<<"eat_chicken">>, 1).
start_one_tick_worker(Game, GameId) ->
    {ok, _} = supervisor:start_child(cg_gatesvr_tick_sup, [Game, GameId]),
    ?INFO("tick worker started for game: ~s, game_id=~p~n", [Game, GameId]),
    ok.

do_game(Game, GameId) ->
    ?DBG("processing tick for game ~s, game_id=~p...~n", [Game, GameId]),
    try
        ok
    catch
        throw:ThrownErr ->
            ThrownErr;
        _:ExceptionErr ->
            ?ERR("tick exception:~nerr_msg=~p~nstack=~p~n", [ExceptionErr, erlang:get_stacktrace()]),
            {exception, ?T2B(ExceptionErr)}
    end.
