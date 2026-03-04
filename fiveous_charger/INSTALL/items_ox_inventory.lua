-- Add these to your ox_inventory/data/items.lua

['powerbank'] = {
    label = 'Power Bank',
    description = 'Portable charger for phones. Rechargeable at charging stations.',
    weight = 50,
    stack = false,
    close = true,
    client = {
        image = 'powerbank.png',
    },
},

['carcharger'] = {
    label = 'Car Charger',
    description = '12V adapter for charging phones in vehicles.',
    weight = 50,
    stack = true,
    close = true,
    client = {
        image = 'carcharger.png',
    },
},
