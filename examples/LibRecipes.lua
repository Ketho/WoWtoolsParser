--[[
https://www.wowace.com/projects/librecipes-2-0
https://gist.github.com/Ketho/4776d54e49bd438b006642c0c4c049c9

example:
	-- Alchemy
	lib:AddRecipe(2553, 3230, 2457) -- Elixir of Minor Agility
	https://www.wowhead.com/item=2553/recipe-elixir-of-minor-agility
	https://www.wowhead.com/spell=3230/elixir-of-minor-agility
	https://www.wowhead.com/item=2457/elixir-of-minor-agility

DBCs:
	-- item.db2
	-- 1:ID, 2:ClassID, 3:SubclassID
	2553,9,6,0,0,0,-1,134942,20,0

	-- itemeffect.db2
	-- 8:SpellID, 10:ParentItemID
	105682,1,6,0,-1,-1,0,3230,0,2553

	-- spelleffect.db2
	-- 12:EffectItemType, 35:SpellID
	991,0,0,0,24,0,0,0,0,1,0,2457,0,0,0,0,0,0,1,0,0.25,0,1,1,0,0,0,0,0,0,0,0,1,0,3230

	-- spellname.db2
	-- 1:ID, 2:Name_lang
	3230,Elixir of Minor Agility

	-- itemsparse.db2
	-- 1:ID, 7:Display_lang
	2457,-1,,,,,Elixir of Minor Agility,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,20,0,0,15,60,1,1,0.9945,0,8192,0,16384,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,12,-1,0,0,0,0,0,0,0,0,3,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,2,0,1
]]

local parser = require "wowtoolsparser"
local output = "out/LibRecipes.lua"

local LE_ITEM_CLASS_RECIPE = 9
local tradeskills = {
	[0] = "Uncategorized",
	[1] = "Leatherworking",
	[2] = "Tailoring",
	[3] = "Engineering",
	[4] = "Blacksmithing",
	[5] = "Cooking",
	[6] = "Alchemy",
	[7] = "First Aid",
	[8] = "Enchanting",
	-- [9] = "Fishing", -- only has removed recipes
	[10] = "Jewelcrafting",
	[11] = "Inscription",
	-- there is no Mining category
}
local LibRecipesOrder = {6, 4, 5, 8, 3, 11, 10, 1, 7, 2, 0} -- alphabetically

local handlers = {
	item = function(dbc)
		local t = {}
		for l in dbc:lines() do
			local ID = tonumber(l.ID)
			local ClassID = tonumber(l.ClassID)
			local SubclassID = tonumber(l.SubclassID)
			if ID then -- last csv line is empty
				if ClassID == LE_ITEM_CLASS_RECIPE then
					t[ID] = SubclassID
				end
			end
		end
		return t
	end,
	itemeffect = function(dbc)
		local t = {}
		for l in dbc:lines() do
			local ID = tonumber(l.ID)
			local SpellID = tonumber(l.SpellID)
			local ParentItemID = tonumber(l.ParentItemID)
			if ID then
				t[ParentItemID] = SpellID
			end
		end
		return t
	end,
	spelleffect = function(dbc)
		local t = {}
		for l in dbc:lines() do
			local ID = tonumber(l.ID)
			local EffectItemType = tonumber(l.EffectItemType)
			local SpellID = tonumber(l.SpellID)
			if ID then
				t[SpellID] = EffectItemType
			end
		end
		return t
	end,
	spellname = function(dbc)
		local t = {}
		for l in dbc:lines() do
			local ID = tonumber(l.ID)
			if ID then
				t[ID] = l.Name_lang
			end
		end
		return t
	end,
	itemsparse = function(dbc)
		local t = {}
		for l in dbc:lines() do
			local ID = tonumber(l.ID)
			if ID then
				t[ID] = l.Display_lang
			end
		end
		return t
	end,
}

local function ParseDBC(name, BUILD)
	local dbc = parser.ReadCSV(name, {build=BUILD, header=true})
	return handlers[name](dbc)
end

local function LibRecipes(BUILD)
	local dbc_item = ParseDBC("item", BUILD)
	local dbc_itemeffect = ParseDBC("itemeffect", BUILD)
	local dbc_spelleffect = ParseDBC("spelleffect", BUILD)
	local dbc_spellname = ParseDBC("spellname", BUILD)
	local dbc_itemsparse = ParseDBC("itemsparse", BUILD)
	-- init tables
	local data = {}
	for i = 0, 11 do
		data[i] = {}
	end
	-- populate data
	for item_id, subclass_id in pairs(dbc_item) do
		local spell_id = dbc_itemeffect[item_id]
		local result_item = dbc_spelleffect[spell_id]
		-- for uncategorized recipes the item name is more descriptive
		local name = subclass_id>0 and dbc_spellname[spell_id] or dbc_itemsparse[item_id]
		if spell_id and name then -- sanity check for removed spells/items
			table.insert(data[subclass_id], {item_id, spell_id, result_item, name})
		end
	end
	-- sort tables
	for _, tbl in pairs(data) do
		table.sort(tbl, function(a, b)
			return a[1] < b[1]
		end)
	end
	-- write data
	print("writing to "..output)
	local file = io.open(output, "w")
	local fs = "lib:AddRecipe(%d, %s, %s) -- %s\n"
	for _, subclassID in pairs(LibRecipesOrder) do
		file:write("-- "..tradeskills[subclassID].."\n")
		for _, tbl in pairs(data[subclassID]) do
			file:write(fs:format(table.unpack(tbl)))
		end
	end
	file:close()
	print("finished")
end

LibRecipes("8.3.0")
-- LibRecipes("1.13.5")
-- LibRecipes() -- beta
