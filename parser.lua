local cURL = require "cURL"
local gumbo = require "gumbo"
local cjson = require "cjson"
local cjsonutil = require "cjson.util"
local csv = require "csv"

local html_url = "https://wow.tools/dbc/?dbc=%s"
local json_url = "https://wow.tools/api/data/%s/?build=%s&length=%d"
local listfile_url = "https://wow.tools/casc/listfile/download/csv/unverified"

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

local function GetLatestBuild(html)
	local document = gumbo.parse(html)
	local element = document:getElementById("buildFilter")
	local build = element.childNodes[2]:getAttribute("value")
	return build
end

local function CacheJSON(dbc, build, file)
	-- get size
	local initialRequest = HTTP_GET(json_url:format(dbc, build, 0)) -- saves them a slice call
	local recordsTotal = cjson.decode(initialRequest).recordsTotal
	-- write to file
	HTTP_GET(json_url:format(dbc, build, recordsTotal), file)
end

function ParseDBC(dbc)
	-- check build
	local html = HTTP_GET(html_url:format(dbc))
	local build = GetLatestBuild(html)
	-- cache json
	local path = string.format("dbc/cache/%s_%s.json", dbc, build)
	local file = io.open(path, "r")
	if not file then
		file = io.open(path, "w")
		CacheJSON(dbc, build, file)
		file:close()
	end
	-- read from file
	local json = cjsonutil.file_load(path)
	local tbl = cjson.decode(json).data
	local handler = require("dbc/"..dbc)
	handler(tbl)
	print("Finished parsing "..dbc)
end

function ParseListfile(force)
	-- cache listfile
	local path = string.format("dbc/cache/listfile.csv")
	local file = io.open(path, "r")
	if force or not file then
		file = io.open(path, "w")
		HTTP_GET(listfile_url, file) 
		file:close()
	end
	-- read listfile
	local file = csv.open(path, {separator = ";"})
	for line in file:lines() do
		print(line[1], line[2])
	end
end
