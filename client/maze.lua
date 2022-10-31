local inBankCardAZone = false
local currentLocker = 0
local copsCalled = false

local QBCore = exports['qb-core']:GetCoreObject()


-- Functions

--- This will load an animation dictionary so you can play an animation in that dictionary
--- @param dict string
--- @return nil
local function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
end

-- Events

RegisterNetEvent('777-mazebank:UseBankcardA', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    Config.OnEvidence(pos, 85)
    if not inBankCardAZone then return end
    QBCore.Functions.TriggerCallback('777-mazebank:server:isRobberyActive', function(isBusy)
        if not isBusy then
            if CurrentCops >= Config.MinimumMazePolice then
                if not Config.MazeBanks["mazebank"]["isOpened"] then
                    Config.ShowRequiredItems(nil, false)
                    loadAnimDict("anim@gangops@facility@servers@")
                    TaskPlayAnim(ped, 'anim@gangops@facility@servers@', 'hotwire', 3.0, 3.0, -1, 1, 0, false, false, false)
                    QBCore.Functions.Progressbar("security_pass", Lang:t("general.validating_bankcard"), math.random(3000, 5000), false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    }, {}, {}, {}, function() -- Done
                        StopAnimTask(ped, "anim@gangops@facility@servers@", "hotwire", 1.0)
                        TriggerServerEvent('777-mazebank:server:setBankState', 'mazebank')
                        TriggerServerEvent('777-mazebank:server:removeBankCard', '01')
                        Config.DoorlockAction(4, false)
                        if copsCalled or not Config.MazeBanks["mazebank"]["alarm"] then return end
                        TriggerServerEvent("777-mazebank:server:callCops", "mazebank", 0, pos)
                        local MazeObject = GetClosestObjectOfType(Config.MazeBanks["mazebank"]["coords"]["x"], Config.MazeBanks["mazebank"]["coords"]["y"], Config.MazeBanks["mazebank"]["coords"]["z"], 5.0, Config.MazeBanks["mazebank"]["object"], false, false, false)
                        if MazeObject ~= 0 then
                            SetEntityHeading(MazeObject, Config.MazeBanks["mazebank"]["heading"].open)
                        end
                        copsCalled = true
                    end, function() -- Cancel
                        StopAnimTask(ped, "anim@gangops@facility@servers@", "hotwire", 1.0)
                        QBCore.Functions.Notify(Lang:t("error.cancel_message"), "error")
                    end)
                else
                    QBCore.Functions.Notify(Lang:t("error.bank_already_open"), "error")
                end
            else
                QBCore.Functions.Notify(Lang:t("error.minimum_police_required", {police = Config.MinimumMazePolice}), "error")
            end
        else
            QBCore.Functions.Notify(Lang:t("error.security_lock_active"), "error", 5500)
        end
    end)
end)

-- Threads

CreateThread(function()
    local bankCardAZone = BoxZone:Create(Config.MazeBanks["mazebank"]["coords"], 1.0, 1.0, {
        name = 'mazebank_coords_bankcarda',
        heading = Config.MazeBanks["mazebank"]["coords"].closed,
        minZ = Config.MazeBanks["mazebank"]["coords"].z - 1,
        maxZ = Config.MazeBanks["mazebank"]["coords"].z + 1,
        debugPoly = false
    })
    bankCardAZone:onPlayerInOut(function(inside)
        inBankCardAZone = inside
        if inside and not Config.MazeBanks["mazebank"]["isOpened"] then
            Config.ShowRequiredItems({
                [1] = {name = QBCore.Shared.Items["security_card_01"]["name"], image = QBCore.Shared.Items["security_card_01"]["image"]}
            }, true)
        else
            Config.ShowRequiredItems({
                [1] = {name = QBCore.Shared.Items["security_card_01"]["name"], image = QBCore.Shared.Items["security_card_01"]["image"]}
            }, false)
        end
    end)
    local thermite1Zone = BoxZone:Create(Config.MazeBanks["mazebank"]["thermite"][1]["coords"], 1.0, 1.0, {
        name = 'mazebank_coords_thermite_1',
        heading = Config.MazeBanks["mazebank"]["heading"].closed,
        minZ = Config.MazeBanks["mazebank"]["thermite"][1]["coords"].z - 1,
        maxZ = Config.MazeBanks["mazebank"]["thermite"][1]["coords"].z + 1,
        debugPoly = false
    })
    thermite1Zone:onPlayerInOut(function(inside)
        if inside and not Config.MazeBanks["mazebank"]["thermite"][1]["isOpened"] then
            currentThermiteGate = Config.MazeBanks["mazebank"]["thermite"][1]["doorId"]
            Config.ShowRequiredItems({
                [1] = {name = QBCore.Shared.Items["thermite"]["name"], image = QBCore.Shared.Items["thermite"]["image"]},
            }, true)
        else
            if currentThermiteGate == Config.MazeBanks["mazebank"]["thermite"][1]["doorId"] then
                currentThermiteGate = 0
                Config.ShowRequiredItems({
                    [1] = {name = QBCore.Shared.Items["thermite"]["name"], image = QBCore.Shared.Items["thermite"]["image"]},
                }, false)
            end
        end
    end)
    for k in pairs(Config.MazeBanks["mazebank"]["lockers"]) do
        if Config.UseTarget then
            exports['qb-target']:AddBoxZone('mazebank_coords_locker_'..k, Config.MazeBanks["mazebank"]["lockers"][k]["coords"], 1.0, 1.0, {
                name = 'mazebank_coords_locker_'..k,
                heading = Config.MazeBanks["mazebank"]["heading"].closed,
                minZ = Config.MazeBanks["mazebank"]["lockers"][k]["coords"].z - 1,
                maxZ = Config.MazeBanks["mazebank"]["lockers"][k]["coords"].z + 1,
                debugPoly = false
            }, {
                options = {
                    {
                        action = function()
                            openLocker("mazebank", k)
                        end,
                        canInteract = function()
                            return not IsDrilling and Config.MazeBanks["mazebank"]["isOpened"] and not Config.MazeBanks["mazebank"]["lockers"][k]["isBusy"] and not Config.MazeBanks["mazebank"]["lockers"][k]["isOpened"]
                        end,
                        icon = 'fa-solid fa-vault',
                        label = Lang:t("general.break_safe_open_option_target"),
                    },
                },
                distance = 1.5
            })
        else
            local lockerZone = BoxZone:Create(Config.MazeBanks["mazebank"]["lockers"][k]["coords"], 1.0, 1.0, {
                name = 'mazebank_coords_locker_'..k,
                heading = Config.MazeBanks["mazebank"]["heading"].closed,
                minZ = Config.MazeBanks["mazebank"]["lockers"][k]["coords"].z - 1,
                maxZ = Config.MazeBanks["mazebank"]["lockers"][k]["coords"].z + 1,
                debugPoly = false
            })
            lockerZone:onPlayerInOut(function(inside)
                if inside and not IsDrilling and Config.MazeBanks["mazebank"]["isOpened"] and not Config.MazeBanks["mazebank"]["lockers"][k]["isBusy"] and not Config.MazeBanks["mazebank"]["lockers"][k]["isOpened"] then
                    exports['qb-core']:DrawText(Lang:t("general.break_safe_open_option_drawtext"), 'right')
                    currentLocker = k
                else
                    if currentLocker == k then
                        currentLocker = 0
                        exports['qb-core']:HideText()
                    end
                end
            end)
        end
    end
    if not Config.UseTarget then
        while true do
            local sleep = 1000
            if isLoggedIn then
                if currentLocker ~= 0 and not IsDrilling and Config.MazeBanks["mazebank"]["isOpened"] and not Config.MazeBanks["mazebank"]["lockers"][currentLocker]["isBusy"] and not Config.MazeBanks["mazebank"]["lockers"][currentLocker]["isOpened"] then
                    sleep = 0
                    if IsControlJustPressed(0, 38) then
                        exports['qb-core']:KeyPressed()
                        Wait(500)
                        exports['qb-core']:HideText()
                        if CurrentCops >= Config.MinimumMazePolice then
                            openLocker("mazebank", currentLocker)
                        else
                            QBCore.Functions.Notify(Lang:t("error.minimum_police_required", {police = Config.MinimumMazePolice}), "error")
                        end
                        sleep = 1000
                    end
                end
            end
            Wait(sleep)
        end
    end
end)

exports['qb-target']:AddBoxZone("firewallStick", vector3(-1311.73, -824.14, 17.15), 1, 1, {
	name = "firewallStick",
	heading = 11.0,
	debugPoly = false,
	minZ = 1.77834,
	maxZ = 300.87834,
}, {
	options = {
		{
            event = "qb-menu:client:fireMenu",
			icon = "fas fa-sign-in-alt",
			label = "view Computer...",
		},
	},
	distance = 2.5
})

exports['qb-target']:AddBoxZone("firewallStick", vector3(-1310.51, -822.95, 17.15), 1, 1, {
	name = "firewallStick",
	heading = 11.0,
	debugPoly = false,
	minZ = 1.77834,
	maxZ = 300.87834,
}, {
	options = {
		{
            event = "qb-menu:client:fireMenu",
			icon = "fas fa-sign-in-alt",
			label = "view Computer...",
		},
	},
	distance = 2.5
})

exports['qb-target']:AddBoxZone("firewallStick", vector3(-1309.08, -822.25, 17.15), 1, 1, {
	name = "firewallStick",
	heading = 11.0,
	debugPoly = false,
	minZ = 1.77834,
	maxZ = 300.87834,
}, {
	options = {
		{
            event = "qb-menu:client:fireMenu",
			icon = "fas fa-sign-in-alt",
			label = "view Computer...",
		},
	},
	distance = 2.5
})

exports['qb-target']:AddBoxZone("firewallStick", vector3(-1307.79, -821.42, 17.15), 1, 1, {
	name = "firewallStick",
	heading = 11.0,
	debugPoly = false,
	minZ = 1.77834,
	maxZ = 300.87834,
}, {
	options = {
		{
            event = "qb-menu:client:fireMenu",
			icon = "fas fa-sign-in-alt",
			label = "view Computer...",
		},
	},
	distance = 2.5
})


RegisterCommand('fireStick', function()
    exports['qb-menu']:openMenu({
        {
            header = 'Computer Menu',
            icon = 'fas fa-code',
            isMenuHeader = true, -- Set to true to make a nonclickable title
        },
        {
            header = 'Turn Off cameras...',
            txt = 'Turn Off cameras...',
            icon = 'fas fa-code-merge',
            params = {
                event = '777-menuHacking:client:hackingMenu', 
                args = {
		    message = 'This was called by clicking a button'
                }
            }
        },  
    })
end)

RegisterNetEvent('qb-menu:client:fireMenu', function()
    ExecuteCommand('fireStick')
end)

RegisterNetEvent('777-menuHacking:client:hackingMenu', function()
    exports['ps-ui']:VarHack(function(success)
    if success then
        print("success")
        TriggerClientEvent("police:client:DisableAllCameras", -1)
	else
		print("fail")
	end
 end, 2, 3) -- Number of Blocks, Time (seconds)
end)

exports['qb-target']:AddBoxZone("locker1", vector3(-1310.28, -814.56, 17.15), 1, 1, {
	name = "locker1",
	heading = 11.0,
	debugPoly = false,
	minZ = 1.77834,
	maxZ = 300.87834,
}, {
	options = {
		{
            event = "777-mazebank:client:GiveGold",
			icon = "fa-solid fa-vault",
			label = "Open Lockers...",
		},
	},
	distance = 2.5
})

exports['qb-target']:AddBoxZone("locker-2", vector3(-1311.97, -812.61, 17.15), 1, 1, {
	name = "locker-2",
	heading = 11.0,
	debugPoly = false,
	minZ = 1.77834,
	maxZ = 300.87834,
}, {
	options = {
		{
            event = "777-mazebank:client:GiveGold",
			icon = "fa-solid fa-vault",
			label = "Open Lockers...",
		},
	},
	distance = 2.5
})

exports['qb-target']:AddBoxZone("locker-3", vector3(-1311.66, -810.78, 17.15), 1, 1, {
	name = "locker-2",
	heading = 11.0,
	debugPoly = false,
	minZ = 1.77834,
	maxZ = 300.87834,
}, {
	options = {
		{
            event = "777-mazebank:client:GiveGold",
			icon = "fa-solid fa-vault",
			label = "Open Lockers...",
		},
	},
	distance = 2.5
})

exports['qb-target']:AddBoxZone("locker-4", vector3(-1309.76, -809.3, 17.15), 1, 1, {
	name = "locker-2",
	heading = 11.0,
	debugPoly = false,
	minZ = 1.77834,
	maxZ = 300.87834,
}, {
	options = {
		{
            event = "777-mazebank:client:GiveGold",
			icon = "fa-solid fa-vault",
			label = "Open Lockers...",
		},
	},
	distance = 2.5
})

exports['qb-target']:AddBoxZone("locker-5", vector3(-1308.14, -809.77, 17.15), 1, 1, {
	name = "locker-2",
	heading = 11.0,
	debugPoly = false,
	minZ = 1.77834,
	maxZ = 300.87834,
}, {
	options = {
		{
            event = "777-mazebank:client:GiveGold",
			icon = "fa-solid fa-vault",
			label = "Open Lockers...",
		},
	},
	distance = 2.5
})

exports['qb-target']:AddBoxZone("locker-6", vector3(-1306.48, -811.49, 17.15), 1, 1, {
	name = "locker-2",
	heading = 11.0,
	debugPoly = false,
	minZ = 1.77834,
	maxZ = 300.87834,
}, {
	options = {
		{
            event = "777-mazebank:client:GiveGold",
			icon = "fa-solid fa-vault",
			label = "Open Lockers...",
		},
	},
	distance = 2.5
})
