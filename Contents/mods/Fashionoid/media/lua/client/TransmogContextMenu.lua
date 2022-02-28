require "ISUI/ISInventoryPaneContextMenu"

local old_ISInventoryPaneContextMenu_createMenu = ISInventoryPaneContextMenu.createMenu
ISInventoryPaneContextMenu.createMenu = function(player, isInPlayerInventory, items, x, y, origin)
    local context = old_ISInventoryPaneContextMenu_createMenu(player, isInPlayerInventory, items, x, y, origin)
    local testItem = nil
    local clothing = nil
    for i,v in ipairs(items) do
        testItem = v;
        if not instanceof(v, "InventoryItem") then
            testItem = v.items[1];
        end
        if TransmogCore.canBeTransmogged(testItem) then
            clothing = testItem;
        end
    end
    
    if tostring(#items) == "1" and clothing then
        local option = context:addOption("Transmog", items, ISTransmogListViewer.OnOpenPanel, player);
        TransmogCore.setItemToTransmog(testItem)
	end
    
    return context
end

-- local old_ISInventoryPaneContextMenu_doWearClothingTooltip = ISInventoryPaneContextMenu.doWearClothingTooltip
-- ISInventoryPaneContextMenu.doWearClothingTooltip = function(playerObj, newItem, currentItem, option)
--     local result = old_ISInventoryPaneContextMenu_doWearClothingTooltip
--     local toolTip = option.toolTip
    
--     return result
-- end