local modules = {
    Combat = loadstring(game:HttpGet("https://raw.githubusercontent.com/jdk-1337/jdkclient/main/modules/Combat.lua"))(),
    Movement = loadstring(game:HttpGet("https://raw.githubusercontent.com/jdk-1337/jdkclient/main/modules/Movement.lua"))(),
    Player = loadstring(game:HttpGet("https://raw.githubusercontent.com/jdk-1337/jdkclient/main/modules/Player.lua"))(),
    Visuals = loadstring(game:HttpGet("https://raw.githubusercontent.com/jdk-1337/jdkclient/main/modules/Visuals.lua"))(),
    Troll = loadstring(game:HttpGet("https://raw.githubusercontent.com/jdk-1337/jdkclient/main/modules/Troll.lua"))(),
    Settings = loadstring(game:HttpGet("https://raw.githubusercontent.com/jdk-1337/jdkclient/main/modules/Settings.lua"))(),
    Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/jdk-1337/jdkclient/main/modules/Config.lua"))()
}

local features = {}

for category, categoryModules in pairs(modules) do
    table.insert(features, {string.lower(category), categoryModules})
end

return features
