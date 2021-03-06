--Copyright (C) 2017-2021 Arno Zura (https://www.gnu.org/licenses/gpl.txt)

surface.CreateFont("Saira_60", {
	font = "Saira",
	extended = true,
	size = 60,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("Saira_100", {
	font = "Saira SemiBold",
	extended = true,
	size = 100,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

local charbgnotfound = "NO BACKGROUND FOUND - F8 General -> Character Background"

local isEventChar = false

local fw = 860
local br = YRP.ctr(20)

local trashicon = ""

function openCharacterCreation()
	if CharacterMenu == nil then
		openMenu()
		
		local win = createD("DFrame", nil, ScrW(), ScrH(), 0, 0)
		win:MakePopup()
		win:Center()
		win:SetTitle("")
		win:ShowCloseButton(true)
		win:SetDraggable(false)
		function win:Paint(pw, ph)
			draw.RoundedBox(0, 0, 0, pw, ph, Color(40, 40, 40)) -- Dark Background - Character Creation
		end
		
		win.bg = createD("DHTML", win, win:GetWide(), win:GetTall(), 0, 0)
		win.bg.url = ""

		win.blur = createD("DPanel", win, win:GetWide(), win:GetTall(), 0, 0)
		function win.blur:Paint(pw, ph)
			-- Blur Background
			Derma_DrawBackgroundBlur(self, 0)
			if win.bg.url != GetGlobalString("text_character_background", "") then
				win.bg.url = GetGlobalString("text_character_background", "")
				win.bg:SetHTML(GetHTMLImage(GetGlobalString("text_character_background", ""), win:GetWide(), win:GetTall()))
			end
		end
		function win.blur:OnRemove()
			self:GetParent():Remove()
			CharacterMenu = nil
		end



		CharacterMenu = win.blur


		
		LocalPlayer().cc = true
		CreateFactionSelectionContent()
	end
end

local CharMenu = {}

function toggleCharacterSelection()
	if YRPIsNoMenuOpen() then
		openCharacterSelection()
	elseif LocalPlayer():Alive() then
		closeCharacterSelection()
	end
end

function closeCharacterSelection()
	if CharMenu.frame != nil and LocalPlayer():GetNW2Bool("loadedchars", false) == true and LocalPlayer():Alive() then
		closeMenu()
		CharMenu.frame:Remove()
		CharMenu.frame = nil
	end
end

local curChar = -1
local _cur = ""
local chars = {}
local loading = false
function LoadCharacters()
	--YRP.msg("gm", "received characterlist")

	trashicon = YRP.GetDesignIcon("64_trash")

	DONE_LOADING = DONE_LOADING or true

	local cache = {}

	curChar = tonumber(LocalPlayer():CharID())

	if pa(CharMenu.charactersBackground) then
		local i = 1
		CharMenu.charactersBackground.text = ""
		if wk(chars) then
			CharMenu.character.amount = 0
			CharMenu.character.amountevent = 0

			if #chars < 1 then
				if pa(CharMenu.frame) then
					CharMenu.frame:Close()
				end
				SetGlobalBool("create_eventchar", false)
				openCharacterCreation()
				return false
			end
			local y = 0
			for k, v in pairs(cache) do
				if wk(v.tmpChar.shadow) then
					v.tmpChar.shadow:Remove()
				end
				v.tmpChar:Remove()
			end
			
			local cni = 0
			local cei = 0
			for i = 1, #chars do
				if chars[i].char != nil then
					chars[i].char = chars[i].char or {}
					chars[i].role = chars[i].role or {}
					chars[i].group = chars[i].group or {}
					chars[i].faction = chars[i].faction or {}

					chars[i].char.uniqueID = tonumber(chars[i].char.uniqueID)
					chars[i].char.bool_archived = tobool(chars[i].char.bool_archived)
					chars[i].char.bool_eventchar = tobool(chars[i].char.bool_eventchar)

					if GetGlobalBool("bool_characters_removeondeath", false) then
						if chars[i].char.bool_archived then
							continue
						end
					end
					
					if chars[i].char.bool_eventchar then
						CharMenu.character.amountevent = CharMenu.character.amountevent + 1
						cei = cei + 1
					else
						CharMenu.character.amount = CharMenu.character.amount + 1
						cni = cni + 1
					end

					cache[i] = {}
					local sw = YRP.ctr(fw) - 2 * br
					local sh = YRP.ctr(200)
					local px = 0
					local py = 0
					if YRP_CharDesign == "horizontalnew" then
						sw = YRP.ctr(350*2)
						sh = YRP.ctr(600*2)
						px = 0
						py = 0
					end
					cache[i].tmpChar = createD("YButton", nil, sw, sh, px, py)
					local tmpChar = cache[i].tmpChar
					tmpChar:SetText("")

					tmpChar.charid = chars[i].char.uniqueID or "UID INVALID"
					tmpChar.charid = tonumber(tmpChar.charid)
					tmpChar.rpname = chars[i].char.rpname or "RPNAME INVALID"
					tmpChar.level = chars[i].char.int_level or "-1"
					tmpChar.rolename = chars[i].role.string_name or "ROLE INVALID"
					tmpChar.factionID = chars[i].faction.string_name or "FACTION INVALID"
					tmpChar.factionIcon = chars[i].faction.string_icon or ""
					tmpChar.groupID = chars[i].group.string_name or "GROUP INVALID"
					tmpChar.map = SQL_STR_OUT(chars[i].char.map)
					tmpChar.playermodelID = chars[i].char.playermodelID or 1
					tmpChar.playermodelID = tonumber(tmpChar.playermodelID)
					tmpChar.bool_eventchar = chars[i].char.bool_eventchar

					tmpChar.playermodels = {}
					if !strEmpty(chars[i].role.string_playermodels) then
						tmpChar.playermodels = string.Explode(",", chars[i].role.string_playermodels)
					end
	
					tmpChar.playermodelsize = chars[i].role.playermodelsize
					tmpChar.skin = chars[i].char.skin
					tmpChar.bg0 = chars[i].char.bg0 or 0
					tmpChar.bg1 = chars[i].char.bg1 or 0
					tmpChar.bg2 = chars[i].char.bg2 or 0
					tmpChar.bg3 = chars[i].char.bg3 or 0
					tmpChar.bg4 = chars[i].char.bg4 or 0
					tmpChar.bg5 = chars[i].char.bg5 or 0
					tmpChar.bg6 = chars[i].char.bg6 or 0
					tmpChar.bg7 = chars[i].char.bg7 or 0
					tmpChar.bg8 = chars[i].char.bg8 or 0
					tmpChar.bg9 = chars[i].char.bg9 or 0
					tmpChar.bg10 = chars[i].char.bg10 or 0
					tmpChar.bg11 = chars[i].char.bg11 or 0
					tmpChar.bg12 = chars[i].char.bg12 or 0
					tmpChar.bg13 = chars[i].char.bg13 or 0
					tmpChar.bg14 = chars[i].char.bg14 or 0
					tmpChar.bg15 = chars[i].char.bg15 or 0
					tmpChar.bg16 = chars[i].char.bg16 or 0
					tmpChar.bg17 = chars[i].char.bg17 or 0
					tmpChar.bg18 = chars[i].char.bg18 or 0
					tmpChar.bg19 = chars[i].char.bg19 or 0

					tmpChar.grp = tmpChar.groupID
					tmpChar.fac = tmpChar.factionID
					if tmpChar.grp == tmpChar.fac then
						tmpChar.grp = ""
					end
					tmpChar.rol = tmpChar.rolename

					if IsLevelSystemEnabled() then
						tmpChar.rol = YRP.lang_string("LID_level") .. " " .. tmpChar.level .. "    " .. tmpChar.rol
					end

					if YRP_CharDesign != "horizontalnew" then
						function tmpChar:Paint(pw, ph)
							if curChar == -1 then
								curChar = tonumber(LocalPlayer():CharID())
							end

							if tmpChar.bool_eventchar then
								if curChar == self.charid then
									draw.RoundedBox(0, 0, 0, pw, ph, Color(100, 100, 255, 160))
								end
								if tmpChar:IsHovered() then
									draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 255, 255, 20))
								end
	
								local x = YRP.ctr(30)
								if !strEmpty(self.factionIcon) then
									x = ph
								end
								draw.SimpleText(YRP.lang_string("LID_event") .. ": " .. self.rpname, "Y_32_500", x, YRP.ctr(35), Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
								draw.SimpleText(self.fac, "Y_18_500", x, YRP.ctr(85), Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
								draw.SimpleText(self.grp, "Y_18_500", x, YRP.ctr(125), Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
								draw.SimpleText(self.rol, "Y_18_500", x, YRP.ctr(165), Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
								if cei > LocalPlayer():GetNW2Int("int_charactersevent_max", 1) then
									draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 100, 100, 100))
									draw.SimpleText("X", "Y_72_500", pw / 2, ph / 2, Color(255, 255, 100, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
								end
							else
								if curChar == self.charid then
									draw.RoundedBox(0, 0, 0, pw, ph, Color(100, 100, 255, 160))
								end
								if tmpChar:IsHovered() then
									draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 255, 255, 20))
								end

								local x = YRP.ctr(30)
								if !strEmpty(self.factionIcon) then
									x = ph
								end
								draw.SimpleText(self.rpname, "Y_32_500", x, YRP.ctr(35), Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
								draw.SimpleText(self.fac, "Y_18_500", x, YRP.ctr(85), Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
								draw.SimpleText(self.grp, "Y_18_500", x, YRP.ctr(125), Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
								draw.SimpleText(self.rol, "Y_18_500", x, YRP.ctr(165), Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

								if cni > LocalPlayer():GetNW2Int("int_characters_max", 1) then
									draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 100, 100, 100))
									draw.SimpleText("X", "Y_72_500", pw / 2, ph / 2, Color(255, 255, 100, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
								end
							end
						end
						function tmpChar:DoClick()
							isEventChar = self.bool_eventchar
							if cni <= LocalPlayer():GetNW2Int("int_characters_max", 1) then
								curChar = tonumber(self.charid)
								_cur = self.rpname
								if self.playermodels != nil and self.playermodelID != nil then
									local _playermodel = self.playermodels[self.playermodelID] or nil
									if _playermodel != nil and CharMenu.charplayermodel != NULL and pa(CharMenu.charplayermodel) then
										if !strEmpty(_playermodel) then
											CharMenu.charplayermodel:SetModel(_playermodel)
										else
											CharMenu.charplayermodel:SetModel("models/player/skeleton.mdl")
										end
										if CharMenu.charplayermodel.Entity != nil then
											CharMenu.charplayermodel.Entity:SetModelScale(self.playermodelsize or 1)
											CharMenu.charplayermodel.Entity:SetSkin(self.skin)
											for bgx = 0, 19 do
												CharMenu.charplayermodel.Entity:SetBodygroup(bgx, self["bg" .. bgx])
											end
										end
									end
								else
									YRP.msg("note", "Character role has no playermodel!")
								end
							end
						end

						if !strEmpty(tmpChar.factionIcon) then
							local icon = createD("DHTML", tmpChar, tmpChar:GetTall() * 0.8, tmpChar:GetTall() * 0.8, tmpChar:GetTall() * 0.1, tmpChar:GetTall() * 0.1)
							icon:SetHTML(GetHTMLImage(tmpChar.factionIcon, icon:GetWide(), icon:GetTall()))
						end
					else
						function tmpChar:Paint(pw, ph)
							draw.RoundedBox(0, 0, 0, pw, ph, Color(51, 51, 51, 200))

							draw.SimpleText(self.rpname, "Saira_60", pw / 2, YRP.ctr(100), Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

							if cni > LocalPlayer():GetNW2Int("int_characters_max", 1) then
								draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 100, 100, 100))
								draw.SimpleText("X", "Y_72_500", pw / 2, ph / 2, Color(255, 255, 100, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
							end
						end

						tmpChar.charplayermodel = createD("DModelPanel", tmpChar, tmpChar:GetWide(), tmpChar:GetTall(), 0, 0)
						tmpChar.charplayermodel:SetModel("models/player/skeleton.mdl")
						tmpChar.charplayermodel:SetAnimated(true)
						tmpChar.charplayermodel.Angles = Angle(0, 0, 0)
						tmpChar.charplayermodel:RunAnimation()

						function tmpChar.charplayermodel:DragMousePress()
							self.PressX, self.PressY = gui.MousePos()
							self.Pressed = true
						end
						function tmpChar.charplayermodel:DragMouseRelease() self.Pressed = false end

						function tmpChar.charplayermodel:LayoutEntity(ent)
							local _playermodel = tmpChar.playermodels[tmpChar.playermodelID] or nil
							if _playermodel == nil or strEmpty(_playermodel) then
								_playermodel = "models/player/skeleton.mdl"
							end
							if self.pm != _playermodel then
								self.pm = _playermodel
								tmpChar.charplayermodel:SetModel(self.pm)
							end

							if (self.bAnimated) then self:RunAnimation() end

							if (self.Pressed) then
								local mx, _ = gui.MousePos()
								self.Angles = self.Angles - Angle(0, (self.PressX or mx) - mx, 0)

								self.PressX, self.PressY = gui.MousePos()
								if ent != nil then
									ent:SetAngles(self.Angles)
								end
							end
						end
						
						local button = {}
						button.w = YRP.ctr(200*2)
						button.h = YRP.ctr(36*2)
						button.x = tmpChar:GetWide() / 2 - button.w / 2
						button.y = tmpChar:GetTall() - YRP.ctr(20*2) - button.h
						local charactersEnter = createD("YButton", tmpChar, button.w, button.h, button.x, button.y)
						function charactersEnter:Paint(pw, ph)
							if tmpChar.bool_eventchar then
								draw.SimpleText("EVENT CHARACTER", "Y_24_500", pw / 2, ph / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
							else
								local tab = {}
								tab.text = math.Round(LocalPlayer():GetNW2Int("int_deathtimestamp_min", 0) - CurTime(), 0)
								if LocalPlayer():GetNW2Int("int_deathtimestamp_min", 0) <= CurTime() then
									tab.text = YRP.lang_string("LID_enterworld") -- .. " (" .. _cur .. ")"
								end
								if LocalPlayer() != nil and LocalPlayer():Alive() then
									tab.text = YRP.lang_string("LID_suicide") .. " (" .. LocalPlayer():RPName() .. ")"
									tab.color = Color(255, 100, 100, 255)
								end
				
								local hasdesign = hook.Run("YButtonPaint", self, pw, ph, tab)
								if !hasdesign then
									draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 255, 255))
									draw.SimpleTextOutlined(tab.text, "Y_24_500", pw / 2, ph / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
								end
							end
						end
			
						charactersEnter:SetText("")
						function charactersEnter:DoClick()
							if tmpChar.bool_eventchar then
								-- nothing
							else
								if LocalPlayer() != nil and tonumber(tmpChar.charid) != "-1" and LocalPlayer():GetNW2Int("int_deathtimestamp_min", 0) <= CurTime() then
									if LocalPlayer():Alive() then
										net.Start("LogOut")
										net.SendToServer()
									elseif tonumber(tmpChar.charid) != nil then
										net.Start("YRP_EnterWorld")
											net.WriteString(tmpChar.charid)
										net.SendToServer()
										if pa(CharMenu.frame) then
											CharMenu.frame:Close()
										end
									end
								end
							end
						end
			
						local px, py = charactersEnter:GetPos()
			
						local deleteChar = createD("YButton", tmpChar, button.h - 2 * YRP.ctr(10), button.h - 2 * YRP.ctr(10), px - YRP.ctr(10) - button.h, py + YRP.ctr(10))
						deleteChar:SetText("")
						function deleteChar:Paint(pw, ph)
							--hook.Run("YRemovePaint", self, pw, ph)
							local color = Color(160, 160, 160, 255)
							if self:IsHovered() then
								color = Color(255, 255, 255, 255)
							end
							if trashicon then
								surface.SetMaterial(trashicon)
								surface.SetDrawColor(color)
								surface.DrawTexturedRect(0, 0, pw, ph)
							end
						end
						function deleteChar:DoClick()
							local _window = createVGUI("DFrame", nil, 430, 50 + 10 + 50 + 10, 0, 0)
							_window:Center()
							_window:SetTitle(YRP.lang_string("LID_areyousure"))
			
							local _yesButton = createVGUI("DButton", _window, 200, 50, 10, 60)
							_yesButton:SetText(YRP.lang_string("LID_yes"))
							function _yesButton:DoClick()
			
								net.Start("DeleteCharacter")
									net.WriteString(tmpChar.charid)
								net.SendToServer()
			
								_window:Close()
							end
			
							local _noButton = createVGUI("DButton", _window, 200, 50, 10 + 200 + 10, 60)
							_noButton:SetText(YRP.lang_string("LID_no"))
							function _noButton:DoClick()
								_window:Close()
							end
			
							_window:MakePopup()
						end
					end

					if chars[i].char.uniqueID == LocalPlayer():CharID() then
						curChar = tonumber(LocalPlayer():CharID())
						tmpChar:DoClick()
					end

					if CharMenu.characterList.AddItem then
						CharMenu.characterList:AddItem(cache[i].tmpChar)
					else
						CharMenu.characterList:AddPanel(cache[i].tmpChar)
					end

					y = y + 1
				end

				i = i + 1
			end
			
			if YRP_CharDesign == "horizontalnew" then
				local sw = YRP.ctr(fw) - 2 * br
				local sh = YRP.ctr(200)
				local px = 0
				local py = 0
				if YRP_CharDesign == "horizontalnew" then
					sw = YRP.ctr(350*2)
					sh = YRP.ctr(600*2)
					px = 0
					py = 0
				end

				if CharMenu.character.amount < LocalPlayer():GetNW2Int("int_characters_max", 1) then
					local addChar = createD("YButton", nil, sw, sh, px, py)
					addChar:SetText("")
					function addChar:Paint(pw, ph)
						if CharMenu.character.amount < LocalPlayer():GetNW2Int("int_characters_max", 1) then
							draw.RoundedBox(0, 0, 0, pw, ph, Color(51, 51, 51, 200))
							
							local sw = pw - 2 * YRP.ctr(180)
							local breite = YRP.ctr(50)
							if YRP.GetDesignIcon("add") ~= nil then
								draw.RoundedBox(breite / 2, pw / 2 - breite / 2, ph / 2 - sw / 2, breite, sw, Color(102, 102, 102, 255))
								draw.RoundedBox(breite / 2, pw / 2 - sw / 2, ph / 2 - breite / 2, sw, breite, Color(102, 102, 102, 255))
							end
						end
					end
					function addChar:DoClick()
						isEventChar = self.bool_eventchar
						if CharMenu.character.amount < LocalPlayer():GetNW2Int("int_characters_max", 1) then
							if pa(CharMenu.frame) then
								CharMenu.frame:Close()
							end
							SetGlobalBool("create_eventchar", false)
							openCharacterCreation()
						end
					end

					if CharMenu.characterList.AddItem then
						CharMenu.characterList:AddItem(addChar)
					else
						CharMenu.characterList:AddPanel(addChar)
					end
				end

				if CharMenu.character.amountevent < LocalPlayer():GetNW2Int("int_charactersevent_max", 1) then
					local addCharEvent = createD("YButton", nil, sw, sh, px, py)
					addCharEvent:SetText("")
					function addCharEvent:Paint(pw, ph)
						if CharMenu.character.amountevent and CharMenu.character.amountevent < LocalPlayer():GetNW2Int("int_charactersevent_max", 1) then
							draw.RoundedBox(0, 0, 0, pw, ph, Color(51, 51, 51, 200))
							
							draw.SimpleText(YRP.lang_string("LID_event"), "Y_18_500", pw / 2, YRP.ctr(300), Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

							local sw = pw - 2 * YRP.ctr(180)
							local breite = YRP.ctr(50)
							if YRP.GetDesignIcon("add") ~= nil then
								draw.RoundedBox(breite / 2, pw / 2 - breite / 2, ph / 2 - sw / 2, breite, sw, Color(102, 102, 102, 255))
								draw.RoundedBox(breite / 2, pw / 2 - sw / 2, ph / 2 - breite / 2, sw, breite, Color(102, 102, 102, 255))
							end
						end
					end
					function addCharEvent:DoClick()
						if CharMenu.character.amountevent < LocalPlayer():GetNW2Int("int_charactersevent_max", 1) then
							if pa(CharMenu.frame) then
								CharMenu.frame:Close()
							end
							SetGlobalBool("create_eventchar", true)
							openCharacterCreation()
						end
					end

					if CharMenu.characterList.AddItem then
						CharMenu.characterList:AddItem(addCharEvent)
					else
						CharMenu.characterList:AddPanel(addCharEvent)
					end
				end
			end
		end
	end

	if CharMenu.characterList:GetWide() > CharMenu.characterList:GetCanvas():GetWide() then
		CharMenu.characterList:SetWide(CharMenu.characterList:GetCanvas():GetWide())
		local px, py = CharMenu.characterList:GetPos()
		CharMenu.characterList:SetPos(CharMenu.charactersBackground:GetWide() / 2 - CharMenu.characterList:GetWide() / 2, py)
	end

	if pa(CharMenu.frame) then
		CharMenu.frame:Show()
		CharMenu.frame:MakePopup()
	end
end
net.Receive("yrp_get_characters", function(len)
	local first = net.ReadBool()
	if first and pa(CharMenu.characterList) then
		chars = {}
		CharMenu.characterList:Clear()
	end
	local char = net.ReadTable()
	local last = net.ReadBool()
	table.insert(chars, char)
	if last then
		LoadCharacters()
	end
end)

function openCharacterSelection()
	if !loading then
		loading = true
		timer.Simple(0.3, function()
			loading = false
		end)
	else
		return
	end

	chars = {}

	CharMenu.character = {}
	CharMenu.character.amount = 0

	openMenu()
	
	if !pa(CharMenu.frame) then
		YRP_CharDesign = string.lower(GetGlobalString("text_character_design"))

		function CharMenu.logic()
			if YRP_CharDesign != string.lower(GetGlobalString("text_character_design")) then
				YRP_CharDesign = string.lower(GetGlobalString("text_character_design"))

				if CharMenu.frame and CharMenu.frame:IsVisible() then
					closeMenu()
					CharMenu.frame:Remove()
					CharMenu.frame = nil
					openCharacterSelection()
				end
			end
			timer.Simple(1, CharMenu.logic)
		end
		CharMenu.logic()

		CharMenu.frame = createD("DFrame", nil, ScrW(), ScrH(), 0, 0)

		if YRP_CharDesign == "vertical" then
			CharMenu.frame:Hide()
			CharMenu.frame:SetTitle("")
			CharMenu.frame:ShowCloseButton(false)
			CharMenu.frame:SetDraggable(false)
			CharMenu.frame:Center()
			function CharMenu.frame:Paint(pw, ph)
				draw.RoundedBox(0, 0, 0, pw, ph, Color(40, 40, 40, 255)) -- Dark Background - Character Selection [vertical]
			end
			function CharMenu.frame:OnClose()
				closeMenu()
			end
			function CharMenu.frame:OnRemove()
				closeMenu()
			end

			CharMenu.frame.bg = createD("DHTML", CharMenu.frame, ScrW(), ScrH(), 0, 0)
			CharMenu.frame.bg.url = ""

			CharMenu.frame.bgcf = createD("DPanel", CharMenu.frame.bg, CharMenu.frame.bg:GetWide(), CharMenu.frame.bg:GetTall(), 0, 0)
			function CharMenu.frame.bgcf:Paint(pw, ph)
				-- Blur Background
				Derma_DrawBackgroundBlur(self, 0)

				
				-- Header of Menu
				draw.SimpleText(YRP.lang_string("LID_characterselection"), "Y_18_500", pw / 2, YRP.ctr(50), Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				-- Current Character Name
				draw.SimpleText(_cur, "Y_40_500", pw / 2, YRP.ctr(110), Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				local aecur = CharMenu.character.amountevent or -1
				local aemax = LocalPlayer():GetNW2Int("int_charactersevent_max", 1)
				if aecur < aemax then
					draw.SimpleText(YRP.lang_string("LID_event"), "Y_24_500", pw / 2 - YRP.ctr(480), ph - YRP.ctr(180), Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end

				-- Get Newest Background for the Menu
				local oldurl = CharMenu.frame.bg.url
				local newurl = GetGlobalString("text_character_background", "")
				if oldurl != newurl then
					CharMenu.frame.bg.url = newurl
					CharMenu.frame.bg:SetHTML(GetHTMLImage(newurl, ScrW(), ScrH())) -- url?
				end
				if newurl and strEmpty(newurl) then
					draw.SimpleText(charbgnotfound, "Y_26_500", pw / 2, ph / 5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end

			-- Language Changer / LanguageChanger
			YRP.DChangeLanguage(CharMenu.frame, ScrW() - YRP.ctr(100 + 20), YRP.ctr(20), YRP.ctr(100))

			local border = YRP.ctr(50)
			CharMenu.charactersBackground = createD("DPanel", CharMenu.frame, YRP.ctr(fw), ScrH() - (2 * border), (ScrW() - ScW()) / 2 + border, border)
			CharMenu.charactersBackground.text = YRP.lang_string("LID_siteisloading")
			function CharMenu.charactersBackground:Paint(pw, ph)
				local color = LocalPlayer():InterfaceValue("YFrame", "NC")
				draw.RoundedBox(YRP.ctr(10), 0, 0, pw, ph, Color(color.r, color.g, color.b, 100))

				local acur = CharMenu.character.amount or -1
				local amax = LocalPlayer():GetNW2Int("int_characters_max", 1)
				local acolor = Color(255, 255, 255, 255)
				if acur > amax then
					acolor = Color(255, 100, 100, 255)
				end

				local aecur = CharMenu.character.amountevent or -1
				local aemax = LocalPlayer():GetNW2Int("int_charactersevent_max", 1)
				local aecolor = Color(255, 255, 255, 255)
				if aecur > aemax then
					aecolor = Color(255, 100, 100, 255)
				end

				-- Current and Max Count of Possible Characters
				if aemax > 0 then
					draw.SimpleText(acur .. "/" .. amax, "Y_36_500", YRP.ctr(20), ph - YRP.ctr(50), acolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				else
					draw.SimpleText(acur .. "/" .. amax, "Y_36_500", pw / 2, ph - YRP.ctr(50), acolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end

				-- Current and Max Count of Possible Characters
				if aemax > 0 then
					draw.SimpleText(YRP.lang_string("LID_event") .. ": " .. aecur .. "/" .. aemax, "Y_36_500", pw - YRP.ctr(20), ph - YRP.ctr(50), aecolor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				end

				draw.SimpleText(self.text, "Y_36_500", pw / 2, YRP.ctr(50), Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			CharMenu.charplayermodel = createD("DModelPanel", CharMenu.frame, ScrH() - YRP.ctr(200), ScrH() - YRP.ctr(200), ScrW2() - (ScrH() - YRP.ctr(200)) / 2, 0)
			CharMenu.charplayermodel:SetModel("models/player/skeleton.mdl")
			CharMenu.charplayermodel:SetAnimated(true)
			CharMenu.charplayermodel.Angles = Angle(0, 0, 0)
			CharMenu.charplayermodel:RunAnimation()

			function CharMenu.charplayermodel:DragMousePress()
				self.PressX, self.PressY = gui.MousePos()
				self.Pressed = true
			end
			function CharMenu.charplayermodel:DragMouseRelease() self.Pressed = false end

			function CharMenu.charplayermodel:LayoutEntity(ent)

				if (self.bAnimated) then self:RunAnimation() end

				if (self.Pressed) then
					local mx, _ = gui.MousePos()
					self.Angles = self.Angles - Angle(0, (self.PressX or mx) - mx, 0)

					self.PressX, self.PressY = gui.MousePos()
					if ent != nil then
						ent:SetAngles(self.Angles)
					end
				end
			end

			CharMenu.characterList = createD("DPanelList", CharMenu.charactersBackground, YRP.ctr(fw) - 2 * br, ScrH() - (2 * border) - br - YRP.ctr(120), br, br)
			CharMenu.characterList:EnableVerticalScrollbar()
			CharMenu.characterList:SetSpacing(YRP.ctr(20))
			function CharMenu.characterList:Paint(pw, ph)
				--draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 0, 0, 255))
			end
			local sbar = CharMenu.characterList.VBar
			function sbar:Paint(w, h)
				local lply = LocalPlayer()
				draw.RoundedBox(0, 0, 0, w, h, lply:InterfaceValue("YFrame", "NC"))
			end
			function sbar.btnUp:Paint(w, h)
				draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 60))
			end
			function sbar.btnDown:Paint(w, h)
				draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 60))
			end
			function sbar.btnGrip:Paint(w, h)
				local lply = LocalPlayer()
				draw.RoundedBox(w / 2, 0, 0, w, h, lply:InterfaceValue("YFrame", "HI"))
			end

			timer.Simple(0.1, function()
				--YRP.msg("gm", "ask for characterlist")

				net.Start("yrp_get_characters")
				net.SendToServer()
			end)

			local button = {}
			button.w = YRP.ctr(600)
			button.h = YRP.ctr(100)
			button.x = ScrW2() - button.w / 2
			button.y = ScrH() - button.h - border
			local charactersEnter = createD("YButton", CharMenu.frame, button.w, button.h, button.x, button.y)
			function charactersEnter:Paint(pw, ph)
				if isEventChar then
					draw.SimpleText("EVENT CHARACTER", "Y_24_500", pw / 2, ph / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				else
					local tab = {}
					tab.text = math.Round(LocalPlayer():GetNW2Int("int_deathtimestamp_min", 0) - CurTime(), 0)
					if LocalPlayer():GetNW2Int("int_deathtimestamp_min", 0) <= CurTime() then
						tab.text = YRP.lang_string("LID_enterworld") -- .. " (" .. _cur .. ")"
					end
					if LocalPlayer() != nil and LocalPlayer():Alive() then
						tab.text = YRP.lang_string("LID_suicide") .. " (" .. LocalPlayer():RPName() .. ")"
						tab.color = Color(255, 100, 100, 255)
					end

					local hasdesign = hook.Run("YButtonPaint", self, pw, ph, tab)
					if !hasdesign then
						draw.RoundedBox(10, 0, 0, pw, ph, Color(255, 255, 255))
						draw.SimpleTextOutlined(tab.text, "Y_24_500", pw / 2, ph / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
					end
				end
			end

			charactersEnter:SetText("")
			function charactersEnter:DoClick()
				if isEventChar then
					-- nothing
				else
					if LocalPlayer() != nil and curChar != "-1" and LocalPlayer():GetNW2Int("int_deathtimestamp_min", 0) <= CurTime() then
						if LocalPlayer():Alive() then
							net.Start("LogOut")
							net.SendToServer()
						elseif curChar != nil then
							net.Start("YRP_EnterWorld")
								net.WriteString(curChar)
							net.SendToServer()
							if pa(CharMenu.frame) then
								CharMenu.frame:Close()
							end
						end
					end
				end
			end

			local px, py = charactersEnter:GetPos()

			local deleteChar = createD("YButton", CharMenu.frame, YRP.ctr(100), YRP.ctr(100), px + br + button.w, py)
			deleteChar:SetText("")
			function deleteChar:Paint(pw, ph)
				hook.Run("YRemovePaint", self, pw, ph)
			end
			function deleteChar:DoClick()
				local _window = createVGUI("DFrame", nil, 430, 50 + 10 + 50 + 10, 0, 0)
				_window:Center()
				_window:SetTitle(YRP.lang_string("LID_areyousure"))

				local _yesButton = createVGUI("DButton", _window, 200, 50, 10, 60)
				_yesButton:SetText(YRP.lang_string("LID_yes"))
				function _yesButton:DoClick()

					net.Start("DeleteCharacter")
						net.WriteString(curChar)
					net.SendToServer()

					_window:Close()
				end

				local _noButton = createVGUI("DButton", _window, 200, 50, 10 + 200 + 10, 60)
				_noButton:SetText(YRP.lang_string("LID_no"))
				function _noButton:DoClick()
					_window:Close()
				end

				_window:MakePopup()
			end

			local charactersCreate = createD("YButton", CharMenu.frame, YRP.ctr(100), YRP.ctr(100), px - br - YRP.ctr(100), py)
			charactersCreate:SetText("")
			function charactersCreate:Paint(pw, ph)
				if CharMenu.character.amount < LocalPlayer():GetNW2Int("int_characters_max", 1) then
					hook.Run("YAddPaint", self, pw, ph)
				end
			end
			function charactersCreate:DoClick()
				if CharMenu.character.amount < LocalPlayer():GetNW2Int("int_characters_max", 1) then
					if pa(CharMenu.frame) then
						CharMenu.frame:Close()
					end
					SetGlobalBool("create_eventchar", false)
					openCharacterCreation()
				end
			end

			local charactersCreateEvent = createD("YButton", CharMenu.frame, YRP.ctr(100), YRP.ctr(100), px - br - YRP.ctr(210), py)
			charactersCreateEvent:SetText("")
			function charactersCreateEvent:Paint(pw, ph)
				if CharMenu.character.amountevent < LocalPlayer():GetNW2Int("int_charactersevent_max", 1) then
					hook.Run("YAddPaint", self, pw, ph)
				end
			end
			function charactersCreateEvent:DoClick()
				if CharMenu.character.amountevent < LocalPlayer():GetNW2Int("int_charactersevent_max", 1) then
					if pa(CharMenu.frame) then
						CharMenu.frame:Close()
					end
					SetGlobalBool("create_eventchar", true)
					openCharacterCreation()
				end
			end
		elseif YRP_CharDesign == "horizontal" then -- Horizontal
			CharMenu.frame:Hide()
			CharMenu.frame:SetTitle("")
			CharMenu.frame:ShowCloseButton(false)
			CharMenu.frame:SetDraggable(false)
			CharMenu.frame:Center()
			function CharMenu.frame:Paint(pw, ph)
				draw.RoundedBox(0, 0, 0, pw, ph, Color(40, 40, 40, 255)) -- Dark Background - Character Selection [horizontal]
			end
			function CharMenu.frame:OnClose()
				closeMenu()
			end
			function CharMenu.frame:OnRemove()
				closeMenu()
			end

			CharMenu.frame.bg = createD("DHTML", CharMenu.frame, ScrW(), ScrH(), 0, 0)
			CharMenu.frame.bg.url = ""

			CharMenu.frame.bgcf = createD("DPanel", CharMenu.frame.bg, CharMenu.frame.bg:GetWide(), CharMenu.frame.bg:GetTall(), 0, 0)
			function CharMenu.frame.bgcf:Paint(pw, ph)
				-- Blur Background
				Derma_DrawBackgroundBlur(self, 0)
				
				-- Header of Menu
				draw.SimpleText(YRP.lang_string("LID_characterselection"), "Y_18_500", pw / 2, YRP.ctr(50), Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				-- Current Character Name
				draw.SimpleText(_cur, "Y_40_500", pw / 2, YRP.ctr(110), Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				-- Get Newest Background for the Menu
				local oldurl = CharMenu.frame.bg.url
				local newurl = GetGlobalString("text_character_background", "")
				if oldurl != newurl then
					CharMenu.frame.bg.url = newurl
					CharMenu.frame.bg:SetHTML(GetHTMLImage(newurl, ScrW(), ScrH())) -- url?
				end
				if newurl and strEmpty(newurl) then
					draw.SimpleText(charbgnotfound, "Y_26_500", pw / 2, ph / 5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end

				local acur = CharMenu.character.amount or -1
				local amax = LocalPlayer():GetNW2Int("int_characters_max", 1)
				local acolor = Color(255, 255, 255, 255)
				if acur > amax then
					acolor = Color(255, 100, 100, 255)
				end

				local aecur = CharMenu.character.amountevent or -1
				local aemax = LocalPlayer():GetNW2Int("int_charactersevent_max", 1)
				local aecolor = Color(255, 255, 255, 255)
				if aecur > aemax then
					aecolor = Color(255, 100, 100, 255)
				end

				-- Current and Max Count of Possible Characters
				draw.SimpleText(acur .. "/" .. amax, "Y_36_500", pw - br - YRP.ctr(100), ph - br - YRP.ctr(200) - br - YRP.ctr(100), color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				-- Current and Max Count of Possible Characters
				if aemax > 0 then
					draw.SimpleText(YRP.lang_string("LID_event") .. ": " .. aecur .. "/" .. aemax, "Y_36_500", pw - br - YRP.ctr(600), ph - br - YRP.ctr(200) - br - YRP.ctr(100), color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end

			-- Language Changer / LanguageChanger
			YRP.DChangeLanguage(CharMenu.frame, ScrW() - YRP.ctr(100 + 20), YRP.ctr(20), YRP.ctr(100))

			local border = YRP.ctr(50)
			CharMenu.charactersBackground = createD("DPanel", CharMenu.frame, ScrW() - (2 * br), YRP.ctr(200) + (2 * br), br, ScrH() - YRP.ctr(200) - 2 * br - br)
			CharMenu.charactersBackground.text = YRP.lang_string("LID_siteisloading")
			function CharMenu.charactersBackground:Paint(pw, ph)
				local color = LocalPlayer():InterfaceValue("YFrame", "NC")
				draw.RoundedBox(YRP.ctr(10), 0, 0, pw, ph, Color(color.r, color.g, color.b, 120))

				draw.SimpleText(self.text, "Y_36_500", pw / 2, YRP.ctr(50), Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			local size = ScrH() - br - br - YRP.ctr(200) - br - br - br - YRP.ctr(100) - br - br
			CharMenu.charplayermodel = createD("DModelPanel", CharMenu.frame, size, size, ScrW2() - (size) / 2, br)
			CharMenu.charplayermodel:SetModel("models/player/skeleton.mdl")
			CharMenu.charplayermodel:SetAnimated(true)
			CharMenu.charplayermodel.Angles = Angle(0, 0, 0)
			CharMenu.charplayermodel:RunAnimation()

			function CharMenu.charplayermodel:DragMousePress()
				self.PressX, self.PressY = gui.MousePos()
				self.Pressed = true
			end
			function CharMenu.charplayermodel:DragMouseRelease() self.Pressed = false end

			function CharMenu.charplayermodel:LayoutEntity(ent)

				if (self.bAnimated) then self:RunAnimation() end

				if (self.Pressed) then
					local mx, _ = gui.MousePos()
					self.Angles = self.Angles - Angle(0, (self.PressX or mx) - mx, 0)

					self.PressX, self.PressY = gui.MousePos()
					if ent != nil then
						ent:SetAngles(self.Angles)
					end
				end
			end

			CharMenu.characterList = createD("DHorizontalScroller", CharMenu.charactersBackground, CharMenu.charactersBackground:GetWide() - 2 * br, CharMenu.charactersBackground:GetTall() - 2 * br, br, br)
			--CharMenu.characterList:EnableVerticalScrollbar()
			CharMenu.characterList:SetOverlap(-YRP.ctr(20))
			function CharMenu.characterList:Paint(pw, ph)
				--draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 0, 0, 255))
			end
			
			timer.Simple(0.1, function()
				--YRP.msg("gm", "ask for characterlist")

				net.Start("yrp_get_characters")
				net.SendToServer()
			end)

			local button = {}
			button.w = YRP.ctr(600)
			button.h = YRP.ctr(100)
			button.x = ScrW2() - button.w / 2
			button.y = ScrH() - br - YRP.ctr(200) - br - br - br - button.h
			local charactersEnter = createD("YButton", CharMenu.frame, button.w, button.h, button.x, button.y)
			function charactersEnter:Paint(pw, ph)
				if isEventChar then
					draw.SimpleText("EVENT CHARACTER", "Y_24_500", pw / 2, ph / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
				else
					local tab = {}
					tab.text = math.Round(LocalPlayer():GetNW2Int("int_deathtimestamp_min", 0) - CurTime(), 0)
					if LocalPlayer():GetNW2Int("int_deathtimestamp_min", 0) <= CurTime() then
						tab.text = YRP.lang_string("LID_enterworld") -- .. " (" .. _cur .. ")"
					end
					if LocalPlayer() != nil and LocalPlayer():Alive() then
						tab.text = YRP.lang_string("LID_suicide") .. " (" .. LocalPlayer():RPName() .. ")"
						tab.color = Color(255, 100, 100, 255)
					end

					local hasdesign = hook.Run("YButtonPaint", self, pw, ph, tab)
					if !hasdesign then
						draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 255, 255))
						draw.SimpleTextOutlined(tab.text, "Y_24_500", pw / 2, ph / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
					end
				end
			end

			charactersEnter:SetText("")
			function charactersEnter:DoClick()
				if isEventChar then
					-- nothing
				else
					if LocalPlayer() != nil and curChar != "-1" and LocalPlayer():GetNW2Int("int_deathtimestamp_min", 0) <= CurTime() then
						if LocalPlayer():Alive() then
							net.Start("LogOut")
							net.SendToServer()
						elseif curChar != nil then
							net.Start("YRP_EnterWorld")
								net.WriteString(curChar)
							net.SendToServer()
							if pa(CharMenu.frame) then
								CharMenu.frame:Close()
							end
						end
					end
				end
			end

			local px, py = charactersEnter:GetPos()

			local deleteChar = createD("YButton", CharMenu.frame, YRP.ctr(100), YRP.ctr(100), px + br + button.w, py)
			deleteChar:SetText("")
			function deleteChar:Paint(pw, ph)
				hook.Run("YRemovePaint", self, pw, ph)
			end
			function deleteChar:DoClick()
				local _window = createVGUI("DFrame", nil, 430, 50 + 10 + 50 + 10, 0, 0)
				_window:Center()
				_window:SetTitle(YRP.lang_string("LID_areyousure"))

				local _yesButton = createVGUI("DButton", _window, 200, 50, 10, 60)
				_yesButton:SetText(YRP.lang_string("LID_yes"))
				function _yesButton:DoClick()

					net.Start("DeleteCharacter")
						net.WriteString(curChar)
					net.SendToServer()

					_window:Close()
				end

				local _noButton = createVGUI("DButton", _window, 200, 50, 10 + 200 + 10, 60)
				_noButton:SetText(YRP.lang_string("LID_no"))
				function _noButton:DoClick()
					_window:Close()
				end

				_window:MakePopup()
			end

			local charactersCreate = createD("YButton", CharMenu.frame, YRP.ctr(100), YRP.ctr(100), px - br - YRP.ctr(100), py)
			charactersCreate:SetText("")
			function charactersCreate:Paint(pw, ph)
				if CharMenu.character.amount < LocalPlayer():GetNW2Int("int_characters_max", 1) then
					hook.Run("YAddPaint", self, pw, ph)
				end
			end
			function charactersCreate:DoClick()
				if CharMenu.character.amount < LocalPlayer():GetNW2Int("int_characters_max", 1) then
					if pa(CharMenu.frame) then
						CharMenu.frame:Close()
					end
					SetGlobalBool("create_eventchar", false)
					openCharacterCreation()
				end
			end
			
			local charactersCreateEvent = createD("YButton", CharMenu.frame, YRP.ctr(100), YRP.ctr(100), px - br - YRP.ctr(210), py)
			charactersCreateEvent:SetText("")
			function charactersCreateEvent:Paint(pw, ph)
				if CharMenu.character.amountevent < LocalPlayer():GetNW2Int("int_charactersevent_max", 1) then
					hook.Run("YAddPaint", self, pw, ph)
				end
			end
			function charactersCreateEvent:DoClick()
				if CharMenu.character.amountevent < LocalPlayer():GetNW2Int("int_charactersevent_max", 1) then
					if pa(CharMenu.frame) then
						CharMenu.frame:Close()
					end
					SetGlobalBool("create_eventchar", true)
					openCharacterCreation()
				end
			end
		elseif YRP_CharDesign == "horizontalnew" then -- HorizontalNEW
			CharMenu.frame:Hide()
			CharMenu.frame:SetTitle("")
			CharMenu.frame:ShowCloseButton(false)
			CharMenu.frame:SetDraggable(false)
			CharMenu.frame:Center()
			function CharMenu.frame:Paint(pw, ph)
				draw.RoundedBox(0, 0, 0, pw, ph, Color(40, 40, 40, 255)) -- Dark Background - Character Selection [horizontalnew]
			end
			function CharMenu.frame:OnClose()
				closeMenu()
			end
			function CharMenu.frame:OnRemove()
				closeMenu()
			end

			CharMenu.frame.bg = createD("DHTML", CharMenu.frame, ScrW(), ScrH(), 0, 0)
			CharMenu.frame.bg.url = ""

			CharMenu.frame.bgcf = createD("DPanel", CharMenu.frame.bg, CharMenu.frame.bg:GetWide(), CharMenu.frame.bg:GetTall(), 0, 0)
			function CharMenu.frame.bgcf:Paint(pw, ph)
				-- Blur Background
				Derma_DrawBackgroundBlur(self, 0)

				-- Get Newest Background for the Menu
				local oldurl = CharMenu.frame.bg.url
				local newurl = GetGlobalString("text_character_background", "")
				if oldurl != newurl then
					CharMenu.frame.bg.url = newurl
					CharMenu.frame.bg:SetHTML(GetHTMLImage(newurl, ScrW(), ScrH())) -- url?
				end
				if newurl and strEmpty(newurl) then
					draw.SimpleText(charbgnotfound, "Y_26_500", pw / 2, ph / 5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end

				-- Current and Max Count of Possible Characters
				local acur = CharMenu.character.amount or -1
				local amax = LocalPlayer():GetNW2Int("int_characters_max", 1)
				local acolor = Color(255, 255, 255, 255)
				if acur > amax then
					acolor = Color(255, 100, 100, 255)
				end
				draw.SimpleText(acur .. "/" .. amax, "Y_36_500", pw / 2, ph - YRP.ctr(300), acolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				-- Current and Max Count of Possible Event Characters
				local aecur = CharMenu.character.amountevent or -1
				local aemax = LocalPlayer():GetNW2Int("int_charactersevent_max", 1)
				local aecolor = Color(255, 255, 255, 255)
				if aecur > aemax then
					aecolor = Color(255, 100, 100, 255)
				end
				if aemax > 0 then
					draw.SimpleText(YRP.lang_string("LID_event") .. ": " .. aecur .. "/" .. aemax, "Y_36_500", pw / 2, ph - YRP.ctr(200), aecolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end

			-- Language Changer / LanguageChanger
			YRP.DChangeLanguage(CharMenu.frame, ScrW() - YRP.ctr(100 + 20), YRP.ctr(20), YRP.ctr(100))

			CharMenu.charactersHeader = createD("YPanel", CharMenu.frame, ScrW(), YRP.ctr(120*2), 0, 0)
			CharMenu.charactersHeader.logo = Material("yrp/yrpicon.png")
			CharMenu.charactersHeader.br = YRP.ctr(30)
			function CharMenu.charactersHeader:Paint(pw, ph)
				--draw.RoundedBox(0, 0, 0, pw, ph, Color(51, 51, 51, 255))

				surface.SetMaterial(self.logo)
				surface.SetDrawColor(Color(255, 255, 255))
				surface.DrawTexturedRect(self.br, self.br, ph - 2 * self.br, ph - 2 * self.br)

				draw.SimpleText("YourRP", "Saira_100", ph + 1 * self.br, ph / 2, Color(23, 107, 225), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end

			local charw = YRP.ctr(3 * 350*2 + 2 * 200)
			CharMenu.charactersBackground = createD("DPanel", CharMenu.frame, charw, ScrH() - YRP.ctr(600 + 360), ScrW() / 2 - charw / 2, YRP.ctr(600))
			CharMenu.charactersBackground.text = YRP.lang_string("LID_siteisloading")
			function CharMenu.charactersBackground:Paint(pw, ph)
				--draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 0, 0, 100))
				draw.SimpleText(self.text, "Y_36_500", pw / 2, YRP.ctr(50), Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end



			CharMenu.characterList = createD("DHorizontalScroller", CharMenu.charactersBackground, CharMenu.charactersBackground:GetWide(), CharMenu.charactersBackground:GetTall(), 0, 0)
			--CharMenu.characterList:EnableVerticalScrollbar()
			CharMenu.characterList:SetOverlap(-YRP.ctr(200))
			function CharMenu.characterList:Paint(pw, ph)
				--draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 0, 0, 255))
			end
			


			CharMenu.characterList.OffsetX = 0

			CharMenu.prevChar = createD("YButton", CharMenu.frame, YRP.ctr(100), YRP.ctr(100), ScrW() / 2 - charw / 2 - YRP.ctr(100 + 100), YRP.ctr(600) + CharMenu.charactersBackground:GetTall() / 2 - YRP.ctr(100/2))
			CharMenu.prevChar:SetText("")
			function CharMenu.prevChar:Paint(pw, ph)
				if CharMenu.characterList.OffsetX > 0 then
					hook.Run("YButtonPaint", self, pw, ph)
					if YRP.GetDesignIcon("64_angle-right") ~= nil then
						surface.SetMaterial(YRP.GetDesignIcon("64_angle-left"))
						surface.SetDrawColor(255, 255, 255, 255)
						surface.DrawTexturedRect(br, ph / 2 - (pw - 2 * br) / 2, pw - 2 * br, pw - 2 * br)
					end
				end
			end
			function CharMenu.prevChar:DoClick()
				CharMenu.characterList.OffsetX = CharMenu.characterList.OffsetX - YRP.ctr(350 * 2 + 200)
				if CharMenu.characterList.OffsetX <= 0 then
					CharMenu.characterList.OffsetX = 0
				end
				CharMenu.characterList:SetScroll(CharMenu.characterList.OffsetX)
			end

			CharMenu.nextChar = createD("YButton", CharMenu.frame, YRP.ctr(100), YRP.ctr(100), ScrW() / 2 + charw / 2 + YRP.ctr(100), YRP.ctr(600) + CharMenu.charactersBackground:GetTall() / 2 - YRP.ctr(100/2))
			CharMenu.nextChar:SetText("")
			function CharMenu.nextChar:Paint(pw, ph)
				if CharMenu.characterList.OffsetX < CharMenu.characterList:GetCanvas():GetWide() - CharMenu.characterList:GetWide() then
					hook.Run("YButtonPaint", self, pw, ph)
					if YRP.GetDesignIcon("64_angle-right") ~= nil then
						surface.SetMaterial(YRP.GetDesignIcon("64_angle-right"))
						surface.SetDrawColor(255, 255, 255, 255)
						surface.DrawTexturedRect(br, ph / 2 - (pw - 2 * br) / 2, pw - 2 * br, pw - 2 * br)
					end
				end
			end
			function CharMenu.nextChar:DoClick()
				CharMenu.characterList.OffsetX = CharMenu.characterList.OffsetX + YRP.ctr(350 * 2 + 200)
				if CharMenu.characterList.OffsetX >= CharMenu.characterList:GetCanvas():GetWide() - CharMenu.characterList:GetWide() then
					CharMenu.characterList.OffsetX = CharMenu.characterList:GetCanvas():GetWide() - CharMenu.characterList:GetWide()
				end
				CharMenu.characterList:SetScroll(CharMenu.characterList.OffsetX)
			end

			timer.Simple(0.01, function()
				--YRP.msg("gm", "ask for characterlist")

				net.Start("yrp_get_characters")
				net.SendToServer()
			end)
		end
	end
end

net.Receive("openCharacterMenu", function(len, ply)
	timer.Simple(1, function()
		openCharacterSelection()
	end)
end)

net.Receive("OpenCharacterCreation", function(len, ply)
	timer.Simple(1, function()
		SetGlobalBool("create_eventchar", false)
		openCharacterCreation()
	end)
end)
