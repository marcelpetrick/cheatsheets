# Cheatsheet for JQL (JIRa query language)

## List all open tickets for specific version, which are open
(statusCategory != "Done")  AND project = 10204 AND fixVersion = 13638 ORDER BY priority DESC, key ASC

(Note: adapt project and version of course)

## find all tickets processed by me
resolved >= -999w AND assignee in (currentUser()) ORDER BY updated DESC
