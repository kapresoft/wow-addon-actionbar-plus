---@param LIB table LibStub
---@param VF table VERSION_FORMAT
local __def = function(LIB, versionFormat, unpack)

    local format, tonumber = string.format, tonumber
    local C = {}

    local libAceConsole = nil

    function C:GetAceLibVersion(libName)
        local major, minor = format(versionFormat, libName), tonumber(("$Revision: 1 $"):match("%d+"))
        return { major, minor }
    end

    function C:NewPlainAceLib(libName)
        local version = self:GetAceLibVersion(libName)
        local newLib = LIB:NewLibrary(unpack(version))
        newLib.__name = libName
        return newLib
    end

    function C:GetAceConsole()
        libAceConsole = self:LazyGetAceLib(libAceConsole, AceModule.AceConsole)
        return libAceConsole
    end

    function C:LazyGetAceLib(libObj, libName)
        if not libObj then return LIB(libName) end
        return libObj
    end

    return C
end

ABP_AceUtil = __def(LibStub, VERSION_FORMAT, ABP_Table.unpackIt)
