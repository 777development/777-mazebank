Config = Config or {}

--- This function gets triggered whenever one or more PowerStations have been hit
--- @param hits array
--- @return nil
function Config.OnPoliceCameraHit(hits)
    TriggerClientEvent("police:client:SetCamera", -1, hits, false)
end

--- This is called whenever a bank robbery is started, after a hack is done or a card is used, in this function you can do extra stuff after it has started
--- @param bankId number | string
--- @return nil
function Config.OnRobberyStart(bankId)
    local bankName = type(bankId) == "number" and "bankrobbery" or bankId
    if bankName ~= "bankrobbery" then return end
    TriggerEvent('qb-banking:server:SetBankClosed', bankId, true)
end

--- This is called whenever a bank robbery's timeout has ended
--- @param bankId string | number
--- @return nil
function Config.OnRobberyTimeoutEnd(bankId)
    local bankName = type(bankId) == "number" and "bankrobbery" or bankId
    if bankName ~= "bankrobbery" then return end
    TriggerEvent('qb-banking:server:SetBankClosed', bankId, false)
end

--- This will be called once a blackout starts or ends
--- @param isBlackout boolean
--- @return nil
function Config.OnBlackout(isBlackout)
    if isBlackout then
        TriggerClientEvent("police:client:DisableAllCameras", -1)
    else
        TriggerClientEvent("police:client:EnableAllCameras", -1)
    end
end

Config.HitsNeeded = 13 -- The amount of powerstation needed to be hit to cause a blackout
Config.BlackoutTimer = 10 -- The amount of minutes a blackout will take until all power comes back

Config.RewardTypes = {
    [1] = {
        type = "item"
    },
    [2] = {
        type = "money"
    }
}

Config.LockerRewardsMaze = {
    ["tier1"] = {
        [1] = {item = "goldchain", minAmount = 10, maxAmount = 20},
    },
    ["tier2"] = {
        [1] = {item = "rolex", minAmount = 10, maxAmount = 20},
    },
    ["tier3"] = {
        [1] = {item = "goldbar", minAmount = 2, maxAmount = 4},
    },
}