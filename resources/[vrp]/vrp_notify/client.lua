RegisterNetEvent("Notify")
AddEventHandler("Notify",function(css,mensagem)
	SendNUIMessage({ css = css, mensagem = mensagem, time = 7000 })
end)

RegisterNetEvent("NotifyAdm")
AddEventHandler("NotifyAdm",function(nomeadm,mensagem)
	SendNUIMessage({ css = "negado", mensagem = "<font color=\"red\">ADMIN<font color=\"white\"><br>"..mensagem.."</br>", time = 20000 })
end)

RegisterNetEvent("NotifyAviso")
AddEventHandler("NotifyAviso",function(mensagem)
	SendNUIMessage({ css = "negado", mensagem = "<font color=\"#ffae00\">Alerta<font color=\"white\"><br>"..mensagem.."</br>", time = 7000 })
end)
RegisterNetEvent("NotifyPolicia")
AddEventHandler("NotifyPolicia",function(mensagem)
	SendNUIMessage({ css = "importante", mensagem = "<p style='color:#009dff'>Policia<br><b>"..mensagem.."</b></br>", time = 7000 })
end)
RegisterNetEvent("NotifySangramento")
AddEventHandler("NotifySangramento",function(mensagem)
	SendNUIMessage({ css = "sangramento", mensagem = "<p style='color:#ff0000'>Sangramento<br><b>"..mensagem.."</b></br>", time = 7000 })
end)
RegisterNetEvent("NotifySucesso")
AddEventHandler("NotifySucesso",function(mensagem)
	SendNUIMessage({ css = "sucesso", mensagem = "<font color=\"#00b894\">Sucesso<font color=\"white\"><br>"..mensagem.."</br>", time = 7000 })
end)

RegisterNetEvent("NotifyAdmCallback")
AddEventHandler("NotifyAdmCallback",function(nomeadm,mensagem)
	SendNUIMessage({ css = "aviso", mensagem = "<b>"..mensagem.."</b><br>- Privada de "..nomeadm, time = 20000 })
end)
