RegisterNetEvent('777-mazebank:client:ClearTimeoutDoors', function()
    Config.DoorlockAction(4, true)
    local MazeObject = GetClosestObjectOfType(Config.MazeBanks["mazebank"]["coords"]["x"], Config.MazeBanks["mazebank"]["coords"]["y"], Config.MazeBanks["mazebank"]["coords"]["z"], 5.0, Config.MazeBanks["mazebank"]["object"], false, false, false)
    if MazeObject ~= 0 then
        SetObjectHeading(MazeObject, Config.MazeBanks["mazebank"]["heading"].closed)
    end
    for k in pairs(Config.MazeBanks["mazebank"]["lockers"]) do
        Config.MazeBanks["mazebank"]["lockers"][k]["isBusy"] = false
        Config.MazeBanks["mazebank"]["lockers"][k]["isOpened"] = false
    end
    Config.MazeBanks["mazebank"]["isOpened"] = false
end)

RegisterNetEvent('777-mazebank:server:OpenMazeBank', function()
    while true do
        local ped = PlayerPedId()
        local pos = GetObjectCoords(ped)
        local MazeDist = #(pos - Config.MazeBanks["mazebank"]["coords"])
        if MazeDist < 15 then
            if Config.MazeBanks["mazebank"]["isOpened"] then
                Config.DoorlockAction(4, false)
                local object = GetClosestObjectOfType(Config.MazeBanks["mazebank"]["coords"]["x"], Config.MazeBanks["mazebank"]["coords"]["y"], Config.MazeBanks["mazebank"]["coords"]["z"], 5.0, Config.MazeBanks["mazebank"]["object"], false, false, false)
                if object ~= 0 then
                    SetObjectHeading(object, Config.MazeBanks["mazebank"]["heading"].open)
                end
            else
                Config.DoorlockAction(4, true)
                local object = GetClosestObjectOfType(Config.MazeBanks["mazebank"]["coords"]["x"], Config.MazeBanks["mazebank"]["coords"]["y"], Config.MazeBanks["mazebank"]["coords"]["z"], 5.0, Config.MazeBanks["mazebank"]["object"], false, false, false)
                if object ~= 0 then
                    SetObjectHeading(object, Config.MazeBanks["mazebank"]["heading"].closed)
                end
            end
        end
        Wait(1000)
    end
end)
