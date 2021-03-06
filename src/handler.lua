local BasePlugin = require "kong.plugins.base_plugin"

local ApiComposition = BasePlugin:extend()

function ApiComposition:new()
    ApiComposition.super.new(self, "kong-api-composition")
end

function ApiComposition:access(config)
    ApiComposition.super.access(self)
    for key,value in pairs(config) do
      print("found member " .. key);
    end

    return kong.response.exit(200, { message= "Yo", aggr= config.aggregateResp})
end


return ApiComposition
