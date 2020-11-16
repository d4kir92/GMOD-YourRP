--Copyright (C) 2017-2020 Arno Zura (https://www.gnu.org/licenses/gpl.txt)

-- DO NOT TOUCH THE DATABASE FILES! If you have errors, report them here:
-- https://discord.gg/sEgNZxg

local DATABASE_NAME_DOORS = "yrp_" .. GetMapNameDB() .. "_doors"
SQL_ADD_COLUMN(DATABASE_NAME_DOORS, "buildingID", "TEXT DEFAULT '-1'")
SQL_ADD_COLUMN(DATABASE_NAME_DOORS, "level", "INTEGER DEFAULT 1")
SQL_ADD_COLUMN(DATABASE_NAME_DOORS, "keynr", "INTEGER DEFAULT -1")

--db_drop_table(DATABASE_NAME_DOORS)
--db_is_empty(DATABASE_NAME_DOORS)

local DATABASE_NAME_BUILDINGS = "yrp_" .. GetMapNameDB() .. "_buildings"
SQL_ADD_COLUMN(DATABASE_NAME_BUILDINGS, "groupID", "INTEGER DEFAULT 0")
SQL_ADD_COLUMN(DATABASE_NAME_BUILDINGS, "buildingprice", "TEXT DEFAULT 100")
SQL_ADD_COLUMN(DATABASE_NAME_BUILDINGS, "ownerCharID", "TEXT DEFAULT ' '")
SQL_ADD_COLUMN(DATABASE_NAME_BUILDINGS, "name", "TEXT DEFAULT 'Building'")
SQL_ADD_COLUMN(DATABASE_NAME_BUILDINGS, "text_header", "TEXT DEFAULT ''")
SQL_ADD_COLUMN(DATABASE_NAME_BUILDINGS, "text_description", "TEXT DEFAULT ''")
SQL_ADD_COLUMN(DATABASE_NAME_BUILDINGS, "bool_canbeowned", "INT DEFAULT 1")
SQL_ADD_COLUMN(DATABASE_NAME_BUILDINGS, "int_securitylevel", "TEXT DEFAULT 0")

SQL_ADD_COLUMN(DATABASE_NAME_BUILDINGS, "bool_lockdown", "INT DEFAULT 1")

--db_drop_table(DATABASE_NAME_BUILDINGS)
--db_is_empty(DATABASE_NAME_BUILDINGS)

function IsUnderGroup(uid, tuid)
	local group = SQL_SELECT("yrp_ply_groups", "*", "uniqueID = '" .. uid .. "'")
	group = group[1]
	local undergroup = SQL_SELECT("yrp_ply_groups", "*", "uniqueID = '" .. group.int_parentgroup .. "'")
	if wk(undergroup) then
		undergroup = undergroup[1]
		if tonumber(undergroup.uniqueID) == tonumber(tuid) then
			return true
		else
			return IsUnderGroup(undergroup.uniqueID, tuid)
		end
	end
	return false
end

function IsUnderGroupOf(ply, uid)
	local ply_group = SQL_SELECT("yrp_ply_groups", "*", "uniqueID = '" .. ply:GetDString("groupUniqueID", "Failed") .. "'")
	if wk(ply_group) then
		ply_group = ply_group[1]
		local group = SQL_SELECT("yrp_ply_groups", "*", "uniqueID = '" .. ply_group.uniqueID .. "'")
		group = group[1]
		return IsUnderGroup(group.uniqueID, uid)
	else
		return false
	end
end

function allowedToUseDoor(id, ply, door)
	if ply:HasAccess() then
		return true
	else
		local _tmpBuildingTable = SQL_SELECT("yrp_" .. GetMapNameDB() .. "_buildings", "*", "uniqueID = '" .. id .. "'")
		if wk(_tmpBuildingTable) then
			local bui_cuid = _tmpBuildingTable[1].ownerCharID
			local bui_guid = _tmpBuildingTable[1].groupID
			if (tostring(bui_cuid) == "" or tostring(bui_cuid) == " ") and tonumber(_tmpBuildingTable[1].groupID) == -1 then
				return true
			else
				local _tmpChaTab = SQL_SELECT("yrp_characters", "*", "uniqueID = " .. bui_cuid)

				local removeowner = false
				if !wk(_tmpChaTab) then -- If char not available anymore => remove ownership
					SQL_UPDATE(DATABASE_NAME_BUILDINGS, "ownerCharID = '" .. "" .. "'", "uniqueID = '" .. id .. "'")
					
					door:SetDTable("owner", {})
					door:SetDString("ownerRPName", "")
					door:SetDInt("ownerGroupUID", -99)
					door:SetDString("ownerGroup", "")
					door:SetDString("ownerCharID", "")
					door:SetDBool("bool_hasowner", false)
					door:Fire("Unlock")
				else
					local grp_id = ply:GetGroupUID()

					if tostring(bui_cuid) == tostring(ply:CharID()) then
						return true
					elseif tonumber(bui_guid) == tonumber(grp_id) then
						return true
					elseif IsUnderGroupOf(ply, bui_guid) then
						return true
					else
						YRP.msg("note", "[allowedToUseDoor] not allowed")
						return false
					end
					return false
				end
			end
		else
			YRP.msg("note", "[allowedToUseDoor] not allowed 2")
			return false
		end
	end
end

function searchForDoors()
	YRP.msg("db", "[Buildings] Search Map for Doors")

	for k, v in pairs(GetAllDoors()) do
		SQL_INSERT_INTO_DEFAULTVALUES("yrp_" .. GetMapNameDB() .. "_buildings")

		local _tmpBuildingTable = SQL_SELECT("yrp_" .. GetMapNameDB() .. "_buildings", "*", nil)
		if wk(_tmpBuildingTable) then
			SQL_INSERT_INTO("yrp_" .. GetMapNameDB() .. "_doors", "buildingID", "'" .. _tmpBuildingTable[table.Count(_tmpBuildingTable)].uniqueID .. "'")

			local _tmpDoorsTable = SQL_SELECT("yrp_" .. GetMapNameDB() .. "_doors", "*", nil)
		end
	end

	local allDoorsNum = table.Count(GetAllDoors())
	YRP.msg("db", "[Buildings] Done finding them (" .. allDoorsNum .. " doors found)")
	return allDoorsNum
end

util.AddNetworkString("loaded_doors")
function loadDoors()
	YRP.msg("db", "[Buildings] Setting up Doors!")
	local _tmpDoors = SQL_SELECT("yrp_" .. GetMapNameDB() .. "_doors", "*", nil)

	if wk(_tmpDoors) then
		for i, door in pairs(GetAllDoors()) do
			if worked(_tmpDoors[i], "loadDoors 2") then
				door:SetDString("buildingID", _tmpDoors[i].buildingID)
				door:SetDString("uniqueID", i)
				HasUseFunction(door)
			else
				YRP.msg("note", "[Buildings] more doors, then in list!")
			end
		end
	end

	local _tmpBuildings = SQL_SELECT("yrp_" .. GetMapNameDB() .. "_buildings", "*", nil)
	if wk(_tmpBuildings) then
		for k, v in pairs(GetAllDoors()) do
			for l, w in pairs(_tmpBuildings) do
				if tonumber(w.uniqueID) == tonumber(v:GetDString("buildingID")) then
					v:SetDBool("bool_canbeowned", w.bool_canbeowned)
					v:SetDTable("building", w)
					v:SetDBool("bool_hasowner", false)
					if !strEmpty(w.ownerCharID) then
						local tabChar = SQL_SELECT("yrp_characters", "*", "uniqueID = " .. w.ownerCharID)
						if wk(tabChar) then
							tabChar = tabChar[1]
							if wk(tabChar.rpname) then
								v:SetDTable("owner", tabChar)
								v:SetDString("ownerRPName", SQL_STR_OUT(tabChar.rpname))
								v:SetDString("ownerCharID", w.ownerCharID)
								v:SetDBool("bool_hasowner", true)
							end
						end
					else
						if tonumber(w.groupID) != 0 then
							local _tmpGroupName = SQL_SELECT("yrp_ply_groups", "uniqueID, string_name", "uniqueID = " .. w.groupID)
							if wk(_tmpGroupName) then
								_tmpGroupName = _tmpGroupName[1]
								if wk(_tmpGroupName) then
									v:SetDInt("ownerGroupUID", _tmpGroupName.uniqueID)
									v:SetDString("ownerGroup", tostring(_tmpGroupName.string_name))
									v:SetDBool("bool_hasowner", true)
								end
							end
						end
					end

					w.int_securitylevel = tonumber(w.int_securitylevel)
					if w.int_securitylevel > 0 then
						v:SetDInt("int_securitylevel", w.int_securitylevel)
					end

					--[[v:Fire("Open")
					timer.Simple(10, function()
						v:Fire("Close")
					end)]]
					if v:GetDInt("int_securitylevel", 0) > 0 then
						v:Fire("Lock")
					else
						v:Fire("Unlock")
					end

					if !strEmpty(w.text_header) then
						v:SetDString("text_header", w.text_header)
					end
					if !strEmpty(w.text_description) then
						v:SetDString("text_description", w.text_description)
					end

					break
				end
			end
		end
	end

	YRP.msg("db", "[Buildings] Map Doors are now available!")
	SetGlobalDBool("loaded_doors", true)
	net.Start("loaded_doors")
	net.Broadcast()
end

function check_map_doors()
	YRP.msg("db", "[Buildings] Get Database Doors and Buildings")
	local _tmpTable = SQL_SELECT("yrp_" .. GetMapNameDB() .. "_doors", "*", nil)
	local _tmpTable2 = SQL_SELECT("yrp_" .. GetMapNameDB() .. "_buildings", "*", nil)
	if wk(_tmpTable) and wk(_tmpTable2) then
		YRP.msg("db", "[Buildings] Found! (" .. tostring(table.Count(_tmpTable)) .. " Doors | " .. tostring(table.Count(_tmpTable)) .. " Buildings)")
		local doors = GetAllDoors()
		if (table.Count(_tmpTable)) < (table.Count(doors)) then
			YRP.msg("db", "[Buildings] New doors found!")
			searchForDoors()
		end
	else
		searchForDoors()
	end

	loadDoors()
end

util.AddNetworkString("getBuildingInfo")
util.AddNetworkString("getBuildings")
util.AddNetworkString("changeBuildingName")
util.AddNetworkString("changeBuildingID")
util.AddNetworkString("changeBuildingPrice")
util.AddNetworkString("changeBuildingSL")

util.AddNetworkString("changeBuildingHeader")
util.AddNetworkString("changeBuildingDescription")

util.AddNetworkString("getBuildingGroups")

util.AddNetworkString("setBuildingOwnerGroup")

util.AddNetworkString("buyBuilding")
util.AddNetworkString("removeOwner")
util.AddNetworkString("sellBuilding")

util.AddNetworkString("lockDoor")

util.AddNetworkString("addnewbuilding")
net.Receive("addnewbuilding", function()
	SQL_INSERT_INTO_DEFAULTVALUES("yrp_" .. GetMapNameDB() .. "_buildings")
end)

function unlockDoor(ply, ent, nr)
	if canLock(ply, ent) then
		ent:Fire("Unlock")
		return true
	end
	return false
end

function lockDoor(ply, ent, nr)
	if canLock(ply, ent) then
		ent:Fire("Lock")
		return true
	end
	return false
end

function openDoor(ply, ent, nr)
	local _tmpBuildingTable = SQL_SELECT("yrp_" .. GetMapNameDB() .. "_buildings", "*", "uniqueID = '" .. ent:GetDString("buildingID", "-1") .. "'")
	if wk(_tmpBuildingTable) then
		_tmpBuildingTable = _tmpBuildingTable[1]
		_tmpBuildingTable.bool_canbeowned = tonumber(_tmpBuildingTable.bool_canbeowned)
		_tmpBuildingTable.groupID = tonumber(_tmpBuildingTable.groupID)

		if canLock(ply, ent) then
			ent:Fire("Toggle")
		elseif _tmpBuildingTable.bool_canbeowned == 0 or _tmpBuildingTable.groupID == -1 then
			_tmpBuildingTable.int_securitylevel = tonumber(_tmpBuildingTable.int_securitylevel)
			if ply:GetDInt("int_securitylevel", 0) >= _tmpBuildingTable.int_securitylevel and ply:HasWeapon("yrp_idcard") then
				local locked = ent:GetSaveTable().m_bLocked
				if locked then
					ent:Fire("Unlock")
				end
				ent:Fire("Toggle")
				if locked then
					ent:Fire("Lock")
				end
			else
				--YRP.msg("note", "Building: NOT ALLOWED TO OPEN")
				local filename = "doors/default_locked.wav"
				util.PrecacheSound(filename)
				ent:EmitSound(filename, 75, 100, 1, CHAN_AUTO )
			end
		else
			YRP.msg("note", "Building must be not ownable or PUBLIC")
		end
	else
		YRP.msg("note", "Building not found!")
	end
end

function BuildingRemoveOwner(SteamID)
	YRP.msg("db", "BuildingRemoveOwner(" .. tostring(SteamID) .. ")")
	local chars = SQL_SELECT("yrp_characters", "*", "SteamID = '" .. SteamID .. "'")

	if wk(chars) then
		for i, c in pairs(chars) do
			local charid = c.uniqueID
			for k, v in pairs(GetAllDoors()) do
				if v:GetDString("ownerCharID") == charid then
					v:SetDTable("owner", {})
					v:SetDString("ownerRPName", "")
					v:SetDInt("ownerGroupUID", -99)
					v:SetDString("ownerGroup", "")
					v:SetDString("ownerCharID", "")
					v:SetDBool("bool_hasowner", false)
					v:Fire("Unlock")
					SQL_UPDATE("yrp_" .. GetMapNameDB() .. "_buildings", "ownerCharID = ''", "uniqueID = '" .. v:GetDString("uniqueID") .. "'")
				end
			end
		end
	end
end

net.Receive("removeOwner", function(len, ply)
	local _tmpBuildingID = net.ReadString()
	local _tmpTable = SQL_SELECT("yrp_" .. GetMapNameDB() .. "_buildings", "*", "uniqueID = '" .. _tmpBuildingID .. "'")

	SQL_UPDATE("yrp_" .. GetMapNameDB() .. "_buildings", "ownerCharID = '', groupID = 0", "uniqueID = '" .. _tmpBuildingID .. "'")

	for k, v in pairs(GetAllDoors()) do
		if tonumber(v:GetDString("buildingID")) == tonumber(_tmpBuildingID) then
			v:SetDTable("owner", {})
			v:SetDString("ownerRPName", "")
			v:SetDInt("ownerGroupUID", -99)
			v:SetDString("ownerGroup", "")
			v:SetDString("ownerCharID", "")
			v:SetDBool("bool_hasowner", false)
			v:Fire("Unlock")
		end
	end
end)

net.Receive("sellBuilding", function(len, ply)
	local _tmpBuildingID = net.ReadString()
	local _tmpTable = SQL_SELECT("yrp_" .. GetMapNameDB() .. "_buildings", "*", "uniqueID = '" .. _tmpBuildingID .. "'")

	SQL_UPDATE("yrp_" .. GetMapNameDB() .. "_buildings", "ownerCharID = '', groupID = 0", "uniqueID = '" .. _tmpBuildingID .. "'")

	for k, v in pairs(GetAllDoors()) do
		if tonumber(v:GetDString("buildingID")) == tonumber(_tmpBuildingID) then
			v:SetDTable("owner", {})
			v:SetDString("ownerRPName", "")
			v:SetDInt("ownerGroupUID", -99)
			v:SetDString("ownerGroup", "")
			v:SetDString("ownerCharID", "")
			v:SetDBool("bool_hasowner", false)
			v:Fire("Unlock")
			SQL_UPDATE("yrp_" .. GetMapNameDB() .. "_doors", "keynr = -1", "buildingID = " .. tonumber(v:GetDString("buildingID")))
		end
	end

	ply:addMoney(_tmpTable[1].buildingprice / 2)
end)

net.Receive("buyBuilding", function(len, ply)
	if GetGlobalDBool("bool_building_system", false) then
		local _tmpBuildingID = net.ReadString()
		local _tmpTable = SQL_SELECT("yrp_" .. GetMapNameDB() .. "_buildings", "*", "uniqueID = '" .. _tmpBuildingID .. "'")

		if ply:canAfford(_tmpTable[1].buildingprice) then
			if (_tmpTable[1].ownerCharID == "" or _tmpTable[1].ownerCharID == " ") and tonumber(_tmpTable[1].groupID) <= 0 then
				ply:addMoney(- _tmpTable[1].buildingprice)
				SQL_UPDATE("yrp_" .. GetMapNameDB() .. "_buildings", "ownerCharID = '" .. ply:CharID() .. "'", "uniqueID = '" .. _tmpBuildingID .. "'")
				local tabChar = SQL_SELECT("yrp_characters", "rpname", "uniqueID = " .. ply:CharID())
				if wk(tabChar) then
					tabChar = tabChar[1]
				end
				for k, v in pairs(GetAllDoors()) do
					if tonumber(v:GetDString("buildingID")) == tonumber(_tmpBuildingID) then
						v:SetDTable("owner", tabChar)
						v:SetDString("ownerRPName", SQL_STR_OUT(tabChar.rpname))
						v:SetDString("ownerCharID", ply:CharID())
						v:SetDBool("bool_hasowner", true)
					end
				end
				YRP.msg("gm", ply:RPName() .. " has buyed a door")
			else
				YRP.msg("gm", ply:RPName() .. " has already an owner!")
			end
		else
			YRP.msg("gm", ply:RPName() .. " has not enough money to buy door")
		end
	else
		YRP.msg("note", "buildings disabled")
	end
end)

net.Receive("setBuildingOwnerGroup", function(len, ply)
	local _tmpBuildingID = net.ReadString()
	local _tmpGroupID = net.ReadInt(32)

	SQL_UPDATE("yrp_" .. GetMapNameDB() .. "_buildings", "groupID = " .. _tmpGroupID, "uniqueID = " .. _tmpBuildingID)

	local _tmpGroupName = SQL_SELECT("yrp_ply_groups", "uniqueID, string_name", "uniqueID = " .. _tmpGroupID)
	if wk(_tmpGroupName) then
		for k, v in pairs(GetAllDoors()) do
			if tonumber(v:GetDString("buildingID")) == tonumber(_tmpBuildingID) then
				v:SetDInt("ownerGroupUID", _tmpGroupName[1].uniqueID)
				v:SetDString("ownerGroup", _tmpGroupName[1].string_name)
				v:SetDBool("bool_hasowner", true)
			end
		end
	end
end)

net.Receive("getBuildingGroups", function(len, ply)
	local _tmpTable = SQL_SELECT("yrp_ply_groups", "*", nil)

	net.Start("getBuildingGroups")
		net.WriteTable(_tmpTable)
	net.Send(ply)
end)

net.Receive("changeBuildingPrice", function(len, ply)
	local _tmpBuildingID = net.ReadString()
	local _tmpNewPrice = net.ReadString()
	_tmpNewPrice = tonumber(_tmpNewPrice) or 99

	local _result = SQL_UPDATE("yrp_" .. GetMapNameDB() .. "_buildings", "buildingprice = " .. _tmpNewPrice , "uniqueID = " .. _tmpBuildingID)
end)

function SetSecurityLevel(id, sl)
	for i, door in pairs(GetAllDoors()) do
		if door:GetDString("buildingID", -1) == id then
			door:SetDInt("int_securitylevel", sl)
			if door:GetDInt("int_securitylevel", 0) > 0 then
				door:Fire("Lock")
			else
				door:Fire("Unlock")
			end
		end
	end
end

net.Receive("changeBuildingSL", function(len, ply)
	local _tmpBuildingID = net.ReadString()
	local _tmpNewSL = net.ReadString()
	_tmpNewSL = tonumber(_tmpNewSL) or 0

	local _result = SQL_UPDATE("yrp_" .. GetMapNameDB() .. "_buildings", "int_securitylevel = " .. _tmpNewSL , "uniqueID = " .. _tmpBuildingID)
	SetSecurityLevel(_tmpBuildingID, _tmpNewSL)
end)

util.AddNetworkString("CanBuildingBeOwned")
net.Receive("CanBuildingBeOwned", function(len, ply)
	local _tmpBuildingID = net.ReadString()
	local _canbeowned = tonum(net.ReadBool())

	SQL_UPDATE("yrp_" .. GetMapNameDB() .. "_buildings", "bool_canbeowned = '" .. _canbeowned .. "'", "uniqueID = " .. _tmpBuildingID)

	ChangeBuildingBool(tonumber(_tmpBuildingID), "bool_canbeowned", _canbeowned)
end)


function hasDoors(id)
	local _allDoors = SQL_SELECT("yrp_" .. GetMapNameDB() .. "_doors", "*", nil)
	for k, v in pairs(_allDoors) do
		if tonumber(v.buildingID) == tonumber(id) then
			return true
		end
	end
	return false
end

function lookForEmptyBuildings()
	local _allBuildings = SQL_SELECT("yrp_" .. GetMapNameDB() .. "_buildings", "*", nil)
	if wk(_allBuildings) then
		for k, v in pairs(_allBuildings) do
			if !hasDoors(v.uniqueID) then
				SQL_DELETE_FROM("yrp_" .. GetMapNameDB() .. "_buildings", "uniqueID = " .. tonumber(v.uniqueID))
			end
		end
	end
end
lookForEmptyBuildings()

net.Receive("changeBuildingID", function(len, ply)
	local _tmpDoor = net.ReadEntity()
	local _tmpBuildingID = net.ReadString()

	_tmpDoor:SetDString("buildingID", _tmpBuildingID)
	SQL_UPDATE("yrp_" .. GetMapNameDB() .. "_doors", "buildingID = " .. tonumber(_tmpBuildingID) , "uniqueID = " .. _tmpDoor:GetDString("uniqueID"))

	lookForEmptyBuildings()
end)

net.Receive("changeBuildingName", function(len, ply)
	local _tmpBuildingID = net.ReadString()
	local _tmpNewName = net.ReadString()
	if wk(_tmpBuildingID) then
		YRP.msg("note", "renamed Building: " .. _tmpNewName)
		SQL_UPDATE("yrp_" .. GetMapNameDB() .. "_buildings", "name = '" .. SQL_STR_IN(_tmpNewName) .. "'" , "uniqueID = " .. _tmpBuildingID)
	else
		YRP.msg("note", "changeBuildingName failed")
	end
end)

function ChangeBuildingString(uid, net_str, new_str)
	for i, v in pairs(GetAllDoors()) do
		if uid == tonumber(v:GetDString("buildingID")) then
			v:SetDString(net_str, new_str)
		end
	end
end

function ChangeBuildingBool(uid, net_str, new_boo)
	local tabBuilding = SQL_SELECT(DATABASE_NAME_BUILDINGS, "*", "uniqueID = '" .. uid .. "'")
	if wk(tabBuilding) then
		tabBuilding = tabBuilding[1]
	else
		tabBuilding = {}
	end
	for i, v in pairs(GetAllDoors()) do
		if uid == tonumber(v:GetDString("buildingID")) then
			v:SetDBool(net_str, new_boo)
			v:SetDTable("building", tabBuilding)
		end
	end
end

net.Receive("changeBuildingHeader", function(len, ply)
	local _tmpBuildingID = net.ReadString()
	local _tmpNewName = net.ReadString()
	if wk(_tmpBuildingID) then
		YRP.msg("note", "header Building: " .. _tmpNewName)
		SQL_UPDATE("yrp_" .. GetMapNameDB() .. "_buildings", "text_header = '" .. SQL_STR_IN(_tmpNewName) .. "'" , "uniqueID = " .. _tmpBuildingID)
		ChangeBuildingString(tonumber(_tmpBuildingID), "text_header", _tmpNewName)
	else
		YRP.msg("note", "changeBuildingName failed")
	end
end)

net.Receive("changeBuildingDescription", function(len, ply)
	local _tmpBuildingID = net.ReadString()
	local _tmpNewName = net.ReadString()
	if wk(_tmpBuildingID) then
		YRP.msg("note", "description Building: " .. _tmpNewName)
		SQL_UPDATE("yrp_" .. GetMapNameDB() .. "_buildings", "text_description = '" .. SQL_STR_IN(_tmpNewName) .. "'" , "uniqueID = " .. _tmpBuildingID)
		ChangeBuildingString(tonumber(_tmpBuildingID), "text_description", _tmpNewName)
	else
		YRP.msg("note", "changeBuildingName failed")
	end
end)

function GetDoors()
	local _tmpTable = SQL_SELECT("yrp_" .. GetMapNameDB() .. "_buildings", "name, uniqueID", "name != 'Building'")

	if wk(_tmpTable) then
		for k, building in pairs(_tmpTable) do
			local _doors = 0
			_tmpDoors = ents.FindByClass("prop_door_rotating")
			for j, d in pairs(_tmpDoors) do
				if tonumber(d:GetDString("buildingID", "-1")) == tonumber(building.uniqueID) then
					_doors = _doors + 1
				end
			end
			_tmpFDoors = ents.FindByClass("func_door")
			for j, d in pairs(_tmpFDoors) do
				if tonumber(d:GetDString("buildingID", "-1")) == tonumber(building.uniqueID) then
					_doors = _doors + 1
				end
			end
			_tmpFRDoors = ents.FindByClass("func_door_rotating")
			for j, d in pairs(_tmpFRDoors) do
				if tonumber(d:GetDString("buildingID", "-1")) == tonumber(building.uniqueID) then
					_doors = _doors + 1
				end
			end

			building.name = SQL_STR_OUT(building.name)
			building.doors = _doors
		end
	end
	if !wk(_tmpTable) then
		_tmpTable = {}
	end

	return _tmpTable
end

net.Receive("getBuildings", function(len, ply)
	local doors = GetDoors()

	net.Start("getBuildings")
		net.WriteTable(doors)
	net.Send(ply)
end)

function SendBuildingInfo(ply, ent, tab)
	local t = tab or {}
	if net.BytesLeft() == nil and net.BytesWritten() == nil then
		net.Start("getBuildingInfo")
			net.WriteEntity(ent)
			net.WriteTable(t)
		net.Send(ply)
	else
		timer.Simple(0.1, function()
			SendBuildingInfo(ply, ent, t)
		end)
	end
end

net.Receive("getBuildingInfo", function(len, ply)
	local door = net.ReadEntity()
	local buid = door:GetDString("buildingID")

	local tabBuilding = {}
	local tabOwner = {}
	local tabGroup = {}
	if wk(buid) and buid != "nil" then
		tabBuilding = SQL_SELECT("yrp_" .. GetMapNameDB() .. "_buildings", "*", "uniqueID = '" .. buid .. "'")
		--local owner = ""
		if wk(tabBuilding) then
			tabBuilding = tabBuilding[1]
			tabBuilding.name = SQL_STR_OUT(tabBuilding.name)
			tabBuilding.groupID = tonumber(tabBuilding.groupID)
			if !strEmpty(tabBuilding.ownerCharID) then
				tabOwner = SQL_SELECT("yrp_characters", "*", "uniqueID = '" .. tabBuilding.ownerCharID .. "'")
				if wk(tabOwner) then
					tabOwner = tabOwner[1]
					--owner = tabOwner.rpname
				else
					YRP.msg("note", "[getBuildingInfo] owner dont exists.")
					tabOwner = {}
				end
			elseif tabBuilding.groupID != 0 then
				tabGroup = SQL_SELECT("yrp_ply_groups", "*", "uniqueID = '" .. tabBuilding.groupID .. "'")
				if wk(tabGroup) then
					tabGroup = tabGroup[1]
					--owner = _tmpGroTab.string_name
				else
					local test = SQL_UPDATE("yrp_" .. GetMapNameDB() .. "_buildings", "groupID = '0'", "uniqueID = '" .. buid .. "'")

					YRP.msg("note", "[getBuildingInfo] group dont exists.")
					tabGroup = {}
				end
			end
			
			local tab = {}
			tab["B"] = tabBuilding
			tab["O"] = tabOwner
			tab["G"] = tabGroup

			SendBuildingInfo(ply, door, tab)
		else
			YRP.msg("note", "getBuildingInfo -> Building not found in Database.")
		end
	else
		YRP.msg("note", "getBuildingInfo -> BuildingID is not valid")
	end
end)

util.AddNetworkString("update_lockdown_buildings")
net.Receive("update_lockdown_buildings", function(len, ply)
	local buid = net.ReadString()
	local checked = net.ReadBool()

	SQL_UPDATE(DATABASE_NAME_BUILDINGS, "bool_lockdown = '" .. tonum(checked) .. "'", "uniqueID = '" .. buid .. "'")
end)
