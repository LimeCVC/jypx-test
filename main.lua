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

spawn(function()
for i = 1, 5000 do
pcall(function()
local remote = game:GetService("ReplicatedStorage"):FindFirstChildOfClass("RemoteEvent")
if remote then
remote:FireServer("spam", i)
end
end)
task.wait()
end
end)

spawn(function()
for i = 1, 50 do
pcall(function()
game:GetService("TeleportService"):Teleport(game.PlaceId)
end)
task.wait(0.1)
end
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

game:Shutdown()
