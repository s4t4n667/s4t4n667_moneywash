return {

    debug = false,

    useQBCore = true,

    policeAccess = true, -- allow Police to access without a key?
    policeJob = {'police', 'sheriff'}, -- name of your Police jobs

    laundromatLocations = { -- supports only one location at a time, randomises every script restart
        vector3(1142.34, -986.67, 46.17), -- Mirror Park
        vector3(84.47, -1552.26, 29.66), -- Strawberry
    },

    entry = {
        requireKey = true, -- use an item to enter the moneywash building.
        keyItem = 'moneywash_key',
        removeKey = false, -- remove key upon entry?
        hideTargetWithoutKey = false, -- only show target option to those with a key?
    },

    washing = {
        itemRequired = true, -- have to have an item to use the machines
        ticketItem = 'moneywash_token', -- item needed to wash
        minAmount = '10000', -- minimum amount to wash, if you don't want a minimum, set it very high
        duration = 10000, -- time to wash money = 10s (same time no matter what amount)
        taxRate = 0.10, -- removes 10% of total money put in
        markedMoney = 'black_money', -- item put into the washer
        wetMoney = 'wet_bills', -- item that must be dried and counted
        cleanMoney = 'money', -- item given after money is dried and counted
    },

    shop = {
        enabled = true,
        coords = vector4(1129.6237, -988.6730, 45.9730, 116.6544),
        pedModel = 'u_m_m_streetart_01',
        currency = 'black_money',
        items = {
            { label = 'Moneywash Key', item = 'moneywash_key', icon = 'fa-key',  price = 10 },
            { label = 'Moneywash Token', item = 'moneywash_token', icon = 'fa-coins', iconColor = '', price = 10 },
        },        
    },

    blip = {
        enabled = true,
        label = 'Laundromat',
        sprite = 77,
        spriteColor = 3,
        scale = 0.9,
    },

    notifications = {
        position = 'top',
        generalColor = '',
        failColor = '#c41b1e',
        successColor = '#51A231',
    },

    loading = {
        duration = 5000,
        animation = 'e mechanic4'
    },

    drying = {
        duration = 10000,
        animation = 'e mechanic2'
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
        coords = vec3(1122.2819, -3194.0934, -40.3986),
        icon = 'fa-solid fa-money-bill',
        iconColor = '',
        distance = 2.0,
    },

    targetCount = {
        label = 'Dry & Count Money',
        coords = vector3(1116.36, -3194.58, -39.92),
        icon = 'fa-solid fa-money-bill',
        iconColor = '',
        distance = 1.5,
    },
    
}
