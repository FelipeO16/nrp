AddEventHandler('onClientMapStart', function()
	exports.spawnmanager:spawnPlayer()
	exports.spawnmanager:forceRespawn()
end)
