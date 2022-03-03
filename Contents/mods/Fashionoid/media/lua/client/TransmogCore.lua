TransmogCore = {
    itemToTransmog = nil,
    clothingItemAssetsBackup = {}
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

TransmogCore.getItemToTransmog = function (item)
    return TransmogCore.itemToTransmog;
end

TransmogCore.getTransmogTable = function ()
    local player = getPlayer();
    local playerdata = player:getModData();
    return playerdata.transmogTable or {};
end

TransmogCore.getItemTransmog = function (item)
    local transmogTable = TransmogCore.getTransmogTable()

    local fullName = item:getScriptItem():getFullName()

    local transmogFullName = transmogTable[fullName] 
    return transmogFullName and ScriptManager.instance:getItem(transmogTable[fullName]) or nil
end

TransmogCore.applyTransmogToItem = function (_itemToUse)
    local player = getPlayer();
    local itemToTransmog = TransmogCore.getItemToTransmog()
    local itemToTransmogScriptItem = itemToTransmog:getScriptItem()

    -- Checking for nil, since I can pass nil to invalidate the transmog table for the cached item
    local donorFullName = _itemToUse ~= nil and _itemToUse:getFullName() or nil;
    
    local playerdata = player:getModData();
    local transmogTable = TransmogCore.getTransmogTable()
    transmogTable[itemToTransmogScriptItem:getFullName()] = donorFullName
    playerdata.transmogTable = transmogTable;

    player:resetModelNextFrame();
    triggerEvent("OnClothingUpdated", player);
end

TransmogCore.applyTransmogToPlayer = function ()
    local transmogTable = TransmogCore.getTransmogTable()
    local player = getPlayer();

    local inv = player:getInventory();
    for i = 0, inv:getItems():size() - 1 do
        local receiverItem = inv:getItems():get(i);
        local receiverScriptItem = receiverItem:getScriptItem()
        local receiverFullName = receiverScriptItem:getFullName()
        local canBeTransmogged = TransmogCore.canBeTransmogged(receiverItem)
        local donorFullName = transmogTable[receiverFullName]

        if receiverItem ~= nil and canBeTransmogged and donorFullName ~= nil then
            print(receiverFullName..' has to be transmogged into'..donorFullName)
            local receiverClothingAsset = receiverItem:getScriptItem():getClothingItemAsset()
            TransmogCore.addClothingItemAssetsBackup(receiverFullName, receiverClothingAsset)
            local donorScriptItem = ScriptManager.instance:getItem(donorFullName)
            local donorClothingItemAsset = donorScriptItem:getClothingItemAsset()
            receiverScriptItem:setClothingItemAsset(donorClothingItemAsset)
        end
    end

    player:resetModelNextFrame();
end

TransmogCore.addClothingItemAssetsBackup = function (receiverFullName, receiverClothingItemAsset)
    if TransmogCore.clothingItemAssetsBackup[receiverFullName] ~= nil then
        return
    end
    TransmogCore.clothingItemAssetsBackup[receiverFullName] = receiverClothingItemAsset
end

TransmogCore.getClothingItemAssetsBackup = function (fuLLName)
    return TransmogCore.clothingItemAssetsBackup[fuLLName]
end

TransmogCore.resetItemTransmog = function (receiverItem)
    local transmogTable = TransmogCore.getTransmogTable()
    local receiverScriptItem = receiverItem:getScriptItem()
    local receiverFullName = receiverScriptItem:getFullName()
    local donorFullName = transmogTable[receiverFullName]
    if donorFullName ~= nil then
        TransmogCore.applyTransmogToItem(nil)
        receiverScriptItem:setClothingItemAsset(TransmogCore.getClothingItemAssetsBackup(receiverFullName))
    end
end

Events.OnClothingUpdated.Add(TransmogCore.applyTransmogToPlayer);
Events.OnGameStart.Add(TransmogCore.applyTransmogToPlayer);