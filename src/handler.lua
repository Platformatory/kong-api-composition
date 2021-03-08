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

-- Loop through the req targets and run HTTP requests
-- TODO: Fix this.. This has some weird issues. Resty HTTP has some coroutiney code which probably yields outside the loop or breaks the loop in some way. It seems to be running only once. The loop in subsequent runs errors out by complaining "reqs" is a string and not a table
   
    for k, v in pairs(reqs) do
      print ("inside the loop")
      local client = http:new()
      print(inspect(client))      
      local res, err = pcall(client:request_uri(v.uri, {method = v.method, headers = v.headers, body = v.body}))
      print(inspect(res))  

      if err then
      end

      if not res then
      end

      if res.status == 200 then
      end

    end      
  
    print(inspect(reqs))

   if config.aggregateResp then
--  Merge all the headers & bodies 
   end


-- JSON encode and send the response
    return kong.response.exit(200, { message= "Yo", aggr= config.aggregateResp})
end


return ApiComposition
