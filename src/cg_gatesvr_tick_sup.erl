%%%-------------------------------------------------------------------
%% @doc cg_gatesvr tick supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(cg_gatesvr_tick_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    {ok, { {simple_one_for_one, 3, 10},
           [{cg_gatesvr_tick,
             {cg_gatesvr_tick, start_link, []},
             transient,
             10000,
             worker,
             [cg_gatesvr_tick]}]}}.

%%====================================================================
%% Internal functions
%%====================================================================
