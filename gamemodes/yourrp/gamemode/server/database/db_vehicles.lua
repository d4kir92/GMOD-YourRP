--Copyright (C) 2017 Arno Zura ( https://www.gnu.org/licenses/gpl.txt )

--db_vehicle.lua

util.AddNetworkString( "resetVehicleKey" )
util.AddNetworkString( "createVehicleKey" )
util.AddNetworkString( "removeVehicleOwner" )

util.AddNetworkString( "getVehicleInfo" )

local dbTable = "yrp_vehicles"
sqlAddColumn( dbTable, "keynr", "TEXT DEFAULT '-1'" )
sqlAddColumn( dbTable, "price", "TEXT DEFAULT 100" )
sqlAddColumn( dbTable, "ownerCharID", "TEXT DEFAULT ''" )
sqlAddColumn( dbTable, "ClassName", "TEXT DEFAULT ''" )

function createVehicleKey( ent, id )
  local _tmp = id
  _tmp = _tmp .. math.Round( math.Rand( 100000, 999999 ), 0 )
  ent.keynr = _tmp
  local result = dbUpdate( "yrp_vehicles", "keynr = '" .. _tmp .. "'", "uniqueID = " .. id )
  return _tmp
end

function getVehicleNumber( ent, id )
  if ent.keynr == nil then
    ent.keynr = createVehicleKey( ent, id )
  end
  return ent.keynr
end

function allowedToUseVehicle( id, ply )
  if ply:IsSuperAdmin() or ply:IsAdmin() then
    return true
  else
    local _tmpVehicleTable = dbSelect( "yrp_vehicles", "*", "uniqueID = '" .. id .. "'" )
    if _tmpVehicleTable[1] != nil then
      if tostring( _tmpVehicleTable[1].ownerCharID ) == ply:CharID() then
        return true
      end
    end
  end
  return false
end

net.Receive( "getVehicleInfo", function( len, ply )
  local _vehicle = net.ReadEntity()

  local _vehicleID = net.ReadString()

  local _vehicleTab = dbSelect( "yrp_vehicles", "*", "uniqueID = " .. _vehicleID )

  local owner = ""
  for k, v in pairs( player.GetAll() ) do
    if tostring( v:CharID() ) == tostring( _vehicleTab[1].ownerCharID ) then
      owner = v:RPName()
    end
  end

  if _vehicleTab != nil then
    if allowedToUseVehicle( _vehicleID, ply ) then
      net.Start( "getVehicleInfo" )
        net.WriteBool( true )
        net.WriteEntity( _vehicle )
        net.WriteTable( _vehicleTab )
        net.WriteString( owner )
      net.Send( ply )
    else
      net.Start( "getVehicleInfo" )
        net.WriteBool( false )
      net.Send( ply )
    end
  end
end)

net.Receive( "resetVehicleKey", function( len, ply )
  local _vehicle = net.ReadEntity()
  local _tmpVehicleID = net.ReadInt( 16 )

  createVehicleKey( _vehicle, _tmpVehicleID )
end)

net.Receive( "createVehicleKey", function( len, ply )
  local _vehicle = net.ReadEntity()
  local _tmpVehicleID = net.ReadInt( 16 )

  local _keynr = -1
  for k, v in pairs( ply:GetWeapons() ) do
    if v.ClassName == "yrp_key" then
      _keynr = getVehicleNumber( _vehicle, _tmpVehicleID )
      local _oldkeynrs = dbSelect( "yrp_characters", "keynrs", "uniqueID = " .. ply:CharID() )
      local _tmpTable = string.Explode( ",", _oldkeynrs[1].keynrs )
      if !table.HasValue( _tmpTable, _keynr ) then
        v:AddKeyNr( _keynr )

        local _newkeynrs = ""
        for l, w in pairs( _tmpTable ) do
          if w != "" then
            _newkeynrs = _newkeynrs .. w
            _newkeynrs = _newkeynrs .. ","
          end
        end
        _newkeynrs = _newkeynrs .. _keynr
        dbUpdate( "yrp_characters", "keynrs = '" .. _newkeynrs .. "'", "uniqueID = " .. ply:CharID() )
      else
        printGM( "note", "Key already exists")
      end
      break
    end
  end
end)

function canVehicleLock( ent, nr )
  local _tmpTable = dbSelect( "yrp_vehicles", "keynr", "uniqueID = " .. ent:GetNWInt( "vehicleID" ) )
  if _tmpTable != nil then
    if _tmpTable[1] != nil then
      if _tmpTable[1].keynr == nr then
        return true
      else
        return false
      end
    end
  end
  return false
end

function unlockVehicle( ent, nr )
  if canVehicleLock( ent, nr ) then
    ent:Fire( "Unlock" )
    return true
  end
  return false
end

function lockVehicle( ent, nr )
  if canVehicleLock( ent, nr ) then
    ent:Fire( "Lock", "", 0 )
    return true
  end
  return false
end

net.Receive( "removeVehicleOwner", function( len, ply )
  local _tmpVehicleID = net.ReadInt( 16 )
  local _tmpTable = dbSelect( "yrp_vehicles", "*", "uniqueID = '" .. _tmpVehicleID .. "'" )

  local result = dbUpdate( "yrp_vehicles", "ownerCharID = ''", "uniqueID = '" .. _tmpVehicleID .. "'" )

  for k, v in pairs( ents.GetAll() ) do
    if tonumber( v:GetNWInt( "vehicleID" ) ) == tonumber( _tmpVehicleID ) then
      v:SetNWString( "ownerRPName", "" )
      createVehicleKey( v, _tmpVehicleID )
    end
  end
end)
