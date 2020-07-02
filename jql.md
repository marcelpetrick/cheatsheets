# Cheatsheet for JQL (JIRA query language)

## List all open tickets for specific version, which are open
(statusCategory != "Done") AND project = 10204 AND fixVersion = 13638 ORDER BY priority DESC, key ASC

(Note: adapt project and version of course)

## List all open tickets for specific version, which are open and have more than one hour left (remaining estimate)

(statusCategory != "Done") AND project = 10204 AND fixVersion = 13638 AND remainingEstimate > 1h ORDER BY priority DESC, key ASC

## List all open tickets for specific version, which are not assigned to the active sprint

(statusCategory != "Done") AND project = 10204 AND fixVersion = 13638 AND AND (sprint is EMPTY or sprint in closedSprints()) ORDER BY priority DESC, key ASC

## find all tickets processed by me
resolved >= -999w AND assignee in (currentUser()) ORDER BY updated DESC

## Find all tickets whcih belong to a certain project and release and which are not done
project = myPROJECT AND fixVersion = 1.33.7 AND resolution = Unresolved ORDER BY remainingEstimate DESC, priority DESC, updated DESC
