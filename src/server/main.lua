for _, cfg in ipairs(Config.Items) do
    if cfg.useable ~= false then
        Framework.RegisterUsableItem(cfg.name, function(source, item)
        local Player = Framework.GetPlayer(source)
        if not Player then return end

        local slot = item and (item.slot or item.Slot) or nil
        local meta = Inventory.GetMeta(item)
        local charge = nil

        if cfg.metaField then
            charge = meta[cfg.metaField]
            if charge ~= nil then charge = tonumber(charge) end

            if charge == nil then
                charge = cfg.defaultCharge or 100
                if slot then
                    Inventory.UpdateMeta(source, cfg.name, slot, cfg.metaField, charge)
                end
                DebugPrint('Init', cfg.name, 'charge:', charge)
            end

            if cfg.type == 'charger' and cfg.depleteRate > 0 and charge <= 0 then
                Framework.Notify(source, cfg.label .. ' is empty!', 'error', 3000)
                return
            end
        end

        DebugPrint(cfg.name, 'used by', source, '| slot:', slot, '| charge:', charge)

        if cfg.type == 'charger' then
            TriggerClientEvent('fiveous_charger:client:useChargerItem', source, cfg.name, charge, slot)
        elseif cfg.type == 'chargeable' then
            if charge then
                Framework.Notify(source, cfg.label .. ': ' .. math.floor(charge) .. '% charged', 'primary', 3000)
            end
        end
    end)
        DebugPrint('Registered item:', cfg.name)
    else
        DebugPrint('Skipped item (useable = false):', cfg.name)
    end
end

RegisterNetEvent('fiveous_charger:server:updateMeta', function(slot, itemName, metaField, value)
    local src = source
    local item = Inventory.GetItemBySlot(src, slot)
    if not item then return end
    if Inventory.GetName(item) ~= itemName then return end
    Inventory.UpdateMeta(src, itemName, slot, metaField, tonumber(value) or 0)
end)

RegisterNetEvent('fiveous_charger:server:requestItemCharge', function(itemName)
    local src = source
    local Player = Framework.GetPlayer(src)
    if not Player then return end

    local cfg = GetItemConfig(itemName)
    if not cfg or not cfg.canChargeAtStation then return end

    local item, slot = Inventory.FindItem(src, itemName)
    if not item then
        Framework.Notify(src, "You don't have a " .. cfg.label, 'error', 3000)
        return
    end

    local meta = Inventory.GetMeta(item)
    local charge = 0

    if cfg.metaField then
        charge = tonumber(meta[cfg.metaField]) or 0
        if meta[cfg.metaField] == nil then
            charge = cfg.defaultCharge or 100
            Inventory.UpdateMeta(src, itemName, slot, cfg.metaField, charge)
        end
    end

    if charge >= (cfg.maxCharge or 100) then
        Framework.Notify(src, cfg.label .. ' is already fully charged', 'error', 3000)
        return
    end

    TriggerClientEvent('fiveous_charger:client:startItemStationCharge', src, itemName, charge, slot)
end)

-- tgiann-inventory hooks
if Config.Inventory == 'tgiann-inventory' then
    local filter = {}
    for _, cfg in ipairs(Config.Items) do
        if cfg.metaField then filter[cfg.name] = true end
    end

    local function initHook(hookName)
        local ok, err = pcall(function()
            exports['tgiann-inventory']:RegisterHook(hookName, function(payload)
                if not payload then return end
                local itemName = payload.itemName or (type(payload.item) == 'table' and payload.item.name) or payload.item
                local cfg = GetItemConfig(itemName)
                if not cfg or not cfg.metaField then return end

                local src = tonumber(payload.source)
                if not src then return end

                local slot = payload.toSlot or payload.slot
                CreateThread(function()
                    Wait(150)
                    if slot then
                        Inventory.UpdateMeta(src, itemName, slot, cfg.metaField, cfg.defaultCharge or 100)
                        DebugPrint(hookName, '| init', itemName, 'charge:', cfg.defaultCharge or 100)
                    end
                end)
            end, { itemFilter = filter })
        end)
        if not ok then
            DebugPrint(hookName, 'hook failed:', err)
        end
    end

    initHook('buyItem')
    initHook('craftItem')
end

-- ox_inventory / qs-inventory crafting hooks
if Config.Inventory == 'ox_inventory' or Config.Inventory == 'qs-inventory' then
    local invResource = Config.Inventory == 'qs-inventory' and 'qs-inventory' or 'ox_inventory'
    for _, cfg in ipairs(Config.Items) do
        if cfg.metaField then
            pcall(function()
                exports[invResource]:RegisterHook(cfg.name .. '_crafted', function(payload)
                    if not payload then return true end
                    if payload.toInventory and type(payload.toInventory) == 'number' then
                        CreateThread(function()
                            Wait(200)
                            local src = payload.toInventory
                            local item, slot = Inventory.FindItem(src, cfg.name)
                            if item and slot then
                                local meta = Inventory.GetMeta(item)
                                if not meta[cfg.metaField] then
                                    Inventory.UpdateMeta(src, cfg.name, slot, cfg.metaField, cfg.defaultCharge or 100)
                                    DebugPrint('ox hook | init', cfg.name, 'charge:', cfg.defaultCharge or 100)
                                end
                            end
                        end)
                    end
                    return true
                end, 'craftItem')
            end)
        end
    end
end

CreateThread(function()
    Wait(1000)
    print('^2[fiveous_charger]^7 Loaded | Framework: ' .. Config.Framework .. ' | Inventory: ' .. Config.Inventory .. ' | Phone: ' .. (Config.Phone.Enabled and Config.Phone.Resource or 'disabled'))
    for _, cfg in ipairs(Config.Items) do
        local s = '  ^3' .. cfg.name .. '^7 [' .. cfg.type .. ']'
        if cfg.type == 'charger' then s = s .. ' ' .. cfg.chargeRate .. '%/s' end
        if cfg.canChargeAtStation then s = s .. ' (station: ' .. (cfg.stationChargeRate or 0) .. '%/s)' end
        print('^2[fiveous_charger]^7' .. s)
    end
    if Config.RechargeStations.Enabled then
        print('^2[fiveous_charger]^7  Stations: ' .. #Config.RechargeStations.Locations)
    end
end)
