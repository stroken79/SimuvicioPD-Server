# smvlpd-fire

Recurso independiente de Bomberos. No modifica ni depende de configuraciones EMS.

## Activación

El recurso ya está activado en el `server.cfg` después de `night_ers` y `smvlpd-ranks`.

## Configuración

Todo se configura en `config.lua` y `uniforms.lua`: puntos, garajes, rangos, vehículos y uniformes. Las listas están vacías a propósito; no se han inventado coordenadas, modelos ni prendas.

## Integración ya existente

Night ERS ya soporta el tipo de servicio `fire` y filtra los avisos con `fireRequired = true`; este recurso sólo cambia el turno mediante su export existente y comprueba ese mismo estado.

## Rangos persistentes

`smvlpd-ranks` ya está ampliado para `fire`: usa ocho rangos, su progresión por puntos existente y una lista de vehículos vacía para impedir que un garaje genérico entregue vehículos policiales. El garaje de Bomberos usa únicamente `Config.VehiclesByRank` de este recurso.

No se ha modificado EMS ni Night ERS.
