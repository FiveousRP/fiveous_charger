Config = {}

Config.Debug = false

-- 'qb-core' | 'qbox' | 'es_extended' | 'standalone'
Config.Framework = 'qb-core'

-- 'framework' | 'ox_lib' | 'custom'
Config.Notifications = 'framework'

-- 'ox_inventory' | 'qb-inventory' | 'tgiann-inventory' | 'qs-inventory' | 'codesign-inventory'
-- note: qbox uses ox_inventory by default
Config.Inventory = 'ox_inventory'

-- 'qb-target' | 'ox_target' | 'qtarget' | 'interact' | 'none'
-- 'none' uses draw text + E key
Config.Target = 'ox_target'

Config.Phone = {
    Enabled = true,
    Resource = 'lb-phone',
    UniquePhone = true,
}

Config.UI = {
    BrandName = 'FIVEOUS',
    BrandColor = '#ff69b4',
    BrandColorRGB = '255, 105, 180',
    BrandGradientFrom = '#ff1493',
    BrandGradientTo = '#ff69b4',
    UpdateInterval = 100,
    ShowPercentage = true,
    ShowTime = true,
    HideKeybind = 'BACKSPACE',
    CompletionPopupDuration = 4000,
}

--[[
    name             - item spawn name
    label            - display name
    icon             - emoji for the widget
    type             - 'charger' charges the phone, 'chargeable' holds its own charge
    useable          - register as useable item (false = skip, useful if another script handles it)
    metaField        - metadata key that stores charge (nil = infinite / no meta)
    defaultCharge    - starting charge on first use / purchase
    maxCharge        - cap
    chargeRate       - %/s added to phone (charger only)
    depleteRate      - %/s lost while charging phone (charger only)
    requireVehicle   - must be in a vehicle
    requireEngine    - engine must be running
    canChargeAtStation - rechargeable at world stations
    stationChargeRate  - %/s when charging at station
]]
Config.Items = {
    {
        name = 'powerbank',
        label = 'Power Bank',
        icon = '🔋',
        type = 'charger',
        useable = true,
        metaField = 'charge',
        defaultCharge = 100,
        maxCharge = 100,
        chargeRate = 2.0,
        depleteRate = 0.5,
        requireVehicle = false,
        requireEngine = false,
        canChargeAtStation = true,
        stationChargeRate = 1.5,
    },
    {
        name = 'carcharger',
        label = 'Car Charger',
        icon = '🚗',
        type = 'charger',
        useable = true,
        metaField = nil,
        defaultCharge = nil,
        maxCharge = nil,
        chargeRate = 1.5,
        depleteRate = 0,
        requireVehicle = true,
        requireEngine = true,
        canChargeAtStation = false,
        stationChargeRate = 0,
    },
    -- uncomment these if you run fiveous_drone
    -- {
    --     name = 'fiveous_battery',
    --     label = 'Fiveous Battery',
    --     icon = '🔋',
    --     type = 'chargeable',
    --     useable = true,
    --     metaField = 'charge',
    --     defaultCharge = 100,
    --     maxCharge = 100,
    --     chargeRate = 0,
    --     depleteRate = 0,
    --     requireVehicle = false,
    --     requireEngine = false,
    --     canChargeAtStation = true,
    --     stationChargeRate = 2.0,
    -- },
    -- {
    --     name = 'fiveous_drone',
    --     label = 'Fiveous Drone',
    --     icon = '🛸',
    --     type = 'chargeable',
    --     useable = false,
    --     metaField = 'battery',
    --     defaultCharge = 100,
    --     maxCharge = 100,
    --     chargeRate = 0,
    --     depleteRate = 0,
    --     requireVehicle = false,
    --     requireEngine = false,
    --     canChargeAtStation = true,
    --     stationChargeRate = 1.0,
    -- },
}

Config.RechargeStations = {
    Enabled = true,
    PhoneChargeRate = 1.0,

    Blip = {
        Enabled = true,
        Sprite = 521,
        Color = 8,
        Scale = 0.7,
        Display = 4,
        Label = 'Charging Station',
    },

    Target = {
        Icon = 'fas fa-charging-station',
        Label = 'Use Charging Station',
        Distance = 2.0,
    },

    Locations = {
        { coords = vector3(392.615, -831.758, 29.292), heading = 0.0, label = 'Charging Station' },
        -- OTHER DIGITAL DEN LOCATIONS (MLOS)
        -- { coords = vector3(-39.314, -1036.125, 28.513), heading = 0.0, label = 'Charging Station' },
        -- { coords = vector3(-1315.79, -396.36, 36.59), heading = 0.0, label = 'Charging Station' },
        -- { coords = vector3(-655.54, -856.04, 24.50), heading = 0.0, label = 'Charging Station' },
        -- { coords = vector3(1134.433, -476.474, 66.545), heading = 0.0, label = 'Charging Station' },
        -- { coords = vector3(1655.777, 4847.968, 41.999), heading = 0.0, label = 'Charging Station' },
    },
}
