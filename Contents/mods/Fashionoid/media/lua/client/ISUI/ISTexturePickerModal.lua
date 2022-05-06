ISTexturePickerModal = ISColorPickerModal:derive("ISTexturePickerModal");

function ISTexturePickerModal:initialise()
    ISColorPickerModal.initialise(self);

    self.textureSelect = ISComboBox:new(self.colorBtn:getX(), self.colorBtn:getY(), self.colorBtn:getWidth(), self.colorBtn:getHeight(), self, self.onSelectTexture)
    self.textureSelect:initialise()

    local textureChoices = TransmogCore.getItemToTransmog():getClothingItem():getTextureChoices()
    for i=0, textureChoices:size() - 1 do
        local text = getText("UI_ClothingTextureType", i + 1)
        self.textureSelect:addOption(text)
    end

    self.textureSelect:initialise();

    self:addChild(self.textureSelect);
    self.colorBtn:setVisible(false);
end


function ISTexturePickerModal:onSelectTexture()
    print(self.textureSelect.selected -1 )
    self.OnSelectionCallback(self.textureSelect.selected - 1)
end
-- ISComboBox