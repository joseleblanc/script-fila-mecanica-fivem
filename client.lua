local currentNumber = nil
local filaCoords = vector3(-930.58, -2057.72, 9.74)
local isMecanico = false

local pontosMecanico = {
    { coords = vector3(-936.05, -2062.41, 9.74), box = 1 },
    { coords = vector3(-941.03, -2067.28, 9.74), box = 2 },
    { coords = vector3(-948.1,  -2046.14, 9.74), box = 3 },
    { coords = vector3(-944.91, -2036.92, 9.74), box = 4 },
    { coords = vector3(-933.83, -2025.7, 9.74), box = 5 },
    { coords = vector3(-923.6, -2015.68, 9.74), box = 6 },
    { coords = vector3(-903.04, -2029.66, 9.74), box = 7 },
    { coords = vector3(-908.47, -2034.98, 9.74), box = 8 },
}

RegisterNetEvent("mechanic:checkPermissionResult")
AddEventHandler("mechanic:checkPermissionResult", function(status)
    isMecanico = status
end)

Citizen.CreateThread(function()
    TriggerServerEvent("mechanic:checkPermission")
end)

RegisterNetEvent("fila:updateNumero")
AddEventHandler("fila:updateNumero", function(numero)
    currentNumber = numero
end)

RegisterNetEvent("fila:notificacaoCliente")
AddEventHandler("fila:notificacaoCliente", function(box)
    SetNotificationTextEntry("STRING")
    AddTextComponentString("O mecânico irá atendê-lo, dirija-se ao box ~g~" .. box)
    DrawNotification(false, false)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        if currentNumber then
            local distance = #(playerCoords - vector3(filaCoords.x, filaCoords.y, filaCoords.z))
            if distance <= 2.0 then
                DrawText3D(filaCoords.x, filaCoords.y, filaCoords.z, "Senha atual: ~g~" .. currentNumber)
            end
        end
    end
end)

-- Detectar jogador perto do ponto da fila
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local dist = #(coords - filaCoords)

        if dist < 10.0 then
            sleep = 1
            DrawMarker(1, filaCoords.x, filaCoords.y, filaCoords.z - 1.0,
                0, 0, 0, 0, 0, 0,
                0.3, 0.3, 0.3,
                255, 0, 0, 200,
                false, true, 2, nil, nil, false)

            if dist < 1.5 then
                DrawText3D(filaCoords.x, filaCoords.y, filaCoords.z + 0.3, "[E] Entrar na fila de atendimento")
                if IsControlJustPressed(0, 38) then
                    TriggerServerEvent("fila:entrarComando")
                end
            end
        end

        Citizen.Wait(sleep)
    end
end)

-- Detectar mecânico perto dos boxes para chamar cliente
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for _, ponto in pairs(pontosMecanico) do
            local dist = #(coords - ponto.coords)
            if dist < 10.0 and isMecanico then
                sleep = 1
                DrawMarker(1, ponto.coords.x, ponto.coords.y, ponto.coords.z - 1.0,
                    0, 0, 0, 0, 0, 0,
                    0.4, 0.4, 0.4,
                    0, 255, 0, 150,
                    false, true, 2, nil, nil, false)

                if dist < 1.5 then
                    DrawText3D(ponto.coords.x, ponto.coords.y, ponto.coords.z + 0.3, "[E] Chamar cliente para o box " .. ponto.box)
                    if IsControlJustPressed(0, 38) then
                        TriggerServerEvent("fila:chamarClienteBox", ponto.box)
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end
