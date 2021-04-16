-- https://github.com/ketho-wow/ClickMorph/blob/master/Data/Live/ItemVisuals.lua
local parser = require "wowtoolsparser"
local output = "out/ItemVisuals.lua"

local function GetFirstID(t)
	for _, v in pairs(t) do
		if v ~= 0 then
			return v
		end
	end
end

local function ItemVisuals(BUILD)
	local fd = parser.ReadListfile()
	local iter = parser.ReadCSV("itemvisuals", {build=BUILD, header=true})
	--local fsRaw = '\t[%d] = {%s},\n'
	local fsName = '\t[%d] = "%s",\n'
	local modelFileID = {}

	print("writing "..output)
	local file = io.open(output, "w")
	file:write("local ItemVisuals = {\n")
	for l in iter:lines() do
		local ID = tonumber(l.ID)
		if ID then
			modelFileID[ID] = {}
			for i = 0, 4 do
				table.insert(modelFileID[ID], tonumber(l["ModelFileID["..i.."]"]))
			end
			local firstID = GetFirstID(modelFileID[ID])
			if firstID and fd[firstID] then -- ID 352 does not have a fd entry
				--file:write(fsRaw:format(ID, table.concat(modelFileID[ID], ", ")))
				local name = fd[firstID]:match(".+/(.+)%.m2")
				file:write(fsName:format(ID, name))
			end
		end
	end
	file:write("}\n\nreturn ItemVisuals\n")
	file:close()
	print("finished")
end

ItemVisuals()
