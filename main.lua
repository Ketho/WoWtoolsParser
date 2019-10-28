local parser = require "wowtoolsparser"

parser.ExplodeCSV(parser.ReadCSV("uimap")) -- most recent retail build
parser.ExplodeCSV(parser.ReadCSV("chrraces", {build="1.13.2"})) -- most recent classic build

parser.ExplodeJSON(parser.ReadJSON("azeriteessence"))
parser.ExplodeJSON(parser.ReadJSON("map", {build="7.3.5.26972"})) -- specific build

-- has file handlers in dbc/
parser.ReadCSV("toy", {header=true}) -- dbc/toy.lua, keyed by header name
parser.ReadJSON("mount") -- dbc/mount.lua

--ExplodeListfile(parser.ReadListfile()) -- this takes very long when printing
print("finished")
