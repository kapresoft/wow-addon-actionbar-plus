-- Interface Definitions
-- This file is not needed to run the addon.
-- Copy and paste this anywhere in your IDE for Emmy Lua to detect

--- @class DebugChatFrameOptionsInterface
--- @field addon string The addon name
--- @field chatFrameTabName string The name of the chat frame tab
--- @field font Font The blizzard font instance name
--- @field fontSize number
--- @field windowAlpha number
--- @field maxLines number

--- @class ChatLogFrameInterface
--- @field options DebugChatFrameOptionsInterface
--- @field prefix fun(self:ChatLogFrameInterface, module: string): string
--- @field log fun(self:ChatLogFrameInterface, ...: any)
--- @field logp fun(self:ChatLogFrameInterface, module: string, ...: any)
--- @field IsSelected fun(self:ChatLogFrameInterface): boolean
--- @field StartFlash fun(self:ChatLogFrameInterface, ...) : void
--- @field GetTabName fun(self:ChatLogFrameInterface): string
--- @field SelectInDock fun(self:ChatLogFrameInterface): void

--- @class DebugChatFrameInterface
--- @field New fun(self:DebugChatFrameInterface, ...:any) : ChatLogFrameInterface
