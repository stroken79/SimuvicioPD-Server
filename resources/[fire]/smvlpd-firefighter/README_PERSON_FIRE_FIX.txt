CORRECCION: PERSONAS/ENTIDADES EN LLAMAS

- Evita NetworkGetNetworkIdFromEntity en entidades no networkadas.
- Detecta fuego nativo de GTA/ERS sobre peds, vehiculos y animales.
- La manguera puede extinguir una entidad no networkada localmente tras la
  exposicion configurada.
- Las entidades networkadas siguen usando la sincronizacion servidor.
- No modifica SmartHoseLite ni SmartFiresLite.

Probar:
1. Generar/recibir un aviso de persona en llamas.
2. Sacar manguera con H.
3. Mantener agua sobre la persona durante Config.ExtinguishTime.
4. Comprobar que las llamas desaparecen.
