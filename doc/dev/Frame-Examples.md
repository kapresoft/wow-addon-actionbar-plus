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

# Anchored Frames (Inner frame)

The inner frame ABP_F1 can be accessed by the ABP_UIParent via `ABP_UIParent.inner` due to the parentKey "inner" attribute.

```xml
<Frame name="ABP_ParentFrameTemplate" parent="UIParent" frameStrata="LOW"
           hidden="false" enableMouse="true" movable="true" alpha="1.0" virtual="true"
           inherits="BackdropTemplate" mixin="BackdropTemplateMixin">
        <Size x="400" y="200" />
        <Anchors>
            <Anchor point="CENTER" relativePoint="CENTER" relativeto="UIParent">
                <Offset>
                    <AbsDimension x="0" y="0" />
                </Offset>
            </Anchor>
        </Anchors>
        <Layers>
            <Layer level="ARTWORK">
                <Texture setAllPoints="true">
                    <Color r="0.1" g="0.1" b="0.1" a="0.4" />
                </Texture>
            </Layer>
        </Layers>
    </Frame>

    <Frame name="ABP_UIParent" inherits="ABP_ParentFrameTemplate" parent="UIParent" frameStrata="LOW"
           hidden="false" enableMouse="true" movable="true" alpha="1.0">
        <Size x="275" y="175" />
        <Scripts>
            <OnLoad>
                (function()
                self:RegisterForDrag("LeftButton")
                local backdrop = {
                    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
                    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                    tile = true, tileSize = 16, edgeSize = 16,
                    insets = { left = 3, right = 3, top = 5, bottom = 3 },
                }
                self:SetBackdrop(backdrop)
                self:ApplyBackdrop()
                --
                --
                --self:SetBackdrop(ABP_BACKDROP_CHARACTER_CREATE_TOOLTIP_32_32)
                --self:SetClampedToScreen(true)
                self:SetPoint("CENTER")
                self:SetBackdropColor(0, 0, 0, 0.4)
                self:SetFrameLevel(100)
                self:SetToplevel(true)
                self:SetFrameStrata("DIALOG")
                self:SetFrameLevel(100)

                end)()
            </OnLoad>
            <OnDragStart>(function()
                self:StartMoving();
                end)()
            </OnDragStart>
            <OnDragStop>
                self:StopMovingOrSizing();
                print('anchor:', self:GetPoint());
            </OnDragStop>
        </Scripts>
    </Frame>

    <Frame name="ABP_F1" parent="ABP_UIParent" parentKey="inner"
           frameStrata="HIGH"
           hidden="false" enableMouse="true" movable="false" alpha="0.5"
           inherits="BackdropTemplate">
        <Size x="300" y="200" />
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
        </Scripts>
        <Anchors>
            <Anchor point="CENTER" relativePoint="CENTER" relativeto="ABP_UIParent">
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
