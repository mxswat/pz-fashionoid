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
        local subMenuContext = context:getNew(context);
        context:addSubMenu(option, subMenuContext);

        ISInventoryPaneContextMenu.addTransmogOptions(subMenuContext, clothing)

        local clothingItem = clothing:getClothingItem()
        if clothingItem:getAllowRandomTint() then
            ISInventoryPaneContextMenu.addColorChangeContextMenu(subMenuContext, clothing)
        end

        local textureChoices = clothingItem:hasModel() and clothingItem:getTextureChoices() or clothingItem:getBaseTextures()
	    if textureChoices and (textureChoices:size() > 1) then
            ISInventoryPaneContextMenu.addTextureChangeContextMenu(subMenuContext, clothing)
        end
        TransmogCore.setItemToTransmog(clothing)
	end

    return context
end

ISInventoryPaneContextMenu.addTransmogOptions = function (context, item)
    local option_transmog = context:addOption("Transmogrify", nil, ISTransmogListViewer.OnOpenPanel);
    local option_reset = context:addOption("Reset", item, TransmogCore.resetItemTransmog);
    local option_hide = context:addOption("Hide", item, TransmogCore.hideItem);
end

ISInventoryPaneContextMenu.addColorChangeContextMenu = function (context, testItem)
    local option_color = context:addOption("Change Color", testItem, function ()
        local modal = ISColorPickerModal:new(0, 0, 280, 180, "Change color of "..testItem:getDisplayName(), 'None');
        modal:initialise();
        modal:addToUIManager();
        modal:setOnSelectionCallback(TransmogCore.changeItemColor)
    end);
end

ISInventoryPaneContextMenu.addTextureChangeContextMenu = function (context, testItem)
    local option_texture = context:addOption("Change Texture", testItem, function ()
        local modal = ISTexturePickerModal:new(0, 0, 280, 180, "Change Texture of "..testItem:getDisplayName(), 'None');
        modal:initialise();
        modal:addToUIManager();
        modal:setOnSelectionCallback(TransmogCore.changeTexture)
    end);
end