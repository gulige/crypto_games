%%%--------------------------------------
%%% @Module  : cg_gatesvr
%%% @Description: 游戏网关服
%%%--------------------------------------
-module(cg_gatesvr).
-behaviour(gen_server).

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%%开启网关服
%%Port:端口
start_link(Port) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [Port], []).

init([Port]) ->
    Dispatch = cowboy_router:compile([{'_', [
            {"/api", cg_gatesvr_cb, []},
            {"/", cowboy_static, {file, <<"../priv/eat_chicken/index.html">>}},
            {"/[...]", cowboy_static, {dir, <<"../priv/eat_chicken">>}}
        ]}
    ]),

    %{ok, _} = cowboy:start_tls(https_listener, [
    %    {port, Port},
    %    {cacertfile, "../priv/ssl/cryptogames-ca.crt"},
    %    {certfile, "../priv/ssl/server.crt"},
    %    {keyfile, "../priv/ssl/server.key"}
    %], #{env => #{dispatch => Dispatch}}),
    {ok, _} = cowboy:start_clear(http_listener, [{port, Port}], #{env => #{dispatch => Dispatch}}),

    Dispatch2 = cowboy_router:compile([{'_', [
            {"/", cowboy_static, {file, <<"../priv/web/html/index.html">>}},
            {"/[...]", cowboy_static, {dir, <<"../priv/web">>}}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http_listener2, [{port, Port+1}], #{env => #{dispatch => Dispatch2}}),

    {ok, true}.

handle_cast(_Rec, Status) ->
    {noreply, Status}.

handle_call(_Rec, _FROM, Status) ->
    {reply, ok, Status}.

handle_info(_Info, Status) ->
    {noreply, Status}.

terminate(normal, Status) ->
    {ok, Status}.

code_change(_OldVsn, Status, _Extra) ->
    {ok, Status}.
