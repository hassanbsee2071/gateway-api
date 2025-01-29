local typedefs = require "kong.db.schema.typedefs"

return {
  name = "maxmind-header", -- Name of the plugin
  fields = {
    { consumer = typedefs.no_consumer }, 
    { protocols = typedefs.protocols_http }, -- This plugin works with HTTP/HTTPS protocols
    { config = {
        type = "record",
        fields = {
          { db_path = { type = "string", required = true, default = "/opt/kong/maxmind-database/GeoLite2-Country.mmdb" } },
        },
      },
    },
  },
}