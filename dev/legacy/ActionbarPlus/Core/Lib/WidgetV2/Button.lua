-- Create ConsumableButtonMixin?
-- mixin:Onload()
function ABP_Button_OnLoad(self)
    --print('ConsumableButton_OnLoad:: called...')
end

function ABP_Button_UpdateAction(self, name, value)
    --print('ConsumableButton_UpdateAction:: called...')
end

function ABP_Button_OnEvent(self, event, ...)
    --print('ConsumableButton_OnEvent:: called...')
end


---@param self _CheckButton
function ABP_Button_UpdateState(self, button, down)
    self:SetChecked(false)
end
