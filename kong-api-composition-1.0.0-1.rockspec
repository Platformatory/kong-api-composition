package = "kong-api-composition"

version = "1.0.0-1"

supported_platforms = {"linux"}

source = {
  url = "git@github.com:Platformatory/kong-api-composition.git",
  tag = "1.0.0"
}

description = {
  summary = "Demonstrate API composition with Kong",
  license = "MIT",
  maintainer = "Pavan Keshavamurthy <pavan@platformatory.com>"
}

dependencies = {
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.kong-api-composition.access"] = "src/access.lua",
    ["kong.plugins.kong-api-composition.handler"] = "src/handler.lua",
    ["kong.plugins.kong-api-composition.header_filter"] = "src/header_filter.lua",
    ["kong.plugins.kong-api-composition.schema"] = "src/schema.lua",
  }
}
