package = "kong-plugin-obfuscated-log-file"

version = "1.0.0-1"

-- The version '1.0.0' is the source code version, the trailing '1' is the version of this rockspec.
-- whenever the source version changes, the rockspec should be reset to 1. The rockspec version is only
-- updated (incremented) when this file changes, but the source remains the same.

local pluginName = package:match("^kong%-plugin%-(.+)$")  -- "obfuscated-log-file"
supported_platforms = {"linux", "macosx"}

source = {
  url = "https://github.com/mtormento/kong-plugin-obfuscated-log.git",
  tag = "1.0.0"
}

description = {
  summary = "A Kong plugin that logs obfuscated request and response json bodies to file.",
  license = "MIT"
}

dependencies = {
  "lua >= 5",
	"lua-cjson >= 2.1"
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.obfuscated-log-file.base"] = "../../common/base_obfuscated_log.lua",
    ["kong.plugins.obfuscated-log-file.serializer"] = "../../common/serializer.lua",
    ["kong.plugins.obfuscated-log-file.obfuscator"] = "../../common/obfuscator.lua",
    ["kong.plugins.obfuscated-log-file.handler"] = "src/handler.lua",
    ["kong.plugins.obfuscated-log-file.schema"] = "src/schema.lua"
  }
}
