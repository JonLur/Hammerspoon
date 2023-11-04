global visMelding
global nettsiderProject
global currentURL
global currentTitle
global engangkanskjeFolder
global nettsidearkivProject

on run
	set visMelding to true
	set nettsiderProject to "Nettsider"
	set engangkanskjeFolder to "Engang / Kanskje"
	set nettsidearkivProject to "EK-Nettsider"

	if application "OmniFocus" is running then
		getBrowserURL()
		addTaskOmniFocus()
		if visMelding then
			visStatusMelding()
		end if
		archiveTaskOmniFocus()
	else
		display dialog "OmniFocus kjører ikke" with title "OmniFocus" buttons {"OK"} default button "OK" giving up after 2
	end if
end run

on getBrowserURL()
	if application "Microsoft Edge" is frontmost then
		tell application "Microsoft Edge"
			set currentTitle to title of active tab of front window
			set currentURL to URL of active tab of front window
			end tell
	else if application "Google Chrome" is frontmost then
		tell application "Google Chrome"
			set currentTitle to title of active tab of front window
			set currentURL to URL of active tab of front window
		end tell
	else if application "Safari" is frontmost then
		tell application "Safari"
			set currentTitle to name of front document
			set currentURL to URL of front document
		end tell
	else
		display dialog "Hverken Chrome eller Safari kjører" with title "OmniFocus" buttons {"OK"} default button "OK" giving up after 2
	end if
end getBrowserURL


on addTaskOmniFocus()
	tell front document of application "OmniFocus"
		if project nettsiderProject exists then
			set currentProject to project nettsiderProject
			tell currentProject
				make new task with properties {name:(currentTitle), note:currentURL as text}
			end tell
		end if
	end tell
end addTaskOmniFocus


on visStatusMelding()
	set melding to currentTitle & " lagt til"
	display dialog melding with title "OmniFocus" buttons {"OK"} default button "OK" giving up after 2
end visStatusMelding


on archiveTaskOmniFocus()
  set theDate to current date
  set moveDate to theDate - 4 * weeks
  set reportText to ""

  if application "OmniFocus" is running then
  	tell front document of application "OmniFocus"
  		if project nettsiderProject exists then
  			set theProject to project nettsiderProject
  			set theTasks to (every flattened task of theProject where its completed = false and creation date is less than moveDate)

  			-- If there are tasks that meet the criteria
  			if theTasks is not equal to {} then
  				set reportText to reportText & return & "Flyttet til arkiv"
  				-- Loop through the tasks
  				repeat with b from 1 to length of theTasks
  					-- Get the current task to work with
  					set currentTask to item b of theTasks
  					set reportText to reportText & return & "*" & name of currentTask
  					if folder engangkanskjeFolder exists then
  						set theFolder to folder engangkanskjeFolder
  						tell theFolder
  							if project nettsidearkivProject exists then
  								set theProject to project nettsidearkivProject
  							end if
  						end tell
  						move currentTask to end of tasks of theProject
  					end if
  				end repeat
  			end if
  		end if
  	end tell
  end if
  if (length of reportText is greater than 0) then
  	display dialog reportText with title "OmniFocus URL arkivering" buttons {"OK"} default button "OK" giving up after 5
  end if
end archiveTaskOmniFocus
