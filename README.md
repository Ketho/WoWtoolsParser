## wow.tools Parser
Lua parser for CSV or JSON files from [wow.tools](https://wow.tools/)

* CSV/JSON Files will be downloaded and then cached in `dbc/cache/`
* If a handler exists in `dbc/` it will be used, otherwise just prints the file's contents.

Example usage can be found in `main.lua` and `scripts/`

#### Dependencies
* curl: https://curl.haxx.se/
* lua-curl: https://luarocks.org/modules/moteus/lua-curl
* lua-cjson: https://luarocks.org/modules/openresty/lua-cjson
* csv: https://luarocks.org/modules/geoffleyland/csv
* gumbo: https://luarocks.org/modules/craigb/gumbo
