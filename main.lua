require "parser"

ParseJSON("azeriteessence") -- no handler
ParseJSON("mount") -- mount has json handler
ParseJSON("map", "7.3.5.26972") -- targeted build number

ParseCSV("battlepetspecies") -- no handler
ParseCSV("toy", true) -- toy has csv handler and keyed by header
ParseCSV("uimap", false, "1.13.2.31209") -- not keyed by header, targeted build number

-- this takes very long when printing
ParseListfile()
