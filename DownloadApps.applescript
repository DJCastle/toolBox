-- ============================================================
--  Non App Store Apps Download
--  A native macOS AppleScript application
--  https://github.com/DJCastle/nonappstoreappsdownload
--
--  Built with AppleScript and compiled with Apple's osacompile.
--  Part of Apple's macOS automation ecosystem.
--
--  Edit apps.txt inside the app bundle to change the app list:
--    Right-click app > Show Package Contents > Contents > Resources > apps.txt
-- ============================================================

on run
	-- Locate apps.txt inside the app bundle
	set myPath to POSIX path of (path to me)
	set configFile to myPath & "Contents/Resources/apps.txt"

	-- Read and parse the config file
	set appList to my loadAppList(configFile)

	-- Welcome / Manage Apps loop
	repeat
		set totalApps to count of appList

		-- Build numbered preview list
		set previewList to ""
		if totalApps > 0 then
			repeat with i from 1 to totalApps
				set appName to item 1 of (item i of appList)
				set previewList to previewList & "     " & i & ".  " & appName & return
			end repeat
		else
			set previewList to "     (no apps in list)" & return
		end if

		-- Show welcome dialog
		if totalApps > 0 then
			set welcomeResult to button returned of (display dialog "Ready to download " & totalApps & " apps to your Desktop:" & return & return & previewList & return & "Always downloads the latest stable release from official sources." buttons {"Manage Apps", "Cancel", "Download All"} default button "Download All" cancel button "Cancel" with title "Non App Store Apps Download" with icon note)
		else
			set welcomeResult to button returned of (display dialog "Your app list is empty." & return & return & "Click \"Manage Apps\" to search for apps to download." buttons {"Manage Apps", "Cancel"} default button "Manage Apps" cancel button "Cancel" with title "Non App Store Apps Download" with icon note)
		end if

		if welcomeResult is "Download All" then
			exit repeat

		else if welcomeResult is "Manage Apps" then
			-- Show manage sub-menu
			if totalApps > 0 then
				set manageResult to button returned of (display dialog "What would you like to do?" buttons {"Remove App", "Back", "Add App"} default button "Add App" with title "Manage Apps" with icon note)
			else
				set manageResult to "Add App"
			end if

			if manageResult is "Add App" then
				-- Ask for search term
				try
					set searchResponse to display dialog "Search for an app by name:" & return & return & "Examples:  Firefox, Slack, Discord, Spotify" default answer "" buttons {"Cancel", "Search"} default button "Search" cancel button "Cancel" with title "Add App" with icon note
					set searchTerm to text returned of searchResponse

					if searchTerm is not "" then
						-- Search Homebrew Cask catalog
						set searchResults to my searchBrewCask(searchTerm)

						if searchResults is {} then
							display dialog "No apps found matching \"" & searchTerm & "\"." & return & return & "Try a different name, or browse all available apps at:" & return & "https://formulae.brew.sh/cask/" buttons {"OK"} default button "OK" with title "Search Results" with icon caution
						else
							-- Let user pick from results
							set chosenApp to choose from list searchResults with prompt "Select an app to add:" & return & "(showing up to 20 matches)" with title "Search Results"
							if chosenApp is not false then
								set chosenItem to item 1 of chosenApp

								-- Parse cask name and display name
								set caskName to my extractCaskName(chosenItem)
								set appDisplayName to my extractDisplayName(chosenItem)

								-- Check for duplicates
								set isDuplicate to false
								repeat with existingApp in appList
									if item 3 of existingApp is "BREW:" & caskName then
										set isDuplicate to true
										exit repeat
									end if
								end repeat

								if isDuplicate then
									display dialog appDisplayName & " is already in your download list." buttons {"OK"} default button "OK" with title "Already Added" with icon note
								else
									-- Add to in-memory list
									set end of appList to {appDisplayName, appDisplayName & ".dmg", "BREW:" & caskName}

									-- Save to apps.txt permanently
									try
										do shell script "echo " & quoted form of (appDisplayName & " | " & appDisplayName & ".dmg | BREW:" & caskName) & " >> " & quoted form of configFile
									end try

									display dialog my checkMark() & "  " & appDisplayName & " added." & return & "It will be included in every future download." buttons {"OK"} default button "OK" with title "App Added" with icon note
								end if
							end if
						end if
					end if
				on error number -128
					-- User cancelled the search dialog
				end try

			else if manageResult is "Remove App" then
				-- Build list of app names for selection
				set appNames to {}
				repeat with i from 1 to totalApps
					set end of appNames to item 1 of (item i of appList)
				end repeat

				-- Let user select apps to remove (multiple selection)
				set appsToRemove to choose from list appNames with prompt "Select apps to remove:" & return & "(hold Command to select multiple)" with title "Remove Apps" with multiple selections allowed
				if appsToRemove is not false then
					set removeCount to count of appsToRemove

					-- Build preview of what will be removed
					set removePreview to ""
					repeat with appToRemove in appsToRemove
						set removePreview to removePreview & "     " & my crossMark() & "  " & (appToRemove as text) & return
					end repeat

					-- Confirm removal
					set confirmResult to button returned of (display dialog "Remove " & removeCount & " app(s) from your list?" & return & return & removePreview buttons {"Cancel", "Remove"} default button "Cancel" cancel button "Cancel" with title "Confirm Removal" with icon caution)

					if confirmResult is "Remove" then
						-- Remove each selected app from apps.txt
						repeat with appToRemove in appsToRemove
							repeat with i from 1 to count of appList
								if item 1 of (item i of appList) is (appToRemove as text) then
									set urlRef to item 3 of (item i of appList)
									-- Remove line containing this URL reference from apps.txt
									set pyRemove to "import sys" & linefeed & "ref = sys.argv[2]" & linefeed & "with open(sys.argv[1]) as f:" & linefeed & "    lines = f.readlines()" & linefeed & "with open(sys.argv[1], 'w') as f:" & linefeed & "    for line in lines:" & linefeed & "        if ref not in line:" & linefeed & "            f.write(line)"
									try
										do shell script "python3 -c " & quoted form of pyRemove & " " & quoted form of configFile & " " & quoted form of urlRef
									end try
									exit repeat
								end if
							end repeat
						end repeat

						-- Rebuild in-memory list without removed apps
						set newAppList to {}
						repeat with i from 1 to count of appList
							set isRemoved to false
							repeat with appToRemove in appsToRemove
								if item 1 of (item i of appList) is (appToRemove as text) then
									set isRemoved to true
									exit repeat
								end if
							end repeat
							if not isRemoved then
								set end of newAppList to item i of appList
							end if
						end repeat
						set appList to newAppList

						display dialog my checkMark() & "  " & removeCount & " app(s) removed from your list." buttons {"OK"} default button "OK" with title "Apps Removed" with icon note
					end if
				end if
			end if
		end if
	end repeat

	-- Build status tracking lists
	set totalApps to count of appList
	set appStates to {}
	set appSizes to {}
	repeat with i from 1 to totalApps
		set end of appStates to "pending"
		set end of appSizes to ""
	end repeat

	-- Set up progress bar
	set progress total steps to totalApps
	set progress description to "Preparing to download " & totalApps & " apps..."
	set progress additional description to my buildStatusList(appList, appStates, appSizes)

	set destFolder to (POSIX path of (path to desktop folder))
	set successCount to 0
	set failCount to 0
	set totalBytes to 0
	set startTime to (current date)

	-- Download each app
	repeat with i from 1 to totalApps
		set thisApp to item i of appList
		set appName to item 1 of thisApp
		set fileName to item 2 of thisApp
		set downloadURL to item 3 of thisApp
		set destPath to destFolder & fileName

		-- Mark as resolving
		set item i of appStates to "resolving"
		set item i of appSizes to "Preparing..."
		set timeEst to my estimateTime(startTime, i - 1, totalApps)
		set progress description to "Downloading " & i & " of " & totalApps & timeEst
		set progress additional description to my buildStatusList(appList, appStates, appSizes)
		set progress completed steps to (i - 1)

		-- Resolve BREW: URLs via Homebrew Cask API (always gets latest stable release)
		if downloadURL starts with "BREW:" then
			set caskName to text 6 thru -1 of downloadURL
			set item i of appSizes to "Checking latest stable release..."
			set progress additional description to my buildStatusList(appList, appStates, appSizes)
			try
				set brewJSON to do shell script "curl -s --connect-timeout 10 --max-time 15 " & quoted form of ("https://formulae.brew.sh/api/cask/" & caskName & ".json")
				set brewURL to do shell script "echo " & quoted form of brewJSON & " | python3 -c \"import sys,json; print(json.load(sys.stdin).get('url',''))\""
				set brewVersion to do shell script "echo " & quoted form of brewJSON & " | python3 -c \"import sys,json; print(json.load(sys.stdin).get('version',''))\""
				if brewURL is not "" then
					set downloadURL to brewURL
					set item i of appSizes to "v" & brewVersion & " (stable)"
					-- Update filename from resolved URL
					set resolvedFile to do shell script "basename " & quoted form of brewURL
					if resolvedFile is not "" then
						set fileName to resolvedFile
						set destPath to destFolder & fileName
					end if
				else
					set downloadURL to ""
				end if
			on error
				set downloadURL to ""
			end try
			if downloadURL is "" then
				set failCount to failCount + 1
				set item i of appStates to "failed"
				set item i of appSizes to "Cask not found"
				set progress additional description to my buildStatusList(appList, appStates, appSizes)
			end if
		end if

		-- Resolve GITHUB: URLs via GitHub Releases API
		if downloadURL starts with "GITHUB:" then
			set item i of appSizes to "Finding latest release..."
			set progress additional description to my buildStatusList(appList, appStates, appSizes)
			set repoPath to text 8 thru -1 of downloadURL
			try
				set downloadURL to do shell script "curl -s --connect-timeout 10 --max-time 15 " & quoted form of ("https://api.github.com/repos/" & repoPath & "/releases/latest") & " | grep 'browser_download_url.*mac.*\\.dmg' | head -1 | cut -d '\"' -f 4"
			on error
				set downloadURL to ""
			end try
			if downloadURL is "" then
				set failCount to failCount + 1
				set item i of appStates to "failed"
				set item i of appSizes to "Release not found"
				set progress additional description to my buildStatusList(appList, appStates, appSizes)
			end if
		end if

		if downloadURL is not "" and item i of appStates is not "failed" then
			set item i of appStates to "downloading"
			set item i of appSizes to "Connecting..."
			set progress additional description to my buildStatusList(appList, appStates, appSizes)

			-- Remove existing file so we can track size from zero
			try
				do shell script "rm -f " & quoted form of destPath
			end try

			-- Launch curl in background -- redirect all FDs so do shell script returns immediately
			set curlPID to do shell script "curl -L -s --connect-timeout 15 -o " & quoted form of destPath & " " & quoted form of downloadURL & " >/dev/null 2>&1 & echo $!"

			-- Poll until download completes -- UI stays responsive
			set dlStartTime to (current date)
			repeat
				delay 1

				-- Check if curl is still running
				set isRunning to "no"
				try
					set isRunning to do shell script "kill -0 " & curlPID & " 2>/dev/null && echo 'yes' || echo 'no'"
				end try

				-- Get current file size
				set currentSize to 0
				try
					set currentSize to (do shell script "stat -f '%z' " & quoted form of destPath & " 2>/dev/null || echo '0'") as number
				end try

				-- Calculate speed and show progress
				set dlElapsed to (current date) - dlStartTime
				if dlElapsed > 0 and currentSize > 0 then
					set speed to currentSize / dlElapsed
					set item i of appSizes to (my formatSize(currentSize)) & "  @  " & (my formatSize(round speed)) & "/s"
				else if currentSize > 0 then
					set item i of appSizes to my formatSize(currentSize)
				end if

				-- Update UI
				set timeEst to my estimateTime(startTime, i - 1, totalApps)
				set progress description to "Downloading " & i & " of " & totalApps & timeEst
				set progress additional description to my buildStatusList(appList, appStates, appSizes)

				if isRunning is "no" then exit repeat
			end repeat

			-- Check if download succeeded (file exists and is reasonable size)
			set finalSize to 0
			try
				set finalSize to (do shell script "stat -f '%z' " & quoted form of destPath & " 2>/dev/null || echo '0'") as number
			end try

			if finalSize > 1000 then
				set successCount to successCount + 1
				set totalBytes to totalBytes + finalSize
				set item i of appStates to "done"
				set item i of appSizes to my formatSize(finalSize)
			else
				set failCount to failCount + 1
				set item i of appStates to "failed"
				set item i of appSizes to "Download failed"
				try
					do shell script "rm -f " & quoted form of destPath
				end try
			end if
		end if

		-- Update progress after this app
		set timeEst to my estimateTime(startTime, i, totalApps)
		if i < totalApps then
			set progress description to "Downloading " & i & " of " & totalApps & timeEst
		else
			set progress description to "Finishing up..."
		end if
		set progress additional description to my buildStatusList(appList, appStates, appSizes)
		set progress completed steps to i
	end repeat

	-- Calculate total time and size
	set elapsed to (current date) - startTime
	set timeText to my formatTime(elapsed)
	set totalSizeText to my formatSize(totalBytes)

	-- Build results summary
	set resultText to ""
	repeat with i from 1 to totalApps
		set appName to item 1 of (item i of appList)
		set state to item i of appStates
		set sizeText to item i of appSizes
		if state is "done" then
			set resultText to resultText & "     " & my checkMark() & "   " & appName & "     " & sizeText & return
		else
			set resultText to resultText & "     " & my crossMark() & "   " & appName & "     " & sizeText & return
		end if
	end repeat

	-- Show completion dialog
	if failCount is 0 then
		set summaryLine to my checkMark() & "  All " & successCount & " apps downloaded successfully"
		set detailLine to totalSizeText & " total  " & my bullet() & "  " & timeText
		set instructionLine to "Open each .dmg to install, or unzip .zip files to get the .app." & return & "macOS Gatekeeper will verify each app before it runs."
		set dialogResult to button returned of (display dialog summaryLine & return & detailLine & return & return & resultText & return & instructionLine buttons {"Open Desktop", "Done"} default button "Done" with title "Non App Store Apps Download" with icon note)
	else
		set summaryLine to successCount & " of " & totalApps & " apps downloaded  " & my bullet() & "  " & failCount & " failed"
		set detailLine to totalSizeText & " total  " & my bullet() & "  " & timeText
		set instructionLine to "Failed downloads may be due to network issues or changed URLs." & return & "Check that your download links point to official vendor sites."
		set dialogResult to button returned of (display dialog summaryLine & return & detailLine & return & return & resultText & return & instructionLine buttons {"Open Desktop", "Done"} default button "Done" with title "Non App Store Apps Download" with icon caution)
	end if

	if dialogResult is "Open Desktop" then
		tell application "Finder"
			open folder "Desktop" of home
			activate
		end tell
	end if
end run

-- ============================================================
--  Config File Functions
-- ============================================================

-- Load and parse the app list from apps.txt
on loadAppList(configFile)
	set appList to {}
	try
		set configText to do shell script "cat " & quoted form of configFile
	on error
		return appList
	end try

	set configLines to paragraphs of configText
	repeat with aLine in configLines
		set trimmed to my trimText(aLine as text)
		if trimmed is not "" and trimmed does not start with "#" then
			set appRecord to my parseLine(trimmed)
			if appRecord is not missing value then
				set end of appList to appRecord
			end if
		end if
	end repeat
	return appList
end loadAppList

-- ============================================================
--  Homebrew Cask Search
-- ============================================================

-- Search the Homebrew Cask catalog for apps matching a search term
on searchBrewCask(searchTerm)
	set cacheFile to "/tmp/brew_cask_catalog.json"

	-- Download catalog if not cached or stale (older than 24 hours)
	set needsDownload to true
	try
		set cacheAge to (do shell script "echo $(( $(date +%s) - $(stat -f '%m' " & quoted form of cacheFile & " 2>/dev/null || echo 0) ))") as number
		if cacheAge < 86400 then
			-- Verify the cache file is valid JSON (not empty or corrupt)
			do shell script "python3 -c \"import json,sys; json.load(open(sys.argv[1]))\" " & quoted form of cacheFile & " 2>/dev/null"
			set needsDownload to false
		end if
	end try

	if needsDownload then
		try
			do shell script "curl -s --connect-timeout 15 --max-time 45 " & quoted form of "https://formulae.brew.sh/api/cask.json" & " -o " & quoted form of cacheFile
		on error
			return {}
		end try
	end if

	-- Search with Python — exact matches first, then partial matches
	set pyScript to "import json, sys
with open(sys.argv[2]) as f:
    data = json.load(f)
q = sys.argv[1].lower()
exact = []
partial = []
for c in data:
    t = c.get('token', '')
    names = c.get('name', [])
    n = names[0] if names else t
    if t == q or q == n.lower():
        exact.append(n + ' (' + t + ')')
    elif q in t or any(q in x.lower() for x in names):
        partial.append(n + ' (' + t + ')')
for m in (exact + partial)[:20]:
    print(m)"

	try
		set resultText to do shell script "python3 -c " & quoted form of pyScript & " " & quoted form of searchTerm & " " & quoted form of cacheFile
		if resultText is "" then return {}
		return paragraphs of resultText
	on error
		return {}
	end try
end searchBrewCask

-- Extract cask name from "App Name (cask-name)" format
on extractCaskName(displayString)
	set oldDelims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "("
	set parts to text items of displayString
	set lastPart to last item of parts
	set AppleScript's text item delimiters to ")"
	set caskName to first text item of lastPart
	set AppleScript's text item delimiters to oldDelims
	return caskName
end extractCaskName

-- Extract display name from "App Name (cask-name)" format
on extractDisplayName(displayString)
	set oldDelims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to " ("
	set parts to text items of displayString
	set displayName to first item of parts
	set AppleScript's text item delimiters to oldDelims
	return displayName
end extractDisplayName

-- ============================================================
--  UI Helper Functions
-- ============================================================

-- Status symbols
on checkMark()
	return character id 10003
end checkMark

on crossMark()
	return character id 10007
end crossMark

on bullet()
	return character id 8226
end bullet

-- Build the status list showing all apps and their current state
on buildStatusList(appList, appStates, appSizes)
	set statusText to ""
	repeat with i from 1 to count of appList
		set appName to item 1 of (item i of appList)
		set state to item i of appStates
		set sizeText to item i of appSizes

		if state is "done" then
			set statusText to statusText & "  " & my checkMark() & "   " & appName & "     " & sizeText
		else if state is "downloading" then
			set statusText to statusText & "  " & character id 11015 & "   " & appName & "     " & sizeText
		else if state is "resolving" then
			set statusText to statusText & "  " & character id 11015 & "   " & appName & "     " & sizeText
		else if state is "failed" then
			set statusText to statusText & "  " & my crossMark() & "   " & appName & "     " & sizeText
		else
			set statusText to statusText & "  " & character id 9675 & "   " & appName
		end if

		if i < (count of appList) then
			set statusText to statusText & return
		end if
	end repeat
	return statusText
end buildStatusList

-- ============================================================
--  Time and Size Functions
-- ============================================================

-- Estimate remaining time based on elapsed time and completed count
on estimateTime(startTime, completedCount, totalCount)
	if completedCount < 1 then return ""
	set elapsed to (current date) - startTime
	if elapsed < 3 then return ""
	set avgPerApp to elapsed / completedCount
	set remaining to (totalCount - completedCount) * avgPerApp
	if remaining < 5 then return "     Almost done"
	return "     About " & my formatTime(round remaining) & " remaining"
end estimateTime

-- Format seconds to human-readable time
on formatTime(totalSeconds)
	if totalSeconds < 60 then
		return (totalSeconds as integer as text) & "s"
	else if totalSeconds < 3600 then
		set m to totalSeconds div 60
		set s to totalSeconds mod 60
		if s > 0 then
			return (m as text) & "m " & (s as integer as text) & "s"
		else
			return (m as text) & "m"
		end if
	else
		set h to totalSeconds div 3600
		set m to (totalSeconds mod 3600) div 60
		return (h as text) & "h " & (m as text) & "m"
	end if
end formatTime

-- Format bytes to human-readable size
on formatSize(bytes)
	if bytes is greater than or equal to 1.073741824E+9 then
		set sizeNum to (round (bytes / 1.073741824E+9 * 10)) / 10
		return (sizeNum as text) & " GB"
	else if bytes is greater than or equal to 1048576 then
		set sizeNum to (round (bytes / 1048576 * 10)) / 10
		return (sizeNum as text) & " MB"
	else if bytes is greater than or equal to 1024 then
		set sizeNum to (round (bytes / 1024 * 10)) / 10
		return (sizeNum as text) & " KB"
	else
		return (bytes as text) & " bytes"
	end if
end formatSize

-- ============================================================
--  Parsing Functions
-- ============================================================

-- Parse a config line: "Name | File | URL"
on parseLine(theLine)
	set oldDelims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "|"
	try
		set parts to text items of theLine
		if (count of parts) is 3 then
			set appName to my trimText(item 1 of parts)
			set fileName to my trimText(item 2 of parts)
			set downloadURL to my trimText(item 3 of parts)
			set AppleScript's text item delimiters to oldDelims
			return {appName, fileName, downloadURL}
		end if
	end try
	set AppleScript's text item delimiters to oldDelims
	return missing value
end parseLine

-- Trim whitespace from start and end
on trimText(theText)
	if theText is "" then return ""
	set trimmed to do shell script "echo " & quoted form of theText & " | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'"
	return trimmed
end trimText
