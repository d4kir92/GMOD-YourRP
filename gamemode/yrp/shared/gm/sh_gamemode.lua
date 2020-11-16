--Copyright (C) 2017-2020 Arno Zura (https://www.gnu.org/licenses/gpl.txt)

--here you can change this, but it's dumb, because you can change it ingame
GM.Name = "DarkRP" -- Is for other addons detecting that the gamemode is "DarkRP" compatible
GM.BaseName = "YourRP" -- DO NOT CHANGE THIS, thanks

DeriveGamemode("sandbox")

-- >>> do NOT change this! (it can cause crashes and more!) <<<
GM.ShortName = "YRP" --do NOT change this!
GM.Author = "D4KiR" --do NOT change this!
GM.Discord = "https://discord.gg/sEgNZxg" --do NOT change this!
GM.Email = GM.Discord --do NOT change this!
GM.Website = "https://sites.google.com/view/yrp" --do NOT change this!
GM.Youtube = "youtube.com/c/D4KiR" --do NOT change this!
GM.Twitter = "twitter.com/D4KIR" --do NOT change this!
GM.Help = "Create your rp you want to make!" --do NOT change this!
GM.dedicated = "-" --do NOT change this!
GM.VersionStable = 0 --do NOT change this!
GM.VersionBeta = 323 --do NOT change this!
GM.VersionCanary = 650 --do NOT change this!
GM.Version = GM.VersionStable .. "." .. GM.VersionBeta .. "." .. GM.VersionCanary --do NOT change this!
GM.VersionSort = "outdated" --do NOT change this! --stable, beta, canary
GM.rpbase = "YourRP" --do NOT change this! <- this is not for server browser
GM.ServerIsDedicated = game.IsDedicated()

function GetRPBase()
	return GAMEMODE.rpbase
end

function GetBranch()
	local branch = jit.arch
	branch = string.Replace(branch, "x64", "64Bit")
	branch = string.Replace(branch, "x86", "32Bit")
	return branch
end

VERSIONART = "github"
for i, wsi in pairs(engine.GetAddons()) do
	if tostring(wsi.wsid) == "1114204152" then
		VERSIONART = "workshop"
	end
end
GM.Art = VERSIONART

function ChangeChannel(channel)
	if channel == "stable" or channel == "beta" or channel == "canary" then
		GAMEMODE.VersionSort = channel
		YRP.msg("gm", "Switched to " .. tostring(channel))
	else
		YRP.msg("error", "Switched to not available channel (" .. tostring(channel) .. ")")
	end
end

function GM:Initialize()
	self.BaseClass.Initialize(self)
end

function GM:GetGameDescription()
	return GAMEMODE.BaseName
end

function GetNiceMapName()
	local map = game.GetMap()
	local _first = string.find(map, "_", 1, false)
	if _first != nil then
		map = string.sub(map, _first + 1)
	end
	map = string.Explode("_", map)
	local _new_map = {}
	for i, str in pairs(map) do
		local _tab = string.Explode("", str)
		local _insert = true
		for j, char in pairs(_tab) do
			if isnumber(tonumber(char)) then
				_insert = false
				break
			end
		end
		if _insert then
			table.insert(_new_map, str)
		end
	end
	map = string.Implode(" ", _new_map)
	return string.upper(map)
end

function GetMapName()
	return game.GetMap()
end

function GetMapNameDB()
	local mapname = game.GetMap()
	mapname = string.Replace(mapname, "-", "_")
	mapname = string.Replace(mapname, " ", "_")
	return string.lower(mapname)
end

function StringToColor(str)
	local _col = string.Explode(",", str)

	return Color(_col[1], _col[2], _col[3], _col[4] or 255)
end

function StringToVector(str)
	local color = StringToColor(str)
	return Vector( color.r / 255, color.g / 255, color.b / 255 )
end

concommand.Add("yrp_version", function(ply, cmd, args)
	hr_pre("gm")
	local _text = "Gamemode - Version:\t" .. GAMEMODE.Version .. " (" .. string.upper(GAMEMODE.VersionSort) .. ")"
	YRP.msg("gm", _text)
	hr_pos("gm")
end)

concommand.Add("yrp_status", function(ply, cmd, args)
	local _text = "Gamemode - Version:\t" .. GAMEMODE.Version
	if IsYRPOutdated() == nil then
		_text = _text .. " (Checking)"
	elseif IsYRPOutdated() then
		_text = _text .. " (OUTDATED!)"
	end

	hr_pre("gm")
	YRP.msg("gm", "    Version: " .. GAMEMODE.Version)
	YRP.msg("gm", "    Channel: " .. string.upper(GAMEMODE.VersionSort))
	YRP.msg("gm", " Servername: " .. GetHostName())
	YRP.msg("gm", "         IP: " .. game.GetIPAddress())
	YRP.msg("gm", "        Map: " .. GetMapNameDB())
	YRP.msg("gm", "    Players: " .. tostring(player.GetCount()) .. "/" .. tostring(game.MaxPlayers()))
	hr_pos("gm")
end)

concommand.Add("yrp_maps", function(ply, cmd, args)
	hr_pre("gm")
	YRP.msg("gm", "[MAPS ON SERVER]")
	local allmaps = file.Find("maps/*.bsp", "GAME", "nameasc")
	for i, map in pairs(allmaps) do
		local mapname = string.Replace(map, ".bsp", "")
		YRP.msg("gm", i .. "\t" .. mapname)
	end
	hr_pos("gm")
end)

concommand.Add("yrp_map", function(ply, cmd, args)
	hr_pre("gm")
	YRP.msg("gm", "[Changelevel]")
	local allmaps = file.Find("maps/*.bsp", "GAME", "nameasc")
	for i, map in pairs(allmaps) do
		local mapname = string.Replace(map, ".bsp", "")
		allmaps[i] = mapname
	end
	local id = tonumber(args[1])
	local map = allmaps[id]
	if map != nil then
		if SERVER then
			YRP.msg("gm", "Changelevel to " .. map)
			RunConsoleCommand("changelevel", map)
		else
			YRP.msg("gm", "ONLY AVAILABLE ON SERVER")
		end
	else
		YRP.msg("gm", "ID OUT OF RANGE")
	end
	hr_pos("gm")
end)

function makeString(tab, str_len, cut)
	local _result = ""
	for i = 1, str_len do
		if tab[i] != nil then
			_result = _result .. tab[i]
		elseif i >= str_len-3 and cut then
			_result = _result .. "."
		else
			_result = _result .. " "
		end
	end
	return _result
end

concommand.Add("yrp_players", function(ply, cmd, args)
	hr_pre("gm")
	YRP.msg("gm", "Players:\t" .. tostring(player.GetCount()) .. "/" .. tostring(game.MaxPlayers()))
	YRP.msg("gm", "ID   SteamID              Name                     Money")
	for i, pl in pairs(player.GetAll()) do
		local _id = makeString(string.ToTable(pl:UserID()), 4, false)
		local _steamid = makeString(string.ToTable(pl:SteamID()), 20, false)
		local _name = makeString(string.ToTable(pl:YRPName()), 24, true)
		local _money = makeString(string.ToTable(pl:GetDString("money", -1)), 12, false)
		local _str = string.format("%s %s %s %s", _id, _steamid, _name, _money)
		YRP.msg("gm", _str)
	end
	hr_pos("gm")
end)

function PrintHelp()
	hr_pre("note")
	YRP.msg("note", "Shared Commands:")
	YRP.msg("note", "yrp_status")
	YRP.msg("note", "	Shows info")
	YRP.msg("note", "yrp_version")
	YRP.msg("note", "	Shows gamemode version")
	YRP.msg("note", "yrp_players")
	YRP.msg("note", "	Shows all players")
	YRP.msg("note", "yrp_usergroup RPNAME UserGroup")
	YRP.msg("note", "	Put a player with the RPNAME to the UserGroup")
	YRP.msg("note", "yrp_maps")
	YRP.msg("note", "	Shows all maps on server")
	YRP.msg("note", "yrp_map ID")
	YRP.msg("note", "	Changelevel to map ID")
	YRP.msg("note", "yrp_collection / yrp_collectionid")
	YRP.msg("note", "	Shows servers collectionid")
	hr_pos("note")

	hr_pre("note")
	YRP.msg("note", "Client Commands:")
	YRP.msg("note", "yrp_cl_hud X")
	YRP.msg("note", "	1: Shows hud, 0: Hide hud")
	YRP.msg("note", "yrp_togglesettings")
	YRP.msg("note", "	Toggle settings menu")
	hr_pos("note")

	hr_pre("note")
	YRP.msg("note", "Server Commands:")
	YRP.msg("note", "yrp_givelicense NAME LICENSENAME")
	hr_pos("note")
end

concommand.Add("yrp_help", function(ply, cmd, args)
	PrintHelp()
end)

concommand.Add("yrp__help", function(ply, cmd, args)
	PrintHelp()
end)

function YRPCollectionID()
	return tonumber(GetGlobalDString("text_server_collectionid", "0"))
end

function PrintCollectionID()
	hr_pre("note")
	YRP.msg("note", "Server - CollectionID: " .. YRPCollectionID())
	hr_pos("note")
end
concommand.Add("yrp_collectionid", function(ply, cmd, args)
	PrintCollectionID()
end)
concommand.Add("yrp_collection", function(ply, cmd, args)
	PrintCollectionID()
end)

hook.Add("StartCommand", "NoJumpGuns", function(ply, cmd)
	if GetGlobalDBool("bool_anti_bhop", false) and !ply:GetDBool("canjump", false) and ply:GetMoveType() != MOVETYPE_NOCLIP then
		cmd:RemoveKey(IN_JUMP)
	end
end)

function IsEntityAlive(ply, uid)
	for i, ent in pairs(ents.GetAll()) do
		if tostring(ent:GetDString("item_uniqueID", "")) == tostring(uid) and ent:GetRPOwner() == ply then
			return true, ent
		end
	end
	return false
end

if SERVER then
	util.AddNetworkString("GetServerInfo")
	net.Receive("GetServerInfo", function(len, ply)
		local tab = {}
		tab.Version = GAMEMODE.Version
		tab.VersionStable = GAMEMODE.VersionStable
		tab.VersionBeta = GAMEMODE.VersionBeta
		tab.VersionCanary = GAMEMODE.VersionCanary
		tab.isdedicated = game.IsDedicated()
		net.Start("GetServerInfo")
			net.WriteTable(tab)
		net.Send(ply)
	end)

	local tmp = SQL_SELECT("yrp_general", "text_gamemode_name", nil)
	if wk(tmp) then
		tmp = tmp[1]
		GM.BaseName = SQL_STR_OUT(tmp.text_gamemode_name)
	end

	util.AddNetworkString("getGamemodename")
	net.Receive("getGamemodename", function(len, ply)
		net.Start("getGamemodename")
			net.WriteString(GAMEMODE.BaseName)
		net.Send(ply)
	end)
end

if CLIENT then
	net.Receive("getGamemodename", function(len)
		GAMEMODE.BaseName = net.ReadString()
	end)

	timer.Simple(1, function()
		net.Start("getGamemodename")
		net.SendToServer()
	end)
end

-- Multicore (Shared) enable:
RunConsoleCommand("gmod_mcore_test", "1")
RunConsoleCommand("mat_queue_mode", "-1")
RunConsoleCommand("studio_queue_mode", "1")
RunConsoleCommand("r_hunkalloclightmaps", "0")

-- Enable Errorlog
RunConsoleCommand("lua_log_sv", "1")

if CLIENT then
	-- Enable Errorlog
	RunConsoleCommand("lua_log_cl", "1")

	-- Multicore (Client) enable:
	RunConsoleCommand("cl_threaded_bone_setup", "1")
	RunConsoleCommand("cl_threaded_client_leaf_system", "1")
	RunConsoleCommand("r_threaded_particles", "1")
	RunConsoleCommand("r_threaded_renderables", "1")
	RunConsoleCommand("r_threaded_client_shadow_manager", "1")
	RunConsoleCommand("r_queued_ropes", "1")
elseif SERVER then
	-- "removes" voice icons
	RunConsoleCommand("mp_show_voice_icons", "0")
end

function GetAllDoors()
	local propDoors = ents.FindByClass("prop_door")
	local propDoorRs = ents.FindByClass("prop_door_rotating")
	local funcDoors = ents.FindByClass("func_door")
	local funcDoorRs = ents.FindByClass("func_door_rotating")

	local doors = {}
	for i, v in pairs(propDoors) do
		table.insert(doors, v)
	end
	for i, v in pairs(propDoorRs) do
		table.insert(doors, v)
	end
	for i, v in pairs(funcDoors) do
		table.insert(doors, v)
	end
	for i, v in pairs(funcDoorRs) do
		table.insert(doors, v)
	end
	return doors
end

function IsInTable(tab, val)
	if tab[val] != nil then
		return true
	else
		return false
	end
end

function IsInChannel(ply, channel, skip)
	skip = skip or false

	local ug = ply:GetUserGroup()
	local grp = ply:GetGroupUID()
	local rol = ply:GetRoleUID()
	
	if !skip and ply:GetDBool("yrp_voice_channel_mute_" .. channel.uniqueID, false) then
		return false
	end

	return IsInTable(channel.string_active_usergroups, ug) or IsInTable(channel.string_active_groups, grp) or IsInTable(channel.string_active_roles, rol) or IsInTable(channel.string_passive_usergroups, ug) or IsInTable(channel.string_passive_groups, grp) or IsInTable(channel.string_passive_roles, rol) or false
end

function IsActiveInChannel(ply, channel, skip)
	skip = skip or false
	
	local ug = ply:GetUserGroup()
	local grp = ply:GetGroupUID()
	local rol = ply:GetRoleUID()

	if !skip and ply:GetDBool("yrp_voice_channel_mutemic_" .. channel.uniqueID, true) then
		return false
	end
	return IsInTable(channel.string_active_usergroups, ug) or IsInTable(channel.string_active_groups, grp) or IsInTable(channel.string_active_roles, rol) or false
end

function IsInMaxVoiceRange(listener, talker)
	local dist = listener:GetPos():Distance(talker:GetPos())
	local result = dist <= GetGlobalDInt("int_voice_max_range", 1)
	return result
end

function GetVoiceRangeText(ply)
	local ranges = {
		[0] = YRP.lang_string("LID_whisper"),
		[1] = YRP.lang_string("LID_quiet"),
		[2] = "",
		[3] = YRP.lang_string("LID_noisy"), 
		[4] = YRP.lang_string("LID_yell")
	}
	return ranges[ply:GetDInt("voice_range", 2)]
end

function GetVoiceRange(ply)
	local ranges = {
		[0] = 80,
		[1] = 120,
		[2] = 250,
		[3] = 400, 
		[4] = GetGlobalDInt("int_voice_max_range", 1)
	}
	return math.Clamp(ranges[ply:GetDInt("voice_range", 2)], 0, GetGlobalDInt("int_voice_max_range", 1))
end

function IsInSpeakRange(listener, talker)
	local dist = listener:GetPos():Distance(talker:GetPos())
	local result = dist <= GetVoiceRange(talker)
	return result
end

-- COLORFIX
if system.IsLinux() then
	_MsgC                       = _MsgC         or MsgC
	_ErrorNoHalt                = _ErrorNoHalt  or ErrorNoHalt

	local available_colors      = {
	Color(0, 0, 0),       Color(128, 0, 0),     Color(0, 128, 0),
	Color(128, 128, 0),   Color(0, 0, 128),     Color(128, 0, 128),
	Color(0, 128, 128),   Color(192, 192, 192), Color(128, 128, 128),
	Color(255, 0, 0),     Color(0, 255, 0),     Color(255, 255, 0),
	Color(0, 0, 255),     Color(255, 0, 255),   Color(0, 255, 255),
	Color(255, 255, 255), Color(0, 0, 0),       Color(0, 0, 95),
	Color(0, 0, 135),     Color(0, 0, 175),     Color(0, 0, 215),
	Color(0, 0, 255),     Color(0, 95, 0),      Color(0, 95, 95),
	Color(0, 95, 135),    Color(0, 95, 175),    Color(0, 95, 215),
	Color(0, 95, 255),    Color(0, 135, 0),     Color(0, 135, 95),
	Color(0, 135, 135),   Color(0, 135, 175),   Color(0, 135, 215),
	Color(0, 135, 255),   Color(0, 175, 0),     Color(0, 175, 95),
	Color(0, 175, 135),   Color(0, 175, 175),   Color(0, 175, 215),
	Color(0, 175, 255),   Color(0, 215, 0),     Color(0, 215, 95),
	Color(0, 215, 135),   Color(0, 215, 175),   Color(0, 215, 215),
	Color(0, 215, 255),   Color(0, 255, 0),     Color(0, 255, 95),
	Color(0, 255, 135),   Color(0, 255, 175),   Color(0, 255, 215),
	Color(0, 255, 255),   Color(95, 0, 0),      Color(95, 0, 95),
	Color(95, 0, 135),    Color(95, 0, 175),    Color(95, 0, 215),
	Color(95, 0, 255),    Color(95, 95, 0),     Color(95, 95, 95),
	Color(95, 95, 135),   Color(95, 95, 175),   Color(95, 95, 215),
	Color(95, 95, 255),   Color(95, 135, 0),    Color(95, 135, 95),
	Color(95, 135, 135),  Color(95, 135, 175),  Color(95, 135, 215),
	Color(95, 135, 255),  Color(95, 175, 0),    Color(95, 175, 95),
	Color(95, 175, 135),  Color(95, 175, 175),  Color(95, 175, 215),
	Color(95, 175, 255),  Color(95, 215, 0),    Color(95, 215, 95),
	Color(95, 215, 135),  Color(95, 215, 175),  Color(95, 215, 215),
	Color(95, 215, 255),  Color(95, 255, 0),    Color(95, 255, 95),
	Color(95, 255, 135),  Color(95, 255, 175),  Color(95, 255, 215),
	Color(95, 255, 255),  Color(135, 0, 0),     Color(135, 0, 95),
	Color(135, 0, 135),   Color(135, 0, 175),   Color(135, 0, 215),
	Color(135, 0, 255),   Color(135, 95, 0),    Color(135, 95, 95),
	Color(135, 95, 135),  Color(135, 95, 175),  Color(135, 95, 215),
	Color(135, 95, 255),  Color(135, 135, 0),   Color(135, 135, 95),
	Color(135, 135, 135), Color(135, 135, 175), Color(135, 135, 215),
	Color(135, 135, 255), Color(135, 175, 0),   Color(135, 175, 95),
	Color(135, 175, 135), Color(135, 175, 175), Color(135, 175, 215),
	Color(135, 175, 255), Color(135, 215, 0),   Color(135, 215, 95),
	Color(135, 215, 135), Color(135, 215, 175), Color(135, 215, 215),
	Color(135, 215, 255), Color(135, 255, 0),   Color(135, 255, 95),
	Color(135, 255, 135), Color(135, 255, 175), Color(135, 255, 215),
	Color(135, 255, 255), Color(175, 0, 0),     Color(175, 0, 95),
	Color(175, 0, 135),   Color(175, 0, 175),   Color(175, 0, 215),
	Color(175, 0, 255),   Color(175, 95, 0),    Color(175, 95, 95),
	Color(175, 95, 135),  Color(175, 95, 175),  Color(175, 95, 215),
	Color(175, 95, 255),  Color(175, 135, 0),   Color(175, 135, 95),
	Color(175, 135, 135), Color(175, 135, 175), Color(175, 135, 215),
	Color(175, 135, 255), Color(175, 175, 0),   Color(175, 175, 95),
	Color(175, 175, 135), Color(175, 175, 175), Color(175, 175, 215),
	Color(175, 175, 255), Color(175, 215, 0),   Color(175, 215, 95),
	Color(175, 215, 135), Color(175, 215, 175), Color(175, 215, 215),
	Color(175, 215, 255), Color(175, 255, 0),   Color(175, 255, 95),
	Color(175, 255, 135), Color(175, 255, 175), Color(175, 255, 215),
	Color(175, 255, 255), Color(215, 0, 0),     Color(215, 0, 95),
	Color(215, 0, 135),   Color(215, 0, 175),   Color(215, 0, 215),
	Color(215, 0, 255),   Color(215, 95, 0),    Color(215, 95, 95),
	Color(215, 95, 135),  Color(215, 95, 175),  Color(215, 95, 215),
	Color(215, 95, 255),  Color(215, 135, 0),   Color(215, 135, 95),
	Color(215, 135, 135), Color(215, 135, 175), Color(215, 135, 215),
	Color(215, 135, 255), Color(215, 175, 0),   Color(215, 175, 95),
	Color(215, 175, 135), Color(215, 175, 175), Color(215, 175, 215),
	Color(215, 175, 255), Color(215, 215, 0),   Color(215, 215, 95),
	Color(215, 215, 135), Color(215, 215, 175), Color(215, 215, 215),
	Color(215, 215, 255), Color(215, 255, 0),   Color(215, 255, 95),
	Color(215, 255, 135), Color(215, 255, 175), Color(215, 255, 215),
	Color(215, 255, 255), Color(255, 0, 0),     Color(255, 0, 95),
	Color(255, 0, 135),   Color(255, 0, 175),   Color(255, 0, 215),
	Color(255, 0, 255),   Color(255, 95, 0),    Color(255, 95, 95),
	Color(255, 95, 135),  Color(255, 95, 175),  Color(255, 95, 215),
	Color(255, 95, 255),  Color(255, 135, 0),   Color(255, 135, 95),
	Color(255, 135, 135), Color(255, 135, 175), Color(255, 135, 215),
	Color(255, 135, 255), Color(255, 175, 0),   Color(255, 175, 95),
	Color(255, 175, 135), Color(255, 175, 175), Color(255, 175, 215),
	Color(255, 175, 255), Color(255, 215, 0),   Color(255, 215, 95),
	Color(255, 215, 135), Color(255, 215, 175), Color(255, 215, 215),
	Color(255, 215, 255), Color(255, 255, 0),   Color(255, 255, 95),
	Color(255, 255, 135), Color(255, 255, 175), Color(255, 255, 215),
	Color(255, 255, 255), Color(8, 8, 8),       Color(18, 18, 18),
	Color(28, 28, 28),    Color(38, 38, 38),    Color(48, 48, 48),
	Color(58, 58, 58),    Color(68, 68, 68),    Color(78, 78, 78),
	Color(88, 88, 88),    Color(98, 98, 98),    Color(108, 108, 108),
	Color(118, 118, 118), Color(128, 128, 128), Color(138, 138, 138),
	Color(148, 148, 148), Color(158, 158, 158), Color(168, 168, 168),
	Color(178, 178, 178), Color(188, 188, 188), Color(198, 198, 198),
	Color(208, 208, 208), Color(218, 218, 218), Color(228, 228, 228),
	Color(238, 238, 238)
	}

	local n_available_colors    = #available_colors
	local color_clear_sequence  = "\27[0m"
	local color_start_sequence  = "\27[38;5;"
	local background_sequence   = "\27[48;5;"

	local function color_id_from_color(col)
		local dist, windist, ri

		for i = 1, n_available_colors do
			local color = available_colors[i]

			dist = (col.r - color.r)^2 + (col.g - color.g)^2 + (col.b - color.b)^2

			if i == 1 or dist < windist then
			windist = dist
			ri = i
			end
		end

		return tostring(ri - 1)
	end

	function print_colored(text, color, background_color, style)
		local color_sequence = color_clear_sequence

		if color != nil then
			if istable(color) then
			color_sequence = color_start_sequence .. color_id_from_color(color) .. "m"
			elseif isstring(color) then
			color_sequence = color
			end
		end

		if background_color != nil then
			if istable(background_color) then
			color_sequence = color_sequence .. background_sequence .. color_id_from_color(background_color) .. "m"
			elseif isstring(background_color) then
			color_sequence = color_sequence .. background_color
			end
		end

		if istable(style) then
			if style.bold == true then
			color_sequence = color_sequence .. "\27[1m"
			end

			if style.dim == true or style.dimmed == true then
			color_sequence = color_sequence .. "\27[2m"
			end

			if style.underline == true or style.underlined == true then
			color_sequence = color_sequence .. "\27[4m"
			end

			if style.blink == true then
			color_sequence = color_sequence .. "\27[5m"
			end

			if style.inverted == true or style.invert == true then
			color_sequence = color_sequence .. "\27[7m"
			end

			if style.hidden == true then
			color_sequence = color_sequence .. "\27[8m"
			end
		end

		Msg(color_sequence .. tostring(text) .. color_clear_sequence)
	end

	function MsgC(...)
		local this_sequence = color_clear_sequence

		for k, v in ipairs({ ... }) do
			if istable(v) then
			this_sequence = color_start_sequence .. color_id_from_color(v) .. "m"
			else
			print_colored(tostring(v), this_sequence)
			end
		end
	end

	function ErrorNoHalt(msg)
		Msg('\27[41;15m\27[1m')
		_ErrorNoHalt(msg)
		Msg(color_clear_sequence)
	end
end
