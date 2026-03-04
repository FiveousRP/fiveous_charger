local ESX = exports['es_extended']:getSharedObject()

Framework = {}

function Framework.GetPlayer(src)
    return ESX.GetPlayerFromId(src)
end

function Framework.GetPlayerData()
    return ESX.GetPlayerData()
end

function Framework.RegisterUsableItem(name, cb)
    ESX.RegisterUsableItem(name, function(playerId)
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if not xPlayer then return end

        local inventoryItem = nil
        for _, item in ipairs(xPlayer.getInventory()) do
            if item.name == name and item.count > 0 then
                inventoryItem = item
                break
            end
        end

        cb(playerId, inventoryItem or { name = name, slot = inventoryItem and inventoryItem.slot })
    end)
end

function Framework.Notify(src, msg, type, duration)
    if IsDuplicityVersion() then
        TriggerClientEvent('esx:showNotification', src, msg)
    else
        ESX.ShowNotification(msg)
    end
end
