## WoW.tools Parser
Lua parser for CSV or JSON files from [wow.tools](https://wow.tools/) by [Marlamin](https://github.com/Marlamin/wow.tools)  

### Usage
Prints [UiMap.db2](https://wow.tools/dbc/?dbc=uimap)
```lua
local parser = require "wowtoolsparser"
local iter = parser.ReadCSV("uimap")
for line in iter:lines() do
	print(table.unpack(line))
end
```
Prints the most recent classic [ChrRaces.db2](https://wow.tools/dbc/?dbc=chrraces&build=1.13.4.33728) build
```lua
local parser = require "wowtoolsparser"
parser.ExplodeCSV(parser.ReadCSV("chrraces", {build="1.13"}))
```
Prints a specific [GlobalStrings.db2](https://wow.tools/dbc/?dbc=globalstrings&build=7.3.5.26972) build and accesses table keys by header name
```lua
local parser = require "wowtoolsparser"
local options = {
	build = "7.3.5.26972",
	header = true, -- index keys by header
}

local iter = parser.ReadCSV("globalstrings", options)
for line in iter:lines() do
	print(line.ID, line.BaseTag, line.TagText_lang)
end
```

### Dependencies
* curl: https://curl.haxx.se/
* lua-curl: https://luarocks.org/modules/moteus/lua-curl
* lua-cjson: https://luarocks.org/modules/openresty/lua-cjson
* csv: https://luarocks.org/modules/geoffleyland/csv
