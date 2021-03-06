local BasePlugin = require "kong.plugins.base_plugin"

local ApiComposition = BasePlugin:extend()

function APIComposition:new()
    APIComposition.super.new(self, "kong-api-composition")
end

function APIComposition:access(config)
    APIComposition.super.access(self)
    for key,value in pairs(config) do
      print("found member " .. key);
    end

end


return APIComposition
