return {
    ENUM = {
        STAT = {
            ["STRENGTH"]                = 0,
            ["AGILITY"]                 = 1,
            ["STAMINA"]                 = 2,
            ["INTELLECT"]               = 3,
            ["SPIRIT"]                  = 4,
            ["HEALTH"]                  = 5,
            ["MANA"]                    = 6,
            ["RAGE"]                    = 7,
            ["FOCUS"]                   = 8,
            ["ENERGY"]                  = 9,
            ["HAPPINESS"]               = 10,
            ["RUNE"]                    = 11,
            ["RUNIC POWER"]             = 12,
            ["ARMOR"]                   = 13,
            ["RESISTANCE HOLY"]         = 14,
            ["RESISTANCE FIRE"]         = 15,
            ["RESISTANCE NATURE"]       = 16,
            ["RESISTANCE FROST"]        = 17,
            ["RESISTANCE SHADOW"]       = 18,
            ["RESISTANCE ARCANE"]       = 19,
            ["ATTACK POWER"]            = 20,
            ["ATTACK POWER RANGED"]     = 21,
            ["DAMAGE MAIN HAND"]        = 22,
            ["DAMAGE OFF HAND"]         = 23,
            ["DAMAGE RANGED"]           = 24,
            ["SPELL POWER"]             = 25
        },

        SPECIALIZATION = {
            ["ALL"]     = 0,
            ["TANK"]    = 1,
            ["HEAL"]    = 2,
            ["CASTER"]  = 3,
            ["MELEE"]   = 4
        },

        CLASS = {
            ["WARRIOR"]         = 1,
            ["PALADIN"]         = 2,
            ["HUNTER"]          = 3,
            ["ROGUE"]           = 4,
            ["PRIEST"]          = 5,
            ["DEATH KNIGHT"]    = 6,
            ["SHAMAN"]          = 7,
            ["MAGE"]            = 8,
            ["WARLOCK"]         = 9,
            ["DRUID"]           = 11
        },

        DIFFICULTY = {
            ["NORMAL RAID (10 PLAYERS)"] = 0,
            ["NORMAL RAID (25 PLAYERS)"] = 1,
            ["HEROIC RAID (10 PLAYERS)"] = 2,
            ["HEROIC RAID (25 PLAYERS)"] = 3,

            ["NORMAL DUNGEON (5 PLAYERS)"] = 0,
            ["HEROIC DUNGEON (5 PLAYERS)"] = 1
        },

        EVENTS = {
            PLAYER = {

            }
        }
    },

    QUERY = {
        DATABASE = {
            NAME = "335_dev_eluna",
            CREATE = "CREATE DATABASE IF NOT EXISTS %s;"
        },

        INDEX = {
            CREATE = [[
                CREATE TABLE IF NOT EXISTS `%s`.`index_map_stat` (
                    `id_map` int(10) NOT NULL,
                    `id_statistics` int(10) NOT NULL,
                    PRIMARY KEY (`id_map`,`id_statistics`),
                    KEY `id_statistics` (`id_statistics`),
                    CONSTRAINT `id_map` FOREIGN KEY (`id_map`)
                        REFERENCES `index_map_stat_map` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
                    CONSTRAINT `id_statistics` FOREIGN KEY (`id_statistics`)
                        REFERENCES `index_map_stat_statistics` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
            ]],
            READ   = "SELECT * FROM `%s`.`index_map_stat`;"
        },

        MAP = {
            CREATE = [[
                CREATE TABLE IF NOT EXISTS `%s`.`index_map_stat_map` (
                    `id` INT(10) NOT NULL AUTO_INCREMENT,
                    `map` INT(10) NOT NULL,
                    `area` INT(10) NOT NULL DEFAULT 0,
                    `difficulty` INT(1) NOT NULL DEFAULT 0,
                    PRIMARY KEY (`id`)
                )
                ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
            ]],
            READ   = "SELECT * FROM `%s`.`index_map_stat_map`;"
        },

        STATISTIC = {
            CREATE = [[
                CREATE TABLE IF NOT EXISTS `%s`.`index_map_stat_statistics` (
                    `id` int(10) NOT NULL,
                    `class` enum('Warrior','Paladin','Hunter','Rogue','Priest','Death Knight','Shaman','Mage','Warlock','Druid') NOT NULL,
                    `specialization` enum('All','Tank','Melee','Caster','Heal') NOT NULL,
                    `statistic` enum('Strength','Agility','Stamina','Intellect','Spirit','Health','Mana','Rage','Focus','Energy','Happiness','Rune','Runic Power','Armor','Resistance Holy','Resistance Fire','Resistance Nature','Resistance Frost','Resistance Shadow','Resistance Arcane','Attack Power','Attack Power Ranger','Damage Main Hand','Damage Off Hand','Damage Ranged','Spell Power') NOT NULL,
                    `value` float NOT NULL,
                    PRIMARY KEY (`id`,`class`,`specialization`,`statistic`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
            ]],
            READ   = "SELECT * FROM `%s`.`index_map_stat_statistics`;"
        }
    }
}