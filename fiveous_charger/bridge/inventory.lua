Inventory = {}

local inv = Config.Inventory

function Inventory.GetItemBySlot(src, slot)
    slot = tonumber(slot)

    if inv == 'tgiann-inventory' then
        return exports['tgiann-inventory']:GetItemBySlot(src, slot)

    elseif inv == 'ox_inventory' then
        local items = exports.ox_inventory:GetInventoryItems(src, false)
        if not items then return nil end
        for _, item in pairs(items) do
            if item.slot == slot then return item end
        end
        return nil

    elseif inv == 'qs-inventory' then
        local ok, result = pcall(function()
            return exports['qs-inventory']:GetItemBySlot(src, slot)
        end)
        return ok and result or nil

    elseif inv == 'qb-inventory' then
        local Player = Framework.GetPlayer(src)
        if Player and Player.PlayerData then
            local items = Player.PlayerData.items
            return items and items[slot] or nil
        end
        return nil

    elseif inv == 'codesign-inventory' then
        local ok, result = pcall(function()
            return exports['codesign-inventory']:GetItemBySlot(src, slot)
        end)
        return ok and result or nil
    end

    return nil
end

function Inventory.GetMeta(item)
    if not item then return {} end
    return item.metadata or item.info or {}
end

function Inventory.GetName(item)
    if not item then return nil end
    return item.name or item.Name
end

function Inventory.UpdateMeta(src, itemName, slot, key, value)
    slot = tonumber(slot)
    local item = Inventory.GetItemBySlot(src, slot)
    if not item then return false end

    local meta = Inventory.GetMeta(item)
    meta[key] = value

    if inv == 'tgiann-inventory' then
        if item.metadata then item.metadata[key] = value end
        if item.info then item.info[key] = value end
        pcall(function()
            if exports['tgiann-inventory'].UpdateItemMetadata then
                exports['tgiann-inventory']:UpdateItemMetadata(src, itemName, slot, meta)
            end
        end)
        pcall(function()
            if exports['tgiann-inventory'].SetItemData then
                exports['tgiann-inventory']:SetItemData(src, itemName, slot, meta)
            end
        end)

    elseif inv == 'ox_inventory' then
        exports.ox_inventory:SetMetadata(src, slot, meta)

    elseif inv == 'qs-inventory' then
        pcall(function()
            exports['qs-inventory']:SetItemMetadata(src, slot, meta)
        end)

    elseif inv == 'qb-inventory' then
        local Player = Framework.GetPlayer(src)
        if Player and Player.PlayerData.items and Player.PlayerData.items[slot] then
            Player.PlayerData.items[slot].info = meta
            Player.Functions.SetInventory(Player.PlayerData.items)
        end

    elseif inv == 'codesign-inventory' then
        pcall(function()
            exports['codesign-inventory']:SetItemMetadata(src, slot, meta)
        end)
    end

    return true
end

function Inventory.FindItem(src, itemName)
    -- use native search when available
    if inv == 'ox_inventory' then
        local ok, items = pcall(function()
            return exports.ox_inventory:Search(src, 'slots', itemName)
        end)
        if ok and items and #items > 0 then
            return items[1], items[1].slot
        end
        return nil, nil
    end

    if inv == 'qs-inventory' then
        local ok, items = pcall(function()
            return exports['qs-inventory']:Search(src, 'slots', itemName)
        end)
        if ok and items and #items > 0 then
            return items[1], items[1].slot
        end
    end

    -- fallback: walk slots
    for i = 1, 100 do
        local item = Inventory.GetItemBySlot(src, i)
        if item and Inventory.GetName(item) == itemName then
            return item, i
        end
    end
    return nil, nil
end
