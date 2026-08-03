Config = Config or {}

--======================= IMPORT NOTE ABOUT ADDING CUSTOM QUESTIONS =======================--

-- [[ WE DO NOT OFFER TICKET SUPPORT FOR ADDING CUSTOM QUESTIONS/ANSWERS. ]]

-- [[ INSTRUCTIONS ]]
-- To add custom question(s), you need to add a new table entry in the Config.Questioning table.
-- To add answer(s) to these questions, you need to add a new table entry in the Config.DynamicAnswers table.
-- You need to consider the ID ("name" for example) and make sure to define them in both tables.
-- Follow the code structure as displayed in the Config tables below. 
-- For questions, as well as answers, you can add as many options as you like: These are the variations of the question/answer.

-- [[ SOUND FILES ]]
-- Sound files for the questions and answers should be placed in the ./NUI/sounds/en/ folder. [NOTE: en is replaced by the system for other languages via Config.SoundLanguage]
-- Female sound files have "_f" added to the end of the file name. The system automatically detects if the NPC/player is male or female and plays the correct sound file.

--======================= QUESTIONING SETTINGS =======================--

Config.EnableSoundBasedQuestions = true -- Setting this to false will not trigger the sound based questions, just text.
Config.EnableSoundBasedAnswers = true   -- Setting this to false will not trigger the sound based answers, just text.
Config.Enable3DTextDrawingOnAnswers = false -- Setting this to false will not draw 3D text on the answers above the NPC's head.

Config.EnableCinematic = true -- Setting this to false will not trigger the cinematic black bars on the top and bottom of the screen.
Config.CinematicRectangleHeight = 0.25 -- Defines how big the cinematic black bars are.

Config.ExitQuestioning = {
    text = "Creo que ya se suficiente...",
    soundFile = "q_exit",
    soundVolume = 0.5
}

Config.Questioning = {
    {
        id = "name", -- Don't change the id, it's linked to Config.DynamicAnswers.
        orderIndex = 1, -- You can set the order of the questions. A lower number is available earlier in the questioning. You can give multiple questions the same orderIndex to have them available around the same time.
        serviceTypes = { "police", "ambulance", "fire", "tow" },  -- Which services can ask this question? [OPTIONS: "police", "ambulance", "fire", "tow"]
        question = {
            options = {
                {
                    text = "Puede decirme su nombre?",
                    soundFile = "q_name_1", -- Find the sound file in path: ./NUI/sounds/en/q_name_1.ogg for example.
                    soundVolume = 0.5,      -- 0.5 is the default volume, you can change this to a custom volume if you want.
                },
                {
                    text = "Como puedo llamarle?",
                    soundFile = "q_name_2",
                    soundVolume = 0.5,
                },
                {
                    text = "Cual es su nombre?",
                    soundFile = "q_name_3",
                    soundVolume = 0.5,
                },
                -- Add another option here if you like, use the code structure as displayed above.
            }
        }
    },
    {
        id = "weather",
        orderIndex = 1,
        serviceTypes = { "police", "ambulance", "fire", "tow" },  -- Which services can ask this question? [OPTIONS: "police", "ambulance", "fire", "tow"]
        question = {
            options = {
                {
                    text = "Hola, hace una temperatura bastante agradable hoy, verdad?",
                    soundFile = "q_weather_1",
                    soundVolume = 0.5,
                },
                {
                    text = "Como le esta tratando el tiempo hoy? Hemos tenido bastantes dias buenos...",
                    soundFile = "q_weather_2",
                    soundVolume = 0.5,
                },
                {
                    text = "Veo que hoy ha salido. Que le parecen las condiciones del exterior?",
                    soundFile = "q_weather_3",
                    soundVolume = 0.5,
                }
            }
        }
    },
    {
        id = "dateofbirth", -- Don't change the id, it's linked to Config.DynamicAnswers.
        orderIndex = 2,
        serviceTypes = { "police", "ambulance", "fire", "tow" },  -- Which services can ask this question? [OPTIONS: "police", "ambulance", "fire", "tow"]
        question = {
            options = {
                {
                    text = "Puede decirme su fecha de nacimiento?",
                    soundFile = "q_dob_1",
                    soundVolume = 0.5,
                },
                {
                    text = "Cual es su fecha de nacimiento?",
                    soundFile = "q_dob_2",
                    soundVolume = 0.5,
                },
                {
                    text = "Cuando nacio?",
                    soundFile = "q_dob_3",
                    soundVolume = 0.5,
                }
            }
        }
    },
    {
        id = "address", -- Don't change the id, it's linked to Config.DynamicAnswers.
        orderIndex = 3,
        serviceTypes = { "police", "ambulance", "fire", "tow" },  -- Which services can ask this question? [OPTIONS: "police", "ambulance", "fire", "tow"]
        question = {
            options = {
                {
                    text = "Puede decirme su direccion, por favor?",
                    soundFile = "q_address_1",
                    soundVolume = 0.5,
                },
                {
                    text = "Cual es su direccion?",
                    soundFile = "q_address_2",
                    soundVolume = 0.5,
                },
                {
                    text = "Y que puede contarme sobre el lugar donde vive?",
                    soundFile = "q_address_3",
                    soundVolume = 0.5,
                }
            }
        }
    },
    {
        id = "destination", -- Don't change the id, it's linked to Config.DynamicAnswers.
        orderIndex = 4,
        serviceTypes = { "police", "ambulance", "fire", "tow" },  -- Which services can ask this question? [OPTIONS: "police", "ambulance", "fire", "tow"]
        question = {
            options = {
                {
                    text = "Puede decirme cual es su destino hoy?",
                    soundFile = "q_destination_1",
                    soundVolume = 0.5,
                },
                {
                    text = "Cual es su destino?",
                    soundFile = "q_destination_2",
                    soundVolume = 0.5,
                },
                {
                    text = "Adonde tiene pensado ir?",
                    soundFile = "q_destination_3",
                    soundVolume = 0.5,
                }
            }
        }
    },
    {
        id = "licenses", -- Don't change the id, it's linked to Config.DynamicAnswers.
        orderIndex = 5,
        serviceTypes = { "police" },  -- Which services can ask this question? [OPTIONS: "police", "ambulance", "fire", "tow"]
        question = {
            options = {
                {
                    text = "Puede decirme que permisos de conducir posee?",
                    soundFile = "q_licenses_1",
                    soundVolume = 0.5,
                },
                {
                    text = "Que permisos de conducir tiene?",
                    soundFile = "q_licenses_2",
                    soundVolume = 0.5,
                },
                {
                    text = "Tiene permiso para conducir o manejar algun vehiculo?",
                    soundFile = "q_licenses_3",
                    soundVolume = 0.5,
                }
            }
        }
    },
    {
        id = "inventory", -- Don't change the id, it's linked to Config.DynamicAnswers.
        orderIndex = 6,
        serviceTypes = { "police" },  -- Which services can ask this question? [OPTIONS: "police", "ambulance", "fire", "tow"]
        question = {
            options = {
                {
                    text = "Puede decirme que objetos lleva encima o consigo?",
                    soundFile = "q_inventory_1",
                    soundVolume = 0.5,
                },
                {
                    text = "Que objetos lleva encima o consigo?",
                    soundFile = "q_inventory_2",
                    soundVolume = 0.5,
                },
                {
                    text = "Que objetos tiene encima o consigo?",
                    soundFile = "q_inventory_3",
                    soundVolume = 0.5,
                }
            }
        }
    },
    {
        id = "intoxication", -- Don't change the id, it's linked to Config.DynamicAnswers.
        orderIndex = 7,
        serviceTypes = { "police", "ambulance", "fire" },  -- Which services can ask this question? [OPTIONS: "police", "ambulance", "fire", "tow"]
        question = {
            options = {
                {
                    text = "Ha consumido drogas o alcohol recientemente?",
                    soundFile = "q_intoxication_1",
                    soundVolume = 0.5,
                },
                {
                    text = "Esta bajo los efectos de alguna sustancia o del alcohol?",
                    soundFile = "q_intoxication_2",
                    soundVolume = 0.5,
                },
                {
                    text = "Ha bebido o consumido drogas hoy?",
                    soundFile = "q_intoxication_3",
                    soundVolume = 0.5,
                }
            }
        }
    },
    {
        id = "medical", -- Don't change the id, it's linked to Config.DynamicAnswers.
        orderIndex = 8,
        serviceTypes = { "police", "ambulance", "fire" },  -- Which services can ask this question? [OPTIONS: "police", "ambulance", "fire", "tow"]
        question = {
            options = {
                {
                    text = "Tiene alguna herida?",
                    soundFile = "q_medical_1",
                    soundVolume = 0.5,
                },
                {
                    text = "Necesita atencion medica?",
                    soundFile = "q_medical_2",
                    soundVolume = 0.5,
                },
                {
                    text = "Esta herido o se siente mal de alguna manera?",
                    soundFile = "q_medical_3",
                    soundVolume = 0.5,
                }
            }
        }
    },
}

Config.DynamicAnswers = {
    ["name"] = {
        templates = {
            -- Behavior State (The way the NPC are feeling.)
            normal = {
                options = {
                    {
                        text = "Mis padres me pusieron este nombre, es %s.", -- %s will be replaced with name
                        soundFile = "a_name_normal_1", -- If the NPC is a female, suffix "_f" will be added to the sound file. Example: a_name_normal_1_f
                        soundVolume = 0.5
                    },
                    {
                        text = "Tengo este nombre desde que naci, es %s.",
                        soundFile = "a_name_normal_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Es una tradicion familiar, me llamo %s.",
                        soundFile = "a_name_normal_3",
                        soundVolume = 0.5
                    }
                }
            },
            positive = {
                options = {
                    {
                        text = "Me alegra mucho que lo pregunte! Mi bonito nombre es %s.", -- %s will be replaced with name
                        soundFile = "a_name_positive_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Que pregunta tan agradable! Me enorgullece llamarme %s.",
                        soundFile = "a_name_positive_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Me encanta que la gente pregunte por mi nombre! Es %s.",
                        soundFile = "a_name_positive_3",
                        soundVolume = 0.5
                    }
                }
            },
            negative = {
                options = {
                    {
                        text = "Por que carajo iba a decirte mi nombre? Ni siquiera te conozco.",
                        soundFile = "a_name_negative_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Metete en tus asuntos! No voy diciendo mi nombre a desconocidos.",
                        soundFile = "a_name_negative_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Largate! No voy a contarte nada sobre mi.",
                        soundFile = "a_name_negative_3",
                        soundVolume = 0.5
                    }
                }
            },
            unusual = {
                options = {
                    {
                        text = "Creo que eres gracioso. Por que no me dices tu nombre? Bonito perro, por cierto.",
                        soundFile = "a_name_unusual_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Las voces dicen que no deberia decirtelo... pero ahora no estan aqui. Tu tambien ves las mariposas?",
                        soundFile = "a_name_unusual_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Los nombres solo son etiquetas que usa el gobierno para rastrearnos... pero las sombras conocen mi verdadero nombre.",
                        soundFile = "a_name_unusual_3",
                        soundVolume = 0.5
                    }
                }
            }
        }
    },
    ["weather"] = {
        templates = {
            normal = {
                options = {
                    {
                        text = "Creo que ultimamente ha hecho un poco de frio, pero hoy lo llevo bien. Agradezco el tiempo %s.", -- %s will be replaced with weather condition.
                        soundFile = "a_weather_normal_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Tienes razon. Siento algo parecido sobre el tiempo. No me molesta que este %s.",
                        soundFile = "a_weather_normal_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Todo va bien. Excepto cuando hay vientos fuertes. Aparte de eso, estoy bien con el tiempo %s.",
                        soundFile = "a_weather_normal_3",
                        soundVolume = 0.5
                    }
                }
            },
            positive = {
                options = {
                    {
                        text = "Me encanta este tiempo! El clima %s hace que todo parezca tan vivo!",
                        soundFile = "a_weather_positive_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "No es un dia perfecto? El tiempo %s realmente saca lo mejor de la ciudad!",
                        soundFile = "a_weather_positive_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Llevaba mucho tiempo esperando un tiempo asi! Esto es justo lo que necesitaba!",
                        soundFile = "a_weather_positive_3",
                        soundVolume = 0.5
                    }
                }
            },
            negative = {
                options = {
                    {
                        text = "Por que te importa el tiempo? Eres meteorologo o algo asi? Aunque... estoy bien con las condiciones de hoy.",
                        soundFile = "a_weather_negative_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "No tengo tiempo para hablar del clima. Tengo cosas mejores que hacer, pero gracias por preguntar.",
                        soundFile = "a_weather_negative_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "A que vienen tantas preguntas? El tiempo es el tiempo, a quien le importa?",
                        soundFile = "a_weather_negative_3",
                        soundVolume = 0.5
                    }
                }
            },
            unusual = {
                options = {
                    {
                        text = "Las nubes... me estan susurrando... me dicen que me quede dentro...",
                        soundFile = "a_weather_unusual_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Puedo sentir como el tiempo cambia mis pensamientos... el aire esta lleno de voces...",
                        soundFile = "a_weather_unusual_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Los patrones del tiempo... estan formando mensajes... no puedes verlos?",
                        soundFile = "a_weather_unusual_3",
                        soundVolume = 0.5
                    }
                }
            }
        }
    },
    ["dateofbirth"] = {
        templates = {
            normal = {
                options = {
                    {
                        text = "Naci el %s.", -- %s will be replaced with date of birth
                        soundFile = "a_dob_normal_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Mi fecha de nacimiento es el %s.",
                        soundFile = "a_dob_normal_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Estoy vivo desde el %s.",
                        soundFile = "a_dob_normal_3",
                        soundVolume = 0.5
                    }
                }
            },
            positive = {
                options = {
                    {
                        text = "Me encanta mi cumpleanos! Naci el %s!",
                        soundFile = "a_dob_positive_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Me alegra mucho que lo pregunte! Naci el %s!",
                        soundFile = "a_dob_positive_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Mi dia especial fue el %s!",
                        soundFile = "a_dob_positive_3",
                        soundVolume = 0.5
                    }
                }
            },
            negative = {
                options = {
                    {
                        text = "De todas formas, mi cumpleanos te importara una mierda.",
                        soundFile = "a_dob_negative_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "No creo que necesites saberlo.",
                        soundFile = "a_dob_negative_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "No puedo recordar ese dia.",
                        soundFile = "a_dob_negative_3",
                        soundVolume = 0.5
                    }
                }
            },
            unusual = {
                options = {
                    {
                        text = "Las estrellas dicen que es el mismo dia en que nacio el papa.",
                        soundFile = "a_dob_unusual_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Volvi a nacer la semana pasada. Desde entonces me siento perfecto.",
                        soundFile = "a_dob_unusual_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Tu tambien lo sientes? El tiempo esta cambiando. Creo que estamos cambiando de dimension.",
                        soundFile = "a_dob_unusual_3",
                        soundVolume = 0.5
                    }
                }
            }
        }
    },
    ["address"] = {
        templates = {
            normal = {
                options = {
                    {
                        text = "Quieres mi direccion? Vivo en %s.", -- %s will be replaced with address
                        soundFile = "a_address_normal_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Ya veo, quieres saber donde vivo. Mi casa esta en %s.",
                        soundFile = "a_address_normal_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Puedes encontrarme en casa, en %s.",
                        soundFile = "a_address_normal_3",
                        soundVolume = 0.5
                    }
                }
            },
            positive = {
                options = {
                    {
                        text = "Me encanta mi casa. Nos mudamos hace poco. Esta en %s!",
                        soundFile = "a_address_positive_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Mi maravilloso hogar esta en una de las mejores zonas de la ciudad, si quieres mi opinion! Esta en %s!",
                        soundFile = "a_address_positive_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Vivo en un lugar increible. Esta en %s!",
                        soundFile = "a_address_positive_3",
                        soundVolume = 0.5
                    }
                }
            },
            negative = {
                options = {
                    {
                        text = "Definitivamente no vas a conseguir mi direccion, asqueroso.",
                        soundFile = "a_address_negative_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "No encuentro ninguna razon en todo el maldito mundo por la que necesites saber mi direccion.",
                        soundFile = "a_address_negative_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Deja de preguntarme por mi direccion, no voy a decirtela...",
                        soundFile = "a_address_negative_3",
                        soundVolume = 0.5
                    }
                }
            },
            unusual = {
                options = {
                    {
                        text = "Que? Donde? Mi direccion? No se donde vivo. La ultima vez desperte en las alcantarillas.",
                        soundFile = "a_address_unusual_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Estan llegando... Nuestra caida es inminente. Si saben donde vivo, estare muerto!",
                        soundFile = "a_address_unusual_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "No, ahora mismo no puedo con esto. Debes de haberme confundido con otra persona.",
                        soundFile = "a_address_unusual_3",
                        soundVolume = 0.5
                    }
                }
            }
        }
    },
    ["destination"] = {
        templates = {
            normal = {
                options = {
                    {
                        text = "Me dirijo a %s.", -- %s will be replaced with destination
                        soundFile = "a_destination_normal_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Mi siguiente parada es %s.", 
                        soundFile = "a_destination_normal_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Voy de camino a %s.",
                        soundFile = "a_destination_normal_3",
                        soundVolume = 0.5
                    }
                }
            },
            positive = {
                options = {
                    {
                        text = "Tengo muchas ganas de ir a %s!",
                        soundFile = "a_destination_positive_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "En realidad, llevo una buena hora de camino. Estoy deseando llegar a, eh... %s!",
                        soundFile = "a_destination_positive_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Te lo dire! Tengo muchas ganas de visitar %s!",
                        soundFile = "a_destination_positive_3",
                        soundVolume = 0.5
                    }
                }
            },
            negative = {
                options = {
                    {
                        text = "Por que necesitas saber adonde voy? Metete en tus asuntos!",
                        soundFile = "a_destination_negative_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "No voy a decirte adonde voy. Deja de seguirme! Haces esto con todo el mundo?",
                        soundFile = "a_destination_negative_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Eso no es asunto tuyo. Me estas poniendo de los nervios. Dejame en paz!",
                        soundFile = "a_destination_negative_3",
                        soundVolume = 0.5
                    }
                }
            },
            unusual = {
                options = {
                    {
                        text = "Las voces de mi cabeza no paran de cambiar de opinion sobre adonde deberia ir...",
                        soundFile = "a_destination_unusual_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Creo que voy a algun sitio... o ya estoy alli?",
                        soundFile = "a_destination_unusual_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Las mariposas me dijeron que las siguiera, pero no paran de desaparecer...",
                        soundFile = "a_destination_unusual_3",
                        soundVolume = 0.5
                    }
                }
            }
        }
    },
    ["licenses"] = {
        templates = {
            normal = {
                options = {
                    {
                        text = "Tengo los siguientes permisos: %s.", -- %s will be replaced with all licenses the NPC has.
                        soundFile = "a_licenses_normal_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Poseo algunos permisos. Son estos: %s.",
                        soundFile = "a_licenses_normal_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Estoy cualificado porque hace poco aprobe las pruebas de los siguientes permisos: %s.",
                        soundFile = "a_licenses_normal_3",
                        soundVolume = 0.5
                    }
                }
            },
            positive = {
                options = {
                    {
                        text = "Me enorgullece decir que tengo permiso para %s!",
                        soundFile = "a_licenses_positive_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Trabaje muy duro para conseguir mis permisos para %s!",
                        soundFile = "a_licenses_positive_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Tengo todos los permisos necesarios para conducir un %s!",
                        soundFile = "a_licenses_positive_3",
                        soundVolume = 0.5
                    }
                }
            },
            negative = {
                options = {
                    {
                        text = "Por que preguntas por mis permisos? Eres policia?",
                        soundFile = "a_licenses_negative_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "No tengo que mostrarte ningun permiso. Largate!",
                        soundFile = "a_licenses_negative_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Que te importa que permisos tengo? Metete en tus asuntos!",
                        soundFile = "a_licenses_negative_3",
                        soundVolume = 0.5
                    }
                }
            },
            unusual = {
                options = {
                    {
                        text = "El gobierno me dio un permiso especial para hablar con los arboles...",
                        soundFile = "a_licenses_unusual_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Tengo permiso para ver a las personas invisibles, pero no paran de esconderlo...",
                        soundFile = "a_licenses_unusual_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Mi piedra mascota tiene todos mis permisos. El es el responsable...",
                        soundFile = "a_licenses_unusual_3",
                        soundVolume = 0.5
                    }
                }
            }
        }
    },
    ["inventory"] = {
        templates = {
            normal = {
                options = {
                    {
                        text = "Si... En realidad llevo algunas cosas conmigo: %s.", -- %s will be replaced with inventory items
                        soundFile = "a_inventory_normal_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Entiendo que quieres saber que llevo encima. Tengo estos objetos: %s.", -- %s will be replaced with inventory items
                        soundFile = "a_inventory_normal_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Dejame comprobarlo... Llevo %s.", -- %s will be replaced with inventory items
                        soundFile = "a_inventory_normal_3",
                        soundVolume = 0.5
                    }
                }
            },
            positive = {
                options = {
                    {
                        text = "Me hace mucha ilusion mostrarte lo que tengo! Tengo %s!", -- %s will be replaced with inventory items
                        soundFile = "a_inventory_positive_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Me encantan mis pertenencias! Tengo %s", -- %s will be replaced with inventory items
                        soundFile = "a_inventory_positive_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Estoy muy orgulloso de lo que llevo. Tengo %s!", -- %s will be replaced with inventory items
                        soundFile = "a_inventory_positive_3",
                        soundVolume = 0.5
                    }
                }
            },
            negative = {
                options = {
                    {
                        text = "Por que te interesa tanto lo que tengo? Piensas robarme?",
                        soundFile = "a_inventory_negative_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "No tengo que decirte lo que llevo en los bolsillos. Metete en tus asuntos!",
                        soundFile = "a_inventory_negative_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Largate! No voy a mostrarte lo que tengo. Es privado!",
                        soundFile = "a_inventory_negative_3",
                        soundVolume = 0.5
                    }
                }
            },
            unusual = {
                options = {
                    {
                        text = "Las voces de mi cabeza me dicen que no te lo muestre... pero, pensandolo bien, creo que no pasa nada...",
                        soundFile = "a_inventory_unusual_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Creo que tengo algo... o se lo volvieron a llevar las personas de las sombras?",
                        soundFile = "a_inventory_unusual_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Me siento raro... Creo que estan vacios, pero se que mientes sobre todo...",
                        soundFile = "a_inventory_unusual_3",
                        soundVolume = 0.5
                    }
                }
            }
        }
    },
    ["intoxication"] = {
        templates = {
            normal = {
                options = {
                    {
                        text = "Quieres saber si he tomado algo? Estoy %s.", -- %s will be replaced with sober/drunk/drugged
                        soundFile = "a_intoxication_normal_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Me siento bien, gracias por preguntar. Creo que estoy %s.", -- %s will be replaced with sober/drunk/drugged
                        soundFile = "a_intoxication_normal_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Tengo la mente despejada. Estoy %s.", -- %s will be replaced with sober/drunk/drugged
                        soundFile = "a_intoxication_normal_3",
                        soundVolume = 0.5
                    }
                }
            },
            positive = {
                options = {
                    {
                        text = "Me siento de maravilla! Estoy totalmente %s!", -- %s will be replaced with sober/drunk/drugged
                        soundFile = "a_intoxication_positive_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Estoy en perfectas condiciones! Estoy %s!", -- %s will be replaced with sober/drunk/drugged
                        soundFile = "a_intoxication_positive_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Nunca me he sentido mejor! Podrias decir que estoy %s!", -- %s will be replaced with sober/drunk/drugged
                        soundFile = "a_intoxication_positive_3",
                        soundVolume = 0.5
                    }
                }
            },
            negative = {
                options = {
                    {
                        text = "Que eres, un agente antidroga? Largate! Y no vuelvas a preguntar...",
                        soundFile = "a_intoxication_negative_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "No es asunto tuyo lo que he tomado! Preocupate de tu vida! De verdad debes de estar buscando algo que hacer...",
                        soundFile = "a_intoxication_negative_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "No tengo que contarte nada sobre lo que he consumido! Por que te preocupa?",
                        soundFile = "a_intoxication_negative_3",
                        soundVolume = 0.5
                    }
                }
            },
            unusual = {
                options = {
                    {
                        text = "Las paredes estan respirando... pero no he tomado nada! O si? No puedo recordarlo...",
                        soundFile = "a_intoxication_unusual_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Los colores son preciosos... pero no he tomado nada... verdad? No estoy seguro...",
                        soundFile = "a_intoxication_unusual_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Siento que estoy flotando... pero estoy seguro de que estoy sobrio... o no? Tal vez mi psiquiatra lo sepa...",
                        soundFile = "a_intoxication_unusual_3",
                        soundVolume = 0.5
                    }
                }
            }
        }
    },
    ["medical"] = {
        templates = {
            normal = {
                options = {
                    {
                        text = "Quieres conocer mi estado medico? Estoy %s.", -- %s will be replaced with healthy/conditions
                        soundFile = "a_medical_normal_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Creo que estoy bien. Siento que estoy %s.", -- %s will be replaced with healthy/conditions
                        soundFile = "a_medical_normal_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Normalmente estoy en buena forma. Estoy %s.", -- %s will be replaced with healthy/conditions
                        soundFile = "a_medical_normal_3",
                        soundVolume = 0.5
                    }
                }
            },
            positive = {
                options = {
                    {
                        text = "En realidad me siento de maravilla. Puedo decirte que estoy, eh... %s!", -- %s will be replaced with healthy/conditions
                        soundFile = "a_medical_positive_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Nunca he estado mejor! Es lo logico cuando estas %s!", -- %s will be replaced with healthy/conditions
                        soundFile = "a_medical_positive_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Tengo una salud perfecta! Creo... Me siento %s!", -- %s will be replaced with healthy/conditions
                        soundFile = "a_medical_positive_3",
                        soundVolume = 0.5
                    }
                }
            },
            negative = {
                options = {
                    {
                        text = "No necesito tu ayuda! Dejame en paz! No quiero ver a un medico.",
                        soundFile = "a_medical_negative_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Deja de preguntar por mi salud! No es asunto tuyo! Es algo privado...",
                        soundFile = "a_medical_negative_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Estoy bien! Deja de molestarme con estas preguntas! No te necesito para sobrevivir.",
                        soundFile = "a_medical_negative_3",
                        soundVolume = 0.5
                    }
                }
            },
            unusual = {
                options = {
                    {
                        text = "Los bichos... estan arrastrandose bajo mi piel... pero el medico dice que estoy bien...",
                        soundFile = "a_medical_unusual_1",
                        soundVolume = 0.5
                    },
                    {
                        text = "Puedo sentir como se mueven mis huesos... pero las voces dicen que es normal...",
                        soundFile = "a_medical_unusual_2",
                        soundVolume = 0.5
                    },
                    {
                        text = "Mi sangre fluye como un rio... Y el que esta dentro de mi dice que estoy sano...",
                        soundFile = "a_medical_unusual_3",
                        soundVolume = 0.5
                    }
                }
            }
        }
    },
}