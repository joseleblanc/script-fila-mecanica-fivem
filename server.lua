local Tunnel = module("vrp", "lib/Tunnel")
local Proxy  = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

-- Verificação de permissão do mecânico
RegisterNetEvent("mechanic:checkPermission")
AddEventHandler("mechanic:checkPermission", function()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local hasPerm = vRP.hasPermission(user_id, "mecanico.permissao")
        TriggerClientEvent("mechanic:checkPermissionResult", source, hasPerm)
    else
        TriggerClientEvent("mechanic:checkPermissionResult", source, false)
    end
end)

-- Sistema de fila
local filaAtual = 0
local filaClientes = {}

RegisterNetEvent("fila:entrarComando")
AddEventHandler("fila:entrarComando", function()
    local src = source
    if not filaClientes[src] then
        filaAtual = filaAtual + 1
        filaClientes[src] = filaAtual
        TriggerClientEvent("fila:updateNumero", -1, filaAtual)
        TriggerClientEvent("chat:addMessage", src, {
            color = {0,255,0},
            multiline = true,
            args = {"Sistema", "Você entrou na fila. Sua senha é: " .. filaAtual}
        })
    else
        TriggerClientEvent("chat:addMessage", src, {
            color = {255,255,0},
            args = {"Sistema", "Você já está na fila com a senha: " .. filaClientes[src]}
        })
    end
end)

RegisterNetEvent("fila:chamarClienteBox")
AddEventHandler("fila:chamarClienteBox", function(box)
    local src = source
    local menorSenha = nil
    local clienteChamar = nil

    for cliente, senha in pairs(filaClientes) do
        if not menorSenha or senha < menorSenha then
            menorSenha = senha
            clienteChamar = cliente
        end
    end

    if clienteChamar then
        TriggerClientEvent("fila:notificacaoCliente", clienteChamar, box)
        filaClientes[clienteChamar] = nil
        print("Cliente "..clienteChamar.." chamado para box "..box)
    else
        TriggerClientEvent("chat:addMessage", src, {
            color = {255,0,0},
            args = {"Sistema", "Não há clientes na fila no momento."}
        })
    end
end)
