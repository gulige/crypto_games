%%%--------------------------------------
%%% @Module  : chain_eos
%%% @Description: EOS链的访问接口
%%%--------------------------------------
-module(chain_eos).
-compile(export_all).

-export([get_balance/2,
         make_tx/4,
         sign_tx/2,
         send_tx/1,
         get_latest_block_id/0,
         get_block/1,
         get_tx/1,
         import_priv_key/1,
         call_contract/4,
         get_table/6,
         now/0]).

-include("common.hrl").

-define(CHAIN, <<"eos">>).
-define(SYMBOL, <<"eos">>).
-define(FACTOR, 1).

-define(WALLET_NAME, <<"game">>).
-define(ACCOUNT_NAME, <<"bitgame12345">>).

-define(HTTP_REQUEST_TIMEOUT, 60000 * 10).
-define(JSON_CONTENT, {"Content-Type", "application/json; charset=utf8"}).

-define(TX_EXPIRED_SECONDS, 300).
-define(DEFAULT_TX_EXPIRED_SECONDS, 120).


%% ！！部署节点时需要执行
wallet_create() ->
    {ok, _} = http_request(<<"wallet/create">>, ?WALLET_NAME).

wallet_open() ->
    {ok, _} = http_request(<<"wallet/open">>, ?WALLET_NAME).

wallet_passphrase() ->
    Passphrase = case cg:env() of
        ?ENV_PROD -> <<>>;
        _ -> <<"PW5JHzYhe4XnkGdZhj4uWDgxKiNRVKeXZ6b19BnPYRx6rySHZMEVq">>
    end,
    case http_request(<<"wallet/unlock">>, [?WALLET_NAME, Passphrase]) of
        {ok, _} -> ok;
        {error, ?ERRNO_HTTP_REQ_SERVER_LOGIC, #{<<"code">> := 3120007, <<"what">> := <<"Already unlocked">>}} -> ok
    end.

make_sure_usable() ->
    wallet_open(),
    wallet_passphrase(),
    ok.

get_balance(?SYMBOL, _Addr) ->
    case http_request(<<"chain/get_currency_balance">>, [{code, <<"eosio.token">>}, {account, ?ACCOUNT_NAME}, {symbol, <<"EOS">>}], true) of
        {ok, []} -> 0;
        {ok, [EosBin]} ->
            {Balance, <<"eos">>} = get_amount_and_symbol(EosBin),
            Balance
    end;
get_balance(_Symbol, _Addr) ->
    0.

-ifdef(use_rpc).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 如果定义了use_rpc，则使用rpc接口来转账

make_tx0(ToAddr, Data) ->
    {MegaSecs, Secs, MicroSecs} = os:timestamp(),
    {ok, #{<<"last_irreversible_block_num">> := BlockNum}} = http_request(<<"chain/get_info">>, [], true),
    {ok, #{<<"ref_block_prefix">> := RefBlockPrefix}} = http_request(<<"chain/get_block">>, [{block_num_or_id, BlockNum}], true),
    {[
        {<<"ref_block_num">>, BlockNum},
        {<<"ref_block_prefix">>, RefBlockPrefix},
        {<<"expiration">>, util:timestamp_to_utc_string({MegaSecs, Secs + ?TX_EXPIRED_SECONDS, MicroSecs})},
        {<<"scope">>, [?ACCOUNT_NAME, ToAddr]},
        {<<"actions">>, [
            {[
                {<<"account">>, <<"eosio.token">>}, % code -> account
                {<<"name">>, <<"transfer">>}, % type -> name
                {<<"recipients">>, [?ACCOUNT_NAME, ToAddr]},
                {<<"authorization">>, [
                    {[
                        {<<"actor">>, ?ACCOUNT_NAME}, % account -> actor
                        {<<"permission">>, <<"active">>}
                    ]}
                ]},
                {<<"data">>, Data}
            ]}
        ]},
        {<<"signatures">>, []},
        {<<"authorizations">>, []}
    ]}.

make_tx1(
    {[
        {<<"ref_block_num">>, BlockNum},
        {<<"ref_block_prefix">>, RefBlockPrefix},
        {<<"expiration">>, Expiration},
        {<<"scope">>, Scope},
        {<<"actions">>, [
            {[
                {<<"account">>, Code},
                {<<"name">>, Type},
                {<<"recipients">>, _Recipients},
                {<<"authorization">>, Authorization},
                {<<"data">>, Data}
            ]}
        ]},
        {<<"signatures">>, []},
        {<<"authorizations">>, []}
    ]} = Tx0, RequiredKeys) ->
    [
     {[
        {<<"ref_block_num">>, BlockNum},
        {<<"ref_block_prefix">>, RefBlockPrefix},
        {<<"expiration">>, Expiration},
        {<<"scope">>, Scope},
        {<<"read_scope">>, []},
        {<<"messages">>, [
            {[
                {<<"code">>, Code},
                {<<"type">>, Type},
                {<<"authorization">>, Authorization},
                {<<"data">>, Data}
            ]}
        ]},
        {<<"signatures">>, []}
      ]},
     RequiredKeys,
     <<"aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906">>].

make_tx(?SYMBOL, ToAddr0, [{_FromAddr, Amount}], Gas) ->
    [ToAddr, Memo] = binary:split(ToAddr0, <<"__">>),
    Quantity = util:round10d(Amount - Gas) * ?FACTOR,
    QuantityBin = float_to_binary(Quantity, [{decimals, 4}]),
    EosBin = <<QuantityBin/binary, " EOS">>,
    {ok, #{<<"binargs">> := BinArgs}} =
        http_request(<<"chain/abi_json_to_bin">>, [{code, <<"eosio.token">>},
                                                   {action, <<"transfer">>},
                                                   {args, {[{from, ?ACCOUNT_NAME},
                                                            {to, ToAddr},
                                                            {quantity, EosBin},
                                                            {memo, Memo}
                                                           ]}}], true),
    Tx0 = make_tx0(ToAddr, BinArgs),
    put(tx0, Tx0),
    {ok, #{<<"required_keys">> := RequiredKeys}} =
        http_request(<<"chain/get_required_keys">>, {[{transaction, Tx0},
                                                      {available_keys, [<<"EOS53EU641XG3hTaCBp7TE51fm2cLSrBFdNKvPDaGZ5C4DDryNhM3">>]}]}, true),
    Tx1 = make_tx1(Tx0, RequiredKeys),
    jiffy:encode(Tx1);
make_tx(_Symbol, _ToAddr, _AddrToDeltaAmountPairs, _Gas) ->
    <<>>.

sign_tx(_Addr, JsonTx) ->
    Tx = jiffy:decode(JsonTx),
    {ok, SignedTx0} = http_request(<<"wallet/sign_transaction">>, Tx),
    % todo: packed_trx - the bytes of a transaction without padding, expressed in little endian binary, prefixed by the size in bytes as a 32 bit little endian integer
    PackedTx = <<>>,
    SignedTx = SignedTx0#{<<"compression">> => <<"none">>,
                          <<"transaction">> => get(tx0),
                          <<"packed_context_free_data">> => [],
                          <<"packed_trx">> => PackedTx},
    jiffy:encode(SignedTx).

send_tx(JsonSignedTx) ->
    SignedTx = jiffy:decode(JsonSignedTx),
    {ok, #{<<"transaction_id">> := Hash}} = http_request(<<"chain/push_transaction">>, SignedTx, true),
    Hash.

-else.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 否则，使用os:cmd()执行本地操作系统命令的方式来转账

make_tx(?SYMBOL, ToAddr0, [{_FromAddr, Amount}], Gas) ->
    [ToAddr, Memo] = binary:split(ToAddr0, <<"__">>),
    Quantity = util:round10d(Amount - Gas) * ?FACTOR,
    QuantityBin = float_to_binary(Quantity, [{decimals, 4}]),
    EosBin = <<QuantityBin/binary, " EOS">>,
    <<"cleos --wallet-url http://127.0.0.1:8900 transfer ", (?ACCOUNT_NAME)/binary, " ", ToAddr/binary, " '", EosBin/binary, "' ", Memo/binary>>;
make_tx(_Symbol, _ToAddr, _AddrToDeltaAmountPairs, _Gas) ->
    <<>>.

sign_tx(_Addr, TxCmdBin) ->
    Res = os:cmd(binary_to_list(TxCmdBin)),
    case string:tokens(Res, " ") of
        ["executed", "transaction:", TxId | _] ->
            list_to_binary(TxId);
        [_, Code | _] when Code =:= "3120002:"; Code =:= "3120003:"; Code =:= "3120004:" ->
            make_sure_usable(),
            sign_tx(_Addr, TxCmdBin)
    end.

send_tx(SignedTx) ->
    SignedTx.

-endif.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 转账逻辑结束

get_latest_block_id() ->
    {ok, #{<<"head_block_id">> := Hash}} = http_request(<<"chain/get_info">>, [], true),
    Hash.

% 说明：参数可以是id，也可以是高度
get_block(BlockId) ->
    {ok, #{<<"block_num">> := Height, <<"transactions">> := TxList, <<"previous">> := PrevBlockId}} =
        http_request(<<"chain/get_block">>, [{block_num_or_id, BlockId}], true),
    TxIds = [case Tx of
                 #{<<"id">> := TxId} -> TxId;
                 TxId -> TxId
             end || #{<<"trx">> := Tx} <- TxList],
    {ok, #{<<"last_irreversible_block_num">> := IrreversibleHeight}} =
        http_request(<<"chain/get_info">>, [], true),
    % 根据块号连续的前提，来确定确认数和后继区块
    Confirmations = case Height =< IrreversibleHeight of
                        true -> IrreversibleHeight - Height + 1;
                        false -> 0 % 首先要不可逆转，不满足时都为0
                    end,
    NextBlockId =
        case http_request(<<"chain/get_block">>, [{block_num_or_id, Height + 1}], true) of
            {ok, #{<<"block_num">> := NextHeight, <<"id">> := NextBlockId_}} ->
                NextHeight = Height + 1,
                NextBlockId_;
            _ -> undefined
        end,
    {Height, TxIds, PrevBlockId, NextBlockId, Confirmations}.

% 说明：nodeos启动时，已经使用--filter-on "eosio.token:transfer:"
get_tx(TxId) ->
    case http_request(<<"history/get_transaction">>, [{id, TxId}], true) of
        {ok, #{<<"trx">> := #{<<"trx">> := #{<<"actions">> := Actions}},
               <<"block_num">> := Height,
               <<"last_irreversible_block">> := IrreversibleHeight}} ->
            case [{F, T, M, A} || #{<<"account">> := <<"eosio.token">>,
                                    <<"name">> := <<"transfer">>,
                                    <<"data">> := #{<<"from">> := F,
                                                    <<"to">> := T,
                                                    <<"memo">> := M,
                                                    <<"quantity">> := A}} <- Actions] of
                [] ->
                    tx_type_we_dont_care;
                [{FromAddr, ToAddr0, Memo, Amount0}] -> % 暂认为只能包含1个transfer
                    case get_amount_and_symbol(Amount0) of
                        unsupported_symbol ->
                            symbol_we_dont_care;
                        {Amount, Symbol} ->
                            Gas = 0, % EOS没有gas费
                            ToAddr = <<ToAddr0/binary, "__", Memo/binary>>,
                            Confirmations = case Height =< IrreversibleHeight of
                                                true -> IrreversibleHeight - Height + 1;
                                                false -> 0 % 首先要不可逆转，不满足时都为0
                                            end,
                            {[FromAddr], [ToAddr], Symbol, [Amount / ?FACTOR], Gas / ?FACTOR, Confirmations}
                    end
            end;
        {ok, #{} = M} ->
            case maps:size(M) =:= 0 of
                true -> undefined;
                false -> tx_type_we_dont_care
            end
    end.

get_amount_and_symbol(Amount0) ->
    [Amount, Symbol] = binary:split(Amount0, <<" ">>),
    case Symbol of
        <<"EOS">> -> {util:binary_to_float(Amount), ?SYMBOL};
        _ -> unsupported_symbol
    end.

import_priv_key(PrivKey) ->
    {ok, _} = http_request(<<"wallet/import_key">>, [?WALLET_NAME, PrivKey]).

get_new_key() ->
    % key type: R1 curve (iPhone), K1 curve (Bitcoin)
    {ok, PubKey} = http_request(<<"wallet/create_key">>, [?WALLET_NAME, <<"K1">>]),
    PubKey.

call_contract(Contract, Action, Args, Executor) ->
    {ok, CfgList} = application:get_env(gatesvr, jsonrpc_eos),
    {_, Url} = lists:keyfind(rpchost_pub, 1, CfgList),
    CmdBin = <<"cleos --url ", Url/binary, " --wallet-url http://127.0.0.1:8900 push action ", Contract/binary, " ", Action/binary, " '", Args/binary, "' -p ", Executor/binary>>,
    ?DBG("call_contract: cmd=~s~n", [CmdBin]),
    Parent = self(),
    {Pid, Mref} = spawn_monitor(fun() -> Parent ! {self(), os:cmd(binary_to_list(CmdBin))} end),
    receive
        {'DOWN', Mref, process, Pid, Reason} ->
            ?INFO("call_contract error: ~p~ntry again...~n", [Reason]),
            call_contract(Contract, Action, Args, Executor);
        {Pid, Res} ->
            case string:tokens(Res, " ") of
                ["executed", "transaction:", TxId | _] ->
                    list_to_binary(TxId);
                [_, Code | _] when Code =:= "3120002:"; Code =:= "3120003:"; Code =:= "3120004:"; Code =:= "3120006:" ->
                    make_sure_usable(),
                    call_contract(Contract, Action, Args, Executor);
                [_, Code | _] when Code =:= "3040005:" -> % expired transaction
                    ?INFO("call_contract error: ~p~ntry again...~n", [Res]),
                    call_contract(Contract, Action, Args, Executor);
                [_, Code | _] when Code =:= "3080006:" -> % transaction took too long
                    ?INFO("call_contract error: ~p~ntry again...~n", [Res]),
                    call_contract(Contract, Action, Args, Executor);
                [_, Code | _] when Code =:= "3200002:" -> % invalid http response
                    ?INFO("call_contract error: ~p~ntry again...~n", [Res]),
                    call_contract(Contract, Action, Args, Executor);
                [_, Code | _] when Code =:= "3040008:" -> % duplicate transaction
                    ?INFO("call_contract error: ~p~ntry again...~n", [Res]),
                    call_contract(Contract, Action, Args, Executor);
                [_, Code | _] when Code =:= "3081001:" -> % transaction reached the deadline set due to leeway on account CPU limits
                    % the transaction was unable to complete by deadline, but it is possible it could have succeeded if it were allowed to run to completion
                    ?INFO("call_contract error: ~p~ncontinue...~n", [Res]),
                    continue;
                [_, Code | _] ->
                    {error, Res}
            end
    after 20000 ->
        exit(Pid, timeout),
        ?INFO("call_contract error: timeout~ntry again...~n", []),
        call_contract(Contract, Action, Args, Executor)
    end.

get_table(Contract, Executor, Table, Key, Lower, Limit) ->
    LowerBin = integer_to_binary(Lower),
    {LimitBin, UpperBin} =
        case Limit < 0 of
            true -> {<<"-1">>, <<"-1">>};
            false -> {integer_to_binary(Limit), integer_to_binary(Lower + Limit)}
        end,
    {ok, CfgList} = application:get_env(gatesvr, jsonrpc_eos),
    {_, Url} = lists:keyfind(rpchost_pub, 1, CfgList),
    CmdBin = <<"cleos --url ", Url/binary, " get table ", Contract/binary, " ", Executor/binary, " ", Table/binary, " -k ", Key/binary, " -L ", LowerBin/binary, " -U ", UpperBin/binary, " -l ", LimitBin/binary>>,
    ?DBG("get_table: cmd=~s~n", [CmdBin]),
    Res = os:cmd(binary_to_list(CmdBin)),
    #{<<"rows">> := Rows, <<"more">> := More} = jiffy:decode(unicode:characters_to_binary(Res,utf8), [return_maps]),
    {Rows, More}.

now() ->
    {ok, #{<<"head_block_time">> := TimeBin}} = http_request(<<"chain/get_info">>, [], true),
    {M, S, _} = lib_time:datetime_string_to_timestamp(binary_to_list(TimeBin)),
    M * 1000000 + S.

get_http_url(IsPub) ->
    {ok, CfgList} = application:get_env(gatesvr, jsonrpc_eos),
    case IsPub of
        true ->
            {_, Url} = lists:keyfind(rpchost_pub, 1, CfgList);
        false ->
            {_, Url} = lists:keyfind(rpchost, 1, CfgList)
    end,
    <<Url/binary, "/v1/">>.

http_request(ParamsUrl) ->
    http_request(ParamsUrl, [], false).

http_request(ParamsUrl, Params) ->
    http_request(ParamsUrl, Params, false).

http_request(ParamsUrl, Params, IsPub) ->
    case http_request_(ParamsUrl, Params, IsPub) of
        {error, ?ERRNO_HTTP_REQ_SERVER_LOGIC, #{<<"code">> := 3120002, <<"name">> := <<"wallet_nonexistent_exception">>}} -> % closed
            make_sure_usable(),
            http_request_(ParamsUrl, Params, IsPub);
        {error, ?ERRNO_HTTP_REQ_SERVER_LOGIC, #{<<"code">> := 3120003, <<"name">> := <<"wallet_locked_exception">>}} -> % locked
            make_sure_usable(),
            http_request_(ParamsUrl, Params, IsPub);
        {error, ?ERRNO_HTTP_REQ_SERVER_LOGIC, #{<<"code">> := 3120004, <<"name">> := <<"wallet_missing_pub_key_exception">>}} ->
            make_sure_usable(),
            http_request_(ParamsUrl, Params, IsPub);
        Res -> Res
    end.

http_request_(ParamsUrl, Params, IsPub) ->
    UrlPrefix = get_http_url(IsPub),
    Url = <<UrlPrefix/binary, ParamsUrl/binary>>,
    JsonParams = case Params of
                     [] -> [];
                     [{_,_}|_] -> jiffy:encode({Params});
                     _ -> jiffy:encode(Params)
                 end,
    %?DBG("Url: ~p, Params: ~p~n", [Url, JsonParams]),
    case ibrowse:send_req(binary_to_list(Url), [?JSON_CONTENT], post, JsonParams, [], ?HTTP_REQUEST_TIMEOUT) of
        {ok, Status, _Head, Body} ->
            case Status of
                _ when Status =:= "200"; Status =:= "201" -> % 成功
                    JsonObject = jiffy:decode(Body, [return_maps]),
                    ?DBG("JsonObject: ~p~n", [JsonObject]),
                    {ok, JsonObject};
                "500" ->  % 失败
                    JsonObject = jiffy:decode(Body, [return_maps]),
                    ?DBG("JsonObject: ~p~n", [JsonObject]),
                    {error, ?ERRNO_HTTP_REQ_SERVER_LOGIC, maps:get(<<"error">>, JsonObject)};
                _ ->
                    throw({error, ?ERRNO_HTTP_REQ_FAILED, "status="++Status++",body="++Body})
            end;
        {error, req_timedout} ->
            throw({error, ?ERRNO_HTTP_REQ_TIMEOUT, <<"request timeout">>});
        {error, Reason} ->
            throw({error, ?ERRNO_HTTP_REQ_FAILED, Reason})
    end.

