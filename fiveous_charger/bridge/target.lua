Target = {}

local system = Config.Target

function Target.AddZone(name, coords, distance, options, debug)
    if system == 'qb-target' then
        exports['qb-target']:AddCircleZone(name, coords, distance, {
            name = name,
            debugPoly = debug or false,
        }, {
            options = options,
            distance = distance,
        })

    elseif system == 'ox_target' or system == 'interact' then
        local resource = system == 'interact' and 'interact' or 'ox_target'
        local oxOpts = {}
        for _, opt in ipairs(options) do
            oxOpts[#oxOpts + 1] = {
                name = name .. '_' .. opt.label,
                icon = opt.icon,
                label = opt.label,
                onSelect = opt.action,
            }
        end
        exports[resource]:addSphereZone({
            coords = coords,
            radius = distance,
            debug = debug or false,
            options = oxOpts,
        })

    elseif system == 'qtarget' then
        exports['qtarget']:AddCircleZone(name, coords, distance, {
            name = name,
            debugPoly = debug or false,
            useZ = true,
        }, {
            options = options,
            distance = distance,
        })
    end
end

function Target.RemoveZone(name)
    if system == 'qb-target' then
        pcall(function() exports['qb-target']:RemoveZone(name) end)
    elseif system == 'ox_target' or system == 'interact' then
        local resource = system == 'interact' and 'interact' or 'ox_target'
        pcall(function() exports[resource]:removeZone(name) end)
    elseif system == 'qtarget' then
        pcall(function() exports['qtarget']:RemoveZone(name) end)
    end
end
