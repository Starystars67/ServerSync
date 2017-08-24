-- ======================================
      -- Written By : Titch2000
      -- Free to use and edit but 
	  -- please give credit
-- ======================================

-- Change Weather Type
function changeWeatherType(type)
	ClearWeatherTypePersist() -- Ensure no persistant weather
	--SetOverrideWeather(type)
	SetWeatherTypeOverTime(type, 60.00)
end

-- Update players wind
function updateWind(toggle,heading)
	if(toggle) then
		SetWind(1.0)
		SetWindSpeed(11.99);
		SetWindDirection(heading)
	else
		SetWind(0.0)
		SetWindSpeed(0.0);
	end
end

-- Sync on player connect
AddEventHandler('onClientMapStart', function()	
	Citizen.Trace("Running V1.0 of [YT-SYNC:Weather] created by Titch2000")
	Citizen.Trace("Running V1.0 of [YT-SYNC:Time] created by Titch2000")
	TriggerServerEvent('yt:syncWeather')
	TriggerServerEvent('yt:syncTime')
	Citizen.Trace("Synced Weather with server.")
	Citizen.Trace("Synced Time with server.")
end)

-- Sync weather with server settings.
RegisterNetEvent('yt:updateWeather')
AddEventHandler('yt:updateWeather', function(data)
	changeWeatherType(data["weatherString"])
	updateWind(data["windEnabled"],data["windHeading"])
end)

-- Sync time with server settings.
RegisterNetEvent('yt:updateTime')
AddEventHandler('yt:updateTime', function(data)
	--SetClockTime(data["timeHour"],data["timeMinute"],data["timeSecond"])
	AdvanceClockTimeTo(data["timeHour"],data["timeMinute"],data["timeSecond"])
end)

