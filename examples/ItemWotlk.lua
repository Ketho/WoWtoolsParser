local parser = require "wowtoolsparser"
local output = "out/ItemWotlk.lua"

local function ItemWotlk(BUILD)
	print("reading itemdisplayinfo")
	local itemdisplayinfo = {}
	local dbc_itemdisplayinfo = parser:ReadCSV("itemdisplayinfo", {build=BUILD, header=true})
	for line in dbc_itemdisplayinfo:lines() do
		local ID = tonumber(line.ID)
		if ID then
			itemdisplayinfo[ID] = line["InventoryIcon[0]"]
		end
	end
	local fs = '\t[%d] = {%d, "%s"},\n'

	print("reading itemsparse")
	local itemsparse = {}
	local dbc_itemsparse = parser:ReadCSV("itemsparse", {header=true})
	for line in dbc_itemsparse:lines() do
		local ID = tonumber(line.ID)
		if ID then
			itemsparse[ID] = line["Display_lang"]:gsub('"', '\\"')
		end
	end

	local fs_noname = '\t[%d] = {%d, "%s"},\n'
	local fs_name = '\t[%d] = {%d, "%s", "%s"},\n'
	print("writing "..output)
	local file = io.open(output, "w")
	file:write("local ItemWotlk = {\n")
	file:write("\t-- ID = InventoryType, Icon, Name\n")
	local dbc_item = parser:ReadCSV("item", {build=BUILD, header=true})
	for line in dbc_item:lines() do
		local ID = tonumber(line.ID)
		if ID then
			local InventoryType = tonumber(line.InventoryType)
			if InventoryType > 0 then
				local DisplayInfoID = tonumber(line.DisplayInfoID)
				if itemsparse[ID] then
					file:write(fs_name:format(
						ID,
						InventoryType,
						itemdisplayinfo[DisplayInfoID],
						itemsparse[ID]
					))
				else
					file:write(fs_noname:format(
						ID,
						InventoryType,
						itemdisplayinfo[DisplayInfoID]
					))
				end
			end
		end
	end
	file:write("}\n")
	file:close()
	print("finished")
end

ItemWotlk("3.3.5")
