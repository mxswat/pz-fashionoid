TransmogCore = TransmogCore or {}
TransmogCore.immersiveMode = true

local old_ISInventoryPane_refreshContainer = ISInventoryPane.refreshContainer
function ISInventoryPane:refreshContainer()
	local result = old_ISInventoryPane_refreshContainer(self)
	
    local player = getPlayer();
    local playerdata = player:getModData();
    local transmogItemsMap = playerdata.transmogItemsMap or {}
    
    for _, v in pairs(self.itemindex) do
        local item = v.items[1]
        if v ~= nil and TransmogCore.canBeTransmogged(item) then
            transmogItemsMap[item:getScriptItem():getFullName()] = true
        end
    end
    
    playerdata.transmogItemsMap = transmogItemsMap
    TransmogCore.transmogItemsMapCache = transmogItemsMap
	return result
end
