# smvlpd-admin-clothing v2.0

Uniforme independiente de Administración de SIMUVICIOPD.

## Acceso
Exclusivamente mediante autenticación de administrador de txAdmin:
`txAdmin:events:adminAuth`

No utiliza smvlpd-ranks, trabajos, rangos policiales, group.admin, pd5m
ni smlvpd-clothing.

## Comando
`/adminuniform`

Es un toggle:
- Primera ejecución: guarda TODO el outfit actual y equipa el uniforme de Administración.
- Segunda ejecución: restaura TODO el outfit anterior.

## Conjunto configurado

- Pantalón: componente 4, drawable 36, texture 0
- Bolsas: componente 5, drawable 82, texture 0
- Zapatos: componente 6, drawable 111, texture 0
- Accesorios: componente 7, drawable 200, texture 0
- Camiseta/interior: componente 8, drawable 235, texture 0
- Chaleco/Armor: componente 9, drawable 0, texture 0
- Decals/Insignias: componente 10, drawable 0, texture 0
- Sudadera AdminPack: componente 11, colección mp_m_gunrunning_01, drawable 13, texture 0
- Gorra/casco: prop 0, drawable 245, texture 0
- Todos los demás props se limpian.

## Instalación

Sustituir la carpeta `smvlpd-admin-clothing` por esta versión y mantener:

ensure smvlpd-admin-clothing
