local function read(csv)
	local names, itemIDs = {}, {}
	for l in csv:lines() do
		local setID = tonumber(l.ID)
		if setID then
			names[setID] = l.Name_lang
			itemIDs[setID] = {}
			for i = 0, 9 do
				local itemID = tonumber(l["ItemID["..i.."]"])
				if itemID > 0 then
					table.insert(itemIDs[setID], itemID)
				end
			end
		end
	end
	return names, itemIDs
end

return read
