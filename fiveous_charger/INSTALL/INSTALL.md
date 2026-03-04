# Installation Guide

## 1. Drop the resource

Copy the `fiveous_charger` folder into your server's `resources` directory.

## 2. Add to server.cfg

```
ensure fiveous_charger
```

Make sure it starts **after** your framework, inventory, phone, and target resources.

Example ordering:
```
ensure qb-core
ensure ox_inventory
ensure lb-phone
ensure qb-target
ensure fiveous_charger
```

## 3. Set your config

Open `config.lua` and set the framework, inventory, and target to match your server.

### Framework

| Value | For |
|---|---|
| `'qb-core'` | QBCore |
| `'qbox'` | Qbox |
| `'es_extended'` | ESX / ESX Legacy |
| `'standalone'` | No framework |

### Inventory

| Value | For | Metadata support |
|---|---|---|
| `'ox_inventory'` | ox_inventory (also used by Qbox) | Yes |
| `'qb-inventory'` | qb-inventory (default QBCore) | Yes (via `info`) |
| `'tgiann-inventory'` | tgiann-inventory | Yes |
| `'qs-inventory'` | qs-inventory | Yes |
| `'codesign-inventory'` | codesign-inventory | Yes |

> **Note:** The default ESX inventory (`es_extended` with database items) has limited metadata support. If you're on ESX and want full metadata (charge tracking, etc), use `ox_inventory` or `qs-inventory`.

### Target

| Value | For |
|---|---|
| `'qb-target'` | qb-target |
| `'ox_target'` | ox_target |
| `'qtarget'` | qtarget |
| `'interact'` | interact (Qbox) |
| `'none'` | No target — uses draw text + E key |

## 4. Add items to your inventory

Item definition files are in this `INSTALL/` folder. Pick the one for your inventory:

| File | Inventory |
|---|---|
| `items_qbcore.lua` | qb-core `shared/items.lua` |
| `items_ox_inventory.lua` | ox_inventory `data/items.lua` |
| `items_tgiann.lua` | tgiann-inventory items config |
| `items_qs_inventory.lua` | qs-inventory `shared/items.lua` |
| `items_esx.sql` | ESX database `items` table |

Copy the item entries into the right file for your setup.

### Item images

Copy the images from `INSTALL/images/` into your inventory's image folder:

- **ox_inventory**: `ox_inventory/web/images/`
- **qb-inventory**: `qb-inventory/html/images/`
- **tgiann-inventory**: `tgiann-inventory/html/images/`
- **qs-inventory**: `qs-inventory/html/images/`

> The `powerbank` and `carcharger` images are included. If you add custom items, provide your own images.

### Items with metadata

Items that track charge (`powerbank`, `fiveous_battery`, `fiveous_drone`) should be **unique / non-stackable** in your inventory config so they can hold individual metadata. The `carcharger` doesn't track charge (infinite use) so it can be stackable.

## 5. Phone setup (optional)

If you run `lb-phone` and want phone charging:

```lua
Config.Phone = {
    Enabled = true,
    Resource = 'lb-phone',
    UniquePhone = true,  -- set to false if your server doesn't use unique phones
}
```

If you don't use lb-phone, or don't want phone charging at all:

```lua
Config.Phone = {
    Enabled = false,
    Resource = 'lb-phone',
    UniquePhone = true,
}
```

The resource works fine with phone disabled — it just becomes an item-only charger.

## 6. Branding

Change the widget appearance in `Config.UI`:

```lua
Config.UI = {
    BrandName = 'YOUR SERVER',     -- text at the bottom of the widget
    BrandColor = '#ff69b4',        -- main accent color
    BrandColorRGB = '255, 105, 180',
    BrandGradientFrom = '#ff1493', -- gradient start
    BrandGradientTo = '#ff69b4',   -- gradient end
    HideKeybind = 'BACKSPACE',
    CompletionPopupDuration = 4000,
}
```

## 7. Restart

Restart the server or run `ensure fiveous_charger`. Check the server console for the startup print — it lists all registered items and stations.

If something doesn't load, enable `Config.Debug = true` for verbose logging.
