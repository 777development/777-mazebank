local QBCore = exports['qb-core']:GetCoreObject()
local robberyBusy = false
local timeOut = false

-- Functions

--- This will convert a table's keys into an array
--- @param tbl table
--- @return array
local function TableKeysToArray(tbl)
    local array = {}
    for k in pairs(tbl) do
        array[#array+1] = k
    end
    return array
end

--- This will loop over the given table to check if the power stations in the table have been hit
--- @param toLoop table
--- @return boolean
local function TableLoopStations(toLoop)
    local hits = 0
    for _, station in pairs(toLoop) do
        if type(station) == 'table' then
            local hits2 = 0
            for _, station2 in pairs(station) do
                if Config.PowerStations[station2].hit then hits2 += 1 end
                if hits2 == #station then return true end
            end
        else
            if Config.PowerStations[station].hit then hits += 1 end
            if hits == #toLoop then return true end
        end
    end
    return false
end

--- This will check what stations have been hit and update them accordingly
--- @return nil
local function CheckStationHits()
    local policeHits = {}
    local bankHits = {}

    for k, v in pairs(Config.CameraHits) do
        local allStationsHitPolice = false
        local allStationsHitBank = false
        if type(v.type) == 'table' then
            for _, cameraType in pairs(v.type) do
                if cameraType == 'police' then
                    if type(v.stationsToHitPolice) == 'table' then
                        allStationsHitPolice = TableLoopStations(v.stationsToHitPolice)
                    else
                        allStationsHitPolice = Config.PowerStations[v.stationsToHitPolice].hit
                    end
                elseif cameraType == 'bank' then
                    if type(v.stationsToHitBank) == 'table' then
                        allStationsHitBank = TableLoopStations(v.stationsToHitBank)
                    else
                        allStationsHitBank = Config.PowerStations[v.stationsToHitBank].hit
                    end
                end
            end
        else
            if v.type == 'police' then
                if type(v.stationsToHitPolice) == 'table' then
                    allStationsHitPolice = TableLoopStations(v.stationsToHitPolice)
                else
                    allStationsHitPolice = Config.PowerStations[v.stationsToHitPolice].hit
                end
            elseif v.type == 'bank' then
                if type(v.stationsToHitBank) == 'table' then
                    allStationsHitBank = TableLoopStations(v.stationsToHitBank)
                else
                    allStationsHitBank = Config.PowerStations[v.stationsToHitBank].hit
                end
            end
        end

        if allStationsHitPolice then
            policeHits[k] = true
        end

        if allStationsHitBank then
            bankHits[k] = true
        end
    end

    policeHits = TableKeysToArray(policeHits)
    bankHits = TableKeysToArray(bankHits)

    -- table.type checks if it's empty as well, if it's empty it will return the type 'empty' instead of 'array'
    if table.type(policeHits) == 'array' then Config.OnPoliceCameraHit(policeHits) end
    if table.type(bankHits) == 'array' then TriggerClientEvent("777-mazebank:client:BankSecurity", -1, bankHits, false) end
end

--- This will do a quick check to see if all stations have been hit
--- @return boolean
local function AllStationsHit()
    local hit = 0
    for k in pairs(Config.PowerStations) do
        if Config.PowerStations[k].hit then
            hit += 1
        end
    end
    return hit >= Config.HitsNeeded
end

--- This will check if the given coords are in the area of the given distance of a powerstation
--- @param coords vector3
--- @param dist number
--- @return boolean
local function IsNearPowerStation(coords, dist)
    for _, v in pairs(Config.PowerStations) do
        if #(coords - v.coords) < dist then
            return true
        end
    end
    return false
end

-- Events

RegisterNetEvent('777-mazebank:server:setBankState', function(bankId)
    if robberyBusy then return end
    if bankId == "mazebank" then
        if Config.MazeBanks["mazebank"]["isOpened"] or #(GetEntityCoords(GetPlayerPed(source)) - Config.MazeBanks["mazebank"]["coords"]) > 2.5 then
            return error(Lang:t("error.event_trigger_wrong", {event = "777-mazebank:server:setBankState", extraInfo = " (mazebank) ", source = source}))
        end
        Config.MazeBanks["mazebank"]["isOpened"] = true
        TriggerEvent('777-mazebank:server:setTimeout')
    end
    TriggerClientEvent('777-mazebank:client:setBankState', -1, bankId)
    robberyBusy = true
    Config.OnRobberyStart(bankId)
end)

RegisterNetEvent('777-mazebank:server:setLockerState', function(bankId, lockerId, state, bool)
    if bankId == "mazebank" then
        if #(GetObjectCoords(GetPlayerPed(source)) - Config.MazeBanks[bankId]["lockers"][lockerId]["coords"]) > 2.5 then
            return error(Lang:t("error.event_trigger_wrong", {event = "777-mazebank:server:setLockerState", extraInfo = " ("..bankId..") ", source = source}))
        end
        Config.MazeBanks[bankId]["lockers"][lockerId][state] = bool
    end
    TriggerClientEvent('777-mazebank:client:setLockerState', -1, bankId, lockerId, state, bool)
end)

AddEventHandler('777-mazebank:server:setTimeout', function()
    if robberyBusy or timeOut then return end
    timeOut = true
    CreateThread(function()
        SetTimeout(60000 * 90, function()
            for k in pairs(Config.MazeBanks["mazebank"]["lockers"]) do
                Config.MazeBanks["mazebank"]["lockers"][k]["isBusy"] = false
                Config.MazeBanks["mazebank"]["lockers"][k]["isOpened"] = false
            end
            TriggerClientEvent('777-mazebank:client:ClearTimeoutDoors', -1)
            Config.MazeBanks["mazebank"]["isOpened"] = false
            timeOut = false
            robberyBusy = false
            Config.OnRobberyTimeoutEnd("mazebank")
        end)
    end)
end)

RegisterNetEvent('777-mazebank:Server:AddItem', function(item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(item, amount)
end)

RegisterNetEvent('777-mazebank:Client:GiveGold')
AddEventHandler("777-mazebank:Client:GiveGold", function()
    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, "CODE_HUMAN_MEDIC_TEND_TO_DEAD")
    progressBar("Opening Vault ...")
    TriggerServerEvent("777-mazebank:Server:AddItem", "goldbar", 1)
    TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items["goldbar"], "add", 1)
end)

RegisterNetEvent('777-mazebank:server:callCops', function(type, bank, coords)
    if type == "mazebank" then
        if not Config.MazeBanks["mazebank"]["alarm"] then
            return error(Lang:t("error.event_trigger_wrong", {event = "777-mazebank:server:callCops", extraInfo = " (mazebank) ", source = source}))
        end
    end
    TriggerClientEvent("777-mazebank:client:robberyCall", -1, type, coords)
end)

RegisterNetEvent('777-mazebank:server:SetStationStatus', function(key, isHit)
    Config.PowerStations[key].hit = isHit
    TriggerClientEvent("777-mazebank:client:SetStationStatus", -1, key, isHit)
    if AllStationsHit() then
        exports["qb-weathersync"]:setBlackout(true)
        TriggerClientEvent("777-mazebank:client:disableAllBankSecurity", -1)
        Config.OnBlackout(true)
        CreateThread(function()
            SetTimeout(60000 * Config.BlackoutTimer, function()
                exports["qb-weathersync"]:setBlackout(false)
                TriggerClientEvent("777-mazebank:client:enableAllBankSecurity", -1)
                Config.OnBlackout(false)
            end)
        end)
    else
        CheckStationHits()
    end
end)

RegisterNetEvent('777-mazebank:server:removeElectronicKit', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.RemoveItem('electronickit', 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["electronickit"], "remove")
    Player.Functions.RemoveItem('trojan_usb', 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["trojan_usb"], "remove")
end)

RegisterNetEvent('777-mazebank:server:removeBankCard', function(number)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local pos = GetEntityCoords(ped)
    local MazeDist = #(pos - Config.MazeBanks["mazebank"]["coords"])
    if not Player then return end
    Player.Functions.RemoveItem('security_card_'..number, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['security_card_'..number], "remove")
end)

RegisterNetEvent('thermite:StartServerFire', function(coords, maxChildren, isGasFire)
    local src = source
    local ped = GetPlayerPed(src)
    local coords2 = GetObjectCoords(ped)
    local thermite3Coords = Config.MazeBanks['mazebank'].thermite[1].coords
    if #(coords2 - thermiteCoords) < 10 or #(coords2 - thermite2Coords) < 10 or #(coords2 - thermite3Coords) < 10 or IsNearPowerStation(coords2, 10) then
        TriggerClientEvent("thermite:StartFire", -1, coords, maxChildren, isGasFire)
    end
end)

RegisterNetEvent('thermite:StopFires', function()
    TriggerClientEvent("thermite:StopFires", -1)
end)

-- Callbacks

QBCore.Functions.CreateCallback('777-mazebank:server:isRobberyActive', function(_, cb)
    cb(robberyBusy)
end)

QBCore.Functions.CreateCallback('777-mazebank:server:GetConfig', function(_, cb)
    cb(Config.PowerStations, Config.MazeBanks)
end)

QBCore.Functions.CreateCallback("thermite:server:check", function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(false) end
    if Player.Functions.RemoveItem("thermite", 1) then
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items["thermite"], "remove")
        cb(true)
    else
        cb(false)
    end
end)

-- Items

QBCore.Functions.CreateUseableItem("thermite", function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player or not Player.Functions.GetItemByName('thermite') then return end
	if Player.Functions.GetItemByName('lighter') then
        TriggerClientEvent("thermite:UseThermite", source)
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.missing_ignition_source"), "error")
    end
end)

QBCore.Functions.CreateUseableItem("security_card_01", function(source)
    local Player = QBCore.Functions.GetPlayer(source)
	if not Player or not Player.Functions.GetItemByName('security_card_01') then return end
    TriggerClientEvent("777-mazebank:UseBankcardA", source)
end)

QBCore.Functions.CreateUseableItem("electronickit", function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player or not Player.Functions.GetItemByName('electronickit') then return end
    TriggerClientEvent("electronickit:UseElectronickit", source)
end)


RegisterNetEvent('777-mazebank:server:DeleteObject', function(netId)
    local object = NetworkGetEntityFromNetworkId(netId)
	DeleteEntity(object)
end)
