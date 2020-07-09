--Copyright (C) 2017-2020 Arno Zura (https://www.gnu.org/licenses/gpl.txt)

--cl_think.lua

local _cmdpre = "[COMMAND] "
local _cmdsv = "This command is adminonly/serversided!"
concommand.Add("yrp_usergroup", function(ply, cmd, args)
	YRP.msg("note", _cmdpre .. _cmdsv)
end)

local chatisopen = false
_thirdperson = 0
local _thirdpersonC = 0
local _lastkey = nil
ch_attack1 = 0

function isChatOpen()
	return chatisopen or false
end

function isConsoleOpen()
	return gui.IsConsoleVisible()
end

function isMainMenuOpen()
	return gui.IsGameUIVisible()
end

local wasgroup = false
hook.Remove("StartChat", "yrp_startchat")
hook.Add("StartChat", "yrp_startchat", function(isTeamChat)
	chatisopen = true
	net.Start("startchat")
	net.SendToServer()
	if isTeamChat then
		wasgroup = true
		
		SetChatMode("GROUP")
	elseif wasgroup then
		wasgroup = false
		SetChatMode("SAY")
	end
end)

hook.Add("FinishChat", "yrp_finishchat", function()
	chatisopen = false
	net.Start("finishchat")
	net.SendToServer()
end)

local keys = {}
keys["_hold"] = 0

hook.Add("HUDWeaponPickedUp", "yrp_translate_weaponname", function(wep)
	if wep.LanguageString != nil then
		wep.PrintName = YRP.lang_string(wep.LanguageString)
	end
end)

function GM:PlayerSwitchWeapon(ply, oldWeapon, newWeapon)
	--[[ Change language ]]--
	if newWeapon.LanguageString != nil then
		newWeapon.PrintName = YRP.lang_string(newWeapon.LanguageString)
	end
end

function close_all()
	CloseCombinedMenu()
	CloseHelpMenu()
	CloseEmotesMenu()
	closeTicketMenu()
	closeCharMenu()
	closeKeybindsMenu()
	closeCharacterSelection()
	close_appearance()
	CloseInventory()
	CloseRoleMenu()
	CloseBuyMenu()
	CloseSettings()
	closeMap()
	closeInteractMenu()
	closeSP()
end

function useFunction(str)
	if str == nil then
		return
	end
	local lply = LocalPlayer()
	local eyeTrace = lply:GetEyeTrace()

	if str == "close_all" then
		close_all()
	end

	if !isChatOpen() and !isConsoleOpen() and !isMainMenuOpen() then
		--Menues
		if str == "openSP" then
			openSP()
		elseif str == "closeSP" then
			closeSP()
		elseif str == "ToggleEmotesMenu" then
			ToggleEmotesMenu()
		elseif str == "ToggleLawsMenu" then
			ToggleLawsMenu()
		elseif str == "openCharacterMenu" then
			done_tutorial("tut_cs")
			toggleCharacterSelection()
		elseif str == "openAppearance" then
			toggleAppearanceMenu()
		elseif str == "openInventory" then
			done_tutorial("tut_mi")
			ToggleInventory()
		elseif str == "openSettings" then
			done_tutorial("tut_ms")
			ToggleSettings()
		elseif str == "openMap" then
			done_tutorial("tut_tma")
			toggleMap()
		elseif str == "openInteractMenu" then
			toggleInteractMenu()
		elseif str == "menu_talents" then
			ToggleTalentsMenu()
		elseif str == "voice_mute" then
			net.Start("yrp_mute_voice")
			net.SendToServer()
		elseif str == "voice_range_up" then
			net.Start("yrp_voice_range_up")
			net.SendToServer()
		elseif str == "voice_range_dn" then
			net.Start("yrp_voice_range_dn")
			net.SendToServer()
		elseif str == "voice_menu" then
			ToggleVoiceMenu()
		elseif str == "chat_menu" then
			ToggleChatMenu()
		elseif str == "macro_menu" then
			ToggleMacroMenu()
		elseif str == "openOptions" then
			if eyeTrace.Entity != NULL then
				if eyeTrace.Entity:GetClass() == "prop_door_rotating" or eyeTrace.Entity:GetClass() == "func_door" or eyeTrace.Entity:GetClass() == "func_door_rotating" then
					toggleDoorOptions(eyeTrace.Entity)
				elseif eyeTrace.Entity:IsVehicle() then
					toggleVehicleOptions(eyeTrace.Entity, eyeTrace.Entity:GetDInt("item_uniqueID"))
				end
			end

		--When scoreboard open, enable mouse
		elseif str == "scoreboard" and IsScoreboardOpen() then
			gui.EnableScreenClicker(true)
		--Inventory
		elseif str == "dropitem" and !mouseVisible() then
			local _weapon = LocalPlayer():GetActiveWeapon()
			if _weapon != NULL then
				local _pname = _weapon:GetPrintName() or _weapon.PrintName or YRP.lang_string("LID_weapon")
				local tab = {}
				tab["ITEM"] = _pname
				local cannotbedropped = YRP.lang_string("LID_cannotbedropped", tab)
				local hasbeendropped = YRP.lang_string("LID_hasbeendropped", tab)
				if _weapon.notdropable == nil then
					net.Receive("dropswep", function(len)
						local _b = net.ReadBool()
						if _b then
							notification.AddLegacy(hasbeendropped, 0, 3)
						else
							notification.AddLegacy(cannotbedropped, 0, 3)
						end
					end)
					net.Start("dropswep")
					net.SendToServer()
				else
					notification.AddLegacy(cannotbedropped, 0, 3)
				end
			end

		--Mouse changer
		elseif str == "F11Toggle" then
			done_tutorial("tut_tmo")
			gui.EnableScreenClicker(!vgui.CursorVisible())

		elseif str == "vyes" and !mouseVisible() then
			net.Start("voteYes")
			net.SendToServer()
		elseif str == "vno" and !mouseVisible() then
			net.Start("voteNo")
			net.SendToServer()
		elseif str == "scoreboard" and IsScoreboardOpen() then
			gui.EnableScreenClicker(true)
		elseif string.StartWith(str, "m_") then
			str = string.Replace(str, "m_", "")
			local uid = tonumber(str)
			UseMacro(uid)
		elseif GetGlobalDBool("bool_yrp_combined_menu", false) then
			local id = 0
			if str == "OpenHelpMenu" and GetGlobalDBool("bool_yrp_help_menu", false) then
				done_tutorial("tut_f1info", 10)
				id = 1
			elseif str == "OpenRoleMenu" and GetGlobalDBool("bool_yrp_role_menu", false) then
				id = 2
			elseif str == "OpenBuyMenu" and GetGlobalDBool("bool_yrp_buy_menu", false) then
				id = 3
			elseif str == "openCharMenu" and GetGlobalDBool("bool_yrp_char_menu", false) then
				id = 4
			elseif str == "openKeybindsMenu" and GetGlobalDBool("bool_yrp_keybinds_menu", false) then
				id = 5
			elseif str == "openTicketMenu" and GetGlobalDBool("bool_yrp_tickets_menu", false) then
				done_tutorial("tut_feedback")
				id = 6
			end
			if id > 0 then
				ToggleCombinedMenu(id)
			end
		elseif !GetGlobalDBool("bool_yrp_combined_menu", false) then
			if str == "OpenHelpMenu" and GetGlobalDBool("bool_yrp_help_menu", false) then
				done_tutorial("tut_welcome")
				done_tutorial("tut_feedback")
				done_tutorial("tut_f1info", 10)
				ToggleHelpMenu()
			elseif str == "OpenRoleMenu" and GetGlobalDBool("bool_yrp_role_menu", false) then
				done_tutorial("tut_mr")
				ToggleRoleMenu()
			elseif str == "OpenBuyMenu" and GetGlobalDBool("bool_yrp_buy_menu", false) then
				done_tutorial("tut_mb")
				ToggleBuyMenu()
			elseif str == "openTicketMenu" and GetGlobalDBool("bool_yrp_tickets_menu", false) then
				toggleTicketMenu()
			elseif str == "openCharMenu" and GetGlobalDBool("bool_yrp_char_menu", false) then
				toggleCharMenu()
			elseif str == "openKeybindsMenu" and GetGlobalDBool("bool_yrp_keybinds_menu", false) then
				toggleKeybindsMenu()
			end			
		end
	end
end

function keyDown(key, str, distance)
	local lply = LocalPlayer()
	local plyTrace = lply:GetEyeTrace()
	local _return = false
	if distance != nil then
		if plyTrace.Entity:GetPos():Distance(ply:GetPos()) > distance then
			_return = true
		end
	end
	if !_return then
		if keys[tostring(key)] == nil then
			keys[tostring(key)] = false
		end
		if lply:KeyDown(key) and !keys[tostring(key)] then
			keys[tostring(key)] = true
			timer.Simple(0.2, function()
				if str != nil then
					useFunction(str)
				end
				keys[tostring(key)] = false
			end)
		end
	end
end

function keyPressed(key, str, distance)
	if ChatIsClosedForChat() then
		local lply = LocalPlayer()
		local plyTrace = lply:GetEyeTrace()
		local _return = false
		if distance and ea(plyTrace.Entity) then
			if plyTrace.Entity:GetPos():Distance(lply:GetPos()) > distance then
				_return = true
			end
		end
		if !_return then
			if keys[tostring(key)] == nil then
				keys[tostring(key)] = false
			end
			if input.IsKeyDown(key) and !keys[tostring(key)] then
				keys[tostring(key)] = true
				timer.Simple(0.14, function()
					if str != nil then
						useFunction(str)
					end
					keys[tostring(key)] = false
				end)
			end
		end
	end
end

local clicked = false

local afktime = CurTime()
local _view_delay = true
local blink_delay = 0
local setup = false
local hudD = nil
local hudFail = hudFail or false
function KeyPress()
	local lply = LocalPlayer()

	hudD = hudD or CurTime() + 240

	if hudD < CurTime() then
		hudD = CurTime() + 240
		if lply:GetDInt("hud_version", -1) < 0 and !hudFail then
			hudFail = true
			net.Start("rebuildHud")
			net.SendToServer()
			YRP.msg("error", "HUD Version outdated! " .. tostring(lply:GetDInt("hud_version", -1)) .. " " .. printReadyError())
		end
	end

	lply.view_range = lply.view_range or 0
	lply.view_range_view = lply.view_range_view or 0

	lply.view_z = lply.view_z or 0
	lply.view_x = lply.view_x or 0
	lply.view_s = lply.view_s or 0

	lply.view_z_c = lply.view_z_c or 0
	lply.view_x_c = lply.view_x_c or 0
	lply.view_s_c = lply.view_s_c or 0

	if !setup then
		setup = true
		lply.view_range = 0
		lply.view_range_view = 0

		lply.view_z = 0
		lply.view_x = 0
		lply.view_s = 0

		lply.view_z_c = 0
		lply.view_x_c = 0
		lply.view_s_c = 0
	else
		if lply:IsInCombat() and CurTime() > blink_delay and !system.HasFocus() then
			blink_delay = CurTime() + 1
			system.FlashWindow()
		end

		if lply:AFK() then
			local afk = true
			for i = 107, 113 do
				if input.IsMouseDown(i) then
					afk = false
					break
				end
			end
			if afk then
				for i = 0, 159 do
					if lply:KeyDown(i) then
						afk = false
						break
					end
				end
			end
			if !afk then
				net.Start("notafk")
				net.SendToServer()
			end
		else
			for i = 107, 113 do
				if input.IsMouseDown(i) then
					afktime = CurTime()
				end
			end
			for i = 0, 159 do
				if lply:KeyDown(i) then
					afktime = CurTime()
				end
			end
			if afktime + 300 < CurTime() then -- AFKTIME
				net.Start("setafk")
				net.SendToServer()
			end
		end

		if !vgui.CursorVisible() then
			if input.IsKeyDown(get_keybind("view_switch")) then
				--[[ When toggle view ]]--
				if _view_delay then
					_view_delay = false
					timer.Simple(0.16, function()
						_view_delay = true
					end)

					if tonumber(lply.view_range_view) > 0 then
						lply.view_range_view = 0
					else
						local _old_view = tonumber(LocalPlayer():GetDInt("view_range_old", 0))
						if _old_view > 0 then
							lply.view_range_view = _old_view
						else
							lply.view_range_view = tonumber(GetGlobalDString("text_view_distance", "0"))
						end
					end

					lply.view_range = lply.view_range_view
				end
			else
				--[[ smoothing ]]--
				if tonumber(lply.view_range) < tonumber(lply.view_range_view) then
					lply.view_range = lply:GetDInt("view_range") + lply.view_range_view / 16
				else

					if input.IsKeyDown(get_keybind("view_zoom_out")) then
						done_tutorial("tut_vo", 5)

						lply.view_range_view = lply.view_range_view + 1

						if tonumber(lply.view_range_view) > tonumber(GetGlobalDString("text_view_distance", "0")) then
							lply.view_range_view = tonumber(GetGlobalDString("text_view_distance", "0"))
						end
						lply.view_range_old = lply.view_range_view
					elseif input.IsKeyDown(get_keybind("view_zoom_in")) then
						done_tutorial("tut_vi", 5)

						lply.view_range_view = lply.view_range_view - 1

						if tonumber(lply.view_range_view) < -200 then
							lply.view_range_view = -200
						end
						lply.view_range_old = lply.view_range_view
					end
					lply.view_range = lply.view_range_view
				end
			end

			--[[ Up and down ]]--
			if input.IsKeyDown(get_keybind("view_up")) then
				lply.view_z_c = lply.view_z_c + 0.1
			elseif input.IsKeyDown(get_keybind("view_down")) then
				lply.view_z_c = lply.view_z_c - 0.1
			end
			if tonumber(lply.view_z_c) > 100 then
				lply.view_z_c = 100
			elseif tonumber(lply.view_z_c) < -100 then
				lply.view_z_c = -100
			end
			if tonumber(lply.view_z_c) < 3 and tonumber(lply.view_z_c) > -3 then
				lply.view_z = 0
			else
				lply.view_z = lply.view_z_c
			end

			--[[ Left and right ]]--
			if input.IsKeyDown(get_keybind("view_right")) then
				lply.view_x_c = lply.view_x_c + 0.1
			elseif input.IsKeyDown(get_keybind("view_left")) then
				lply.view_x_c = lply.view_x_c - 0.1
			end
			if tonumber(lply.view_x_c) > 300 then
				lply.view_x_c = 300
			elseif tonumber(lply.view_x_c) < -300 then
				lply.view_x_c = -300
			end
			if tonumber(lply.view_x_c) < 3 and tonumber(lply.view_x_c) > -3 then
				lply.view_x = 0
			else
				lply.view_x = lply.view_x_c
			end

			--[[ spin right and spin left ]]--
			if input.IsKeyDown(get_keybind("view_spin_right")) then
				lply.view_s_c = lply.view_s_c + 0.4
			elseif input.IsKeyDown(get_keybind("view_spin_left")) then
				lply.view_s_c = lply.view_s_c - 0.4
			end
			if tonumber(lply.view_s_c) > 360 or tonumber(lply.view_s_c) < -360 then
				lply.view_s_c = 0
			end
			if tonumber(lply.view_s_c) < 6 and tonumber(lply.view_s_c) > -6 then
				lply.view_s = 0
			else
				lply.view_s =  lply.view_s_c
			end
		end
	end

	keyPressed(KEY_ESCAPE, "close_all")

	keyPressed(IN_ATTACK2, "scoreboard")

	keyPressed(KEY_F1, "OpenHelpMenu")
	keyPressed(KEY_F7, "openTicketMenu")

	keyPressed(get_keybind("menu_char"), "openCharMenu")
	keyPressed(get_keybind("menu_keybinds"), "openKeybindsMenu")

	keyPressed(get_keybind("menu_emotes"), "ToggleEmotesMenu")

	keyPressed(get_keybind("menu_laws"), "ToggleLawsMenu")

	keyPressed(get_keybind("menu_settings"), "openSettings")

	keyPressed(get_keybind("menu_inventory"), "openInventory")
	keyPressed(get_keybind("menu_appearance"), "openAppearance")

	keyPressed(get_keybind("menu_character_selection"), "openCharacterMenu")
	keyPressed(get_keybind("menu_role"), "OpenRoleMenu")
	keyPressed(get_keybind("menu_buy"), "OpenBuyMenu")

	keyPressed(get_keybind("menu_interact"), "openInteractMenu", GetGlobalDInt("int_door_distance", 200))

	keyPressed(get_keybind("menu_options_door"), "openOptions", GetGlobalDInt("int_door_distance", 200))
	keyPressed(get_keybind("menu_options_vehicle"), "openOptions", GetGlobalDInt("int_door_distance", 200))

	keyPressed(get_keybind("toggle_map"), "openMap")

	keyPressed(get_keybind("toggle_mouse"), "F11Toggle")

	--keyPressed(KEY_PAGEUP, "vyes")
	--keyPressed(KEY_PAGEDOWN, "vno")

	keyPressed(get_keybind("drop_item"), "dropitem")

	keyPressed(KEY_UP, "openSP")
	keyPressed(KEY_DOWN, "closeSP")

	keyPressed(get_keybind("voice_mute"), "voice_mute")
	keyPressed(get_keybind("voice_range_up"), "voice_range_up")
	keyPressed(get_keybind("voice_range_dn"), "voice_range_dn")
	keyPressed(get_keybind("voice_menu"), "voice_menu")

	keyPressed(get_keybind("chat_menu"), "chat_menu")

	keyPressed(get_keybind("menu_talents"), "menu_talents")

	keyPressed(get_keybind("macro_menu"), "macro_menu")
	for i = 1, 49 do
		if get_keybind("m_" .. i) != 0 then
			keyPressed(get_keybind("m_" .. i), "m_" .. i)
		end
	end
end
hook.Add("Think", "Thinker", KeyPress)

local _savePos = Vector(0, 0, 0)
_lookAtEnt = nil
_drawViewmodel = false

local PLAYER = FindMetaTable("Player")
function TauntCamera()
	local CAM = {}
	CAM.ShouldDrawLocalPlayer = function( self, ply, on )
		return true
	end
	CAM.CalcView = function( self, view, ply, on )
		return true
	end
	CAM.CreateMove = function( self, cmd, ply, on )
		return true
	end
	return CAM
end
PLAYER.TauntCam = TauntCamera()

-- #THIRDPERSON
local oldang = Angle(0, 0, 0)
local function yrpCalcView(lply, pos, angles, fov)
	lply.view_range = lply.view_range or 0
	lply.view_range_view = lply.view_range_view or 0

	lply.view_z = lply.view_z or 0
	lply.view_x = lply.view_x or 0
	lply.view_s = lply.view_s or 0

	lply.view_z_c = lply.view_z_c or 0
	lply.view_x_c = lply.view_x_c or 0
	lply.view_s_c = lply.view_s_c or 0

	if lply:Alive() then --and !lply:IsPlayingTaunt() then

		if lply:AFK() then
			if (oldang.p + 1 < angles.p and oldang.p - 1 < angles.p) or (oldang.y + 1 < angles.y and oldang.y - 1 < angles.y) or (oldang.r + 1 < angles.r and oldang.r - 1 < angles.r) then
				net.Start("notafk")
				net.SendToServer()
			end
		end
		oldang = angles

		local disablethirdperson = false
		local weapon = lply:GetActiveWeapon()
		if weapon != NULL and weapon:GetClass() != nil then
			local _weaponName = string.lower(tostring(lply:GetActiveWeapon():GetClass()))
			if _weaponName == "yrp_lightsaber_base" then
				
			elseif string.find(_weaponName, "lightsaber", 0, false) then
				disablethirdperson = true
			end
		end

		local _view_range = lply.view_range or 0
		if _view_range < 0 then
			_view_range = 0
		end
		if lply:IsPlayingTaunt() then
			disablethirdperson = false
			_view_range = 200
		end
		local dist = _view_range * lply:GetModelScale()

		local view = {}
		if lply:GetModel() != "models/player.mdl" and !lply:InVehicle() and !disablethirdperson and GetGlobalDBool("bool_thirdperson", false) then
			if lply:LookupBone("ValveBiped.Bip01_Head1") != nil then
				pos2 = lply:GetBonePosition(lply:LookupBone("ValveBiped.Bip01_Head1")) + (angles:Forward() * 12 * lply:GetModelScale())
			end
			if lply:GetMoveType() == MOVETYPE_NOCLIP and lply:GetModel() == "models/crow.mdl" then
				local _tmpThick = 4
				local _minDistFor = 8
				local _minDistBac = 40
				if dist > 0 then
					_drawViewmodel = true
				else
					_drawViewmodel = false
				end
				view.origin = pos - (angles:Forward() * dist) - Vector(0, 0, 58)
				view.angles = angles
				view.fov = fov
				return view
			else
			--if _thirdperson == 2 then

				if tonumber(lply.view_range or 0) > 0 then
					if lply:LookupBone("ValveBiped.Bip01_Head1") != nil then
						local _head = lply:GetPos().z + lply:OBBMaxs().z
						pos.z = _head
					end
					--Thirdperson
					dist = lply.view_range * lply:GetModelScale()

					local _tmpThick = 4
					local _minDistFor = 8
					local _minDistBac = 40
					angles = angles + Angle(0, lply.view_s, 0)
					local _pos_change = angles:Up() * lply.view_z + angles:Right() * lply.view_x

					local tr = util.TraceHull({
						start = pos + angles:Forward() * _minDistFor,
						endpos = pos - (angles:Forward() * dist) + _pos_change,
						filter = function( ent )
							if ent:GetCollisionGroup() == 20 then
								return false
							elseif ent == LocalPlayer() then
								return false
							elseif ent == weapon then
								return false
							end
							return true
						end,
						mins = Vector(-_tmpThick, -_tmpThick, -_tmpThick),
						maxs = Vector(_tmpThick, _tmpThick, _tmpThick),
						mask = MASK_SHOT_HULL
					})

					if tr.HitPos:Distance(pos) < dist and !tr.HitNonWorld then
						dist = tr.HitPos:Distance(pos) -- _tmpThick
					end

					if tr.Hit and tr.HitPos:Distance(pos) > _minDistBac then
						view.origin = tr.HitPos
						_savePos = view.origin
						view.angles = angles
						view.fov = fov
						_drawViewmodel = true
						return view
					elseif tr.Hit and tr.HitPos:Distance(pos) <= _minDistBac then
						view.origin = pos
						view.angles = angles
						view.fov = fov
						_drawViewmodel = false
						return view
					else
						view.origin = pos - (angles:Forward() * dist) + _pos_change
						view.angles = angles
						view.fov = fov
						_drawViewmodel = true
						return view
					end
				elseif tonumber(lply.view_range) > -200 and tonumber(lply.view_range) <= 0 then
					--Disabled
					view.origin = pos
					view.angles = angles
					view.fov = fov
					_drawViewmodel = false
					return view
				else
					--Firstperson realistic
					local dist = lply.view_range * lply:GetModelScale()

					local _tmpThick = 16
					local _head = lply:LookupBone("ValveBiped.Bip01_Head1")

					if worked(_head, "_head failed @cl_think.lua") then
						local tr = util.TraceHull({
							start = lply:GetBonePosition(_head) + angles:Forward() * 4,
							endpos = lply:GetBonePosition(_head) - angles:Forward() * 4,
							filter = {LocalPlayer(),weapon},
							mins = Vector(-_tmpThick, -_tmpThick, -_tmpThick),
							maxs = Vector(_tmpThick, _tmpThick, _tmpThick),
							mask = MASK_SHOT_HULL
						})

						if !tr.Hit then
							pos2 = lply:GetBonePosition(_head) + (angles:Forward() * 5 * lply:GetModelScale()) - Vector(0, 0, 1.4) * lply:GetModelScale() + (angles:Up() * 6 * lply:GetModelScale())
							view.origin = pos2
							_savePos = pos2
							view.angles = angles
							view.fov = fov
							_drawViewmodel = true

							return view
						else
							view.origin = pos
							view.angles = angles
							view.fov = fov
							_drawViewmodel = false
							return view
						end
					else
						view.origin = pos
						view.angles = angles
						view.fov = fov
						_drawViewmodel = false
						return view
					end
				end
			end
		end
	else
		local entindex = lply:GetDInt("ent_ragdollindex")

		if entindex then
			local ent = Entity(entindex)
			if !IsValid(ent) then
				return
			end
			if ent:LookupBone("ValveBiped.Bip01_Head1") != nil then
				pos, angles = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Head1"))
				pos = pos + angles:Forward() * 10

				angles:RotateAroundAxis(angles:Forward(), -90)--90)
				angles:RotateAroundAxis(angles:Right(), -90)--90)
				angles:RotateAroundAxis(angles:Up(), 0)
			end
	
			local view = {}

			view.origin = pos
			view.angles = angles
			view.fov = fov
			view.drawviewer = true

			return view
		end
	end
end
hook.Remove("CalcView", "MyCalcView")
hook.Add("CalcView", "MyCalcView", yrpCalcView)

function showPlayermodel()
	local lply = LocalPlayer()

	if !lply:InVehicle() then
		if _drawViewmodel then-- or LocalPlayer():IsPlayingTaunt() then
			return true
		else
			return false
		end
	else
		if _drawViewmodel then-- or LocalPlayer():IsPlayingTaunt() then
			--
		else
			
		end
		return false
	end
end
hook.Remove("ShouldDrawLocalPlayer", "ShowPlayermodel")
hook.Add("ShouldDrawLocalPlayer", "ShowPlayermodel", showPlayermodel)

net.Receive("send_team", function(len)
	local teamname = net.ReadString()
	local teamTab = net.ReadTable()
	local teamcolor = teamTab.color
	local teamuid = teamTab.uniqueID

	_G[teamname] = team
	table.insert(RPExtraTeams, teamTab)

	team.SetUp(teamuid, teamname, teamcolor)
end)
