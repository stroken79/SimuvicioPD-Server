# SMVLPD Ranks

Recurso de rangos y puntos persistentes por servicio para Night ERS.

## Progreso por servicio

Los puntos y rangos se guardan de forma independiente para:

- `police`
- `ambulance`
- `fire`
- `tow`

Al cambiar de servicio se cargan automaticamente el rango y la puntuacion correspondientes. Los datos anteriores a la version 1.1.0 se conservan como progreso de `police`.

## Fusion con EMS

Este recurso sustituye tambien a `smvlpd-ems-ranks`. Al iniciarse importa los
rangos y puntos existentes de `smvlpd_ems_ranks` y `smvlpd_ems_points` como
progreso del servicio `ambulance`, sin sobrescribir datos ya migrados.

No inicies `smvlpd-ems-ranks` junto a este recurso. El vestuario EMS utiliza
ahora el export compatible `GetPlayerEMSRank` de `smvlpd-ranks`.

## Instalacion

`server.cfg` ya debe cargar primero `oxmysql`, `ox_lib` y `smvlpd-character`, y despues `smvlpd-ranks`.

Para permitir que un administrador gestione rangos, anade su licencia (sustituye el valor por la tuya) en `server.cfg`:

```cfg
add_ace group.admin smvlpd.ranks.manage allow
add_principal identifier.license:TU_LICENSE_AQUI group.admin
```

Usa `status` en la consola para comprobar que el recurso este iniciado.

## Comandos

- `/rango`: muestra el rango y uniforme asociado.
- `/armeria`: abre la armeria limitada por el rango actual.
- `/gestionrangos`: panel de administracion de rangos; requiere el permiso ACE anterior.
- `/subirrango <id>`: sube un nivel al jugador en su trabajo activo; requiere permiso de gestion.
- `/bajarrango <id>`: baja un nivel al jugador en su trabajo activo; requiere permiso de gestion.

## Uniformes EUP

Los uniformes existentes no se modifican. `config.lua` contiene la asignacion funcional por rango como referencia. Cuando se facilite la forma concreta de abrir o aplicar cada conjunto de `eup-ui`, se puede conectar cada entrada sin rehacer el sistema de rangos.


## Permisos de gestion
El rango 14 (Chief of Police / Jefe de Policia) puede usar `/gestionrangos` automaticamente. El permiso ACE `smvlpd.ranks.manage` se mantiene como acceso administrativo alternativo.


## Sistema de puntos - Fase 1
- Puntos persistentes por personaje en `smvlpd_police_points`.
- `/puntos` muestra total, rango actual, siguiente rango y puntos restantes.
- Ascensos automaticos acumulativos desde Novato hasta Capitan III.
- Los rangos 12-14 son administrativos y nunca cambian automaticamente por puntos.
- Export de servidor `AddPolicePoints(source, amount, reason)` preparado para conectar callouts y acciones en la siguiente fase.
- Baremo de avisos y acciones complementarias centralizado en `config.lua`.

## Puntuacion de avisos
- Cada aviso completado recibe los puntos de su dificultad: muy sencillo (50), sencillo (75), normal (100), complejo (150) o alto riesgo (200).
- Las acciones complementarias se puntúan una sola vez por aviso y sus importes se ajustan en `Config.PointRewards` dentro de `config.lua`.
- Al salir de servicio aparece un resumen con todos los puntos obtenidos durante ese turno.
- Los avisos completados correctamente de `night_ers` también conceden puntos; se clasifican por identificador en `Config.ERSCalloutDifficulties`.
