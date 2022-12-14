local RSGCore = exports['rsg-core']:GetCoreObject()
local SelectedHorseId = {}
local Horses

CreateThread(function()
    if GetCurrentResourceName() ~= "rsg-stable" then
        print("^1=====================================")
        print("^1SCRIPT NAME OTHER THAN ORIGINAL")
        print("^1YOU SHOULD STOP SCRIPT")
        print("^1CHANGE NAME TO: ^2rsg-stable^1")
        print("^1=====================================^0")
    end
end)

RegisterNetEvent("rsg-stable:UpdateHorseComponents", function(components, idhorse, MyHorse_entity)
    local src = source
    local encodedComponents = json.encode(components)
    local Player = RSGCore.Functions.GetPlayer(src)
    local Playercid = Player.PlayerData.citizenid
    local id = idhorse
    MySQL.Async.execute("UPDATE player_horses SET `components`=@components WHERE `citizenid`=@citizenid AND `id`=@id", {components = encodedComponents, citizenid = Playercid, id = id}, function(done)
        TriggerClientEvent("rsg-stable:client:UpdadeHorseComponents", src, MyHorse_entity, components)
    end)
end)

RegisterNetEvent("rsg-stable:CheckSelectedHorse", function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local Playercid = Player.PlayerData.citizenid

    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE `citizenid`=@citizenid;', {citizenid = Playercid}, function(horses)
        if #horses ~= 0 then
            for i = 1, #horses do
                if horses[i].selected == 1 then
                    TriggerClientEvent("rsg-stable:SetHorseInfo", src, horses[i].id, horses[i].citizenid, horses[i].model, horses[i].name, horses[i].components)
                end
            end
        end
    end)
end)

RegisterNetEvent("rsg-stable:AskForMyHorses", function()
    local src = source
    local horseId = nil
    local components = nil
    local Player = RSGCore.Functions.GetPlayer(src)
    local Playercid = Player.PlayerData.citizenid
    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE `citizenid`=@citizenid;', {citizenid = Playercid}, function(horses)
        if horses[1]then
            horseId = horses[1].id
        else
            horseId = nil
        end

        MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE `citizenid`=@citizenid;', {citizenid = Playercid}, function(components)
            if components[1] then
                components = components[1].components
            end
        end)
        TriggerClientEvent("rsg-stable:ReceiveHorsesData", src, horses)
    end)
end)

RegisterNetEvent("rsg-stable:BuyHorse", function(data, name)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local Playercid = Player.PlayerData.citizenid

    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE `citizenid`=@citizenid;', {citizenid = Playercid}, function(horses)
        if #horses >= 3 then
            TriggerClientEvent('rsg-core:client:DrawText', src, 'you can have a maximum of 3 horses!', 'left')
            Wait(5000) -- display text for 5 seconds
            TriggerClientEvent('rsg-core:client:HideText', src)
            return
        end
        Wait(200)
        if data.IsGold then
            local currentBank = Player.Functions.GetMoney('bank')
            if data.Gold <= currentBank then
                local bank = Player.Functions.RemoveMoney("bank", data.Gold, "stable-bought-horse")
                TriggerClientEvent('rsg-core:client:DrawText', src, 'horse purchased for $'..data.Gold, 'left')
                Wait(5000) -- display text for 5 seconds
                TriggerClientEvent('rsg-core:client:HideText', src)
                TriggerEvent('qbr-log:server:CreateLog', 'shops', 'Stable', 'green', "**"..GetPlayerName(Player.PlayerData.source) .. " (citizenid: "..Player.PlayerData.citizenid.." | id: "..Player.PlayerData.source..")** bought a horse for $"..data.Gold..".")
            else
                TriggerClientEvent('rsg-core:client:DrawText', src, 'not enough money!', 'left')
                Wait(5000) -- display text for 5 seconds
                TriggerClientEvent('rsg-core:client:HideText', src)
                return
            end
        else
            if Player.Functions.RemoveMoney("cash", data.Dollar, "stable-bought-horse") then
                TriggerClientEvent('rsg-core:client:DrawText', src, 'horse purchased for $'..data.Dollar, 'left')
                Wait(5000) -- display text for 5 seconds
                TriggerClientEvent('rsg-core:client:HideText', src)
                TriggerEvent('qbr-log:server:CreateLog', 'shops', 'Stable', 'green', "**"..GetPlayerName(Player.PlayerData.source) .. " (citizenid: "..Player.PlayerData.citizenid.." | id: "..Player.PlayerData.source..")** bought a horse for $"..data.Dollar..".")
            else
                TriggerClientEvent('rsg-core:client:DrawText', src, 'not enough money!', 'left')
                Wait(5000) -- display text for 5 seconds
                TriggerClientEvent('rsg-core:client:HideText', src)
                return
            end
        end
    MySQL.Async.execute('INSERT INTO player_horses (`citizenid`, `name`, `model`) VALUES (@Playercid, @name, @model);',
        {
            Playercid = Playercid,
            name = tostring(name),
            model = data.ModelH
        }, function(rowsChanged)

        end)
    end)
end)

RegisterNetEvent("rsg-stable:SelectHorseWithId", function(id)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local Playercid = Player.PlayerData.citizenid
    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE `citizenid`=@citizenid;', {citizenid = Playercid}, function(horse)
        for i = 1, #horse do
            local horseID = horse[i].id
            MySQL.Async.execute("UPDATE player_horses SET `selected`='0' WHERE `citizenid`=@citizenid AND `id`=@id", {citizenid = Playercid,  id = horseID}, function(done)
            end)

            Wait(300)

            if horse[i].id == id then
                MySQL.Async.execute("UPDATE player_horses SET `selected`='1' WHERE `citizenid`=@citizenid AND `id`=@id", {citizenid = Playercid, id = id}, function(done)
                    TriggerClientEvent("rsg-stable:SetHorseInfo", src, horse[i].model, horse[i].name, horse[i].components)
                end)
            end
        end
    end)
end)

RegisterNetEvent("rsg-stable:SellHorseWithId", function(id)
    local modelHorse = nil
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local Playercid = Player.PlayerData.citizenid
    MySQL.Async.fetchAll('SELECT * FROM player_horses WHERE `citizenid`=@citizenid;', {citizenid = Playercid}, function(horses)

        for i = 1, #horses do
           if tonumber(horses[i].id) == tonumber(id) then
                modelHorse = horses[i].model
                MySQL.Async.fetchAll('DELETE FROM player_horses WHERE `citizenid`=@citizenid AND`id`=@id;', {citizenid = Playercid,  id = id}, function(result)
                end)
            end
        end

        for k,v in pairs(Config.Horses) do
            for models,values in pairs(v) do
                if models ~= "name" then
                    if models == modelHorse then
                        local price = tonumber(values[3]/2)
                        Player.Functions.AddMoney("cash", price, "stable-sell-horse")
                        TriggerEvent('qbr-log:server:CreateLog', 'shops', 'Stable', 'red', "**"..GetPlayerName(Player.PlayerData.source) .. " (citizenid: "..Player.PlayerData.citizenid.." | id: "..Player.PlayerData.source..")** sold a horse for $"..price..".")
                    end
                end
            end
        end
    end)
end)

-- call active horse command
RSGCore.Commands.Add("callhorse", "call your active horse", {}, false, function(source)
    src = source
    TriggerClientEvent('rsg-stable:client:callHorse', src)
end)

-- flee active horse command
RSGCore.Commands.Add("fleehorse", "flee your active horse", {}, false, function(source)
    src = source
    TriggerClientEvent('rsg-stable:client:fleeHorse', src)
end)

-- open active horse inventory command
RSGCore.Commands.Add("horseinv", "open your active horse inventory", {}, false, function(source)
    src = source
    TriggerClientEvent('rsg-stable:client:inventoryHorse', src)
end)

-- feed horse carrot
RSGCore.Functions.CreateUseableItem("carrot", function(source, item)
    local Player = RSGCore.Functions.GetPlayer(source)
    if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("rsg-stable:client:feedhorse", source, item.name)
    end
end)

-- feed horse sugarcube
RSGCore.Functions.CreateUseableItem("sugarcube", function(source, item)
    local Player = RSGCore.Functions.GetPlayer(source)
    if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("rsg-stable:client:feedhorse", source, item.name)
    end
end)

-- brush horse
RSGCore.Functions.CreateUseableItem("horsebrush", function(source, item)
    local Player = RSGCore.Functions.GetPlayer(source)
    TriggerClientEvent("rsg-stable:client:brushhorse", source, item.name)
end)

-- horselantern
RSGCore.Functions.CreateUseableItem("horselantern", function(source, item)
    local Player = RSGCore.Functions.GetPlayer(source)
    TriggerClientEvent("rsg-stable:client:equipHorseLantern", source, item.name)
end)
