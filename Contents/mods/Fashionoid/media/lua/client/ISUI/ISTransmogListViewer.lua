require "ISUI/AdminPanel/ISItemsListViewer"

ISTransmogListViewer = ISItemsListViewer:derive("ISTransmogListViewer");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

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
    local title_text = TransmogCore.isImmersiveMode() and "IGUI_TransmogListImmersive" or "IGUI_TransmogList"
    self:drawText(getText(title_text), self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, getText(title_text)) / 2), z, 1,1,1,1, UIFont.Medium);
end

function ISTransmogListViewer.OnOpenPanel()
    if ISTransmogListViewer.instance then
        ISTransmogListViewer.instance:close()
    end
    local modal = ISTransmogListViewer:new(50, 200, 850, 650)
    modal:initialise();
    modal:addToUIManager();
end