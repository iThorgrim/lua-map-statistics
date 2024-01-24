local Helper = require("map_stat_helper")
local Entity = { }

-- Private functions
local upper  = string.upper
local format = string.format

---
-- Create the database if it doesn't exist
--
-- @return void
---
local function CreateDatabase()
    WorldDBQuery( format( Helper.QUERY.DATABASE.CREATE, Helper.QUERY.DATABASE.NAME ) )
end

---
-- Fetch or create index associating maps to statistics
--
-- @return table
---
local function GetOrCreateIndex()
    WorldDBQuery( format( Helper.QUERY.INDEX.CREATE, Helper.QUERY.DATABASE.NAME ) )

    local query = WorldDBQuery( format( Helper.QUERY.INDEX.READ, Helper.QUERY.DATABASE.NAME ) )
    local temp = { }
    if ( query ) then
        repeat
            local id_map = query:GetUInt32( 0 )
            if ( not temp[ id_map ] ) then
                temp[ id_map ] = { }
            end

            local id_statistics = query:GetUInt32( 1 )
            local key = #temp[ id_map ]

            temp[ id_map ][ key + 1 ] = id_statistics
        until not query:NextRow()
    end
    return temp
end

---
-- Fetch or create map data
--
-- @return table
---
local function GetOrCreateMap()
    WorldDBQuery( format( Helper.QUERY.MAP.CREATE, Helper.QUERY.DATABASE.NAME ) )

    local query = WorldDBQuery( format( Helper.QUERY.MAP.READ, Helper.QUERY.DATABASE.NAME ) )
    local temp = { }
    if ( query ) then
        repeat
            local id = query:GetUInt32( 0 )
            if ( not temp[ id ] ) then
                temp[ id ] = { }
            end

            local map = query:GetUInt32( 1 )
            if ( not temp[ id ][ map ] ) then
                temp[ id ][ map ] = { }
            end

            local area = query:GetUInt32( 2 )
            if ( not temp[ id ][ map ][ area ] ) then
                temp[ id ][ map ][ area ] = { }
            end

            local difficulty    = query:GetString( 3 )
            local difficulty_id = Helper.ENUM.DIFFICULTY[ upper(difficulty) ]

            temp[ id ][ map ][ area ][ difficulty_id ] = true
        until not query:NextRow()
    end
    return temp
end

---
-- Fetch or create statistics for classes, specialisations and stats
--
-- @return table
---
local function GetOrCreateStatistic()
    WorldDBQuery( format( Helper.QUERY.STATISTIC.CREATE, Helper.QUERY.DATABASE.NAME ) )

    local query = WorldDBQuery( format( Helper.QUERY.STATISTIC.READ, Helper.QUERY.DATABASE.NAME ) )
    local temp = { }
    if ( query ) then
        repeat
            local id                = query:GetUInt32( 0 )
            local class             = query:GetString( 1 )
            local specialization    = query:GetString( 2 )
            local statistic         = query:GetString( 3 )
            local value             = query:GetFloat( 4 )

            local class_id = Helper.ENUM.CLASS[ upper(class) ]
            local spec_id  = Helper.ENUM.SPECIALIZATION[ upper(specialization) ]
            local stat_id  = Helper.ENUM.STAT[ upper(statistic) ]

            if ( not temp[ id ] ) then temp[ id ] = { } end
            if ( not temp[ id ][ class_id ] ) then temp[ id ][ class_id ] = { } end
            if ( not temp[ id ][ class_id ][ spec_id ] ) then temp[ id ][ class_id ][ spec_id ] = { } end

            local key = #temp[ id ][ class_id ][ spec_id ]
            temp[ id ][ class_id ][ spec_id ][ key + 1 ] = { [ stat_id ] = value }
        until not query:NextRow()
    end
    return temp
end

local function table_merge(t1, t2)
    local result = {}

    for key, value in pairs(t1) do
        if type(value) == "table" and type(t2[key]) == "table" then
            result[key] = table_merge(value, t2[key])
        else
            result[key] = value
        end
    end

    for key, value in pairs(t2) do
        if result[key] == nil then
            if type(value) == "table" then
                result[key] = table_merge({}, value)
            else
                result[key] = value
            end
        end
    end

    return result
end

local function table_merge_recursive(t1, t2)
    for key, value in pairs(t2) do
        if type(value) == "table" then
            if type(t1[key]) == "table" then
                t1[key] = table_merge_recursive(t1[key], value)
            else
                t1[key] = table_merge_recursive({}, value)
            end
        else
            t1[key] = value
        end
    end

    return t1
end

-- Public methods

---
-- Interfacial method to construct or recall an instance of Entity
--
-- @return Entity instance
---
local _instance
function Entity:New()
    if _instance then return _instance end

    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.Config = self:Load()
    _instance = o
    return o
end

---
-- Load configurations for the Entity
--
-- @return nil
---
function Entity:Load()
    -- [[ Security ]]--
    CreateDatabase()

    -- [[ Load Data ]]--
    self.statistics = GetOrCreateStatistic()
    self.maps       = GetOrCreateMap()
    self.index      = GetOrCreateIndex()
    self.search     = { }

    -- [[ Format Data ]]--
    self.statistics = self:FormatIndex()
end

---
-- Format the index in a specific way
--
-- @return table
---
function Entity:FormatIndex()
    local temp = {}

    for id_map, _ in pairs(self.index) do
        for _, id_statistic in ipairs(self.index[id_map]) do
            for map, _ in pairs(self.maps[id_map]) do
                for area, _ in pairs(self.maps[id_map][map]) do
                    for difficulty, _ in pairs(self.maps[id_map][map][area]) do
                        if not temp[map] then temp[map] = {} end
                        if not temp[map][area] then temp[map][area] = {} end
                        if not temp[map][area][difficulty] then temp[map][area][difficulty] = {} end

                        local stats = self.statistics[id_statistic]
                        for class_id, _ in pairs(stats) do
                            for spec_id, _ in pairs(stats[class_id]) do
                                if not temp[map][area][difficulty][class_id] then temp[map][area][difficulty][class_id] = {} end
                                if not temp[map][area][difficulty][class_id][spec_id] then temp[map][area][difficulty][class_id][spec_id] = {} end

                                for _, stat_value in ipairs(stats[class_id][spec_id]) do
                                    local stat_id, value = next(stat_value)
                                    temp[map][area][difficulty][class_id][spec_id][stat_id] = value
                                end

                                if ( spec_id ~= Helper.ENUM.SPECIALIZATION.ALL ) then
                                    temp[map][area][difficulty][class_id][spec_id] = table_merge(temp[map][area][difficulty][class_id][Helper.ENUM.SPECIALIZATION.ALL], temp[map][area][difficulty][class_id][spec_id])
                                end
                            end
                            temp[map][area][difficulty][class_id][Helper.ENUM.SPECIALIZATION.ALL] = nil
                        end
                    end
                end
            end
        end
    end

    self.statistics = nil
    self.maps       = nil
    self.index      = nil

    return temp
end

---
-- Retrieve map information for a given map
-- Throws an error if the map does not exist
--
-- @param map The map to retrieve the information for
-- @return Entity
---
function Entity:GetForMap( map )
    local data = self.statistics[ map ]
    if ( not data ) then
        error(string.format("Map %s doesn't exist.", map))
    end

    self.search.map    = map
    self.search.result = data
    return self
end

---
-- Retrieve area information for a given area
-- Throws an error if the area does not exist for the current map
--
-- @param area The area to retrieve the information for
-- @return Entity
---
function Entity:GetForArea( area )
    if ( not self.search.map ) then
        error("Please use Entity:GetForMap( map_id ) first.")
    end

    local all_area = self.search.result[ 0 ]
    local data = self.search.result[ area ]
    if ( not data and not all_area ) then
        error(string.format("Area %s doesn't exist for this map.", area))
    end

    local area_data
    if ( all_area and data ) then
        area_data = table_merge_recursive(all_area, data)
    elseif ( all_area ) then
        area_data = all_area
    else
        area_data = data
    end

    self.search.area       = area
    self.search.result     = area_data
    return self
end

---
-- Retrieve difficulty information for a given difficulty level
-- Throws an error if the difficulty does not exist for the current area
--
-- @param difficulty The difficulty level to retrieve the information for
-- @return Entity
---
function Entity:GetForDifficulty( difficulty )
    if ( not self.search.area ) then
        error("Please use Entity:GetForArea( map_id ) first.")
    end

    local data = self.search.result[ difficulty ]
    if ( not data ) then
        error(string.format("Difficulty %s doesn't exist for this area.", difficulty))
    end

    self.search.difficulty = difficulty
    self.search.result     = data
    return self
end

---
-- Retrieve class information for a given class
-- Throws an error if the class does not exist for the current difficulty
--
-- @param class The class to retrieve the information for
-- @return Entity
---
function Entity:GetForClass( class )
    if ( not self.search.difficulty ) then
        error("Please use Entity:GetForDifficulty( difficulty ) first.")
    end

    local data = self.search.result[ class ]
    if ( not data ) then
        error(string.format("Class %s doesn't exist for this difficulty.", class))
    end

    self.search.class  = class
    self.search.result = data
    return self
end

---
-- Retrieve specialization information for a given specialization
-- Throws an error if the specialization does not exist for the current class
--
-- @param spec The specialization to retrieve the information for
-- @return Entity
---
function Entity:GetForSpecialization( spec )
    if ( not self.search.class ) then
        error("Please use Entity:GetForClass( class ) first.")
    end

    local data = self.search.result[ spec ]
    if ( not data ) then
        error(string.format("Specialization %s doesn't exist for this class.", spec))
    end

    self.search.spec   = spec
    self.search.result = data
    return self
end

---
-- Get the final search results
--
-- @return table The search results
---
function Entity:GetResult()
    self.search.map         = nil
    self.search.difficulty  = nil
    self.search.class       = nil
    self.search.spec        = nil

    local temp = self.search.result
    self.search.result = nil

    return temp
end

---
-- Reloads the data from the database.
-- This function cleans up the current state of the Entity instance and then calls `load`.
--
-- @return void
---
function Entity:Reload()
    self.statistics = nil
    self.maps       = nil
    self.index      = nil
    self.search     = {}

    self:Load()
end

-- Player Methods

function Player:GetSpecialization()
    return self:HasTankSpec()   and Helper.ENUM.SPECIALIZATION.TANK
        or self:HasHealSpec()   and Helper.ENUM.SPECIALIZATION.HEAL
        or self:HasCasterSpec() and Helper.ENUM.SPECIALIZATION.CASTER
        or self:HasMeleeSpec()  and Helper.ENUM.SPECIALIZATION.MELEE
        or nil
end

return Entity