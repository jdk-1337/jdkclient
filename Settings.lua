return {
        {name="Theme", type="dropdown", options={"Gradient (Default)", "Sleek Dark", "Light Mode", "Neon Blue", "Blood Red"}, default="Gradient (Default)", logic=function(v)
            if v == "Gradient (Default)" then
                c_colors = {
                    bg = Color3.fromRGB(13, 13, 18),
                    sbg = Color3.fromRGB(22, 22, 28),
                    outline = Color3.fromRGB(35, 35, 45),
                    accent = Color3.fromRGB(138, 43, 226),
                    accent2 = Color3.fromRGB(0, 220, 255),
                    accent3 = Color3.fromRGB(200, 40, 255),
                    text = Color3.fromRGB(245, 245, 250),
                    dim = Color3.fromRGB(140, 140, 155),
                    white = Color3.fromRGB(255, 255, 255)
                }
            elseif v == "Sleek Dark" then
                c_colors = {
                    bg = Color3.fromRGB(12, 12, 12),
                    sbg = Color3.fromRGB(18, 18, 18),
                    outline = Color3.fromRGB(35, 35, 35),
                    accent = Color3.fromRGB(180, 180, 180),
                    accent2 = Color3.fromRGB(230, 230, 230),
                    accent3 = Color3.fromRGB(150, 150, 150),
                    text = Color3.fromRGB(235, 235, 235),
                    dim = Color3.fromRGB(120, 120, 120),
                    white = Color3.fromRGB(255, 255, 255)
                }
            elseif v == "Light Mode" then
                c_colors = {
                    bg = Color3.fromRGB(240, 240, 245),
                    sbg = Color3.fromRGB(255, 255, 255),
                    outline = Color3.fromRGB(215, 215, 225),
                    accent = Color3.fromRGB(0, 122, 255),
                    accent2 = Color3.fromRGB(88, 86, 214),
                    accent3 = Color3.fromRGB(0, 150, 255),
                    text = Color3.fromRGB(30, 30, 35),
                    dim = Color3.fromRGB(120, 120, 130),
                    white = Color3.fromRGB(0, 0, 0)
                }
            elseif v == "Neon Blue" then
                c_colors = {
                    bg = Color3.fromRGB(10, 14, 24),
                    sbg = Color3.fromRGB(16, 22, 38),
                    outline = Color3.fromRGB(30, 45, 75),
                    accent = Color3.fromRGB(0, 160, 255),
                    accent2 = Color3.fromRGB(0, 255, 170),
                    accent3 = Color3.fromRGB(0, 120, 255),
                    text = Color3.fromRGB(240, 248, 255),
                    dim = Color3.fromRGB(120, 150, 190),
                    white = Color3.fromRGB(255, 255, 255)
                }
            elseif v == "Blood Red" then
                c_colors = {
                    bg = Color3.fromRGB(14, 8, 8),
                    sbg = Color3.fromRGB(22, 10, 10),
                    outline = Color3.fromRGB(45, 20, 20),
                    accent = Color3.fromRGB(255, 30, 30),
                    accent2 = Color3.fromRGB(255, 100, 30),
                    accent3 = Color3.fromRGB(200, 10, 10),
                    text = Color3.fromRGB(255, 220, 220),
                    dim = Color3.fromRGB(160, 70, 70),
                    white = Color3.fromRGB(255, 255, 255)
                }
            end
            pcall(updatecolors)
        end},
        {name="blur effect", logic=function(state) blur.Enabled=state end},
        {name="watermark", logic=function(state) watermark.Visible=state; wmvisible=state end},
        {name="arraylist", logic=function(state) alframe.Visible=state end},
        {name="menu transparency", hasSettings=true, settings={
            {type="slider", name="percent", min=0, max=100, default=85, initial=85, suffix="%", callback=function(v)
                menuTransparency = 1 - (v / 100)
                updatecolors()
            end}
        }, logic=function(state) end},
        {name="accent color 1", hasSettings=true, settings={
            {type="colorpicker", name="color", default=Color3.fromRGB(150, 0, 255), callback=function(c)
                c_colors.accent = c
                updatecolors()
            end}
        }, logic=function(state) end},
        {name="accent color 2", hasSettings=true, settings={
            {type="colorpicker", name="color", default=Color3.fromRGB(0, 220, 255), callback=function(c)
                c_colors.accent2 = c
                updatecolors()
            end}
        }, logic=function(state) end},
        {name="accent color 3", hasSettings=true, settings={
            {type="colorpicker", name="color", default=Color3.fromRGB(255, 0, 150), callback=function(c)
                c_colors.accent3 = c
                updatecolors()
            end}
        }, logic=function(state) end},
        {name="join new server", type="button", logic=function()
            local HttpService = game:GetService("HttpService")
            local TeleportService = game:GetService("TeleportService")
            local placeId = game.PlaceId
            local url = "https://games.roblox.com/v1/games/" .. tostring(placeId) .. "/servers/Public?sortOrder=Asc&limit=100"
            local success, response = pcall(function() return game:HttpGet(url) end)
            if success and response then
                local data
                pcall(function() data = HttpService:JSONDecode(response) end)
                if data and data.data then
                    local possibleServers = {}
                    for _, server in ipairs(data.data) do
                        if server.playing and server.maxPlayers and server.playing < server.maxPlayers and server.id ~= game.JobId then
                            table.insert(possibleServers, server)
                        end
                    end
                    if #possibleServers > 0 then
                        table.sort(possibleServers, function(a, b)
                            return (a.playing or 0) > (b.playing or 0)
                        end)
                        TeleportService:TeleportToPlaceInstance(placeId, possibleServers[1].id, plr)
                        return
                    end
                end
            end
            TeleportService:Teleport(placeId, plr)
        end},
        {name="unload client", logic=function() unload() end}
    }
