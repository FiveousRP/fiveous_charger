local framework = Config.Framework or 'standalone'
local path = ('bridge/framework/%s'):format(framework)

local src = LoadResourceFile(GetCurrentResourceName(), path .. '.lua')
local chunk, err = load(src, '@fiveous_charger/' .. path .. '.lua', 't', _ENV)
if chunk then
    chunk()
    DebugPrint('Loaded framework bridge:', framework)
else
    print('^1[fiveous_charger] Failed to load framework bridge: ' .. (err or framework) .. '^7')
    Framework = {}
    Framework.GetPlayer = function() return nil end
    Framework.GetPlayerData = function() return {} end
    Framework.RegisterUsableItem = function() end
    Framework.Notify = function() end
end
