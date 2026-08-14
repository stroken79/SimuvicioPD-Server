# smvlpd-firefighter

Capa aislada para `night_ers`, `SmartFiresLite`, `SmartHoseLite` y `ox_target`.

## Lo que utiliza

- La manguera se equipa y guarda con `H` (o mediante las opciones de `ox_target`) sobre `firetruk`, `spartan`, `ferrara`, `pumper` y `gmc`. H solo se procesa para Bomberos en servicio junto a uno de esos vehiculos.
- No crea otra manguera: ejecuta el comando configurado de SmartHoseLite. SmartFiresLite ya está configurado con `usingHoseLS = true` y `weapon_hose`.
- Para cada impacto de agua, consulta `GetAllFires`/`GetAllSmokes`; apaga fuego tras `Config.ExtinguishTime` y despeja humo tras `Config.SmokeClearTime`, usando `StopFireById`/`StopSmokeById` contra la entidad real de SmartFiresLite.
- ERS conserva los IDs de SmartFires en `fireList` y `smokeList`; su comprobación de estado existente actualiza las tareas cuando esos IDs dejan de estar activos.

## Inicio

`server.cfg` inicia este recurso después de `SmartFiresLite` y `SmartHoseLite`. ERS ofrece los avisos durante 45 segundos mediante `Config.OfferedCalloutTimeout`.

## Prueba en servidor obligatoria

No se ha ejecutado FiveM desde esta copia de trabajo. Reinicia el recurso y prueba: sacar/guardar/volver a sacar la manguera, agua visible, incendio y humo de ERS, cañón de cada camión, dos bomberos, cancelar aviso, salida de servicio, muerte y desconexión. Activa `Config.Debug = true` para la traza de impactos y extinciones.
