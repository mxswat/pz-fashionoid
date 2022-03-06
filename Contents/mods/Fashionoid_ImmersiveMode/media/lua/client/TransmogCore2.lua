TransmogCore = TransmogCore or {}
TransmogCore.immersiveMode = true

local old_ISInventoryPane_refreshContainer = ISInventoryPane.refreshContainer
function ISInventoryPane:refreshContainer()
	local result = old_ISInventoryPane_refreshContainer(self)
	
    local player = getPlayer();
    local playerdata = player:getModData();
    local transmogItemsMap = playerdata.transmogItemsMap or {}
    
    for _, v in pairs(self.itemindex) do
        if v ~= nil and v.items[1]:getCategory() == "Clothing" then
            transmogItemsMap[v.items[1]:getScriptItem():getFullName()] = true
        end
    end
    
    playerdata.transmogItemsMap = transmogItemsMap
    TransmogCore.transmogItemsMapCache = transmogItemsMap
	return result
end
