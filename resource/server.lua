lib.locale()
local config = lib.require('config')
lib.versionCheck('s4t4n667/s4t4n667_moneywash')

local maxDistance = 5.0
local insideLaundry = {}
local dryingStarted = {}
local activeWash = {}
GlobalState.moneywashLocation = math.random(#config.laundromatLocations)


local function getFramework()
    if config.framework ~= 'auto' then
        return config.framework
    end

    if GetResourceState('qbx_core') == 'started' then return 'qbox' end
    if GetResourceState('qb-core') == 'started' then return 'qbcore' end
    if GetResourceState('es_extended') == 'started' then return 'esx' end
end

local function getJobAndGang(src)
    local framework = getFramework()

    if framework == 'qbox' then
        local player = exports.qbx_core:GetPlayer(src)
        local playerData = player and player.PlayerData
        if not playerData then return end
        return playerData.job and playerData.job.name, playerData.gang and playerData.gang.name
    elseif framework == 'qbcore' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local player = QBCore.Functions.GetPlayer(src)
        local playerData = player and player.PlayerData
        if not playerData then return end
        return playerData.job and playerData.job.name, playerData.gang and playerData.gang.name
    elseif framework == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return end
        return xPlayer.job and xPlayer.job.name, xPlayer.job2 and xPlayer.job2.name
    end
end

local function isInList(list, value)
    if not value then return false end

    for _, entry in ipairs(list or {}) do
        if entry == value then
            return true
        end
    end

    return false
end

local function hasKeylessAccess(src)
    local jobName, gangName = getJobAndGang(src)

    return isInList(config.entry.keylessJobs, jobName) or isInList(config.entry.keylessGangs, gangName)
end

local function isNear(src, coords)
    local playerCoords = GetEntityCoords(GetPlayerPed(src))

    return #(playerCoords - vector3(coords.x, coords.y, coords.z)) <= maxDistance
end

local function isWholeNumber(value)
    return type(value) == 'number' and value > 0 and value == math.floor(value)
end

local function notifyInventoryFull(src, descriptionKey)
    TriggerClientEvent('ox_lib:notify', src, {title = locale('inventory_full'), description = locale(descriptionKey or 'inventory_full_description'), type = 'error', position = config.notifications.position})
end

local function getWashTotal(Amount)
    return math.floor(Amount - (Amount * config.washing.taxRate))
end

lib.callback.register('s4t4n667_moneywash:canCarry', function(source, step, Amount)
    local src = source
    local washing = config.washing
    local canCarry = false

    if step == 'wash' and isWholeNumber(Amount) then
        canCarry = exports.ox_inventory:CanSwapItem(src, washing.markedMoney, Amount, washing.wetMoney, getWashTotal(Amount))
    elseif step == 'dry' then
        local wet_money = exports.ox_inventory:Search(src, 'count', washing.wetMoney) or 0
        canCarry = wet_money > 0 and exports.ox_inventory:CanSwapItem(src, washing.wetMoney, wet_money, washing.cleanMoney, wet_money)
    end

    if not canCarry then
        notifyInventoryFull(src)
    end

    return canCarry
end)

lib.callback.register('s4t4n667_moneywash:enter', function(source)
    local src = source
    local entry = config.entry

    if not isNear(src, config.laundromatLocations[GlobalState.moneywashLocation]) then return false end

    if entry.requireKey then
        local hasKey = (exports.ox_inventory:Search(src, 'count', entry.keyItem) or 0) >= 1

        if hasKey then
            if entry.removeKey then
                exports.ox_inventory:RemoveItem(src, entry.keyItem, 1)
            end
        elseif not hasKeylessAccess(src) then
            return false
        end
    end

    insideLaundry[src] = true
    return true
end)

RegisterNetEvent('s4t4n667_moneywash:exit', function()
    local src = source

    insideLaundry[src] = nil
    dryingStarted[src] = nil
end)

AddEventHandler('playerDropped', function()
    local src = source

    insideLaundry[src] = nil
    dryingStarted[src] = nil
    activeWash[src] = nil
end)

local function GetWashDuration(Amount)
    local washing = config.washing

    if washing.durationMode ~= 'perAmount' then
        return washing.durationFlat
    end

    local perAmount = washing.perAmount
    local duration = math.floor((Amount / perAmount.per) * perAmount.time)

    return math.max(perAmount.min, math.min(perAmount.max, duration))
end

lib.callback.register('s4t4n667_moneywash:cleanmoney', function(source, Amount)
    local src = source
    local washing = config.washing

    if activeWash[src] then return false end
    if not insideLaundry[src] or not isNear(src, config.targetWash.coords) then return false end
    if not isWholeNumber(Amount) or Amount < tonumber(washing.minAmount) then return false end

    local black_money = exports.ox_inventory:Search(src, 'count', washing.markedMoney) or 0
    if black_money < Amount then return false end

    if not exports.ox_inventory:CanSwapItem(src, washing.markedMoney, Amount, washing.wetMoney, getWashTotal(Amount)) then
        notifyInventoryFull(src)
        return false
    end

    if washing.itemRequired then
        local moneywash_ticket = exports.ox_inventory:Search(src, 'count', washing.ticketItem) or 0
        if moneywash_ticket < 1 then return false end
    end

    if not exports.ox_inventory:RemoveItem(src, washing.markedMoney, Amount) then return false end

    if washing.itemRequired and not exports.ox_inventory:RemoveItem(src, washing.ticketItem, 1) then
        exports.ox_inventory:AddItem(src, washing.markedMoney, Amount)
        return false
    end

    local WashTotal = getWashTotal(Amount)
    local duration = GetWashDuration(Amount)

    activeWash[src] = true

    SetTimeout(duration + 1000, function()
        if not activeWash[src] then return end
        activeWash[src] = nil

        if not exports.ox_inventory:CanCarryItem(src, washing.wetMoney, WashTotal)
            or not exports.ox_inventory:AddItem(src, washing.wetMoney, WashTotal) then
            exports.ox_inventory:CustomDrop('Wet Bills', { { washing.wetMoney, WashTotal } }, GetEntityCoords(GetPlayerPed(src)))
            notifyInventoryFull(src, 'inventory_dropped_description')
        end
    end)

    return duration
end)

RegisterNetEvent('s4t4n667_moneywash:startDrying', function()
    local src = source

    if not insideLaundry[src] or not isNear(src, config.targetCount.coords) then return end

    dryingStarted[src] = GetGameTimer()
end)

RegisterNetEvent('s4t4n667_moneywash:drymoney', function()
    local src = source
    local startedAt = dryingStarted[src]

    dryingStarted[src] = nil

    if not startedAt or not insideLaundry[src] or not isNear(src, config.targetCount.coords) then return end

    if GetGameTimer() - startedAt < config.drying.duration - 500 then return end

    local wet_money = exports.ox_inventory:Search(src, 'count', config.washing.wetMoney) or 0
    if wet_money < 1 then return end

    if not exports.ox_inventory:CanSwapItem(src, config.washing.wetMoney, wet_money, config.washing.cleanMoney, wet_money) then
        notifyInventoryFull(src)
        return
    end

    if exports.ox_inventory:RemoveItem(src, config.washing.wetMoney, wet_money) then
        exports.ox_inventory:AddItem(src, config.washing.cleanMoney, wet_money)
    end
end)

local function GetShopItem(itemName)
    for _, item in pairs(config.shop.items) do
        if item.item == itemName then
            return item
        end
    end
    return nil
end

RegisterNetEvent("s4t4n667_moneywash:buyItem", function(item)
    local src = source

    if not config.shop.enabled or not isNear(src, config.shop.coords) then return end

    local data = GetShopItem(item)
    if not data then
        print(("[s4t4n667_moneywash] %s invalid item: %s"):format(src, tostring(item)))
        return
    end

    local money = exports.ox_inventory:Search(src, 'count', config.shop.currency) or 0

    if money >= data.price then

        if exports.ox_inventory:CanCarryItem(src, item, 1) then
            if exports.ox_inventory:RemoveItem(src, config.shop.currency, data.price) then
                exports.ox_inventory:AddItem(src, item, 1)
            end

            TriggerClientEvent('ox_lib:notify', src, {title = locale('shop.notify_title'), description = locale('shop.notify_success'), type = "success", position = config.notifications.position})
        else
            TriggerClientEvent('ox_lib:notify', src, {title = locale('shop.notify_title'), description = locale('shop.notify_carry'), type = "error", position = config.notifications.position})
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {title = locale('shop.notify_title'), description = locale('shop.notify_money'), type = "error", position = config.notifications.position})
    end
end)
