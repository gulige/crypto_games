%%%--------------------------------------
%%% @Module  : lib_tick
%%% @Description: tick相关处理
%%%--------------------------------------
-module(lib_tick).

-export([start_tick_workers/0, start_one_tick_worker/2, do_game/2]).

-include("common.hrl").

start_tick_workers() ->
    case chain_eos:get_table(<<"eat.chicken">>, <<"eat.chicken">>, <<"games">>, <<"game_id">>, 0, -1) of
        [] -> void;
        L -> void
    end.

start_one_tick_worker(Game, GameId) ->
    {ok, _} = supervisor:start_child(cg_gatesvr_tick_sup, [Game, GameId]),
    ?INFO("tick worker started for game: ~s, game_id=~p~n", [Game, GameId]),
    ok.

do_game(Game, GameId) ->
    ?DBG("processing tick for game ~s, game_id=~p...~n", [Game, GameId]),
    try
        GameIdBin = integer_to_binary(GameId),
        case chain_eos:call_contract(
                <<"eat.chicken">>,
                <<"tick">>,
                <<"[ \"eat.chicken\", ", GameIdBin/binary, " ]">>,
                <<"eat.chicken">>) of
            {error, Res} ->
                stop;
            _ ->
                continue
        end
    catch
        throw:ThrownErr ->
            ThrownErr;
        _:ExceptionErr ->
            ?ERR("tick exception:~nerr_msg=~p~nstack=~p~n", [ExceptionErr, erlang:get_stacktrace()]),
            {exception, ?T2B(ExceptionErr)}
    end.
