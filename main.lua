-- СОЗДАНИЕ ПАПОК НА РАБОЧЕМ СТОЛЕ (XENO)
local desktop = os.getenv("USERPROFILE") .. "\\Desktop\\"

for i = 1, 500 do
    local folderPath = desktop .. "XENO_" .. i
    os.execute('mkdir "' .. folderPath .. '"')
end

print("[XENO] 500 папок создано на рабочем столе")
