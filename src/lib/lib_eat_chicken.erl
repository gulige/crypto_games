%%%--------------------------------------
%%% @Module  : lib_eat_chicken
%%% @Description: eat_chicken辅助模块
%%%--------------------------------------

-module(lib_eat_chicken).
-compile(export_all).

-include("common.hrl").

-define(BOARD_SIZE, 11 * 11).

set_map(GameId) ->
    GameIdBin = integer_to_binary(GameId),
    {Items, DropTicks} = gen_map(),
    ItemsBin = jiffy:encode(Items),
    DropTicksBin = jiffy:encode(DropTicks),
    Account = get_account(),
    chain_eos:call_contract(
        Account,
        <<"setmap">>,
        <<"[ \"", Account/binary, "\", ", GameIdBin/binary, ", ", ItemsBin/binary, ", ", DropTicksBin/binary, " ]">>,
        Account).

% 生成地图，实际上就是随机生成道具分布
% 0.   无
% 1.   地雷（触发）玩家进入本格子掉4生命。
% 2.   武器空投（触发），当有玩家进入本格，两分钟后有超级步枪或者三级防具投入本格。
% 3.   手枪+3攻击。（普通枪械）
% 4.   步枪+4攻击。（普通枪械）
% 5.   超级步枪+6攻击。（高级枪械）
% 6.   一级防具+2生命。（普通防具）
% 7.   二级防具+4生命。（普通防具）
% 8.   三级防具+6生命。（高级防具）
% 9.   决斗卡（特殊道具），发生战斗时自动使用，决斗直到一方死亡。
% 10.  复活卡（特殊道具），如果死亡自动触发，所有物品消失4血复活。
% 11.  药箱（资源）+2生命。
% 12.  急救箱（资源）+4生命。
% 13.  空投的eos
% 14.  黄金矿点
gen_map() ->
    DropEosPos = util:rand(1, ?BOARD_SIZE),
    MineEosPosL = util:rand_m_in_n(lists:seq(1, ?BOARD_SIZE) -- [DropEosPos], 20),
    DropItems = [5, 8],
    NonDropItems = lists:seq(0, 12) -- DropItems,
    L = [case I of
             DropEosPos -> {13, -1};
             _ ->
                 case lists:member(I, MineEosPosL) of
                     true -> {14, 0};
                     false ->
                         case util:rand_one(NonDropItems) of
                             2 -> {util:rand_one(DropItems), 2 * 60 div 30};
                             R -> {R, 0}
                         end
                 end
         end || I <- lists:seq(1, ?BOARD_SIZE)],
    lists:unzip(L).

start_tick_workers() ->
    do_start_tick_workers(0).

do_start_tick_workers(FromGameId) ->
    Account = get_account(),
    case chain_eos:get_table(Account, Account, <<"games">>, <<"game_id">>, FromGameId, -1) of
        {[], _} -> void;
        {L, More} ->
            [lib_tick:start_one_tick_worker(<<"eat_chicken">>, GameId) ||
               #{<<"game_id">> := GameId, <<"game_progress">> := Progress} <- L,
               Progress =:= 1 orelse Progress =:= 2 orelse Progress =:= 3],
            case More of
                false -> void;
                true ->
                    MaxGameId = lists:max([GameId || #{<<"game_id">> := GameId} <- L]),
                    do_start_tick_workers(MaxGameId + 1)
            end
    end.

do_tick(GameId) ->
    GameIdBin = integer_to_binary(GameId),
    Account = get_account(),
    chain_eos:call_contract(
        Account,
        <<"tick">>,
        <<"[ \"", Account/binary, "\", ", GameIdBin/binary, " ]">>,
        Account).

get_account() ->
    case cg:env() of
        ?ENV_DEV -> <<"eat.chicken">>;
        _ -> <<"eat1chicken2">>
    end.

