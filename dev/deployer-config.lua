local env = require('user-env')

--- @type DeploymentConfig
local c = {
  version = "1.0.0",
  name = "ActionbarPlus",
  addons = {
    ["ActionbarPlus"]           = {
      deploy=true,
      as="ActionbarPlus"
    },
    ["ActionbarPlus-Core"]      = {
      deploy=true
    },
    ["ActionbarPlus-BarsUI"]    = {
      deploy=true
    },
    ["ActionbarPlus-OptionsUI"] = {
      deploy=false
    },
  },
  deployments = {
    ["test"] = {
      deploy = false,
      dir=path("%s/Desktop/deployer/wow/", env.home)
    },
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
      deploy = false,
      dir=env.wow.retail.addOnDir,
    }
  }
}
return c
