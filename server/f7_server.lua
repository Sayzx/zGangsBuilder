ESX = nil
local playersHealing, deadPlayers = {}, {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--TriggerEvent('esx_phone:registerNumber', 'CoffreGang', 'alerte CoffreGang', true, true) --- Si vous avez un GCPHONE

TriggerEvent('esx_society:registerSociety', 'CoffreGang', 'CoffreGang', 'society_CoffreGang', 'society_CoffreGang', 'society_CoffreGang', {type = 'public'})

ESX.RegisterServerCallback('esx_policejob:getOtherPlayerData', function(source, cb, target, notify)
    local xPlayer = ESX.GetPlayerFromId(target)

    TriggerClientEvent("esx:showNotification", target, "~r~Quelqu'un vous fouille ...")

    if xPlayer then
        local data = {
            name = xPlayer.getName(),
            job = xPlayer.job.label,
            grade = xPlayer.job.grade_label,
            inventory = xPlayer.getInventory(),
            accounts = xPlayer.getAccounts(),
            weapons = xPlayer.getLoadout()
        }

        cb(data)
    end
end)

RegisterNetEvent('jejey:confiscatePlayerItem')
AddEventHandler('jejey:confiscatePlayerItem', function(target, itemType, itemName, amount)
    local _source = source
    local sourceXPlayer = ESX.GetPlayerFromId(_source)
    local targetXPlayer = ESX.GetPlayerFromId(target)

    if itemType == 'item_standard' then
        local targetItem = targetXPlayer.getInventoryItem(itemName)
		local sourceItem = sourceXPlayer.getInventoryItem(itemName)
		
			targetXPlayer.removeInventoryItem(itemName, amount)
			sourceXPlayer.addInventoryItem   (itemName, amount)
            TriggerClientEvent("esx:showNotification", source, "Vous avez confisqué ~b~"..amount..' '..sourceItem.label.."~s~.")
            TriggerClientEvent("esx:showNotification", target, "Quelqu'un vous a pris ~b~"..amount..' '..sourceItem.label.."~s~.")
		end
        
    if itemType == 'item_account' then
        targetXPlayer.removeAccountMoney(itemName, amount)
        sourceXPlayer.addAccountMoney(itemName, amount)
        
        TriggerClientEvent("esx:showNotification", source, "Vous avez confisqué ~b~"..amount.."$ d'argent sale~s~.")
        TriggerClientEvent("esx:showNotification", target, "Quelqu'un vous aconfisqué ~b~"..amount.."$ d'argent sale~s~.")
        
    elseif itemType == 'item_weapon' then
        if amount == nil then amount = 0 end
        targetXPlayer.removeWeapon(itemName, amount)
        sourceXPlayer.addWeapon   (itemName, amount)

        TriggerClientEvent("esx:showNotification", source, "Vous avez confisqué ~b~"..ESX.GetWeaponLabel(itemName).."~s~ avec ~b~"..amount.."~s~ balle(s).")
        TriggerClientEvent("esx:showNotification", target, "Quelqu'un vous a confisqué ~b~"..ESX.GetWeaponLabel(itemName).."~s~ avec ~b~"..amount.."~s~ balle(s).")
    end

    if sourceXPlayer > targetXPlayer then
        TriggerClientEvent("esx:showNotification", source, "~r~Quantité invalide")
    end

end)


RegisterServerEvent('policejob:mettremenotte')
AddEventHandler('policejob:mettremenotte', function(targetid, playerheading, playerCoords,  playerlocation)
    local _source = source
    TriggerClientEvent('policejob:mettreM', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('policejob:animarrest', _source)
end)

RegisterServerEvent('policejob:enlevermenotte')
AddEventHandler('policejob:enlevermenotte', function(targetid, playerheading, playerCoords,  playerlocation)
    local _source = source
    TriggerClientEvent('policejob:enleverM', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('policejob:animenlevermenottes', _source)
end)

RegisterServerEvent('policejob:drag')
AddEventHandler('policejob:drag', function(target)
	local _source = source
	TriggerClientEvent('policejob:drag1', target, _source)
end)

RegisterNetEvent('esx_policejob:putInVehicle')
AddEventHandler('esx_policejob:putInVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job2.name ~= 'unemployed2' then
		TriggerClientEvent('esx_policejob:putInVehicle', target)
	else
        --
	end
end)

RegisterNetEvent('esx_policejob:OutVehicle')
AddEventHandler('esx_policejob:OutVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job2.name ~= 'unemployed2' then
		TriggerClientEvent('esx_policejob:OutVehicle', target)
	else
        --
	end
end)

RegisterServerEvent('policejob:mettremenottenofreeze')
AddEventHandler('policejob:mettremenottenofreeze', function(targetid, playerheading, playerCoords,  playerlocation)
    local _source = source
    TriggerClientEvent('policejob:mettreMnofreeze', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('policejob:animarrest', _source)
end)
