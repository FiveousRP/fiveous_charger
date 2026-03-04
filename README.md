# fiveous_charger

Configurable charging system for FiveM. Charge phones, power banks, batteries, drones — anything with item metadata.

## Features

- **QBCore**, **Qbox**, **ESX**, or **standalone**
- **ox_inventory**, **qb-inventory**, **tgiann-inventory**, **qs-inventory**, **codesign-inventory**
- **qb-target**, **ox_target**, **qtarget**, **interact**, or draw-text fallback
- Phone charging is optional — disable `lb-phone` and use purely as an item charger
- Add any item from config — define metadata field, charge rates, depletion, vehicle requirements, station compatibility
- Players can **BACKSPACE** to hide the widget while charging, pops back on completion
- Configurable branding (logo, accent colors, gradients)
- No hard dependencies in the manifest

## Install

See [INSTALL/INSTALL.md](INSTALL/INSTALL.md) for full setup instructions per framework and inventory.

Quick version:
1. Drop `fiveous_charger` into resources
2. `ensure fiveous_charger` in server.cfg (after framework/inventory/phone)
3. Set `Config.Framework`, `Config.Inventory`, and `Config.Target` in `config.lua`
4. Add item definitions to your inventory (see `INSTALL/` for templates)
5. Restart

## Adding items

Each entry in `Config.Items` is either a `'charger'` (charges the phone) or `'chargeable'` (holds its own charge).

| Field | What it does |
|---|---|
| `name` | item spawn name |
| `label` | display name in UI |
| `icon` | emoji shown in widget |
| `type` | `'charger'` or `'chargeable'` |
| `useable` | register as useable item (false to skip if another script handles it) |
| `metaField` | metadata key for charge (nil = infinite) |
| `defaultCharge` | initial charge on purchase/craft |
| `maxCharge` | cap |
| `chargeRate` | %/s added to phone (charger only) |
| `depleteRate` | %/s drained from item while charging |
| `requireVehicle` | must be in vehicle |
| `requireEngine` | engine must be on |
| `canChargeAtStation` | rechargeable at world stations |
| `stationChargeRate` | %/s when at a station |

Example — adding a flashlight:

```lua
{
    name = 'flashlight',
    label = 'Flashlight',
    icon = '🔦',
    type = 'chargeable',
    metaField = 'battery',
    defaultCharge = 100,
    maxCharge = 100,
    chargeRate = 0,
    depleteRate = 0,
    requireVehicle = false,
    requireEngine = false,
    canChargeAtStation = true,
    stationChargeRate = 3.0,
},
```

No code changes needed, just add the entry and restart.

## Keybinds

- **BACKSPACE** — hide/show charging widget (rebindable in FiveM keybind settings)
- **E** — interact with station (only when `Config.Target = 'none'`)

## Debug

`Config.Debug = true` for verbose console output on both client and server.

## License

MIT
