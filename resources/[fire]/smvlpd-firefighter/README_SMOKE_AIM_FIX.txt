CORRECCION: AGUA CONTRA HUMO ERS

El humo no tiene colision fisica, por lo que el raycast normal de GTA no
devuelve la posicion del humo. Esta version envia el origen y direccion de
la camara al servidor y busca los humos de SmartFiresLite que estan dentro
del chorro de agua.

No cambia SmartHoseLite ni night_ers.
Mantiene H y el resto de la integracion existente.

Prueba:
1. restart smvlpd-firefighter
2. entrar en un aviso de SMOKE IN A TUNNEL
3. sacar manguera con H
4. apuntar al humo y mantener el disparo 2-3 segundos
