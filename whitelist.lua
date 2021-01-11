-- Created by Flagship - 𝕕𝕖𝕧#1001 and Kirta#9173  for their server LeyendasRP || https://discord.gg/wwbxcC8Qp4


-- Maximum attempts for players
local attempts = 2  -- How many attempts

--[[
	When player connects to server:
		- Checks whitelist, if the steam ID is on the whitelist array, let him in.
		- If he is not on the whitelist, check if the IP has more than the variable "attemps", if attempts > Nº IPs, then let him in.
		- If he is not whitelisted, and he connected more than "attempts", drop from the server.
]]
AddEventHandler("playerConnecting", function(playerName, setKickReason, deferrals)

	--  Array Whitelist
	local whitelistArray = {}

	--  Read whitelist.txt
	local data = LoadResourceFile(GetCurrentResourceName(), "whitelist.txt")

	-- If there are new steamids on the .txt, add them to the array.
	if data then
		for s in string.gmatch(data,"[^\r\n]+") do
			table.insert(whitelistArray, s)
		end
    	print("Loaded " .. #whitelistArray .. " whitelisted identifiers")
	end

	--  Same to ips.log
	local ipArray = {}

	local dataIp = LoadResourceFile(GetCurrentResourceName(), "ips.log")

	if dataIp then
		for s in string.gmatch(dataIp, "[^\r\n]+") do
			table.insert(ipArray, s)
		end
		print("Loaded " .. #ipArray .. "IPs")
	end
	
    --  Stop conection to check the stuff
	deferrals.defer()
	
	-- Save source.
	local s = source
	
	-- Boolean to join or not
	local joined = false
	

	-- Say to the user, that we are checking whitelist
    deferrals.update("👽 Wait, we are checking the whitelist -- Discord = https://discord.gg/wwbxcC8Qp4👽")
	
	-- Necessary
	Wait(100)
	
	-- Variables
	local totalInWhitelist = #whitelistArray 
	local noIdentifiers = #GetPlayerIdentifiers(s) 
	local currentId = 0 
	local totalChecksNeeded = totalInWhitelist * noIdentifiers 
	local ipcount = 0


	-- Get player identifiers
    for myIdx,identifier in pairs(GetPlayerIdentifiers(s)) do
	

		-- Checks steam IDs
        for wIdx,i in ipairs(whitelistArray) do
			

			-- Check if the steam ID is on the whitelist
            if(string.lower(i) == string.lower(identifier))then
                deferrals.done() -- Dejarles conectar
				joined = true 

				break -- Stop loop
			end

			-- Say to user the % of checking
			deferrals.update(string.format("🍸 Checking whitelist: %.2f%% --  Discord! https://discord.gg/prqmx8P🍸", (currentId / totalChecksNeeded)*100))

			Wait(1)
			currentId = currentId +1
		end

	end
	

	-- If he is not whitelist, then:
	if(joined == false)then
	
		-- Get his IP
		local ipv4 = GetPlayerEndpoint(s)

	-- Check the number of connections with that IP
		for k,j in ipairs(ipArray) do
		
			if(string.lower(j) == string.lower(ipv4))then
				ipcount = ipcount + 1
			end
		end					
	end	
	
	-- Stop resource if he is already joined
	if joined then
		return
	-- Not whitelist + More than "attempts" then:
	elseif((joined == false) and (ipcount>=attempts))then
		deferrals.done("🌙 You have finished the trial period! -- https://discord.gg/prqmx8P🌙")

	-- No whitelist, but he is already on trial period:
	else
	-- Save his IP on logs
		local file = LoadResourceFile(GetCurrentResourceName(), "ips.log")
		SaveResourceFile(GetCurrentResourceName(), "ips.log", file  .. GetPlayerEndpoint(s) .. "\n", -1)
	-- Let them in
		deferrals.done()
	end
end)