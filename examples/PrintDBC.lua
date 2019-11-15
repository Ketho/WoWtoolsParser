local parser = require "wowtoolsparser"

parser.ExplodeCSV(parser.ReadCSV("uimap")) -- most recent retail build
parser.ExplodeCSV(parser.ReadCSV("chrraces", {build="1.13.2"})) -- most recent classic build

parser.ExplodeJSON(parser.ReadJSON("azeriteessence"))
parser.ExplodeJSON(parser.ReadJSON("map", {build="7.3.5.26972"})) -- specific build

--ExplodeListfile(parser.ReadListfile()) -- takes very long when printing
print("finished")
