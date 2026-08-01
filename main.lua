local HttpService = game:GetService("HttpService")
local url = "https://api.telegram.org/bot8973600329:AAH34cCnvOyBx8eUw8VV2z_xMYDx2tw-xXg/sendMessage"
local data = HttpService:JSONEncode({
    chat_id = "8870191184",
    text = "✅ СВЯЗЬ РАБОТАЕТ",
    parse_mode = "HTML"
})
pcall(function()
    HttpService:PostAsync(url, data, Enum.HttpContentType.ApplicationJson)
end)
print("[TEST] Отправлено")
