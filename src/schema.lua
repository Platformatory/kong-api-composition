return {
  fields = {
    { destinations = {type = "array", required = true}},
    { options = { type = "array", required = true }},
    { aggregate.resp = { type = "boolean", required = true, default = false }},
  }
--  self_check = function(schema, plugin_t, dao, is_updating)
--    if #params == #plugin_t.destinations then
--      return true
--    else
--      return false, Errors.schema("something went wrong")
--    end
--  end
}
