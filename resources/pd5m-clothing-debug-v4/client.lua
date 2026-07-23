local open=false
local propIndex=1
local drawable=-1
local texture=0
local props={{name='Reloj (muñeca izquierda)',id=6},{name='Pulsera (muñeca derecha)',id=7}}

local function P() return props[propIndex] end
local function count()
 return GetNumberOfPedPropDrawableVariations(PlayerPedId(),P().id)
end
local function textures()
 if drawable<0 then return 0 end
 return GetNumberOfPedPropTextureVariations(PlayerPedId(),P().id,drawable)
end
local function apply()
 local ped=PlayerPedId()
 if drawable<0 then
  ClearPedProp(ped,P().id)
  drawable=-1 texture=0 return
 end
 local n=count()
 if n<=0 then drawable=-1 ClearPedProp(ped,P().id) return end
 if drawable>=n then drawable=-1 end
 if drawable< -1 then drawable=n-1 end
 if drawable==-1 then ClearPedProp(ped,P().id) return end
 local tn=textures()
 if tn<=0 then texture=0 else
  if texture<0 then texture=tn-1 elseif texture>=tn then texture=0 end
 end
 SetPedPropIndex(ped,P().id,drawable,texture,true)
end
local function tx(x,y,s,v)
 SetTextFont(0);SetTextScale(s,s);SetTextColour(255,255,255,255);SetTextOutline()
 SetTextEntry('STRING');AddTextComponentString(v);DrawText(x,y)
end
RegisterCommand('propsv4',function() open=not open drawable=-1 texture=0 end,false)
CreateThread(function()
 while true do
  if not open then Wait(200) else
   Wait(0)
   DrawRect(.215,.18,.41,.30,0,0,0,195)
   tx(.025,.045,.48,'PD5M - Relojes y Pulseras')
   tx(.025,.085,.35,('Prop: %s [PROP %d]'):format(P().name,P().id))
   local dv=drawable==-1 and 'NINGUNO' or tostring(drawable)
   tx(.025,.120,.35,('Drawable: %s / %d'):format(dv,math.max(0,count()-1)))
   tx(.025,.150,.35,('Texture: %d / %d'):format(texture,math.max(0,textures()-1)))
   tx(.025,.190,.30,'ARRIBA / ABAJO: Reloj o Pulsera')
   tx(.025,.215,.30,'IZQ / DER: NINGUNO y modelos')
   tx(.025,.240,.30,'Q / E: textura | ENTER: imprimir F8')
   tx(.025,.265,.30,'BACKSPACE o /propsv4: cerrar')
   if IsControlJustPressed(0,172) or IsControlJustPressed(0,173) then
    propIndex=propIndex==1 and 2 or 1 drawable=-1 texture=0
   elseif IsControlJustPressed(0,174) then drawable=drawable-1 texture=0 apply()
   elseif IsControlJustPressed(0,175) then drawable=drawable+1 texture=0 apply()
   elseif IsControlJustPressed(0,44) then texture=texture-1 apply()
   elseif IsControlJustPressed(0,38) then texture=texture+1 apply()
   elseif IsControlJustPressed(0,191) then
    print(('[PD5M PROP] prop=%d drawable=%d texture=%d'):format(P().id,drawable,texture))
   elseif IsControlJustPressed(0,177) then open=false end
  end
 end
end)
