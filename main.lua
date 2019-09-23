local parser = require "parser"

parser.ReadCSV("globalstrings")
--parser.ReadCSV("globalstrings", false, "1.13.2.31650")
--[[
parser.ReadJSON("azeriteessence") -- no handler
parser.ReadJSON("mount") -- mount has json handler
parser.ReadJSON("map", "7.3.5.26972") -- targeted build number
parser.ReadCSV("battlepetspecies") -- no handler
parser.ReadCSV("toy", true) -- toy has csv handler and keyed by header
parser.ReadCSV("uimap", false, "1.13.2.31209") -- not keyed by header, targeted build number
--parser.ReadListfile() -- this takes very long when printing
]]
print("finished")
