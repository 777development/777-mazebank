Config = Config or {}

--- This is called whenever an item check occurs
---
--- Accepted formats for `items`:
--- ```lua
--- 'itemName'
---
--- {'item1', 'item2', 'etc'}
---
--- {['item1'] = amount, ['item2'] = 2, ['etc' = 5]} -- the amount here is the amount needed of that item, if the amount variable is defined when this format is used, the amount variable will be prioritized
--- ```
--- @param items table | array | string
--- @param amount number | nil
--- @return boolean
function Config.HasItem(items, amount)
    return QBCore.Functions.HasItem(items, amount)
end

Config.PowerStations = {
    [1] = {
        coords = vector3(2835.24, 1505.68, 24.72),
        hit = false
    },
    [2] = {
        coords = vector3(2811.76, 1500.6, 24.72),
        hit = false
    },
    [3] = {
        coords = vector3(2137.73, 1949.62, 93.78),
        hit = false
    },
    [4] = {
        coords = vector3(708.92, 117.49, 80.95),
        hit = false
    },
    [5] = {
        coords = vector3(670.23, 128.14, 80.95),
        hit = false
    },
    [6] = {
        coords = vector3(692.17, 160.28, 80.94),
        hit = false
    },
    [7] = {
        coords = vector3(2459.16, 1460.94, 36.2),
        hit = false
    },
    [8] = {
        coords = vector3(2280.45, 2964.83, 46.75),
        hit = false
    },
    [9] = {
        coords = vector3(2059.68, 3683.8, 34.58),
        hit = false
    },
    [10] = {
        coords = vector3(2589.5, 5057.38, 44.91),
        hit = false
    },
    [11] = {
        coords = vector3(1343.61, 6388.13, 33.4),
        hit = false
    },
    [12] = {
        coords = vector3(236.61, 6406.1, 31.83),
        hit = false
    },
    [13] = {
        coords = vector3(-293.1, 6023.54, 31.54),
        hit = false
    }
}

Config.MazeBanks = {
    ["mazebank"] = {
        ["label"] = "Maze Bank",
        ["coords"] = vector3(-1306.15, -821.34, 17.15),
        ["alarm"] = true,
        ["object"] = 961976194,
        ["heading"] = {
            closed = 90.58,
            open = -122.95
        },
        ["thermite"] = {
            [1] = {
                ["coords"] = vector3(-1303.34, -819.53, 17.15),
                ["isOpened"] = false,
                ["doorId"] = 5
            }
        },
        ["camId"] = 50,
        ["isOpened"] = false,
        ["lockers"] = {
            [1] = {
                ["coords"] = vector3(-1307.07, -811.82, 17.15),
                ["isBusy"] = false,
                ["isOpened"] = false
            },
            [2] = {
                ["coords"] = vector3(-1307.79, -810.8, 17.15),
                ["isBusy"] = false,
                ["isOpened"] = false
            },
            [3] = {
                ["coords"] = vector3(-1308.49, -809.77, 17.15),
                ["isBusy"] = false,
                ["isOpened"] = false
            },
            [4] = {
                ["coords"] = vector3(-1309.14, -809.62, 17.15),
                ["isBusy"] = false,
                ["isOpened"] = false
            },
            [5] = {
                ["coords"] = vector3(-1310.31, -810.42, 17.15),
                ["isBusy"] = false,
                ["isOpened"] = false
            },
            [6] = {
                ["coords"] = vector3(-1311.24, -811.2, 17.15),
                ["isBusy"] = false,
                ["isOpened"] = false
            },
            [7] = {
                ["coords"] = vector3(-1311.38, -812.11, 17.15),
                ["isBusy"] = false,
                ["isOpened"] = false
            },
            [8] = {
                ["coords"] = vector3(-1310.25, -813.6, 17.15),
                ["isBusy"] = false,
                ["isOpened"] = false
            }
        }
    }
}
