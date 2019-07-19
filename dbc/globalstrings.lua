-- handler for ParseJSON
local globalstrings = {}
local shortcut = '%s = "%s";'
local full = '_G["%s"] = "%s";'

-- use full syntax
local fullKeys = {
	["8.0_WARFRONTS_-_ARATHI_-_CONSTRUCT_BUILDING_-_BARRACKS"] = true,
	["8.2_HUNTER_KILLER_ENERGY"] = true,
	["82_TAUREN_HERITAGE_TOY_ERROR"] = true,
	["ARGUS_RAID-ENGINEER_BOSS-FIRE_ENERGY"] = true,
	["HUNTER_KILLER_AREA_DENIAL_BOT-BATTERY"] = true,
}

local slashKeys = {
	KEY_BACKSLASH = '\\\\',
	CHATLOGENABLED = 'Chat being logged to Logs\\\\WoWChatLog.txt',
	COMBATLOGENABLED = "Combat being logged to Logs\\\\WoWCombatLog.txt",
}

local function read(tbl)
	-- filter and sort globalstrings
	for _, v in pairs(tbl) do
		local flags = tonumber(v[4])
		-- strings with flags 0 and 2 are not available in-game
		if flags == 1 or flags == 3 then
			local key, value = v[2], v[3]
			table.insert(globalstrings, {key, value})
		end
	end
	table.sort(globalstrings, function(a, b)
		return a[1] < b[1]
	end)

	local file = io.open("out/globalstrings.lua", "w")
	for _, v in pairs(globalstrings) do
		local key, value = v[1], v[2]
		-- space char
		value = value:gsub('\\32', ' ')
		-- unescape any quotes before escaping quotes
		value = value:gsub('\\\"', '"')
		value = value:gsub('"', '\\\"')
		-- dont know any good pattern, escape single backslashes manually
		value = slashKeys[key] or value

		local fs = fullKeys[key] and full or shortcut
		file:write(fs:format(key, value), "\n")
	end
	file:close()
end

return read
