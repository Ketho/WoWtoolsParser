-- https://github.com/ketho-wow/UnexploredAreas/blob/master/UnexploredAreas.lua
local parser = require "wowtoolsparser"
local output = "out/AreaTable.lua"

local AreaIDs = {}

local function SortByKey(tbl)
	local t = {}
	for k, v in pairs(tbl) do
		table.insert(t, {k, v})
	end
	table.sort(t, function(a, b)
		return a[1] < b[1]
	end)
	return t
end

local function SortKeys(tbl)
	local t = {}
	for k, v in pairs(tbl) do
		table.insert(t, k)
	end
	table.sort(t)
	return t
end

local function main(BUILD)
	print("writing "..output)
	local file = io.open(output, "w")

	local areatable_csv = parser:ReadCSV("areatable", {build=BUILD, header=true})
	-- general lookup table for areaids
	local areatable_tbl = {}
	for line in areatable_csv:lines() do
		local ID = tonumber(line.ID)
		if ID then
			local ParentAreaID = tonumber(line.ParentAreaID)
			areatable_tbl[ID] = {ParentAreaID, line.AreaName_lang}
		end
	end

	-- areaids grouped by parent
	local areatable_parents = {}
	for ID, tbl in pairs(areatable_tbl) do
		local parent = tbl[1]
		local name = tbl[2]
		if parent > 0 then -- ignore the parent themselves
			areatable_parents[parent] = areatable_parents[parent] or {}
			areatable_parents[parent][ID] = true
		end
	end

	file:write("local AreaTable = {\n")
	-- oof this is confusing
	for _, v in pairs(SortByKey(areatable_parents)) do
		local parentID = v[1]
		local parentName = areatable_tbl[parentID][2]
		file:write(string.format('\t[%d] = { -- %s\n', parentID, parentName))
		for _, ID in pairs(SortKeys(v[2])) do
			local AreaName_lang = areatable_tbl[ID][2]
			file:write(string.format('\t\t[%d] = "%s",\n', ID, AreaName_lang))
		end
		file:write("\t},\n")
	end
	file:write("}\n\n")

	local uimapassignment_csv = parser:ReadCSV("uimapassignment", {build=BUILD, header=true})
	local uimapassignment_tbl = {}
	for line in uimapassignment_csv:lines() do
		local AreaID = tonumber(line.AreaID)
		if AreaID and AreaID > 0 then
			-- an AreaID can have multiple of UiMapID
			local UiMapID = tonumber(line.UiMapID)
			uimapassignment_tbl[UiMapID] = AreaID
		end
	end

	file:write("local UiMapAssignment = {\n")
	for _, v in pairs(SortByKey(uimapassignment_tbl)) do
		local UiMapID = v[1]
		local AreaID = v[2]
		file:write(string.format('\t[%d] = %d,\n', UiMapID, AreaID))
	end
	file:write("}\n")

	file:close()
	print("finished")
end

main()
