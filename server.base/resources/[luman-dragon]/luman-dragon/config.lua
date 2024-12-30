COMPANIONS = {
    -- Dragon with Static Tail
    {
        -- BASE CONFIG:
        command = 'dragon', -- Command to spawn dragon
        invincible = true, -- Is dragon invincible
        adminOnly = false, -- Is restricted by ace permissions
        blipName = "Dragon",

        -- SYSTEM CONFIG:
        pedModel = 'a_c_hawk_01',
        pedScale = 10.0,
        showPed = false,
        customCamera = {
            enabled = true,
            distance = 20.5,
        },
        -- attachments = {},
        attachments = {
            -- Left wing
            {
                position = {
                    0.8, 0.1, -0.1
                },
                rotation = {
                    90.0,
                    -5.0,
                    21.9589,
                },
                bone = 'skel_l_upperarm',
                model = 'rdr2_dragon_wing_l',
            },

            -- Right wing
            {
                position = {
                    0.8, 0.1, 0.1
                },
                rotation = {
                    -90.0,
                    -5.0,
                    201.95,
                },
                bone = 'skel_r_upperarm',
                model = 'rdr2_dragon_wing_r',
            },

            -- Body
            {
                position = {
                    0.21, 0.1, 0.0
                },
                rotation = {
                    90.0, 
                    -90.0, 
                    0.0
                },
                bone = 'skel_spine0',
                model = 'rdr2_dragon_body',
            },

            -- Head
            {
                position = {
                    0.19, 0.09, 0.0
                },
                rotation = {
                    135.0, -90.0, 0.0
                },
                bone = 'skel_neck0',
                model = 'rdr2_dragon_head',
            },

            -- Left Leg
            {
                position = {
                    -0.01, 0.01, 0.0
                },
                rotation = {
                    0.0, -90.0, 0.0
                },
                bone = 'skel_l_foot',
                model = 'rdr2_dragon_leg_l',
            },

            -- Right Leg
            {
                position = {
                    -0.01, 0.01, 0.0
                },
                rotation = {
                    0.0, -90.0, 0.0
                },
                bone = 'skel_r_foot',
                model = 'rdr2_dragon_leg_r',
            },

            -- TAIL
            {
                position = {
                    -0.27, 0.12, 0.0
                },
                rotation = {
                    90.0, -90.0, 0.0
                },
                bone = 'skel_spine0',
                model = 'rdr2_dragon_tail',
            },
        },
    },

    -- Dragon with Dynamic Tail
    {
        -- BASE CONFIG:
        command = 'dragon2', -- Command to spawn dragon
        invincible = true, -- Is dragon invincible
        adminOnly = false, -- Is restricted by ace permissions
        blipName = "Dragon",

        -- SYSTEM CONFIG:
        pedModel = 'a_c_hawk_01',
        pedScale = 10.0,
        showPed = false,
        customCamera = {
            enabled = true,
            distance = 20.5,
        },
        -- attachments = {},
        attachments = {
            -- Left wing
            {
                position = {
                    0.8, 0.1, -0.1
                },
                rotation = {
                    90.0,
                    -5.0,
                    21.9589,
                },
                bone = 'skel_l_upperarm',
                model = 'rdr2_dragon_wing_l',
            },

            -- Right wing
            {
                position = {
                    0.8, 0.1, 0.1
                },
                rotation = {
                    -90.0,
                    -5.0,
                    201.95,
                },
                bone = 'skel_r_upperarm',
                model = 'rdr2_dragon_wing_r',
            },

            -- Body
            {
                position = {
                    0.21, 0.1, 0.0
                },
                rotation = {
                    90.0, 
                    -90.0, 
                    0.0
                },
                bone = 'skel_spine0',
                model = 'rdr2_dragon_body',
            },

            -- Head
            {
                position = {
                    0.19, 0.09, 0.0
                },
                rotation = {
                    135.0, -90.0, 0.0
                },
                bone = 'skel_neck0',
                model = 'rdr2_dragon_head',
            },

            -- Left Leg
            {
                position = {
                    -0.01, 0.01, 0.0
                },
                rotation = {
                    0.0, -90.0, 0.0
                },
                bone = 'skel_l_foot',
                model = 'rdr2_dragon_leg_l',
            },

            -- Right Leg
            {
                position = {
                    -0.01, 0.01, 0.0
                },
                rotation = {
                    0.0, -90.0, 0.0
                },
                bone = 'skel_r_foot',
                model = 'rdr2_dragon_leg_r',
            },

            -- Tail
            {
                position = {
                    -0.2, 0.05, 0.0
                },
                rotation = {
                    90.0, -90.0, 0.0
                },
                bone = 'skel_pelvis',
                model = 'rdr2_dragon_tail',
            },
        },
    },

    -- Cat
    {
        -- BASE CONFIG:
        command = 'cat', -- Command to spawn cat
        invincible = true, -- Is cat invincible
        adminOnly = false, -- Is restricted by ace permissions
        blipName = "Cat",

        -- SYSTEM CONFIG:
        pedModel = 'a_c_cat_01',
        pedScale = 3.0,
        showPed = true,
        customCamera = {
            enabled = false,
            distance = 10.5,
        },
        attachments = {},
    },
}
