--Copyright (C) 2017 Arno Zura ( https://www.gnu.org/licenses/gpl.txt )

--db_restriction.lua

local _db_name = "yrp_restrictions"

sql_add_column( _db_name, "usergroup", "TEXT DEFAULT ''" )
sql_add_column( _db_name, "vehicles", "INT DEFAULT 0" )
sql_add_column( _db_name, "weapons", "INT DEFAULT 0" )
sql_add_column( _db_name, "duplicator", "INT DEFAULT 0" )
sql_add_column( _db_name, "entities", "INT DEFAULT 0" )
sql_add_column( _db_name, "effects", "INT DEFAULT 0" )
sql_add_column( _db_name, "npcs", "INT DEFAULT 0" )
sql_add_column( _db_name, "props", "INT DEFAULT 0" )
sql_add_column( _db_name, "ragdolls", "INT DEFAULT 0" )

if db_select( _db_name, "*", "usergroup = 'superadmin'" ) == nil then
  db_insert_into( _db_name, "usergroup, vehicles, weapons, duplicator, entities, effects, npcs, props, ragdolls", "'superadmin', 1, 1, 1, 1, 1, 1, 1, 1" )
end
if db_select( _db_name, "*", "usergroup = 'admin'" ) == nil then
  db_insert_into( _db_name, "usergroup, vehicles, weapons, duplicator, entities, effects, npcs, props, ragdolls", "'admin', 1, 1, 1, 1, 1, 1, 1, 1" )
end
if db_select( _db_name, "*", "usergroup = 'user'" ) == nil then
  db_insert_into( _db_name, "usergroup", "'user'" )
end
if db_select( _db_name, "*", "usergroup = 'player'" ) == nil then
  db_insert_into( _db_name, "usergroup", "'player'" )
end
if db_select( _db_name, "*", "usergroup = 'operator'" ) == nil then
  db_insert_into( _db_name, "usergroup", "'operator'" )
end

--sql.Query( "DROP TABLE " .. _db_name )
db_is_empty( _db_name )

hook.Add( "PlayerSpawnVehicle", "yrp_vehicles_restriction", function( ply )
  local _tmp = db_select( "yrp_restrictions", "vehicles", "usergroup = '" .. ply:GetUserGroup() .. "'" )
  if worked( _tmp, "PlayerSpawnVehicle failed" ) then
    _tmp = _tmp[1]
    if tobool( _tmp.vehicles ) then
      return true
    else
      printGM( "note", ply:Nick() .. " [" .. ply:GetUserGroup() .. "] tried to spawn a vehicle." )
      return false
    end
  end
end)

hook.Add( "PlayerGiveSWEP", "yrp_weapons_restriction", function( ply )
  local _tmp = db_select( "yrp_restrictions", "weapons", "usergroup = '" .. ply:GetUserGroup() .. "'" )
  if worked( _tmp, "PlayerGiveSWEP failed" ) then
    _tmp = _tmp[1]
    if tobool( _tmp.weapons ) then
      return true
    else
      printGM( "note", ply:Nick() .. " [" .. ply:GetUserGroup() .. "] tried to spawn a weapon." )
      return false
    end
  end
end)

hook.Add( "PlayerSpawnSENT", "yrp_entities_restriction", function( ply )
  local _tmp = db_select( "yrp_restrictions", "entities", "usergroup = '" .. ply:GetUserGroup() .. "'" )
  if worked( _tmp, "PlayerSpawnSENT failed" ) then
    _tmp = _tmp[1]
    if tobool( _tmp.entities ) then
      return true
    else
      printGM( "note", ply:Nick() .. " [" .. ply:GetUserGroup() .. "] tried to spawn an entity." )
      return false
    end
  end
end)

hook.Add( "PlayerSpawnEffect", "yrp_effects_restriction", function( ply )
  local _tmp = db_select( "yrp_restrictions", "effects", "usergroup = '" .. ply:GetUserGroup() .. "'" )
  if worked( _tmp, "PlayerSpawnEffect failed" ) then
    _tmp = _tmp[1]
    if tobool( _tmp.effects ) then
      return true
    else
      printGM( "note", ply:Nick() .. " [" .. ply:GetUserGroup() .. "] tried to spawn an effect." )
      return false
    end
  end
end)

hook.Add( "PlayerSpawnNPC", "yrp_npcs_restriction", function( ply )
  local _tmp = db_select( "yrp_restrictions", "npcs", "usergroup = '" .. ply:GetUserGroup() .. "'" )
  if worked( _tmp, "PlayerSpawnNPC failed" ) then
    _tmp = _tmp[1]
    if tobool( _tmp.npcs ) then
      return true
    else
      printGM( "note", ply:Nick() .. " [" .. ply:GetUserGroup() .. "] tried to spawn a npc." )
      return false
    end
  end
end)

hook.Add( "PlayerSpawnProp", "yrp_props_restriction", function( ply )
  local _tmp = db_select( "yrp_restrictions", "props", "usergroup = '" .. ply:GetUserGroup() .. "'" )
  if worked( _tmp, "PlayerSpawnProp failed" ) then
    _tmp = _tmp[1]
    if tobool( _tmp.props ) then
      return true
    else
      printGM( "note", ply:Nick() .. " [" .. ply:GetUserGroup() .. "] tried to spawn a prop." )
      return false
    end
  end
end)

hook.Add( "PlayerSpawnRagdoll", "yrp_ragdolls_restriction", function( ply )
  local _tmp = db_select( "yrp_restrictions", "ragdolls", "usergroup = '" .. ply:GetUserGroup() .. "'" )
  if worked( _tmp, "PlayerSpawnRagdoll failed" ) then
    _tmp = _tmp[1]
    if tobool( _tmp.ragdolls ) then
      return true
    else
      printGM( "note", ply:Nick() .. " [" .. ply:GetUserGroup() .. "] tried to spawn a ragdoll." )
      return false
    end
  end
end)

util.AddNetworkString( "getRistrictions" )
util.AddNetworkString( "dbUpdate" )

net.Receive( "getRistrictions", function( len, ply )
  local _usergroups = {}
  for k, v in pairs( player.GetAll() ) do
    local _ug = v:GetUserGroup()
    if db_select( _db_name, "*", "usergroup = '" .. _ug .. "'" ) == nil then
      printGM( "note", "usergroup: " .. _ug .. " not found" )
    end
  end
  local _tmp = db_select( _db_name, "*", nil )
  net.Start( "getRistrictions" )
  if _tmp != nil then
    net.WriteTable( _tmp )
  else
    net.WriteTable( {} )
  end
  net.Send( ply )
end)

net.Receive( "dbUpdate", function( len, ply )
  local _dbTable = net.ReadString()
  local _dbSets = net.ReadString()
  local _dbWhile = net.ReadString()
  db_update( _dbTable, _dbSets, _dbWhile )
  local _usergroup_ = string.Explode( " ", _dbWhile )
  local _restriction_ = string.Explode( " ", _dbSets )
  printGM( "note", ply:SteamName() .. " SETS " .. _dbSets .. " WHERE " .. _dbWhile )
end)