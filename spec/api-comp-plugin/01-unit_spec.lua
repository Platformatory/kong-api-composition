local PLUGIN_NAME = "kong-api-composition"


-- helper function to validate data against a schema
local validate do
  local validate_entity = require("spec.helpers").validate_plugin_config_schema
  local plugin_schema = require("kong.plugins."..PLUGIN_NAME..".schema")

  function validate(data)
    return validate_entity(data, plugin_schema)
  end
end


describe(PLUGIN_NAME .. ": (schema)", function()

  it("accepts flattened=True", function()
    local ok, err = validate({
        flattened = True,
      })
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

  it("accepts destinations with differnt HTTP methods", function()
    local ok, err = validate({
        destinations = {
            {uri = "http://xyz", method="GET"},
            {uri = "http://xyz", method="POST"}
        }
      })
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

  it("does not accept destinations with missing uri", function()
    local ok, err = validate({
        destinations = {
            {method="GET"},
            {uritypo = "http://xyz", method="POST"}
        }
      })

    assert.is_same({
        destinations = {
          [1] = {uri="required field missing"},
          [2] = {uri="required field missing", uritypo="unknown field"}
        }
    }, err.config)
    assert.is_falsy(ok)
  end)

  it("does not accept destinations with missing method", function()
    local ok, err = validate({
        destinations = {
            {uri = "http://xyz"},
            {uri = "http://xyz", methodtypo="POST"}
        }
      })

    assert.is_same({
        destinations = {
          [1] = {method="required field missing"},
          [2] = {method="required field missing", methodtypo="unknown field"}
        }
    }, err.config)
    assert.is_falsy(ok)
  end)

end)
