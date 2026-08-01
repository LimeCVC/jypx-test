--===================================================================================--
--                             JYPX // V2.0 - BUILD A BOAT FOR TREASURE               --
--===================================================================================--

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

if not isfolder("jypxBuild") then
    makefolder("jypxBuild")
end

--===================================================================================--
-- [ГЛОБАЛЬНЫЕ НАСТРОЙКИ]
--===================================================================================--
_G.Building = false
_G.BuildDelay = 0.05
_G.AutoFarm = false
_G.FarmDuration = 25
_G.NoClip = false
_G.Fly = false
_G.FlySpeed = 50
_G.BHop = false
_G.BhopSpeed = 35
_G.BhopJump = 50
_G.SpeedBoost = false
_G.SpeedAmount = 100

local Cam = Workspace.CurrentCamera
local PreviewModel = nil
local farmRunning = false
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
    print("✅ Постройка сохранена")
end

local function clearPreview()
    if PreviewModel then PreviewModel:Destroy() PreviewModel = nil end
end

local function previewBuild(fileName)
    clearPreview()
    local success, content = pcall(function() return readfile("jypxBuild/" .. fileName .. ".build") end)
    if not success then return end
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
        return 
    end
    local blocksData = HttpService:JSONDecode(content)
    
    local plotFolder = Workspace:FindFirstChild("Plots")
    local playerPlot = plotFolder and plotFolder:FindFirstChild(LocalPlayer.Name)
    
    if not playerPlot then
        _G.Building = false
        return
    end
    
    print("🏗️ Строительство...")
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
-- [МОДУЛЬ 2: АВТОФАРМ]
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
    Vector3.new(-50, 0, 8500),
    Vector3.new(-55, -360, 9500),
}

local function farmLoop()
    while farmRunning and _G.AutoFarm do
        local char = LocalPlayer.Character
        if not char then
            LocalPlayer.CharacterAdded:Wait()
            char = LocalPlayer.Character
            task.wait(1)
        end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            task.wait(0.5)
            continue
        end
        
        for i, stagePos in ipairs(FarmStages) do
            if not farmRunning or not _G.AutoFarm then break end
            
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                break
            end
            
            hrp = LocalPlayer.Character.HumanoidRootPart
            local distance = (hrp.Position - stagePos).Magnitude
            local speed = distance / (_G.FarmDuration / #FarmStages)
            speed = math.max(speed, 10)
            
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            bv.Velocity = (stagePos - hrp.Position).Unit * speed
            bv.Parent = hrp
            
            pcall(function()
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then 
                        part.CanCollide = false 
                    end
                end
            end)
            
            local timeout = 0
            while (hrp.Position - stagePos).Magnitude > 12 and farmRunning and _G.AutoFarm and LocalPlayer.Character do
                pcall(function()
                    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end)
                task.wait(0.05)
                timeout = timeout + 1
                if timeout > 400 then break end
            end
            bv:Destroy()
        end
        
        if farmRunning and _G.AutoFarm then
            task.wait(2.5)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:BreakJoints()
            end
            LocalPlayer.CharacterAdded:Wait()
            task.wait(1.5)
        end
    end
    farmThread = nil
end

local function toggleFarm()
    if _G.AutoFarm then
        _G.AutoFarm = false
        farmRunning = false
        if farmThread then
            task.cancel(farmThread)
            farmThread = nil
        end
        print("⏹️ Фарм ВЫКЛЮЧЕН")
    else
        _G.AutoFarm = true
        farmRunning = true
        if farmThread then
            task.cancel(farmThread)
            farmThread = nil
        end
        farmThread = task.spawn(farmLoop)
        print("🔄 Фарм ВКЛЮЧЕН")
    end
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

-- Speed Boost (работает постоянно пока включен)
RunService.RenderStepped:Connect(function()
    if _G.SpeedBoost and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        hum.WalkSpeed = _G.SpeedAmount
    end
end)

-- BunnyHop
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space and _G.BHop then
        task.spawn(function()
            while UserInputService:IsKeyDown(Enum.KeyCode.Space) and _G.BHop do
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    local hum = LocalPlayer.Character.Humanoid
                    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hum and hrp and hum.FloorMaterial ~= Enum.Material.Air then
                        hrp.Velocity = Vector3.new(hrp.Velocity.X, _G.BhopJump, hrp.Velocity.Z)
                        hum.WalkSpeed = _G.BhopSpeed
                    end
                end
                task.wait(0.02)
            end
        end)
    end
end)

--===================================================================================--
-- [МОДУЛЬ 4: GUI]
--===================================================================================--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JYPX_Hub"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 400)
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Шапка
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "JYPX // V2.0"
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.BackgroundTransparency = 1
TitleLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Левая панель
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 120, 1, -35)
SideBar.Position = UDim2.new(0, 0, 0, 35)
SideBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 6)
SideLayout.Parent = SideBar

-- Контент
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -125, 1, -45)
ContentFrame.Position = UDim2.new(0, 125, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local BuildPage = Instance.new("ScrollingFrame")
BuildPage.Size = UDim2.new(1, 0, 1, 0)
BuildPage.BackgroundTransparency = 1
BuildPage.CanvasSize = UDim2.new(0, 0, 1.5, 0)
BuildPage.Parent = ContentFrame

local BuildLayout = Instance.new("UIListLayout")
BuildLayout.Padding = UDim.new(0, 6)
BuildLayout.Parent = BuildPage

local ExploitsPage = Instance.new("ScrollingFrame")
ExploitsPage.Size = UDim2.new(1, 0, 1, 0)
ExploitsPage.BackgroundTransparency = 1
ExploitsPage.Visible = false
ExploitsPage.CanvasSize = UDim2.new(0, 0, 1.8, 0)
ExploitsPage.Parent = ContentFrame

local ExploitLayout = Instance.new("UIListLayout")
ExploitLayout.Padding = UDim.new(0, 6)
ExploitLayout.Parent = ExploitsPage

-- Функции кнопок
local function createButton(text, parent, callback, color)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = color or Color3.fromRGB(35, 35, 40)
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function createToggleButton(text, parent, getter, setter)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn
    
    local function updateUI()
        local state = getter()
        btn.Text = text .. " [" .. (state and "ON" or "OFF") .. "]"
        btn.BackgroundColor3 = state and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(35, 35, 40)
        btn.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    end
    
    updateUI()
    btn.MouseButton1Click:Connect(function()
        setter(not getter())
        updateUI()
    end)
    return btn
end

-- Кнопки BUILD
createButton("📦 Safe Build", BuildPage, function() safeBuild("myship") end, Color3.fromRGB(30, 40, 60))
createButton("👁️ Preview", BuildPage, function() previewBuild("myship") end, Color3.fromRGB(30, 50, 50))
createButton("🏗️ Build", BuildPage, function() startBuild("myship") end, Color3.fromRGB(30, 60, 40))
createButton("⏹️ Stop Build", BuildPage, function() _G.Building = false clearPreview() end, Color3.fromRGB(60, 30, 30))

-- Кнопки EXPLOITS
createToggleButton("🔄 Auto Farm", ExploitsPage, function() return _G.AutoFarm end, function(v) 
    _G.AutoFarm = v
    if v then
        farmRunning = true
        if farmThread then task.cancel(farmThread) end
        farmThread = task.spawn(farmLoop)
        print("🔄 Фарм ВКЛЮЧЕН")
    else
        farmRunning = false
        if farmThread then 
            task.cancel(farmThread)
            farmThread = nil
        end
        print("⏹️ Фарм ВЫКЛЮЧЕН")
    end
end)

createToggleButton("✈️ Fly", ExploitsPage, function() return _G.Fly end, function(v) 
    _G.Fly = v 
    _G.NoClip = v
end)

createToggleButton("🦘 BunnyHop", ExploitsPage, function() return _G.BHop end, function(v) 
    _G.BHop = v 
end)

createToggleButton("💨 Speed Boost", ExploitsPage, function() return _G.SpeedBoost end, function(v) 
    _G.SpeedBoost = v 
end)

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
            print("🎯 Телепорт к сундуку!")
        end
    end
end, Color3.fromRGB(60, 40, 20))

-- Вкладки
local function createTabButton(text, parent, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

createTabButton("BUILD", SideBar, function() BuildPage.Visible = true ExploitsPage.Visible = false end)
createTabButton("EXPLOITS", SideBar, function() BuildPage.Visible = false ExploitsPage.Visible = true end)

print("✅ JYPX // V2.0 загружен!")
print("🎯 Фарм на -55, -360, 9500")
