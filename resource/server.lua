local config = lib.require('config')


RegisterServerEvent('s4t4n667_moneywash:cleanmoney', function(Amount)
    local Player = source
    local WashTax = Amount * config.washing.taxRate
    local WashTotal = Amount - WashTax
    local black_money = exports.ox_inventory:Search(Player, 'count', config.washing.markedMoney)
    local moneywash_ticket =  exports.ox_inventory:Search(Player, 'count', config.ticketItem)
    
    if black_money >= Amount then
        if config.itemRequired then
            if moneywash_ticket >= 1 then
                exports.ox_inventory:RemoveItem(Player, config.ticketItem, 1)
                exports.ox_inventory:RemoveItem(Player, config.washing.markedMoney, Amount)
                TriggerClientEvent('s4t4n667_moneywash:washactions', Player)
                Citizen.Wait(config.washing.duration)
                Citizen.Wait(1000)
                exports.ox_inventory:AddItem(Player, 'wet_bills', WashTotal)
            end
        else
            exports.ox_inventory:RemoveItem(Player, config.ticketItem, 1)
            exports.ox_inventory:RemoveItem(Player, config.washing.markedMoney, Amount)
            TriggerClientEvent('s4t4n667_moneywash:washactions', Player)
            Citizen.Wait(config.washing.duration)
            Citizen.Wait(1000)
            exports.ox_inventory:AddItem(Player, 'wet_bills', WashTotal)
        end
    end
end)


RegisterServerEvent('s4t4n667_moneywash:drymoney', function(Amount)
    local Player = source
    local DryTotal = Amount
    local wet_money = exports.ox_inventory:Search(Player, 'count', 'wet_bills')

    if wet_money >= Amount then
        exports.ox_inventory:RemoveItem(Player, 'wet_bills', Amount)
        Wait(1000)
        exports.ox_inventory:AddItem(Player, config.washing.cleanMoney, DryTotal)
    end
end)