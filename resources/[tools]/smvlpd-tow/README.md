# smvlpd-tow

Sistema de prueba de grúa para LSDOT.

## Vehículos soportados
- f450towtruk
- hvywrecker
- towtruck
- towtruck2

## Controles
- F6: abrir menú de grúa
- H: desenganchar

## T440
El T440 se prepara al entrar por primera vez en el vehículo intentando usar su kit/modkit base (`0`), sin tocar extras. Esto busca respetar la configuración `0_default_no_lower` definida en su `hvywrecker_carvar.meta`. Si el brazo trasero sigue apareciendo, será necesario revisar el `carcols.meta`/kit del recurso original; no se fuerza ningún extra del T440.

## F-450
No se modifican ni se gestionan extras de la F-450. El sistema solo utiliza su función de enganche.

## Instalación
Añadir:
ensure smvlpd-tow

Esta versión sigue siendo independiente de night_ers y smvlpd-ranks mientras probamos el comportamiento físico.
