-- https://wago.io/fjl8ot17v
local parser = require "wowtoolsparser"

local locales = {
	"enUS",
	"deDE",
	"frFR",
	"esES",
	"esMX",
	"ptBR",
	"ruRU",
	"zhCN",
	"zhTW",
	"koKR",
}

local output = "examples/WeaponSkills.txt"
local file = io.open(output, "w")
file:write("local weaponSkills = {\n")

for _, locale in pairs(locales) do
	local iter = parser.ReadCSV("skillline", {
		header = true,
		build = "1.13.6",
		locale = locale,
	})

	file:write(string.format("\t%s = {\n", locale))
	for l in iter:lines() do
		local id = tonumber(l.ID)
		if id then
			if tonumber(l.CategoryID) == 6 then
				file:write(string.format('\t\t[%d] = "%s",\n', id, l.DisplayName_lang))
			end
		end
	end
	file:write("\t},\n")
end

file:write("}\n")
