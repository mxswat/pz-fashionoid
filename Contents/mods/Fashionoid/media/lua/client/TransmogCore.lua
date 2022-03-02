TransmogCore = {
    itemToTransmog = nil,
    clothingItemAssetsBackup = {}
}

-- Argument is a (Script)Item or an InventoryItem
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

TransmogCore.getLocalPlayerTransmogTable = function ()
    local player = getPlayer();
    local playerdata = player:getModData();
    local transmogTable = playerdata.transmogTable or {};

    return transmogTable
end

TransmogCore.setItemToLocalPlayerTransmogTable = function (toTrnsmogName, srcTrnsmogName)
    local player = getPlayer();
    local playerdata = player:getModData();
    local transmogTable = playerdata.transmogTable or {};
    transmogTable[toTrnsmogName] = srcTrnsmogName
end

TransmogCore.setItemToTransmog = function (item)
    TransmogCore.itemToTransmog = item;
end

TransmogCore.getItemToTransmog = function (item)
    return TransmogCore.itemToTransmog
end

TransmogCore.getItemTransmog = function (item)
    local transmogTable = TransmogCore.getLocalPlayerTransmogTable()

    local fullName = item:getScriptItem():getFullName()

    local transmogFullName = transmogTable[fullName] 
    return transmogFullName and ScriptManager.instance:getItem(transmogTable[fullName]) or nil
end

TransmogCore.applyTransmogToItem = function (itemToUse)
    local player = getPlayer();
    local itemToTransmogScriptItem = TransmogCore.getItemToTransmog():getScriptItem()

    TransmogCore.setItemToLocalPlayerTransmogTable(itemToTransmogScriptItem:getFullName(), itemToUse:getFullName())

    player:resetModelNextFrame();
    triggerEvent("OnClothingUpdated", player);
end

TransmogCore.applyTransmogToPlayer = function ()
    local player = getPlayer();
    
    local transmogTable = TransmogCore.getLocalPlayerTransmogTable()
    
    local inv = player:getInventory();
    for i = 0, inv:getItems():size() - 1 do
        local itmToTransmog = inv:getItems():get(i);
        if itmToTransmog ~= nil and TransmogCore.canBeTransmogged(itmToTransmog)and transmogTable[itmToTransmog:getScriptItem():getFullName()] ~= nil then
            local itmToTrnsmgScriptItem = itmToTransmog:getScriptItem()
            local itmToTransmogFullName = itmToTransmog:getScriptItem():getFullName()
            local trnsmgSourceItemFullName = transmogTable[itmToTransmog:getScriptItem():getFullName()]

            print(itmToTrnsmgScriptItem:getFullName()..' is transmogged into '..transmogTable[itmToTrnsmgScriptItem:getFullName()])

            local itmToTrnsmgClothingItemAsset = itmToTrnsmgScriptItem:getClothingItemAsset()

            local trnsmgSourceScriptItem = ScriptManager.instance:getItem(trnsmgSourceItemFullName)
            local trnsmgSourceClothingItemAsset = trnsmgSourceScriptItem:getClothingItemAsset()

            TransmogCore.addClothingItemAssetsBackup(itmToTransmogFullName, itmToTrnsmgClothingItemAsset)
            itmToTrnsmgScriptItem:setClothingItemAsset(trnsmgSourceClothingItemAsset)
        end
    end

    player:resetModelNextFrame();
end

TransmogCore.addClothingItemAssetsBackup = function (fuLLName, clothingItemAsset)
    if TransmogCore.clothingItemAssetsBackup[fuLLName] then
        return
    end
    TransmogCore.clothingItemAssetsBackup[fuLLName] = clothingItemAsset
end

TransmogCore.getClothingItemAssetsBackup = function (fuLLName)
    return TransmogCore.clothingItemAssetsBackup[fuLLName]
end

TransmogCore.resetItemTransmog = function (itemToReset)
    local player = getPlayer();
    local itemToResetFullName = itemToReset:getScriptItem():getFullName()
    local itemToResetScriptItem = TransmogCore.getItemToTransmog():getScriptItem()
    local clothingItemAssetBackup = TransmogCore.getClothingItemAssetsBackup(itemToResetFullName)

    TransmogCore.setItemToLocalPlayerTransmogTable(itemToResetFullName, nil)

    itemToResetScriptItem:setClothingItemAsset(clothingItemAssetBackup)

    player:resetModelNextFrame();
end

Events.OnClothingUpdated.Add(TransmogCore.applyTransmogToPlayer);
Events.OnGameStart.Add(TransmogCore.applyTransmogToPlayer);