--Copyright (C) 2017-2021 Arno Zura (https://www.gnu.org/licenses/gpl.txt)

CreateConVar("yrp_cl_hud", 1, {}, "")
--##############################################################################
--Resolution Change
hook.Add("Initialize", "Resolution Change", function()
	vgui.CreateFromTable {
		Base = "Panel",
		PerformLayout = function()
			hook.Run("ResolutionChanged", ScrW(), ScrH())
		end
	} : ParentToHUD()
end)

hook.Add("ResolutionChanged", "Resolution Change", function(w, h)
	local rw, rh = getResolutionRatio()
	YRP.msg("gm", "Changed Resolution to " .. w .. "x" .. h .. " (" .. rw .. ":" .. rh .. ")")
	changeFontSize()

	net.Start("ply_changed_resolution")
	net.SendToServer()
end)
--##############################################################################

--##############################################################################

function GM:DrawDeathNotice(x, y)
	--No Kill Feed
end

hook.Add("HUDShouldDraw", "yrp_hidehud", function(name)
	if GetGlobalBool("bool_yrp_hud", false) then
		local lply = LocalPlayer()
		if lply:IsValid() then
			local hide = {
				CHudHealth = true,
				CHudBattery = true,
				CHudAmmo = true,
				CHudSecondaryAmmo = true,
				CHudCrosshair = GetGlobalBool("bool_yrp_crosshair", false),
				CHudVoiceStatus = false,
				CHudDamageIndicator = true,
				CHudDeathNotice = true
			}

			--[[if g_VoicePanelList != nil then
				g_VoicePanelList:SetVisible(true)
			end]]
			if (hide[ name ]) then return false end
		end
	end
end)

--##############################################################################

--##############################################################################
--includes
include("hud/cl_hud_map.lua")
include("hud/cl_hud_player.lua")
include("hud/cl_hud_view.lua")
include("hud/cl_hud_crosshair.lua")
--##############################################################################

Material("voice/icntlk_pl"):SetFloat("$alpha", 0)

function IsScreenshotting()
	if input.IsKeyDown(KEY_F12) or input.IsKeyDown(KEY_F5) then
		return true
	else
		return false
	end
end

hook.Add("PlayerStartVoice", "yrp_playerstartvoice", function(pl)
	if pl != nil then
		if pl == LocalPlayer() then
			_showVoice = true
			net.Start("yrp_voice_start")
			net.SendToServer()
		end
	end
end)

hook.Add("PlayerEndVoice", "yrp_playerendvoice", function(pl)
	if pl == LocalPlayer() then
		_showVoice = false
		net.Start("yrp_voice_end")
		net.SendToServer()
	end
end)

local _yrp_icon = Material("vgui/yrp/logo100_beta.png")
local star = Material("vgui/material/icon_star.png")

function DrawEquipment(ply, name)
	local _tmp = ply:GetNW2Entity(name, NULL)
	if ea(_tmp) then
		ply.yrp_view_range = ply.yrp_view_range or 0
		if ply.yrp_view_range <= 0 then
			_tmp:SetNoDraw(true)
		else
			_tmp:SetNoDraw(false)
		end
	end
end

hook.Add("HUDPaint", "yrp_hud_safezone", function()
	local lply = LocalPlayer()
	if IsInsideSafezone(lply) then
		draw.SimpleText(YRP.lang_string("LID_safezone"), "Y_24_500", ScrW() / 2, YRP.ctr(650), Color(100, 100, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end)

hook.Add("HUDPaint", "yrp_hud_alert", function()
	local text = GetGlobalString("yrp_alert", "")
	local font = "Y_100_500"

	surface.SetFont(font)
	local tw, th = surface.GetTextSize(text)
	if tw > ScrW() then
		font = "Y_72_500"
		surface.SetFont(font)
		tw, th = surface.GetTextSize(text)
		if tw > ScrW() then
			font = "Y_36_500"
			surface.SetFont(font)
			tw, th = surface.GetTextSize(text)
			if tw > ScrW() then
				font = "Y_18_500"
			end
		end
	end


	draw.SimpleText(text, font, ScrW() / 2, YRP.ctr(500), Color(255, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)

local oldlevel = oldlevel or nil--ply:Level()
hook.Add("HUDPaint", "yrp_hud_levelup", function()
	local lply = LocalPlayer()
	if IsLevelSystemEnabled() then
		if oldlevel == nil then
			lply:Level()
		end
		if oldlevel != lply:Level() then
			oldlevel = lply:Level()

			surface.PlaySound("garrysmod/content_downloaded.wav")

			local levelup = createD("DFrame", nil, YRP.ctr(600), YRP.ctr(160), 0, 0)
			levelup:SetPos(ScrW() / 2 - levelup:GetWide() / 2, ScrH() / 2 - levelup:GetTall() / 2 - YRP.ctr(400))
			levelup:ShowCloseButton(false)
			levelup:SetTitle("")
			levelup.LID_levelup = YRP.lang_string("LID_levelup")
			local tab = {}
			tab["LEVEL"] = lply:Level()
			levelup.LID_levelx = YRP.lang_string("LID_levelx", tab)
			levelup.lucolor = Color(255, 255, 100, 255)
			levelup.lxcolor = Color(255, 255, 255, 255)
			levelup.brcolor = Color(0, 0, 0, 255)
			levelup.level = oldlevel
			function levelup:Paint(pw, ph)
				surface.SetFont("Y_36_500")
				local tw, th = surface.GetTextSize(self.LID_levelup)
				tw = tw + 2 * YRP.ctr(20)
				self.aw = self.aw or 0

				draw.RoundedBox(YRP.ctr(10), pw / 2 - self.aw / 2, 0, self.aw, ph, Color(0, 0, 0, 120))

				if self.aw < tw then
					self.aw = math.Clamp(self.aw + 5, 0, tw)
				else
					draw.SimpleText(self.LID_levelup, "Y_36_500", pw / 2, ph / 4, self.lucolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					draw.SimpleText(self.LID_levelx, "Y_24_500", pw / 2, ph / 4 * 3, self.lxcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end

				if self.level != lply:Level() then
					self:Remove()
				end
				self.delay = self.delay or CurTime() + 6
				if self.delay < CurTime() then
					self:Remove()
				end
			end
		end
	end
end)

local HUD_AVATAR = nil
local PAvatar = vgui.Create("DPanel")
function PAvatar:Paint(pw, ph)
	if GetGlobalBool("bool_yrp_hud", false) then
		render.ClearStencil()
		render.SetStencilEnable(true)

			render.SetStencilWriteMask(1)
			render.SetStencilTestMask(1)

			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)

			render.SetStencilFailOperation(STENCILOPERATION_INCR)
			render.SetStencilPassOperation(STENCILOPERATION_KEEP)
			render.SetStencilZFailOperation(STENCILOPERATION_KEEP)

			render.SetStencilReferenceValue(1)

			drawRoundedBox(ph / 2, 0, 0, pw, ph, Color(255, 255, 255, 255))

			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)

			if HUD_AVATAR != nil then
				HUD_AVATAR:SetPaintedManually(false)
				HUD_AVATAR:PaintManual()
				HUD_AVATAR:SetPaintedManually(true)
			end

		render.SetStencilEnable(false)
	end
end
timer.Simple(1, function()
	HUD_AVATAR = vgui.Create("AvatarImage", PAvatar)
	local ava = {}
	ava.w = 64
	ava.h = 64
	ava.x = 0
	ava.y = 0
	ava.version = -1
	function HUD_AVATARUpdate()
		local lply = LocalPlayer()
		if lply != NULL then
			if GetGlobalBool("bool_yrp_hud", false) then
				if lply:GetNW2Int("hud_version", 0) != ava.version then
					ava.version = lply:GetNW2Int("hud_version", 0)

					HUD_AVATAR:Show()

					ava.w = lply:HudValue("AV", "SIZE_W")
					ava.h = lply:HudValue("AV", "SIZE_H")
					ava.x = lply:HudValue("AV", "POSI_X")
					ava.y = lply:HudValue("AV", "POSI_Y")
					ava.visible = lply:HudValue("AV", "VISI")

					PAvatar:SetPos(ava.x, ava.y)
					PAvatar:SetSize(ava.h, ava.h)
					HUD_AVATAR:SetPlayer(LocalPlayer(), ava.h)
					if !ava.visible then
						PAvatar:SetSize(0, 0)
					end

					HUD_AVATAR:SetPos(0, 0)
					HUD_AVATAR:SetSize(PAvatar:GetWide(), PAvatar:GetTall())
				end
			else
				if lply:GetNW2Int("hud_version", 0) != ava.version then
					ava.version = lply:GetNW2Int("hud_version", 0)

					HUD_AVATAR:Hide()
				end
			end
		end

		timer.Simple(1, HUD_AVATARUpdate)
	end
	HUD_AVATARUpdate()
end)

SL = SL or vgui.Create("DHTML", nil)
SL.w = 64
SL.h = 64
SL.x = 0
SL.y = 0
SL.url = ""
SL.visible = false
SL.version = -1

YRP_PM = YRP_PM or vgui.Create("DModelPanel", nil)
YRP_PM.w = 64
YRP_PM.h = 64
YRP_PM.x = 0
YRP_PM.y = 0
YRP_PM.version = -1
YRP_PM.model = ""
function YRP_PMUpdate()
	local lply = LocalPlayer()
	if IsValid(lply) then
		if GetGlobalBool("bool_yrp_hud", false) then
			if lply:GetNW2Int("hud_version", 0) != YRP_PM.version or YRP_PM.model != lply:GetPlayerModel() or YRP_PM.skin != lply:GetSkin() then
				YRP_PM.version = lply:GetNW2Int("hud_version", 0)

				YRP_PM:Show()

				YRP_PM.model = lply:GetPlayerModel()
				YRP_PM.skin = lply:GetSkin()

				YRP_PM.w = lply:HudValue("PM", "SIZE_W")
				YRP_PM.h = lply:HudValue("PM", "SIZE_H")
				YRP_PM.x = lply:HudValue("PM", "POSI_X")
				YRP_PM.y = lply:HudValue("PM", "POSI_Y")
				YRP_PM.visible = lply:HudValue("PM", "VISI")

				YRP_PM:SetPos(YRP_PM.x, YRP_PM.y)
				YRP_PM:SetSize(YRP_PM.h, YRP_PM.h)
				YRP_PM:SetModel(YRP_PM.model)
				
				if ea(YRP_PM.Entity) then
					YRP_PM.Entity:SetSkin(lply:GetSkin())
					local lb = YRP_PM.Entity:LookupBone("ValveBiped.Bip01_Head1")
					if lb != nil then
						local eyepos = YRP_PM.Entity:GetBonePosition(lb)
						eyepos:Add(Vector(0, 0, 2))	-- Move up slightly
						YRP_PM:SetLookAt(eyepos - Vector(0, 0, 4))
						YRP_PM:SetCamPos(eyepos - Vector(0, 0, 4) - Vector(-26, 0, 0))	-- Move cam in front of eyes
						YRP_PM.Entity:SetEyeTarget(eyepos-Vector(-40, 0, 0))
					else
						YRP_PM:SetLookAt(Vector(0, 0, 40))
						YRP_PM:SetCamPos(Vector(50, 50, 50))
					end
				end

				if !YRP_PM.visible then
					YRP_PM:SetModel("")
				end
			end

			if IsValid(SL) and (lply:GetNW2Int("hud_version", 0) != SL.version or SL.url != GetGlobalString("text_server_logo", "")) then
				SL.version = lply:GetNW2Int("hud_version", 0)
				SL.visible = lply:HudValue("SL", "VISI")
				SL.url = GetGlobalString("text_server_logo", "")

				SL.w = lply:HudValue("SL", "SIZE_W")
				SL.h = lply:HudValue("SL", "SIZE_H")
				SL.x = lply:HudValue("SL", "POSI_X")
				SL.y = lply:HudValue("SL", "POSI_Y")

				SL:SetPos(SL.x, SL.y)
				SL:SetSize(SL.h, SL.h)
				SL:SetHTML(GetHTMLImage(SL.url, SL.h, SL.h))

				SL:SetVisible(SL.visible)
			end
		else
			if lply:GetNW2Int("hud_version", 0) != YRP_PM.version then
				YRP_PM.version = lply:GetNW2Int("hud_version", 0)

				YRP_PM:Hide()
				YRP_PM:SetModel("")
			end
		end
	end

	timer.Simple(1, YRP_PMUpdate)
end
YRP_PMUpdate()

function YRP_PM:LayoutEntity(ent)
	local seq = ent:LookupSequence("menu_gman")
	if seq > -1 then
		ent:SetSequence(ent:LookupSequence("menu_gman"))
	end
	YRP_PM:RunAnimation()
	return
end

local tested = false
function TestYourRPContent()
	if !tested then
		tested = true
		local str = ""
		local files, directories = file.Find("addons/*", "GAME")
		for i, v in pairs(files) do
			if string.find(v, "1189643820") then
				local ts = file.Time("addons/" .. v, "GAME")
				if ts < 1585861486 then
					if str != "" then
						str = str .. "\n"
					end
					str = str .. v
				end
			end
		end
		LocalPlayer().badyourrpcontent = LocalPlayer().badyourrpcontent or ""
		if LocalPlayer() != NULL then
			LocalPlayer().badyourrpcontent = str
		end
	end
end
timer.Simple(4, function()
	TestYourRPContent()
end)

local function HUDPermille()
	local lply = LocalPlayer()
    if lply:Permille() > 0 then
        DrawMotionBlur(0.1, 0.79, 0.05)
    end
end
hook.Add( "RenderScreenspaceEffects", "BlurTest", HUDPermille)

hook.Add("HUDPaint", "yrp_hud", function()
	local lply = LocalPlayer()

	if game.SinglePlayer() then
		draw.SimpleText("[YourRP] " .. "DO NOT USE SINGLEPLAYER" .. "!", "Y_72_500", ScrW2(), ScrH2(), Color(255, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	if lply:GetNW2Bool("yrp_spawning", false) then
		draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255)) -- Black Background - Respawning

		draw.SimpleText(YRP.lang_string("LID_pleasewait"), "Y_18_500", ScrW() / 2, ScrH() / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(YRP.lang_string("LID_respawning"), "Y_40_500", ScrW() / 2, ScrH() / 2 + YRP.ctr(100), Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if lply:GetNW2Bool("yrp_speaking", false) then
		local text = YRP.lang_string("LID_youarespeaking")
		if lply:GetNW2Bool("mute_voice", false) then
			text = text .. " (" .. YRP.lang_string("LID_speaklocal") .. ")"
		end
		if GetVoiceRangeText(lply) != "" then
			text = text .. " (" .. YRP.lang_string("LID_range") .. " " .. GetVoiceRangeText(lply) .. " [" .. GetVoiceRange(lply) .. "])"
		end

		draw.SimpleText(text, "Y_24_500", ScrW2(), ScrH2() - YRP.ctr(600), Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	DONE_LOADING = DONE_LOADING or false
	if !DONE_LOADING then
		draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(10, 10, 10))
	end

	if GetGlobalBool("blinded", false) then
		surfaceBox(0, 0, ScrW(), ScrH(), Color(255, 255, 255, 255))
		surfaceText(YRP.lang_string("LID_blinded"), "Y_30_500", ScrW2(), ScrH2() + YRP.ctr(100), Color(255, 255, 0, 255), 1, 1)
	end
	if lply:IsFlagSet(FL_FROZEN) then
		surfaceText(YRP.lang_string("LID_frozen"), "Y_30_500", ScrW2(), ScrH2() + YRP.ctr(150), Color(255, 255, 0, 255), 1, 1)
	end
	if lply:GetNW2Bool("cloaked", false) then
		surfaceText(YRP.lang_string("LID_cloaked"), "Y_30_500", ScrW2(), ScrH2() - YRP.ctr(400), Color(255, 255, 0, 255), 1, 1)
	end

	DrawEquipment(lply, "backpack")
	DrawEquipment(lply, "weaponprimary1")
	DrawEquipment(lply, "weaponprimary2")
	DrawEquipment(lply, "weaponsecondary1")
	DrawEquipment(lply, "weaponsecondary2")
	DrawEquipment(lply, "weapongadget")

	if !lply:InVehicle() then
		HudPlayer(lply)
		HudView()
		HudCrosshair()
	end

	local _target = LocalPlayer():GetNW2String("hittargetName", "")
	if !strEmpty(_target) then
		surfaceText(YRP.lang_string("LID_target") .. ": " .. LocalPlayer():GetNW2String("hittargetName", ""), "Y_24_500", YRP.ctr(10), YRP.ctr(10), Color(255, 0, 0, 255), 0, 0)
		LocalPlayer():drawHitInfo()
	end

	if IsSpVisible() then
		local _br = {}
		_br.y = 50
		_br.x = 10

		local _r = 60

		local _sp = GetSpTable()

		draw.RoundedBox(ctrb(_r), _sp.x - _br.x, _sp.y - _br.y, _sp.w + 2 * _br.x, _sp.h + 2 * _br.y, getSpCaseColor())

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(_yrp_icon	)
		surface.DrawTexturedRect(_sp.x + _sp.w / 2 - ctrb(246) / 2, _sp.y - ctrb(80 + 10), ctrb(246), ctrb(80))
	end

	if GetGlobalBool("bool_wanted_system", false) and false then
		local stars = {}
		stars.size = YRP.ctr(80)
		stars.cur = stars.size
		stars.x = -YRP.ctr(32) + ScrW() - 6 * stars.size
		stars.y = YRP.ctr(32)

		-- Slot
		surface.SetDrawColor(0, 0, 0, 255)
		surface.SetMaterial(star)
		for x = 1, 5 do
			surface.DrawTexturedRect(stars.x + x * stars.size, stars.y, stars.cur, stars.cur)
		end

		stars.cur = YRP.ctr(60)
		stars.br = (stars.size - stars.cur) / 2
		surface.SetDrawColor(100, 100, 100, 255)
		for x = 1, 5 do
			surface.DrawTexturedRect(stars.x + x * stars.size + stars.br, stars.y + stars.br, stars.cur, stars.cur)
		end

		-- Current Stars
		surface.SetDrawColor(255, 255, 255, 255)
		for x = 1, 5 do
			if lply:GetNW2Int("yrp_stars", 0) >= x then
				surface.DrawTexturedRect(stars.x + x * stars.size + stars.br, stars.y + stars.br, stars.cur, stars.cur)
			end
		end
	end

	if !HasYRPContent() then
		draw.SimpleText("YOURRP CONTENT IS MISSING! (FROM SERVER COLLECTION)", "Y_60_500", ScrW2(), ScrH2(), Color(255, 255, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	LocalPlayer().badyourrpcontent = LocalPlayer().badyourrpcontent or ""
	if LocalPlayer().badyourrpcontent != "" then
		draw.SimpleText("Your addon is outdated, please delete/redownload (addons folder):", "Y_30_500", ScrW2() + YRP.ctr(50), ScrH2() + YRP.ctr(50), Color(255, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		local addons = string.Explode("\n", LocalPlayer().badyourrpcontent)
		for i, v in pairs(addons) do
			draw.SimpleText("• " .. v, "Y_30_500", ScrW2() + YRP.ctr(50), ScrH2() + YRP.ctr(50) + i * YRP.ctr(50), Color(255, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end

	if GetGlobalBool("bool_radiation", false) then
		LocalPlayer().radiation = LocalPlayer().radiation or CurTime()
		if LocalPlayer().radiation < CurTime() then
			LocalPlayer().radiation = CurTime() + math.Rand(0.1, 0.5)
			if IsInsideRadiation(LocalPlayer()) then
				local filename = "tools/ifm/ifm_snap.wav"
				util.PrecacheSound(filename)
				LocalPlayer():EmitSound(filename)
			end
		end
	end
end)

hook.Add("HUDPaint", "yrp_hud_collectionid", function()
	local lply = LocalPlayer()
	if lply:HasAccess() and YRPCollectionID() == 0 then
		local text = YRP.lang_string("LID_thecollectionidismissing") .. " (" .. GetKeybindName("menu_settings") .. " >> " .. YRP.lang_string("LID_server") .. " >> " .. YRP.lang_string("LID_general") .. " >> " .. YRP.lang_string("LID_collectionid") .. ")"
		draw.SimpleText(text, "Y_30_500", ScrW() / 2, ScrH()  * 0.12, Color(255, 255, 0, 255), 1, 1)
	end
end)

local yrpeh = nil
function YRPInitEdgeHud()
	if EdgeHUD and EdgeHUD.Configuration and yrpeh == nil then
		YRP.msg("note", "EDGEHUD installed, add hunger and thirst.")
		if EdgeHUD.Configuration.GetConfigValue( "LowerLeft" ) then

			--Create a variable for the local player.
			local ply = LocalPlayer()
		
			--Create a copy of the colors and vars table.
			local COLORS = table.Copy(EdgeHUD.Colors)
			local VARS = table.Copy(EdgeHUD.Vars)
		
			local screenWidth = ScrW()
			local screenHeight = ScrH()
		
			local alwaysShowPercentage = EdgeHUD.Configuration.GetConfigValue( "LowerLeft_AlwaysShow" )
		
			--Create a table where we store information about the statuswidgets.
			local statusWidgets = {}

			--Insert intot he table.
			table.insert(statusWidgets,	{
				Icon = Material("edgehud/icon_hunger.png", "smooth"),
				Color = Color(131,90,38),
				getData = function(  )
					return ply:getDarkRPVar("Energy")
				end,
				getMax = function(  )
					return 100
				end,
				IsDisabled = function(  )
					return !GetGlobalBool("bool_hunger", false)
				end
			})

			table.insert(statusWidgets,	{
				Icon = Material("edgehud/icon_thirst.png", "smooth"),
				Color = ply:HudValue("TH", "BA"),
				getData = function(  )
					return ply:getDarkRPVar("Thirst")
				end,
				getMax = function(  )
					return 100
				end,
				IsDisabled = function(  )
					return !GetGlobalBool("bool_thirst", false)
				end
			})

			--Loop through statusWidgets.
			for i = 1,#statusWidgets do
				local id = i + 2

				--Create a x & y var for the position.
				local x = VARS.ScreenMargin + (VARS.ElementsMargin + VARS.statusWidgetWidth) * (i - 1)
				local y = screenHeight - VARS.ScreenMargin - VARS.WidgetHeight * 3 - VARS.ElementsMargin * 2
		
				--Create a var for the current widget.
				local curWidget = statusWidgets[i]
		
				--Create a widgetbox.
				local statusWidget = vgui.Create("EdgeHUD:WidgetBox")
				statusWidget:SetWidth(VARS.statusWidgetWidth)
				statusWidget:SetPos(x + EdgeHUD.LeftOffset,y - EdgeHUD.BottomOffset - (VARS.WidgetHeight + VARS.ElementsMargin))
				
				yrpeh = statusWidget

				--Register the derma element.
				EdgeHUD.RegisterDerma("StatusWidget_" .. id, statusWidget)
		
				--Create the icon.
				local Icon = vgui.Create("DImage",statusWidget)
				Icon:SetSize(VARS.iconSize_Small,VARS.iconSize_Small)
				Icon:SetPos(statusWidget:GetWide() / 2 - VARS.iconSize_Small / 2, VARS.iconMargin_Small)
				Icon:SetMaterial(curWidget.Icon)
		
				--Create a lerpedData for the curWidget.
				local lerpedData = curWidget.getData()
		
				--Create a lerpedSize var.
				local lerpedSize = Icon:GetWide()
		
				--Create a lerpedPos var.
				local xPos, lerpedPos = Icon:GetPos()
		
				--Create a lerpedAlha var.
				local lerpedAlpha = 255
		
				--Create a PaintOVer function for the statusWidget.
				statusWidget.Paint = function( s, w, h )
					if curWidget:IsDisabled() then
						Icon:Hide()
						return
					else
						Icon:Show()
					end

					--Draw the background.
					surface.SetDrawColor(COLORS["Black_Transparent"])
					surface.DrawRect(0,0,w,h)
		
					--Get the player's max health.
					local max = curWidget.getMax()
					local data = math.max(curWidget.getData() or 0,0)
		
					--Cache the FrameTime.
					local FT = FrameTime() * 5
		
					--Lerp the EdgeHUD.calcData.
					lerpedData = Lerp(FT or 0,lerpedData or 0,data or 0)
		
					--Calculate the proportion.
					local prop = math.Clamp(lerpedData / max,0,1)
		
					--Lerp the Alpha.
					lerpedAlpha = Lerp(FT,lerpedAlpha,prop > 0.999 and alwaysShowPercentage == false and data <= max and 0 or 255)
		
					--Calculate the height.
					local height = h * prop
		
					--Draw the overlay.
					surface.SetDrawColor(ColorAlpha(curWidget.Color,lerpedAlpha))
					surface.DrawRect(0,h - height,w,height)
		
					--Draw the infotext.
					draw.SimpleText(math.max(math.Round(lerpedData),0) .. "%","EdgeHUD:Small",w / 2,h - VARS.iconMargin_Small,ColorAlpha(COLORS["White"],lerpedAlpha),TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
		
					--Draw the white outline.
					surface.SetDrawColor(COLORS["White_Outline"])
					surface.DrawOutlinedRect(0,0,w,h)
		
					--Draw the corners.
					surface.SetDrawColor(COLORS["White_Corners"])
					EdgeHUD.DrawEdges(0,0,w,h, 8)
		
					--Calculate the new size.
					lerpedSize = Lerp(FT,lerpedSize,prop > 0.999 and alwaysShowPercentage == false and data <= max  and VARS.iconSize or VARS.iconSize_Small)
		
					--Update the size.
					Icon:SetSize(lerpedSize,lerpedSize)
		
					--Calculate the new ypos.
					lerpedPos = Lerp(FT,lerpedPos,prop > 0.999 and alwaysShowPercentage == false and data <= max  and VARS.iconMargin or VARS.iconMargin_Small)
		
					--Update the position.
					Icon:SetPos(xPos,lerpedPos)
		
				end
			end		
		end
	end

	timer.Simple(2, YRPInitEdgeHud)
end
YRPInitEdgeHud()