-- handler for ParseCSV
local function read(csv)
	for line in csv:lines() do
		print(line.ID, line.ItemID, line.SourceTypeEnum, line.SourceText_lang)
	end
end

return read
