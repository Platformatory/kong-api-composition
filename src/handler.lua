local BasePlugin = require "kong.plugins.base_plugin"
local inspect = require 'inspect'
local json = require "cjson"
local http = require "resty.http"

local ApiComposition = BasePlugin:extend()

function ApiComposition:new()
    ApiComposition.super.new(self, "kong-api-composition")
end

function ApiComposition:access(config)
    ApiComposition.super.access(self) 

--  destinations from the plugin conf json string
    local reqs = json.decode(config.destinations)
  
--  Collect all responses into this table by default
    local responses = {}
    if config.flattened then
      responses.body = ""
    end

-- Loop through the req targets and run HTTP requests
   
    local client = http:new()
    for k, v in pairs(reqs) do
      -- TODO: headers need to be a table
      -- local settings = {method = v.method, headers = v.headers, body = v.body}
      local settings = {method = v.method, body = v.body}
      print(inspect(v.headers))      
      local res, err = client:request_uri(v.uri, settings)

      if config.flattened then
        if not res then
          responses.body = responses.body .. "error:" .. err
        else
          responses.body = responses.body .. res.body
        end
      else
        local result = { uri = v.uri}
        if not res then
          result.err = err
          responses[k] = result
        else
          result.status = res.status
          result.headers = res.headers
          result.body = res.body
          responses[k] = result
        end
      end     -- if flattened 
    end       -- for loop
  

   -- JSON encode and send the response
   return kong.response.exit(200, responses)
end


return ApiComposition
