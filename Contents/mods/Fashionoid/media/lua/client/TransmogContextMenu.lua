require "ISUI/ISInventoryPaneContextMenu"

local old_ISInventoryPaneContextMenu_createMenu = ISInventoryPaneContextMenu.createMenu
ISInventoryPaneContextMenu.createMenu = function(player, isInPlayerInventory, items, x, y, origin)
    local context = old_ISInventoryPaneContextMenu_createMenu(player, isInPlayerInventory, items, x, y, origin)
    local testItem = nil
    local clothing = nil
    for _, v in ipairs(items) do
        testItem = v;
        if not instanceof(v, "InventoryItem") then
            testItem = v.items[1];
        end
        if TransmogCore.canBeTransmogged(testItem) then
            clothing = testItem;
        end
    end

    if tostring(#items) == "1" and clothing then
        local option = context:addOption("Transmog Menu");
        local subMenu = context:getNew(context);
        context:addSubMenu(option, subMenu);
        context = subMenu;

        local option_transmog = context:addOption("Transmogrify", items, ISTransmogListViewer.OnOpenPanel, player);
        local option_reset = context:addOption("Reset", testItem, TransmogCore.resetItemTransmog);
        local option_hide = context:addOption("Hide", testItem, TransmogCore.hideItem);
        local clothingItem = clothing:getClothingItem()

        if clothingItem:getAllowRandomTint() then
            local option_color = context:addOption("Change Color", testItem, function ()
                local modal = ISColorPickerModal:new(0, 0, 280, 180, "Change color of "..testItem:getDisplayName(), 'None');
                modal:initialise();
                modal:addToUIManager();
                modal:setOnPickedColorCallback(TransmogCore.changeItemColor)
            end);
        end

        local textureChoices = clothingItem:hasModel() and clothingItem:getTextureChoices() or clothingItem:getBaseTextures()
	    if textureChoices and (textureChoices:size() > 1) then
            local textureOption = context:addOption("Change Texture");
            local texturesSubMenu = context:getNew(context);
            context:addSubMenu(textureOption, texturesSubMenu);
            context = texturesSubMenu;
            for i=0,textureChoices:size() - 1 do
                local text = getText("UI_ClothingTextureType", i + 1)
                context:addOption(text, i, TransmogCore.changeTexture);
            end
        end
        TransmogCore.setItemToTransmog(testItem)
	end
    
    return context
end

ISColorPickerModal = ISTextBox:derive("ISColorPickerModal");

function ISColorPickerModal:initialise()
    ISTextBox.initialise(self);

    local inset = 2
    local height = inset + self.fontHgt * self.numLines + inset
    self:removeChild(self.colorBtn);
    self.colorBtn = ISButton:new(self.entry.x + self.entry.width + 5, self.entry.y, height, height, "", self, ISColorPickerModal.onColorPicker);
    self.colorBtn:setX(self.entry:getX());
    self.colorBtn:setWidth(self.entry:getWidth());
    self.colorBtn:initialise();
    self.colorBtn.backgroundColor = {r = 1, g = 1, b = 1, a = 1};
    self:addChild(self.colorBtn);
    self.colorBtn:setVisible(true);
    self.entry:setVisible(false);

    self.yes:setTitle("Close")
    self:removeChild(self.no);
end

function ISColorPickerModal:setOnPickedColorCallback(functionCallback)
    self.onPickedColorCallback = functionCallback
end

function ISColorPickerModal:onColorPicker(button)
    self.colorPicker:setX(getMouseX() - 100);
    self.colorPicker:setY(getMouseY() - 20);
    self.colorPicker.pickedFunc = ISColorPickerModal.onPickedColor;
    self.colorPicker:setVisible(true);
    self.colorPicker:bringToTop();
end

function ISColorPickerModal:onPickedColor(color, mouseUp)
    self.currentColor = ColorInfo.new(color.r, color.g, color.b,1);
    self.colorBtn.backgroundColor = {r = color.r, g = color.g, b = color.b, a = 1};
    self.entry.javaObject:setTextColor(self.currentColor);
    self.colorPicker:setVisible(false);
    if self.onPickedColorCallback ~= nil then
        local color = Color.new(color.r, color.g, color.b,1);
        self.onPickedColorCallback(ImmutableColor.new(color))
    end
end