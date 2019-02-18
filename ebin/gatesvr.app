{
    application, gatesvr,
    [
        {description, "This is cg gate server."},
        {vsn, "1.0a"},
        {modules,
        [
            cg_gatesvr_app,
            cg_gatesvr_sup
        ]},
        {registered, [cg_gatesvr_sup]},
        {applications, [kernel, stdlib, sasl]},
        {mod, {cg_gatesvr_app, []}},
        {start_phases, []},
        {env, [
                {env, dev}
                %{env, beta}
                %{env, prod}
            ]}
    ]
}.
