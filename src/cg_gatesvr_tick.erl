%%%------------------------------------
%%% @Module  : cg_gatesvr_tick
%%% @Description: tick进程
%%%------------------------------------
-module(cg_gatesvr_tick).
-behaviour(gen_server).

-export([start_link/2]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("common.hrl").

-define(PROCESS_INTERVAL, 30 * 1000).

-record(status, {
    game = <<>>,
    game_id = 0
}).

start_link(Game, GameId) ->
    GameIdBin = integer_to_binary(GameId),
    WorkerName = binary_to_atom(<<"cg_gatesvr_tick_worker_", Game/binary, "_", GameIdBin/binary>>, utf8),
    gen_server:start_link({local, WorkerName}, ?MODULE, [Game, GameId], []).

init([Game, GameId]) ->
    process_flag(trap_exit, true),
    erlang:send_after(?PROCESS_INTERVAL, self(), to_process),
    {ok, #status{game = Game, game_id = GameId}}.

handle_cast(_R, Status) ->
    {noreply, Status}.

handle_call(_R, _FROM, Status) ->
    {reply, ok, Status}.

handle_info(to_process, #status{game = Game, game_id = GameId} = Status) ->
    case catch lib_tick:do_game(Game, GameId) of
        stop ->
            ?DBG("game ~s(~s) terminating...~n", [Game, GameId]),
            {stop, normal, Status};
        _ ->
            erlang:send_after(?PROCESS_INTERVAL, self(), to_process),
            {noreply, Status}
    end;

handle_info(_Info, Status) ->
    {noreply, Status}.

terminate(_Reason, #status{game = Game, game_id = GameId} = Status) ->
    ?DBG("game ~s(~s) terminated~n", [Game, GameId]),
    {ok, Status}.

code_change(_OldVsn, Status, _Extra) ->
    {ok, Status}.

