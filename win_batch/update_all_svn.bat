@echo off

rem Update all directories on the current level including externals.

rem https://ss64.com/nt/for_d.html
for /D %%d in (*) do (
	svn update %%d
)

exit /b