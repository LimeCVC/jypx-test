-- ПУСТОЕ GUI ОКНО (SWILL)
local player = game.Players.LocalPlayer

-- СОЗДАЁМ ЭКРАН
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

-- ОСНОВНАЯ ПАНЕЛЬ
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 250)
frame.Position = UDim2.new(0.5, -200, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- ЗАГОЛОВОК (просто текст)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ОКНО"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- ТЕКСТ ПОСЕРЕДИНЕ (просто для вида)
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -40, 1, -100)
label.Position = UDim2.new(0, 20, 0, 60)
label.BackgroundTransparency = 1
label.Text = "Тут ничего нет"
label.TextColor3 = Color3.fromRGB(200, 200, 200)
label.TextScaled = true
label.TextWrapped = true
label.Parent = frame

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

-- КНОПКА ПЕРЕТАСКИВАНИЯ (заголовок можно двигать)
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local dragStart = input.Position
        local startPos = frame.Position
        frame.Dragging = true
        frame.DragStart = dragStart
        frame.StartPos = startPos
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        frame.Dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if frame.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - frame.DragStart
        frame.Position = UDim2.new(
            frame.StartPos.X.Scale,
            frame.StartPos.X.Offset + delta.X,
            frame.StartPos.Y.Scale,
            frame.StartPos.Y.Offset + delta.Y
        )
    end
end)

print("[GUI] Окно открыто")
