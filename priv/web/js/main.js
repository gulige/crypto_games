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
        }).then((resp) => {
            $("#message_create_account_name").html(resp);
        });
    }
}

var socket = io("http://114.115.135.201:52919");

socket.on("connect", function () {
    socket.on("message", function (msg) {
        
    });
});

chain = {
    main: 'aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906', // main network
    jungle: '038f4b0fc8ff18a4f0842a8f0564611f6e96e8535901dd45e43ac8691a1c4dca', // jungle testnet
    dev: 'cf057bbfb72640471fd910bcb67639c22df9f92470936cddc1ade0e2f2e7dc4f' // local developer
}

config = {
    keyProvider: ['5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3'], // 配置私钥字符串
    httpEndpoint: 'http://114.115.135.201:8888', // EOS开发链url与端口
    chainId: chain.dev, // 通过cleos get info可以获取chainId
    expireInSeconds: 60,
    broadcast: true,
    debug: false,
    sign: true
}

eos = Eos(config)

