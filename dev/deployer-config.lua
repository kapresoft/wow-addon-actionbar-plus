local env = require('user-env')

--- @type DeploymentConfig
local c = {
  version = "1.0.0",
  name = "ActionbarPlus",
  addons = {
    ["ActionbarPlus"]           = {
      deploy=false,
      as="ActionbarPlus"
    },
    ["ActionbarPlus-Core"]      = {
      deploy=false
    },
    ["ActionbarPlus-BarsUI"]    = {
      deploy=false
    },
    ["ActionbarPlus-OptionsUI"] = {
      deploy=true
    },
  },
  deployments = {
    ["classic-era"] = {
      deploy = true,
      dir=env.wow.classic_era.addOnDir
    },
    ["classic"] = {
      deploy = true,
      dir=env.wow.classic.addOnDir
    },
    ["classic-anniversary"] = {
      deploy = true,
      dir=env.wow.classic_anniversary.addOnDir,
    },
    ["retail"] = {
      deploy = true,
      dir=env.wow.retail.addOnDir,
    },
  }
}
return c
