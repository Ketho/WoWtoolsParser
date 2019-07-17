local function read(tbl)
	for k, v in pairs(tbl) do
		local id, name, desc = v[4], v[1], v[3]
		print(k, id, name, desc)
	end
end

return read
