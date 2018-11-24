%%%--------------------------------------
%%% @Module  : cg_gatesvr_cb
%%% @Description: gatesvr回调模块
%%%--------------------------------------
-module(cg_gatesvr_cb).
-export([init/2]).

-include("common.hrl").

init(Req, Opts) ->
    Method = cowboy_req:method(Req),
    #{a := Action} = cowboy_req:match_qs([a], Req),
    Req2 =
        try
            {ok, ResMap} = action(Method, Action, Req),
            cowboy_req:reply(200, #{}, lib_http:reply_body_succ(ResMap), Req)
        catch
            throw:{ErrNo, ErrMsg} when is_integer(ErrNo), is_binary(ErrMsg) ->
                ?DBG("cg_gatesvr_cb throw(action=~p):~nerr_msg=~p~nstack=~p~n", [Action, {ErrNo, ErrMsg}, erlang:get_stacktrace()]),
                cowboy_req:reply(200, #{}, lib_http:reply_body_fail(Action, ErrNo, ErrMsg), Req);
            throw:{HttpCode, ErrNo, ErrMsg} when is_integer(HttpCode), is_integer(ErrNo), is_binary(ErrMsg) ->
                ?DBG("cg_gatesvr_cb throw(action=~p):~nerr_msg=~p~nstack=~p~n", [Action, {HttpCode, ErrNo, ErrMsg}, erlang:get_stacktrace()]),
                cowboy_req:reply(HttpCode, #{}, lib_http:reply_body_fail(Action, ErrNo, ErrMsg), Req);
            _:ExceptionErr ->
                ?ERR("cg_gatesvr_cb exception(action=~p):~nerr_msg=~p~nstack=~p~n", [Action, ExceptionErr, erlang:get_stacktrace()]),
                cowboy_req:reply(200, #{}, lib_http:reply_body_fail(Action, ?ERRNO_EXCEPTION, ?T2B(ExceptionErr)), Req)
        end,
    {ok, Req2, Opts}.

action(_, undefined, _Req) ->
    throw({200, ?ERRNO_MISSING_PARAM, <<"Missing parameter">>});

% https://www.eatchicken.com/api/?a=setmap&game_id=xxx
action(<<"GET">>, <<"setmap">> = Action, Req) ->
    ParamsMap = cowboy_req:match_qs([game_id], Req),
    ?DBG("setmap: ~p~n", [ParamsMap]),
    #{game_id := GameIdBin0} = ParamsMap,
    L = [GameIdBin0],
    [GameIdBin] = [util:trim(One) || One <- L],
    case lists:member(<<>>, [GameIdBin]) of
        true -> throw({200, ?ERRNO_MISSING_PARAM, <<"Missing parameter">>});
        false -> void
    end,
    GameId = binary_to_integer(GameIdBin),
    case lib_eat_chicken:set_map(GameId) of
        {error, Res} ->
            throw({200, ?ERRNO_HTTP_REQ_SERVER_LOGIC, ?T2B_P(Res)});
        _ ->
            % start tick
            lib_tick:start_one_tick_worker(<<"eat_chicken">>, GameId),
            {ok, #{}}
    end;

action(_, _Action, _Req) ->
    throw({200, ?ERRNO_ACTION_NOT_SUPPORT, <<"Action not supported">>}).

