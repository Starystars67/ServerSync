-- ======================================
      -- Written By : Titch2000
      -- Free to use and edit but 
	  -- please give credit
-- ======================================
_VERSION = '1.0.0'

-- version check
PerformHttpRequest("https://raw.githubusercontent.com/Starystars67/Sync/master/Sync/version.txt", function(err, rText, headers)
	print("\n[YT-SYNC]")
	print("Current version: " .. _VERSION)
	print("Updated version: " .. rText)
	--print("  Admins loaded: " .. adminAmount .. "\n")
	
	if rText ~= _VERSION then
		--print("\nYou do not seem to be using the latest version of YT:Sync. Please update\n")
	else
		print("Everything is up-to-date!\n")
	end
end, "GET", "", {what = 'this'})

-- VARIABLES
secondsToWait = 600              -- Seconds to wait between changing weather. 60 seconds to fully switch types
currentWeatherString = "CLEAR"   -- Starting Weather Type.

-- OBJECTS
weatherTree = {
	["EXTRASUNNY"] = {"CLEAR","SMOG"},
	["SMOG"] = {"FOGGY","CLEAR","CLEARING","OVERCAST","CLOUDS","EXTRASUNNY"},
	["CLEAR"] = {"CLOUDS","EXTRASUNNY","CLEARING","SMOG","FOGGY","OVERCAST"},
	["CLOUDS"] = {"CLEAR","SMOG","FOGGY","CLEARING","OVERCAST","SNOW","SNOWLIGHT"},
	["FOGGY"] = {"CLEAR","CLOUDS","SMOG","OVERCAST"},
	["OVERCAST"] = {"CLEAR","CLOUDS","SMOG","FOGGY","RAIN","CLEARING"},
	["RAIN"] = {"THUNDER","CLEARING","SNOW","SNOWLIGHT","OVERCAST"},
	["THUNDER"] = {"RAIN","CLEARING","BLIZZARD"},
	["CLEARING"] = {"CLEAR","CLOUDS","OVERCAST","FOGGY","SMOG","RAIN","SNOWLIGHT"},
	["SNOW"] = {"BLIZZARD","RAIN","SNOWLIGHT"},
	["BLIZZARD"] = {"SNOW","SNOWLIGHT","THUNDER"},
	["SNOWLIGHT"] = {"SNOW","RAIN","CLEARING"},
}

windWeathers = {
	["OVERCAST"] = true,
	["RAIN"] = true,
	["THUNDER"] = true,
	["BLIZZARD"] = true,
	["XMAS"] = true,
	["SNOW"] = true,
	["CLOUDS"] = true
}

currentWeatherData = {
	["weatherString"] = currentWeatherString,
	["windEnabled"] = false,
	["windHeading"] = 0
}

currentTimeData = {
	["timeHour"] = 1,
	["timeMinute"] = 1
}

-- FUNCTIONS
function stringsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

function getTableLength(T)
	local count = 0
	for _ in pairs(T) do 
		count = count + 1
	end
	return count
end

function getTableKeys(T)
	local keys = {}
	for k,v in pairs(T) do
		table.insert(keys,k)
	end
	return keys
end

function stringsplit(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t,str)
    end
    return t
end

function updateWeatherString()
	local newWeatherString
	local windEnabled = false
	local windHeading = 0
	-- Lua random requires an updated randomseed to ensure randomnees between same range values.
	math.randomseed(GetGameTimer())

	local count = getTableLength(weatherTree)
	local tableKeys = getTableKeys(weatherTree)

	if(currentWeatherData["weatherString"] == nil)then
		newWeatherString = tableKeys[math.random(1,count)]
	else
		local currentOptions = weatherTree[currentWeatherData["weatherString"]]
		newWeatherString = currentOptions[math.random(1,getTableLength(currentOptions))]
	end

	-- 50/50 Chance to enabled wind at a random heading for the specified weathers.
	if(windWeathers[newWeatherString] and (math.random(0,1) == 1))then
		windEnabled = true
		windHeading = math.random(0,360)
	end

	currentWeatherData = {
		["weatherString"] = newWeatherString,
		["windEnabled"] = windEnabled,
		["windHeading"] = windHeading
	}

	print("Updating Weather to "..newWeatherString.." for all players.")
	TriggerClientEvent("yt:updateWeather", -1, currentWeatherData)
end

function updateTime()

	currentTimeData = {
		["timeHour"] = currentTimeData["timeHour"],
		["timeMinute"] = currentTimeData["timeMinute"] + 1
	}
	if currentTimeData["timeMinute"] == 56 then 
		currentTimeData["timeMinute"] = 0
		currentTimeData["timeHour"] = currentTimeData["timeHour"] + 1
		if currentTimeData["timeHour"] == 13 then
			currentTimeData["timeHour"] = 0
		end
	end
	TriggerClientEvent("yt:updateTime", -1, currentTimeData)
end

-- EVENTS
-- Sync Weather once player joins.
RegisterServerEvent("yt:syncWeather")
AddEventHandler("yt:syncWeather",function()
	print("Syncing weather for: "..GetPlayerName(source))
	TriggerClientEvent("yt:updateWeather", source, currentWeatherData)
end)

-- Sync Time once player joins.
RegisterServerEvent("yt:syncTime")
AddEventHandler("yt:syncTime",function()
	print("Syncing time for: "..GetPlayerName(source))
	TriggerClientEvent("yt:updateTime", source, currentTimeData)
end)

-- Wait before updating the weather.
CreateThread(function()
	while true do
		-- Every 7 minutes update the weather type.
		-- Wait(420000)

		Wait(secondsToWait * 1000)
		if(weatherEnabled)then
			updateWeatherString()
		else
			print("yt is currently disabled.")
		end
	end
end)

-- Loop to update game time on server for new players.
CreateThread(function()
	while true do
		-- 2 Seconds = 1 GTA V Minute
		Wait(2000)
		updateTime()
	end
end)