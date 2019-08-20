--Copyright (C) 2017-2019 Arno Zura (https://www.gnu.org/licenses/gpl.txt)

hook.Add("YFramePaint", "YFrame_Simple", function(self, pw, ph, tab)
	tab = tab or {}

	local lply = LocalPlayer()
	if GetGlobalDString("string_interface_design") == "Simple" then
		draw.RoundedBox(0, 0, 0, pw, self:GetHeaderHeight(), lply:InterfaceValue("YFrame", "HB"))

		draw.RoundedBox(0, 0, self:GetHeaderHeight(), pw, ph - self:GetHeaderHeight(), Color(60, 60, 60, 200)) --lply:InterfaceValue("YFrame", "BG"))

		local x, y = self:GetContent():GetPos()
		local w, h = self:GetContent():GetSize()
		draw.RoundedBox(0, x, y, w, h, Color(20, 20, 20, 200))

		if self.GetTitle != nil then
			draw.SimpleText(YRP.lang_string(self:GetTitle()), "Roboto18", self:GetHeaderHeight() / 2, self:GetHeaderHeight() / 2, lply:InterfaceValue("YFrame", "HT"), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
		return true
	end
end)

hook.Add("YButtonPaint", "YButton_Simple", function(self, pw, ph, tab)
	tab = tab or {}

	local lply = LocalPlayer()
	if GetGlobalDString("string_interface_design") == "Simple" then
		local color = lply:InterfaceValue("YButton", "NC")
		local tcolor = lply:InterfaceValue("YButton", "NT")
		if self:IsDown() or self:IsPressed() then
			--lply:InterfaceValue("YButton", "SC")
			--tcolor = lply:InterfaceValue("YButton", "ST")
			color.r = color.r - 50
			color.g = color.g - 50
			color.b = color.b - 50
		elseif self:IsHovered() then
			--color = lply:InterfaceValue("YButton", "HC")
			--tcolor = lply:InterfaceValue("YButton", "HT")
			color.r = color.r + 50
			color.g = color.g + 50
			color.b = color.b + 50
		end
		color = tab.color or color
		tcolor = tab.tcolor or tcolor
		draw.RoundedBox(0, 0, 0, pw, ph, Color(color.r, color.g, color.b, 255))

		draw.SimpleText(YRP.lang_string(tab.text or self:GetText()), "Roboto18", pw / 2, ph / 2, tcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		return true
	end
end)

hook.Add("YLabelPaint", "YLabel_Simple", function(self, pw, ph, tab)
	tab = tab or {}

	local lply = LocalPlayer()
	if GetGlobalDString("string_interface_design") == "Simple" then
		local color = lply:InterfaceValue("YButton", "NC")
		local tcolor = lply:InterfaceValue("YButton", "NT")

		draw.RoundedBox(0, 0, 0, pw, ph, Color(color.r, color.g, color.b, 255))

		local ax = tab.ax or TEXT_ALIGN_CENTER
		local ay = tab.ay or TEXT_ALIGN_CENTER

		local tx = pw / 2
		if ax == 0 then
			tx = YRP.ctr(20)
		end
		local ty = ph / 2
		if ay == 3 then
			ty = YRP.ctr(20)
		end

		draw.SimpleText(YRP.lang_string(self:GetText()), "Roboto18", tx, ty, tcolor, ax, ay)
		return true
	end
end)

hook.Add("YAddPaint", "YAdd_Simple", function(self, pw, ph, tab)
	tab = tab or {}

	if GetGlobalDString("string_interface_design") == "Simple" then
		local color = Color(100, 205, 100)
		if self:IsDown() or self:IsPressed() then
			color.r = color.r - 50
			color.g = color.g - 50
			color.b = color.b - 50
		elseif self:IsHovered() then
			color.r = color.r + 50
			color.g = color.g + 50
			color.b = color.b + 50
		end
		surface.SetDrawColor(color)
		surface.SetMaterial(YRP.GetDesignIcon("circle"))
		surface.DrawTexturedRect(0, 0, pw, ph)

		local br = ph * 0.1
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(YRP.GetDesignIcon("add"))
		surface.DrawTexturedRect(br, br, pw - br * 2, ph - br * 2)
		return true
	end
end)

hook.Add("YRemovePaint", "YRemove_Simple", function(self, pw, ph, tab)
	tab = tab or {}

	if GetGlobalDString("string_interface_design") == "Simple" then
		local color = Color(205, 100, 100)
		if self:IsDown() or self:IsPressed() then
			color.r = color.r - 50
			color.g = color.g - 50
			color.b = color.b - 50
		elseif self:IsHovered() then
			color.r = color.r + 50
			color.g = color.g + 50
			color.b = color.b + 50
		end
		surface.SetDrawColor(color)
		surface.SetMaterial(YRP.GetDesignIcon("circle"))
		surface.DrawTexturedRect(0, 0, pw, ph)

		local br = ph * 0.1
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(YRP.GetDesignIcon("remove"))
		surface.DrawTexturedRect(br, br, pw - br * 2, ph - br * 2)
		return true
	end
end)

hook.Add("YClosePaint", "YClose_Simple", function(self, pw, ph, tab)
	tab = tab or {}

	if GetGlobalDString("string_interface_design") == "Simple" then
		local color = Color(205, 100, 100)
		if self:IsDown() or self:IsPressed() then
			color.r = color.r - 50
			color.g = color.g - 50
			color.b = color.b - 50
		elseif self:IsHovered() then
			color.r = color.r + 50
			color.g = color.g + 50
			color.b = color.b + 50
		end
		surface.SetDrawColor(color)
		surface.SetMaterial(YRP.GetDesignIcon("circle"))
		surface.DrawTexturedRect(0, 0, pw, ph)

		local br = ph * 0.1
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(YRP.GetDesignIcon("clear"))
		surface.DrawTexturedRect(br, br, pw - br * 2, ph - br * 2)
		return true
	end
end)

hook.Add("YGroupBoxPaint", "YGroupBox_Simple", function(self, pw, ph, tab)
	tab = tab or {}

	if GetGlobalDString("string_interface_design") == "Simple" then
		draw.RoundedBox(0, 0, 0, pw, ph, Color(40, 40, 40, 255))

		draw.RoundedBox(0, 0, 0, pw, self:GetHeaderHeight(), Color(60, 60, 60, 255))

		local x, y = self.con:GetPos()
		draw.RoundedBox(0, x, y, self.con:GetWide(), self.con:GetTall(), Color(20, 20, 20, 255))

		draw.SimpleText(YRP.lang_string(tab.text or self:GetText()), "YRP_18_500", pw / 2, self:GetHeaderHeight() / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		return true
	end
end)
