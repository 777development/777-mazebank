QBCore = exports['qb-core']:GetCoreObject()
isLoggedIn = LocalPlayer.state['isLoggedIn']
currentThermiteGate = 0
CurrentCops = 0
IsDrilling = false
local closestBank = 0
local inElectronickitZone = false
local copsCalled = false
local refreshed = false
local currentLocker = 0

-- Handlers

--- This will reset the bank doors to the position that they should be in, so if the bank is still open, it will open the door and vise versa
--- @return nil
local function ResetBankDoors()
if not Config.MazeBanks["mazebank"]["isOpened"] then
        local mazeObject = GetClosestObjectOfType(Config.MazeBanks["mazebank"]["coords"]["x"], Config.MazeBanks["mazebank"]["coords"]["y"], Config.MazeBanks["mazebank"]["coords"]["z"], 5.0, Config.MazeBanks["mazebank"]["object"], false, false, false)
        SetObjectHeading(mazeObject, Config.MazeBanks["mazebank"]["heading"].closed)
    else
        local mazeObject = GetClosestObjectOfType(Config.MazeBanks["mazebank"]["coords"]["x"], Config.MazeBanks["mazebank"]["coords"]["y"], Config.MazeBanks["mazebank"]["coords"]["z"], 5.0, Config.MazeBanks["mazebank"]["object"], false, false, false)
        SetObjectHeading(mazeObject, Config.MazeBanks["mazebank"]["heading"].open)
    end
end