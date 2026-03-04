Framework = {}

function Framework.GetPlayer(src)
    return { source = src }
end

function Framework.GetPlayerData()
    return {}
end

function Framework.RegisterUsableItem(name, cb)
    RegisterCommand('use_' .. name, function(source)
        cb(source, { name = name })
    end, false)
end

function Framework.Notify(src, msg, type, duration)
    if IsDuplicityVersion() then
        TriggerClientEvent('chat:addMessage', src, { args = { msg } })
    else
        SetNotificationTextEntry('STRING')
        AddTextComponentSubstringPlayerName(msg)
        DrawNotification(false, true)
    end
end
