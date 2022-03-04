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

        if clothing:getClothingItem():getAllowRandomTint() then
            local function changeItemColor(color)
                print('color-picked: '..tostring(color))
                testItem:getVisual():setTint(color)
                TransmogCore.resetPlayerModelNextFrame()
            end

            local option_color = context:addOption("Change Color", testItem, function ()
                local modal = ISColorPickerModal:new(0, 0, 280, 180, "Change color of "..testItem:getDisplayName(), 'None');
                modal:initialise();
                modal:addToUIManager();
                modal:setOnPickedColorCallback(changeItemColor)
            end);
        end

        TransmogCore.setItemToTransmog(testItem)
	end
    
    return context
end

ISColorPickerModal = ISTextBox:derive("ISColorPickerModal");

function ISColorPickerModal:initialise()
    ISTextBox.initialise(self);

    self.colorBtn:setVisible(true);
    self.colorBtn:setX(self.entry:getX());
    self.colorBtn:setWidth(self.entry:getWidth());
    self.colorBtn.onmousedown = ISColorPickerModal.onColorPicker
    self.entry:setVisible(false);
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