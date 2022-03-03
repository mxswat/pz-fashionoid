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

        TransmogCore.setItemToTransmog(testItem)
	end
    
    return context
end