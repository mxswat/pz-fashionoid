TransmogCore = {
    itemToTransmog = nil
}

TransmogCore.canBeTransmogged = function (item)
    if item.getScriptItem then
        if item:getCategory() == "Clothing" then
            return true
        end
    
        if instanceof(item, "InventoryContainer") and item:getBodyLocation() then
            return true
        end
    else
        local typeString = item:getTypeString() 
        -- local displayCategory = item:getDisplayCategory()
        local isClothing = typeString == 'Clothing'
        local isBackpack = typeString == "Container" and item:getBodyLocation()
        if isClothing or isBackpack then
            return true
        end

    end
end

TransmogCore.setItemToTransmog = function (item)
    TransmogCore.itemToTransmog = item;
end

TransmogCore.getItemTransmog = function (item)
    local player = getPlayer();
    local playerdata = player:getModData();
    local transmogTable = playerdata.transmogTable or {};

    local fullName = item:getScriptItem():getFullName()

    local transmogFullName = transmogTable[fullName] 
    return transmogFullName and ScriptManager.instance:getItem(transmogTable[fullName]) or nil
end

TransmogCore.applyTransmogToItem = function (itemToUse)
    local player = getPlayer();
    local itemToTransmogScriptItem = TransmogCore.itemToTransmog:getScriptItem()
    
    local playerdata = player:getModData();
    local transmogTable = playerdata.transmogTable or {};
    transmogTable[itemToTransmogScriptItem:getFullName()] = itemToUse:getFullName();
    playerdata.transmogTable = transmogTable;

    player:resetModelNextFrame();
    triggerEvent("OnClothingUpdated", player);
end

TransmogCore.applyTransmogToPlayer = function ()
    local player = getPlayer();
    local playerdata = player:getModData();
    local transmogTable = playerdata.transmogTable or {};
    
    local inv = player:getInventory();
    for i = 0, inv:getItems():size() - 1 do
        local item = inv:getItems():get(i);
        if item ~= nil and TransmogCore.canBeTransmogged(item)and transmogTable[item:getScriptItem():getFullName()] ~= nil then
            local scriptItem = item:getScriptItem()
            local sourceItemName = transmogTable[item:getScriptItem():getFullName()]
            print(scriptItem:getFullName()..' has to be transmogged into'..transmogTable[scriptItem:getFullName()])

            local sourceItem = ScriptManager.instance:getItem(sourceItemName)
            local sourceItemAsset = sourceItem:getClothingItemAsset()
            scriptItem:setClothingItemAsset(sourceItemAsset)
        end
    end

    player:resetModelNextFrame();
end

Events.OnClothingUpdated.Add(TransmogCore.applyTransmogToPlayer);
Events.OnGameStart.Add(TransmogCore.applyTransmogToPlayer);