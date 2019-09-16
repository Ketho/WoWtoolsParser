local function read(csv)
	local item = {}
	for l in csv:lines() do
		local ID = tonumber(l.ID)
		if ID then
			item[ID] = tonumber(l.InventoryType)
		end
	end
	return item
end

return read
