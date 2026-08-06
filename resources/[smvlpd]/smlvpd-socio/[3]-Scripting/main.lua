local BuddySpawned = false
local BuddyServices = {}
function PoliceBuddy_Spawn(Uniform, ServiceType)
    -- Evita que una solicitud de borrado anterior elimine al nuevo companero.
    Removal = false
    local player = PlayerPedId()
    local BuddyService = ServiceType or GetBuddyService()
    local BuddyModel = tostring(Uniform or GetBuddyUniform(BuddyService))
    local BuddyModelHash = GetHashKey(BuddyModel)

    if not IsModelInCdimage(BuddyModelHash) or not IsModelValid(BuddyModelHash) then
        ShowNotification(('~r~Modelo de companero no valido: %s'):format(BuddyModel))
        BuddySpawned = false
        return false
    end

    RequestModel(BuddyModelHash)
    local timeoutAt = GetGameTimer() + 5000
    while not HasModelLoaded(BuddyModelHash) and GetGameTimer() < timeoutAt do
        Wait(10)
    end

    if not HasModelLoaded(BuddyModelHash) then
        ShowNotification(('~r~No se pudo cargar el modelo: %s'):format(BuddyModel))
        BuddySpawned = false
        return false
    end

    local spawnCoords = GetOffsetFromEntityInWorldCoords(player, 0.0, 1.5, 0.0)
    local pedType = BuddyService == 'police' and 6 or 4
    local Buddy = CreatePed(
        pedType,
        BuddyModelHash,
        spawnCoords.x,
        spawnCoords.y,
        spawnCoords.z,
        GetEntityHeading(player),
        true,
        true
    )

    SetModelAsNoLongerNeeded(BuddyModelHash)

    if DoesEntityExist(Buddy) then 
        BuddyServices[Buddy] = BuddyService
        TriggerEvent('PoliceBuddy:SetBuddy', Buddy, BuddyService)
        if BuddyService == 'police' then
            GiveWeaponToPed(Buddy,0x5EF9FEC4,1000,false,false)
            SetPedCombatAbility(Buddy,100)
            SetPedCombatAttributes(Buddy,46,true)
        else
            RemoveAllPedWeapons(Buddy, true)
            SetPedFleeAttributes(Buddy, 0, false)
        end
        return true
    else
        BuddySpawned = false
        ShowNotification('~r~No se pudo crear el companero.')
        return false
    end
end

RegisterNetEvent('PoliceBuddy:SetBuddy')
AddEventHandler('PoliceBuddy:SetBuddy', function(Bud, BuddyService)
local player = GetPlayerPed(-1)
local playerPos = GetEntityCoords( player )
local inFrontOfPlayer = GetOffsetFromEntityInWorldCoords( player, 0.0, 2.0, 0.0 )
Bud = Bud
  if DoesEntityExist(Bud) then
    NetworkRequestControlOfEntity(Bud)
    ClearPedTasksImmediately(Bud)
    SetEntityAsMissionEntity(Bud)
    SetBlockingOfNonTemporaryEvents(Bud, false)

    playerGroupId = GetPedGroupIndex(player)
    SetPedAsGroupMember(Bud, playerGroupId)
    SetGroupFormationSpacing(playerGroupId,1.0,1.0,1.0)
    AddRelationshipGroup("BUM1")
    if BuddyService == 'ambulance' then
        SetPedArmour(Bud, 0)
        SetPedCombatAttributes(Bud, 5, false)
        SetPedCombatAbility(Bud, 0)
    else
        SetPedArmour(Bud, math.random(50, 100))
        SetPedCombatAttributes(Bud, 5, true)
        SetPedCombatAbility(Bud, 100)
    end
    SetRelationshipBetweenGroups(0, GetHashKey("BUM1"), GetHashKey("PLAYER"))
    SetPedRelationshipGroupHash(Bud, GetHashKey("BUM1"))
    if BuddyService == 'ambulance' then
        ShowNotification('~r~Enfermera creada.')
    else
        ShowNotification('~b~Companero creado.')
    end
    BuddyBlip = AddBlipForEntity(Bud)
    SetBlipColour(BuddyBlip, BuddyService == 'ambulance' and 1 or 3)
    SetBlipSprite(BuddyBlip, 480)
    TriggerEvent('RegisterBuddy', Bud)
  else
    ShowNotification('Error. Please contact development.')
  end
end)
--=============================================
RegisterNetEvent('RegisterBuddy')
AddEventHandler('RegisterBuddy', function(Bud)
SetEntityAsMissionEntity(Bud)
local Bud = Bud
local Buddy = Bud 
Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(0)
        if DoesEntityExist(Buddy) then
            if StayCar then 
                TriggerEvent('staycar', Buddy) 
                StayCar = false 
            end
            if LeaveCar then 
                TriggerEvent('leavecar', Buddy) 
                LeaveCar = false 
            end
            if Removal then 
                BuddyServices[Buddy] = nil
                DeleteEntity(Buddy)
                Buddy = nil
                BuddyBlip = RemoveBlip(BuddyBlip)
                ShowNotification('~r~Buddy Removed.')
                Wait(500)
                Removal = false
                 
            end
            if IsPedDeadOrDying(GetPlayerPed(-1), 1) then 
                BuddyServices[Buddy] = nil
                DeleteEntity(Buddy)
                Buddy = nil
                BuddyBlip = RemoveBlip(BuddyBlip)
                ShowNotification('~r~Buddy Removed.')
            end
            if GetSeatPedIsTryingToEnter(Buddy) ~= 0 then
                TaskEnterVehicle(Buddy, GetVehiclePedIsIn(GetPlayerPed(-1)), -1, 0, 1.0, 1, 0)
            end
        end
    end
    end)
end)
--=============================================
RegisterNetEvent('staycar')
AddEventHandler('staycar', function(Bud)
local targetVehh = GetPlayersLastVehicle(player)
local player = GetPlayerPed(-1)
local playerGroupId = GetPedGroupIndex(player)

if DoesEntityExist(Bud) then
	if IsPedInVehicle(Bud, targetVehh, false) then
		ShowNotification('Buddy Staying In Car.')
		RemovePedFromGroup(Bud)
		SetBlockingOfNonTemporaryEvents(Bud, true)
		--ClearPedTasksImmediately(Bud)
	else
		ShowNotification('Buddy Going To Car.')
		RemovePedFromGroup(Bud)
		SetBlockingOfNonTemporaryEvents(Bud, true)
		ClearPedTasksImmediately(Bud)
		TaskEnterVehicle(Bud, targetVehh, -1, 0, 1.0, 1, 0)
	end
else
	ShowNotification('Buddy Does Not Exist.')
end
end)
RegisterNetEvent('leavecar')
AddEventHandler('leavecar', function(Bud)
local targetVehh = GetPlayersLastVehicle(player)
local player = GetPlayerPed(-1)
local playerGroupId = GetPedGroupIndex(player)
local BuddyService = BuddyServices[Bud] or 'police'

if DoesEntityExist(Bud) then
	if IsPedInVehicle(Bud, targetVehh, false) then
		ShowNotification('Buddy Getting Out Of Car.')
		NetworkRequestControlOfEntity(Bud)
		ClearPedTasksImmediately(Bud)
		TriggerEvent('selped', NetworkGetNetworkIdFromEntity(Bud))
		SetEntityAsMissionEntity(Bud)
		SetBlockingOfNonTemporaryEvents(Bud, true)
		SetPedAsGroupMember(Bud, playerGroupId)
		SetGroupFormationSpacing(playerGroupId,1.0,1.0,1.0)
        AddRelationshipGroup("BUM1")
        if BuddyService == 'ambulance' then
            SetPedArmour(Bud, 0)
            SetPedCombatAttributes(Bud, 5, false)
            SetPedCombatAbility(Bud, 0)
        else
            SetPedArmour(Bud, math.random(50, 100))
            SetPedCombatAttributes(Bud, 5, true)
            SetPedCombatAbility(Bud, 100)
        end
		SetRelationshipBetweenGroups(0, GetHashKey("BUM1"), GetHashKey("PLAYER"))
		SetPedRelationshipGroupHash(Bud, GetHashKey("BUM1"))
	else
		ShowNotification('Buddy Is Not In A Vehicle.')
	end
else
	ShowNotification('Buddy Does Not Exist.')
end
end)

RegisterNetEvent('smvlpd-socio:spawn')
AddEventHandler('smvlpd-socio:spawn', function()

    if BuddySpawned then
        ShowNotification('~y~Ya tienes un compañero.')
        return
    end

    BuddySpawned = true
    local serviceType = GetBuddyService()
    PoliceBuddy_Spawn(GetBuddyUniform(serviceType), serviceType)

end)

RegisterNetEvent('smvlpd-socio:remove')
AddEventHandler('smvlpd-socio:remove', function()

    BuddySpawned = false
    Removal = true

end)
