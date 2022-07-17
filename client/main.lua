ESX = nil
ESXLoaded = false
if not Config.ArmesInItem then
	PlayerWeapon = {}
end

local prefix = "[^3zGangBuilder^7]"
function ToConsol(str)
	print(prefix.." "..str)
end

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent(Config.TriggerGetEsx, function(obj) ESX = obj end)
		ESXLoaded = true
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	ESX.PlayerData = ESX.GetPlayerData()

	if not Config.ArmesInItem then
		PlayerWeapon = ESX.GetWeaponList()
		for i = 1, #PlayerWeapon, 1 do
			if PlayerWeapon[i].name == 'WEAPON_UNARMED' then
				PlayerWeapon[i] = nil
			else
				PlayerWeapon[i].hash = GetHashKey(PlayerWeapon[i].name)
			end
		end
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job2)
	ESX.PlayerData.job2 = job2
end)



CurrentGangs = {}

function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
	AddTextEntry(entryTitle, textEntry)
	DisplayOnscreenKeyboard(1, entryTitle, '', inputText, '', '', '', maxLength)
	blockinput = true

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end

	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		blockinput = false
		return result
	else
		Citizen.Wait(500)
		blockinput = false
		return nil
	end
end

function CountGrade(t)
	local count = 0
	for k,v in pairs(t) do
		count = count + 1
	end
	return count+1
end

function CountTable(t)
	local count = 0
	for k,v in pairs(t) do
		count = count + 1
	end
	return count
end

function StoreVehicle(pVeh)
	local vProps = ESX.Game.GetVehicleProperties(pVeh)
	local vName = GetDisplayNameFromVehicleModel(vProps.model)
	if Config.WhitelistVeh(vProps) then
		TriggerServerEvent("zGangsBuilder:AddVehicle", CurrentGangs.name, vProps, vName)
		DeleteEntity(pVeh)
	end
end

function CheckQuantity(number)
	number = tonumber(number)
	
	if type(number) == 'number' then
		number = ESX.Math.Round(number)
		if number > 0 then
			return true, number
		end
	end
	
	return false, number
end

function GetWeight(t) 
	local count = 0
	for k,v in pairs(t) do 
		if k ~= "accounts" then
			if k == "item" then
				for a,b in pairs(v) do
					count = count 
				end
			elseif k == "weapons" then 
				for a,b in pairs(v) do
					count = count + Config.PoidsWeapons[b.name]
				end
			end
		end
	end
	return count
end

RegisterNetEvent(Config.TriggerEsxPlayerLoaded)
AddEventHandler(Config.TriggerEsxPlayerLoaded, function(playerData)
	ESX.PlayerData = playerData
	TriggerServerEvent("zGangsBuilder:PlayerSpawned")
end)

RegisterNetEvent(Config.TriggerEsxSetjob2)
AddEventHandler(Config.TriggerEsxSetjob2, function(job)
	ESX.PlayerData.job2 = job
	TriggerServerEvent("zGangsBuilder:PlayerRefresh")
end)

RegisterNetEvent('zGangsBuilder:SpawnVehicle')
AddEventHandler('zGangsBuilder:SpawnVehicle', function(vProps)
	ESX.Game.SpawnVehicle(vProps.model, CurrentGangs.coords["Garage"].SpawnCoord.coords, CurrentGangs.coords["Garage"].SpawnCoord.heading, function(vehicle)
		ESX.Game.SetVehicleProperties(vehicle, vProps)
	end)
	RageUI.CloseAll()
end)

RegisterNetEvent('zGangsBuilder:UpdateCoffre')
AddEventHandler('zGangsBuilder:UpdateCoffre', function(data)
	CurrentGangs.data = data
end)

RegisterCommand("reload", function()
	TriggerServerEvent("zGangsBuilder:PlayerSpawned")
end, false)

local ZonesListe = {}

Citizen.CreateThread(function()
	while not ESXLoaded do 
		Wait(1)
	end

	while true do
		local isProche = false
		for k,v in pairs(ZonesListe) do
			local dist = Vdist2(GetEntityCoords(PlayerPedId(), false), v.Position)

			if dist < 250 then
				isProche = true
				if Config.Marker.UseMoins1 then
					DrawMarker(Config.Marker.MarkerId, v.Position.x, v.Position.y, v.Position.z-1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.55, 0.55, 0.55, Config.Marker.Color.R, Config.Marker.Color.G, Config.Marker.Color.B, Config.Marker.Color.A,  Config.Marker.BobUpAndDown,  Config.Marker.FaceCamera, 2,  Config.Marker.Rotate,  false, false, false)
				else 
					DrawMarker(Config.Marker.MarkerId, v.Position.x, v.Position.y, v.Position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.55, 0.55, 0.55, Config.Marker.Color.R, Config.Marker.Color.G, Config.Marker.Color.B, Config.Marker.Color.A,  Config.Marker.BobUpAndDown,  Config.Marker.FaceCamera, 2,  Config.Marker.Rotate,  false, false, false)
				end
			end
			if dist < 10 then
				ESX.ShowHelpNotification(Config.PrefixColorHelpNotif..Config.DevNotif.."\n~w~Appuyez sur ~INPUT_CONTEXT~ pour interagir")
				if IsControlJustPressed(1,51) then
					if k == "BossMenu" then 
						if ESX.PlayerData.job2 and ESX.PlayerData.job2.grade_name == "boss" then 
							Config.BossAction(ESX.PlayerData.job2)
						else 
							
							ESX.ShowAdvancedNotification('~g~zDev', '~p~zGangsBuilder', '~r~ Vous n\'etes pas le boss', 'CHAR_ASHLEY', 3)
						end
					elseif k == "Coffre" then
						local PlayerAlreadyInCoffre = false
						local loaded = false 
						
						ESX.TriggerServerCallback('zGangsBuilder:CheckIfPlayerInCoffre', function(isAvailabe)
							PlayerAlreadyInCoffre = isAvailabe
							loaded = true
						end, CurrentGangs.name)
					
						while not loaded do 
							Wait(1)
						end
					
						if PlayerAlreadyInCoffre then 
		
							ESX.ShowAdvancedNotification('~g~zDev', '~p~zGangsBuilder', '~b~ Quelqu\'un regarde dans votre coffre', 'CHAR_ASHLEY', 3)
						else
							OpenMenuCoffre()
						end
					elseif k == "RangeVeh" then 
						local pPed = PlayerPedId()
						if IsPedInAnyVehicle(pPed, true) then 
							local pVeh = GetVehiclePedIsIn(pPed, false)
							StoreVehicle(pVeh)
						else 
				
							ESX.ShowAdvancedNotification('~g~zDev', '~p~zGangsBuilder', '~r~ Vous devez etre dans un véhicule', 'CHAR_ASHLEY', 3)
						end
					elseif k == "ExitVeh" then 
						local PlayerAlreadyInGarage = false
						local loaded = false 
						
						ESX.TriggerServerCallback('zGangsBuilder:CheckIfPlayerInGarage', function(isAvailabe)
							PlayerAlreadyInGarage = isAvailabe
							loaded = true
						end, CurrentGangs.name)
					
						while not loaded do 
							Wait(1)
						end
					
						if PlayerAlreadyInGarage then 
							ESX.ShowAdvancedNotification('~g~zDev', '~p~zGangsBuilder', '~b~ Quelqu\'un regarde dans votre coffre', 'CHAR_ASHLEY', 3)
						else
							OpenMenuGarage()
						end
					end
				end
			end
		end
		
		if isProche then
			Wait(0)
		else
			Wait(750)
		end
	end
end)

function AddZones(zoneName, data)
	if not ZonesListe[zoneName] then
		ZonesListe[zoneName] = data
		-- ToConsol("Creation d'une zone (ZoneName:"..zoneName..")")
		return true
	else 
		-- ToConsol("Tentative de cree une zone qui exise deja (ZoneName:"..zoneName..")")
		return false
	end
end

function RemoveZone(zoneName)
	if ZonesListe[zoneName] then
		ZonesListe[zoneName] = nil
		-- ToConsol("Suppression d'une zone (ZoneName:"..zoneName..")")
	else 
		-- ToConsol("Tentative de supprimer une zone qui exise pas (ZoneName:"..zoneName..")")
	end
end

RegisterNetEvent("zGangsBuilder:PlayerSpawned")
AddEventHandler("zGangsBuilder:PlayerSpawned", function(t)
	if t then
		CurrentGangs = t
		for k,v in pairs(t.coords) do 
			if k ~= "Garage" then 
				AddZones(k, {
					Position = vector3(v.x, v.y, v.z)
				})
			end
		end
		for k,v in pairs(t.coords["Garage"]) do 
			if k ~= "SpawnCoord" then
				AddZones(k, {
					Position = vector3(v.x, v.y, v.z)
				})
			end
		end
	end
end)

RegisterNetEvent("zGangsBuilder:PlayerRefresh")
AddEventHandler("zGangsBuilder:PlayerRefresh", function(hasJob, t)
	if hasJob then 
		if t then
			for k,v in pairs(ZonesListe) do 
				RemoveZone(k)
			end
			CurrentGangs = t
			for k,v in pairs(t.coords) do 
				if k ~= "Garage" then 
					AddZones(k, {
						Position = vector3(v.x, v.y, v.z)
					})
				end
			end
			for k,v in pairs(t.coords["Garage"]) do 
				if k ~= "SpawnCoord" then
					AddZones(k, {
						Position = vector3(v.x, v.y, v.z)
					})
				end
			end
		end
	else 
		for k,v in pairs(ZonesListe) do 
			RemoveZone(k)
		end
	end
end)

local List = {
	Actions = {
		"Deposer",
		"Prendre"
	},
	ActionIndex = 1
}

function OpenMenuCoffre()
	TriggerServerEvent("zGangsBuilder:playerOpenedCoffre", CurrentGangs.name) -- ANTI DUPIS

	local ItemLoaded = false
	ESX.TriggerServerCallback("zGangsBuilder:GetItemGangs", function(result) 
		CurrentGangs.data = result
		ItemLoaded = true
	end, CurrentGangs.name)

	while not ItemLoaded do Wait(1) end

	local menu = RageUI.CreateMenu("Coffre", "Que souhaitez-vous faire ?")
	menu:SetRectangleBanner(143, 9, 241)
	local depositMenu = RageUI.CreateSubMenu(menu, "Deposer", "Contenu de vos poche", 10, 80, 'builder', 'interaction_bgd')

	RageUI.Visible(menu, not RageUI.Visible(menu))
	local UsedPoids = 0

	while menu do
		Wait(0)
		RageUI.IsVisible(menu, function()
			RageUI.Line({Line = {134, 23, 216 , 255}})
			RageUI.Separator("[~r~"..GetWeight(CurrentGangs.data).."/"..Config.CoffrePoidsMax.."~s~] ~b~KG")
			RageUI.Separator()
			RageUI.Button("~b~→→ ~s~Déposer dans le coffre", nil, { RightLabel = "→→→" }, true, {}, depositMenu)
			RageUI.Separator()
			RageUI.Separator("~r~↓ ~y~Actuellement dans le coffre ~r~↓")
			RageUI.Separator()

			
			RageUI.List("[~r~"..CurrentGangs.data["accounts"][Config.MoneyType.black_money].."$~s~] Argent sale", List.Actions, List.ActionIndex, nil, {}, true, {
				onListChange = function(Index, Item)
					List.ActionIndex = Index;
				end,
				onSelected = function()
					if List.ActionIndex == 1 then 
						if UpdateOnscreenKeyboard() == 0 then return end
						local result = KeyboardInput('Combien voulez vous deposer ?', 'Combien voulez vous deposer ?', "", 10)
						local valide, number = CheckQuantity(result)
						if valide then
							TriggerServerEvent("zGangsBuilder:AddMoney", CurrentGangs.name, Config.MoneyType.black_money, number)
						end
					elseif List.ActionIndex == 2 then
						if UpdateOnscreenKeyboard() == 0 then return end
						local result = KeyboardInput('Combien voulez vous prendre ?', 'Combien voulez vous prendre ?', "", 10)
						local valide, number = CheckQuantity(result)
						if valide then
							if CurrentGangs.data["accounts"][Config.MoneyType.black_money] >= number then
								TriggerServerEvent("zGangsBuilder:SuppMoney", CurrentGangs.name, Config.MoneyType.black_money, number)
							else 

								ESX.ShowAdvancedNotification('~g~zDev', '~p~zGangsBuilder', '~r~ Il n\'y a pas cette quantitee.', 'CHAR_ASHLEY', 3)
							end
						end
					end
				end
			})
			if json.encode(CurrentGangs.data["item"]) ~= "[]" then
				for k,v in pairs(CurrentGangs.data["item"]) do
					RageUI.Button("~s~[~r~x"..v.count.."~s~] ~s~"..v.label, nil, { RightLabel = "~s~ ~b~Prendre~s~ →→" }, true, {
						onSelected = function()
							if UpdateOnscreenKeyboard() == 0 then return end
							local result = KeyboardInput('Combien voulez vous prendre ?', 'Combien voulez vous prendre ?', v.count, 10)
							local valide, number = CheckQuantity(result)
							if valide then
								if v.count >= number then
									TriggerServerEvent("zGangsBuilder:SuppItem", CurrentGangs.name, v.name, number)
								
								else

										ESX.ShowAdvancedNotification('~g~zDev', '~p~zGangsBuilder', '~r~ Vous n\'avez pas cette quantité sur vous ', 'CHAR_ASHLEY', 3)
								end
							else
						
								ESX.ShowAdvancedNotification('~g~zDev', '~p~zGangsBuilder', '~r~ Erreur Syntaxe', 'CHAR_ASHLEY', 3)
							end
						end
					})
				end
			else 
				RageUI.Separator()
				RageUI.Line({Line = {134, 23, 216 , 255}})
				RageUI.Separator("~b~⛔️ ~o~ Aucun Item(s) dans le coffre.")
				RageUI.Line({Line = {134, 23, 216 , 255}})
				
			end
			if not Config.ArmesInItem then 
				if json.encode(CurrentGangs.data["weapons"]) ~= "[]" then
					for k,v in pairs(CurrentGangs.data["weapons"]) do
						RageUI.Button("~s~[~r~"..v.ammo.."~s~] "..v.label, nil, { RightLabel = "~b~Prendre~s~ →→" }, true, {
							onSelected = function()
								TriggerServerEvent("zGangsBuilder:SuppWeapons", CurrentGangs.name, k, v.name, ammo)
							end
						})
					end
				else 

					
					RageUI.Line({Line = {134, 23, 216 , 255}})
					RageUI.Separator("~b~⛔️ ~o~ Aucune Arme(s) dans le coffre.")
					RageUI.Line({Line = {134, 23, 216 , 255}})
				end
			end

		end, function()
		end)

		RageUI.IsVisible(depositMenu, function()
			RageUI.Line({Line = {134, 23, 216 , 255}})
			RageUI.Separator("↓ ~r~Items~s~ ↓")
			RageUI.Separator()
			ESX.PlayerData = ESX.GetPlayerData()
			for i = 1, #ESX.PlayerData.inventory do
				if ESX.PlayerData.inventory[i].count > 0 then
					RageUI.Button("~s~[~r~x"..ESX.PlayerData.inventory[i].count.."~s~] "..ESX.PlayerData.inventory[i].label, nil, { RightLabel = "~b~Deposer~s~ →→" }, true, {
						onSelected = function()
							if UpdateOnscreenKeyboard() == 0 then return end
							local result = KeyboardInput('Combien voulez vous deposer ?', 'Combien voulez vous deposer ?', ESX.PlayerData.inventory[i].count, 10)
							local valide, number = CheckQuantity(result)
							if valide then
								if ESX.PlayerData.inventory[i].count >= number then
									TriggerServerEvent("zGangsBuilder:AddItem", CurrentGangs.name, ESX.PlayerData.inventory[i].name, number)
								else
									ESX.ShowNotification("~g~Coffre"..Config.DevNotif.."\n~s~Vous n'avez pas cette quantite sur vous !")
								end
							else
								ESX.ShowNotification("~g~Coffre"..Config.DevNotif.."\n~s~Vous avez mal renseignez ce champs.")
							end
						end
					})
				end
			end
			if not Config.ArmesInItem then 
				RageUI.Line({Line = {134, 23, 216 , 255}})
				RageUI.Separator("↓ ~o~Armes~s~ ↓")
				RageUI.Separator()
				local pPed = PlayerPedId()
				for i = 1, #PlayerWeapon, 1 do
					if HasPedGotWeapon(pPed, PlayerWeapon[i].hash, false) then
						local ammo = GetAmmoInPedWeapon(pPed, PlayerWeapon[i].hash)
						RageUI.Button("~s~[~r~"..ammo.."~s~] "..PlayerWeapon[i].label, nil, { RightLabel = "~b~Deposer~s~ →→→" }, true, {
							onSelected = function()
								TriggerServerEvent("zGangsBuilder:AddWeapons", CurrentGangs.name, PlayerWeapon[i].name, ammo)
							end
						})
					end
				end
			end

		end, function()
		end)

		if not RageUI.Visible(menu) and not RageUI.Visible(depositMenu) then
			menu = RMenu:DeleteType('menu', true)
			depositMenu = RMenu:DeleteType('depositMenu', true)
			TriggerServerEvent("zGangsBuilder:playerClosedCoffre", CurrentGangs.name)
		end
	end
end

local function OpenMenu()
	local menu = RageUI.CreateMenu("", "Création de gangs via Menu", 10, 80, "builder", "interaction_bgd")
	local gradesMenu = RageUI.CreateSubMenu(menu, "Grades", "Creations des grades")
	RageUI.Visible(menu, not RageUI.Visible(menu))

	local Gangs = {
		Name = "",
		Label = "",
		Coords = {
			BossMenu = nil,
			Garage = {
				ExitVeh = nil,
				SpawnCoord = nil,
				RangeVeh = nil,
			},
			Coffre = nil
		},
		Grades = {
			["1"] = {
				name = "boss",
				label = ""
			}
		}
	}
	local idxList = 1
	local GradeCount = 0

	while menu do
		Wait(0)
		RageUI.IsVisible(menu, function()
			
			RageUI.Line({Line = {134, 23, 216 , 255}})
			RageUI.Button('Nom du gang', nil, { RightLabel = "~b~"..Gangs.Label }, true, {
				onSelected = function()
					local result = KeyboardInput('Nom du gang', ('Nom du gang'), '', 50)
					if result and result ~= "" then 
						Gangs.Label = tostring(result)
						Gangs.Name = string.lower(string.gsub(result, "%s+", "_"))
					else 
						
						ESX.ShowAdvancedNotification('~g~zDev', '~p~zGangsBuilder', '~r~ Mauvaise Syntaxe', 'CHAR_ASHLEY', 3)
					end
				end
			})
			local BossMenu
			if Gangs.Coords.BossMenu == nil then 
				BossMenu = "~r~❌"
			else 
				BossMenu = "~b~✅"
			end 
			

			RageUI.Button('Position Gestion Gang', nil, { RightLabel = BossMenu }, true, {
				onSelected = function()
					local pPed = PlayerPedId()
					local pCoords = GetEntityCoords(pPed)
					Gangs.Coords.BossMenu = pCoords
					ESX.ShowAdvancedNotification('~g~zDev', '~p~zGangsBuilder', '~r~ Vous avez définis : ~b~Gestion Gang', 'CHAR_ASHLEY', 3)
					
				end
			})
			local ExitVeh
			local RangeVeh
			local SpawnVeh
			if Gangs.Coords.Garage.ExitVeh == nil then 
				ExitVeh = "~r~❌~s~"
			else 
				ExitVeh = "~b~✅~s~"
			end
			if Gangs.Coords.Garage.RangeVeh == nil then 
				RangeVeh = "~r~❌~s~"
			else 
				RangeVeh = "~b~✅~s~"
			end 
			if Gangs.Coords.Garage.SpawnCoord == nil then 
				SpawnVeh = "~r~❌~s~"
			else 
				SpawnVeh = "~b~✅~s~"
			end
			RageUI.List("Position garage :", {
				{Name = "Sortie vehicule", Value = 1},
				{Name = "Rentrer vehicule", Value = 2},
				{Name = "Point de Spawn", Value = 3},
			}, idxList, "Sortie vehicule : "..ExitVeh.."\n\nRentrer vehicule : "..RangeVeh.."\n\nPoint de Spawn : "..SpawnVeh, {}, not notPersonnal, {
				onListChange = function(Index, Item)
					idxList = Index;
				end,
				onSelected = function()
					if idxList == 1 then 
						local pPed = PlayerPedId()
						local pCoords = GetEntityCoords(pPed)
						Gangs.Coords.Garage.ExitVeh = pCoords
						
						ESX.ShowAdvancedNotification('~g~zDev', '~p~zGangsBuilder', '~r~ Vous avez définis : ~b~Sortie du Vehicule', 'CHAR_ASHLEY', 3)
					elseif idxList == 2 then 
						local pPed = PlayerPedId()
						local pCoords = GetEntityCoords(pPed)
						Gangs.Coords.Garage.RangeVeh = pCoords
						
						ESX.ShowAdvancedNotification('~g~zDev', '~p~zGangsBuilder', '~r~ Vous avez définis : ~b~Ranger Vehicule', 'CHAR_ASHLEY', 3)
					elseif idxList == 3 then 
						local pPed = PlayerPedId()
						local pCoords = GetEntityCoords(pPed)
						local pHeading = GetEntityHeading(pPed)
						Gangs.Coords.Garage.SpawnCoord = {coords = pCoords, heading = pHeading}
						
						ESX.ShowAdvancedNotification('~g~zDev', '~p~zGangsBuilder', '~r~ Vous avez définis : ~b~Point Spawn Vehicle', 'CHAR_ASHLEY', 3)
						
					end
				end
			})
			local CoffreMenu
			if Gangs.Coords.Coffre == nil then 
				CoffreMenu = "~r~❌"
			else 
				CoffreMenu = "~b~✅"
			end 
			RageUI.Button('Position du coffre', nil, { RightLabel = CoffreMenu }, true, {
				onSelected = function()
					local pPed = PlayerPedId()
					local pCoords = GetEntityCoords(pPed)
					Gangs.Coords.Coffre = pCoords
					
					ESX.ShowAdvancedNotification('~g~zDev', '~p~zGangsBuilder', '~r~ Vous avez définis : ~b~Coffre du Gang', 'CHAR_ASHLEY', 3)
				end
			})
			RageUI.Button('Gestion des grades', nil, { RightLabel = "→→→" }, true, {}, gradesMenu)
			RageUI.Separator()
			RageUI.Line({Line = {134, 23, 216 , 255}})
		
			RageUI.Button('Validation & Crée le gang ~b~'..Gangs.Label, nil, { RightLabel = "→→→" }, true, {
			
				onSelected = function()
					if Gangs.Name == "" or Gangs.Label == "" or Gangs.Coords.BossMenu == nil or Gangs.Coords.Garage.ExitVeh == nil or Gangs.Coords.Garage.SpawnCoord == nil or Gangs.Coords.Garage.RangeVeh == nil or Gangs.Coords.Coffre == nil then 
					
						ESX.ShowAdvancedNotification('~g~zDev', '~p~zGangsBuilder', '~r~ Imposible : ~b~Paramètre Non Définis', 'CHAR_ASHLEY', 3)
					else 
						if GradeCount >= 1 then 
							TriggerServerEvent("zGangsBuilder:CreateGangs", Gangs)
							RageUI.CloseAll()
						else
						
							ESX.ShowAdvancedNotification('~g~zDev', '~p~zGangsBuilder', '~r~ Imposible: ~b~Il dois y avoir 1 grade au minimum', 'CHAR_ASHLEY', 3)
						end
					end
				end
			})

		end, function()
		end)

		RageUI.IsVisible(gradesMenu, function()

			RageUI.Button("~b~→→ ~s~Ajouter un grade", nil, { RightLabel = "→→" }, true, {
				onSelected = function()
					local result = KeyboardInput('Nom du grade', ('Nom du grade'), '', 50)
					if result and result ~= "" then 
						local Exist = false
						local GradeTable = {}
						for k,v in pairs(Gangs.Grades) do 
							table.insert(GradeTable, tonumber(k))
							if v.label == result then 
							
								ESX.ShowAdvancedNotification('~g~zDev', '~p~zGangsBuilder', '~r~ Erreur : ~b~Grade Déja Existant', 'CHAR_ASHLEY', 3)
								Exist = true
							end
						end
						if not Exist then
							local noSpace = string.lower(string.gsub(result, "%s+", "_"))
							local max = CountGrade(GradeTable)
							if not Gangs.Grades[max] then 
								Gangs.Grades[max] = {}
								Gangs.Grades[max].name = noSpace
								Gangs.Grades[max].label = tostring(result)
								GradeCount = GradeCount + 1
							end
						end
					else 
						
						ESX.ShowAdvancedNotification('~g~zDev', '~p~zGangsBuilder', '~r~ Erreur : ~b~Parametre Mal Renseigner', 'CHAR_ASHLEY', 3)
					end
				end
			})
			if json.encode(Gangs.Grades) ~= "[]" then 
				RageUI.Separator("↓ Grades Deja Crée ↓")
			end
			local GradeLabel
			local GradeRight
			if Gangs.Grades["1"].label == "" then 
				GradeLabel = "[~r~Obligatoire~s~] ~b~Grade Boss"
				GradeRight = "~r~À definir~s~ →→→"
			else 
				GradeLabel = "~r~→→ ~b~"..Gangs.Grades["1"].label.." ~s~"
				GradeRight = "~b~Crée / Modifier"
			end 
			RageUI.Button(GradeLabel, nil, { RightLabel = GradeRight }, true, {
				onSelected = function()
					local result = KeyboardInput('Nom du grade', ('Nom du grade'), '', 50)
					if result and result ~= "" then 
						Gangs.Grades["1"].label = tostring(result)                  
					else 
					
						ESX.ShowAdvancedNotification('~g~zDev', '~p~zGangsBuilder', '~r~ Erreur : ~b~Parametre Mal Renseigner', 'CHAR_ASHLEY', 3)
					end
				end
			})
			for k,v in pairs(Gangs.Grades) do 
				if v.name ~= "boss" then
					RageUI.Button("~r~→→ ~b~"..v.label, nil, { RightLabel = "~r~Supprimer~s~ →→→" }, true, {
						onSelected = function()
							Gangs.Grades[k] = nil
							GradeCount = GradeCount - 1
						end
					})
				end
			end

		end, function()
		end)

		if not RageUI.Visible(menu) and not RageUI.Visible(gradesMenu) then
			menu = RMenu:DeleteType('menu', true)
			gradesMenu = RMenu:DeleteType('gradesMenu', true)
		end
	end
end
RegisterNetEvent("zGangsBuilder:OpenMenuCreator")
AddEventHandler("zGangsBuilder:OpenMenuCreator", OpenMenu)

function OpenMenuGarage()
	TriggerServerEvent("zGangsBuilder:playerOpenedGarage", CurrentGangs.name) -- ANTI DUPIS
	local VehLoaded = false
	ESX.TriggerServerCallback("zGangsBuilder:GetVehiclesGangs", function(result) 
		CurrentGangs.vehicle = result
		VehLoaded = true
	end, CurrentGangs.name)

	while not VehLoaded do Wait(1) end

	local VehCount = CountTable(CurrentGangs.vehicle)
	local menu = RageUI.CreateMenu("Garage ", VehCount.." véhicule(s) sont dans votre garage", 10, 90, 'builder', 'interaction_bgd')

	RageUI.Visible(menu, not RageUI.Visible(menu))

	while menu do
		Wait(0)
		RageUI.IsVisible(menu, function()

			if VehCount > 0 then 
				for k,v in pairs(CurrentGangs.vehicle) do 
					local vName = GetDisplayNameFromVehicleModel(v.model)
					RageUI.Button(vName.." [~r~"..v.plate.."~s~]", nil, { RightLabel = "~r~Sortir~s~ →→" }, true, {
						onSelected = function()
							TriggerServerEvent("zGangsBuilder:SuppVehicle", CurrentGangs.name, v.plate, vName)
						end
					})
				end
			else 
				RageUI.Line({Line = {134, 23, 216 , 255}})
				RageUI.Separator()
				RageUI.Line({Line = {134, 23, 216 , 255}})
			end

		end, function()
		end)

		if not RageUI.Visible(menu) then
			menu = RMenu:DeleteType('menu', true)
			TriggerServerEvent("zGangsBuilder:playerClosedGarage", CurrentGangs.name)
		end
	end
end

