
local typedefs = require "kong.db.schema.typedefs"


return {
  name = "db-sql",
  fields = {
    { consumer = typedefs.no_consumer },
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { sourcename = { type = "string", required = true, default = "clients" }, },
          { username = { type = "string", required = true, default = "root" }, },
          { password = { type = "string", required = true, default = "mypassword" }, },
          { host = { type = "string", required = true, default = "mysql" }, },
          { port = { type = "number", required = true, default = 3306 }, },
        },
    }, },
  },
}