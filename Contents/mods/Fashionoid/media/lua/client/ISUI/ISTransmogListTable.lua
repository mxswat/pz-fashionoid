require "ISUI/AdminPanel/ISItemsListTable"

ISTransmogListTable = ISItemsListTable:derive("ISTransmogListTable");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2


function ISTransmogListTable:render()
    ISPanel.render(self);
    
    local y = self.datas.y + self.datas.height + 5
    self:drawText(getText("IGUI_DbViewer_TotalResult") .. self.totalResult, 0, y, 1,1,1,1,UIFont.Small)
    self:drawText(getText("IGUI_TransmogList_Info"), 0, y + FONT_HGT_SMALL, 1,1,1,1,UIFont.Small)

    y = self.filters:getBottom()
    
    self:drawRectBorder(self.datas.x, y, self.datas:getWidth(), HEADER_HGT, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawRect(self.datas.x, y+1, self.datas:getWidth(), HEADER_HGT, self.listHeaderColor.a, self.listHeaderColor.r, self.listHeaderColor.g, self.listHeaderColor.b);

    local x = 0;
    for i,v in ipairs(self.datas.columns) do
        local size;
        if i == #self.datas.columns then
            size = self.datas.width - x
        else
            size = self.datas.columns[i+1].size - self.datas.columns[i].size
        end
--        print(v.name, x, v.size)
        self:drawText(v.name, x+10+3, y+2, 1,1,1,1,UIFont.Small);
        self:drawRectBorder(self.datas.x + x, y, 1, self.datas.itemheight + 1, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b);
        x = x + size;
    end
end

function ISTransmogListTable:createChildren()
    ISItemsListTable.createChildren(self);
    self.datas:setOnMouseDoubleClick(self, ISTransmogListTable.transmogItem);
    self:removeChild(self.buttonAdd1);
    self:removeChild(self.buttonAdd2);
    self:removeChild(self.buttonAdd5);
    self:removeChild(self.buttonAddMultiple);
    self:removeChild(self.filters);
end

function ISTransmogListTable:transmogItem(item)
    local playerObj = getPlayer()
    if not playerObj or playerObj:isDead() then return end
    -- playerObj:getInventory():AddItem(item:getFullName())
    TransmogCore.applyTransmogToItem(item)
end

function ISTransmogListTable:update()

end
