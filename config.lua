return {

    debug = false,                          -- print debug info to the console
    framework = 'auto',                     -- 'auto', 'qbox', 'qbcore' or 'esx'

    laundromatLocations = {
        vector3(1142.34, -986.67, 46.17),         -- Mirror Park
        vector3(84.2931, -1552.0133, 29.5979),    -- Strawberry
    },

    blip = {
        enabled = true,
        label = 'Laundromat',
        sprite = 77,
        spriteColor = 3,
        scale = 0.9,
    },

    entry = {
        requireKey = true,                        -- require an item to enter the building
        keyItem = 'moneywash_key',                -- item used as the key
        removeKey = false,                        -- remove the key on entry
        hideTargetWithoutKey = false,             -- only show the entry target to players holding a key
        keylessJobs = { 'police', 'sheriff' },    -- jobs that can enter without a key ({} = nobody)
        keylessGangs = { 'ballas' },              -- gangs that can enter without a key, e.g. { 'ballas', 'vagos' }
    },

    washing = {
        itemRequired = true,                -- require a token to use the machines
        ticketItem = 'moneywash_token',     -- token consumed per wash
        minAmount = 10000,                  -- minimum amount per wash (set to 1 for no minimum)
        durationMode = 'flat',              -- 'flat' = same time for any amount, 'perAmount' = scales with amount
        durationFlat = 10000,               -- flat: wash time in ms
        perAmount = {                       -- perAmount: wash time = (amount / per) * time, clamped to min/max
            time = 1000,                    -- ms added... 
            per = 1000,                     -- ...for every this much money (1000 = 1s per $1,000)
            min = 5000,                     -- shortest wash in ms
            max = 60000,                    -- longest wash in ms
        },
        taxRate = 0.10,                     -- cut taken from the washed amount (0.10 = 10%)
        markedMoney = 'black_money',        -- item put into the washer
        wetMoney = 'wet_bills',             -- item received after washing, must be dried
        cleanMoney = 'money',               -- item received after drying
    },

    shop = {
        enabled = true,
        coords = vector4(1129.6237, -988.6730, 45.9730, 116.6544),
        pedModel = 'u_m_m_streetart_01',
        currency = 'black_money',           -- item used to pay
        items = {
            { label = 'Moneywash Key',   item = 'moneywash_key',   icon = 'fa-key',   iconColor = '', price = 10 },
            { label = 'Moneywash Token', item = 'moneywash_token', icon = 'fa-coins', iconColor = '', price = 10 },
        },
    },

    loading = {                             -- loading money into the washer
        duration = 5000,                    -- ms
        animation = 'e mechanic4',          -- emote command
    },

    drying = {                              -- drying & counting wet bills
        duration = 10000,                   -- ms
        animation = 'e mechanic2',          -- emote command
    },

    ------ STYLE PREFERENCES ------

    notifications = {
        position = 'top',
        generalColor = '',
        failColor = '#c41b1e',
        successColor = '#51A231',
    },

    targetEntry = {
        label = 'Enter Laundromat',
        icon = 'fa-solid fa-soap',
        iconColor = '',
        distance = 1.5,
    },

    targetExit = {
        label = 'Exit Laundromat',
        icon = 'fa-solid fa-door-open',
        iconColor = '',
        distance = 2.0,
    },

    targetWash = {
        label = 'Wash Money',
        coords = vector3(1122.2819, -3194.0934, -40.3986),
        icon = 'fa-solid fa-money-bill',
        iconColor = '',
        distance = 2.0,
    },

    targetCount = {
        label = 'Dry & Count Money',
        coords = vector3(1116.16, -3194.98, -40.42),
        icon = 'fa-solid fa-money-bill',
        iconColor = '',
        distance = 1.5,
    },

}
