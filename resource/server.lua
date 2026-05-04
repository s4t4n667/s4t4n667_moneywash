lib.locale()
local config = lib.require('config')
lib.versionCheck('s4t4n667/s4t4n667_moneywash')

RegisterServerEvent('s4t4n667_moneywash:entryKey', function()
    local src = source
    local item = config.entry.keyItem

    local count = exports.ox_inventory:Search(src, 'count', item) or 0
    if count < 1 then return end

    exports.ox_inventory:RemoveItem(src, item, 1)
end)

RegisterServerEvent('s4t4n667_moneywash:cleanmoney', function(Amount)
    local src = source
    local WashTax = Amount * config.washing.taxRate
    local WashTotal = Amount - WashTax
    local black_money = exports.ox_inventory:Search(src, 'count', config.washing.markedMoney)
    local moneywash_ticket =  exports.ox_inventory:Search(src, 'count', config.washing.ticketItem)
    
    if black_money >= Amount then
        if config.washing.itemRequired and moneywash_ticket >= 1 then
            exports.ox_inventory:RemoveItem(src, config.washing.ticketItem, 1)
        end            
        exports.ox_inventory:RemoveItem(src, config.washing.markedMoney, Amount)
        TriggerClientEvent('s4t4n667_moneywash:washactions', src)
        Citizen.Wait(config.washing.duration)
        Citizen.Wait(1000)
        exports.ox_inventory:AddItem(src, 'wet_bills', WashTotal)
    end
end)

RegisterServerEvent('s4t4n667_moneywash:drymoney', function(Amount)
    local src = source
    local dryTotal = Amount
    local wet_money = exports.ox_inventory:Search(source, 'count', config.washing.wetMoney)

    if wet_money >= Amount then
        exports.ox_inventory:RemoveItem(src, config.washing.wetMoney, Amount)
        exports.ox_inventory:AddItem(src, config.washing.cleanMoney, dryTotal)
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

    local data = GetShopItem(item)
    if not data then
        print(("[s4t4n667_moneywash] %s invalid item: %s"):format(src, item))
        return
    end

    local money = exports.ox_inventory:Search(src, 'count', config.shop.currency)

    if money >= data.price then

        if exports.ox_inventory:CanCarryItem(src, item, 1) then
            exports.ox_inventory:RemoveItem(src, config.shop.currency, data.price)
            exports.ox_inventory:AddItem(src, item, 1)

            TriggerClientEvent('ox_lib:notify', src, {title = locale('shop.notify_title'), description = locale('shop.notify_success'), type = "success", position = config.notifications.position})
        else
            TriggerClientEvent('ox_lib:notify', src, {title = locale('shop.notify_title'), description = locale('shop.notify_carry'), type = "error", position = config.notifications.position})
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {title = locale('shop.notify_title'), description = locale('shop.notify_money'), type = "error", position = config.notifications.position})
    end
end)