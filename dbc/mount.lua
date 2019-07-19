-- handler for ParseJSON
local function read(tbl)
	for idx, line in pairs(tbl) do
		local id, name, desc = line[4], line[1], line[3]
		print(idx, id, name, desc)
	end
end

return read
