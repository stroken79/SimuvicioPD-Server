CORRECCION DE HUMO ERS / SMARTFIRESLITE

Esta versión corrige la capa de integración de humo:
- Lee varias posibles estructuras de coordenadas devueltas por SmartFiresLite.
- Usa StopSmokeById sobre el humo que está dentro del radio del impacto.
- Mantiene la manguera, la H, el texto, el cañón y la extinción de fuego.
- El humo requiere exposición continua al agua durante Config.SmokeClearTime.
- Radio de humo configurable con Config.SmokeClearRange.

Si quieres depurar, pon Config.Debug = true y revisa F8/console del servidor.
