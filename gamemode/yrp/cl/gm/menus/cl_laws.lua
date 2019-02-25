--Copyright (C) 2017-2019 Arno Zura (https://www.gnu.org/licenses/gpl.txt)
local _la = {}

function ToggleLawsMenu()
	if isNoMenuOpen() then
		OpenLawsMenu()
	end
end

function CloseLawsMenu()
	if _la.window != nil then
		closeMenu()
		_la.window:Remove()
		_la.window = nil
	end
end

function OpenLawsMenu()
	openMenu()
	_la.window = createD("YFrame", nil, ctr(800), ctr(1200), 0, 0)
	_la.window:Center()
	_la.window:ShowCloseButton(true)
	_la.window:MakePopup()
	_la.window:SetTitle(YRP.lang_string("LID_laws"))
	_la.window:SetHeaderHeight(ctr(100))
	function _la.window:Paint(pw, ph)
		hook.Run("YFramePaint", self, pw, ph)
	end

	local lply = LocalPlayer()
	net.Receive("get_laws", function(len)
		local lawtab = net.ReadTable()
		local lawsymbol = tostring(lawtab.string_lawsymbol)
		local laws = lawtab.string_laws
		local lockdowntext = lawtab.string_lockdowntext
		local lockdown = tobool(lawtab.bool_lockdown)

		if !lply:GetNWBool("bool_" .. "ismayor", false) then
			laws = string.Explode(lawsymbol, laws)
			if _la.window:IsValid() then
				_la.dpl = createD("DPanelList", _la.window, ctr(760), ctr(1200 - 100 - 20 - 20), ctr(20), ctr(100 + 20))
				_la.dpl:SetSpacing(ctr(20))
				for i, law in pairs(laws) do
					if law != "" then
						if string.EndsWith(law, "\n") then
							law = string.sub(law, 1, string.len(law) - 1)
						end
						local lines = string.Explode("\n", law)
						lines = table.Count(lines)
						local l = createD("YLabel", nil, ctr(100), ctr(50) * lines, 0, 0)
						l:SetText(lawsymbol .. law)
						l:SetWrap(true)
						function l:Paint(pw, ph)
							local tab = {}
							tab.ax = 0
							hook.Run("YLabelPaint", self, pw, ph, tab)
						end

						_la.dpl:AddItem(l)
					end
				end
			end
		else
			_la.window:SetWide(ctr(1600))
			_la.window:SetTitle(YRP.lang_string("LID_laws") .. " | " .. YRP.lang_string("LID_lockdown"))
			_la.window:Center()



			-- LAWS
			_la.lawsymbolheader = createD("YLabel", _la.window, ctr(760), ctr(50), ctr(20), ctr(100 + 20))
			_la.lawsymbolheader:SetText(YRP.lang_string("LID_lawsymbol"))
			function _la.lawsymbolheader:Paint(pw, ph)
				hook.Run("YLabelPaint", self, pw, ph)
			end

			_la.lawsymbol = createD("DTextEntry", _la.window, ctr(760), ctr(50), ctr(20), ctr(100 + 20 + 50))
			_la.lawsymbol:SetText("#" .. lawsymbol)
			function _la.lawsymbol:OnChange()
				net.Start("set_lawsymbol")
					net.WriteString(self:GetText())
				net.SendToServer()
			end



			_la.lawsheader = createD("YLabel", _la.window, ctr(760), ctr(50), ctr(20), ctr(100 + 20 + 50 + 50 + 20))
			_la.lawsheader:SetText(YRP.lang_string("LID_laws"))
			function _la.lawsheader:Paint(pw, ph)
				hook.Run("YLabelPaint", self, pw, ph)
			end

			_la.laws = createD("DTextEntry", _la.window, ctr(760), ctr(1200 - 100 - 20 - 20 - 100 - 20 - 50), ctr(20), ctr(100 + 20 + 50 + 50 + 20 + 50))
			_la.laws:SetMultiline(true)
			_la.laws:SetText("#" .. laws)
			function _la.laws:OnChange()
				net.Start("set_laws")
					net.WriteString(self:GetText())
				net.SendToServer()
			end



			-- LOCKDOWN
			_la.lockdownheader = createD("YLabel", _la.window, ctr(760), ctr(50), ctr(800 + 20), ctr(100 + 20))
			_la.lockdownheader:SetText(YRP.lang_string("LID_lockdowntext"))
			function _la.lockdownheader:Paint(pw, ph)
				hook.Run("YLabelPaint", self, pw, ph)
			end

			_la.lockdowntext = createD("DTextEntry", _la.window, ctr(760), ctr(50), ctr(800 + 20), ctr(100 + 20 + 50))
			_la.lockdowntext:SetText("#" .. lockdowntext)
			function _la.lockdowntext:OnChange()
				net.Start("set_lockdowntext")
					net.WriteString(self:GetText())
				net.SendToServer()
			end

			_la.lockdowntoggle = createD("YButton", _la.window, ctr(760), ctr(50), ctr(800 + 20), ctr(240))
			_la.lockdowntoggle:SetPressed(lockdown)
			local ld_enabled = YRP.lang_string("LID_lockdown") .. " (" .. YRP.lang_string("LID_enabled") .. ")"
			local ld_disabled = YRP.lang_string("LID_lockdown") .. " (" .. YRP.lang_string("LID_disabled") .. ")"
			if lockdown then
				_la.lockdowntoggle:SetText(ld_enabled)
			else
				_la.lockdowntoggle:SetText(ld_disabled)
			end
			function _la.lockdowntoggle:Paint(pw, ph)
				hook.Run("YButtonPaint", self, pw, ph)
			end
			function _la.lockdowntoggle:DoClick()
				lockdown = !self:IsPressed()
				self:SetPressed(lockdown)
				if lockdown then
					_la.lockdowntoggle:SetText(ld_enabled)
				else
					_la.lockdowntoggle:SetText(ld_disabled)
				end
				net.Start("set_lockdown")
					net.WriteBool(lockdown)
				net.SendToServer()
			end
		end
	end)

	net.Start("get_laws")
	net.SendToServer()
end
