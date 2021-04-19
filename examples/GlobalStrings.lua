-- https://github.com/Ketho/BlizzardInterfaceResources/blob/live/Resources/GlobalStrings.lua
local parser = require "wowtoolsparser"
local output = "out/GlobalStrings.lua"

local short = '%s = "%s";'
local full = '_G["%s"] = "%s";'

local slashStrings = {
	KEY_BACKSLASH = true,
	--CHATLOGENABLED = true,
	--COMBATLOGENABLED = true,
}

local hacks = {
	-- https://wow.tools/dbc/?dbc=globalstrings#search=PARTY_PLAYER_CHROMIE_TIME_FMT
	PARTY_PLAYER_CHROMIE_TIME_FMT = [[%s\n\n\\%s]], -- uhh wtf; 9.0.1 (35256)
}

local function IsValidTableKey(s)
	return not s:find("-") and not s:find("^%d")
end

local function GlobalStrings(options)
	options = options or {}
	options.header = true
	-- filter and sort globalstrings
	local globalstrings, usedBuild = parser.ReadCSV("globalstrings", options)
	local stringsTable = {}
	for line in globalstrings:lines() do
		local flags = tonumber(line.Flags)
		-- strings with flags 0 and 2 are not available in-game
		if flags == 0x1 or flags == 0x3 then
			table.insert(stringsTable, {
				BaseTag = line.BaseTag,
				TagText = line.TagText_lang
			})
		end
	end
	table.sort(stringsTable, function(a, b)
		return a.BaseTag < b.BaseTag
	end)

	print("writing "..output)
	local file = io.open(output, "w")
	for _, tbl in pairs(stringsTable) do
		local key, value = tbl.BaseTag, tbl.TagText
		value = value:gsub('\\32', ' ') -- space char
		-- unescape any quotes before escaping quotes
		value = value:gsub('\\\"', '"')
		value = value:gsub('"', '\\\"')
		-- apparently this is only unescaped for retail and fixed on classic/bc
		if slashStrings[key] and string.sub(usedBuild, 1, 2) == "9." then
			value = value:gsub("\\", "\\\\")
		end
		if hacks[key] then
			value = hacks[key]
		end

		-- check if the key is proper short table syntax
		local fs = IsValidTableKey(key) and short or full
		file:write(fs:format(key, value), "\n")
	end
	file:close()
	print("finished")
end

GlobalStrings()
-- GlobalStrings({build="9.0.2"})
-- GlobalStrings({build="1.13"})
-- GlobalStrings({locale="deDE"})
