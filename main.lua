require "parser"

ParseJSON("mount") -- mount has json handler
ParseJSON("azeriteessence") -- no handler

ParseCSV("toy") -- toy has csv handler
ParseCSV("battlepetspecies") -- no handler

-- this takes very long when printing
ParseListfile()
