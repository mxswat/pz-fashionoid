require "ISUI/ISToolTipInv"
local item = nil
local numRows = 0

local transmogText = nil

local old_render = ISToolTipInv.render

function ISToolTipInv:render()
    numRows = 0
    if self.item ~= nil then
        item = self.item
        getPlayer()
        local transmogItem = TransmogCore.getItemTransmog(item)
        if item and instanceof(item, "Clothing") and transmogItem ~= nil then
            numRows = 1
			transmogText = "Transmog to "..transmogItem:getDisplayName()
		else
			return old_render(self)
		end
    end
    local stage = 1
    local old_y = 0
    local fontSize = 0
    local tooltipFontSize = 0
    local lineSpacing = self.tooltip:getLineSpacing() + 0.5
    local old_setHeight = self.setHeight
    self.setHeight = function(self, num, ...)
        if stage == 1 then
            stage = 2
            fontSize = getCore():getOptionFontSize() -- font size
            old_y = num
            num = num + numRows * lineSpacing
        else 
            stage = -1 --error
        end
        return old_setHeight(self, num, ...)
    end
    local old_drawRectBorder = self.drawRectBorder
    self.drawRectBorder = function(self, ...)
        if numRows > 0 then
            local color = {0.68, 0.64, 0.96}
            local font = UIFont[getCore():getOptionTooltipFont()];
            self.tooltip:DrawText(font, transmogText, 5, old_y, color[1], color[2], color[3], 1);
            stage = 3
        else
            stage = -1 --error
        end
        return old_drawRectBorder(self, ...)
    end
    old_render(self)
    self.setHeight = old_setHeight
    self.drawRectBorder = old_drawRectBorder
end
