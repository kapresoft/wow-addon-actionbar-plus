local tostring, tinsert, tsort = tostring, table.insert, table.sort

-- DELETE ME
local P = {
    maxFrames = 8,
    baseFrameName = 'ActionbarPlusF'
}
-- TODO: Rename to ABProfileUtil
ProfileUtil = P

function P:GetMaxFrames() return self.maxFrames end
function P:GetBaseFrameName() return self.baseFrameName end

function P:GetFrameNameFromIndex(frameIndex)
    return self:GetBaseFrameName() .. tostring(frameIndex)
end

function P:GetAllFrameNames()
    local fnames = {}
    for i=1, self:GetMaxFrames() do
        local fn = self:GetFrameNameFromIndex(i)
        tinsert(fnames, fn)
    end
    tsort(fnames)
    return fnames
end