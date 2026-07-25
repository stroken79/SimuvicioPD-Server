# Prueba de Police Simulator V

La carpeta `dist` es el recurso listo para instalar.

## Instalación

1. Copia `dist` a la carpeta `resources` del servidor y renómbrala a `polsim`.
2. Añade esta línea a `server.cfg`:

```cfg
ensure polsim
```

No se necesitan administradores, identificadores ni permisos ACE. Todos los
jugadores pueden utilizar los comandos. Si un jugador no aparece en
`users.json`, recibe automáticamente un perfil básico del primer departamento
configurado. `users.json` solo es necesario para personalizar rango, división,
placa y estadísticas.

## Prueba rápida

1. Inicia el servidor y confirma que aparecen los mensajes `POLSIM`, `DATA FILES`
   y `Automatic Dispatcher started` sin errores.
2. Entra al servidor y ejecuta `/forceduty`.
3. Ejecuta `/mdc`; el MDC debe abrirse y cerrarse sin dejar bloqueado el teclado.
4. Ejecuta `/randomcallout`. Debe funcionar para cualquier jugador.
5. Acércate al aviso generado. El servidor debe indicar que la misión fue
   activada una sola vez.
6. En el MDC, busca una identidad por nombre y actualiza la lista de arrestos.
   La respuesta debe mostrarse únicamente al jugador que hizo la consulta.
7. Espera al siguiente callout automático y confirma que se genera uno, no
   varias copias simultáneas.

## Configuración útil

- `server-settings.json`: intervalos, prioridad, agresividad y probabilidades.
- `client-settings.json`: tipos y probabilidades de eventos de tráfico.
- `users.json`: departamento, rango, división y placa de cada jugador.
- `departments.json`: agencias, uniformes, armas y taquillas.

Para una prueba rápida puede bajarse temporalmente `minimumIntervalTime` y
`maximumIntervalTime`; el servidor aplica un mínimo técnico de 10 segundos.
