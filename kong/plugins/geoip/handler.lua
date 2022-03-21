local intervaltree = require("kong.plugins.geoip.intervaltree")
local utils = require("kong.tools.utils")
local lrucache = require("resty.lrucache")
local ipconv = require("kong.plugins.geoip.iptonumber")
local io_open = io.open
local io_lines = io.lines
local inflate_gzip = utils.inflate_gzip

local IPRestrictionHandler = {}

IPRestrictionHandler.PRIORITY = 2501
IPRestrictionHandler.VERSION = "1.0.0"

function load_trees(conf)
  local all_country_code_trees = {}
  local ip_db_file = conf.ip_db_file
	
  local f = io_open(ip_db_file, "rb")
  local ip_db_gz, err = f:read("*a")
  if not ip_db_gz then
    kong.log.err("Error reading IP DB: ", err)
	return false
  end
  f:close()
  local ip_db = inflate_gzip(ip_db_gz)
  
  local codes_of_interest = {}
  -- initialize the trees for the country codes we care about
  for i,country_code in ipairs(conf.deny_country_codes) do
	codes_of_interest[country_code] = true
  end
  for i,country_code in ipairs(conf.allow_country_codes) do
	codes_of_interest[country_code] = true
  end
  
  local loaded_ips = 0
  for start_ip, end_ip, block_country_code in ip_db:gmatch("(%d+) (%d+) ([%u][%u])") do
	  if codes_of_interest[block_country_code] then
        local node = intervaltree:node(tonumber(start_ip), tonumber(end_ip))
        loaded_ips = loaded_ips + 1
        all_country_code_trees[block_country_code] = intervaltree:insert(all_country_code_trees[block_country_code],node)
	  end
  end
  ngx.shared[conf.shm_name] = all_country_code_trees
end

function is_ip_in_country(ip, country_code_tree)
  local ip_as_number = ipconv:ip2dec(ip)
  return intervaltree:point_intersects(country_code_tree,ip_as_number)
end

function IPRestrictionHandler:access(conf)
  -- this is a bit of a hack: it'd be more optimal to load this on worker init rather than on access phase
  local all_country_code_trees = ngx.shared[conf.shm_name]
  if not all_country_code_trees then
	load_trees(conf, all_country_code_trees)
  end

  local binary_remote_addr = ngx.var.binary_remote_addr
  if not binary_remote_addr then
    return kong.response.error(403, "Cannot identify the client IP address, unix domain sockets are not supported.")
  end
  local status = conf.status or 403
  local message = conf.message or "Your IP address is not allowed"
  
  if conf.deny_country_codes and #conf.deny_country_codes > 0 then
    for i,country_code in ipairs(conf.deny_country_codes) do
      local blocked = is_ip_in_country(binary_remote_addr, ngx.shared[conf.shm_name][country_code])
      if blocked then
        return kong.response.error(status, message)
      end
    end
  end

  if conf.allow_country_codes and #conf.allow_country_codes > 0 then
    local allow_country_codes = false
    for i,country_code in ipairs(conf.allow_country_codes) do
      local allowed = is_ip_in_country(binary_remote_addr, ngx.shared[conf.shm_name][country_code])
      if allowed then
        break
      end
    end
    if not allowed then
      return kong.response.error(status, message)
    end
  end
end

return IPRestrictionHandler