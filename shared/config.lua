Config = {
    TriggerGetEsx = "esx:getSharedObject",
    TriggerEsxNotif = "esx:showNotification",
    TriggerEsxPlayerLoaded = "esx:playerLoaded",
    TriggerEsxSetjob2 = "esx:setJob2",
    MoneyType = {money = "money", black_money = "black_money"}, -- Si vous etes base calif money = cash et black_money = dirtycash
    Marker = {
        MarkerId = 21, 
        Color = { R = 141, G = 37, B = 218, A = 255},
        BobUpAndDown = false,
        FaceCamera = false,
        Rotate = true,
        UseMoins1 = false -- Si votre marker est en l'air metter ceci en true
    },
    PrefixColorHelpNotif = "~b~",
    ExecutCommandCreateGang = {
        "superadmin",
        "admin",
    },
    WhitelistVeh = function(vProps)
        return true -- Ajouter ici la condition pour ranger un vehicule dans le garage
    end,
    BossAction = function(job) -- Job = la table job, votre trigger pour ouvrir le menu boss
        TriggerEvent('esx_society:openBossMenu', job.name, function(data, menu) 
        end, { wash = false }) -- disable washing money
    end,
    UseESXSocietyBasic = true, -- Si vous utilsier TriggerEvent('esx_society:registerSociety')
    CheatAction = function(id, reason) -- Action quand un joueur tente de cheat, id = son id et reason = l'event du cheat
        DropPlayer(id, "Il est interdit de cheat sur notre server. (TRIGGER:"..reason.."). Si vous pensez qu'il sagit d'une erreur rendez-vous sur notre discord discord.gg/.")
    end,
    CoffrePoidsMax = 500, -- Poids Valable que pour les armes
    ArmesInItem = false,
    SaveTime = 5, -- En minutes, par exemple toute les 5 minutes les véchicule, les items etc seront save en bdd

    PoidsWeapons = { -- Si vous avez pas les armes en item
        ["WEAPON_NIGHTSTICK"] = 15,
        ["WEAPON_KNIFE"] = 15,
        ["WEAPON_STUNGUN"] = 30,
        ["WEAPON_FLASHLIGHT"] = 15,
        ["WEAPON_FLAREGUN"] = 30,
        ["WEAPON_FLARE"] = 30,
        ["WEAPON_COMBATPISTOL"] = 35,
        ["WEAPON_HEAVYPISTOL"] = 32,
        ["WEAPON_ASSAULTSMG"] = 40,
        ["WEAPON_COMBATPDW"] = 40,
        ["WEAPON_BULLPUPRIFLE"] = 42,
        ["WEAPON_PUMPSHOTGUN"] = 42,
        ["WEAPON_BULLPUPSHOTGUN"] = 45,
        ["WEAPON_CARBINERIFLE"] = 45,
        ["WEAPON_ADVANCEDRIFLE"] = 45,
        ["WEAPON_MARKSMANRRIFLE"] = 28,
        ["WEAPON_SNIPERRIFLE"] = 28,
        ["WEAPON_FIREEXTINGUISHER"] = 28, 
        ["GADGET_PARACHUTE"] = 10,
        ["WEAPON_BAT"] = 32,
        ["WEAPON_PISTOL"] = 40,
        ["WEAPON_PISTOL50"] = 42,

    }
}


Config.DevNotif = "zGangsBuilder" -- Mettre le nom de votre Serveur
Config.CommandName = "zbuilder" -- Nom de la command IG