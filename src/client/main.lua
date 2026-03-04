local isCharging = false
local chargingType = nil
local chargingItemName = nil
local currentSlot = nil
local stationBlips = {}
local stationZones = {}
local uiHidden = false

local function SendUI(data)
    SendNUIMessage(data)
end

local function OpenUI(uiType, label, icon, rate, battery, secLabel, secCharge)
    SendUI({
        action = 'open',
        type = uiType,
        label = label or 'Charging',
        icon = icon or '🔋',
        battery = battery or 0,
        chargeRate = rate or 1.0,
        secondaryLabel = secLabel,
        secondaryCharge = secCharge,
        brandName = Config.UI.BrandName,
        brandColor = Config.UI.BrandColor,
        brandColorRGB = Config.UI.BrandColorRGB,
        brandGradientFrom = Config.UI.BrandGradientFrom,
        brandGradientTo = Config.UI.BrandGradientTo,
        hideKeybind = Config.UI.HideKeybind,
    })
end

local function UpdateUI(battery, rate, secCharge)
    SendUI({ action = 'update', battery = battery, chargeRate = rate, secondaryCharge = secCharge })
end

local function CloseUI(completed)
    if completed then
        SendUI({ action = 'complete', duration = Config.UI.CompletionPopupDuration })
    else
        SendUI({ action = 'close' })
    end
end

local function StopCharging(reason, ntype)
    if not isCharging then return end
    local was = chargingType

    isCharging = false
    chargingType = nil
    chargingItemName = nil
    currentSlot = nil
    uiHidden = false

    if was == 'phone_charger' or was == 'phone_station' then
        Phone.ToggleCharging(false)
    end

    if reason then
        Framework.Notify(nil, reason, ntype or 'error', 2000)
    end
end

local function IsNearStation()
    local pos = GetEntityCoords(PlayerPedId())
    for _, station in ipairs(Config.RechargeStations.Locations) do
        if #(pos - station.coords) <= 3.0 then return true end
    end
    return false
end

-- phone charging via items (powerbank, car charger, etc)
function StartPhoneCharging(cfg, charge, slot)
    if isCharging then
        Framework.Notify(nil, 'Already charging something', 'error', 2000)
        return
    end

    if not Phone.IsEnabled() or not Phone.HasPhone() then
        Framework.Notify(nil, "You don't have a phone", 'error', 3000)
        return
    end

    local battery = Phone.GetBattery()
    if battery >= 100 then
        Framework.Notify(nil, 'Phone is already fully charged', 'error', 3000)
        return
    end

    local ped = PlayerPedId()
    if cfg.requireVehicle and not IsPedInAnyVehicle(ped, false) then
        Framework.Notify(nil, 'You must be in a vehicle', 'error', 3000)
        return
    end
    if cfg.requireVehicle and cfg.requireEngine then
        local veh = GetVehiclePedIsIn(ped, false)
        if not GetIsVehicleEngineRunning(veh) then
            Framework.Notify(nil, 'Vehicle engine must be running', 'error', 3000)
            return
        end
    end

    isCharging = true
    chargingType = 'phone_charger'
    chargingItemName = cfg.name
    currentSlot = slot
    Phone.ToggleCharging(true)

    local secLabel, secCharge = nil, nil
    local itemCharge = charge
    if cfg.metaField and cfg.depleteRate > 0 then
        secLabel = cfg.label .. ' Charge'
        secCharge = itemCharge
    end

    OpenUI('charger', cfg.label, cfg.icon, cfg.chargeRate, battery, secLabel, secCharge)
    DebugPrint('Phone charging via', cfg.name, '| bat:', battery)

    CreateThread(function()
        while isCharging and chargingType == 'phone_charger' do
            local bat = Phone.GetBattery()

            if not Phone.HasPhone() then
                StopCharging('Phone removed!', 'error')
                CloseUI(false)
                break
            end

            if bat >= 100 then
                StopCharging(nil)
                Framework.Notify(nil, 'Phone fully charged!', 'success', 2000)
                CloseUI(true)
                break
            end

            if cfg.requireVehicle then
                local p = PlayerPedId()
                if not IsPedInAnyVehicle(p, false) then
                    StopCharging('Left vehicle - charging stopped', 'error')
                    CloseUI(false)
                    break
                end
                if cfg.requireEngine and not GetIsVehicleEngineRunning(GetVehiclePedIsIn(p, false)) then
                    StopCharging('Engine stopped - charging stopped', 'error')
                    CloseUI(false)
                    break
                end
            end

            if cfg.metaField and cfg.depleteRate > 0 then
                if itemCharge <= 0 then
                    StopCharging(cfg.label .. ' depleted!', 'error')
                    TriggerServerEvent('fiveous_charger:server:updateMeta', currentSlot, cfg.name, cfg.metaField, 0)
                    CloseUI(false)
                    break
                end
                itemCharge = math.max(itemCharge - cfg.depleteRate, 0)
                TriggerServerEvent('fiveous_charger:server:updateMeta', currentSlot, cfg.name, cfg.metaField, itemCharge)
            end

            local newBat = math.min(bat + cfg.chargeRate, 100)
            Phone.SetBattery(newBat)
            UpdateUI(newBat, cfg.chargeRate, itemCharge)

            Wait(1000)
        end
    end)
end

-- phone charging at a station
function StartPhoneStationCharging()
    if isCharging then
        Framework.Notify(nil, 'Already charging something', 'error', 2000)
        return
    end

    if not Phone.IsEnabled() or not Phone.HasPhone() then
        Framework.Notify(nil, "You don't have a phone", 'error', 3000)
        return
    end

    local battery = Phone.GetBattery()
    if battery >= 100 then
        Framework.Notify(nil, 'Phone is already fully charged', 'error', 3000)
        return
    end

    isCharging = true
    chargingType = 'phone_station'
    Phone.ToggleCharging(true)

    local rate = Config.RechargeStations.PhoneChargeRate
    OpenUI('station', 'Charging Station', '🏪', rate, battery)
    Framework.Notify(nil, 'Plugged in at charging station', 'success', 2000)

    CreateThread(function()
        while isCharging and chargingType == 'phone_station' do
            local bat = Phone.GetBattery()

            if not Phone.HasPhone() then
                StopCharging('Phone removed!', 'error')
                CloseUI(false)
                break
            end

            if bat >= 100 then
                StopCharging(nil)
                Framework.Notify(nil, 'Phone fully charged!', 'success', 2000)
                CloseUI(true)
                break
            end

            if not IsNearStation() then
                StopCharging('Moved too far from charging station', 'error')
                CloseUI(false)
                break
            end

            local newBat = math.min(bat + rate, 100)
            Phone.SetBattery(newBat)
            UpdateUI(newBat, rate)

            Wait(1000)
        end
    end)
end

-- item charging at a station (battery, drone, powerbank recharge)
function StartItemStationCharging(cfg, currentCharge, slot)
    if isCharging then
        Framework.Notify(nil, 'Already charging something', 'error', 2000)
        return
    end

    local max = cfg.maxCharge or 100
    if currentCharge >= max then
        Framework.Notify(nil, cfg.label .. ' is already fully charged', 'error', 3000)
        return
    end

    isCharging = true
    chargingType = 'item_station'
    chargingItemName = cfg.name
    currentSlot = slot

    local rate = cfg.stationChargeRate or 1.0
    local charge = currentCharge

    OpenUI('station', cfg.label, cfg.icon, rate, charge)
    Framework.Notify(nil, 'Charging ' .. cfg.label .. '...', 'success', 2000)

    CreateThread(function()
        while isCharging and chargingType == 'item_station' do
            if charge >= max then
                TriggerServerEvent('fiveous_charger:server:updateMeta', currentSlot, cfg.name, cfg.metaField, max)
                StopCharging(nil)
                Framework.Notify(nil, cfg.label .. ' fully charged!', 'success', 2000)
                CloseUI(true)
                break
            end

            if not IsNearStation() then
                TriggerServerEvent('fiveous_charger:server:updateMeta', currentSlot, cfg.name, cfg.metaField, charge)
                StopCharging('Moved too far from charging station', 'error')
                CloseUI(false)
                break
            end

            charge = math.min(charge + rate, max)
            TriggerServerEvent('fiveous_charger:server:updateMeta', currentSlot, cfg.name, cfg.metaField, charge)
            UpdateUI(charge, rate)

            Wait(1000)
        end
    end)
end

-- nui callbacks
RegisterNUICallback('stopCharging', function(_, cb)
    StopCharging('Stopped charging', 'error')
    CloseUI(false)
    cb('ok')
end)

RegisterNUICallback('uiReady', function(_, cb) cb('ok') end)

-- keybind: backspace to toggle ui visibility
RegisterCommand('+fiveous_charger_toggle', function()
    if not isCharging then return end
    uiHidden = not uiHidden
    SendUI({ action = uiHidden and 'hide' or 'show' })
end, false)
RegisterCommand('-fiveous_charger_toggle', function() end, false)
RegisterKeyMapping('+fiveous_charger_toggle', 'Toggle Charger UI', 'keyboard', 'back')

-- events from server
RegisterNetEvent('fiveous_charger:client:useChargerItem', function(itemName, charge, slot)
    local cfg = GetItemConfig(itemName)
    if not cfg then return end
    if cfg.type == 'charger' then
        StartPhoneCharging(cfg, charge, slot)
    end
end)

RegisterNetEvent('fiveous_charger:client:startItemStationCharge', function(itemName, charge, slot)
    local cfg = GetItemConfig(itemName)
    if not cfg then return end
    StartItemStationCharging(cfg, charge, slot)
end)

RegisterNetEvent('fiveous_charger:client:stopCharging', function()
    if isCharging then
        StopCharging(nil)
        CloseUI(false)
    end
end)

-- station setup
local function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(1)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

local function BuildStationOptions()
    local opts = {}

    if Config.Phone.Enabled then
        opts[#opts + 1] = {
            type = 'client',
            icon = Config.RechargeStations.Target.Icon,
            label = 'Charge Phone',
            action = function() StartPhoneStationCharging() end,
        }
    end

    for _, cfg in ipairs(GetChargeableItems()) do
        opts[#opts + 1] = {
            type = 'client',
            icon = 'fas fa-battery-half',
            label = 'Charge ' .. cfg.label,
            action = function()
                TriggerServerEvent('fiveous_charger:server:requestItemCharge', cfg.name)
            end,
        }
    end

    return opts
end

local function SetupStations()
    if not Config.RechargeStations or not Config.RechargeStations.Enabled then return end

    local blipCfg = Config.RechargeStations.Blip
    local targetCfg = Config.RechargeStations.Target

    for i, station in ipairs(Config.RechargeStations.Locations) do
        if blipCfg.Enabled then
            local blip = AddBlipForCoord(station.coords.x, station.coords.y, station.coords.z)
            SetBlipSprite(blip, blipCfg.Sprite)
            SetBlipDisplay(blip, blipCfg.Display)
            SetBlipScale(blip, blipCfg.Scale)
            SetBlipColour(blip, blipCfg.Color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(station.label or blipCfg.Label)
            EndTextCommandSetBlipName(blip)
            stationBlips[#stationBlips + 1] = blip
        end

        local opts = BuildStationOptions()
        if #opts == 0 then goto skip end

        local zoneName = 'fiveous_charger_' .. i

        if Config.Target ~= 'none' then
            Target.AddZone(zoneName, station.coords, targetCfg.Distance, opts, Config.Debug)
        end

        stationZones[#stationZones + 1] = zoneName
        ::skip::
    end

    if Config.Target == 'none' then
        CreateThread(function()
            while true do
                local sleep = 1000
                local pos = GetEntityCoords(PlayerPedId())

                for _, station in ipairs(Config.RechargeStations.Locations) do
                    if #(pos - station.coords) <= Config.RechargeStations.Target.Distance then
                        sleep = 0
                        DrawText3D(station.coords.x, station.coords.y, station.coords.z + 0.5, '~w~Press ~b~[E]~w~ to use Charging Station')
                        if IsControlJustReleased(0, 38) then
                            local phoneNeedsCharge = Config.Phone.Enabled and Phone.HasPhone() and Phone.GetBattery() < 100
                            if phoneNeedsCharge then
                                StartPhoneStationCharging()
                            else
                                local items = GetChargeableItems()
                                if #items > 0 then
                                    TriggerServerEvent('fiveous_charger:server:requestItemCharge', items[1].name)
                                elseif Config.Phone.Enabled then
                                    Framework.Notify(nil, 'Nothing to charge', 'error', 2000)
                                end
                            end
                        end
                    end
                end

                Wait(sleep)
            end
        end)
    end

    DebugPrint('Stations ready:', #Config.RechargeStations.Locations)
end

local function CleanupStations()
    for _, blip in ipairs(stationBlips) do
        if DoesBlipExist(blip) then RemoveBlip(blip) end
    end
    stationBlips = {}

    for _, zone in ipairs(stationZones) do
        Target.RemoveZone(zone)
    end
    stationZones = {}
end

AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    SetupStations()
end)

AddEventHandler('onClientResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    CleanupStations()
    if isCharging then
        StopCharging(nil)
        SendUI({ action = 'close' })
    end
end)

if Config.Debug then
    RegisterCommand('setbattery', function(_, args)
        if not Phone.IsEnabled() then
            print('[fiveous_charger] Phone is disabled in config')
            return
        end
        local val = tonumber(args[1])
        if not val or val < 0 or val > 100 then
            print('[fiveous_charger] Usage: /setbattery 0-100')
            return
        end
        Phone.SetBattery(val)
        Framework.Notify(nil, 'Battery set to ' .. val .. '%', 'success', 2000)
        DebugPrint('Battery manually set to', val)
    end, false)
end
