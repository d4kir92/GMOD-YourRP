--Copyright (C) 2017-2021 Arno Zura (https://www.gnu.org/licenses/gpl.txt)

-- DO NOT TOUCH THE DATABASE FILES! If you have errors, report them here:
-- https://discord.gg/sEgNZxg

local DATABASE_NAME = "yrp_levelsystem"

SQL_ADD_COLUMN(DATABASE_NAME, "int_level_min", "INT DEFAULT 0")
SQL_ADD_COLUMN(DATABASE_NAME, "int_level_max", "INT DEFAULT 100")
SQL_ADD_COLUMN(DATABASE_NAME, "int_level_start", "INT DEFAULT 1")
SQL_ADD_COLUMN(DATABASE_NAME, "int_xp_for_levelup", "INT DEFAULT 100")
SQL_ADD_COLUMN(DATABASE_NAME, "float_multiplier", "INT DEFAULT 1.5")

SQL_ADD_COLUMN(DATABASE_NAME, "int_xp_per_kill", "INT DEFAULT 20")
SQL_ADD_COLUMN(DATABASE_NAME, "int_xp_per_minute", "INT DEFAULT 10")
SQL_ADD_COLUMN(DATABASE_NAME, "int_xp_per_revive", "INT DEFAULT 30")

if SQL_SELECT(DATABASE_NAME, "*", "uniqueID = 1") == nil then
	SQL_INSERT_INTO(DATABASE_NAME, "uniqueID", "'1'")
end

--[[ LOADOUT ]]--
local Player = FindMetaTable("Player")
function Player:LevelSystemLoadout()
	local setting = SQL_SELECT(DATABASE_NAME, "*", "uniqueID = '1'")
	if wk(setting) then
		setting = setting[1]
		self:SetNW2String("int_level_min", setting.int_level_min)
		self:SetNW2String("int_level_max", setting.int_level_max)
	end
end

util.AddNetworkString("get_levelsystem_settings")
net.Receive("get_levelsystem_settings", function(len, ply)
	if ply:CanAccess("bool_levelsystem") then

		local setting = SQL_SELECT(DATABASE_NAME, "*", "uniqueID = '1'")
		if wk(setting) then
			setting = setting[1]
			net.Start("get_levelsystem_settings")
				net.WriteTable(setting)
			net.Send(ply)
		end
	end
end)

local yrp_levelsystem = SQL_SELECT(DATABASE_NAME, "*", "uniqueID = '1'")
if wk(yrp_levelsystem) then
	yrp_levelsystem = yrp_levelsystem[1]

	function YRP.XPPerMinute()
		return tonumber(yrp_levelsystem.int_xp_per_minute)
	end
end

util.AddNetworkString("update_ls_int_level_min")
net.Receive("update_ls_int_level_min", function(len, ply)
	yrp_levelsystem.int_level_min = net.ReadString()
	SQL_UPDATE(DATABASE_NAME, "int_level_min = '" .. yrp_levelsystem.int_level_min .. "'", "uniqueID = '1'")
end)

util.AddNetworkString("update_ls_int_level_max")
net.Receive("update_ls_int_level_max", function(len, ply)
	yrp_levelsystem.int_level_max = net.ReadString()
	SQL_UPDATE(DATABASE_NAME, "int_level_max = '" .. yrp_levelsystem.int_level_max .. "'", "uniqueID = '1'")
end)

util.AddNetworkString("update_ls_int_level_start")
net.Receive("update_ls_int_level_start", function(len, ply)
	yrp_levelsystem.int_level_start = net.ReadString()
	SQL_UPDATE(DATABASE_NAME, "int_level_start = '" .. yrp_levelsystem.int_level_start .. "'", "uniqueID = '1'")
end)

util.AddNetworkString("update_ls_float_multiplier")
net.Receive("update_ls_float_multiplier", function(len, ply)
	yrp_levelsystem.float_multiplier = net.ReadString()
	SQL_UPDATE(DATABASE_NAME, "float_multiplier = '" .. yrp_levelsystem.float_multiplier .. "'", "uniqueID = '1'")
end)

util.AddNetworkString("update_ls_int_xp_for_levelup")
net.Receive("update_ls_int_xp_for_levelup", function(len, ply)
	yrp_levelsystem.int_xp_for_levelup = net.ReadString()
	SQL_UPDATE(DATABASE_NAME, "int_xp_for_levelup = '" .. yrp_levelsystem.int_xp_for_levelup .. "'", "uniqueID = '1'")
end)



util.AddNetworkString("update_ls_int_xp_per_kill")
net.Receive("update_ls_int_xp_per_kill", function(len, ply)
	yrp_levelsystem.int_xp_per_kill = net.ReadString()
	SQL_UPDATE(DATABASE_NAME, "int_xp_per_kill = '" .. yrp_levelsystem.int_xp_per_kill .. "'", "uniqueID = '1'")
end)

util.AddNetworkString("update_ls_int_xp_per_minute")
net.Receive("update_ls_int_xp_per_minute", function(len, ply)
	yrp_levelsystem.int_xp_per_minute = net.ReadString()
	SQL_UPDATE(DATABASE_NAME, "int_xp_per_minute = '" .. yrp_levelsystem.int_xp_per_minute .. "'", "uniqueID = '1'")
end)

util.AddNetworkString("update_ls_int_xp_per_revive")
net.Receive("update_ls_int_xp_per_revive", function(len, ply)
	yrp_levelsystem.int_xp_per_revive = net.ReadString()
	SQL_UPDATE(DATABASE_NAME, "int_xp_per_revive = '" .. yrp_levelsystem.int_xp_per_revive .. "'", "uniqueID = '1'")
end)

function Player:ClearXP()
	if !self:Alive() then return end
	local charid = self:CharID()
	local result = SQL_UPDATE("yrp_characters", "int_xp = " .. "0", "uniqueID = '" .. charid .. "'")
	if result != nil then
		YRP.msg("error", "ClearXP FAILED #1: " .. tostring(result))
	else
		self:SetNW2Int("int_xp", 0)
	end
end

function Player:AddLevel(level)
	if !self:Alive() then return end
	local charid = self:CharID()
	local curlvl = self:Level()
	local minlvl = self:GetMinLevel()
	local maxlvl = self:GetMaxLevel()

	if charid <= 0 then
		YRP.msg("error", "AddLevel FAILED #3: charid <= 0: " .. tostring(charid))
		return
	end

	if level > 0 then
		level = level - 1
		local newlvl = curlvl + 1
		if newlvl <= maxlvl then

			local result = SQL_UPDATE("yrp_characters", "int_level = '" .. newlvl .. "'", "uniqueID = '" .. charid .. "'")
			if result != nil then
				YRP.msg("error", "AddLevel FAILED #1: " .. tostring(result))
			else
				self:SetNW2String("int_level", newlvl)
				self:AddLevel(level)
			end
		end
	elseif level < 0 then
		level = level + 1
		local newlvl = curlvl - 1
		if newlvl >= minlvl then

			local result = SQL_UPDATE("yrp_characters", "int_level = '" .. newlvl .. "'", "uniqueID = '" .. charid .. "'")
			if result != nil then
				YRP.msg("error", "AddLevel FAILED #2: " .. tostring(result))
			else
				self:SetNW2String("int_level", newlvl)
				self:AddLevel(level)
			end
		end
	end
end

function Player:SetLevel(level)
	if !self:Alive() then return end
	local curlvl = self:Level()
	self:ClearXP()
	self:AddLevel(level - curlvl)
end

function Player:AddXP(xp)
	if !self:Alive() then return end
	xp = tonumber(xp)
	local lvltab = SQL_SELECT(DATABASE_NAME, "*", "uniqueID = '1'")
	lvltab = lvltab[1]
	local chatab = self:GetChaTab()
	local charid = self:CharID()

	if wk(chatab) then
		local curxp = tonumber(chatab.int_xp)
		local lvl = tonumber(chatab.int_level)
		local lvlmulti = tonumber(lvltab.float_multiplier)
		local xpforlvl = tonumber(lvltab.int_xp_for_levelup)
		local maxxp = self:GetMaxXP()

		local curlvl = self:Level()
		local maxlvl = self:GetMaxLevel()

		if xp > 0 then
			local newxp = curxp + xp
			if curlvl < maxlvl then
				if newxp > maxxp then
					newxp = newxp - maxxp
					local result = SQL_UPDATE("yrp_characters", "int_xp = '" .. "0'", "uniqueID = '" .. charid .. "'")
					if result != nil then
						YRP.msg("error", "AddXP FAILED #1: " .. tostring(result))
					else
						self:AddLevel(1)
						self:AddXP(newxp)
					end
				else
					local result = SQL_UPDATE("yrp_characters", "int_xp = '" .. newxp .. "'", "uniqueID = '" .. charid .. "'")
					if result != nil then
						YRP.msg("error", "AddXP FAILED #2: " .. tostring(result))
					else
						self:SetNW2Int("int_xp", newxp)
					end
				end
			elseif curlvl > maxlvl then
				self:SetLevel(maxlvl)
			elseif newxp > maxxp then
				local result = SQL_UPDATE("yrp_characters", "int_xp = '" .. maxxp .. "'", "uniqueID = '" .. charid .. "'")
				if result != nil then
					YRP.msg("error", "AddXP FAILED #5: " .. tostring(result))
				else
					self:SetNW2Int("int_xp", maxxp)
				end
			else
				--YRP.msg("error", "AddXP ELSE " .. tostring(curlvl) .. " | " .. tostring(maxlvl) .. " | " .. tostring(newxp) .. " | " .. tostring(maxxp))
			end
		elseif xp < 0 then
			local newxp = curxp + xp
			if curlvl > 1 then
				if newxp < 0 then
					maxxp = math.Round(math.pow(lvl - 1, lvlmulti), 0) + xpforlvl
					newxp = newxp + maxxp

					local result = SQL_UPDATE("yrp_characters", "int_xp = '" .. "0'", "uniqueID = '" .. charid .. "'")
					if result != nil then
						YRP.msg("error", "AddXP FAILED #3: " .. tostring(result))
					else
						self:AddLevel(-1)
						self:AddXP(newxp)
					end
				else
					local result = SQL_UPDATE("yrp_characters", "int_xp = '" .. newxp .. "'", "uniqueID = '" .. charid .. "'")
					if result != nil then
						YRP.msg("error", "AddXP FAILED #4: " .. tostring(result))
					else
						self:SetNW2Int("int_xp", newxp)
					end
				end
			end
		end
	end
end

hook.Add("PlayerDeath", "yrp_xp_playerdeath", function(victim, inflictor, attacker)
	if attacker:IsPlayer() then
		local setting = SQL_SELECT(DATABASE_NAME, "*", "uniqueID = '1'")
		setting = setting[1]
		attacker:AddXP(setting.int_xp_per_kill)
	end
end)

hook.Add("OnNPCKilled", "yrp_xp_onnpckilled", function(npc, attacker, inflictor)
	if attacker:IsPlayer() then
		local setting = SQL_SELECT(DATABASE_NAME, "*", "uniqueID = '1'")
		setting = setting[1]
		attacker:AddXP(setting.int_xp_per_kill)
	end
end)
