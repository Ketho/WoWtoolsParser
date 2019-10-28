## wow.tools Parser
Lua parser for CSV or JSON files from [wow.tools](https://wow.tools/) by [Marlamin](https://github.com/Marlamin/wow.tools)

* Files are downloaded and cached in `dbc/cache/`
* If the respective file handler exists in `dbc/` it will be used, see [main.lua](https://github.com/Ketho/WoWtoolsParser/blob/master/main.lua) for example usage

### Examples
Prints [UiMap.db2](https://wow.tools/dbc/?dbc=uimap)
```lua
local parser = require "parser"
local csv = parser.ReadCSV("uimap")
for line in csv:lines() do
	print(table.unpack(line))
end
```
Prints the most recent classic [ChrRaces.db2](https://wow.tools/dbc/?dbc=chrraces&build=1.13.2.32089) build
```lua
local parser = require "parser"
parser.ExplodeCSV(parser.ReadCSV("chrraces", {build="1.13.2"}))
```
Prints a specific [GlobalStrings.db2](https://wow.tools/dbc/?dbc=globalstrings&build=7.3.5.26972) build
```lua
local parser = require "parser"
local options = {
	build = "7.3.5.26972",
	header = true, -- index keys by header name
}

local globalstrings = parser.ReadCSV("globalstrings", options)
for line in globalstrings:lines() do
	print(line.ID, line.BaseTag, line.TagText_lang)
end
```

### Dependencies
* curl: https://curl.haxx.se/
* lua-curl: https://luarocks.org/modules/moteus/lua-curl
* lua-cjson: https://luarocks.org/modules/openresty/lua-cjson
* csv: https://luarocks.org/modules/geoffleyland/csv
* gumbo: https://luarocks.org/modules/craigb/gumbo
