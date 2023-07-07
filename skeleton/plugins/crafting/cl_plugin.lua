
local backgroundColor = Color(0, 0, 0, 66)
local dark_color = Color(0, 0, 0, 50)
local color_green, color_red = Color(0, 255, 0, 100), Color(255, 0, 0, 80)

do
    local PANEL = {}

    function PANEL:Init()
        local s = 64
        self:SetSize(s, s)
    end

    function PANEL:Init_Item(item)
        self.item_table = item
    
        local character = LocalPlayer():GetCharacter()
        self.can_craft = character:CRAFT_CanCraft(item.uniqueID)

    --[==[]
        self.name = self:Add("DLabel")
        self.name:Dock(TOP)
        self.name:SetFont("ixSmallFont")
        self.name:SetText(item.GetName and item:GetName() or L(item.name))
        self.name:SetTextColor(color_white)
        self.name:SetContentAlignment(5)
        self.name:SetExpensiveShadow(1, color_black)
        
        function self.name:Paint(w, h)
            surface.SetDrawColor(dark_color)
            surface.DrawRect(0, 0, w, h)
        end
        

        self.craftable = self:Add("DLabel")
        self.craftable:Dock(BOTTOM)
        self.craftable:SetFont("ixSmallFont")
        self.craftable:SetText(self.can_craft and L"Craftable" or L"Not Craftable")
        self.craftable:SetTextColor(self.can_craft and color_green or color_red)
        self.craftable:SetContentAlignment(5)
        self.craftable:SetExpensiveShadow(1, color_black)

        function self.craftable:Paint(w, h)
            surface.SetDrawColor(dark_color)
            surface.DrawRect(0, 0, w, h)
        end
        ]==]

        self.icon = self:Add("ixItemIcon")
        self.icon:SetZPos(999)
        self.icon:Dock(FILL)
        self.icon:DockMargin(0, 0, 0, 0)
        self.icon:SetModel(item:GetModel(), item:GetSkin())
        self.icon:SetItemTable(item)
        self.icon.item_table = item

        self.icon:SetHelixTooltip(function(tooltip)
            ix.hud.PopulateItemTooltip(tooltip, item)
            local requirement_row = tooltip:AddRow("Requirements")
            requirement_row:SetTextColor(color_white)
            requirement_row:SetText("Requirements")
            requirement_row:SetImportant()
            requirement_row:SetMaxWidth(math.max(requirement_row:GetMaxWidth(), ScrW() * 0.5))
            requirement_row:SizeToContents()

            local requirements = character:CRAFT_ShowRequirements(item.uniqueID)

            for i,v in ipairs(requirements) do
                local row = tooltip:AddRow(v[1])
                row:SetBackgroundColor(dark_color)
                row:SetText(v[1] .. v[3])
                row:SetMaxWidth(math.max(row:GetMaxWidth(), ScrW() * 0.5))
                row:SizeToContents()
                row:SetTextColor(v[2] and color_green or color_red)
            end
        end)

        self.icon.ExtraPaint = function(this, w, h)
            local exIcon = ikon:GetIcon(item.uniqueID)
			if (exIcon) then
				surface.SetMaterial(exIcon)
				surface.SetDrawColor(color and color or color_white)
				surface.DrawTexturedRect(0, 0, w, h)
			else
                ikon:renderIcon(
                    item.uniqueID,
                    w,
                    h,
                    item:GetModel(),
                    item.iconCam
                )
            end
        end

        self.icon.PaintOver = function(this)
            if (item and item.PaintOver) then
                local w, h = this:GetSize()
    
                item.PaintOver(this, item, w, h)
            end

            if (self.parent and self.parent.selected == self.icon) then
                surface.SetDrawColor(color_white)
                surface.DrawOutlinedRect(0, 0, self.icon:GetWide(), self.icon:GetTall())
            end
        end

        -- OnMouseReleased
        self.icon.OnMouseReleased = function(this, key)
        end

        -- OnMousePressed
        self.icon.OnMousePressed = function(this, key)
            if (key == MOUSE_LEFT) then
                self.parent.selected = self.icon
            end
        end

        local itemTable = self.item_table
        if (itemTable.iconCam and !ICON_RENDER_QUEUE[itemTable.uniqueID]) or (itemTable.forceRender) then
            local iconCam = itemTable.iconCam
            iconCam = {
                cam_pos = iconCam.pos,
                cam_ang = iconCam.ang,
                cam_fov = iconCam.fov,
            }
            ICON_RENDER_QUEUE[itemTable.uniqueID] = true

            self.icon:RebuildSpawnIconEx(iconCam)
        end
    end

    function PANEL:SetItemTable(item)
        self.item_table = item
    end

    function PANEL:Update()
        self.can_craft = LocalPlayer():GetCharacter():CRAFT_CanCraft(self.item_table.uniqueID)
        self.craftable:SetText(self.can_craft and L"Craftable" or L"Not Craftable")
        self.craftable:SetTextColor(self.can_craft and Color(0, 255, 0) or Color(255, 0, 0))
    end

    vgui.Register("ixCraftingMainItem", PANEL, "DPanel")

end

local PANEL = {}
AccessorFunc(PANEL, "maxWidth", "MaxWidth", FORCE_NUMBER)
function PANEL:Init()
	self:SetWide(180)
	self:Dock(LEFT)

	self.maxWidth = ScrW() * 0.2
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(backgroundColor)
	surface.DrawRect(0, 0, width, height)
end

function PANEL:SizeToContents()
	local width = 0

	for _, v in ipairs(self:GetChildren()) do
		width = math.max(width, v:GetWide())
	end

	self:SetSize(math.max(32, math.min(width, self.maxWidth)), self:GetParent():GetTall())
end

vgui.Register("RCraftingMenuCategories", PANEL, "ixHelpMenuCategories")

do -- crafting menu

    PANEL = {}

    function PANEL:Init()
        self:Dock(FILL)

        self.categories = {}
        self.categorySubpanels = {}
        self.categoryPanel = self:Add("RCraftingMenuCategories")

        self.canvasPanel = self:Add("EditablePanel")
        self.canvasPanel:Dock(FILL)

        self.idlePanel = self.canvasPanel:Add("Panel")
        self.idlePanel:Dock(FILL)
        self.idlePanel:DockMargin(8, 0, 0, 0)
        self.idlePanel.Paint = function(_, width, height)
            surface.SetDrawColor(backgroundColor)
            surface.DrawRect(0, 0, width, height)

            derma.SkinFunc("DrawCoolHelixCurved", width * 0.5, height * 0.5, width * 0.25)

            surface.SetFont("ixIntroSubtitleFont")
            local text = L("helix"):lower()
            local textWidth, textHeight = surface.GetTextSize(text)

            surface.SetTextColor(color_white)
            surface.SetTextPos(width * 0.5 - textWidth * 0.5, height * 0.5 - textHeight * 0.75)
            surface.DrawText(text)

            surface.SetFont("ixMediumLightFont")
            text = L("helpIdle")
            local infoWidth, _ = surface.GetTextSize(text)

            surface.SetTextColor(color_white)
            surface.SetTextPos(width * 0.5 - infoWidth * 0.5, height * 0.5 + textHeight * 0.25)
            surface.DrawText(text)
        end

        local categories = {}
        
        local character = LocalPlayer():GetCharacter()
        for _, v in next, (ix.item.list) do
            if (v.category and !categories[v.category] and character:CRAFT_CanShow(v.uniqueID)) then
                categories[v.category] =  function(panel)
                    local parent = panel:GetParent()
                    panel:Clear()
                    panel.category = v.category
                    panel.selected_item = false

                    local items = {}
                    for _, v in next, (ix.item.list) do
                        if (v.category == panel.category and character:CRAFT_CanShow(v.uniqueID)) then
                            table.insert(items, v)
                        end
                    end

                    table.sort(items, function(a, b)
                        return a.name < b.name
                    end)

                    panel.item_list = panel:Add("DIconLayout")
                    panel.item_list:Dock(TOP)
                    panel.item_list:DockMargin(10, 1, 5, 5)
                    panel.item_list:SetSpaceX(10)
                    panel.item_list:SetSpaceY(10)

                    if !(parent.craft_button) then
                        parent.craft_button = panel:GetParent():Add("RMenuSelectionButton")
                        parent.craft_button:Dock(BOTTOM)
                        parent.craft_button:SetTall(36)
                        parent.craft_button:SetText(L"Craft")
                        parent.craft_button:SetFont("ixMediumFont")
                        parent.craft_button:DockMargin(10, 10, 5, 5)
                        parent.craft_button:SetExpensiveShadow(1, Color(0, 0, 0, 150))

                        parent.craft_button.DoClick = function()
                            if (panel.item_list.selected and panel.item_list.selected.item_table) then
                                print("crafting")
                                net.Start("char_craft")
                                    net.WriteString(panel.item_list.selected.item_table.uniqueID)
                                net.SendToServer()
                            end
                        end
                    end

                    for _, v in next, items do
                        local item = panel.item_list:Add("ixCraftingMainItem")
                        item.parent = panel.item_list
                        item:Init_Item(v)
                        item:SetTooltip(v.description)
                        item.DoClick = function()
                            panel.selected_item = v
                        end

                        function item:PaintOver(width, height)
                            if (panel.selected_item == v) then
                                surface.SetDrawColor(ix.config.Get("color"))
                                surface.DrawOutlinedRect(0, 0, width-2, height-2, 2)
                            end
                        end
                    end
                end
            end
        end

        for k, v in SortedPairs(categories) do
            if (!isstring(k)) then
                ErrorNoHalt("expected string for crafting menu key\n")
                continue
            elseif (!isfunction(v)) then
                ErrorNoHalt(string.format("expected function for crafting menu entry '%s'\n", k))
                continue
            end

            self:AddCategory(k)
            self.categories[k] = v
        end

        self.categoryPanel:SizeToContents()

        if (ix.gui.last_crafting_menu_tab) then
            self:OnCategorySelected(ix.gui.last_crafting_menu_tab)
        end
    end

    function PANEL:AddCategory(name)
        local button = self.categoryPanel:Add("RMenuSelectionButton")
        button:SetText(L(name))
        button:SizeToContents()
        -- @todo don't hardcode this but it's the only panel that needs docking at the bottom so it'll do for now
        button:Dock(name == "credits" and BOTTOM or TOP)
        button.DoClick = function()
            self:OnCategorySelected(name)
        end

        local panel = self.canvasPanel:Add("DScrollPanel")
        panel:SetVisible(false)
        panel:Dock(FILL)
        panel:DockMargin(8, 0, 0, 0)
        panel:GetCanvas():DockPadding(8, 8, 8, 8)

        panel.Paint = function(_, width, height)
            surface.SetDrawColor(backgroundColor)
            surface.DrawRect(0, 0, width, height)
        end

        -- reverts functionality back to a standard panel in the case that a category will manage its own scrolling
        panel.DisableScrolling = function()
            panel:GetCanvas():SetVisible(false)
            panel:GetVBar():SetVisible(false)
            panel.OnChildAdded = function() end
        end

        self.categorySubpanels[name] = panel
    end

    function PANEL:OnCategorySelected(name)
        local panel = self.categorySubpanels[name]

        if (!IsValid(panel)) then
            return
        end

        if (!panel.bPopulated) then
            self.categories[name](panel)
            panel.bPopulated = true
        end

        if (IsValid(self.activeCategory)) then
            self.activeCategory.selected_item = false
            self.activeCategory:SetVisible(false)
        end

        panel:SetVisible(true)
        self.idlePanel:SetVisible(false)

        self.activeCategory = panel
        ix.gui.last_crafting_menu_tab = name
    end

    vgui.Register("RCraftingMenu", PANEL, "EditablePanel")

    -- helix curved
    local function DrawHelix(width, height, color) -- luacheck: ignore 211
        local segments = 76
        local radius = math.min(width, height) * 0.375

        surface.SetTexture(-1)

        for i = 1, math.ceil(segments) do
            local angle = math.rad((i / segments) * -180)
            local x = width * 0.5 + math.sin(angle + math.pi * 2) * radius
            local y = height * 0.5 + math.cos(angle + math.pi * 2) * radius
            local barOffset = math.sin(SysTime() + i * 0.5)
            local barHeight = barOffset * radius * 0.25

            if (barOffset > 0) then
                surface.SetDrawColor(color)
            else
                surface.SetDrawColor(color.r * 0.5, color.g * 0.5, color.b * 0.5, color.a)
            end

            surface.DrawTexturedRectRotated(x, y, 4, barHeight, math.deg(angle))
        end
    end
end

hook.Add("CreateMenuButtons", "RCraftingMenu", function(tabs)
    tabs["crafting"] = function(container)
        container:Add("RCraftingMenu")
    end
end)