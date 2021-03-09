local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")

-- // TODO: Need a  Copy from response_transformer, which has a complex config type

local colon_string_record = {
  type = "record",
  fields = {
    { json = colon_string_array },
    { json_types = {
      type = "array",
      default = {},
      required = true,
      elements = {
        type = "string",
        one_of = { "boolean", "number", "string" }
      }
    } },
    { headers = colon_string_array },
  },
}

return {
  name = plugin_name,
  fields = { 
    {
      config = {
        type = "record",
        fields = {
          { flattened = { type = "boolean", required = false, default = false }},
          { separator = { type = "string", required = false, default = "|", len_max = 1 }},
          { destinations = { type = "array", required = true, default = {}, elements={
              type = "record",
              fields = {
                { uri = { type = "string", required = true, match = "^https?://"}},
                { method = { type = "string", required = true, one_of = {"GET", "POST", "PUT", "DELETE",}}},
                { headers = { type = "array", required = false, default = {}, elements= {type = "string",}}},
                { body = { type = "string", required = false, default = " "}},
              }
            }}, 
          },
        }
      }
    }
  }
}


