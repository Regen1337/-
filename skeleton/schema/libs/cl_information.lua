
local PANEL = {}

function PANEL:Init()
	local parent = self:GetParent()

	self:SetSize(parent:GetWide() * 0.6, parent:GetTall())
	self:Dock(RIGHT)
	self:DockMargin(0, ScrH() * 0.05, 0, 0)

	self.VBar:SetWide(0)

	-- entry setup
	local suppress = {}
	hook.Run("CanCreateCharacterInfo", suppress)

	if (!suppress.name) then
		self.name = self:Add("ixLabel")
		self.name:Dock(TOP)
		self.name:DockMargin(0, 0, 0, 8)
		self.name:SetFont("ixMenuButtonHugeFont")
		self.name:SetContentAlignment(5)
		self.name:SetTextColor(color_white)
		self.name:SetPadding(8)
		self.name:SetScaleWidth(true)

        self.name.Paint = function(self, width, height)
            draw.RoundedBoxEx(8, 0, 0, width, height, Color(0, 0, 0, 240), false, false, true, true)
            surface.SetFont(self.font)
        
            if (self.bScaleWidth) then
                local contentWidth, contentHeight = self:GetContentSize()
        
                if (contentWidth > (width - self.padding * 2)) then
                    local x, y = self:LocalToScreen(self:GetPos())
                    local scale = width / (contentWidth + self.padding * 2)
                    local translation = Vector(x + width * 0.5, y - contentHeight * 0.5 + self.padding, 0)
                    local matrix = Matrix()
        
                    matrix:Translate(translation)
                    matrix:Scale(Vector(scale, scale, 0))
                    matrix:Translate(-translation)
        
                    cam.PushModelMatrix(matrix, true)
                    render.PushFilterMin(TEXFILTER.ANISOTROPIC)
                    DisableClipping(true)
        
                    self.bCurrentlyScaling = true
                end
            end
        
            if (self.kerning > 0) then
                self:DrawKernedText(width, height)
            else
                self:DrawText(width, height)
            end
        
            if (self.bCurrentlyScaling) then
                DisableClipping(false)
                render.PopFilterMin()
                cam.PopModelMatrix()
        
                self.bCurrentlyScaling = false
            end
        end
	end

	if (!suppress.description) then
		self.description = self:Add("DLabel")
		self.description:Dock(TOP)
		self.description:DockMargin(0, 0, 0, 8)
		self.description:SetFont("ixMenuButtonFont")
		self.description:SetTextColor(color_white)
		self.description:SetContentAlignment(5)
		self.description:SetMouseInputEnabled(true)
		self.description:SetCursor("hand")

		self.description.Paint = function(this, width, height)
			draw.RoundedBoxEx(8, 0, 0, width, height, Color(0, 0, 0, 240), false, false, true, true)
		end

		self.description.OnMousePressed = function(this, code)
			if (code == MOUSE_LEFT) then
				ix.command.Send("CharDesc")

				if (IsValid(ix.gui.menu)) then
					ix.gui.menu:Remove()
				end
			end
		end

		self.description.SizeToContents = function(this)
			if (this.bWrap) then
				-- sizing contents after initial wrapping does weird things so we'll just ignore (lol)
				return
			end

			local width, height = this:GetContentSize()

			if (width > self:GetWide()) then
				this:SetWide(self:GetWide())
				this:SetTextInset(16, 8)
				this:SetWrap(true)
				this:SizeToContentsY()
				this:SetTall(this:GetTall() + 16) -- eh

				-- wrapping doesn't like middle alignment so we'll do top-center
				self.description:SetContentAlignment(8)
				this.bWrap = true
			else
				this:SetSize(width + 16, height + 16)
			end
		end
	end

	if (!suppress.characterInfo) then
		self.characterInfo = self:Add("Panel")
		self.characterInfo.list = {}
		self.characterInfo:Dock(TOP) -- no dock margin because this is handled by ixListRow
		self.characterInfo.SizeToContents = function(this)
			local height = 0

			for _, v in ipairs(this:GetChildren()) do
				if (IsValid(v) and v:IsVisible()) then
					local _, top, _, bottom = v:GetDockMargin()
					height = height + v:GetTall() + top + bottom
				end
			end

			this:SetTall(height)
		end

		if (!suppress.faction) then
            self.faction = self:Add("DLabel")
            self.faction:Dock(TOP)
            self.faction:DockMargin(0, 0, 0, 8)
            self.faction:SetFont("ixMenuButtonFont")
            self.faction:SetContentAlignment(5)
            self.faction:SetTextColor(team.GetColor(LocalPlayer():Team()))

            self.faction.Paint = function(self, width, height)
                draw.RoundedBoxEx(8, 0, 0, width, height, Color(0, 0, 0, 240), false, false, true, true)
            end

            self.faction.SizeToContents = function(this)
                if (this.bWrap) then
                    -- sizing contents after initial wrapping does weird things so we'll just ignore (lol)
                    return
                end
    
                local width, height = this:GetContentSize()
    
                if (width > self:GetWide()) then
                    this:SetWide(self:GetWide())
                    this:SetTextInset(16, 8)
                    this:SetWrap(true)
                    this:SizeToContentsY()
                    this:SetTall(this:GetTall() + 16) -- eh
    
                    -- wrapping doesn't like middle alignment so we'll do top-center
                    self.faction:SetContentAlignment(8)
                    this.bWrap = true
                else
                    this:SetSize(width + 16, height + 16)
                end
            end
    
		end

		if (!suppress.class) then
            self.class = self:Add("DLabel")
            self.class:Dock(TOP)
            self.class:DockMargin(0, 0, 0, 8)
            self.class:SetFont("ixMenuButtonFont")
            self.class:SetContentAlignment(5)
            self.class:SetTextColor(team.GetColor(LocalPlayer():Team()))

            self.class.Paint = function(self, width, height)
                draw.RoundedBoxEx(8, 0, 0, width, height, Color(0, 0, 0, 240), false, false, true, true)
            end

            self.class.SizeToContents = function(this)
                if (this.bWrap) then
                    -- sizing contents after initial wrapping does weird things so we'll just ignore (lol)
                    return
                end
    
                local width, height = this:GetContentSize()
    
                if (width > self:GetWide()) then
                    this:SetWide(self:GetWide())
                    this:SetTextInset(16, 8)
                    this:SetWrap(true)
                    this:SizeToContentsY()
                    this:SetTall(this:GetTall() + 16) -- eh
    
                    -- wrapping doesn't like middle alignment so we'll do top-center
                    self.class:SetContentAlignment(8)
                    this.bWrap = true
                else
                    this:SetSize(width + 16, height + 16)
                end
            end
		end

		if (!suppress.money) then
            self.money = self:Add("DLabel")
            self.money:Dock(TOP)
            self.money:DockMargin(0, 0, 0, 8)
            self.money:SetFont("ixMenuButtonFont")
            self.money:SetContentAlignment(5)
            self.money:SetTextColor(Color(0, 200, 0, 255))

            self.money.Paint = function(self, width, height)
                draw.RoundedBoxEx(8, 0, 0, width, height, Color(0, 0, 0, 240), false, false, true, true)
            end

            self.money.SizeToContents = function(this)
                if (this.bWrap) then
                    -- sizing contents after initial wrapping does weird things so we'll just ignore (lol)
                    return
                end
    
                local width, height = this:GetContentSize()
    
                if (width > self:GetWide()) then
                    this:SetWide(self:GetWide())
                    this:SetTextInset(16, 8)
                    this:SetWrap(true)
                    this:SizeToContentsY()
                    this:SetTall(this:GetTall() + 16) -- eh
    
                    -- wrapping doesn't like middle alignment so we'll do top-center
                    self.money:SetContentAlignment(8)
                    this.bWrap = true
                else
                    this:SetSize(width + 16, height + 16)
                end
            end
		end

		hook.Run("CreateCharacterInfo", self.characterInfo)
		self.characterInfo:SizeToContents()
	end

	-- no need to update since we aren't showing the attributes panel
	if (!suppress.attributes) then
		local character = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()

		if (character) then
			self.attributes = self:Add("ixCategoryPanel")
			self.attributes:SetText(L("attributes"))
			self.attributes:Dock(TOP)
			self.attributes:DockMargin(0, 0, 0, 8)
			self.attributes.Paint = function(this, width, height)
                draw.RoundedBoxEx(4, 0, 0, width, height, Color(0, 0, 0, 240), false, false, true, true)
                surface.SetTextPos(4, 4)
                surface.SetTextColor(255, 255, 255, 255)
                surface.DrawText(L("attributes"))
			end

			local boosts = character:GetBoosts()
			local bFirst = true

            -- ix.attributes.list sorted by highest value to lowest
            local attribs = {}

            for k, v in next, (ix.attributes.list) do
                local value = character:GetAttribute(k, 0)

                if boosts[k] then
                    for _, bValue in next, (boosts[k]) do
                        value = value + bValue
                    end
                end

                table.insert(attribs, {name = v.name, value = value})
            end

            table.sort(attribs, function(a, b)
                return a.value > b.value
            end)

            for i,v in ipairs(attribs) do
                local boost = 0

                if (boosts[v.name]) then
                    for _, bValue in pairs(boosts[v.name]) do
                        boost = boost + bValue
                    end
                end

                local bar = self.attributes:Add("ixAttributeBar")
                bar:Dock(TOP)

                if (!bFirst) then
                    bar:DockMargin(0, 5, 0, 0)
                else
                    bFirst = false
                end

                local value = v.value
                bar:SetValue(value - boost or 0)
                bar:SetBoost(boost or 0)

                local maximum = ix.config.Get("maxAttributes", 100)
                bar:SetMax(maximum)
                bar:SetReadOnly()
                bar:SetText(Format("%s [%.1f/%.1f] (%.1f%%)", L(v.name), value, maximum, value / maximum * 100))
            end

			self.attributes:SizeToContents()
		end

        if (!suppress.time) then
            local format = ix.option.Get("24hourTime", false) and "%A, %B %d, %Y. %H:%M" or "%A, %B %d, %Y. %I:%M %p"
    
            self.time = self:Add("DLabel")
            self.time:SetFont("ixMediumFont")
            self.time:SetTall(28)
            self.time:SetContentAlignment(5)
            self.time:Dock(TOP)
            self.time:SetTextColor(color_white)
            self.time:SetExpensiveShadow(1, Color(0, 0, 0, 240))
            self.time:DockMargin(0, 0, 0, 32)
            self.time:SetText(ix.date.GetFormatted(format))
            self.time.Think = function(this)
                if ((this.nextTime or 0) < CurTime()) then
                    this:SetText(ix.date.GetFormatted(format))
                    this.nextTime = CurTime() + 0.5
                end
            end
        end
	end

	hook.Run("CreateCharacterInfoCategory", self)
end

function PANEL:Update(character)
	if (!character) then
		return
	end

	local faction = ix.faction.indices[character:GetFaction()]
	local class = ix.class.list[character:GetClass()]

	if (self.name) then
		self.name:SetText(character:GetName())

		if (faction) then
			self.name.backgroundColor = Color(0, 0, 0, 240)
		end

		self.name:SizeToContents()
	end

	if (self.description) then
		self.description:SetText(character:GetDescription())
		self.description:SizeToContents()
	end

	if (self.faction) then
		self.faction:SetText(L(faction.name))
		self.faction:SizeToContents()
	end

	if (self.class) then
		-- don't show class label if the class is the same name as the faction
		if (class and class.name != faction.name) then
			self.class:SetText(L(class.name))
			self.class:SizeToContents()
		else
			self.class:SetVisible(false)
		end
	end

	if (self.money) then
		self.money:SetText(ix.currency.Get(character:GetMoney()))
		self.money:SizeToContents()
	end

	hook.Run("UpdateCharacterInfo", self.characterInfo, character)

	self.characterInfo:SizeToContents()

	hook.Run("UpdateCharacterInfoCategory", self, character)
end

function PANEL:OnSubpanelRightClick()
	properties.OpenEntityMenu(LocalPlayer())
end

vgui.Register("ixCharacterInfo", PANEL, "DScrollPanel")

hook.Add("CreateMenuButtons", "ixCharInfo", function(tabs)
	tabs["you"] = {
		bHideBackground = true,
		buttonColor = ix.config.Get("color"),
		Create = function(info, container)
			container.infoPanel = container:Add("ixCharacterInfo")

			container.OnMouseReleased = function(this, key)
				if (key == MOUSE_RIGHT) then
					this.infoPanel:OnSubpanelRightClick()
				end
			end
		end,
		OnSelected = function(info, container)
			container.infoPanel:Update(LocalPlayer():GetCharacter())
			ix.gui.menu:SetCharacterOverview(true)
		end,
		OnDeselected = function(info, container)
			ix.gui.menu:SetCharacterOverview(false)
		end
	}
end)
