-- SMVLPD / PD5M - Animal muerto en la calzada
local active,accepted,spawned,located=false,false,false,false
local coords,animal,routeBlip,animalBlip=nil,nil,nil,nil
local models={"a_c_boar","a_c_coyote","a_c_deer","a_c_mtlion"}

local function notify(t)
 SetNotificationTextEntry("STRING"); AddTextComponentString(t); DrawNotification(false,false)
end

local function cleanup()
 if routeBlip and DoesBlipExist(routeBlip) then RemoveBlip(routeBlip) end
 if animalBlip and DoesBlipExist(animalBlip) then RemoveBlip(animalBlip) end
 if animal and DoesEntityExist(animal) then SetEntityAsMissionEntity(animal,true,true); DeletePed(animal) end
 active,accepted,spawned,located=false,false,false,false
 coords,animal,routeBlip,animalBlip=nil,nil,nil,nil
end

local function roadLocation()
 local p=GetEntityCoords(PlayerPedId())
 for i=1,30 do
  local a=math.random()*math.pi*2.0
  local d=math.random(350,650)
  local ok,node=GetClosestVehicleNode(p.x+math.cos(a)*d,p.y+math.sin(a)*d,p.z,1,3.0,0)
  if ok and node then return node end
 end
 return vector3(p.x+450.0,p.y,p.z)
end

RegisterCommand("deadanimal",function()
 if active then notify("~y~Ya hay un aviso de animal en la calzada activo."); return end
 coords=roadLocation(); active=true
 notify("~b~CENTRAL: ~w~Animal muerto bloqueando la calzada.~n~~y~Pulsa Y para aceptar el aviso.")
 print("^3[DEAD ANIMAL] Aviso generado.^7")
end,false)

CreateThread(function()
 while true do
  Wait(0)
  if active and not accepted and IsControlJustReleased(0,246) then
   accepted=true
   routeBlip=AddBlipForCoord(coords.x,coords.y,coords.z)
   SetBlipSprite(routeBlip,141); SetBlipColour(routeBlip,5); SetBlipRoute(routeBlip,true)
   BeginTextCommandSetBlipName("STRING"); AddTextComponentString("Animal en la calzada"); EndTextCommandSetBlipName(routeBlip)
   SetNewWaypoint(coords.x,coords.y)
   notify("~g~Aviso aceptado.~n~~w~Dirígete al punto indicado.")
  end
 end
end)

CreateThread(function()
 while true do
  Wait(500)
  if active and accepted and not spawned and coords and #(GetEntityCoords(PlayerPedId())-coords)<120.0 then
   spawned=true
   local name=models[math.random(#models)]; local model=joaat(name)
   RequestModel(model); while not HasModelLoaded(model) do Wait(50) end
   animal=CreatePed(28,model,coords.x,coords.y,coords.z,math.random(0,359)+0.0,true,true)
   SetEntityAsMissionEntity(animal,true,true); SetEntityHealth(animal,0)
   animalBlip=AddBlipForEntity(animal); SetBlipSprite(animalBlip,141); SetBlipColour(animalBlip,2)
   SetModelAsNoLongerNeeded(model)
   print("^2[DEAD ANIMAL] Escena creada: "..name.."^7")
  end
 end
end)

CreateThread(function()
 while true do
  Wait(500)
  if active and spawned and not located and animal and DoesEntityExist(animal) then
   if #(GetEntityCoords(PlayerPedId())-GetEntityCoords(animal))<35.0 then
    located=true
    if routeBlip and DoesBlipExist(routeBlip) then RemoveBlip(routeBlip); routeBlip=nil end
    notify("~b~CENTRAL: ~w~Animal localizado.~n~~y~Asegura la zona y solicita su retirada.~n~~w~Acércate y pulsa E para finalizar.")
   end
  end
 end
end)

CreateThread(function()
 while true do
  local wait=500
  if active and located and animal and DoesEntityExist(animal) then
   if #(GetEntityCoords(PlayerPedId())-GetEntityCoords(animal))<=4.0 then
    wait=0
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName("Pulsa ~INPUT_CONTEXT~ para solicitar la retirada del animal")
    EndTextCommandDisplayHelp(0,false,true,-1)
    if IsControlJustReleased(0,38) then
     notify("~b~CENTRAL: ~g~Aviso finalizado.~n~~w~Retirada solicitada y calzada despejada.")
     cleanup()
    end
   end
  end
  Wait(wait)
 end
end)

RegisterCommand("canceldeadanimal",function()
 if active then notify("~b~CENTRAL: ~w~Aviso cancelado."); cleanup() end
end,false)

print("^2[DEAD ANIMAL] Archivo cargado correctamente.^7")
