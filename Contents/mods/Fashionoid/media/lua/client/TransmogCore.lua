TransmogCore = TransmogCore or {}
TransmogCore.itemToTransmog = nil
TransmogCore.clothingItemAssetsBackup = {}
TransmogCore.immersiveMode = TransmogCore.immersiveMode or false

TransmogCore.isBannedItem = function (item)
    local fullName = item.getScriptItem and item:getScriptItem():getFullName() or item:getFullName()
    return fullName == "Base.KeyRing"
end

TransmogCore.canBeTransmogged = function (item)
    if TransmogCore.isBannedItem(item) then
        return false
    end

    if item.getScriptItem then
        item = item:getScriptItem()
    end

    local typeString = item:getTypeString() 
    local isClothing = typeString == 'Clothing'
    local isBackpack = typeString == "Container" and item:getBodyLocation()
    -- if it has no clothingItemAsset there is no point in trasmoging it since it will not be transmogged anyway
    local clothingItemAsset = item:getClothingItemAsset()
    if (isClothing or isBackpack) and clothingItemAsset ~= nil then
        return true
    end
end

TransmogCore.isImmersiveMode = function ()
    return TransmogCore.immersiveMode
end

TransmogCore.immersiveModeFilter = function (fullName)
    local player = getPlayer();
    local playerdata = player:getModData();
    local transmogItemsMap = playerdata.transmogItemsMap or {}

    return transmogItemsMap[fullName] == true
end

TransmogCore.setItemToTransmog = function (item)
    TransmogCore.itemToTransmog = item;
end

TransmogCore.getItemToTransmog = function ()
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
    local receiverItem = TransmogCore.getItemToTransmog()
    local receiverScriptItem = receiverItem:getScriptItem()

    -- Checking for nil, since I can pass nil to invalidate the transmog table for the cached item when resetting an item
    local donorFullName = _itemToUse ~= nil and _itemToUse:getFullName() or nil;

    local playerdata = player:getModData();
    local transmogTable = TransmogCore.getTransmogTable()
    transmogTable[receiverScriptItem:getFullName()] = donorFullName
    playerdata.transmogTable = transmogTable;

    -- NEW CODE HERE

    local spawnedItem = player:getInventory():AddItem(_itemToUse:getFullName())

    spawnedItem:setScratchDefense(99)

    local paramsToCheck = {
        "Temperature",
        "Insulation",
        "ConditionLowerChance",
        "StompPower",
        "RunSpeedModifier",
        "CombatSpeedModifier",
        "RemoveOnBroken",
        "CanHaveHoles",
        "WeightWet",
        "BiteDefense",
        "BulletDefense",
        "NeckProtectionModifier",
        "ScratchDefense",
        "ChanceToFall",
        "Windresistance",
        "WaterResistance",
        "AlarmSound",
        "BloodClothingType"
        -- "SoundRadius",
    }

    -- BloodLocation
    print('--------------paramsToCheck----------------')
    for _, param in ipairs(paramsToCheck) do
        local getParam = "get"..param;
        local setParam = "set"..param;
        if receiverItem[getParam] then
            local value = receiverItem[getParam](receiverItem);
            print(getParam..":"..tostring(value));
            spawnedItem[setParam](spawnedItem, value);
        end
    end

    -- createNewScriptItem -- BROKEN FROM HERE
    local a = cloneItemType(receiverScriptItem:getFullName()..'_Transmogged', receiverScriptItem:getFullName())
    -- a:setClothingItemAsset(_itemToUse:getScriptItem():getClothingItemAsset())
    spawnedItem:setScriptItem(a)
        
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
            print(receiverFullName..' has to be transmogged into '..donorFullName)
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

TransmogCore.hideItem = function ()
    local keyRingScriptItem = ScriptManager.instance:getItem("Base.Belt2")
    TransmogCore.applyTransmogToItem(keyRingScriptItem)
end

TransmogCore.resetPlayerModelNextFrame = function ()
    local player = getPlayer();
    player:resetModelNextFrame();
    sendVisual(player)
end

TransmogCore.changeTexture = function (i)
    TransmogCore.getItemToTransmog():getVisual():setTextureChoice(i)
    TransmogCore.resetPlayerModelNextFrame()
end

TransmogCore.changeItemColor = function (color)
    TransmogCore.getItemToTransmog():getVisual():setTint(color)
    TransmogCore.resetPlayerModelNextFrame()
end

TransmogCore.resetTransmogTable = function ()
    local player = getPlayer();
    local playerdata = player:getModData();
    playerdata.transmogTable = {};
    player:resetModelNextFrame();
    TransmogCore.clothingItemAssetsBackup = {}
end

Events.OnClothingUpdated.Add(TransmogCore.applyTransmogToPlayer);
Events.OnGameStart.Add(TransmogCore.applyTransmogToPlayer);