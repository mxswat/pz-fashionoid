ISColorPickerModal = ISTextBox:derive("ISColorPickerModal");

function ISColorPickerModal:initialise()
    ISTextBox.initialise(self);

    local inset = 2
    local height = inset + self.fontHgt * self.numLines + inset
    self:removeChild(self.colorBtn);
    self.colorBtn = ISButton:new(self.entry.x + self.entry.width + 5, self.entry.y, height, height, "", self, ISColorPickerModal.onColorPicker);
    self.colorBtn:setX(self.entry:getX());
    self.colorBtn:setWidth(self.entry:getWidth());
    self.colorBtn:initialise();
    self.colorBtn.backgroundColor = {r = 1, g = 1, b = 1, a = 1};
    self:addChild(self.colorBtn);
    self.colorBtn:setVisible(true);
    self.entry:setVisible(false);

    self.yes:setTitle("Close")
    self:removeChild(self.no);
end

function ISColorPickerModal:setOnPickedColorCallback(functionCallback)
    self.onPickedColorCallback = functionCallback
end

function ISColorPickerModal:onColorPicker(button)
    self.colorPicker:setX(getMouseX() - 100);
    self.colorPicker:setY(getMouseY() - 20);
    self.colorPicker.pickedFunc = ISColorPickerModal.onPickedColor;
    self.colorPicker:setVisible(true);
    self.colorPicker:bringToTop();
end

function ISColorPickerModal:onPickedColor(color, mouseUp)
    self.currentColor = ColorInfo.new(color.r, color.g, color.b,1);
    self.colorBtn.backgroundColor = {r = color.r, g = color.g, b = color.b, a = 1};
    self.entry.javaObject:setTextColor(self.currentColor);
    self.colorPicker:setVisible(false);
    if self.onPickedColorCallback ~= nil then
        local color = Color.new(color.r, color.g, color.b,1);
        self.onPickedColorCallback(ImmutableColor.new(color))
    end
end
