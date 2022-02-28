TransmogCore = {
    itemToTransmog = nil
}

TransmogCore.setItemToTransmog = function (item)
    TransmogCore.itemToTransmog = item;
end

TransmogCore.getItemTransmog = function (item)
    local player = getPlayer();
    local playerdata = player:getModData();
    local transmogTable = playerdata.transmogTable or {};

    local fullName = item:getScriptItem():getFullName()
    return ScriptManager.instance:getItem(transmogTable[fullName])
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
        if item ~= nil and instanceof(item, "Clothing") and transmogTable[item:getScriptItem():getFullName()] ~= nil then
            local scriptItem = item:getScriptItem()
            local sourceItemName = transmogTable[item:getScriptItem():getFullName()]
            print(scriptItem:getFullName()..'has to be transmogged into'..transmogTable[scriptItem:getFullName()])

            local sourceItem = ScriptManager.instance:getItem(sourceItemName)
            local sourceItemAsset = sourceItem:getClothingItemAsset()
            scriptItem:setClothingItemAsset(sourceItemAsset)
        end
    end

    player:resetModelNextFrame();
end

Events.OnClothingUpdated.Add(TransmogCore.applyTransmogToPlayer);
Events.OnGameStart.Add(TransmogCore.applyTransmogToPlayer);