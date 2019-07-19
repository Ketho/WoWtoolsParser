local cURL = require "cURL"
local cjson = require "cjson"
local cjsonutil = require "cjson.util"
local csv = require "csv"
local gumbo = require "gumbo"

local html_url = "https://wow.tools/dbc/?dbc=%s"
local json_url = "https://wow.tools/api/data/%s/?build=%s&length=%d"
local csv_url = "https://wow.tools/api/export/?name=%s&build=%s"
local listfile_url = "https://wow.tools/casc/listfile/download/csv/unverified"

--- Sends an HTTP GET request.
-- @param url the URL of the request
-- @param file (optional) file to be written
-- @return if file is given, string of the response
local function HTTP_GET(url, file)
	local data, idx = {}, 0
	cURL.easy{
		url = url,
		writefunction = file or function(str)
			idx = idx + 1
			data[idx] = str
		end,
		ssl_verifypeer = false,
	}:perform():close()
	return table.concat(data)
end

--- Finds the most recent wow.tools build from an HTML document.
-- @param html the HTML document
-- @return build number (e.g. "8.2.0.30993")
local function GetLatestBuild(html)
	local document = gumbo.parse(html)
	local element = document:getElementById("buildFilter")
	local build = element.childNodes[2]:getAttribute("value")
	return build
end

--- Parses the DBC from JSON.
-- Calls the respective dbc\<name>.lua handler if applicable, otherwise prints the whole DBC
-- @param name of the DBC
function ParseJSON(name)
	-- get build
	local html = HTTP_GET(html_url:format(name))
	local build = GetLatestBuild(html)
	-- cache json
	local path = string.format("dbc/cache/%s_%s.json", name, build)
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
	-- read from file
	local json = cjsonutil.file_load(path)
	local tbl = cjson.decode(json).data
	local exists, handler = pcall(require, "dbc/"..name)
	if exists then
		handler(tbl)
	else
		for i, v in pairs(tbl) do
			print(i, table.unpack(v))
		end
	end
end

--- Parses the DBC (with header) from CSV.
-- Calls the respective dbc\<name>.lua handler if applicable, otherwise prints the whole DBC
-- If a handler exists, each set of fields will be keyed by the names in the header
-- @param name of the DBC
function ParseCSV(name)
	-- get build
	local html = HTTP_GET(html_url:format(name))
	local build = GetLatestBuild(html)
	-- cache csv
	local path = string.format("dbc/cache/%s_%s.csv", name, build)
	local file = io.open(path, "r")
	if not file then
		file = io.open(path, "w")
		HTTP_GET(csv_url:format(name, build), file) 
		file:close()
	end
	-- read from file
	local exists, handler = pcall(require, "dbc/"..name)
	local f = csv.open(path, exists and {header = true})
	if exists then
		handler(f)
	else
		for line in f:lines() do
			print(table.unpack(line))
		end
	end
end

--- Parses the CSV listfile.
-- @refresh if the listfile should be redownloaded
function ParseListfile(refresh)
	-- cache listfile
	local path = "dbc/cache/listfile.csv"
	local file = io.open(path, "r")
	if refresh or not file then
		file = io.open(path, "w")
		HTTP_GET(listfile_url, file) 
		file:close()
	end
	-- read listfile
	local file = csv.open(path, {separator = ";"})
	for line in file:lines() do
		local fdid, path = line[1], line[2]
		print(fdid, path)
	end
end
