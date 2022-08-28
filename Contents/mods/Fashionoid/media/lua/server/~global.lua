-- local maxmax = createNewScriptItem("Base", "MaxMax", "MaxMax", "Clothing", "Weaponicon")
-- print("maxmax: "..tostring(maxmax))

local module = "Base"
local name = "MxDebug"
local displayname = "MxDebugName"
local type = "Clothing"
local inventoryIcon = 'WatermelonSmashed'
local item = createNewScriptItem(module, name, displayname, type, inventoryIcon);

item:DoParam("DisplayCategory = Clothing")
item:DoParam("Type = Clothing")
item:DoParam("DisplayName = Bikini")
item:DoParam("ClothingItem = Bikini_TINT")
item:DoParam("BodyLocation = Underwear")
item:DoParam("Icon = Bikini_White")
item:DoParam("Weight = 0.2")
item:DoParam("WorldStaticModel = Bikini_Ground")

print(tostring(item))
print(tostring(item:isHidden()))
print(tostring(item:getObsolete()))

Events.OnGameStart.Add(function ()
    getPlayer():getInventory():AddItem("Base.MxDebug");
end);