return {

    debug = false,

    useQBCore = true,

    policeAccess = false, -- allow Police to access without a key?
    policeJob = 'police', -- name of your Police job

    requireKeycard = true, -- use an item to enter the moneywash building.
        keycardItem = 'moneywash_key', 

    itemRequired = true, -- use an item to use the machines
        ticketItem = 'moneywash_token',

    laundromatLocations = { -- supports only one location at a time, randomises every script restart
        vector3(1142.34, -986.67, 46.17), -- Mirror Park
        vector3(84.47, -1552.26, 29.66), -- Strawberry
    },

    blip = {
        enabled = true,
        label = 'Laundromat',
        sprite = 77,
        spriteColor = 3,
        scale = 0.9,
    },

    washing = {
        duration = 10000, -- time to wash money (same no matter what amount)
        taxRate = 0.10, -- removes 10% of total money put in
        markedMoney = 'markedbills', -- item put into the washer
        cleanMoney = 'money',
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
        iconColor = '#76A9D2',
    },

    targetExit = {
        label = 'Exit Laundromat',
        icon = 'fa-solid fa-door-open',
        iconColor = '#76A9D2',
    },

    targetWash = {
        label = 'Wash Money',
        coords = vec3(1122.4954, -3193.2864, -40.3926),
        icon = 'fa-solid fa-money-bill',
        iconColor = '#76A9D2',
    },

    targetCount = {
        label = 'Dry & Count Money',
        coords = vector3(1116.36, -3194.58, -39.92),
        icon = 'fa-solid fa-money-bill',
        iconColor = '#76A9D2',
    },
    
}
