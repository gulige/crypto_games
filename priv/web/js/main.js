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
    var newAccountPubKey = document.getElementById("create_account_pubkey").value; //新账号的公钥

    if (newAccount == "") {
        alert("Please input account name to create");
    } else {
        creatorAccount = "eosio" //主账号

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
            $("#message_create_account").html(JSON.stringify(resp));
        }).catch(err => {
            $("#message_create_account").html(JSON.stringify(err));
        });
    }
}

function create_game()
{
    var creatorName = document.getElementById("creator_name").value;
    var joinEos = document.getElementById("join_eos").value;

    if (creatorName == "") {
        alert("Please input creator name");
    } else {
        eos.transaction(
            {
                actions: [
                    {
                        account: 'eosio.token',
                        name: 'transfer',
                        authorization: [{
                            actor: creatorName,
                            permission: 'active'
                        }],
                        data: {
                            from: creatorName,
                            to: 'eat.chicken',
                            quantity: joinEos,
                            memo: ''
                        }
                    }
                ]
            }
        ).then((resp) => {
            $("#message_create_game").html(JSON.stringify(resp));
        }).catch(err => {
            $("#message_create_game").html(JSON.stringify(err));
        });
    }
}

function game_info()
{
    var gameIdStr = document.getElementById("game_id").value;
    if (gameIdStr == "") {
        alert("Please input game id");
    } else {
        var gameId = parseInt(gameIdStr);
        if (gameId >= 0) {
            eos.getTableRows(
                {
                    json: true,
                    scope: "eat.chicken",
                    code: "eat.chicken",
                    table: "games",
                    limit:1,
                    lower_bound: gameId,
                    upper_bound: gameId + 1
                }
            ).then((resp) => {
                $("#message_game_info").html(JSON.stringify(resp));
            }).catch(err => {
                $("#message_game_info").html(JSON.stringify(err));
            });
        } else {
            eos.getTableRows(
                {
                    json: true,
                    scope: "eat.chicken",
                    code: "eat.chicken",
                    table: "games"
                }
            ).then((resp) => {
                $("#message_game_info").html(JSON.stringify(resp));
            }).catch(err => {
                $("#message_game_info").html(JSON.stringify(err));
            });
        }
    }
}

function set_map()
{
    var gameIdStr = document.getElementById("set_game_id").value;
    if (gameIdStr == "") {
        alert("Please input game id");
    } else {
        var gameId = parseInt(gameIdStr);
        $.get("/api?a=setmap&game_id=" + gameIdStr, function(data){
            $("#message_set_map").html(data);
        });
    }
}

function join_game()
{
    var joinerName = document.getElementById("joiner_name").value;
    var joinXStr = document.getElementById("join_x").value;
    var joinYStr = document.getElementById("join_y").value;
    var transferEos = document.getElementById("transfer_eos").value;
    var gameIdStr = document.getElementById("join_game_id").value;

    if (joinerName == "") {
        alert("Please input joiner name");
        return;
    }

    if (gameIdStr == "") {
        alert("Please input game id");
        return;
    }

    var gameId = parseInt(gameIdStr);
    var joinX = parseInt(joinXStr);
    var joinY = parseInt(joinYStr);

    eos.transaction(
        {
            actions: [
                {
                    account: 'eosio.token',
                    name: 'transfer',
                    authorization: [{
                        actor: joinerName,
                        permission: 'active'
                    }],
                    data: {
                        from: joinerName,
                        to: 'eat.chicken',
                        quantity: transferEos,
                        memo: gameIdStr + ',' + joinXStr + ',' + joinYStr
                    }
                }
            ]
        }
    ).then((resp) => {
        $("#message_join_game").html(JSON.stringify(resp));
    }).catch(err => {
        $("#message_join_game").html(JSON.stringify(err));
    });
}

function kick_off()
{
    var requesterName = document.getElementById("kick_requester_name").value;
    var gameIdStr = document.getElementById("kick_game_id").value;

    if (requesterName == "") {
        alert("Please input requester name");
        return;
    }

    if (gameIdStr == "") {
        alert("Please input game id");
        return;
    }

    var gameId = parseInt(gameIdStr);

    eos.transaction(
        {
            actions: [
                {
                    account: 'eat.chicken',
                    name: 'kickoff',
                    authorization: [{
                        actor: requesterName,
                        permission: 'active'
                    }],
                    data: {
                        who: requesterName,
                        game_id: gameId
                    }
                }
            ]
        }
    ).then((resp) => {
        $("#message_kick_off").html(JSON.stringify(resp));
    }).catch(err => {
        $("#message_kick_off").html(JSON.stringify(err));
    });
}

function move()
{
    var requesterName = document.getElementById("move_requester_name").value;
    var gameIdStr = document.getElementById("move_game_id").value;
    var moveXStr = document.getElementById("move_x").value;
    var moveYStr = document.getElementById("move_y").value;

    if (requesterName == "") {
        alert("Please input requester name");
        return;
    }

    if (gameIdStr == "") {
        alert("Please input game id");
        return;
    }

    var gameId = parseInt(gameIdStr);
    var moveX = parseInt(moveXStr);
    var moveY = parseInt(moveYStr);

    eos.transaction(
        {
            actions: [
                {
                    account: 'eat.chicken',
                    name: 'move',
                    authorization: [{
                        actor: requesterName,
                        permission: 'active'
                    }],
                    data: {
                        who: requesterName,
                        game_id: gameId,
                        row: moveX,
                        column: moveY
                    }
                }
            ]
        }
    ).then((resp) => {
        $("#message_move").html(JSON.stringify(resp));
    }).catch(err => {
        $("#message_move").html(JSON.stringify(err));
    });
}

var socket = io("http://114.115.135.201:52920");

socket.on("connect", function () {
    socket.on("message", function (msg) {
        
    });
});

chain = {
    main: 'aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906', // main network
    jungle: 'e70aaab8997e1dfce58fbfac80cbbb8fecec7b99cf982a9444273cbc64c41473', // jungle testnet2
    dev: 'cf057bbfb72640471fd910bcb67639c22df9f92470936cddc1ade0e2f2e7dc4f' // local developer
}

config = {
    keyProvider: ['5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3', // eosio
                  '5KRF8dr2fvHx9dVQyBqWwYhs7KvT8UdCb8Fy6hpWqHp6yZ1K6T3' // player1, player2
                ], // 配置私钥字符串
    httpEndpoint: 'http://114.115.135.201:8888', // EOS开发链url与端口
    chainId: chain.dev, // 通过cleos get info可以获取chainId
    //httpEndpoint: 'https://jungle2.cryptolions.io:443',
    //chainId: chain.jungle,
    expireInSeconds: 60,
    broadcast: true,
    debug: false,
    sign: true
}

eos = Eos(config)

