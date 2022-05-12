Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10000)
		players = {}
		for _, player in ipairs(GetActivePlayers()) do
			table.insert(players, player)
        end

		SetDiscordAppId(655992314249871400)
		SetDiscordRichPresenceAsset('logo')
        SetRichPresence("Jogadores na cidade: ".. #players)
	end
end)
