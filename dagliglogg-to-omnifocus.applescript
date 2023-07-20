set visMelding to false
set dagligProject to "Dagliglogg"
set reportText to ""

if application "OmniFocus" is running then
	tell front document of application "OmniFocus"
		if project dagligProject exists then
			set theProject to project dagligProject
			set theTasks to number of tasks of theProject
			if (theTasks > 0) then
				try
					set theTask to (last flattened task of theProject where its completed = false)
					set theTime to creation date of theTask
					set theTime to time string of theTime
					set reportText to theTime & " - " & name of theTask
				on error
					set reportText to "Ingen"
				end try
			end if
		end if
	end tell
end if

set test to display dialog "Dagslogg" & " forrige er: " & return & reportText default answer " " with title "Omnifocus logg" default button "OK"
if the button returned of the result is "OK" then
	set loggtekst to text returned of the result
	set intLengde to length of loggtekst
	set tmpIndeks to 0
	set tmpString to ""
	repeat
		set tmpString to (get text (intLengde - tmpIndeks) thru (intLengde - tmpIndeks) of loggtekst)
		if (tmpString = " ") then
			exit repeat
		end if
		set tmpIndeks to tmpIndeks + 1
		if (tmpIndeks = intLengde) then
			exit repeat
		end if
	end repeat
	if (intLengde > tmpIndeks) then
		try
			set minutter to ((get text (intLengde - tmpIndeks) through intLengde of loggtekst) as integer)
		on error
			set minutter to 0
			set tmpIndeks to -1
		end try
		set loggtekst to (get text 1 through (intLengde - tmpIndeks - 1) of loggtekst)
	else
		set minutter to 0
		set loggtekst to (get text 1 through (intLengde - tmpIndeks - 1) of loggtekst)
	end if
end if

if application "OmniFocus" is running then
	tell front document of application "OmniFocus"
		if project dagligProject exists then
			set currentProject to project dagligProject
			tell currentProject
				make new task with properties {name:(loggtekst), estimated minutes:minutter}
			end tell
		end if
	end tell
else
	display dialog "OmniFocus kjører ikke" with title "OmniFocus" buttons {"OK"} default button "OK" giving up after 4
end if

if visMelding then
	set melding to loggtekst & " lagt til"
	display dialog melding with title "OmniFocus" buttons {"OK"} default button "OK" giving up after 2
end if
