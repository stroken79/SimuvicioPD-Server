CAMBIO: UNIDADES DE APOYO ERS

- El fuego normal sigue pudiendo extinguirse con manguera/cañon.
- Persona en llamas: se muestra aviso para solicitar unidad de apoyo ERS.
- Humo de SmartFires/ERS: se muestra aviso para solicitar unidad de apoyo ERS.
- No se fuerza StopSmokeById para estos casos, porque ERS ya dispone de la
  mecanica de unidades de apoyo que se ha comprobado que funciona.
- El aviso tiene cooldown configurable para evitar spam.

Prueba:
1. restart smvlpd-firefighter
2. provocar persona en llamas o aviso de humo
3. apuntar con la manguera
4. debe aparecer el aviso de solicitar unidad de apoyo desde el menu ERS
