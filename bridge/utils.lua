function DebugPrint(...)
    if Config.Debug then
        print('[fiveous_charger]', ...)
    end
end

function GetItemConfig(name)
    for _, item in ipairs(Config.Items) do
        if item.name == name then return item end
    end
    return nil
end

function GetChargeableItems()
    local items = {}
    for _, item in ipairs(Config.Items) do
        if item.canChargeAtStation then
            items[#items + 1] = item
        end
    end
    return items
end
