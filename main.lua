-- ТЕСТ: ОТПРАВКА "TEST" В DISCORD
local WEBHOOK_URL = "https://discord.com/api/webhooks/1533234667048796231/nSWhNJCk-VRbH6rn_9KECRTPhYXwmvN03e8WoyKgioHjMvKj0CwvZ2lFfBj_Jd8jksRr"  -- СЮДА ВСТАВЬ СВОЙ URL

local HttpService = game:GetService("HttpService")

local data = HttpService:JSONEncode({
    content = "TEST",  -- <-- ПРОСТОЕ СООБЩЕНИЕ
    embeds = {{
        title = "✅ ТЕСТОВОЕ СООБЩЕНИЕ",
        description = "Если ты это видишь — Discord Webhook работает!",
        color = 65280, -- зелёный
        footer = {text = "Тест от SWILL"}
    }}
})

local function send()
    local success, err = pcall(function()
        HttpService:PostAsync(WEBHOOK_URL, data, Enum.HttpContentType.ApplicationJson)
    end)

    if not success then
        success, err = pcall(function()
            syn.request({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = data
            })
        end)
    end

    if success then
        print("[TEST] ✅ В Discord отправлено!")
    else
        warn("[TEST] ❌ Ошибка: " .. tostring(err))
    end
end

send()
