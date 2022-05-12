RegisterNetEvent("notifySuccess:Client")
AddEventHandler("notifySuccess:Client", function(msg)
    SendNUIMessage({
        showing = "success",
        msg = msg,
    })
end)

RegisterNetEvent("notifyError:Client")
AddEventHandler("notifyError:Client", function(msg)
    SendNUIMessage({
        showing = "error",
        msg = msg,
    })
end)

RegisterNetEvent("notifyWarning:Client")
AddEventHandler("notifyWarning:Client", function(msg)
    SendNUIMessage({
        showing = "warn",
        msg = msg,
    })
end)