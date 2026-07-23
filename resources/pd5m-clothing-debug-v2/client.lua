local opened=false
local ci,pi,d,t=1,1,0,0
local cols={{label='LSPD_EUP',name='mp_m_lspd'},{label='EmergencyEUP',name='mp_m_emergency'}}
local parts={{'Máscara',1},{'Brazos / Torso',3},{'Pantalón',4},{'Bolsas',5},{'Zapatos',6},{'Accesorios',7},{'Camiseta / Interior',8},{'Chaleco / Armor',9},{'Insignias / Decals',10},{'Chaqueta / Top',11}}
local function C() return cols[ci] end
local function P() return parts[pi] end
local function nd() return GetNumberOfPedCollectionDrawableVariations(PlayerPedId(),P()[2],C().name) end
local function nt()
 local n=nd()
 if n<=0 or d<0 or d>=n then return 0 end
 return GetNumberOfPedCollectionTextureVariations(PlayerPedId(),P()[2],C().name,d)
end
local function apply()
 local n=nd()
 if n<=0 then d=0;t=0;return end
 if d<0 then d=n-1 elseif d>=n then d=0 end
 local x=nt()
 if x<=0 then t=0 else if t<0 then t=x-1 elseif t>=x then t=0 end end
 SetPedCollectionComponentVariation(PlayerPedId(),P()[2],C().name,d,t,0)
end
local function text(x,y,s,v)
 SetTextFont(0);SetTextScale(s,s);SetTextColour(255,255,255,255);SetTextOutline()
 SetTextEntry('STRING');AddTextComponentString(v);DrawText(x,y)
end
local function draw()
 local n,x=nd(),nt()
 DrawRect(.21,.20,.40,.35,0,0,0,195)
 text(.025,.045,.48,'PD5M - Explorador EUP por colección')
 text(.025,.085,.35,('Colección: %s [%s]'):format(C().label,C().name))
 text(.025,.115,.35,('Pieza: %s [ID %d]'):format(P()[1],P()[2]))
 text(.025,.145,.35,('Drawable: %d / %d'):format(d,math.max(0,n-1)))
 text(.025,.175,.35,('Texture: %d / %d'):format(t,math.max(0,x-1)))
 text(.025,.215,.30,'A / D: cambiar colección')
 text(.025,.240,.30,'ARRIBA / ABAJO: cambiar pieza')
 text(.025,.265,.30,'IZQ / DER: cambiar drawable')
 text(.025,.290,.30,'Q / E: cambiar textura')
 text(.025,.315,.30,'ENTER: imprimir IDs en F8')
 text(.025,.340,.30,'BACKSPACE o /ropav2: cerrar')
end
RegisterCommand('ropav2',function() opened=not opened;d=0;t=0 end,false)
CreateThread(function()
 while true do
  if not opened then Wait(250) else
   Wait(0);draw()
   if IsControlJustPressed(0,34) then ci=ci-1;if ci<1 then ci=#cols end;d=0;t=0
   elseif IsControlJustPressed(0,35) then ci=ci+1;if ci>#cols then ci=1 end;d=0;t=0
   elseif IsControlJustPressed(0,172) then pi=pi-1;if pi<1 then pi=#parts end;d=0;t=0
   elseif IsControlJustPressed(0,173) then pi=pi+1;if pi>#parts then pi=1 end;d=0;t=0
   elseif IsControlJustPressed(0,174) then d=d-1;t=0;apply()
   elseif IsControlJustPressed(0,175) then d=d+1;t=0;apply()
   elseif IsControlJustPressed(0,44) then t=t-1;apply()
   elseif IsControlJustPressed(0,38) then t=t+1;apply()
   elseif IsControlJustPressed(0,191) then print(('[PD5M EUP] collection=%s component=%d drawable=%d texture=%d'):format(C().name,P()[2],d,t))
   elseif IsControlJustPressed(0,177) then opened=false end
  end
 end
end)
