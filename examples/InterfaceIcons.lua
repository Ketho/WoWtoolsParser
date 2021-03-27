-- https://github.com/ketho-wow/LargerMacroIconSelection/blob/master/Data/FileDataRetail.lua
local parser = require "wowtoolsparser"
local output = "out/InterfaceIcons.lua"

local function main(BUILD)
	local filedata = parser.ReadListfile()
	local sorted = {}
	for fdid, path in pairs(filedata) do
		local _, _, icon = path:find("interface/icons/(.+)%.blp$")
		if icon then
			table.insert(sorted, {fdid, icon})
		end
	end
	table.sort(sorted, function(a, b)
		return a[1] < b[1]
	end)

	local fs = '[%d]="%s",\n'
	print("writing "..output)
	local file = io.open(output, "w")
	file:write("local InterfaceIcons = {\n")
	for _, tbl in pairs(sorted) do
		file:write(fs:format(table.unpack(tbl)))
	end
	file:write("}\n")
	file:close()
	print("finished")
end

main()
