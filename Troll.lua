return {
        {name="fling", logic=function(state)
            if state then
                active["fling"]=runservice.Heartbeat:Connect(function()
                    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = plr.Character.HumanoidRootPart
                        hrp.Velocity = Vector3.new(math.random(-500,500), 0, math.random(-500,500))
                        hrp.RotVelocity = Vector3.new(math.random(-200,200), math.random(-200,200), math.random(-200,200))
                    end
                end)
            elseif active["fling"] then
                active["fling"]:Disconnect(); active["fling"]=nil
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    plr.Character.HumanoidRootPart.Velocity = Vector3.zero
                    plr.Character.HumanoidRootPart.RotVelocity = Vector3.zero
                end
            end
        end},
        {name="vanish", logic=function(state)
            if state then
                if plr.Character then
                    getgenv().old_cframe_vanish = plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.HumanoidRootPart.CFrame or nil
                    pcall(function() plr.Character.HumanoidRootPart.CFrame = CFrame.new(0, 1e7, 0) end)
                    for _, part in ipairs(plr.Character:GetDescendants()) do
                        if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture") then part.Transparency = 1 end
                    end
                end
            else
                if plr.Character then
                    for _, part in ipairs(plr.Character:GetDescendants()) do
                        if (part:IsA("BasePart") and part.Name ~= "HumanoidRootPart") or part:IsA("Decal") or part:IsA("Texture") then part.Transparency = 0 end
                    end
                    if getgenv().old_cframe_vanish and plr.Character:FindFirstChild("HumanoidRootPart") then
                        plr.Character.HumanoidRootPart.CFrame = getgenv().old_cframe_vanish
                    end
                end
            end
        end},
        {name="crasher", hasSettings=true, settings={
            {type="slider", name="intensity", min=5, max=50, default=20, initial=20, suffix="x", callback=function(v) end}
        }, logic=function(state)
            if state then
                local crashtarget = nearest(50, false)
                if crashtarget and crashtarget.char then
                    active["crasher"]=task.spawn(function()
                        while moduleStates["crasher"] do
                            pcall(function()
                                for i = 1, 20 do
                                    local part = Instance.new("Part"); part.Size = Vector3.new(0.1, 0.1, 0.1); part.Transparency = 1; part.Anchored = true; part.CanCollide = false
                                    part.CFrame = crashtarget.hrp.CFrame * CFrame.new(math.random(-5,5), math.random(-5,5), math.random(-5,5)); part.Parent = workspace
                                    local fire = Instance.new("Fire"); fire.Size = 50; fire.Parent = part
                                    local smoke = Instance.new("Smoke"); smoke.Size = 50; smoke.Parent = part
                                    local sparkles = Instance.new("Sparkles"); sparkles.Parent = part
                                    task.delay(0.5, function() pcall(function() part:Destroy() end) end)
                                end
                            end)
                            task.wait(0.05)
                        end
                    end)
                end
            else moduleStates["crasher"] = false end
        end},
        {name="spin", hasSettings=true, settings={
            {type="slider", name="speed", min=5, max=100, default=25, initial=25, suffix=" rpm", callback=function(v) end}
        }, logic=function(state)
            if state then
                local spinspd = 25
                active["spin"]=runservice.RenderStepped:Connect(function()
                    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = plr.Character.HumanoidRootPart
                        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinspd), 0)
                    end
                end)
            elseif active["spin"] then active["spin"]:Disconnect(); active["spin"]=nil end
        end},
        {name="orbit", hasSettings=true, settings={
            {type="slider", name="radius", min=5, max=30, default=10, initial=10, suffix=" studs", callback=function(v) end},
            {type="slider", name="speed", min=1, max=10, default=3, initial=3, suffix="x", callback=function(v) end}
        }, logic=function(state)
            if state then
                local orbittarget = nearest(100, false)
                if orbittarget and orbittarget.hrp then
                    local starttime = tick()
                    active["orbit"]=runservice.RenderStepped:Connect(function()
                        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and orbittarget.hrp and orbittarget.hrp.Parent then
                            local hrp = plr.Character.HumanoidRootPart
                            local radius = 10; local speed = 3
                            local t = (tick() - starttime) * speed; local targetpos = orbittarget.hrp.Position
                            hrp.CFrame = CFrame.new(targetpos.X + math.cos(t) * radius, targetpos.Y + 2, targetpos.Z + math.sin(t) * radius, targetpos.X, targetpos.Y, targetpos.Z)
                        end
                    end)
                end
            elseif active["orbit"] then active["orbit"]:Disconnect(); active["orbit"]=nil end
        end},
        {name="annoy", logic=function(state)
            if state then
                local annoytarget = nearest(50, false)
                if annoytarget and annoytarget.hrp then
                    active["annoy"]=runservice.Heartbeat:Connect(function()
                        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and annoytarget.hrp and annoytarget.hrp.Parent then
                            local hrp = plr.Character.HumanoidRootPart
                            local offset = Vector3.new(math.random(-3,3), math.random(0,3), math.random(-3,3))
                            hrp.CFrame = CFrame.new(annoytarget.hrp.Position + offset)
                        end
                    end)
                end
            elseif active["annoy"] then active["annoy"]:Disconnect(); active["annoy"]=nil end
        end},
        {name="tp aura", hasSettings=true, settings={
            {type="slider", name="range", min=10, max=100, default=30, initial=30, suffix=" studs", callback=function(v) end}
        }, logic=function(state)
            if state then
                active["tpaura"]=runservice.Heartbeat:Connect(function()
                    local t = nearest(30, false)
                    if t and t.hrp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = plr.Character.HumanoidRootPart
                        local dir = (t.hrp.Position - hrp.Position).Unit
                        hrp.CFrame = CFrame.new(t.hrp.Position - dir * 3, t.hrp.Position)
                    end
                end)
            elseif active["tpaura"] then active["tpaura"]:Disconnect(); active["tpaura"]=nil end
        end},
        {name="desync", logic=function(state)
            if state then
                active["desync"]=runservice.Heartbeat:Connect(function()
                    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = plr.Character.HumanoidRootPart
                        pcall(function()
                            local oldCF = hrp.CFrame
                            hrp.CFrame = hrp.CFrame * CFrame.new(math.random(-15,15)/10, 0, math.random(-15,15)/10)
                            runservice.RenderStepped:Wait()
                            hrp.CFrame = oldCF
                        end)
                    end
                end)
            elseif active["desync"] then active["desync"]:Disconnect(); active["desync"]=nil end
        end},
        {name="clan invite all", type="button", logic=function()
            if not knitok or not bw.Knit then
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "JDKClient",
                    Text = "Knit is not initialized yet!",
                    Duration = 3
                })
                return
            end
            local store = getClientStore()
            if not store then
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "JDKClient",
                    Text = "Could not access ClientStore!",
                    Duration = 3
                })
                return
            end
            local state = store:getState()
            local myClanId = state.Clans and state.Clans.myClanId
            if not myClanId or myClanId == "" then
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "JDKClient",
                    Text = "You are not in a clan!",
                    Duration = 3
                })
                return
            end
            local clanController = bw.Knit.Controllers.ClanController
            if not clanController then
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "JDKClient",
                    Text = "ClanController not found!",
                    Duration = 3
                })
                return
            end
            local Players = game:GetService("Players")
            local count = 0
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= Players.LocalPlayer then
                    count = count + 1
                    task.spawn(function()
                        pcall(function()
                            clanController:invitePlayerToClan({ userId = p.UserId }, myClanId)
                        end)
                    end)
                end
            end
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "JDKClient",
                Text = "Inviting " .. tostring(count) .. " players to the clan...",
                Duration = 5
            })
        end}
    }
