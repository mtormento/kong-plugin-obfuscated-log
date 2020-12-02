local typedefs = require "kong.db.schema.typedefs"

return {
  name = "obfuscated-log-file",
  fields = {
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { path = { type = "string",
                     required = true,
                     match = [[^[^*&%%\`]+$]],
                     err = "not a valid filename",
          }, },
          { reopen = { type = "boolean", default = false }, },
          { obfuscate_request_body = { type = "boolean", required = true, default = true }, },
          { obfuscate_response_body = { type = "boolean", required = true, default = true }, },
          { keys_to_obfuscate = { type = "set", elements = { type = "string"} } },
          { mask = { type = "string", required = true, default = "***" } },
          { original_body_on_error = { type = "boolean", required = true, default = false }, },
    }, }, },
  },
}
