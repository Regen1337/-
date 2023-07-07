--[==[
	Description:
		Here is the overhead for the new plugin that replicates the functionality of the existing code while improving it. The plugin is intended to handle file downloads and caching, and it should be compatible with Garry's Mod (GLua).

		This is for a Helix Shema Plugin.

		Functionality Overview:
		1. The plugin will allow downloading files from URLs and storing them in a specified location.
		2. It will have a caching mechanism to prevent unnecessary downloads.
		3. The plugin should support queuing multiple downloads simultaneously.
		4. The code will include a PlayURL function to play audio files directly from URLs.
		5. It should provide a method to download Garry's Mod workshop files using their IDs.

		Goals:
		1. Modular and organized code structure for easy maintenance and readability.
		2. Efficient error handling and logging to track any issues.
		3. Proper use of Garry's Mod-specific functions for better integration.

		Instructions for Implementation:
		1. Design the core functionality of the plugin using Lua.
		2. Implement separate functions to download files from URLs and handle caching.
		3. Create a queuing system to manage multiple downloads concurrently.
		4. Develop a PlayURL function to play audio files from URLs.
		5. Add a function to download Garry's Mod workshop files using their IDs.
		6. Use the http.Fetch function for file downloads and handle errors properly.
		7. Utilize Garry's Mod-specific functions, like game.MountGMA, for workshop file handling.
		8. Organize the code into reusable modules or classes for easy maintenance.
		9. Implement logging to track download status and any potential errors.
		10. Handle edge cases and potential errors gracefully.

		Considerations:
		1. Optimize the download and caching mechanism for performance.
		2. Support various file types (e.g., txt, jpg, png, json) and extensions.
		3. Ensure security measures against malicious URLs and user input.
		4. Provide clear and detailed documentation for users to understand the plugin's usage and functionality.

		Optional Improvements:
		1. Implement a progress bar or status updates during downloads.
		2. Include an option to cancel ongoing downloads.
		3. Support HTTPS URLs for secure downloads.

		Remember to test the plugin thoroughly and handle different scenarios before release. Good luck with your new plugin development!
		Remember to be as logical and efficient as possible.
]==]

do return end -- disable plugin

local PLUGIN = PLUGIN

PLUGIN.name = "File Downloader"
PLUGIN.author = "regen"
PLUGIN.description = "A plugin to download files from URLs and cache them."

PLUGIN.queuedDownloads = PLUGIN.queuedDownloads or {}
PLUGIN.cachedFiles = PLUGIN.cachedFiles or {}
PLUGIN.nextDownload = PLUGIN.nextDownload or 0
PLUGIN.isReady = PLUGIN.isReady or false

-- A function to add a file to the download queue.
function PLUGIN:AddToQueue(url, path, callback)
	if (!url or !path) then
		return
	end

	local download = {
		url = url,
		path = path,
		callback = callback
	}

	table.insert(self.queuedDownloads, download)
end

-- A function to download a file from a URL.
function PLUGIN:DownloadFile(url, path, callback)
	if (!url or !path) then
		return
	end

	-- Check if the file is already cached.
	if (self.cachedFiles[url]) then
		callback(self.cachedFiles[url])

		return
	end

	-- Check if the file already exists.
	if (file.Exists(path, "DATA")) then
		self.cachedFiles[url] = path

		callback(path)

		return
	end

	-- Add the file to the download queue.
	self:AddToQueue(url, path, callback)
end

function PLUGIN:DownloadFileFromQueue(download)
	if (!download) then
		return
	end

	local url = download.url
	local path = download.path
	local callback = download.callback

	-- Check if the file is already cached.
	if (self.cachedFiles[url]) then
		callback(self.cachedFiles[url])

		return
	end

	-- Check if the file already exists.
	if (file.Exists(path, "DATA")) then
		self.cachedFiles[url] = path

		callback(path)

		return
	end

	-- Download the file from the URL.
	http.Fetch(url, function(body, length, headers, code)
		if (code == 200) then
			-- Create the directories for the file.
			file.CreateDir(string.GetPathFromFilename(path))

			-- Write the file to the data folder.
			file.Write(path, body)

			-- Cache the file.
			self.cachedFiles[url] = path

			-- Call the callback with the file path.
			callback(path)
		else
			-- Call the callback with the error.
			callback(code)
		end
	end, function(error)
		-- Call the callback with the error.
		callback(error)
	end)
end

function PLUGIN:InitPostEntity()
	timer.Simple(5, function()
		self.isReady = true
		self.nextDownload = CurTime() + 1
	end)
end

function PLUGIN:Think()
	if (!self.isReady or CurTime() < self.nextDownload) then return end

	if (#self.queuedDownloads > 0) then
		local download = table.remove(self.queuedDownloads, 1)

		self:DownloadFileFromQueue(download)
	end
end

-- A function to download a file from a URL and play it.
function PLUGIN:PlayURL(url)
	if (!url) then
		return
	end

	-- Check if the file is already cached.
	if (self.cachedFiles[url]) then
		sound.PlayFile(self.cachedFiles[url], "noplay", function(station, errorID, errorName)
			if (IsValid(station)) then
				station:Play()
			else
				ErrorNoHalt("["..PLUGIN.name.."] Failed to play sound file: "..errorID.." ("..errorName..")\n")
			end
		end)

		return
	end

	-- Check if the file already exists.
	if (file.Exists(path, "DATA")) then
		self.cachedFiles[url] = path

		sound.PlayFile(path, "noplay", function(station, errorID, errorName)
			if (IsValid(station)) then
				station:Play()
			else
				ErrorNoHalt("["..PLUGIN.name.."] Failed to play sound file: "..errorID.." ("..errorName..")\n")
			end
		end)

		return
	end

	-- Add the file to the download queue.
	self:AddToQueue(url, path, function(path)
		sound.PlayFile(path, "noplay", function(station, errorID, errorName)
			if (IsValid(station)) then
				station:Play()
			else
				ErrorNoHalt("["..PLUGIN.name.."] Failed to play sound file: "..errorID.." ("..errorName..")\n")
			end
		end)
	end)
end



-- A function to download a file from a URL and mount it.
function PLUGIN:MountURL(url)
	if (!url) then
		return
	end

	-- Check if the file is already cached.
	if (self.cachedFiles[url]) then
		game.MountGMA(self.cachedFiles[url])

		return
	end

	-- Check if the file already exists.
	if (file.Exists(path, "DATA")) then
		self.cachedFiles[url] = path

		game.MountGMA(path)

		return
	end

	-- Add the file to the download queue.
	self:AddToQueue(url, path, function(path)
		game.MountGMA(path)
	end)
end

function PLUGIN:MountWorkshop(id)
	if (!id) then return end

	steamworks.FileInfo(id, function(out)
		steamworks.Download(out.fileid, true, function(path)
			game.MountGMA(path)
		end)
	end)
end
