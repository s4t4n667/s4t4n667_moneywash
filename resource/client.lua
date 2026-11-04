lib.locale()
local config = lib.require('config')

local CurrentlyWashing = false
local CountdownShowing = false
local InsideLaundry = false

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    if CountdownShowing then
        lib.hideTextUI()
    end
end)

local selectedLocation

CreateThread(function()
    while not GlobalState.moneywashLocation do Wait(100) end
    selectedLocation = config.laundromatLocations[GlobalState.moneywashLocation]

    if config.debug then
        print(('Selected laundromat location: x=%.2f, y=%.2f, z=%.2f'):format(selectedLocation.x, selectedLocation.y, selectedLocation.z))
    end

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

local function notify(titleKey, descriptionKey, icon, iconColor)
    lib.notify({
        title = locale(titleKey),
        description = locale(descriptionKey),
        icon = icon or 'fa-solid fa-circle-info',
        iconColor = iconColor or '',
        position = config.notifications.position
    })
end

function WashMoney()
    CurrentlyWashing = true

    local function handleWash()
        SetEntityHeading(PlayerPedId(), 349.9048)

        local input = lib.inputDialog(locale('menu.input_title'), {
            {
                type = 'input',
                label = locale('menu.title'),
                description = locale('menu.description'),
                required = true,
                min = 1,
                max = 16
            },
        })

        if not input then
            CurrentlyWashing = false
            return
        end

        local WashAmount = tonumber(input[1])
        local minAmount = tonumber(config.washing.minAmount)

        if not WashAmount then
            notify('loading.notify_invalid', 'loading.notify_invalid_description', 'fa-solid fa-ban', config.notifications.failColor)
            CurrentlyWashing = false
            return
        end

        if WashAmount < minAmount then
            notify('loading.notify_too_low', locale('loading.notify_too_low_description'):format(minAmount), 'fa-solid fa-arrow-down', config.notifications.failColor)
            CurrentlyWashing = false
            return
        end

        local black_money = exports.ox_inventory:Search('count', config.washing.markedMoney)

        if black_money < WashAmount then
            notify('loading.notify_nodirty', 'loading.notify_nodirty_description', 'fa-solid fa-ban', config.notifications.failColor)
            CurrentlyWashing = false
            return
        end

        if not lib.callback.await('s4t4n667_moneywash:canCarry', false, 'wash', WashAmount) then
            CurrentlyWashing = false
            return
        end

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

        local duration = lib.callback.await('s4t4n667_moneywash:cleanmoney', false, WashAmount)
        ClearPedTasksImmediately(PlayerPedId())

        if not duration then
            CurrentlyWashing = false
            return
        end

        washCountdown(duration)
    end

    if config.washing.itemRequired then
        local WashTicket = exports.ox_inventory:Search('count', config.washing.ticketItem)

        if WashTicket < 1 then
            notify('loading.notify_notoken', 'loading.notify_notoken_description', 'fa-solid fa-coins', config.notifications.failColor)
            CurrentlyWashing = false
            return
        end
    end

    handleWash()
end

function washCountdown(duration)
    notify('washing.notify_started', 'washing.notify_started_description', 'fa-solid fa-soap', config.notifications.generalColor)
    Wait(500)

    local endTime = GetGameTimer() + duration
    CountdownShowing = true

    while true do
        local secondsLeft = math.ceil((endTime - GetGameTimer()) / 1000)
        if secondsLeft <= 0 then break end

        lib.showTextUI(('%s %d:%02d'):format(locale('washing.progress'), secondsLeft // 60, secondsLeft % 60), {
            position = 'right-center',
            icon = 'fa-solid fa-soap',
        })
        Wait(250)
    end

    lib.hideTextUI()
    CountdownShowing = false
    notify('washing.notify_finished', 'washing.notify_finished_description', 'fa-solid fa-soap', config.notifications.successColor)

    CurrentlyWashing = false
end

function DryMoney()
    CurrentlyDrying = true

    local WetBills = exports.ox_inventory:Search('count', config.washing.wetMoney)

    if WetBills > 0 then
        if not lib.callback.await('s4t4n667_moneywash:canCarry', false, 'dry') then
            CurrentlyDrying = false
            return
        end

        SetEntityHeading(PlayerPedId(), 96.65)
        ExecuteCommand(config.drying.animation)
        TriggerServerEvent('s4t4n667_moneywash:startDrying')

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
            notify('drying.notify_success_title', 'drying.notify_success_description', 'fa-solid fa-money-bill', config.notifications.successColor)
            Wait(300)
            TriggerServerEvent('s4t4n667_moneywash:drymoney')
            Wait(1000)
            ClearPedTasksImmediately(PlayerPedId())
        end
    else
        notify('drying.notify_fail_title', 'drying.notify_fail_description', 'fa-solid fa-ban', config.notifications.failColor)
    end

    CurrentlyDrying = false
end

function EnterLaundry()
    local ped = PlayerPedId()

    if not lib.callback.await('s4t4n667_moneywash:enter', false) then
        notify('access', 'access_description', 'fa-solid fa-key', config.notifications.failColor)
        return
    end

    DoScreenFadeOut(100)
    Wait(1000)
    SetEntityCoords(ped, 1137.76, -3198.47, -39.67)
    SetEntityHeading(ped, 41.47)
    Wait(1000)
    DoScreenFadeIn(100)
    InsideLaundry = true
end

function ExitLaundry()
	if CurrentlyWashing then
		notify('washing.notify_cant_leave', 'washing.notify_cant_leave_description', 'fa-solid fa-ban', config.notifications.failColor)
		return
	end

	InsideLaundry = false
	TriggerServerEvent('s4t4n667_moneywash:exit')
	DoScreenFadeOut(100)
	Wait(500)
	SetEntityCoords(PlayerPedId(), selectedLocation.x, selectedLocation.y, selectedLocation.z)
	if type(selectedLocation) == 'vector4' then
		SetEntityHeading(PlayerPedId(), selectedLocation.w)
	end
	Wait(1000)
	DoScreenFadeIn(100)
end

local function hasKey()
    local item = config.entry.keyItem
    if not item then return false end

    return (exports.ox_inventory:Search('count', item) or 0) > 0
end

Citizen.CreateThread(function()
    while not selectedLocation do Wait(100) end

    exports.ox_target:addBoxZone({
        coords = vector3(selectedLocation.x, selectedLocation.y, selectedLocation.z),
        size = vec3(1.0, 1.0, 1.0),
        debug = drawZones,
        options = {
            {
                name = 'WashEnter',
                label = config.targetEntry.label,
                icon = config.targetEntry.icon,
                iconColor = config.targetEntry.iconColor,
                distance = config.targetEntry.distance,
                canInteract = function()
                    if not config.entry.hideTargetWithoutKey then
                        return true
                    end
                    return hasKey()
                end,
                onSelect = function()
                    EnterLaundry()
                end,
            }
        }
    })
    exports.ox_target:addBoxZone({
        coords = vector3(1138.04, -3199.45, -39.6),
        size = vec3(1.0, 1.0, 1.0),
        debug = drawZones,
        options = {
            {
                name = 'WashExit',
                label = config.targetExit.label,
                icon = config.targetExit.icon,
                iconColor = config.targetExit.iconColor,
                distance = config.targetExit.distance,
                onSelect = function() 
                    ExitLaundry() 
                end,
            }
        }
    })
    exports.ox_target:addBoxZone({
        coords = config.targetWash.coords,
        size = vec3(1.0, 1.0, 1.0),
        debug = drawZones,
        options = {
            {
                name = 'WashWash',
                label = config.targetWash.label,
                icon = config.targetWash.icon,
                iconColor = config.targetWash.iconColor,
                distance = config.targetWash.distance,
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
        size = vec3(1.0, 1.0, 1.0),
        debug = drawZones,
        options = {
            {
                name = 'WashDry',
                label = config.targetCount.label,
                icon = config.targetCount.icon,
                iconColor = config.targetCount.iconColor,
                distance = config.targetCount.distance,
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

CreateThread(function()
    if not config.shop.enabled then return end

    local pedModel = config.shop.pedModel
    local coords = config.shop.coords

    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do Wait(0) end

    local ped = CreatePed(4, pedModel, coords.x, coords.y, coords.z -1, coords.w, false, true)

    if not DoesEntityExist(ped) then
        return
    end

    SetEntityAsMissionEntity(ped, true, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'moneywash-shop',
            icon = 'fa-solid fa-basket-shopping',
            label = 'Browse Shop',
            onSelect = function()
                OpenShopMenu()
            end
        }
    })
end)

function OpenShopMenu()
    local options = {}

    for _, v in pairs(config.shop.items) do
        options[#options + 1] = {
            title = v.label .. " - $" .. v.price,
            icon = v.icon,
            iconColor = v.iconColor,
            onSelect = function()
                TriggerServerEvent("s4t4n667_moneywash:buyItem", v.item)
            end
        }
    end

    lib.registerContext({
        id = 'moneywash_shop',
        title = locale('shop.title'),
        options = options
    })

    lib.showContext('moneywash_shop')
end