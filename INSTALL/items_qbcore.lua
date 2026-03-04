-- Add these to your qb-core/shared/items.lua

['powerbank'] = {
    name = 'powerbank',
    label = 'Power Bank',
    weight = 50,
    type = 'item',
    image = 'powerbank.png',
    unique = true,
    useable = true,
    shouldClose = true,
    description = 'Portable charger for phones. Rechargeable at charging stations.',
},

['carcharger'] = {
    name = 'carcharger',
    label = 'Car Charger',
    weight = 50,
    type = 'item',
    image = 'carcharger.png',
    unique = false,
    useable = true,
    shouldClose = true,
    description = '12V adapter for charging phones in vehicles.',
},
