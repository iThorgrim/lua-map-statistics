local Entity     = require( "map_stat_entity" )
local Helper     = require( "map_stat_helper" )
local Controller = { }

-- Private functions

local function OnServerStart( _ )
    Entity = Entity:New()

    local players = GetPlayersInWorld()
    for _, player in pairs( players ) do
        Controller.OnPlayerChangeMap( 33, player )
    end
end
RegisterServerEvent( 33, OnServerStart )

local function handleEntityData( map, area, difficulty, class, spec )
    local success, result = pcall(function()
        return Entity
                :GetForMap( map )
                :GetForArea( area )
                :GetForDifficulty( difficulty )
                :GetForClass( class )
                :GetForSpecialization( spec )
                :GetResult()
    end)

    return success and result or nil, not success and result or nil
end

-- Public functions

function Controller.UpdateStat( player, data, up )
    for stat, value in pairs( data ) do
        if ( stat ~= Helper.ENUM.STAT[ 'SPELL POWER' ] ) then
            player:HandleStatModifier( stat, 3, value, up )
        else
            player:SetSpellPower( stat, value, up )
        end
    end
end

function Controller.OnPlayerChangeMap( event, player, _, new_area )
    local player_data = player:GetData( "Map_Stat" )
    if ( player_data ) then
        Controller.UpdateStat( player, player_data, false )
        player:SetData( "Map_Stat", nil )
    end

    local map        = player:GetMapId()
    local area       = new_area or player:GetAreaId()
    local difficulty = player:GetMap():GetDifficulty()
    local class      = player:GetClass()
    local spec       = player:GetSpecialization()

    local data, status = handleEntityData( map, area, difficulty, class, spec )

    -- TODO: Add Config File with Debug option to show status
    -- if ( true and status ) then print( string.format( "Map Stat :: %s", status ) ) return end

    if ( data ) then
        if ( event == 33 ) then
            Controller.UpdateStat( player, data, false )
        end
        Controller.UpdateStat( player, data, true )

        local in_combat = player:IsInCombat()
        if ( not in_combat ) then
            local health = player:GetMaxHealth()
            player:SetHealth( health )
            if ( class ~= Helper.ENUM.CLASS.WARRIOR ) then
                local power = player:GetMaxPower( class == Helper.ENUM.CLASS['DEATH KNIGHT'] and 6 or class == Helper.ENUM.CLASS.ROGUE and 3 or 0 )
                player:SetPower( power, class == Helper.ENUM.CLASS['DEATH KNIGHT'] and 6 or class == Helper.ENUM.CLASS.ROGUE and 3 or 0 )
            end
        end

        player:SetData( "Map_Stat", data )
    end
end
RegisterPlayerEvent( 28, Controller.OnPlayerChangeMap )
RegisterPlayerEvent( 27, Controller.OnPlayerChangeMap )
RegisterPlayerEvent( 47, Controller.OnPlayerChangeMap )