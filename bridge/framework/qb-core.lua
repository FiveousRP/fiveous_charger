local QBCore = exports['qb-core']:GetCoreObject()

Framework = {}

function Framework.GetPlayer(src)
    return QBCore.Functions.GetPlayer(src)
end

function Framework.GetPlayerData()
    return QBCore.Functions.GetPlayerData()
end

function Framework.RegisterUsableItem(name, cb)
    QBCore.Functions.CreateUseableItem(name, cb)
end

function Framework.Notify(src, msg, type, duration)
    if IsDuplicityVersion() then
        TriggerClientEvent('QBCore:Notify', src, msg, type, duration or 3000)
    else
        QBCore.Functions.Notify(msg, type, duration or 3000)
    end
end
