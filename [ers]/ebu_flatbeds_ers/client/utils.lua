if not Config.DisableExtKeyControls then
	RegisterKeyMapping('+ers_bedLower', Config.Controlmessages.LowerBed, 'keyboard', 'DOWN')
	RegisterKeyMapping('+ers_bedRaise', Config.Controlmessages.RaiseBed, 'keyboard', 'UP')
	RegisterKeyMapping('+ers_flatbedWheel', Config.Controlmessages.WheelLift, 'keyboard', 'H')
	if Config.EnableRopes then
		RegisterKeyMapping('+ers_flatbedWind', Config.Controlmessages.WindWinch, 'keyboard', 'LEFT')
		RegisterKeyMapping('+ers_flatbedUWind', Config.Controlmessages.ExtendWinch, 'keyboard', 'RIGHT')
		RegisterKeyMapping('+ers_flatbedRope', Config.Controlmessages.DetachWinch, 'keyboard', 'G')
	end
end

if not Config.DisableInVehControl then
	RegisterKeyMapping('+ers_flatbedAtt', Config.Controlmessages.AttachVehicle, 'keyboard', 'E')
end

RegisterKeyMapping('+ers_flatbedWarp', 'Flatbed Get In Car', 'keyboard', 'F')

--allowed() is the function that determines if the player is allowed to use the dyno. DO NOT RENAME THE FUNCTION
--Place whatever job check code you want in here, return true if allowed, false if not
function allowed()
    return true
end

--This function returns if the vehicle is locked or not when trying to get in the loaded vehicle from next to the trailer
--false = NOT locked  true == LOCKED
function IsVehicleLocked(car)
    return DecorGetInt(car, '_VEH_DOOR_LOCK_STATUS') == 2 or DecorGetInt(car, '_VEH_DOOR_LOCK_STATUS') == 10
end

--======NOTIFICATIONS======--
function LoadCompleteNotif()
	EndTextCommandThefeedPostTickerForced(1,1)
	ThefeedNextPostBackgroundColor(184)
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(Config.NotiLoadCompleteMessage)
	EndTextCommandThefeedPostTicker(true, true)
	Wait(3000)
	EndTextCommandThefeedPostTickerForced(1,1)
end

function UnLoadCompleteNotif()
	EndTextCommandThefeedPostTickerForced(1,1)
	ThefeedNextPostBackgroundColor(184)
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(Config.NotiUnLoadCompleteMessage)
	EndTextCommandThefeedPostTicker(true, true)
	Wait(3000)
	EndTextCommandThefeedPostTickerForced(1,1)
end

function FBBlockedNotif()
	EndTextCommandThefeedPostTickerForced(1,1)
	ThefeedNextPostBackgroundColor(6)
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(Config.NotiFBBlockedMessage)
	EndTextCommandThefeedPostTicker(true, true)
	Wait(3000)
	EndTextCommandThefeedPostTickerForced(1,1)
end

function BlockedMessage()
	EndTextCommandThefeedPostTickerForced(1,1)
	ThefeedNextPostBackgroundColor(6)
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(Config.NotiBlockedMessage)
	EndTextCommandThefeedPostTicker(true, true)
	Wait(3000)
	EndTextCommandThefeedPostTickerForced(1,1)
end



--Help Text Messages
function message(lineOne, lineTwo, lineThree, duration, loop)
    BeginTextCommandDisplayHelp("THREESTRINGS")
    AddTextComponentSubstringPlayerName(lineOne)
    AddTextComponentSubstringPlayerName(lineTwo or "")
    AddTextComponentSubstringPlayerName(lineThree or "")
  
    -- shape (always 0), loop (bool), makeSound (bool), duration (5000 max 5 sec)
    EndTextCommandDisplayHelp(0, loop, false, duration or 5000)
end


--Advanced Functions
function validTruck(veh)
	local playerPos = GetEntityCoords(PlayerPedId())
	local truckCoords = GetEntityCoords(veh)
	if trucks and #trucks > 0 and has_value(trucks, GetEntityModel(veh)) and #(playerPos - truckCoords) < 10 then
		return true
	end
	return false
end

--Target
if Config.UseTarget then
    --QB CORE
	local bones = {"seat_dside_f", "seat_dside_r", "seat_pside_f", "seat_pside_f", 'boot', "scoop", 'chassis'}
	local options = {}
	options[#options+1] = {
		num = 1,
		icon = 'fa-solid fa-car-side',
		label = '[Winch] Attach Winch',
		action = function(entity)
			playerAttach(entity)
		end,
		canInteract = function(entity, distance, data)
			return winchInHand and Config.EnableRopes
		end,
	}
	options[#options+1] = {
		num = 2,
		icon = 'fa-solid fa-angles-left',
		label = '[Winch] Attach / Wind Winch',
		action = function(entity)
			TriggerEvent("ebu_flatbeds:client:targetflatbedWind", entity)
		end,
		canInteract = function(entity, distance, data)
			return Config.Trucks[GetEntityModel(entity)] and Config.Trucks[GetEntityModel(entity)].type ~= "static" and allowed() and Config.EnableRopes
		end,
	}
	options[#options+1] = {
		num = 3,
		icon = 'fa-solid fa-angles-right',
		label = '[Winch] UnWind Winch',
		action = function(entity)
			TriggerEvent("ebu_flatbeds:client:targetflatbedUnWind", entity)
		end,
		canInteract = function(entity, distance, data)
			return Config.Trucks[GetEntityModel(entity)] and Config.Trucks[GetEntityModel(entity)].type ~= "static" and allowed() and Config.EnableRopes
		end,
	}
	options[#options+1] = {
		num = 4,
		icon = 'fa-solid fa-angles-up',
		label = '[Winch] Raise Bed',
		action = function(entity)
			TriggerEvent("ebu_flatbeds:client:targetflatbedRaise", entity)
		end,
		canInteract = function(entity, distance, data)
			return Config.Trucks[GetEntityModel(entity)] and Config.Trucks[GetEntityModel(entity)].type ~= "static" and allowed()
		end,
	}
	options[#options+1] = {
		num = 5,
		icon = 'fa-solid fa-angles-down',
		label = '[Winch] Lower Bed',
		action = function(entity)
			TriggerEvent("ebu_flatbeds:client:targetflatbedLower", entity)
		end,
		canInteract = function(entity, distance, data)
			return Config.Trucks[GetEntityModel(entity)] and Config.Trucks[GetEntityModel(entity)].type ~= "static" and allowed()
		end,
	}
	options[#options+1] = {
		num = 6,
		icon = 'fa-solid fa-ban',
		label = '[Winch] Remove Winch',
		action = function(entity)
			TriggerEvent("ebu_flatbeds:client:targetflatbedRope", entity)
		end,
		canInteract = function(entity, distance, data)
			return Config.Trucks[GetEntityModel(entity)] and Config.Trucks[GetEntityModel(entity)].type ~= "static" and allowed() and Config.EnableRopes
		end,
	}
	options[#options+1] = {
		num = 7,
		icon = 'fa-solid fa-car-side',
		label = '[Winch] Attach / Detach Vehicle',
		action = function(entity)
			TriggerEvent("ebu_flatbeds:client:targetflatbedAtt", entity)
		end,
		canInteract = function(entity, distance, data)
			return Config.Trucks[GetEntityModel(entity)] and Config.Trucks[GetEntityModel(entity)].type ~= "static" and allowed()
		end,
	}
	options[#options+1] = {
		num = 8,
		icon = 'fa-solid fa-truck-ramp-box',
		label = '[Winch] Toggle Wheel Lift',
		action = function(entity)
			TriggerEvent("ebu_flatbeds:client:targetflatbedWheel", entity)
		end,
		canInteract = function(entity, distance, data)
			return Config.Trucks[GetEntityModel(entity)] and Config.Trucks[GetEntityModel(entity)].wheellift and allowed() and Config.EnableRopes
		end,
	}

	exports['qb-target']:AddTargetBone(bones, {
		options = options,
		distance = 5.5
	})
    
end

