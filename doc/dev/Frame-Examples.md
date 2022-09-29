# Frame Examples


# Using Global Backdrops
> The following example creates an empty draggable frame.

#### Notes
- Make sure to call `self:ApplyBackdrop()`
#### See Also
- BlizzardInterfaceCode/Interface/SharedXML/Backdrop.lua
- https://wowpedia.fandom.com/wiki/XML/Backdrop
- https://wowpedia.fandom.com/wiki/BackdropTemplate

```xml
<Frame name="ABP_UIParent" parent="UIParent" frameStrata="HIGH"
       hidden="false" enableMouse="true" movable="true" alpha="0.5"
       inherits="BackdropTemplate">
    <KeyValues>
        <KeyValue key="backdropInfo" value="BACKDROP_DIALOG_32_32" type="global" />
    </KeyValues>
    <Scripts>
        <OnLoad>
            (function()
            self:RegisterForDrag("LeftButton")
            self:ApplyBackdrop()
            self:Show()
            --print('Loaded:', ABP_UIParent:GetName())
            end)()
        </OnLoad>
        <OnDragStart>(function()
            self:StartMoving();
            print(string.format("top: %s, right: %s, bottom: %s, left: %s", self:GetTop(), self:GetRight(), self:GetBottom(), self:GetLeft()))
            end)()
        </OnDragStart>
        <OnDragStop>self:StopMovingOrSizing();</OnDragStop>
    </Scripts>
    <Size x="300" y="200" />
    <Anchors>
        <Anchor point="CENTER" relativePoint="CENTER" relativeto="UIParent">
            <Offset>
                <AbsDimension x="0" y="0" />
            </Offset>
        </Anchor>
    </Anchors>
    <Layers>
        <!-- Adds color layer at background level -->
        <Layer level="BACKGROUND">
            <Texture setAllPoints="true">
                <Color r="0.2" g="0.2" b="0.8" a="0.4" />
            </Texture>
        </Layer>
    </Layers>
</Frame>
```