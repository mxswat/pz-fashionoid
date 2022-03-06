--***********************************************************
--**              	  ROBERT JOHNSON                       **
--***********************************************************

ISTransmogListViewer = ISPanel:derive("ISTransmogListViewer");
ISTransmogListViewer.messages = {};

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

--************************************************************************--
--** ISTransmogListViewer:initialise
--**
--************************************************************************--

function ISTransmogListViewer:initialise()
    ISPanel.initialise(self);
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local padBottom = 10

    local top = 50
    self.panel = ISTabPanel:new(10, top, self.width - 10 * 2, self.height - padBottom - btnHgt - padBottom - top);
    self.panel:initialise();
    self.panel.borderColor = { r = 0, g = 0, b = 0, a = 0};
    self.panel.target = self;
    self.panel.equalTabWidth = false
    self:addChild(self.panel);

    self.ok = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("IGUI_CraftUI_Close"), self, ISTransmogListViewer.onClick);
    self.ok.internal = "CLOSE";
    self.ok.anchorTop = false
    self.ok.anchorBottom = true
    self.ok:initialise();
    self.ok:instantiate();
    self.ok.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.ok);
    
    self:initList();
end

function ISTransmogListViewer:initList()
    self.items = getAllItems();

    -- we gonna separate items by module
    self.module = {};
    local moduleNames = {}
    local allItems = {}
    for i=0,self.items:size()-1 do
        local item = self.items:get(i);
        --The following code is used to generate a list of all items in the game
        --in a format that allows for easier conversion into an excel / google sheets

        local isImmersiveMode = TransmogCore.isImmersiveMode()
        local isUnlocked = (isImmersiveMode and TransmogCore.immersiveModeFilter(item:getFullName())) or not isImmersiveMode

        if not item:getObsolete() and not item:isHidden() and TransmogCore.canBeTransmogged(item) and isUnlocked then
            if not self.module[item:getModuleName()] then
                self.module[item:getModuleName()] = {}
                table.insert(moduleNames, item:getModuleName())
            end
            table.insert(self.module[item:getModuleName()], item);
            table.insert(allItems, item)
        end
    end

    table.sort(moduleNames, function(a,b) return not string.sort(a, b) end)

    local listBox = ISTransmogListTable:new(0, 0, self.panel.width, self.panel.height - self.panel.tabHeight, self);
    listBox:initialise();
    self.panel:addView("All", listBox);
--    listBox.parent = self;
    listBox:initList(allItems)

    for _,moduleName in ipairs(moduleNames) do
        -- we ignore the "Moveables" module
        if moduleName ~= "Moveables" then
            local cat1 = ISTransmogListTable:new(0, 0, self.panel.width, self.panel.height - self.panel.tabHeight, self);
            cat1:initialise();
            self.panel:addView(moduleName, cat1);
--            cat1.parent = self;
            cat1:initList(self.module[moduleName])
        end
    end
    self.panel:activateView("All");
end

function ISTransmogListViewer:prerender()
    local z = 20;
    local splitPoint = 100;
    local x = 10;
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawText(getText("IGUI_TransmogList"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_TransmogList")) / 2), z, 1,1,1,1, UIFont.Medium);
end

function ISTransmogListViewer:onClick(button)
    if button.internal == "CLOSE" then
        self:setVisible(false);
        self:removeFromUIManager();
    end
end

function ISTransmogListViewer:onSelectPlayer()
end

function ISTransmogListViewer.OnOpenPanel()
    if ISTransmogListViewer.instance then
        ISTransmogListViewer.instance:close()
    end
    local modal = ISTransmogListViewer:new(50, 200, 850, 650)
    modal:initialise();
    modal:addToUIManager();
end

--************************************************************************--
--** ISTransmogListViewer:new
--**
--************************************************************************--
function ISTransmogListViewer:new(x, y, width, height)
    local o = {}
    x = getCore():getScreenWidth() / 2 + (width / 5);
    y = getCore():getScreenHeight() / 2 - (height / 2);
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.width = width;
    o.height = height;
    o.moveWithMouse = true;
    ISTransmogListViewer.instance = o;
    ISDebugMenu.RegisterClass(self);
    return o;
end

--***********************************************************
--**                    ROBERT JOHNSON                     **
--***********************************************************

require "ISUI/ISPanel"

ISTransmogListTable = ISPanel:derive("ISTransmogListTable");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2

function ISTransmogListTable:initialise()
    ISPanel.initialise(self);
end


function ISTransmogListTable:render()
    ISPanel.render(self);
    
    local y = self.datas.y + self.datas.height + 5
    self:drawText(getText("IGUI_DbViewer_TotalResult") .. self.totalResult, 0, y, 1,1,1,1,UIFont.Small)
    self:drawText(getText("IGUI_TransmogList_Info"), 0, y + FONT_HGT_SMALL, 1,1,1,1,UIFont.Small)

    y = self.filters:getBottom()
    
    self:drawRectBorder(self.datas.x, y, self.datas:getWidth(), HEADER_HGT, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawRect(self.datas.x, y+1, self.datas:getWidth(), HEADER_HGT, self.listHeaderColor.a, self.listHeaderColor.r, self.listHeaderColor.g, self.listHeaderColor.b);

    local x = 0;
    for i,v in ipairs(self.datas.columns) do
        local size;
        if i == #self.datas.columns then
            size = self.datas.width - x
        else
            size = self.datas.columns[i+1].size - self.datas.columns[i].size
        end
--        print(v.name, x, v.size)
        self:drawText(v.name, x+10+3, y+2, 1,1,1,1,UIFont.Small);
        self:drawRectBorder(self.datas.x + x, y, 1, self.datas.itemheight + 1, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b);
        x = x + size;
    end
end

function ISTransmogListTable:new (x, y, width, height, viewer)
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    o.listHeaderColor = {r=0.4, g=0.4, b=0.4, a=0.3};
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=0};
    o.backgroundColor = {r=0, g=0, b=0, a=1};
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5};
    o.totalResult = 0;
    o.filterWidgets = {};
    o.filterWidgetMap = {}
    o.viewer = viewer
    ISTransmogListTable.instance = o;
    return o;
end

function ISTransmogListTable:createChildren()
    ISPanel.createChildren(self);
    
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local entryHgt = FONT_HGT_MEDIUM + 2 * 2
    local bottomHgt = 5 + FONT_HGT_SMALL * 2 + 5 + btnHgt + 20 + FONT_HGT_LARGE + HEADER_HGT + entryHgt

    self.datas = ISScrollingListBox:new(0, HEADER_HGT, self.width, self.height - bottomHgt - HEADER_HGT);
    self.datas:initialise();
    self.datas:instantiate();
    self.datas.itemheight = FONT_HGT_SMALL + 4 * 2
    self.datas.selected = 0;
    self.datas.joypadParent = self;
    self.datas.font = UIFont.NewSmall;
    self.datas.doDrawItem = self.drawDatas;
    self.datas.drawBorder = true;
--    self.datas.parent = self;
    self.datas:addColumn("Type", 0);
    self.datas:addColumn("Name", 200);
    self.datas:addColumn("Category", 450);
    self.datas:addColumn("DisplayCategory", 650)
    self.datas:setOnMouseDoubleClick(self, ISTransmogListTable.transmogItem);
    self:addChild(self.datas);

    local btnY = self.datas.y + self.datas.height + 5 + FONT_HGT_SMALL * 2 + 5

    self.filters = ISLabel:new(0, btnY + 20, FONT_HGT_LARGE, getText("IGUI_DbViewer_Filters"), 1, 1, 1, 1, UIFont.Large, true)
    self.filters:initialise()
    self.filters:instantiate()
    self:addChild(self.filters)
    
    local x = 0;
    local entryY = self.filters:getBottom() + self.datas.itemheight
    for i,column in ipairs(self.datas.columns) do
        local size;
        if i == #self.datas.columns then -- last column take all the remaining width
            size = self.datas:getWidth() - x;
        else
            size = self.datas.columns[i+1].size - self.datas.columns[i].size
        end
        if column.name == "Category" then
            local combo = ISComboBox:new(x, entryY, size, entryHgt)
            combo.font = UIFont.Medium
            combo:initialise()
            combo:instantiate()
            combo.columnName = column.name
            combo.target = combo
            combo.onChange = self.onFilterChange
            combo.itemsListFilter = self.filterCategory
            self:addChild(combo)
            table.insert(self.filterWidgets, combo)
            self.filterWidgetMap[column.name] = combo
        elseif column.name == "DisplayCategory" then
            local combo = ISComboBox:new(x, entryY, size, entryHgt)
            combo.font = UIFont.Medium
            combo:initialise()
            combo:instantiate()
            combo.columnName = column.name
            combo.target = combo
            combo.onChange = self.onFilterChange
            combo.itemsListFilter = self.filterDisplayCategory
            self:addChild(combo)
            table.insert(self.filterWidgets, combo)
            self.filterWidgetMap[column.name] = combo
        else
            local entry = ISTextEntryBox:new("", x, entryY, size, entryHgt);
            entry.font = UIFont.Medium
            entry:initialise();
            entry:instantiate();
            entry.columnName = column.name;
            entry.itemsListFilter = self['filter'..column.name]
            entry.onTextChange = ISTransmogListTable.onFilterChange;
            entry.target = self;
            entry:setClearButton(true)
            self:addChild(entry);
            table.insert(self.filterWidgets, entry);
            self.filterWidgetMap[column.name] = entry
        end
        x = x + size;
    end
end

function ISTransmogListTable:transmogItem(item)
    local playerObj = getPlayer()
    if not playerObj or playerObj:isDead() then return end
    -- playerObj:getInventory():AddItem(item:getFullName())
    TransmogCore.applyTransmogToItem(item)
end

function ISTransmogListTable:onAddItem(button, item)
    if button.internal == "OK" then
        for i=0,tonumber(button.parent.entry:getText()) - 1 do
            self:transmogItem(item);
        end
    end
end

function ISTransmogListTable:initList(module)
    self.totalResult = 0;
    local categoryNames = {}
    local displayCategoryNames = {}
    local categoryMap = {}
    local displayCategoryMap = {}
    for x,v in ipairs(module) do
        self.datas:addItem(v:getDisplayName(), v);
        if not categoryMap[v:getTypeString()] then
            categoryMap[v:getTypeString()] = true
            table.insert(categoryNames, v:getTypeString())
        end
        if not displayCategoryMap[v:getDisplayCategory()] then
            displayCategoryMap[v:getDisplayCategory()] = true
            table.insert(displayCategoryNames, v:getDisplayCategory())
        end
        self.totalResult = self.totalResult + 1;
    end
    table.sort(self.datas.items, function(a,b) return not string.sort(a.item:getDisplayName(), b.item:getDisplayName()); end);

    local combo = self.filterWidgetMap.Category
    table.sort(categoryNames, function(a,b) return not string.sort(a, b) end)
    combo:addOption("<Any>")
    for _,categoryName in ipairs(categoryNames) do
        combo:addOption(categoryName)
    end

    local combo = self.filterWidgetMap.DisplayCategory
    table.sort(displayCategoryNames, function(a,b) return not string.sort(a, b) end)
    combo:addOption("<Any>")
    combo:addOption("<No category set>")
    for _,displayCategoryName in ipairs(displayCategoryNames) do
        combo:addOption(displayCategoryName)
    end
end

function ISTransmogListTable:update()
    -- local playerNum = self.viewer.playerSelect.selected - 1
    -- local playerObj = getSpecificPlayer(playerNum)
    -- local hasPlayer = playerObj ~= nil

    -- self.buttonAdd1.enable = self.datas.selected > 0 and hasPlayer;
    -- self.buttonAdd2.enable = self.datas.selected > 0 and hasPlayer;
    -- self.buttonAdd5.enable = self.datas.selected > 0 and hasPlayer;
    -- self.buttonAddMultiple.enable = self.datas.selected > 0 and hasPlayer;
    -- self.datas.doDrawItem = self.drawDatas;
end

function ISTransmogListTable:filterDisplayCategory(widget, scriptItem)
    if widget.selected == 1 then return true end -- Any category
    if widget.selected == 2 then return scriptItem:getDisplayCategory() == nil end
    return scriptItem:getDisplayCategory() == widget:getOptionText(widget.selected)
end

function ISTransmogListTable:filterCategory(widget, scriptItem)
    if widget.selected == 1 then return true end -- Any category
    return scriptItem:getTypeString() == widget:getOptionText(widget.selected)
end

function ISTransmogListTable:filterName(widget, scriptItem)
    local txtToCheck = string.lower(scriptItem:getDisplayName())
    local filterTxt = string.lower(widget:getInternalText())
    return string.match(txtToCheck, filterTxt)
end

function ISTransmogListTable:filterType(widget, scriptItem)
    local txtToCheck = string.lower(scriptItem:getName())
    local filterTxt = string.lower(widget:getInternalText())
    return string.match(txtToCheck, filterTxt)
end

function ISTransmogListTable.onFilterChange(widget)
    local datas = widget.parent.datas;
    if not datas.fullList then datas.fullList = datas.items; end
    widget.parent.totalResult = 0;
    datas:clear();
--print(entry.parent, combo)
--    local filterTxt = entry:getInternalText();
--    if filterTxt == "" then datas.items = datas.fullList; return; end
    for i,v in ipairs(datas.fullList) do -- check every items
        local add = true;
        for j,widget in ipairs(widget.parent.filterWidgets) do -- check every filters
            if not widget.itemsListFilter(self, widget, v.item) then
                add = false
                break
            end
        end
        if add then
            datas:addItem(i, v.item);
            widget.parent.totalResult = widget.parent.totalResult + 1;
        end
    end
end

function ISTransmogListTable:drawDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end
    
    local a = 0.9;

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.7, 0.35, 0.15);
    end

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.6, 0.5, 0.5);
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    local iconX = 4
    local iconSize = FONT_HGT_SMALL;
    local xoffset = 10;

    local clipX = self.columns[1].size
    local clipX2 = self.columns[2].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)
    
    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.item:getName(), xoffset, y + 4, 1, 1, 1, a, self.font);
    self:clearStencilRect()

    clipX = self.columns[2].size
    clipX2 = self.columns[3].size
    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.item:getDisplayName(), self.columns[2].size + iconX + iconSize + 4, y + 4, 1, 1, 1, a, self.font);
    self:clearStencilRect()

    clipX = self.columns[3].size
    clipX2 = self.columns[4].size
    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.item:getTypeString(), self.columns[3].size + xoffset, y + 4, 1, 1, 1, a, self.font);
    self:clearStencilRect()

    if item.item:getDisplayCategory() ~= nil then
        self:drawText(getText("IGUI_ItemCat_" .. item.item:getDisplayCategory()), self.columns[4].size + xoffset, y + 4, 1, 1, 1, a, self.font);
        else
        self:drawText("Error: No category set", self.columns[4].size + xoffset, y + 4, 1, 1, 1, a, self.font);
    end


    self:repaintStencilRect(0, clipY, self.width, clipY2 - clipY)

    local icon = item.item:getIcon()
    if item.item:getIconsForTexture() and not item.item:getIconsForTexture():isEmpty() then
        icon = item.item:getIconsForTexture():get(0)
    end
    if icon then
        local texture = getTexture("Item_" .. icon)
        if texture then
            self:drawTextureScaledAspect2(texture, self.columns[2].size + iconX, y + (self.itemheight - iconSize) / 2, iconSize, iconSize,  1, 1, 1, 1);
        end
    end
    
    return y + self.itemheight;
end
