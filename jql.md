# Cheatsheet for JQL (JIRa query language)

## List all open tickets for specific version, which are open
todo

## find all tickets processed by me
resolved >= -999w AND assignee in (currentUser()) ORDER BY updated DESC
