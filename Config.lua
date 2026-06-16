return {
    {name="select config", type="dropdown", options=(getgenv().getconfigs and getgenv().getconfigs()) or {"default"}, default="default", logic=function(val)
        if val and val ~= "" then
            getgenv().currentconfigname = string.lower(tostring(val))
            if getgenv().loadconfig then getgenv().loadconfig(getgenv().currentconfigname) end
        end
    end},
    {name="new config name", type="textbox", logic=function(val) if val and val ~= "" then getgenv().newconfigname = string.lower(tostring(val)) end end},
    {name="save config", type="button", logic=function()
        local name = getgenv().newconfigname or getgenv().currentconfigname or "default"
        if getgenv().saveconfig then getgenv().saveconfig(name) end
        local refs = getgenv().toggleRefs or {}
        local dropdown = refs["select config"]
        if dropdown and dropdown.updateOptions and getgenv().getconfigs then
            dropdown:updateOptions(getgenv().getconfigs())
            dropdown:set(name)
        end
        local lobbyD = refs["lobby config"]
        if lobbyD and lobbyD.updateOptions and getgenv().getconfigs then
            lobbyD:updateOptions(getgenv().getconfigs())
        end
        local matchD = refs["match config"]
        if matchD and matchD.updateOptions and getgenv().getconfigs then
            matchD:updateOptions(getgenv().getconfigs())
        end
    end},
    {name="delete config", type="button", logic=function()
        local name = getgenv().currentconfigname
        if name and name ~= "default" then
            if getgenv().delfilesafe then getgenv().delfilesafe("jdkclient/"..name..".json") end
            local refs = getgenv().toggleRefs or {}
            local dropdown = refs["select config"]
            if dropdown and dropdown.updateOptions and getgenv().getconfigs then
                dropdown:updateOptions(getgenv().getconfigs())
                dropdown:set("default")
            end
            local lobbyD = refs["lobby config"]
            if lobbyD and lobbyD.updateOptions and getgenv().getconfigs then
                lobbyD:updateOptions(getgenv().getconfigs())
            end
            local matchD = refs["match config"]
            if matchD and matchD.updateOptions and getgenv().getconfigs then
                matchD:updateOptions(getgenv().getconfigs())
            end
        end
    end},
    {name="auto execute", type="toggle", default=false, logic=function(state)
        getgenv().autoexecEnabled = state
        if getgenv().saveAutoConfigSettings then getgenv().saveAutoConfigSettings() end
    end},
    {name="lobby config", type="dropdown", options=(getgenv().getconfigs and getgenv().getconfigs()) or {"default"}, default="default", logic=function(val)
        getgenv().lobbyConfigName = val
        if getgenv().saveAutoConfigSettings then getgenv().saveAutoConfigSettings() end
    end},
    {name="match config", type="dropdown", options=(getgenv().getconfigs and getgenv().getconfigs()) or {"default"}, default="default", logic=function(val)
        getgenv().matchConfigName = val
        if getgenv().saveAutoConfigSettings then getgenv().saveAutoConfigSettings() end
    end}
}
