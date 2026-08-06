-- ─────────────────────────────────────────────
--  RD-Taxi  –  English locale  (en.lua)
--  Duplicate this file and translate to add
--  a new language.  Then set Config.Locale
--  in config.lua to the new filename (no .lua).
-- ─────────────────────────────────────────────

Locale = {
    -- Help text shown at taxi stops
    HELP_PRESS_TO_OPEN   = "Pulsa ~INPUT_CONTEXT~ para ver los taxis disponibles",
HELP_ON_COOLDOWN     = "~r~Debes esperar. Tiempo restante: %ss",

-- Solicitud / reserva
TAXI_RESERVED        = "Taxi reservado! Espera en la parada hasta que llegue.",
TAXI_EN_ROUTE        = "Tu taxi esta de camino!",

-- Avisos de llegada
TAXI_READY_NEARBY    = "Tu taxi esta listo! Acercate a la puerta trasera y pulsa ~g~G~w~ para entrar.",
TAXI_ARRIVED         = "Tu taxi ha llegado! Acercate a la puerta trasera y pulsa ~g~G~w~ para entrar.",

-- Dentro del taxi
WELCOME_SET_WAYPOINT = "Bienvenido! Abre el mapa (ESC o M) y marca un punto de destino.",
DESTINATION_CONFIRMED = "Destino confirmado. Disfruta del viaje!",
DESTINATION_CANCELLED = "Destino cancelado. Marca un nuevo destino cuando estes listo.",
DOORS_LOCKED_FOR_RIDE = "Las puertas estan cerradas por tu seguridad. Relajate y disfruta del viaje!",

-- Llegada al destino
ARRIVED_EXIT_VEHICLE = "Has llegado! Sal del vehiculo cuando estes listo.",
EXIT_REMINDER        = "~g~Has llegado a tu destino. Sal del vehiculo.",
EXIT_URGENT          = "~r~Sal del taxi, por favor! Tiempo restante: %ss",

-- Tiempos agotados / expulsiones
WAYPOINT_TIMEOUT     = "Has tardado demasiado en seleccionar un destino!",
EXIT_TIMEOUT         = "Has tardado demasiado en salir!",
KICKED_COOLDOWN      = "Has sido expulsado del taxi. Tiempo de espera: 10 minutos.",

-- Pago
PAYMENT_SUCCESS      = "Has pagado $%s por el viaje.",
PAYMENT_FAIL         = "Fondos insuficientes! Necesitas $%s.",
PAYMENT_FAIL_KICKED  = "Fondos insuficientes! Has sido expulsado del taxi.",

-- Tiempo limite del taxi reservado
DEMAND_TIMEOUT       = "El taxi reservado se marcho antes de que pudieras entrar.",
}

-- Helper – printf-style string formatting using Locale keys
function L(key, ...)
    local str = Locale[key]
    if not str then return "[MISSING: " .. tostring(key) .. "]" end
    if select('#', ...) > 0 then
        return string.format(str, ...)
    end
    return str
end
