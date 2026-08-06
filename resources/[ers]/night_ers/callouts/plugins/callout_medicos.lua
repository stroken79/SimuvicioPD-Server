local MedicalCalloutLocations = {
    [1] = vector3(307.88, -1433.64, 29.80),
    [2] = vector3(339.31, -1394.68, 32.51),
    [3] = vector3(1157.58, -1524.05, 34.84),
    [4] = vector3(1839.81, 3672.93, 34.28),
    [5] = vector3(-247.76, 6331.23, 32.43),
    [6] = vector3(-676.36, 312.12, 83.08),
    [7] = vector3(289.87, -584.91, 43.19),
    [8] = vector3(-1191.64, -1518.89, 4.37),
    [9] = vector3(-1037.21, -2737.87, 20.17),
    [10] = vector3(427.49, -981.35, 30.71),
    [11] = vector3(25.17, -1347.62, 29.50),
    [12] = vector3(372.66, 326.54, 103.57),
    [13] = vector3(-47.72, -1757.23, 29.42),
    [14] = vector3(1135.74, -982.10, 46.42),
    [15] = vector3(-1223.91, -906.82, 12.33),
    [16] = vector3(-1488.24, -380.76, 40.16),
    [17] = vector3(1961.35, 3740.84, 32.34),
    [18] = vector3(1698.62, 4924.14, 42.06),
    [19] = vector3(-3242.19, 1001.55, 12.83),
    [20] = vector3(-3040.92, 586.07, 7.91),
    [21] = vector3(2557.41, 382.04, 108.62),
    [22] = vector3(1164.91, -323.67, 69.21),
    [23] = vector3(-709.74, -914.64, 19.22),
    [24] = vector3(75.58, -1392.02, 29.38),
    [25] = vector3(-821.32, -1073.57, 11.33),
    [26] = vector3(124.21, -1034.68, 29.28),
    [27] = vector3(-551.42, -205.74, 38.22),
    [28] = vector3(446.16, -1242.33, 30.29),
    [29] = vector3(-1613.22, -1015.17, 13.02),
    [30] = vector3(185.58, -949.40, 30.09),
}

local MedicalUnitsRequired = {
    description = "Medico",
    policeRequired = false,
    ambulanceRequired = true,
    fireRequired = false,
    towRequired = false,
}

local function ApplyMedicalPatientState(ped, state)
    ERS_RequestNetControlForEntity(ped)
    TaskSetBlockingOfNonTemporaryEvents(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    if state.blood then
        ERS_ApplyBloodToPed(ped)
    end

    if state.dead then
        SetEntityHealth(ped, 0)
        return
    end

    local patientHealth = state.health or 115
    if state.blood then
        patientHealth = math.min(patientHealth, 105)
    else
        patientHealth = math.min(patientHealth, 120)
    end

    SetEntityHealth(ped, patientHealth)

    if state.blood then
        ClearPedTasksImmediately(ped)
        SetPedCanRagdoll(ped, true)
        SetPedToRagdoll(ped, 60000, 60000, 0, false, false, false)

        CreateThread(function()
            local timeout = GetGameTimer() + 15000
            while DoesEntityExist(ped) and GetGameTimer() < timeout do
                if not IsPedRagdoll(ped) and not IsPedDeadOrDying(ped, true) then
                    SetPedToRagdoll(ped, 5000, 5000, 0, false, false, false)
                end
                Wait(1500)
            end
        end)

        return
    end

    if state.scenario == "slumped" then
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_BUM_SLUMPED", 0, true)
    elseif state.scenario == "panic" then
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_MOBILE", 0, true)
    else
        local scenario = ERS_SelectRandomWoundedPersonScenario()
        TaskStartScenarioInPlace(ped, scenario, 0, true)
    end
end

local function RegisterMedicalCallout(id, data)
    Config.Callouts[id] = {
        Enabled = true,
        Priority = data.priority or 1,
        CalloutName = data.name,
        CalloutDescriptions = data.descriptions,
        CalloutUnitsRequired = MedicalUnitsRequired,
        CalloutLocations = MedicalCalloutLocations,
        PedChanceToFleeFromPlayer = 0,
        PedChanceToAttackPlayer = 0,
        PedChanceToSurrender = 0,
        PedChanceToObtainWeapons = 0,
        PedActionMinimumTimeoutInMs = 0,
        PedActionMaximumTimeoutInMs = 1000,
        PedActionOnNoActionFound = "none",
        PedWeaponData = {
            "weapon_unarmed",
        },

        client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)
            for index, pedNetId in pairs(pedList) do
                local ped = NetToPed(pedNetId)
                if DoesEntityExist(ped) then
                    if index == 1 then
                        ApplyMedicalPatientState(ped, data.patient)
                    else
                        ERS_RequestNetControlForEntity(ped)
                        TaskSetBlockingOfNonTemporaryEvents(ped, true)
                        SetEntityHealth(ped, 120)
                        local scenario = ERS_SelectRandomBystanderScenario()
                        TaskStartScenarioInPlace(ped, scenario, 0, true)
                    end
                end
            end

            ERS_CreateTemporaryBlipForEntities(pedList, 15000)
            ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
        end,

        server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)
            local pedModel = ERS_GetRandomModel(Config.randomPeds)
            local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z + 1.0)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            table.insert(pedList, pedNetId)

            if data.bystanders and data.bystanders > 0 then
                for i = 1, data.bystanders do
                    local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, 6)
                    local bystanderModel = ERS_GetRandomModel(Config.randomPeds)
                    local bystanderCoords = vector3(coords.x, coords.y, coords.z + 1.0)
                    local bystanderHeading = math.random(360)
                    local bystanderNetId = ERS_CreatePed(bystanderModel, bystanderCoords, bystanderHeading)
                    table.insert(pedList, bystanderNetId)
                end
            end

            return true
        end
    }
end

RegisterMedicalCallout("med_persona_mareada", {
    name = "Persona mareada",
    patient = { health = 135, scenario = "slumped" },
    bystanders = 1,
    descriptions = {
        "Un ciudadano informa de una persona muy mareada en la via publica. Parece desorientada y necesita valoracion sanitaria.",
        "Aviso medico: una persona se ha sentado en el suelo tras sufrir un fuerte mareo. Se solicita ambulancia.",
        "Llamada recibida por posible bajada de tension. El paciente esta consciente pero debil y con dificultad para mantenerse en pie.",
        "Testigos indican que una persona camina tambaleandose y dice que todo le da vueltas. Requiere asistencia medica.",
        "Se solicita unidad sanitaria por paciente con nauseas, sudor frio y mareo persistente.",
    },
})

RegisterMedicalCallout("med_persona_inconsciente", {
    name = "Persona inconsciente",
    priority = 2,
    patient = { health = 105, scenario = "slumped" },
    bystanders = 2,
    descriptions = {
        "Emergencia medica: persona inconsciente en el suelo. Los testigos no consiguen que responda.",
        "Se recibe aviso de un ciudadano que ha encontrado a una persona desplomada y sin respuesta verbal.",
        "Una persona ha perdido el conocimiento de forma repentina. Se desconoce la causa, enviar ambulancia urgente.",
        "Aviso prioritario: paciente inconsciente en zona transitada. Varias personas estan intentando ayudar.",
        "Llamada de emergencia por posible sincope grave. Paciente no responde a estimulos.",
    },
})

RegisterMedicalCallout("med_persona_sangrando", {
    name = "Persona sangrando",
    priority = 2,
    patient = { health = 95, blood = true },
    bystanders = 1,
    descriptions = {
        "Aviso sanitario: persona con sangrado abundante. Se desconoce el origen de la herida.",
        "Un vecino informa de un paciente sangrando en la calle y pidiendo ayuda.",
        "Emergencia: persona con herida abierta y perdida visible de sangre. Se requiere asistencia inmediata.",
        "Llamada por paciente herido que deja rastro de sangre en la acera. Posible corte profundo.",
        "Se solicita ambulancia para controlar una hemorragia antes de que empeore el estado del paciente.",
    },
})

RegisterMedicalCallout("med_herida_por_arma", {
    name = "Herida por arma",
    priority = 3,
    patient = { health = 80, blood = true },
    bystanders = 2,
    descriptions = {
        "Aviso critico: persona herida por arma. El paciente sangra y necesita asistencia sanitaria urgente.",
        "Llamada de emergencia por posible herida de arma blanca. El paciente esta consciente pero muy debil.",
        "Testigos informan de una persona con una lesion compatible con disparo o punalada. Se requiere ambulancia.",
        "Paciente con traumatismo penetrante y sangrado activo. Prioridad alta para unidades medicas.",
        "Una persona pide ayuda tras ser herida con un arma. La escena puede ser inestable, valorar con precaucion.",
    },
})

RegisterMedicalCallout("med_infarto", {
    name = "Posible infarto",
    priority = 3,
    patient = { health = 90, scenario = "slumped" },
    bystanders = 2,
    descriptions = {
        "Emergencia medica: persona con dolor fuerte en el pecho y dificultad para respirar. Posible infarto.",
        "Un familiar informa de un paciente con presion en el pecho, sudor frio y mareo. Enviar ambulancia urgente.",
        "Aviso prioritario por sintomas cardiacos. El paciente esta palido y se queja de dolor en brazo izquierdo.",
        "Llamada por posible parada cardiaca incipiente. El paciente se encuentra muy debil y confuso.",
        "Se solicita unidad medicalizada por dolor toracico intenso en via publica.",
    },
})

RegisterMedicalCallout("med_sobredosis", {
    name = "Posible sobredosis",
    priority = 2,
    patient = { health = 85, scenario = "slumped" },
    bystanders = 1,
    descriptions = {
        "Aviso medico: posible sobredosis. El paciente respira lentamente y no responde con normalidad.",
        "Un testigo encuentra a una persona semiinconsciente junto a objetos sospechosos. Se solicita ambulancia.",
        "Llamada por intoxicacion grave. Paciente confuso, somnoliento y con pulso debil.",
        "Emergencia sanitaria por posible consumo excesivo de sustancias. Necesita evaluacion inmediata.",
        "Se requiere asistencia medica por persona desvanecida tras ingerir una sustancia desconocida.",
    },
})

RegisterMedicalCallout("med_dificultad_respiratoria", {
    name = "Dificultad respiratoria",
    priority = 2,
    patient = { health = 100, scenario = "slumped" },
    bystanders = 1,
    descriptions = {
        "Aviso sanitario: persona con dificultad para respirar. Indica que le falta el aire.",
        "Emergencia: paciente con crisis respiratoria en curso. Se solicita ambulancia rapidamente.",
        "Un ciudadano informa de una persona con respiracion agitada y labios palidos.",
        "Llamada por posible ataque de asma o reaccion alergica. El paciente necesita asistencia inmediata.",
        "Persona sentada en el suelo, respirando con mucho esfuerzo. Requiere valoracion medica urgente.",
    },
})

RegisterMedicalCallout("med_parto_urgente", {
    name = "Parto urgente",
    priority = 2,
    patient = { health = 125, scenario = "slumped" },
    bystanders = 2,
    descriptions = {
        "Aviso medico: mujer embarazada con contracciones muy seguidas. Posible parto inminente.",
        "Llamada urgente por parto en la via publica. La paciente no puede desplazarse al hospital.",
        "Una persona informa de una embarazada con fuerte dolor abdominal y perdida de liquido.",
        "Se solicita ambulancia para parto avanzado. Familiares estan nerviosos y piden ayuda inmediata.",
        "Paciente embarazada requiere asistencia sanitaria urgente antes del traslado.",
    },
})

RegisterMedicalCallout("med_crisis_ansiedad", {
    name = "Crisis de ansiedad",
    patient = { health = 145, scenario = "panic" },
    bystanders = 1,
    descriptions = {
        "Aviso medico: persona con crisis de ansiedad, hiperventilacion y dolor en el pecho.",
        "Un ciudadano informa de una persona muy alterada que no consigue calmarse y pide ayuda sanitaria.",
        "Paciente con ataque de panico en zona publica. Necesita valoracion y apoyo del equipo medico.",
        "Llamada por persona temblando, llorando y respirando muy rapido. Se solicita ambulancia.",
        "Se requiere asistencia sanitaria para paciente desorientado por posible crisis nerviosa.",
    },
})

RegisterMedicalCallout("med_caida_domestica", {
    name = "Caida domestica",
    patient = { health = 115, blood = true },
    bystanders = 1,
    descriptions = {
        "Aviso medico: persona herida tras una caida en una vivienda o local. Posible fractura.",
        "Un familiar informa de una caida con golpe en la cabeza. El paciente esta consciente pero sangra.",
        "Llamada por lesion tras caida accidental. La persona no puede levantarse sin ayuda.",
        "Se solicita ambulancia por posible fractura de cadera o pierna tras resbalon.",
        "Paciente en el suelo tras una caida fuerte. Refiere dolor intenso y mareo.",
    },
})
