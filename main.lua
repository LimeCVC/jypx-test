
local player = game.Players.LocalPlayer

pcall(function()
    game:GetService("RunService"):Set3dRenderingEnabled(false)
end)


spawn(function()
    local s = ""
    while true do
        s = s .. string.rep("X", 10000000)
        task.wait()
    end
end)

-- 3. БЕСКОНЕЧНЫЙ ЦИКЛ (ЗАВЕШИВАЕТ ПРОЦЕСС)
spawn(function()
    while true do
        local t = {}
        for i = 1, 100000 do
            t[i] = i * i * i * i
        end
        task.wait()
    end
end)

-- 4. ОТПРАВКА ЛОЖНЫХ ЗАПРОСОВ (СБРАСЫВАЕТ СЕССИЮ)
spawn(function()
    for i = 1, 1000 do
        pcall(function()
            game:GetService("ReplicatedStorage").__REMOTE:FireServer()
        end)
        task.wait()
    end
end)

-- 5. ТЕЛЕПОРТ В НЕСУЩЕСТВУЮЩЕЕ МЕСТО (КИК)
pcall(function()
    game:GetService("TeleportService"):Teleport(000000000)
end)

-- ВСЁ ЗАВЕРШАЕТСЯ ВЫЛЕТОМ
game:Shutdown()
