local typedefs = require "kong.db.schema.typedefs"

return {
  name = "geoip",
  fields = {
    { protocols = typedefs.protocols },
    { config = {
        type = "record",
        fields = {
          { ip_db_file = { type = "string", default = "ip2country.db.gz" }, },
          { allow_country_codes = {
			type = "array",
			elements = { type = "string" },
			default = {},
		  }, },
		  { deny_country_codes = {
			type = "array",
			elements = { type = "string" },
			default = {},
		  }, },
		  { status = {
			type = "number",
			default = 403,
		  }, },
		  { message = {
			type = "string",
			default = "Your IP address is not allowed",
		  }, },
		  { shm_name = {
			type = "string",
			default = "geoipdb",
		  }, },
        },
      },
    },
  },
}
