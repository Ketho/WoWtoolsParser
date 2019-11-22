local parser = require "wowtoolsparser"
local output = "out/AtlasInfo.lua"

local function SortTable(tbl, key)
	table.sort(tbl, function(a, b)
		return a[key] < b[key]
	end)
end

local function AtlasInfo(BUILD)
	local filedata = parser.ReadListfile(true)
	local uitextureatlas = parser.ReadCSV("uitextureatlas", {build=BUILD, header=true})
	local atlasTable, atlasOrder, atlasSize = {}, {}, {}
	for line in uitextureatlas:lines() do
		local atlasID = tonumber(line.ID)
		local fdid = tonumber(line.FileDataID)
		if atlasID then -- last csv line is empty
			atlasTable[atlasID] = {}
			table.insert(atlasOrder, {
				atlasID = atlasID,
				fdid = fdid,
				fileName = filedata[fdid] or tostring(fdid), -- listfile might not yet be updated
			})
			atlasSize[atlasID] = {
				width = tonumber(line.AtlasWidth),
				height = tonumber(line.AtlasHeight),
			}
		end
	end
	SortTable(atlasOrder, "fileName")

	local uitextureatlasmember = parser.ReadCSV("uitextureatlasmember", {build=BUILD, header=true})
	for line in uitextureatlasmember:lines() do
		local name = line.CommittedName
		if name and name ~= "" then -- 1130222 interface/store/shop has empty atlas members
			local atlasID = tonumber(line.UiTextureAtlasID)
			local size = atlasSize[atlasID]
			local left = tonumber(line.CommittedLeft)
			local right = tonumber(line.CommittedRight)
			local top = tonumber(line.CommittedTop)
			local bottom = tonumber(line.CommittedBottom)
			table.insert(atlasTable[atlasID], {
				memberID = tonumber(line.ID),
				name = name,
				width = right - left,
				height = bottom - top,
				left = left / size.width,
				right = right / size.width,
				top = top / size.height,
				bottom = bottom / size.height,
				tileshoriz = line.CommittedFlags&0x4 > 0, -- requires lua 5.3
				tilesvert = line.CommittedFlags&0x2 > 0,
			})
		end
	end

	local fsAtlas = '\t["%s"] = { -- %d\n'
	local fsMember = '\t\t["%s"] = {%d, %d, %s, %s, %s, %s, %s, %s},\n'

	print("writing to "..output)
	local file = io.open(output, "w")
	file:write("-- atlas = width, height, leftTexCoord, rightTexCoord, topTexCoord, bottomTexCoord, tilesHorizontally, tilesVertically\n")
	file:write("local AtlasInfo = {\n")
	for _, atlas in pairs(atlasOrder) do
		file:write(fsAtlas:format(atlas.fileName:match("(.+)%.blp") or atlas.fileName, atlas.fdid))
		for _, member in pairs(atlasTable[atlas.atlasID]) do
			file:write(fsMember:format(member.name, member.width, member.height,
				member.left, member.right, member.top, member.bottom,
				member.tileshoriz, member.tilesvert))
		end
		file:write("\t},\n")
	end
	file:write("}\n\nreturn AtlasInfo\n")
	file:close()
	print("finished")
end

AtlasInfo()
--AtlasInfo("8.2.5")
--AtlasInfo("1.13.2")
