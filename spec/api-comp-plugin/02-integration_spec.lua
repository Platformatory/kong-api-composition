local helpers = require "spec.helpers"
local cjson = require "cjson"


local PLUGIN_NAME = "kong-api-composition"


for _, strategy in helpers.each_strategy() do
  describe(PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
    local client

    lazy_setup(function()

      local bp = helpers.get_db_utils(strategy, nil, { PLUGIN_NAME })

      -- Inject a test route. No need to create a service, there is a default
      -- service which will echo the request.
      local route1 = bp.routes:insert({
        hosts = { "test1.com" },
      })
      -- add the plugin to test to the route we created
      bp.plugins:insert {
        name = PLUGIN_NAME,
        route = { id = route1.id },
        config = { destinations = {
          {uri = "https://httpbin.org/headers", method="GET"}
        }},
      }

      -- start kong
      assert(helpers.start_kong({
        -- set the strategy
        database   = strategy,
        -- use the custom test template to create a local mock server
        nginx_conf = "spec/fixtures/custom_nginx.template",
        -- make sure our plugin gets loaded
        plugins = "bundled," .. PLUGIN_NAME,
      }))
    end)

    lazy_teardown(function()
      helpers.stop_kong(nil, true)
    end)

    before_each(function()
      client = helpers.proxy_client()
    end)

    after_each(function()
      if client then client:close() end
    end)


    describe("response", function()
      it("gets a non empty response", function()
        local r = client:get("/request", {
          headers = {
            host = "test1.com"
          }
        })
        -- validate that the request succeeded, response status 200
        assert.response(r).has.status(200)
        local respBodyStr = r:read_body()
        local respBody = cjson.decode(respBodyStr)
        -- validate the body
        assert.equal(#respBody, 1)
        assert.is_not_nil(respBody[1].headers)
        assert.is_not_nil(respBody[1].body)
        assert.equal(respBody[1].uri, "https://httpbin.org/headers")
        assert.equal(respBody[1].status, 200)
      end)
    end)

  end)
end
