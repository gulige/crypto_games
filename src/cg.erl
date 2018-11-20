%%%--------------------------------------
%%% @Module  : cg
%%% @Description:  crypto games服务器开启
%%%--------------------------------------
-module(cg).
-export([gatesvr_start/0, gatesvr_stop/0]).
-export([info/0, topN_bin/1]).
-export([env/0]).

-define(GATESVR_APPS, [sasl, gatesvr, ibrowse]).

-include("common.hrl").


%% 获取环境
%% 据此区分不同的逻辑分支，如下：
%% case bg:env() of
%%     ?ENV_DEV -> ...
%%     ?ENV_PROD -> ...
%%     _ -> ...
%% end
env() ->
    case application:get_env(gatesvr, env) of
        {ok, Env} -> Env;
        undefined -> ?ENV_PROD
    end.

%%启动网关服
gatesvr_start() ->
    try
        ok = application:start(crypto),
        % ssl
        ok = application:start(asn1),
        ok = application:start(public_key),
        ok = application:start(ssl),
        % ssl-end
        ok = lager:start(),
        ok = application:start(ranch),
        ok = application:start(cowlib),
        ok = application:start(cowboy),
        ok = start_applications(?GATESVR_APPS),
        {ok, _} = recon_web:start()
    after
        timer:sleep(100)
    end.

%%停止网关服
gatesvr_stop() ->
    try
        cowboy:stop_listener(https_listener), % 停止监听
        timer:sleep(5000),
        ok = stop_applications(?GATESVR_APPS)
    after
        init:stop() % 能停掉heart
    end.

info() ->
    SchedId      = erlang:system_info(scheduler_id),
    SchedNum     = erlang:system_info(schedulers),
    ProcCount    = erlang:system_info(process_count),
    ProcLimit    = erlang:system_info(process_limit),
    ProcMemUsed  = erlang:memory(processes_used),
    ProcMemAlloc = erlang:memory(processes),
    MemTotal     = erlang:memory(total),
    ?INFO( "erlang node sys info:
                       ~n   Scheduler id:                         ~p
                       ~n   Num scheduler:                        ~p
                       ~n   Process count:                        ~p
                       ~n   Process limit:                        ~p
                       ~n   Memory used by erlang processes:      ~p
                       ~n   Memory allocated by erlang processes: ~p
                       ~n   The total amount of memory allocated: ~p
                       ~n",
                            [SchedId, SchedNum, ProcCount, ProcLimit,
                             ProcMemUsed, ProcMemAlloc, MemTotal]),
      ok.

%% 查找前N个binary内存占用大户
topN_bin(N)->
        [{M, P, process_info(P, [registered_name, initial_call, current_function, dictionary]), B} ||
        {P, M, B} <- lists:sublist(lists:reverse(lists:keysort(2,processes_sorted_by_binary())),N)].
 
processes_sorted_by_binary()->
     [case process_info(P, binary) of
              {_, Bins} ->
                 SortedBins = lists:usort(Bins),
                 {_, Sizes, _} = lists:unzip3(SortedBins),
                 {P, lists:sum(Sizes), []};
              _ ->
                {P, 0, []}
         end ||P <- processes()].

%%############辅助调用函数##############
manage_applications(Iterate, Do, Undo, SkipError, ErrorTag, Apps) ->
    Iterate(fun (App, Acc) ->
                    case Do(App) of
                        ok -> [App | Acc];%合拢
                        {error, {SkipError, _}} -> Acc;
                        {error, Reason} ->
                            [Undo(One) || One <- Acc],
                            throw({error, {ErrorTag, App, Reason}})
                    end
            end, [], Apps),
    ok.

start_applications(Apps) ->
    manage_applications(fun lists:foldl/3,
                        fun application:start/1,
                        fun application:stop/1,
                        already_started,
                        cannot_start_application,
                        Apps).

stop_applications(Apps) ->
    manage_applications(fun lists:foldr/3,
                        fun application:stop/1,
                        fun application:start/1,
                        not_started,
                        cannot_stop_application,
                        Apps).
