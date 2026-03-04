Phone = {}

local cfg = Config.Phone
local res = cfg.Resource

function Phone.IsEnabled()
    return cfg.Enabled
end

function Phone.HasPhone()
    if not cfg.Enabled then return false end
    local ok, result = pcall(function()
        if cfg.UniquePhone then
            local number = exports[res]:GetEquippedPhoneNumber()
            return exports[res]:HasPhoneItem(number)
        else
            return exports[res]:HasPhone()
        end
    end)
    return ok and result or false
end

function Phone.GetBattery()
    if not cfg.Enabled then return 100 end
    local ok, result = pcall(function()
        return exports[res]:GetBattery()
    end)
    return ok and result or 100
end

function Phone.SetBattery(amount)
    if not cfg.Enabled then return end
    pcall(function() exports[res]:SetBattery(amount) end)
end

function Phone.ToggleCharging(state)
    if not cfg.Enabled then return end
    pcall(function() exports[res]:ToggleCharging(state) end)
end
