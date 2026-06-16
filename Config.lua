return {
        {name="select config", type="dropdown", options=getconfigs(), default="default", logic=function(val)
            if val and val ~= "" then
                currentconfigname = string.lower(tostring(val))
                loadconfig(currentconfigname)
            end
        end},
        {name="new config name", type="textbox", logic=function(val) if val and val ~= "" then newconfigname = string.lower(tostring(val)) end end},
        {name="save config", type="button", logic=function()
            local name = newconfigname or currentconfigname or "default"
            saveconfig(name)
            local dropdown = toggleRefs["select config"]
            if dropdown and dropdown.updateOptions then
                dropdown:updateOptions(getconfigs())
                dropdown:set(name)
            end
            local lobbyD = toggleRefs["lobby config"]
            if lobbyD and lobbyD.updateOptions then
                lobbyD:updateOptions(getconfigs())
            end
            local matchD = toggleRefs["match config"]
            if matchD and matchD.updateOptions then
                matchD:updateOptions(getconfigs())
            end
        end},
        {name="delete config", type="button", logic=function()
            local name = currentconfigname
            if name ~= "default" then
                delfilesafe("jdkclient/"..name..".json")
                local dropdown = toggleRefs["select config"]
                if dropdown and dropdown.updateOptions then
                    dropdown:updateOptions(getconfigs())
                    dropdown:set("default")
                end
                local lobbyD = toggleRefs["lobby config"]
                if lobbyD and lobbyD.updateOptions then
                    lobbyD:updateOptions(getconfigs())
                end
                local matchD = toggleRefs["match config"]
                if matchD and matchD.updateOptions then
                    matchD:updateOptions(getconfigs())
                end
            end
        end},
        {name="auto execute", type="toggle", default=false, logic=function(state)
            autoexecEnabled = state
            saveAutoConfigSettings()
            if state then
                local loaderContent = [[-- jdkclient autoexec loader
if not game:IsLoaded() then game.Loaded:Wait() end
local s, r = pcall(function()
    if isfile("jdkclient/main.luau") then
        loadstring(readfile("jdkclient/main.luau"))()
    elseif isfile("jdkclient/main.lua") then
        loadstring(readfile("jdkclient/main.lua"))()
    end
end)
if not s then warn("jdkclient failed to load: " .. tostring(r)) end]]
                local success = pcall(function() writefile("../autoexec/jdkclient.luau", loaderContent) end)
                if not success then
                    pcall(function() writefile("autoexec/jdkclient.luau", loaderContent) end)
                end
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "JDKClient",
                    Text = "Auto-exec enabled! Save main.luau to workspace/jdkclient/ folder.",
                    Duration = 5
                })
            else
                pcall(function() delfile("autoexec/jdkclient.luau") end)
                pcall(function() delfile("../autoexec/jdkclient.luau") end)
                pcall(function() delfile("autoexec/jdkclient.lua") end)
                pcall(function() delfile("../autoexec/jdkclient.lua") end)
            end
        end},
        {name="lobby config", type="dropdown", options=getconfigs(), default="default", logic=function(val)
            lobbyConfigName = val
            saveAutoConfigSettings()
        end},
        {name="match config", type="dropdown", options=getconfigs(), default="default", logic=function(val)
            matchConfigName = val
            saveAutoConfigSettings()
        end}
    }}
