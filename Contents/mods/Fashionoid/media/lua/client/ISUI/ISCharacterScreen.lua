local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local btnHgt = FONT_HGT_SMALL

local old_ISCharacterScreen_create = ISCharacterScreen.create
function ISCharacterScreen:create()
	local result = old_ISCharacterScreen_create(self)

    self.resetTransmogButton = ISButton:new(16, 5, 100, btnHgt, "Reset All Transmogs (Requires Reboot)", self, TransmogCore.resetTransmogTable);
	self.resetTransmogButton:initialise();
	self.resetTransmogButton:instantiate();
	self.resetTransmogButton.background = false;
	self:addChild(self.resetTransmogButton);

	return result
end


local old_ISCharacterScreen_render = ISCharacterScreen.render
function ISCharacterScreen:render()
	local result = old_ISCharacterScreen_render(self)

	self.resetTransmogButton:setY(self.literatureButton:getY() + 24);
	self.resetTransmogButton:setX(self.literatureButton:getX());

	return result
end
