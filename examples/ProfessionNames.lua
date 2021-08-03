local parser = require "wowtoolsparser"

local locales = {
	"enUS",
	"deDE",
	"frFR",
	"esMX",
	"ptBR",
	"ruRU",
	"zhCN",
	"zhTW",
	"koKR",
}

local output = "out/ProfessionNames.lua"
local file = io.open(output, "w")
file:write("local ProfessionNames = {\n")

for _, locale in pairs(locales) do
	local iter = parser:ReadCSV("skillline", {
		header = true,
		locale = locale,
	})

	file:write(string.format("\t%s = {\n", locale))
	for l in iter:lines() do
		local ID = tonumber(l.ID)
		if ID then
			if tonumber(l.SpellBookSpellID) > 0 then
				file:write(string.format('\t\t[%d] = "%s",\n', ID, l.DisplayName_lang))
			end
		end
	end
	file:write("\t},\n")
end
file:write("}\n")
file:close()
