Framework = {}

function Framework.GetPlayer(src)
    return exports.qbx_core:GetPlayer(src)
end

function Framework.GetPlayerData()
    return exports.qbx_core:GetPlayerData()
end

function Framework.RegisterUsableItem(name, cb)
    -- qbox ships with ox_inventory, register through it
    local ok = pcall(function()
        exports.ox_inventory:RegisterUsableItem(name, function(playerData, item)
            local src = playerData.source or source
            cb(src, item)
        end)
    end)

    if not ok then
        pcall(function()
            exports.qbx_core:CreateUseableItem(name, cb)
        end)
    end
end

function Framework.Notify(src, msg, type, duration)
    local ntype = 'inform'
    if type == 'error' then ntype = 'error'
    elseif type == 'success' then ntype = 'success' end

    if IsDuplicityVersion() then
        TriggerClientEvent('ox_lib:notify', src, {
            description = msg,
            type = ntype,
            duration = duration or 3000,
        })
    else
        exports.ox_lib:notify({
            description = msg,
            type = ntype,
            duration = duration or 3000,
        })
    end
end
