lib.locale()
local config = lib.require('config')

local CurrentlyWashing = false
local InsideLaundry = false


math.randomseed(GetGameTimer())
local selectedLocation = config.laundromatLocations[math.random(#config.laundromatLocations)]

if config.debug then
    print(('Selected laundromat location: x=%.2f, y=%.2f, z=%.2f'):format(selectedLocation.x, selectedLocation.y, selectedLocation.z))
end


CreateThread(function()
    if config.blip.enabled then
        local laundromatBlip = AddBlipForCoord(selectedLocation.x, selectedLocation.y, selectedLocation.z)
        SetBlipSprite(laundromatBlip, config.blip.sprite)
        SetBlipColour(laundromatBlip, config.blip.spriteColor)
        SetBlipScale(laundromatBlip, config.blip.scale)
        SetBlipAsShortRange(laundromatBlip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(config.blip.label)
        EndTextCommandSetBlipName(laundromatBlip)
    end
end)


function WashMoney()
    CurrentlyWashing = true

    if config.itemRequired then
        local WashTicket = exports.ox_inventory:Search('count', config.ticketItem)

        if WashTicket >= 1 then
            SetEntityHeading(PlayerPedId(), 349.9048)

            local input = lib.inputDialog(locale('menu.input_title'), {
                {type = 'input', label = locale('menu.title'), description = locale('menu.description'), required = true, min = 1, max = 16},
            })

            if not input then 
                CurrentlyWashing = false
                return 
            end

            local WashAmount = tonumber(input[1])
            if WashAmount and WashAmount > 0 then
                local black_money = exports.ox_inventory:Search('count', config.washing.markedMoney)

                if black_money >= WashAmount then
                    ExecuteCommand(config.loading.animation)

                    lib.progressBar({
                        duration = config.loading.duration,
                        label = locale('loading.progress'),
                        useWhileDead = false,
                        canCancel = false,
                        disable = {
                            move = true,
                            mouse = false,
                        },
                    })

                    TriggerServerEvent('s4t4n667_moneywash:cleanmoney', WashAmount)
                    Wait(200)
                    ClearPedTasksImmediately(PlayerPedId())
                else
                    lib.notify({
                        title = locale('loading.notify_nodirty'),
                        description = locale('loading.notify_nodirty_description'),
                        icon = 'fa-solid fa-ban', 
                        iconColor = '#8C2425',
                    })
                end
            else
                lib.notify({
                    title = locale('loading.notify_invalid'),
                    description = locale('loading.notify_invalid_description'),
                    icon = 'fa-solid fa-ban', 
                    iconColor = '#8C2425',
                })
            end
        else
            lib.notify({
                title = locale('loading.notify_notoken'),
                description = locale('loading.notify_notoken_description'),  
                icon = 'fa-solid fa-coins', 
                iconColor = '#8C2425',
            })
        end
    else
        SetEntityHeading(PlayerPedId(), 349.9048)

        ExecuteCommand(config.loading.animation)

        local input = lib.inputDialog(locale('menu.input_title'), {
            {type = 'input', label = locale('menu.title'), description = locale('menu.description'), required = true, min = 1, max = 16},
        })

        if not input then 
            CurrentlyWashing = false
            return 
        end

        local WashAmount = tonumber(input[1])

        if WashAmount and WashAmount > 0 then
            local black_money = exports.ox_inventory:Search('count', config.washing.markedMoney)

            if black_money >= WashAmount then
                ExecuteCommand(config.loading.animation)

                lib.progressBar({
                    duration = config.loading.duration,
                    label = locale('loading.progress'),
                    useWhileDead = false,
                    canCancel = false,
                    disable = {
                        move = true,
                        mouse = false,
                    },
                })

                TriggerServerEvent('s4t4n667_moneywash:cleanmoney', WashAmount)
                Wait(200)
                ClearPedTasksImmediately(PlayerPedId())
            else
                lib.notify({
                    title = locale('loading.notify_nodirty'),
                    description = locale('loading.notify_nodirty_description'),
                    icon = 'fa-solid fa-ban', 
                    iconColor = '#8C2425',
                })
            end
        else
            lib.notify({
                title = locale('loading.notify_invalid'),
                description = locale('loading.notify_invalid_description'),
                icon = 'fa-solid fa-ban', 
                iconColor = '#8C2425',
            })
        end
    end

    CurrentlyWashing = false
end


function DryMoney()
    CurrentlyDrying = true

    local WetBills = exports.ox_inventory:Search('count', 'wet_bills')

    if WetBills > 0 then
        SetEntityHeading(PlayerPedId(), 96.65)
        ExecuteCommand(config.drying.animation)

        if lib.progressBar({
            duration = config.drying.duration,
            label = locale('drying.progress'),
            useWhileDead = false,
            canCancel = false,
            disable = {
                move = true,
                mouse = false,
            },
        }) then
            lib.notify({
                title = locale('drying.notify_success_title'),
                description = locale('drying.notify_success_description'),
                icon = 'fa-solid fa-money-bill',
                iconColor = '#51A231',
            })

            Wait(300)
            TriggerServerEvent('s4t4n667_moneywash:drymoney', WetBills)
            Wait(1000)
            ClearPedTasksImmediately(PlayerPedId())
        end
    else
        lib.notify({
            title = locale('drying.notify_fail_title'),
            description = locale('drying.notify_fail_description'),
            icon = 'fa-solid fa-ban',
            iconColor = '#8C2425',
        })
    end

    CurrentlyDrying = false
end


function EnterLaundry()
    if config.requireKeycard then
        local keycard = exports.ox_inventory:Search('count', config.keycardItem)
        if keycard >= 1 or (config.policeAccess and hasJobPolice()) then
            DoScreenFadeOut(100)
            Wait(1000)
            SetEntityCoords(PlayerPedId(), 1137.76, -3198.47, -39.67) -- DO NOT CHANGE
            SetEntityHeading(PlayerPedId(), 41.47) -- DO NOT CHANGE
            Wait(1000)
            DoScreenFadeIn(100)
            InsideLaundry = true
        else
            lib.notify({
                title = locale('access'),
                description = locale('access_description'),
                icon = 'fa-solid fa-key',
                iconColor = '#8C2425',
            })
        end
    else
        DoScreenFadeOut(100)
        Wait(1000)
        SetEntityCoords(PlayerPedId(), 1137.76, -3198.47, -39.67) -- DO NOT CHANGE
        SetEntityHeading(PlayerPedId(), 41.47) -- DO NOT CHANGE
        Wait(1000)
        DoScreenFadeIn(100)
        InsideLaundry = true
    end
end


function hasJobPolice()
    if config.useQBCore == true then 
        QBCore = exports["qb-core"]:GetCoreObject()
        local PlayerData = QBCore.Functions.GetPlayerData()
        return PlayerData.job and PlayerData.job.name == config.policeJob
    else
        ESX = exports['es_extended']:getSharedObject()
        local playerData = ESX.GetPlayerData()
        return playerData.job and playerData.job.name == config.policeJob
    end
end


function ExitLaundry()
	InsideLaundry = false
	DoScreenFadeOut(100)
	Wait(500)
	SetEntityCoords(PlayerPedId(), selectedLocation.x, selectedLocation.y, selectedLocation.z)
	SetEntityHeading(PlayerPedId(), selectedLocation.heading)
	Wait(1000)
	DoScreenFadeIn(100)
end


RegisterNetEvent('s4t4n667_moneywash:washactions', function()
    CurrentlyWashing = true

    lib.notify({
        title = locale('washing.notify_started'),
        description = locale('washing.notify_started_description'),
        icon = 'fa-solid fa-soap',
        iconColor = '#76A9D2',
    })

    Wait(1000)

    if lib.progressBar({
        duration = config.washing.duration,
        label = locale('washing.progress'),
        useWhileDead = false,
        canCancel = false,
    }) then        
        lib.notify({
            title = locale('washing.notify_finished'),
            description = locale('washing.notify_finished_description'),
            icon = 'fa-solid fa-soap',
            iconColor = '#51A231',
        })
        
        CurrentlyWashing = false
    end
end)


Citizen.CreateThread(function()
    exports.ox_target:addBoxZone({
        coords = vector3(selectedLocation.x, selectedLocation.y, selectedLocation.z),
        radius = 1,
        debug = drawZones,
        options = {
            {
                name = 'WashEnter',
                label = config.targetEntry.label,
                icon = config.targetEntry.icon,
                iconColor = config.targetEntry.iconColor,
                onSelect = function()
                    EnterLaundry()
                end,
            }
        }
    })
    exports.ox_target:addBoxZone({
        coords = vector3(1138.04, -3199.45, -39.6), -- DO NOT CHANGE
        radius = 1,
        debug = drawZones,
        options = {
            {
                name = 'WashExit',
                label = config.targetExit.label,
                icon = config.targetExit.icon,
                iconColor = config.targetExit.iconColor,
                onSelect = function() 
                    ExitLaundry() 
                end,
            }
        }
    })
    exports.ox_target:addBoxZone({
        coords = config.targetWash.coords,
        radius = 1,
        debug = drawZones,
        options = {
            {
                name = 'WashWash',
                label = config.targetWash.label,
                icon = config.targetWash.icon,
                iconColor = config.targetWash.iconColor,
                canInteract = function()
                    return InsideLaundry
                end,
                onSelect = function()
                    WashMoney()
                end
            }
        }
    })
    exports.ox_target:addBoxZone({
        coords = config.targetCount.coords,
        radius = 1,
        debug = drawZones,
        options = {
            {
                name = 'WashDry',
                label = config.targetCount.label,
                icon = config.targetCount.icon,
                iconColor = config.targetCount.iconColor,
                canInteract = function()
                    return InsideLaundry
                end,
                onSelect = function()
                    DryMoney()
                end
            }
        }
    })
end)