ESX = nil
TriggerEvent(Config.TriggerGetEsx, function(obj) ESX = obj end)

local SharedGangs = {}
local GangsLoaded = false 

local prefix = "[^4zGangBuilder^7]"
function ToConsol(str)
    print(prefix.." "..str)
end

local function Notification(player, message)
    if player and message then
        TriggerClientEvent(Config.TriggerEsxNotif, player, message) 
    end
end

local function InitGangs()
    MySQL.Async.fetchAll('SELECT * FROM gangs', {}, function(data)
        for k,v in pairs(data) do
            if not SharedGangs[v.name] then 
                SharedGangs[v.name] = {}
                SharedGangs[v.name].name = v.name 
                SharedGangs[v.name].label = v.label 
                SharedGangs[v.name].coords = json.decode(v.coords )
                SharedGangs[v.name].data = json.decode(v.data)
                SharedGangs[v.name].vehicle = json.decode(v.vehicle)
                TriggerEvent('esx_society:registerSociety', v.name, v.label, 'society_'..v.name, 'society_'..v.name, 'society_'..v.name, {type = 'public'})
            end
        end
        GangsLoaded = true
    end)
end

Citizen.CreateThread(function()
    InitGangs()
end)

local function SaveInDb(name, data, vehicle) 
    MySQL.Sync.execute("UPDATE gangs SET data=@data,vehicle=@vehicle WHERE name=@name", {
        ["@name"] = name,
        ["@data"] = json.encode(data),
        ["@vehicle"] = json.encode(vehicle)
    })  
end

Citizen.CreateThread(function()
    while not GangsLoaded do 
        Wait(100)
    end
    local SaveCount = 0
    while true do 
        for k,v in pairs(SharedGangs) do 
            SaveInDb(v.name, v.data, v.vehicle)
        end
        SaveCount = SaveCount + 1
        ToConsol("Gang data and vehicle saved to db (SaveID:"..SaveCount..")")

        Wait(Config.SaveTime*60000)
    end
end)

local function SizeOfTable(t)
    local count = 0

    for k,v in pairs(t) do
        count = count + 1
    end

    return count
end

local function GetWeightRestant(gangsName)
    if SharedGangs[gangsName] then 
        local countList = {}
        if json.encode(SharedGangs[gangsName].data["item"]) == "[]" then 
            return 0
        else 
            for k,v in pairs(SharedGangs[gangsName].data["item"]) do 
                table.insert(countList, v.count)
            end
            return SizeOfTable(countList)
        end
    else 
        return nil
    end
end

RegisterNetEvent("sGangsSysteme:CreateGangs")
AddEventHandler("sGangsSysteme:CreateGangs", function(data)
    local _source = source 
    local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer.getGroup() ~= "user" then 
        if not SharedGangs[data.Name] then
            if not ESX.Jobs[data.Name] then 
                local GradeList = {}
                local DefaultData = {
                    ["item"] = {},
                    ["accounts"] = { [Config.MoneyType.money] = 0, [Config.MoneyType.black_money] = 0 },
                    ["weapons"] = {},
                }
                for k,v in pairs(data.Grades) do 
                    MySQL.Async.execute('INSERT INTO job_grades (job_name, name, label, grade, salary, skin_male, skin_female) VALUES (@job_name, @name, @label, @grade, @salary, @skin_male, @skin_female)', {
                        ['@job_name'] = data.Name,
                        ['@name'] = v.name,
                        ['@label'] = v.label,
                        ['@grade'] = k,
                        ['@salary'] = 0,
                        ['@skin_male'] = "{}",
                        ['@skin_female'] = "{}"
                    })
                    
                end
                MySQL.Async.execute('INSERT INTO jobs (name, label, whitelisted) VALUES (@name, @label, @whitelisted)', {
                    ['@name'] = data.Name,
                    ['@label'] = data.Label,
                    ['@whitelisted'] = false
                })
                MySQL.Async.execute('INSERT INTO gangs (name, label, coords, data, vehicle) VALUES (@name, @label, @coords, @data, @vehicle)', {
                    ['@name'] = data.Name,
                    ['@label'] = data.Label,
                    ['@coords'] = json.encode(data.Coords),
                    ['@data'] = json.encode(DefaultData),
                    ['@vehicle'] = "[]"
                })
                MySQL.Async.execute('INSERT INTO addon_account (name, label, shared) VALUES (@name, @label, @shared)', {
                    ['@name'] = "society_"..data.Name,
                    ['@label'] = data.Label,
                    ['@shared'] = 1
                })
                MySQL.Async.execute('INSERT INTO addon_inventory (name, label, shared) VALUES (@name, @label, @shared)', {
                    ['@name'] = "society_"..data.Name,
                    ['@label'] = data.Label,
                    ['@shared'] = 1
                })
                MySQL.Async.execute('INSERT INTO datastore (name, label, shared) VALUES (@name, @label, @shared)', {
                    ['@name'] = "society_"..data.Name,
                    ['@label'] = data.Label,
                    ['@shared'] = 1
                })
                SharedGangs[data.Name] = {}
                SharedGangs[data.Name].name = data.Name
                SharedGangs[data.Name].label = data.Label
                SharedGangs[data.Name].coords = data.Coords
                SharedGangs[data.Name].data = DefaultData
                SharedGangs[data.Name].vehicle = {}
                TriggerClientEvent('esx:showAdvancedNotification', source, '~g~zDev', '~p~zGangsBuilder', '~g~ Succès : ~b~Vous venez de crée ~r~ '..data.Label.." !", 'CHAR_ASHLEY', 3)
            else
           
                TriggerClientEvent('esx:showAdvancedNotification', source, '~g~zDev', '~p~zGangsBuilder', '~g~ Erreur : ~b~Ce Gang Existe Déja ~r~ !', 'CHAR_ASHLEY', 3)
            end
        else
          
            TriggerClientEvent('esx:showAdvancedNotification', source, '~g~zDev', '~p~zGangsBuilder', '~g~ Erreur : ~b~Ce Gang Existe Déja ~r~ !', 'CHAR_ASHLEY', 3)
        end
    else 
        Config.CheatAction(_source, "CreateGangs")
    end
end)

RegisterNetEvent("sGangsSysteme:PlayerSpawned")
AddEventHandler("sGangsSysteme:PlayerSpawned", function()
    local _source = source 
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xJob = xPlayer.job2
    
    if xJob.name == "unemployed" or xJob.name == "unemployed2" then 
        return
    else 
        TriggerClientEvent("sGangsSysteme:PlayerSpawned", _source, SharedGangs[xJob.name])
    end
end)

RegisterNetEvent("sGangsSysteme:PlayerRefresh")
AddEventHandler("sGangsSysteme:PlayerRefresh", function()
    local _source = source 
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xJob = xPlayer.job2
    
    if xJob.name == "unemployed" or xJob.name == "unemployed2" then 
        TriggerClientEvent("sGangsSysteme:PlayerRefresh", _source, false)
    else
        TriggerClientEvent("sGangsSysteme:PlayerRefresh", _source, true, SharedGangs[xJob.name])
    end
end)

RegisterNetEvent("sGangsSysteme:AddVehicle")
AddEventHandler("sGangsSysteme:AddVehicle", function(job, vProps, vName)
    local _source = source 
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xJob = xPlayer.job2
    
    if xJob.name == job then 
        if not SharedGangs[job].vehicle[vProps.plate] then 
            SharedGangs[job].vehicle[vProps.plate] = vProps
        end
        Notification(_source, "~g~Garage "..SharedGangs[job].label.."\n~s~Vous avez range votre "..vName..".")
    else
        Config.CheatAction(_source, "AddVehicle")
    end
end)

RegisterNetEvent("sGangsSysteme:SuppVehicle")
AddEventHandler("sGangsSysteme:SuppVehicle", function(job, vPlate, vName)
    local _source = source 
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xJob = xPlayer.job2
    
    if xJob.name == job then 
        if SharedGangs[job].vehicle[vPlate] then 
            TriggerClientEvent("sGangsSysteme:SpawnVehicle", _source, SharedGangs[job].vehicle[vPlate])
            Notification(_source, "~g~Garage "..SharedGangs[job].label.."\n~s~Vous avez sortis votre "..vName..".")
            SharedGangs[job].vehicle[vPlate] = nil
        end
    else
        Config.CheatAction(_source, "SuppVehicle")
    end
end)

ESX.RegisterServerCallback('sGangsSysteme:GetVehiclesGangs', function(source, cb, job)
    local _source = source 
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xJob = xPlayer.job2
    
    if xJob.name == job then 
        cb(SharedGangs[job].vehicle)
    else
        Config.CheatAction(_source, "GetVehiclesGangs")
    end
end)

RegisterNetEvent("sGangsSysteme:AddItem")
AddEventHandler("sGangsSysteme:AddItem", function(job, itemName, count)
    local _source = source 
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xJob = xPlayer.job2
    
    if xJob.name == job then 
        if SharedGangs[job].data["item"] then 
            local itemInfo = xPlayer.getInventoryItem(itemName)
            if itemInfo.count >= count then 
                local CurrentWeight = GetWeightRestant(job)
                if (Config.CoffrePoidsMax - CurrentWeight) >= count then
                    if not SharedGangs[job].data["item"][itemInfo.name] then 
                        SharedGangs[job].data["item"][itemInfo.name] = {}
                        SharedGangs[job].data["item"][itemInfo.name].name = itemInfo.name 
                        SharedGangs[job].data["item"][itemInfo.name].label = itemInfo.label
                        SharedGangs[job].data["item"][itemInfo.name].count = count
                        SharedGangs[job].data["item"][itemInfo.name].itemWeight = itemInfo.weight
                    else 
                        SharedGangs[job].data["item"][itemInfo.name].count = SharedGangs[job].data["item"][itemInfo.name].count + count
                    end
                    xPlayer.removeInventoryItem(itemInfo.name, count)

                    TriggerClientEvent('esx:showAdvancedNotification', source, '~g~zDev', '~p~zGangsBuilder', '~g~ Coffre  : \n~s~Vous avez depose ~r~x'..count..' ~s~' ..itemInfo.label..' dans le coffre.', 'CHAR_ASHLEY', 3)
                    TriggerClientEvent("sGangsSysteme:UpdateCoffre", _source, SharedGangs[job].data)
                else 
    
                    TriggerClientEvent('esx:showAdvancedNotification', source, '~g~zDev', '~p~zGangsBuilder', '~g~ Coffre  : ~b~Il n\'y a pas assez de place dans le coffre~r~ !', 'CHAR_ASHLEY', 3)
                end
            else

                TriggerClientEvent('esx:showAdvancedNotification', source, '~g~zDev', '~p~zGangsBuilder', '~g~ Coffre  : ~b~\n~s~Vous n\'avez pas cette quantite sur vous !', 'CHAR_ASHLEY', 3)
            end
        end
    else
        Config.CheatAction(_source, "AddItem")
    end
end)

RegisterNetEvent("sGangsSysteme:SuppItem")
AddEventHandler("sGangsSysteme:SuppItem", function(job, itemName, count)
    local _source = source 
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xJob = xPlayer.job2
    
    if xJob.name == job then 
        local itemInfo = xPlayer.getInventoryItem(itemName)
        if SharedGangs[job].data["item"] and SharedGangs[job].data["item"][itemInfo.name] then 
            if SharedGangs[job].data["item"][itemInfo.name].count >= count then 
                
                    if (SharedGangs[job].data["item"][itemInfo.name].count - count) > 0 then 
                        SharedGangs[job].data["item"][itemInfo.name].count = SharedGangs[job].data["item"][itemInfo.name].count - count
                    else 
                        SharedGangs[job].data["item"][itemInfo.name] = nil
                    end
                    xPlayer.addInventoryItem(itemInfo.name, count)
 
                    TriggerClientEvent('esx:showAdvancedNotification', source, '~g~zDev', '~p~zGangsBuilder', '~g~ Coffre  : ~b~\n~s~Vous avez pris '..count..' '..itemInfo.label..' du coffre.', 'CHAR_ASHLEY', 3)
                    TriggerClientEvent("sGangsSysteme:UpdateCoffre", _source, SharedGangs[job].data)
              
            else
     
                TriggerClientEvent('esx:showAdvancedNotification', source, '~g~zDev', '~p~zGangsBuilder', '~g~ Coffre  : \n~s~Il n\'y a pas cette quantite dans le coffre !', 'CHAR_ASHLEY', 3)
            end
        end
    else
        Config.CheatAction(_source, "SuppItem")
    end
end)

RegisterNetEvent("sGangsSysteme:AddMoney")
AddEventHandler("sGangsSysteme:AddMoney", function(job, moneyType, amount) 
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xJob = xPlayer.job2

    if xJob.name == job then 
        local Account = xPlayer.getAccount(moneyType)
        if Account.money >= amount then
            SharedGangs[job].data["accounts"][moneyType] = SharedGangs[job].data["accounts"][moneyType] + amount
            xPlayer.removeAccountMoney(moneyType, amount)
        
            TriggerClientEvent('esx:showAdvancedNotification', source, '~g~zDev', '~p~zGangsBuilder', '~g~ Coffre  : ~s~\nVous avez deposer '..amount..' de '..Account.label..' dans le coffre.', 'CHAR_ASHLEY', 3)
            TriggerClientEvent("sGangsSysteme:UpdateCoffre", _source, SharedGangs[job].data)
        else 
           
            TriggerClientEvent('esx:showAdvancedNotification', source, '~g~zDev', '~p~zGangsBuilder', '~g~ Coffre  : ~g~Coffre '..SharedGangs[job].label..'~s~\nVous n\'avez pas cette quantitee. dans le coffre.', 'CHAR_ASHLEY', 3)
        end
    else 
        Config.CheatAction(_source, "AddMoney")
    end
end)

RegisterNetEvent("sGangsSysteme:SuppMoney")
AddEventHandler("sGangsSysteme:SuppMoney", function(job, moneyType, amount) 
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xJob = xPlayer.job2

    if xJob.name == job then 
        if SharedGangs[job].data["accounts"][moneyType] >= amount then
            SharedGangs[job].data["accounts"][moneyType] = SharedGangs[job].data["accounts"][moneyType] - amount
            xPlayer.addAccountMoney(moneyType, amount)
            local AccountsLabel = xPlayer.getAccount(moneyType).label
            TriggerClientEvent('esx:showAdvancedNotification', source, '~g~zDev', '~p~zGangsBuilder', '~g~Coffre '..SharedGangs[job].label..'~s~\nVous avez pris '..amount..' de '..AccountsLabel..' dans le coffre.', 'CHAR_ASHLEY', 3)
            
            
            TriggerClientEvent("sGangsSysteme:UpdateCoffre", _source, SharedGangs[job].data)
        else 
            TriggerClientEvent('esx:showAdvancedNotification', source, '~g~zDev', '~p~zGangsBuilder', '~g~Coffre Erreur Syntaxique', 'CHAR_ASHLEY', 3)
        end
    else 
        Config.CheatAction(_source, "SuppMoney")
    end
end)

RegisterNetEvent("sGangsSysteme:AddWeapons")
AddEventHandler("sGangsSysteme:AddWeapons", function(job, weaponName, ammo)
    local _source = source 
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xJob = xPlayer.job2
    
    if xJob.name == job then 
        if SharedGangs[job].data["weapons"] then 
            if xPlayer.hasWeapon(weaponName) then 
                local CurrentWeight = GetWeightRestant(job)
                if Config.PoidsWeapons[weaponName] then
                    if (Config.CoffrePoidsMax - CurrentWeight) >= Config.PoidsWeapons[weaponName] then
                        local random = math.random(0, 999999)
                        if not SharedGangs[job].data["weapons"][random] then 
                            SharedGangs[job].data["weapons"][random] = {}
                            SharedGangs[job].data["weapons"][random].name = weaponName
                            SharedGangs[job].data["weapons"][random].label = ESX.GetWeaponLabel(weaponName)
                            SharedGangs[job].data["weapons"][random].ammo = ammo
                        end
                        xPlayer.removeWeapon(weaponName)
                        Notification(_source, "~g~Coffre "..SharedGangs[job].label.."\n~s~Vous avez depose un(e) "..ESX.GetWeaponLabel(weaponName).." dans le coffre.")
                        
                        TriggerClientEvent("sGangsSysteme:UpdateCoffre", _source, SharedGangs[job].data)
                    else 
                        Notification(_source, "~g~Coffre "..SharedGangs[job].label.."\n~s~Il n'y a pas assez de place dans le coffre.")
                    end
                else 
                    Notification(_source, "~g~Coffre "..SharedGangs[job].label.."\n~s~Cette armes existe pas merci de report à un staff.")
                end
            else
                Notification(_source, "~g~Coffre "..SharedGangs[job].label.."\n~s~Vous n'avez pas cette arme sur vous !")
            end
        end
    else
        Config.CheatAction(_source, "AddWeapons")
    end
end)

RegisterNetEvent("sGangsSysteme:SuppWeapons")
AddEventHandler("sGangsSysteme:SuppWeapons", function(job, keyWeapon, weaponName, ammo)
    local _source = source 
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xJob = xPlayer.job2
    
    if xJob.name == job then 
        if SharedGangs[job].data["weapons"] then 
            if not xPlayer.hasWeapon(weaponName) then
                if SharedGangs[job].data["weapons"][keyWeapon] then 
                    SharedGangs[job].data["weapons"][keyWeapon] = nil
                end
                xPlayer.addWeapon(weaponName, ammo)
                Notification(_source, "~g~Coffre "..SharedGangs[job].label.."\n~s~Vous avez pris un(e) "..ESX.GetWeaponLabel(weaponName).." du coffre.")
                TriggerClientEvent("sGangsSysteme:UpdateCoffre", _source, SharedGangs[job].data)
            else 
                Notification(_source, "~g~Coffre "..SharedGangs[job].label.."\n~s~Vous avez dejà un(e) "..ESX.GetWeaponLabel(weaponName).." sur vous.")
            end
        end
    else
        Config.CheatAction(_source, "SuppWeapons")
    end
end)

ESX.RegisterServerCallback('sGangsSysteme:GetItemGangs', function(source, cb, job)
    local _source = source 
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xJob = xPlayer.job2
    
    if xJob.name == job then 
        cb(SharedGangs[job].data)
    else
        Config.CheatAction(_source, "GetItemGangs")
    end
end)

-- FOR ANTI DUPLIS

local PlayerOpenedCoffre = {}

RegisterServerEvent('sGangsSysteme:playerOpenedCoffre')
AddEventHandler('sGangsSysteme:playerOpenedCoffre', function(gangsName)
    local _source = source 

    if not PlayerOpenedCoffre[gangsName] then 
        PlayerOpenedCoffre[gangsName] = _source
    else 
        PlayerOpenedCoffre[gangsName] = _source
    end
end)

RegisterServerEvent('sGangsSysteme:playerClosedCoffre')
AddEventHandler('sGangsSysteme:playerClosedCoffre', function(gangsName)
    local _source = source 

    if not PlayerOpenedCoffre[gangsName] then 
        PlayerOpenedCoffre[gangsName] = nil
    else 
        PlayerOpenedCoffre[gangsName] = nil
    end
end)

ESX.RegisterServerCallback('sGangsSysteme:CheckIfPlayerInCoffre', function(source, cb, gangsName)
    local _source = source

    if PlayerOpenedCoffre[gangsName] then 
        cb(true)
    else 
        cb(false)
    end
end)

local PlayerAlreadyInGarage = {}

RegisterServerEvent('sGangsSysteme:playerOpenedGarage')
AddEventHandler('sGangsSysteme:playerOpenedGarage', function(gangsName)
    local _source = source 

    if not PlayerAlreadyInGarage[gangsName] then 
        PlayerAlreadyInGarage[gangsName] = _source
    else 
        PlayerAlreadyInGarage[gangsName] = _source
    end
end)

RegisterServerEvent('sGangsSysteme:playerClosedGarage')
AddEventHandler('sGangsSysteme:playerClosedGarage', function(gangsName)
    local _source = source 

    if not PlayerAlreadyInGarage[gangsName] then 
        PlayerAlreadyInGarage[gangsName] = nil
    else 
        PlayerAlreadyInGarage[gangsName] = nil
    end
end)

ESX.RegisterServerCallback('sGangsSysteme:CheckIfPlayerInGarage', function(source, cb, gangsName)
    local _source = source

    if PlayerAlreadyInGarage[gangsName] then 
        cb(true)
    else 
        cb(false)
    end
end)

RegisterCommand(Config.CommandName, function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xGroup = xPlayer.getGroup()
    local hasPerm = false

    for k,v in pairs(Config.ExecutCommandCreateGang) do 
        if xGroup == v then 
            hasPerm = true
        end
    end

    if hasPerm then 
        TriggerClientEvent("sGangSysteme:OpenMenuCreator", _source)
    else 
        return
    end
end)
print("^0| ^4zGangsBuilder^7 | ^0REWORK BY^7 ^2SAYZ^7 ")