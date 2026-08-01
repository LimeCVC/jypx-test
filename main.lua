--===================================================================================--
--                             JYPX // V2.0 - BUILD A BOAT FOR TREASURE               --
--===================================================================================--

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Проверка и создание папки для сохранений
if not isfolder("jypxBuild") then
    makefolder("jypxBuild")
end

--===================================================================================--
-- [ГЛОБАЛЬНЫЕ НАСТРОЙКИ]
--===================================================================================--
_G.Building = false
_G.BuildDelay = 0.05
_G.AutoFarm = false
_G.FarmDuration = 35  -- Увеличил для медленного движения
_G.NoClip = false
_G.Fly = false
_G.FlySpeed = 50
_G.BHop = false
_G.BhopSpeed = 35
_G.BhopJump = 50
_G.SpeedBoost = false
_G.SpeedAmount = 100
_G.WallHack = false

local Cam = Workspace.CurrentCamera
local PreviewModel = nil
local isFarming = false
local farmThread = nil

--===================================================================================--
-- [МОДУЛЬ 1: АВТО-БИЛД]
--===================================================================================--

local function sanitizeCFrame(cf) return {cf:GetComponents()} end
local function toCFrame(tbl) return CFrame.new(unpack(tbl)) end
local function sanitizeColor(color) return {color.R, color.G, color.B} end

local function safeBuild(fileName)
    local targetFolder = Workspace:FindFirstChild("jypxBuild") or Workspace:FindFirstChild("Plots")
    if targetFolder and targetFolder:FindFirstChild(LocalPlayer.Name) then
        targetFolder = targetFolder[LocalPlayer.Name]
    end
    if not targetFolder then return end
    
    local blocksData = {}
    for _, block in ipairs(targetFolder:GetDescendants()) do
        if block:IsA("BasePart") then
            pcall(function()
                table.insert(blocksData, {
                    ID = block:GetAttribute("BlockID") or block.Name,
                    Name = block.Name,
                    Position = sanitizeCFrame(block.CFrame),
                    Size = {block.Size.X, block.Size.Y, block.Size.Z},
                    Color = sanitizeColor(block.Color),
                    Transparency = block.Transparency,
                    Anchored = block.Anchored,
                    CanCollide = block.CanCollide
                })
            end)
        end
    end
    writefile("jypxBuild/" .. fileName .. ".build", HttpService:JSONEncode(blocksData))
    print("✅ Постройка сохранена как: " .. fileName)
end

local function clearPreview()
    if PreviewModel then PreviewModel:Destroy() PreviewModel = nil end
end

local function previewBuild(fileName)
    clearPreview()
    local success, content = pcall(function() return readfile("jypxBuild/" .. fileName .. ".build") end)
    if not success then 
        print("❌ Файл не найден: " .. fileName)
        return 
    end
    local blocksData = HttpService:JSONDecode(content)
    PreviewModel = Instance.new("Model")
    PreviewModel.Name = "JYPX_Preview"
    PreviewModel.Parent = Workspace

    local hl = Instance.new("Highlight")
    hl.FillColor = Color3.fromRGB(0, 255, 255)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0.2
    hl.Parent = PreviewModel

    for _, data in ipairs(blocksData) do
        local part = Instance.new("Part")
        part.Size = Vector3.new(unpack(data.Size))
        part.CFrame = toCFrame(data.Position)
        part.Color = Color3.new(unpack(data.Color))
        part.Transparency = 0.5
        part.CanCollide = false
        part.Anchored = true
        part.Parent = PreviewModel
    end
    print("👁️ Предпросмотр загружен")
end

local function startBuild(fileName)
    _G.Building = true
    local success, content = pcall(function() return readfile("jypxBuild/" .. fileName .. ".build") end)
    if not success then 
        _G.Building = false 
        print("❌ Файл не найден")
        return 
    end
    local blocksData = HttpService:JSONDecode(content)
    
    local plotFolder = Workspace:FindFirstChild("Plots")
    local playerPlot = plotFolder and plotFolder:FindFirstChild(LocalPlayer.Name)
    
    if not playerPlot then
        print("❌ Плот игрока не найден")
        _G.Building = false
        return
    end
    
    print("🏗️ Начинаем строительство...")
    for _, data in ipairs(blocksData) do
        if not _G.Building then break end
        pcall(function()
            local part = Instance.new("Part")
            part.Name = data.Name
            part.Size = Vector3.new(unpack(data.Size))
            part.CFrame = toCFrame(data.Position)
            part.Color = Color3.new(unpack(data.Color))
            part.Transparency = data.Transparency or 0
            part.CanCollide = data.CanCollide
            part.Anchored = data.Anchored
            part.Parent = playerPlot
        end)
        task.wait(_G.BuildDelay)
    end
    _G.Building = false
    print("✅ Строительство завершено!")
end

--===================================================================================--
-- [МОДУЛЬ 2: АВТОФАРМ С НОВЫМИ КООРДИНАТАМИ СУНДУКА]
--===================================================================================--
local FarmStages = {
    Vector3.new(-50, 55, 200),
    Vector3.new(-50, 55, 1000),
    Vector3.new(-50, 55, 2000),
    Vector3.new(-50, 55, 3000),
    Vector3.new(-50, 55, 4000),
    Vector3.new(-50, 55, 5000),
    Vector3.new(-50, 55, 6000),
    Vector3.new(-50, 55, 7500),
    Vector3.new(-50, -10, 8500),
    Vector3.new(-55, -360, 9500),  -- НОВЫЕ КООРДИНАТЫ СУНДУКА
}

local function startFarming()
    if farmThread then 
        print("⚠️ Фарм уже запущен")
        return 
    end
    
    print("🔄 Запуск авто-фарма...")
    print("🎯 Цель: сундук на координатах -55, -360, 9500")
    isFarming = true
    
    farmThread = task.spawn(function()
        while _G.AutoFarm and isFarming do
            -- Ждем появления персонажа
            local char = LocalPlayer.Character
            if not char then
                print("⏳ Ожидание появления персонажа...")
                LocalPlayer.CharacterAdded:Wait()
                char = LocalPlayer.Character
                task.wait(1.5)
            end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then
                task.wait(0.5)
                continue
            end
            
            print("🚀 Начинаем прохождение этапов...")
            
            -- Проходим все точки
            for i, stagePos in ipairs(FarmStages) do
                if not _G.AutoFarm or not isFarming then 
                    print("⏹️ Фарм остановлен")
                    break 
                end
                
                -- Проверяем, жив ли персонаж
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    print("💀 Персонаж умер, перезапускаем...")
                    break
                end
                
                hrp = LocalPlayer.Character.HumanoidRootPart
                local distance = (hrp.Position - stagePos).Magnitude
                
                -- Уменьшаем скорость для более плавного движения
                local speed = math.max(distance / (_G.FarmDuration / #FarmStages), 8)
                speed = math.min(speed, 25) -- Ограничиваем максимальную скорость
                
                -- Создаем BodyVelocity для движения
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                bv.Velocity = (stagePos - hrp.Position).Unit * speed
                bv.Parent = hrp
                
                -- Включаем NoClip во время движения
                pcall(function()
                    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then 
                            part.CanCollide = false 
                        end
                    end
                end)
                
                -- Ждем достижения точки
                local timeout = 0
                while (hrp.Position - stagePos).Magnitude > 15 and _G.AutoFarm and isFarming and LocalPlayer.Character do
                    pcall(function()
                        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
                    end)
                    task.wait(0.05)
                    timeout = timeout + 1
                    if timeout > 400 then 
                        print("⚠️ Таймаут на точке " .. i)
                        break 
                    end
                end
                bv:Destroy()
                
                -- Небольшая задержка между точками
                task.wait(0.1)
            end
            
            -- Достигли сундука
            if _G.AutoFarm and isFarming then
                print("🎁 Достигли сундука! Ожидаем награду...")
                task.wait(3)
                
                -- Убиваем персонажа для перерождения
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    print("💀 Перерождение...")
                    LocalPlayer.Character.Humanoid:BreakJoints()
                end
                
                -- Ждем перерождения
                LocalPlayer.CharacterAdded:Wait()
                print("🔄 Персонаж переродился, начинаем заново...")
                task.wait(1.5)
            end
        end
        isFarming = false
        farmThread = nil
        print("⏹️ Фарм полностью остановлен")
    end)
end

local function stopFarming()
    print("⏹️ Остановка фарма...")
    isFarming = false
    if farmThread then
        task.cancel(farmThread)
        farmThread = nil
    end
    _G.AutoFarm = false
end

--===================================================================================--
-- [МОДУЛЬ 3: ЧИТЫ]
--===================================================================================--

-- NoClip / Fly
RunService.Stepped:Connect(function()
    if (_G.NoClip or _G.Fly) and LocalPlayer.Character then
        pcall(function()
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then 
                    part.CanCollide = false 
                end
            end
        end)
    end
end)

-- Fly
RunService.RenderStepped:Connect(function()
    if _G.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local cf = Cam.CFrame
        local move = Vector3.zero
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
        
        if move.Magnitude > 0 then
            hrp.Velocity = move.Unit * _G.FlySpeed
        else
            hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
        end
    end
end)

-- Speed Boost (исправлен - теперь не выключается)
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.SpeedBoost and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local hum = LocalPlayer.Character.Humanoid
            if hum.WalkSpeed ~= _G.SpeedAmount then
                hum.WalkSpeed = _G.SpeedAmount
            end
        end
    end
end)

-- BunnyHop
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if _G.BHop and input.KeyCode == Enum.KeyCode.Space then
        task.spawn(function()
            while UserInputService:IsKeyDown(Enum.KeyCode.Space) and _G.BHop do
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    local hum = LocalPlayer.Character.Humanoid
                    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hum and hrp then
                        if hum.FloorMaterial ~= Enum.Material.Air then
                            hrp.Velocity = Vector3.new(hrp.Velocity.X, _G.BhopJump, hrp.Velocity.Z)
                            hum.WalkSpeed = _G.BhopSpeed
                        end
                    end
                end
                task.wait(0.02)
            end
        end)
    end
end)

-- Wall Hack
if _G.WallHack then
    RunService.RenderStepped:Connect(function()
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("Part") and part.Transparency < 0.5 then
                part.Transparency = 0.3
            end
        end
    end)
end

--===================================================================================--
-- [МОДУЛЬ 4: GUI ИНТЕРФЕЙС]
--===================================================================================--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JYPX_Hub_V20"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Главный фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 450)
MainFrame.Position = UDim2.new(0.3, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Шапка (БЕЛОЕ НАЗВАНИЕ, без Build a Boat)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "JYPX // V2.0"
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- БЕЛЫЙ
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.BackgroundTransparency = 1
TitleLabel.Parent = TitleBar

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 2)
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Кнопка свернуть
local CollapseBtn = Instance.new("TextButton")
CollapseBtn.Text = "−"
CollapseBtn.Size = UDim2.new(0, 35, 0, 35)
CollapseBtn.Position = UDim2.new(1, -75, 0, 2)
CollapseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CollapseBtn.BackgroundTransparency = 1
CollapseBtn.Font = Enum.Font.GothamBold
CollapseBtn.TextSize = 22
CollapseBtn.Parent = TitleBar

-- Левая панель
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 130, 1, -40)
SideBar.Position = UDim2.new(0, 0, 0, 40)
SideBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 6)
SideCorner.Parent = SideBar

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 8)
SideLayout.Parent = SideBar

-- Контейнер контента
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -135, 1, -50)
ContentFrame.Position = UDim2.new(0, 135, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Создание страниц
local BuildPage = Instance.new("ScrollingFrame")
BuildPage.Size = UDim2.new(1, 0, 1, 0)
BuildPage.BackgroundTransparency = 1
BuildPage.CanvasSize = UDim2.new(0, 0, 1.5, 0)
BuildPage.Parent = ContentFrame

local BuildLayout = Instance.new("UIListLayout")
BuildLayout.Padding = UDim.new(0, 8)
BuildLayout.Parent = BuildPage

local ExploitsPage = Instance.new("ScrollingFrame")
ExploitsPage.Size = UDim2.new(1, 0, 1, 0)
ExploitsPage.BackgroundTransparency = 1
ExploitsPage.Visible = false
ExploitsPage.CanvasSize = UDim2.new(0, 0, 1.8, 0)
ExploitsPage.Parent = ContentFrame

local ExploitLayout = Instance.new("UIListLayout")
ExploitLayout.Padding = UDim.new(0, 8)
ExploitLayout.Parent = ExploitsPage

-- Функции создания кнопок
local function createButton(text, parent, callback, color)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(1, -10, 0, 38)
    btn.BackgroundColor3 = color or Color3.fromRGB(35, 35, 40)
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function createToggleButton(text, parent, getter, setter)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 38)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    local function updateUI()
        local state = getter()
        btn.Text = text .. "  [" .. (state and "✅ ON" or "❌ OFF") .. "]"
        btn.BackgroundColor3 = state and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(40, 35, 35)
        btn.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    end
    
    updateUI()
    btn.MouseButton1Click:Connect(function()
        local newState = not getter()
        setter(newState)
        updateUI()
        
        -- Специальная обработка для AutoFarm
        if text:find("Auto Farm") then
            if newState then
                startFarming()
            else
                stopFarming()
            end
        end
    end)
    
    return btn
end

-- Кнопки вкладки BUILD
createButton("📦 Safe Build (Сохранить)", BuildPage, function() 
    safeBuild("myship") 
end, Color3.fromRGB(30, 40, 60))

createButton("👁️ Preview (Предпросмотр)", BuildPage, function() 
    previewBuild("myship") 
end, Color3.fromRGB(30, 50, 50))

createButton("🏗️ Build (Начать постройку)", BuildPage, function() 
    startBuild("myship") 
end, Color3.fromRGB(30, 60, 40))

createButton("⏹️ Stop Build (Остановить)", BuildPage, function() 
    _G.Building = false 
    clearPreview() 
    print("⏹️ Строительство остановлено")
end, Color3.fromRGB(60, 30, 30))

-- Кнопки вкладки EXPLOITS
createToggleButton("🔄 Auto Farm", ExploitsPage, 
    function() return _G.AutoFarm end, 
    function(v) _G.AutoFarm = v end
)

createToggleButton("✈️ Fly + NoClip", ExploitsPage, 
    function() return _G.Fly end, 
    function(v) _G.Fly = v _G.NoClip = v end
)

createToggleButton("🦘 BunnyHop", ExploitsPage, 
    function() return _G.BHop end, 
    function(v) _G.BHop = v end
)

createToggleButton("💨 Speed Boost", ExploitsPage, 
    function() return _G.SpeedBoost end, 
    function(v) _G.SpeedBoost = v end
)

createButton("🎯 Teleport to Chest", ExploitsPage, function()
    local chest = nil
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") and (obj.Name:find("Chest") or obj.Name:find("Treasure")) then
            chest = obj
            break
        end
    end
    
    if chest and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = chest.CFrame + Vector3.new(0, 5, 0)
            print("🎯 Телепортированы к сундуку!")
        end
    else
        print("❌ Сундук не найден!")
    end
end, Color3.fromRGB(60, 40, 20))

-- Кнопки вкладок
local function createTabButton(text, parent, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

createTabButton("🏗️ BUILD", SideBar, function() 
    BuildPage.Visible = true 
    ExploitsPage.Visible = false 
end)

createTabButton("⚡ EXPLOITS", SideBar, function() 
    BuildPage.Visible = false 
    ExploitsPage.Visible = true 
end)

-- Логика сворачивания
local isCollapsed = false
local originalHeight = 450

CollapseBtn.MouseButton1Click:Connect(function()
    isCollapsed = not isCollapsed
    if isCollapsed then
        originalHeight = MainFrame.Size.Y.Offset
        MainFrame:TweenSize(UDim2.new(0, MainFrame.Size.X.Offset, 0, 40), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
        SideBar.Visible = false
        ContentFrame.Visible = false
        CollapseBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, MainFrame.Size.X.Offset, 0, originalHeight), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
        task.wait(0.1)
        SideBar.Visible = true
        ContentFrame.Visible = true
        CollapseBtn.Text = "−"
    end
end)

print("✅ JYPX // V2.0 успешно загружен!")
print("🎯 Фарм настроен на сундук: -55, -360, 9500")
print("📌 Используйте GUI для управления")
