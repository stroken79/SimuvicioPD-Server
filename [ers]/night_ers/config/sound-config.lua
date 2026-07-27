Config = Config or {}

--====================== VOICE OVER & SOUND SETTINGS ======================--

local SoundFileLanguagePrefix = Config.SoundLanguage -- This setting is to be set in config.lua. Do not change here.

--====================== GAME INTUITION SOUNDS ======================--

-- Main recognition sound for player/NPC events (This one is native GTA and sounds quite good to recognize something is happening!)
Config.Sounds = {                                      
    AcceptCalloutSoundLibrary = "Crates_Blipped",
    AcceptCalloutSoundName = "GTAO_Magnate_Boss_Modes_Soundset",
}

--====================== GENERIC SOUNDS ======================--

-- Sounds & Effects
Config.VoiceOverEnabled = true          -- Enable or disable voice-over for your character events (NUI/sounds/[yourLanguage]/*.ogg).
Config.DispatchVoiceOverEnabled = true  -- Enable or disable voice-over for dispatch events (NUI/sounds/[yourLanguage]/*.ogg).
Config.RadioBleepSoundFile = {FileName = "radio_chirp", SoundVolume = 0.25}
Config.InteractionBtnClickSoundFiles = {
    ['interactionbutton'] = {
        Enabled = true,                 -- Enable / disable sound on button press & interaction (action type) click
        FileName = "confirm_click",     -- (NUI/sounds/generic-sounds/*.ogg)
        SoundVolume = 0.5,
    },
}

--===================== LANGUAGE BASED DISPATCH SOUNDS ======================--

-- Notice about custom sound files: NUI/sounds/en/*.ogg holds sounds for the english language. So NUI/sounds/us/*.ogg holds sounds for the american language.
-- If you desire to edit sound files, adjust the existing ones or add new ones, make sure to follow the format of sound file names and configure them as the examples below.

Config.CalloutOfferedSoundFiles = {    -- You will need to add custom soundfiles and transcribe them yourself if you desire to change these, this is not litterally a TTS system.
    [1] = {FileName = SoundFileLanguagePrefix .. "_callout_offered", SoundVolume = 0.3, TTS = '"Ha entrado una nueva llamada de emergencia, hay alguna unidad disponible para responder?"'}, 
    [2] = {FileName = SoundFileLanguagePrefix .. "_callout_offered_1", SoundVolume = 0.3, TTS = '"Tenemos alguna unidad disponible para responder a una emergencia?"'}, 
    [3] = {FileName = SoundFileLanguagePrefix .. "_callout_offered_2", SoundVolume = 0.3, TTS = '"Hemos recibido otra llamada de emergencia. Hay alguna unidad libre para atenderla?"'}, 
}

Config.CalloutExpiredSoundFiles = {    -- You will need to add custom soundfiles and transcribe them yourself if you desire to change these, this is not litterally a TTS system.
    [1] = {FileName = SoundFileLanguagePrefix .. "_callout_expired", SoundVolume = 0.3, TTS = '"Otras unidades pudieron resolver la ultima llamada de emergencia."'}, 
    [2] = {FileName = SoundFileLanguagePrefix .. "_callout_expired_1", SoundVolume = 0.3, TTS = '"Otros equipos de emergencia pudieron atender la llamada de emergencia anterior."'}, 
    [3] = {FileName = SoundFileLanguagePrefix .. "_callout_expired_2", SoundVolume = 0.3, TTS = '"La ultima situacion de emergencia ha sido resuelta por otras unidades."'}, 
}

Config.CalloutAcceptedSoundFiles = {    -- You will need to add custom soundfiles and transcribe them yourself if you desire to change these, this is not litterally a TTS system.
    [1] = {FileName = SoundFileLanguagePrefix .. "_callout_accepted", SoundVolume = 0.3, TTS = '"Te he asignado a la ultima llamada de emergencia. Dirigete al lugar."'}, 
    [2] = {FileName = SoundFileLanguagePrefix .. "_callout_accepted_1", SoundVolume = 0.3, TTS = '"Has sido asignado a la llamada de emergencia mas reciente. Dirigete al lugar."'}, 
    [3] = {FileName = SoundFileLanguagePrefix .. "_callout_accepted_2", SoundVolume = 0.3, TTS = '"Se te ha encargado responder a la ultima llamada de emergencia. Dirigete al lugar de los hechos."'}, 
}

Config.CalloutEndedSoundFiles = {    -- You will need to add custom soundfiles and transcribe them yourself if you desire to change these, this is not litterally a TTS system.
    [1] = {FileName = SoundFileLanguagePrefix .. "_callout_ended", SoundVolume = 0.3, TTS = '"Tu unidad ha sido retirada del ultimo aviso."'}, 
    [2] = {FileName = SoundFileLanguagePrefix .. "_callout_ended_1", SoundVolume = 0.3, TTS = '"Tu unidad ha sido desvinculada del aviso anterior."'}, 
    [3] = {FileName = SoundFileLanguagePrefix .. "_callout_ended_2", SoundVolume = 0.3, TTS = '"Tu unidad ha sido relevada de su servicio en el aviso anterior."'}, 
}

--====================== LANGUAGE BASED GEAR SOUNDS ======================--

Config.GearSoundFiles = {
    Enabled = true,
    Files = { -- Only adjust FileName, SoundVolume and/or TTS if you desire to. (NUI/sounds/*/*.ogg)
        Police = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_police_gear_1", SoundVolume = 0.5, TTS = '"Aqui tienes tu equipo. Que tengas un buen turno!"'},
        },
        Ambulance = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_ambulance_gear_1", SoundVolume = 0.5, TTS = '"Aqui tienes tu equipo. Que tengas un buen turno!"'},
        },
        Fire = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_fire_gear_1", SoundVolume = 0.5, TTS = '"Aqui tienes tu equipo. Que tengas un buen turno!"'},
        },
        Tow = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_tow_gear_1", SoundVolume = 0.5, TTS = '"Aqui tienes tu equipo. Que tengas un buen turno!"'},
        }
    }
}

--====================== LANGUAGE BASED IMPOUND SOUNDS ======================--

Config.ImpoundSoundFiles = {
    Enabled = true,
    Files = { -- Only adjust FileName, SoundVolume and/or TTS if you desire to. (NUI/sounds/*/*.ogg)
        [1] = {FileName = SoundFileLanguagePrefix .. "_impound_task_m", SoundVolume = 0.3, TTS = '"Para llevar tu vehiculo al deposito, conduce hasta la ubicacion que he marcado."'},
        [2] = {FileName = SoundFileLanguagePrefix .. "_impound_done_m", SoundVolume = 0.3, TTS = '"Por favor, sal del vehiculo y alejate."'},
        [3] = {FileName = SoundFileLanguagePrefix .. "_impound_class_m", SoundVolume = 0.3, TTS = '"Ese vehiculo no esta permitido aqui..."'},
    }
}

--====================== LANGUAGE BASED PED INTERACTION SOUNDS ======================--

Config.PedInteractionSoundFiles = { -- Only adjust FileName, SoundVolume and/or TTS if you desire to. (NUI/sounds/*/*.ogg)
    ['greet'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_hello", SoundVolume = 0.3, TTS = '"Hola, como esta hoy?"'}, 
            [2] = {FileName = SoundFileLanguagePrefix .. "_hello_1", SoundVolume = 0.3, TTS = '"Buenos dias. Hablemos un momento..."'}, 
            [3] = {FileName = SoundFileLanguagePrefix .. "_hello_2", SoundVolume = 0.3, TTS = '"Hola..."'}, 
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_hello_f", SoundVolume = 0.3, TTS = '"Hola, como esta hoy?"'}, 
            [2] = {FileName = SoundFileLanguagePrefix .. "_hello_1_f", SoundVolume = 0.3, TTS = '"Buenos dias. Hablemos un momento..."'}, 
            [3] = {FileName = SoundFileLanguagePrefix .. "_hello_2_f", SoundVolume = 0.3, TTS = '"Hola..."'}, 
        },
    },
    ['id'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_id", SoundVolume = 0.3, TTS = '"Puede darme su identificacion, por favor?"'}, 
            [2] = {FileName = SoundFileLanguagePrefix .. "_id_1", SoundVolume = 0.3, TTS = '"Por favor, muestreme su documento de identificacion."'}, 
            [3] = {FileName = SoundFileLanguagePrefix .. "_id_2", SoundVolume = 0.3, TTS = '"Entregue su documento de identificacion."'}, 
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_id_f", SoundVolume = 0.3, TTS = '"Puede darme su identificacion, por favor?"'}, 
            [2] = {FileName = SoundFileLanguagePrefix .. "_id_1_f", SoundVolume = 0.3, TTS = '"Por favor, muestreme su documento de identificacion."'},
            [3] = {FileName = SoundFileLanguagePrefix .. "_id_2_f", SoundVolume = 0.3, TTS = '"Entregue su documento de identificacion."'}, 
        },
    },
    ['breathalyze'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_breathalyze", SoundVolume = 0.3, TTS = '"Quiero tomar una muestra de aire espirado. Sople en el dispositivo, por favor."'},
            [2] = {FileName = SoundFileLanguagePrefix .. "_breathalyze_1", SoundVolume = 0.3, TTS = '"Por favor, sople en el dispositivo."'},
            [3] = {FileName = SoundFileLanguagePrefix .. "_breathalyze_2", SoundVolume = 0.3, TTS = '"Sople aqui, por favor."'},
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_breathalyze_f", SoundVolume = 0.3, TTS = '"Quiero tomar una muestra de aire espirado. Sople en el dispositivo, por favor."'},
            [2] = {FileName = SoundFileLanguagePrefix .. "_breathalyze_1_f", SoundVolume = 0.3, TTS = '"Por favor, sople en el dispositivo."'},
            [3] = {FileName = SoundFileLanguagePrefix .. "_breathalyze_2_f", SoundVolume = 0.3, TTS = '"Sople aqui, por favor."'},
        },
    },
    ['drugtest'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_drugtest", SoundVolume = 0.3, TTS = '"Por favor, abra la boca para realizar una prueba de drogas con hisopo bucal."'},
            -- [2] = {FileName = "en_drugtest_1", SoundVolume = 0.3, TTS = '"Abra la boca para realizar una prueba con hisopo, por favor."'},
            -- [3] = {FileName = "en_drugtest_2", SoundVolume = 0.3, TTS = '"Mantenga la boca abierta para la prueba con hisopo, por favor."'},
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_drugtest_f", SoundVolume = 0.3, TTS = '"Por favor, abra la boca para realizar una prueba de drogas con hisopo bucal."'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_drugtest_1_f", SoundVolume = 0.3, TTS = '"Abra la boca para realizar una prueba con hisopo, por favor."'},
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_drugtest_2_f", SoundVolume = 0.3, TTS = '"Mantenga la boca abierta para la prueba con hisopo, por favor."'},
        },
    },
    ['warn'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_warn", SoundVolume = 0.3, TTS = '"Considere esto una advertencia."'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_warn_1", SoundVolume = 0.3, TTS = '"Esta recibiendo una advertencia."'},
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_warn_2", SoundVolume = 0.3, TTS = '"Considere esto una advertencia."'},
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_warn_f", SoundVolume = 0.3, TTS = '"Considere esto una advertencia."'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_warn_1_f", SoundVolume = 0.3, TTS = '"Esta recibiendo una advertencia."'},
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_warn_2_f", SoundVolume = 0.3, TTS = '"Considere esto una advertencia."'},
        },
    },
    ['fine'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_fine", SoundVolume = 0.3, TTS = '"Esta siendo multado."'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_fine_1", SoundVolume = 0.3, TTS = '"Aqui tiene su multa."'},
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_fine_2", SoundVolume = 0.3, TTS = '"Esta es su multa."'},
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_fine_f", SoundVolume = 0.3, TTS = '"Esta siendo multado."'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_fine_1_f", SoundVolume = 0.3, TTS = '"Aqui tiene su multa."'},
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_fine_2_f", SoundVolume = 0.3, TTS = '"Esta es su multa."'},
        },
    },
    ['getout'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_getout", SoundVolume = 0.3, TTS = '"Por favor, salga del vehiculo."'},
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_getout_f", SoundVolume = 0.3, TTS = '"Por favor, salga del vehiculo."'},
        },
    },
    ['follow'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_follow", SoundVolume = 0.3, TTS = '"Podria seguirme, por favor?"'}, 
            [2] = {FileName = SoundFileLanguagePrefix .. "_follow_1", SoundVolume = 0.3, TTS = '"Por favor, sigame."'}, 
            [3] = {FileName = SoundFileLanguagePrefix .. "_follow_2", SoundVolume = 0.3, TTS = '"Sigame."'}, 
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_follow_f", SoundVolume = 0.3, TTS = '"Podria seguirme, por favor?"'}, 
            [2] = {FileName = SoundFileLanguagePrefix .. "_follow_1_f", SoundVolume = 0.3, TTS = '"Por favor, sigame."'}, 
            [3] = {FileName = SoundFileLanguagePrefix .. "_follow_2_f", SoundVolume = 0.3, TTS = '"Sigame."'}, 
        },
    },
    ['wait'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_wait", SoundVolume = 0.3, TTS = '"Espere aqui, por favor."'}, 
            [2] = {FileName = SoundFileLanguagePrefix .. "_wait_1", SoundVolume = 0.3, TTS = '"Podria esperar aqui, por favor?"'}, 
            [3] = {FileName = SoundFileLanguagePrefix .. "_wait_2", SoundVolume = 0.3, TTS = '"Espere aqui."'}, 
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_wait_f", SoundVolume = 0.3, TTS = '"Espere aqui, por favor."'}, 
            [2] = {FileName = SoundFileLanguagePrefix .. "_wait_1_f", SoundVolume = 0.3, TTS = '"Podria esperar aqui, por favor?"'}, 
            [3] = {FileName = SoundFileLanguagePrefix .. "_wait_2_f", SoundVolume = 0.3, TTS = '"Espere aqui."'}, 
        },
    },
    ['handsup'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_handsup", SoundVolume = 0.3, TTS = '"Levante las manos y quedese donde esta."'}, 
            [2] = {FileName = SoundFileLanguagePrefix .. "_handsup_1", SoundVolume = 0.3, TTS = '"Ponga las manos en alto!"'}, 
            [3] = {FileName = SoundFileLanguagePrefix .. "_handsup_2", SoundVolume = 0.3, TTS = '"Manos arriba."'}, 
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_handsup_f", SoundVolume = 0.3, TTS = '"Levante las manos y quedese donde esta."'}, 
            [2] = {FileName = SoundFileLanguagePrefix .. "_handsup_1_f", SoundVolume = 0.3, TTS = '"Ponga las manos en alto!"'}, 
            [3] = {FileName = SoundFileLanguagePrefix .. "_handsup_2_f", SoundVolume = 0.3, TTS = '"Manos arriba."'}, 
        },
    },
    ['search'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_search", SoundVolume = 0.3, TTS = '"Voy a registrarle. Hay algun objeto que pueda causar dano o que este prohibido y que quiera declarar antes de que continue?"'}, 
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_search_1", SoundVolume = 0.3, TTS = '"Crea tu archivo de audio y escribe aqui el subtitulo."'}, 
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_search_1", SoundVolume = 0.3, TTS = '"Crea tu archivo de audio y escribe aqui el subtitulo."'}, 
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_search_f", SoundVolume = 0.3, TTS = '"Voy a registrarle. Hay algun objeto que pueda causar dano o que este prohibido y que quiera declarar antes de que continue?"'}, 
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_search_1", SoundVolume = 0.3, TTS = '"Crea tu archivo de audio y escribe aqui el subtitulo."'}, 
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_search_1", SoundVolume = 0.3, TTS = '"Crea tu archivo de audio y escribe aqui el subtitulo."'}, 
        },
    },
    ['cuff'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_arrest_rights", SoundVolume = 0.3, TTS = '"**Leyendo los derechos**"'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_cuff_1", SoundVolume = 0.3, TTS = '"Crea tu archivo de audio y escribe aqui el subtitulo."'}, 
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_cuff_2", SoundVolume = 0.3, TTS = '"Crea tu archivo de audio y escribe aqui el subtitulo."'}, 
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_arrest_rights_f", SoundVolume = 0.3, TTS = '"**Leyendo los derechos**"'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_cuff_1", SoundVolume = 0.3, TTS = '"Crea tu archivo de audio y escribe aqui el subtitulo."'}, 
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_cuff_2", SoundVolume = 0.3, TTS = '"Crea tu archivo de audio y escribe aqui el subtitulo."'}, 
        },
    },
    ['putinvehicle'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_putinvehicle", SoundVolume = 0.3, TTS = '"Suba a la parte trasera del vehiculo."'}, 
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_putinvehicle_1", SoundVolume = 0.3, TTS = '"Crea tu archivo de audio y escribe aqui el subtitulo."'}, 
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_putinvehicle_2", SoundVolume = 0.3, TTS = '"Crea tu archivo de audio y escribe aqui el subtitulo."'}, 
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_putinvehicle_f", SoundVolume = 0.3, TTS = '"Suba a la parte trasera del vehiculo."'}, 
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_putinvehicle_f_1", SoundVolume = 0.3, TTS = '"Crea tu archivo de audio y escribe aqui el subtitulo."'}, 
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_putinvehicle_f_2", SoundVolume = 0.3, TTS = '"Crea tu archivo de audio y escribe aqui el subtitulo."'}, 
        },
    },
    ['end'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_end", SoundVolume = 0.3, TTS = '"Ya puede marcharse."'}, 
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_end_1", SoundVolume = 0.3, TTS = '"Crea tu archivo de audio y escribe aqui el subtitulo."'}, 
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_end_2", SoundVolume = 0.3, TTS = '"Crea tu archivo de audio y escribe aqui el subtitulo."'}, 
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_end_f", SoundVolume = 0.3, TTS = '"Ya puede marcharse."'}, 
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_end_1_f", SoundVolume = 0.3, TTS = '"Crea tu archivo de audio y escribe aqui el subtitulo."'}, 
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_end_2_f", SoundVolume = 0.3, TTS = '"Crea tu archivo de audio y escribe aqui el subtitulo."'}, 
        },
    },
}

--====================== LANGUAGE BASED BACKUP SPEECH SOUNDS ======================--

Config.NPCBackupRequestSoundFiles = {
    ['police'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_backup_police", SoundVolume = 0.3, TTS = '"Necesito transporte para un detenido. Envien una unidad."'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_backup_police_1", SoundVolume = 0.3, TTS = '"Necesito transporte para un detenido. Envien una unidad."'},
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_backup_police_2", SoundVolume = 0.3, TTS = '"Necesito transporte para un detenido. Envien una unidad."'},
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_backup_police_f", SoundVolume = 0.3, TTS = '"Necesito transporte para un detenido. Envien una unidad."'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_backup_police_1_f", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_backup_police_2_f", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
        },
    },
    ['ambulance'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_backup_ambulance", SoundVolume = 0.3, TTS = '"Necesito una ambulancia en mi ubicacion. Envien una unidad lo antes posible."'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_backup_ambulance_1", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_backup_ambulance_2", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_backup_ambulance_f", SoundVolume = 0.3, TTS = '"Necesito una ambulancia en mi ubicacion. Envien una unidad lo antes posible."'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_backup_ambulance_1_f", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_backup_ambulance_2_f", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
        },
    },
    ['taxi'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_backup_taxi", SoundVolume = 0.3, TTS = '"Podrian enviar un taxi a mi ubicacion?"'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_backup_taxi_1", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_backup_taxi_2", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_backup_taxi_f", SoundVolume = 0.3, TTS = '"Podrian enviar un taxi a mi ubicacion?"'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_backup_taxi_1_f", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_backup_taxi_2_f", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
        },
    },
    ['tow'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_backup_tow", SoundVolume = 0.3, TTS = '"Necesito transportar un vehiculo. Envien una grua."'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_backup_tow_1", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_backup_tow_2", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_backup_tow_f", SoundVolume = 0.3, TTS = '"Necesito transportar un vehiculo. Envien una grua."'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_backup_tow_1_f", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_backup_tow_2_f", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
        },
    },
    ['animalrescue'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_backup_animalrescue", SoundVolume = 0.3, TTS = '"Necesito servicios de rescate de animales en mi ubicacion. Envien una unidad."'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_backup_animalrescue_1", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_backup_animalrescue_2", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_backup_animalrescue_f", SoundVolume = 0.3, TTS = '"Necesito servicios de rescate de animales en mi ubicacion. Envien una unidad."'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_backup_animalrescue_1_f", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_backup_animalrescue_2_f", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
        },
    },
    ['roadservice'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_backup_roadservice", SoundVolume = 0.3, TTS = '"Necesito servicios de limpieza vial en mi ubicacion. Envien una unidad."'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_backup_roadservice_1", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_backup_roadservice_2", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_backup_roadservice_f", SoundVolume = 0.3, TTS = '"Necesito servicios de limpieza vial en mi ubicacion. Envien una unidad."'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_backup_roadservice_1_f", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_backup_roadservice_2_f", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
        },
    },
    ['coroner'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_backup_coroner", SoundVolume = 0.3, TTS = '"Necesito un forense en mi ubicacion. Envien una unidad."'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_backup_coroner_1", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_backup_coroner_2", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_backup_coroner_f", SoundVolume = 0.3, TTS = '"Necesito un forense en mi ubicacion. Envien una unidad."'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_backup_coroner_1_f", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_backup_coroner_2_f", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
        },
    },
    ['mechanic'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_backup_mechanic", SoundVolume = 0.3, TTS = '"Necesito un mecanico en mi ubicacion. Envien uno lo antes posible."'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_backup_mechanic_1", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_backup_mechanic_2", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_backup_mechanic_f", SoundVolume = 0.3, TTS = '"Necesito un mecanico en mi ubicacion. Envien uno lo antes posible."'},
            -- [2] = {FileName = SoundFileLanguagePrefix .. "_backup_mechanic_1_f", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
            -- [3] = {FileName = SoundFileLanguagePrefix .. "_backup_mechanic_2_f", SoundVolume = 0.3, TTS = '"Necesito refuerzos, mantenganse a la espera."'},
        },
    },
    ['fire'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_backup_fire", SoundVolume = 0.3, TTS = '"Necesito bomberos en mi ubicacion. Envien una unidad de bomberos lo antes posible."'},
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_backup_fire_f", SoundVolume = 0.3, TTS = '"Necesito bomberos en mi ubicacion. Envien una unidad de bomberos lo antes posible."'},
        },
    },
}

--====================== LANGUAGE BASED PURSUIT BACKUP SPEECH SOUNDS ======================--

Config.PursuitBackupSoundFiles = {
    ['light'] = {   
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_pursuit_backup_light", SoundVolume = 0.3, TTS = '"Necesito refuerzos en mi ubicacion. Envien una unidad motorizada."'},
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_pursuit_backup_light_f", SoundVolume = 0.3, TTS = '"Necesito refuerzos en mi ubicacion. Envien una unidad motorizada."'},
        },
    },
    ['medium'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_pursuit_backup_medium", SoundVolume = 0.3, TTS = '"Necesito asistencia en mi ubicacion. Envien una unidad de patrulla."'},
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_pursuit_backup_medium_f", SoundVolume = 0.3, TTS = '"Necesito asistencia en mi ubicacion. Envien una unidad de patrulla."'},
        },
    },
    ['heavy'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_pursuit_backup_heavy", SoundVolume = 0.3, TTS = '"Necesito asistencia inmediata en mi ubicacion. Envien una unidad armada!"'},
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_pursuit_backup_heavy_f", SoundVolume = 0.3, TTS = '"Necesito asistencia inmediata en mi ubicacion. Envien una unidad armada!"'},
        },
    },
    ['air'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_pursuit_backup_air", SoundVolume = 0.3, TTS = '"Necesito apoyo aereo en mi ubicacion. Envien una unidad de helicoptero."'},
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_pursuit_backup_air_f", SoundVolume = 0.3, TTS = '"Necesito apoyo aereo en mi ubicacion. Envien una unidad de helicoptero."'},
        },
    },
    ['army'] = {
        Male = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_pursuit_backup_army", SoundVolume = 0.3, TTS = '"Necesito al ejercito en mi posicion. Envienlos rapidamente!"'},
        },
        Female = {
            [1] = {FileName = SoundFileLanguagePrefix .. "_pursuit_backup_army_f", SoundVolume = 0.3, TTS = '"Necesito al ejercito en mi posicion. Envienlos rapidamente!"'},
        },
    },
}
