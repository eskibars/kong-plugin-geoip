-- IP address to number conversion utility

ipconv = {}

function ipconv:ip2dec(ip)
	local i, dec = 3, 0
	for d in string.gmatch(ip, "%d+") do
		dec = dec + 2 ^ (8 * i) * d
		i = i - 1
	end
	return dec
end

return ipconv