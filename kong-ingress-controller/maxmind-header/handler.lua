local MaxMindDB = require "resty.maxminddb"
local cjson = require "cjson"


local GeoIP2Handler = {
  PRIORITY = 1000, -- Set the plugin priority
  VERSION = "1.0.0",
}

function GeoIP2Handler:access(conf)
  -- Initialize the GeoIP2 database
  local ok, err = MaxMindDB.init(conf.db_path)
  if not ok then
    kong.log.err("Failed to initialize GeoIP2 database: ", err)
    return
  end

  -- Get the client IP address
  local client_ip = kong.client.get_forwarded_ip() or kong.client.get_ip()
  kong.log.err("client ip is this: ", client_ip)

  -- Look up GeoIP2 data for the client IP
  local res, err = MaxMindDB.lookup(client_ip)
  if not res then
    kong.log.err("Failed to lookup GeoIP2 data: ", err)
    return
  end
  kong.log.err("Response is: ", cjson.encode(res))


  -- Add headers based on the GeoIP2 data
  if res.continent and res.continent.code then
    kong.service.request.set_header("X-Visitor-Continent", res.continent.code)
  end

  if res.country and res.country.iso_code then
    kong.service.request.set_header("X-Visitor-Country-Code", res.country.iso_code)
  end

  if res.country and res.country.names and res.country.names.en then
    kong.service.request.set_header("X-Visitor-Country-Name", res.country.names.en)
  end

  if res.registered_country and res.registered_country.iso_code then
    kong.service.request.set_header("X-Visitor-Registered-Country-Code", res.registered_country.iso_code)
  end

  if res.registered_country and res.registered_country.names and res.registered_country.names.en then
    kong.service.request.set_header("X-Visitor-Registered-Country-Name", res.registered_country.names.en)
  end

  if res.subdivisions and res.subdivisions[1] and res.subdivisions[1].iso_code then
    kong.service.request.set_header("X-Visitor-Subdivision-Code", res.subdivisions[1].iso_code)
  end

  if res.subdivisions and res.subdivisions[1] and res.subdivisions[1].names and res.subdivisions[1].names.en then
    kong.service.request.set_header("X-Visitor-Subdivision-Name", res.subdivisions[1].names.en)
  end

  if res.city and res.city.names and res.city.names.en then
    kong.service.request.set_header("X-Visitor-City-Name", res.city.names.en)
    
  end

  if res.postal and res.postal.code then
    kong.service.request.set_header("X-Visitor-Postal-Code", res.postal.code)
  end

  if res.location and res.location.latitude then
    kong.service.request.set_header("X-Visitor-Latitude", res.location.latitude)
  end

  if res.location and res.location.longitude then
    kong.service.request.set_header("X-Visitor-Longitude", res.location.longitude)
  end
end

return GeoIP2Handler
