require "parser"

ParseCSV("globalstrings", false, "8.2.5.31812")
--ParseCSV("globalstrings", false, "1.13.2.31650")

ParseJSON("azeriteessence") -- no handler
ParseJSON("mount") -- mount has json handler
ParseJSON("map", "7.3.5.26972") -- targeted build number
ParseCSV("battlepetspecies") -- no handler
ParseCSV("toy", 	true) -- toy has csv handler and keyed by header
ParseCSV("uimap", false, "1.13.2.31209") -- not keyed by header, targeted build number
--ParseListfile() -- this takes very long when printing

print("finished")
