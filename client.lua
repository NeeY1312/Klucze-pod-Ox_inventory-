ESX = nil
CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) 
			ESX = obj 
		end)
		
		Citizen.Wait(250)
	end
end)

local vehicleKeys = {}
local Ped = {
	Exists = false,
	Id = nil,
	InVehicle = false,
	VehicleInFront = nil,
	VehicleInFrontLock = nil
}
local TimeElapsed = 0
local EngineStatus = false

CreateThread(function()
	while true do
		Citizen.Wait(0)

		TimeElapsed = TimeElapsed + 200
		if not IsPauseMenuActive() then
			local ped = PlayerPedId()
			if not IsEntityDead(ped) then
				Ped.Exists = true
				Ped.Id = ped

				Ped.InVehicle = IsPedInAnyVehicle(Ped.Id, false)
			else
				Ped.Exists = false
			end
		else
			Ped.Exists = false
		end
	end
end)

RegisterCommand("+lockcar", function()
	local playerPed = PlayerPedId()
	local vehicle = nil
	local InVehicle = IsPedInAnyVehicle(playerPed, false)
	if InVehicle then
		vehicle = GetVehiclePedIsIn(playerPed, false)
		if vehicle and (vehicle == 0 or GetPedInVehicleSeat(vehicle, -1) ~= playerPed) then
			vehicle = nil
		end
	else
		vehicle = ESX.Game.GetVehicleInDirection(0.0, 20.0, -0.95)
	end
	local coords = GetEntityCoords(playerPed)
	local plate = GetVehicleNumberPlateText(vehicle)
	if vehicle then
		local count = exports.ox_inventory:Search('count', 'carkey', plate)
		local lockStatus = GetVehicleDoorLockStatus(vehicle)
		if InVehicle then
			if count > 0 then
				local id = NetworkGetNetworkIdFromEntity(vehicle)
				SetNetworkIdCanMigrate(id, false)

				local tries = 0
				while not NetworkHasControlOfNetworkId(id) and tries < 10 do
					tries = tries + 1
					NetworkRequestControlOfNetworkId(id)
					Citizen.Wait(100)
				end

				if lockStatus < 2 then
					SetVehicleDoorsLocked(vehicle, 4)
					SetVehicleDoorsLockedForAllPlayers(vehicle, true)
					SetVehicleDoorsShut(vehicle, false)

					SetVehicleAlarm(vehicle, true)
					exports.dopeNotify:SendNotification({					
						text = '<b><i class="fas fa-bell"></i> POWIADOMIENIE</span></b></br><span style="color: #a9a29f;">Pojazd zosta� zamkni�ty!',
						type = "success",
						timeout = 3000,
						layout = "topRight"
					})					
					TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 4.0, 'lock', 0.3)
					if not IsPedInAnyVehicle(playerPed, true) then
						CreateThread(function()
							RequestAnimDict("gestures@m@standing@casual")
							while not HasAnimDictLoaded("gestures@m@standing@casual") do
								Citizen.Wait(0)
							end

							TaskPlayAnim(playerPed, "gestures@m@standing@casual", "gesture_you_soft", 3.0, 1.0, -1, 48, 0, 0, 0, 0)
						end)
					end
				elseif lockStatus > 1 then
					SetVehicleDoorsLocked(vehicle, 1)
					SetVehicleDoorsLockedForAllPlayers(vehicle, false)

					SetVehicleAlarm(vehicle, false)
					exports.dopeNotify:SendNotification({					
						text = '<b><i class="fas fa-bell"></i> POWIADOMIENIE</span></b></br><span style="color: #a9a29f;">Pojazd zosta� otwarty!',
						type = "success",
						timeout = 3000,
						layout = "topRight"
					})
					TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 4.0, 'unlock', 0.3)
					if not IsPedInAnyVehicle(playerPed, true) then
						CreateThread(function()
							RequestAnimDict("gestures@m@standing@casual")
							while not HasAnimDictLoaded("gestures@m@standing@casual") do
								Citizen.Wait(0)
							end

							TaskPlayAnim(playerPed, "gestures@m@standing@casual", "gesture_you_soft", 3.0, 1.0, -1, 48, 0, 0, 0, 0)
						end)
					end
				end
			else
				if vehicleKeys[plate] == nil or vehicleKeys[plate] == false then
					print( GetRandomIntInRange(1, 100))
					if GetRandomIntInRange(1, 100) < 60 then
						TriggerServerEvent('neey_keys:addKey', plate)
						exports.dopeNotify:SendNotification({					
							text = '<b><i class="fas fa-bell"></i> POWIADOMIENIE</span></b></br><span style="color: #a9a29f;">Znalaz�e� Klucze w stacyjce!',
							type = "success",
							timeout = 3000,
							layout = "topRight"
						})						
					else
						exports.dopeNotify:SendNotification({					
							text = '<b><i class="fas fa-bell"></i> POWIADOMIENIE</span></b></br><span style="color: #a9a29f;">Niestety nie znalaz�e� kluczy!',
							type = "error",
							timeout = 3000,
							layout = "topRight"
						})									
					end
				else
					exports.dopeNotify:SendNotification({					
						text = '<b><i class="fas fa-bell"></i> POWIADOMIENIE</span></b></br><span style="color: #a9a29f;">Niestety nie znalaz�e� kluczy!',
						type = "error",
						timeout = 3000,
						layout = "topRight"
					})
					TriggerServerEvent('neey_keys:addKey', plate, false)

				end
			end
		else
			if count > 0 then
				local id = NetworkGetNetworkIdFromEntity(vehicle)
				SetNetworkIdCanMigrate(id, false)

				local tries = 0
				while not NetworkHasControlOfNetworkId(id) and tries < 10 do
					tries = tries + 1
					NetworkRequestControlOfNetworkId(id)
					Citizen.Wait(100)
				end

				if lockStatus < 2 then
					SetVehicleDoorsLocked(vehicle, 4)
					SetVehicleDoorsLockedForAllPlayers(vehicle, true)
					SetVehicleDoorsShut(vehicle, false)

					SetVehicleAlarm(vehicle, true)

					exports.dopeNotify:SendNotification({					
						text = '<b><i class="fas fa-bell"></i> POWIADOMIENIE</span></b></br><span style="color: #a9a29f;">Pojazd zosta� zamkni�ty!',
						type = "success",
						timeout = 3000,
						layout = "topRight"
					})
					TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 4.0, 'lock', 0.3)
					if not IsPedInAnyVehicle(playerPed, true) then
						CreateThread(function()
							RequestAnimDict("gestures@m@standing@casual")
							while not HasAnimDictLoaded("gestures@m@standing@casual") do
								Citizen.Wait(0)
							end

							-- TaskPlayAnim(playerPed, "gestures@m@standing@casual", "gesture_you_soft", 3.0, 1.0, -1, 48, 0, 0, 0, 0)
						end)
					end
				elseif lockStatus > 1 then
					SetVehicleDoorsLocked(vehicle, 1)
					SetVehicleDoorsLockedForAllPlayers(vehicle, false)

					SetVehicleAlarm(vehicle, false)
					exports.dopeNotify:SendNotification({					
						text = '<b><i class="fas fa-bell"></i> POWIADOMIENIE</span></b></br><span style="color: #a9a29f;">Pojazd zosta� otwarty!',
						type = "success",
						timeout = 3000,
						layout = "topRight"
					})
					TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 4.0, 'unlock', 0.3)
					if not IsPedInAnyVehicle(playerPed, true) then
						CreateThread(function()
							RequestAnimDict("gestures@m@standing@casual")
							while not HasAnimDictLoaded("gestures@m@standing@casual") do
								Citizen.Wait(0)
							end

							-- TaskPlayAnim(playerPed, "gestures@m@standing@casual", "gesture_you_soft", 3.0, 1.0, -1, 48, 0, 0, 0, 0)
						end)
					end
				end
			end
		end
	end
end)

RegisterCommand('+stopcar', function()
	EngineToggle(PlayerPedId())
end)

function EngineToggle(playerPed)
	local vehicle = GetVehiclePedIsIn(playerPed, false)
	local plate = GetVehicleNumberPlateText(vehicle)

	if vehicle and vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == playerPed then
		local plate = GetVehicleNumberPlateText(vehicle)
		if type(plate) == 'string' then
			plate = plate:gsub("%s$", "")
		end

		local status = IsVehicleEngineOn(vehicle)
		
		if not status then
				EngineStatus = true
				SetVehicleEngineOn(vehicle, true, false, true)
				exports.dopeNotify:SendNotification({					
					text = '<b><i class="fas fa-bell"></i> POWIADOMIENIE</span></b></br><span style="color: #a9a29f;">Silnik zosta� w��czony!',
					type = "success",
					timeout = 3000,
					layout = "topRight"
				})
				EngineStatus = true
		else
			EngineStatus = false
			SetVehicleEngineOn(vehicle, false, false, true)
			exports.dopeNotify:SendNotification({					
				text = '<b><i class="fas fa-bell"></i> POWIADOMIENIE</span></b></br><span style="color: #a9a29f;">Silnik zosta� wy��czony!',
				type = "success",
				timeout = 3000,
				layout = "topRight"
			})
		end
	end

end

RegisterNetEvent('neey_keys:updateKeys')
AddEventHandler('neey_keys:updateKeys', function(plate)
	vehicleKeys[plate] = true
end)

RegisterKeyMapping('+stopcar', 'Odpalanie pojazdu', "KEYBOARD", 'Y')
RegisterKeyMapping('+lockcar', 'Zamykanie pojazdu', "KEYBOARD", 'U')

function carkey(data, slot)
	send(data.slot)
end

function send(slot)
	TriggerServerEvent('neey_keys:useKeys', slot)
end

RegisterNetEvent('neey_keys:useKey')
AddEventHandler('neey_keys:useKey', function(kplate)
	local vehs = ESX.Game.GetVehiclesInArea(GetEntityCoords(PlayerPedId()), 75.0)
	local found = false
	local vehicle = nil
	for a,b in pairs(vehs) do
		local platet = GetVehicleNumberPlateText(b)
		if platet == kplate then
			found = true
			vehicle = b
			break
		end
	end
	local plate = GetVehicleNumberPlateText(vehicle)
	if found then
		local lockStatus = GetVehicleDoorLockStatus(vehicle)
		local id = NetworkGetNetworkIdFromEntity(vehicle)
		SetNetworkIdCanMigrate(id, false)

		local tries = 0
		while not NetworkHasControlOfNetworkId(id) and tries < 10 do
			tries = tries + 1
			NetworkRequestControlOfNetworkId(id)
			Citizen.Wait(100)
		end

		if lockStatus < 2 then
			SetVehicleDoorsLocked(vehicle, 4)
			SetVehicleDoorsLockedForAllPlayers(vehicle, true)
			SetVehicleDoorsShut(vehicle, false)

			SetVehicleAlarm(vehicle, true)
			exports.dopeNotify:SendNotification({					
				text = '<b><i class="fas fa-bell"></i> POWIADOMIENIE</span></b></br><span style="color: #a9a29f;">Pojazd zosta� zamkni�ty!',
				type = "success",
				timeout = 3000,
				layout = "topRight"
			})
			TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 4.0, 'lock', 0.3)
			if not IsPedInAnyVehicle(playerPed, true) then
				CreateThread(function()
					RequestAnimDict("gestures@m@standing@casual")
					while not HasAnimDictLoaded("gestures@m@standing@casual") do
						Citizen.Wait(0)
					end

					-- TaskPlayAnim(playerPed, "gestures@m@standing@casual", "gesture_you_soft", 3.0, 1.0, -1, 48, 0, 0, 0, 0)
				end)
			end
		elseif lockStatus > 1 then
			SetVehicleDoorsLocked(vehicle, 1)
			SetVehicleDoorsLockedForAllPlayers(vehicle, false)

			SetVehicleAlarm(vehicle, false)
			exports.dopeNotify:SendNotification({					
				text = '<b><i class="fas fa-bell"></i> POWIADOMIENIE</span></b></br><span style="color: #a9a29f;">Pojazd zosta� otwarty!',
				type = "success",
				timeout = 3000,
				layout = "topRight"
			})
			TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 4.0, 'unlock', 0.3)
			if not IsPedInAnyVehicle(playerPed, true) then
				CreateThread(function()
					RequestAnimDict("gestures@m@standing@casual")
					while not HasAnimDictLoaded("gestures@m@standing@casual") do
						Citizen.Wait(0)
					end

					-- TaskPlayAnim(playerPed, "gestures@m@standing@casual", "gesture_you_soft", 3.0, 1.0, -1, 48, 0, 0, 0, 0)
				end)
			end
		end
	end
end)