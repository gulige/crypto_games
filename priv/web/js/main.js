function ping()
{
    var who = document.getElementById("who").value;

    if(who == "")
    {
        alert("Please input ping target");
    }
    else
    {
        $.get("/ping?who=" + who, function(data){
            $("#message").html(data);
        });
    }
}

function create_account()
{
    var newAccount = document.getElementById("create_account_name").value;

    if (newAccount == "") {
        alert("Please input account name to create");
    } else {
        creatorAccount = "eosio" //主账号
        newAccountPubkey = "EOS7wMezX9vY2wLz2DQLiJXCq9Kk7ei24PaEKhR6gJFewS32zTLKC" //新账号的公钥
    
        // 构建transaction对象
        eos.transaction(tr => {
            // 新建账号
            tr.newaccount({
                creator: creatorAccount,
                name: newAccount,
                owner: newAccountPubkey,
                active: newAccountPubkey
            })
    
            // 为新账号充值RAM
            tr.buyrambytes({
                payer: creatorAccount,
                receiver: newAccount,
                bytes: 8192
            })
    
            // 为新账号抵押CPU和NET资源
            tr.delegatebw({
                from: creatorAccount,
                receiver: newAccount,
                stake_net_quantity: '1.0000 EOS',
                stake_cpu_quantity: '1.0000 EOS',
                transfer: 0
            })
        })
    }
}

var socket = io("http://114.115.135.201:52919");

socket.on("connect", function () {
    socket.on("message", function (msg) {
        
    });
});


Eos = require('eosjs')

config = {
    keyProvider: ['5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3'], // 配置私钥字符串
    httpEndpoint: 'http://114.115.135.201:8888', // EOS开发链url与端口
    chainId: "cf057bbfb72640471fd910bcb67639c22df9f92470936cddc1ade0e2f2e7dc4f", // 通过cleos get info可以获取chainId
    mockTransactions: () => null, // 如果要广播，需要设为null
    transactionHeaders: (expireInSeconds, callback) => {
        callback(null/*error*/, headers) // 手动设置交易记录头，该方法中的callback回调函数每次交易都会被调用
    },
    expireInSeconds: 60,
    broadcast: true,
    debug: false,
    sign: true,
    authorization: null // 该参数用于在多签名情况下，识别签名帐号与权限，格式如：account@permission
}

eos = Eos(config)

