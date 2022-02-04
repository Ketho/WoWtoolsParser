## WoW.tools Parser
Lua parser for CSV or JSON files from [wow.tools](https://wow.tools/) by [Marlamin](https://github.com/Marlamin/wow.tools)  

### Usage
Prints [UiMap.db2](https://wow.tools/dbc/?dbc=uimap)
```lua
local parser = require "wowtoolsparser"
local iter = parser:ReadCSV("uimap")
for line in iter:lines() do
	print(table.unpack(line))
end
```
Prints the most recent classic [ChrRaces.db2](https://wow.tools/dbc/?dbc=chrraces&build=1.13.7.37892) build
```lua
local parser = require "wowtoolsparser"
parser:ExplodeCSV(parser:ReadCSV("chrraces", {build="1.13"}))
```
Prints a specific [GlobalStrings.db2](https://wow.tools/dbc/?dbc=globalstrings&build=7.3.5.26972) build for the French locale, keyed by header name
```lua
local parser = require "wowtoolsparser"
local options = {
	header = true, -- index keys by header
	build = "7.3.5.26972",
	locale = "frFR",
}

local iter = parser:ReadCSV("globalstrings", options)
for line in iter:lines() do
	print(line.ID, line.BaseTag, line.TagText_lang)
end
```

### Dependencies
* luafilesystem: https://luarocks.org/modules/hisham/luafilesystem
* luasocket: https://luarocks.org/modules/luasocket/luasocket
* luasec: https://luarocks.org/modules/brunoos/luasec
* lua-cjson: https://luarocks.org/modules/openresty/lua-cjson
* csv: https://luarocks.org/modules/geoffleyland/csv

