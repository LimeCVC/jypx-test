local url = "https://api.telegram.org/bot8973600329:AAH34cCnvOyBx8eUw8VV2z_xMYDx2tw-xXg/sendMessage"
local data = {
    chat_id = "8870191184",
    text = "✅ СВЯЗЬ РАБОТАЕТ",
    parse_mode = "HTML"
}
pcall(function()
    syn.request({
        Url = url,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = game:GetService("HttpService"):JSONEncode(data)
    })
end)
print("[TEST] Отправлено через syn")
