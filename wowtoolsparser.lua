local cURL = require "cURL"
local cjson = require "cjson"
local cjsonutil = require "cjson.util"
local csv = require "csv"
local gumbo = require "gumbo"
local parser = {}

local user_agent = "your user agent here"

local html_url = "https://wow.tools/dbc/?dbc=%s"
local json_url = "https://wow.tools/api/data/%s/?build=%s&length=%d"
local csv_url = "https://wow.tools/api/export/?name=%s&build=%s"
local listfile_url = "https://wow.tools/casc/listfile/download/csv/unverified"

local csv_cache = "cache/%s_%s.csv"
local json_cache = "cache/%s_%s.json"
local listfile_cache = "cache/listfile.csv"

--- Sends an HTTP GET request.
-- @param url the URL of the request
-- @param file (optional) file to be written
-- @return string if file is given, the HTTP response
local function HTTP_GET(url, file)
	local data, idx = {}, 0
	cURL.easy{
		url = url,
		writefunction = file or function(str)
			idx = idx + 1
			data[idx] = str
		end,
		ssl_verifypeer = false,
		useragent = user_agent,
	}:perform():close()
	return table.concat(data)
end

--- Finds a wow.tools build from an HTML document.
-- @param name the DBC name
-- @param html the HTML document
-- @return build the build number (e.g. "8.2.0.30993")
local function FindBuild(name, build)
	if not build or #build <= 6 then
		local html = HTTP_GET(html_url:format(name))
		local document = gumbo.parse(html)
		local element = document:getElementById("buildFilter")
		if not build then
			local firstBuild = element.childNodes[2]:getAttribute("value")
			return firstBuild
		else
			-- if target is just "7.3.5" or "1.13", check for major version
			local majorversion = "^"..build:gsub("%.", "%%.") -- escape dots
			for i = 2, #element.childNodes, 2 do
				local value = element.childNodes[i]:getAttribute("value")
				if value:find(majorversion) then
					return value
				end
			end
		end
	end
	return build
end

--- Parses the DBC (with header) from CSV.
-- @param name the DBC name
-- @param options.build (optional) the build version, otherwise falls back to the most recent build
-- @param options.header (optional) if true, each set of fields will be keyed by header name, otherwise by column index
-- @return iter the csv iterator
function parser.ReadCSV(name, options)
	options = options or {}
	local build = FindBuild(name, options.build)
	-- cache csv
	local path = string.format(csv_cache, name, build)
	local file = io.open(path, "r")
	if not file then
		file = io.open(path, "w")
		HTTP_GET(csv_url:format(name, build), file)
		file:close()
	end
	print(string.format("reading %s.csv build %s", name, build))
	local iter = csv.open(path, options.header and {header = true})
	return iter
end

--- Parses the DBC from JSON.
-- @param name the DBC name
-- @param options.build (optional) the build version, otherwise falls back to the most recent build
-- @return tbl the converted json table
function parser.ReadJSON(name, options)
	options = options or {}
	local build = FindBuild(name, options.build)
	-- cache json
	local path = string.format(json_cache, name, build)
	local file = io.open(path, "r")
	if not file then
		file = io.open(path, "w")
		-- get number of records
		local initialRequest = HTTP_GET(json_url:format(name, build, 0)) -- saves them a slice call
		local recordsTotal = cjson.decode(initialRequest).recordsTotal
		-- write json to file
		HTTP_GET(json_url:format(name, build, recordsTotal), file)
		file:close()
	end
	print(string.format("reading %s.json build %s", name, build))
	local json = cjsonutil.file_load(path)
	local tbl = cjson.decode(json).data
	return tbl
end

--- Parses the CSV listfile.
-- @param refresh (optional) if the listfile should be redownloaded
function parser.ReadListfile(refresh)
	-- cache listfile
	local file = io.open(listfile_cache, "r")
	if refresh or not file then
		print("downloading listfile...")
		file = io.open(listfile_cache, "w")
		HTTP_GET(listfile_url, file)
		file:close()
	end
	-- read listfile
	local iter = csv.open(listfile_cache, {separator = ";"})
	local filedata = {}
	print("reading listfile...")
	for line in iter:lines() do
		local fdid, filePath = tonumber(line[1]), line[2]
		filedata[fdid] = filePath
	end
	print("finished reading.")
	return filedata
end

function parser.ExplodeCSV(iter)
	for line in iter:lines() do
		print(table.unpack(line))
	end
end

function parser.ExplodeJSON(tbl)
	for _, line in pairs(tbl) do
		print(table.unpack(line))
	end
end

function parser.ExplodeListfile(tbl)
	for fdid, path in pairs(tbl) do
		print(fdid, path)
	end
end

return parser
