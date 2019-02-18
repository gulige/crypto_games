%%%------------------------------------------------
%%% File    : common.hrl
%%% Description: 公共定义
%%%------------------------------------------------

% use lager log system: debug, info, notice, warning, error, critical, alert, emergency
-ifdef(debug).
    -define(DEBUG(F, A), lager:debug(F, A)).
    -define(DBG(Str, Args), lager:info(Str, Args)).
    -define(DBGS(Str), lager:info(Str)).
-else.
    -define(DEBUG(F, A), ok).
    -define(DBG(Str, Args), ok).
    -define(DBGS(Str), ok).
-endif.
-define(INFO(F, A), lager:info(F, A)).
-define(ERR(F, A), lager:error(F, A)).

% 环境
-define(ENV_DEV, dev).
-define(ENV_BETA, beta).
-define(ENV_PROD, prod).

-define(SVRTYPE_GATE, 1).

%%DETS（注意，dets有2GB限制！）
-define(DETS_GLOBAL_RUN_DATA, dets_global_run_data).

-define(ETSRC, {read_concurrency, true}).
-define(ETSWC, {write_concurrency, true}).

-define(B2T(B), util:bitstring_to_term(B)).
-define(T2B(T), util:term_to_bitstring(T)).
-define(T2B_P(T), util:term_to_bitstring_p(T)).

% 用正则式过滤掉进程id，否则无法通过erl_parse
-define(S2T(S), util:string_to_term(re:replace(S, "<[0-9]+\.[0-9]+\.[0-9]+>", "undefined", [global, {return,list}]))).
-define(T2S(T), util:term_to_string(T)).

% 特定的几个错误码定义
-define(ERRNO_IP_BLOCKED, -999). % ip受限
-define(ERRNO_MISSING_PARAM, -998). % 参数不全
-define(ERRNO_WRONG_PARAM, -997). % 参数错误
-define(ERRNO_VERIFY_FAILED, -996). % 校验失败
-define(ERRNO_ACTION_NOT_SUPPORT, -995). % 协议不支持
-define(ERRNO_EXCEPTION, -994). % 异常抛出
-define(ERRNO_HTTP_REQ_FAILED, -993). % 请求失败
-define(ERRNO_HTTP_REQ_TIMEOUT, -992). % 请求超时
-define(ERRNO_HTTP_REQ_SERVER_LOGIC, -991). % 服务器逻辑返回错误
-define(ERRNO_UNIDENTIFIED, -990). % 未确定的错误


