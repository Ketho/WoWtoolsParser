-- handler for ParseCSV
local function read(csv)
	for line in csv:lines() do
		if line.ID then -- last line is empty
			print(line.ID, line.ItemID, line.SourceTypeEnum, line.SourceText_lang)
		end
	end
end

return read
