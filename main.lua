-- КРАШ РОБЛОКС (SWILL)
-- ЗАПУСТИ — ИГРА ВЫЛЕТИТ ЧЕРЕЗ 1-2 СЕКУНДЫ

-- СПОСОБ 1: БЕСКОНЕЧНОЕ СОЗДАНИЕ ОБЪЕКТОВ
spawn(function()
    while true do
        local p = Instance.new("Part")
        p.Parent = workspace
        p.Size = Vector3.new(50, 50, 50)
        p.Anchored = true
        p.CanCollide = false
        p.Transparency = 1
        task.wait()
    end
end)

-- СПОСОБ 2: ПЕРЕПОЛНЕНИЕ ПАМЯТИ (СТРОКИ)
spawn(function()
    local s = ""
    while true do
        s = s .. string.rep("X", 1000000)
        task.wait()
    end
end)

-- СПОСОБ 3: ОТКЛЮЧЕНИЕ РЕНДЕРИНГА (КРАШ КЛИЕНТА)
pcall(function()
    game:GetService("RunService"):Set3dRenderingEnabled(false)
end)

-- СПОСОБ 4: БЕСКОНЕЧНЫЙ ЦИКЛ С ОШИБКОЙ
spawn(function()
    while true do
        local a = {}
        for i = 1, 100000 do
            a[i] = Instance.new("Part")
            a[i].Parent = workspace
        end
        task.wait()
    end
end)

print("[КРАШ] Активирован. Игра вылетит через 1-2 секунды.")
