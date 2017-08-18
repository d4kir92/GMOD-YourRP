

function allowedToUseDoor( id, ply )
  if ply:IsSuperAdmin() or ply:IsAdmin() then
    return true
  else
    local _tmpBuildingTable = dbSelect( "yrp_" .. string.lower( game.GetMap() ) .. "_buildings", "*", "uniqueID = '" .. id .. "'" )
    //PrintTable(_tmpBuildingTable)
    if _tmpBuildingTable[1] != nil then

      if tostring( _tmpBuildingTable[1].ownerSteamID ) == "" and tonumber( _tmpBuildingTable[1].groupID ) == -1 then
        return true
      else
        local _tmpPlyTable = dbSelect( "yrp_players", "*", "SteamID = '" .. ply:SteamID() .. "'" )
        local _tmpRoleTable = dbSelect( "yrp_roles", "*", "uniqueID = " .. _tmpPlyTable[1].roleID )
        local _tmpGroupTable = dbSelect( "yrp_groups", "*", "uniqueID = " .. _tmpRoleTable[1].groupID )

        //PrintTable(_tmpGroupTable)
        if tostring( _tmpBuildingTable[1].ownerSteamID ) == tostring( ply:SteamID() ) or tonumber( _tmpBuildingTable[1].groupID ) == tonumber( _tmpGroupTable[1].uniqueID ) then
          return true
        else
          return false
        end
      end
    else
      return false
    end
  end
end

function addKeys( ply )
  if ply:IsPlayer() then
    for k, v in pairs( ply:GetWeapons() ) do
      if v.ClassName == "yrp_key" then
        local _tmpTable = dbSelect( "yrp_players", "keynrs", "SteamID = '" .. ply:SteamID() .. "'" )
        _tmpTable = string.Explode( ",", _tmpTable[1].keynrs )
        for l, w in pairs( _tmpTable ) do
          if w != nil and w != "" then
            v:AddKeyNr( w )
          end
        end
      end
      break
    end
  end
end

function loadDoors()
  printGM( "note", "loadDoors start!")
  local _allPropDoors = ents.FindByClass( "prop_door_rotating" )
  local _tmpDoors = dbSelect( "yrp_" .. string.lower( game.GetMap() ) .. "_doors", "*", nil )
  for k, v in pairs( _allPropDoors ) do
    v:SetNWInt( "buildingID", tonumber( _tmpDoors[k].buildingID ) )
    v:SetNWInt( "uniqueID", k )
  end

  local _tmpBuildings = dbSelect( "yrp_" .. string.lower( game.GetMap() ) .. "_buildings", "*", nil )
  for k, v in pairs( _allPropDoors ) do
    for l, w in pairs( _tmpBuildings ) do
      if tonumber( w.uniqueID ) == tonumber( v:GetNWInt( "buildingID" ) ) then
        if w.ownerSteamID != "" then

          local _tmpRPName = dbSelect( "yrp_players", "*", "SteamID = '" .. w.ownerSteamID .. "'" )
          if _tmpRPName[1].nameSur != nil then
            v:SetNWString( "owner", _tmpRPName[1].nameSur .. ", " .. _tmpRPName[1].nameFirst )
          end
        else
          if tonumber( w.groupID ) != -1 then
            local _tmpGroupName = dbSelect( "yrp_groups", "groupID", "uniqueID = " .. w.groupID )
            v:SetNWString( "ownerGroup", tostring( _tmpGroupName[1].groupID ) )
          end
        end
        break
      end
    end
  end

  printGM( "note", "loadDoors complete!")
end

function addMapDoors()
  local _tmpTable = dbSelect( "yrp_" .. string.lower( game.GetMap() ) .. "_doors", "*", nil )
  local _tmpTable2 = dbSelect( "yrp_" .. string.lower( game.GetMap() ) .. "_buildings", "*", nil )
  if _tmpTable != nil and _tmpTable2 != nil then
    if #_tmpTable == 0 or #_tmpTable2 == 0 then
      printGM( "db", "NO doors found! Looking for them" )
      local _allPropDoors = ents.FindByClass( "prop_door_rotating" )
      for k, v in pairs( _allPropDoors ) do
        dbInsertIntoDEFAULTVALUES( "yrp_" .. string.lower( game.GetMap() ) .. "_buildings" )

        local _tmpBuildingTable = dbSelect( "yrp_" .. string.lower( game.GetMap() ) .. "_buildings", "*", nil )
        dbInsertInto( "yrp_" .. string.lower( game.GetMap() ) .. "_doors", "buildingID", "" .. _tmpBuildingTable[#_tmpBuildingTable].uniqueID .. "" )

        local _tmpDoorsTable = dbSelect( "yrp_" .. string.lower( game.GetMap() ) .. "_doors", "*", nil )
      end
      printGM( "db", "Done finding them (" .. #_allPropDoors .. " found)" )
    else
      printGM( "db", "yrp_" .. string.lower( game.GetMap() ) .. "_doors: found Doors" )
    end
  else
    printGM( "note", "doors or building nil" )
  end

  //load Doors
  loadDoors()
end
