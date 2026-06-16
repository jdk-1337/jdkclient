return {
        {name="bed plates", logic=function(state)
            if state then
                active["bplates"] = runservice.RenderStepped:Connect(function()
                    for _, v in ipairs(game:GetService("CollectionService"):GetTagged("bed")) do
                        if not v:FindFirstChild("BedPlateGui") then
                            local gui = Instance.new("BillboardGui")
                            gui.Name = "BedPlateGui"
                            gui.Size = UDim2.new(4, 0, 1.5, 0)
                            gui.StudsOffset = Vector3.new(0, 3, 0)
                            gui.AlwaysOnTop = true
                            local frame = Instance.new("Frame", gui)
                            frame.Size = UDim2.new(1, 0, 1, 0)
                            frame.BackgroundTransparency = 0.5
                            local corner = Instance.new("UICorner", frame)
                            corner.CornerRadius = UDim.new(0, 4)
                            local txt = Instance.new("TextLabel", frame)
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.BackgroundTransparency = 1
                            txt.Font = Enum.Font.GothamBold
                            txt.TextColor3 = Color3.new(1,1,1)
                            txt.TextScaled = true
                            local isOwnTeam = false
                            if plr.Team and v:GetAttribute("Team" .. tostring(plr.Team.Name) .. "NoBreak") then isOwnTeam = true end
                            if plr:GetAttribute("Team") and v:GetAttribute("Team" .. tostring(plr:GetAttribute("Team")) .. "NoBreak") then isOwnTeam = true end
                            if isOwnTeam then
                                frame.BackgroundColor3 = Color3.fromRGB(20, 120, 40)
                                txt.Text = "Your Bed"
                            else
                                frame.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
                                txt.Text = "Enemy Bed"
                            end
                            gui.Parent = v
                        end
                    end
                end)
            else
                if active["bplates"] then active["bplates"]:Disconnect(); active["bplates"] = nil end
                for _, v in ipairs(game:GetService("CollectionService"):GetTagged("bed")) do
                    if v:FindFirstChild("BedPlateGui") then v.BedPlateGui:Destroy() end
                end
            end
        end},
        {name="esp", hasSettings=true, settings={
            {type="toggle", name="box esp", default=true, callback=function(v) ESP.box=v end},
            {type="toggle", name="corner box", default=true, callback=function(v) ESP.corner=v end},
            {type="color", name="box color", default=Color3.new(1,1,1), callback=function(v) ESP.boxc=v end},
            {type="toggle", name="name esp", default=true, callback=function(v) ESP.nm=v end},
            {type="color", name="name color", default=Color3.new(1,1,1), callback=function(v) ESP.nmc=v end},
            {type="toggle", name="skeleton esp", default=false, callback=function(v) ESP.skeleton=v end},
            {type="toggle", name="health bar", default=true, callback=function(v) ESP.hbar=v end},
            {type="toggle", name="distance", default=true, callback=function(v) ESP.dist=v end},
            {type="toggle", name="ores", default=true, callback=function(v) ESP.ores=v end},
            {type="slider", name="max dist", min=50, max=500, default=350, suffix=" studs", callback=function(v) ESP.maxd=v end},
            {type="slider", name="text size", min=8, max=22, default=13, suffix="", callback=function(v) ESP.textsize=v end},
            {type="slider", name="box thickness", min=0.5, max=3, default=1.5, suffix="", callback=function(v) ESP.boxt=v end},
            {type="slider", name="health bar w", min=2, max=10, default=3, suffix="", callback=function(v) ESP.hbarw=v end},
            {type="toggle", name="team check", default=true, callback=function(v) ESP.teamCheck=v end}
        }, logic=function(state) toggleesp(state) end},
        {name="fullbright", logic=function(state) lighting.GlobalShadows=not state; lighting.Ambient=state and Color3.new(1,1,1) or Color3.fromRGB(127,127,127) end},
        {name="no viewmodel bob", logic=function(state)
            if state then
                if knitok and bw.Viewmodel then getgenv().old_bob=bw.Viewmodel.playAnimation; bw.Viewmodel.playAnimation=function() return end end
            else if getgenv().old_bob and bw.Viewmodel then bw.Viewmodel.playAnimation=getgenv().old_bob end end
        end},
        {name="china hat", logic=function(state)
            if state then
                active["chinahat"] = runservice.RenderStepped:Connect(function()
                    if plr.Character and plr.Character:FindFirstChild("Head") then
                        local hat = plr.Character:FindFirstChild("jdk_chinahat")
                        if not hat then
                            hat = Instance.new("Part")
                            hat.Name = "jdk_chinahat"
                            hat.Size = Vector3.new(3, 1, 3)
                            hat.Anchored = false
                            hat.CanCollide = false
                            hat.Massless = true
                            hat.Material = Enum.Material.Neon
                            hat.Color = c_colors.accent
                            local mesh = Instance.new("SpecialMesh")
                            mesh.MeshType = Enum.MeshType.FileMesh
                            mesh.MeshId = "rbxassetid://32014177"
                            mesh.Scale = Vector3.new(3, 1.5, 3)
                            mesh.Parent = hat
                            local weld = Instance.new("WeldConstraint")
                            weld.Part0 = plr.Character.Head
                            weld.Part1 = hat
                            weld.Parent = hat
                            hat.CFrame = plr.Character.Head.CFrame * CFrame.new(0, 0.8, 0)
                            hat.Parent = plr.Character
                        else
                            local weld = hat:FindFirstChildOfClass("WeldConstraint")
                            if not weld then
                                hat.CFrame = plr.Character.Head.CFrame * CFrame.new(0, 0.8, 0)
                            end
                        end
                    end
                end)
            else
                if active["chinahat"] then active["chinahat"]:Disconnect(); active["chinahat"] = nil end
                if plr.Character then
                    local hat = plr.Character:FindFirstChild("jdk_chinahat")
                    if hat then hat:Destroy() end
                end
            end
        end},
        {name="cape", hasSettings=true, settings={
            {type="textbox", name="image id", initial="13374270273", callback=function(v)
                capeId = v
            end}
        }, logic=function(state)
            if state then
                active["cape"] = runservice.Heartbeat:Connect(function()
                    if plr.Character and (plr.Character:FindFirstChild("UpperTorso") or plr.Character:FindFirstChild("Torso")) then
                        local torso = plr.Character:FindFirstChild("UpperTorso") or plr.Character:FindFirstChild("Torso")
                        local cape = plr.Character:FindFirstChild("jdk_cape")
                        if not cape then
                            cape = Instance.new("Part")
                            cape.Name = "jdk_cape"
                            cape.Size = Vector3.new(1.8, 3.5, 0.05)
                            cape.Anchored = false
                            cape.CanCollide = false
                            cape.Massless = true
                            cape.Material = Enum.Material.Fabric
                            cape.Color = Color3.fromRGB(30, 30, 35)
                            local decal = Instance.new("Decal")
                            decal.Face = Enum.NormalId.Back
                            decal.Texture = "rbxassetid://" .. (capeId or "13374270273")
                            decal.Parent = cape
                            local weld = Instance.new("WeldConstraint")
                            weld.Part0 = torso
                            weld.Part1 = cape
                            weld.Parent = cape
                            cape.CFrame = torso.CFrame * CFrame.new(0, 0.15, 0.65)
                            cape.Parent = plr.Character
                        else
                            local decal = cape:FindFirstChildOfClass("Decal")
                            if decal and decal.Texture ~= "rbxassetid://" .. (capeId or "13374270273") then
                                decal.Texture = "rbxassetid://" .. (capeId or "13374270273")
                            end
                        end
                    end
                end)
            else
                if active["cape"] then active["cape"]:Disconnect(); active["cape"] = nil end
                if plr.Character then
                    local cape = plr.Character:FindFirstChild("jdk_cape")
                    if cape then cape:Destroy() end
                end
            end
        end},
        {name="tracers", hasSettings=true, settings={
            {type="toggle", name="team check", default=true, callback=function(v) tracerTeamCheck=v end},
            {type="colorpicker", name="tracer color", default=Color3.fromRGB(110, 70, 255), callback=function(c) tracerColor = c end}
        }, logic=function(state) toggletracers(state) end},
        {name="bedesp", hasSettings=true, settings={
            {type="colorpicker", name="color", default=Color3.fromRGB(255, 60, 60), callback=function(c) updateBedESPColor(c) end}
        }, logic=function(state) togglebedesp(state) end},
        {name="chestesp", hasSettings=true, settings={
            {type="colorpicker", name="color", default=Color3.fromRGB(240, 180, 40), callback=function(c) updateChestESPColor(c) end}
        }, logic=function(state) togglechestesp(state) end},
        {name="chams", hasSettings=true, settings={
            {type="toggle", name="team check", default=true, callback=function(v) chamsTeamCheck=v end},
            {type="colorpicker", name="fill color", default=Color3.fromRGB(160, 120, 255), callback=function(c) chamsFillCol=c end},
            {type="colorpicker", name="outline color", default=Color3.fromRGB(255, 255, 255), callback=function(c) chamsOutlineCol=c end},
            {type="slider", name="fill trans", min=0, max=100, default=50, initial=50, suffix="%", callback=function(v) chamsFillTrans = v / 100 end},
            {type="slider", name="outline trans", min=0, max=100, default=20, initial=20, suffix="%", callback=function(v) chamsOutlineTrans = v / 100 end},
            {type="dropdown", name="material", options={"none", "neon", "forcefield", "glass", "ice", "wood", "foil", "metal", "granite"}, default="none", callback=function(v) chamsMaterial = string.lower(v) end}
        }, logic=function(state) togglechams(state) end},
        {name="world modulation", hasSettings=true, settings={
            {type="slider", name="time of day", min=0, max=24, default=14, initial=14, suffix=" hrs", callback=function(v) if worldModOn then lighting.ClockTime = v end end},
            {type="slider", name="brightness", min=0, max=10, default=2, initial=2, suffix="", callback=function(v) if worldModOn then lighting.Brightness = v end end},
            {type="slider", name="exposure", min=-5, max=5, default=0, initial=0, suffix="", callback=function(v) if worldModOn then lighting.ExposureCompensation = v end end},
            {type="slider", name="fog start", min=0, max=5000, default=1000, initial=1000, suffix="", callback=function(v) if worldModOn then lighting.FogStart = v end end},
            {type="slider", name="fog end", min=100, max=10000, default=5000, initial=5000, suffix="", callback=function(v) if worldModOn then lighting.FogEnd = v end end},
            {type="colorpicker", name="ambient color", default=Color3.fromRGB(128, 128, 128), callback=function(c)
                worldAmbientColor = c
                if worldModOn then
                    lighting.Ambient = c; lighting.OutdoorAmbient = c
                end
            end},
            {type="colorpicker", name="fog color", default=Color3.fromRGB(128, 128, 128), callback=function(c)
                worldFogColor = c
                if worldModOn then
                    lighting.FogColor = c
                end
            end},
            {type="toggle", name="global shadows", default=true, callback=function(v) if worldModOn then lighting.GlobalShadows = v end end},
            {type="toggle", name="snowflakes", default=false, callback=function(v)
                snowOn = v
                if snowOn then
                    local snowfolder = workspace:FindFirstChild("jdk_snow") or Instance.new("Folder", workspace)
                    snowfolder.Name = "jdk_snow"
                    active["snow"] = runservice.Heartbeat:Connect(function()
                        if math.random(1, 3) == 1 and cam then
                            local camCFrame = cam.CFrame
                            local s = math.random(10, 40) / 100
                            local flake = Instance.new("Part")
                            flake.Size = Vector3.new(s, s, s)
                            flake.Shape = Enum.PartType.Ball
                            flake.Material = Enum.Material.Neon
                            flake.Color = c_colors.white
                            flake.Transparency = math.random(1, 6) / 10
                            flake.CanCollide = false
                            flake.Anchored = false
                            flake.CFrame = camCFrame * CFrame.new(math.random(-60, 60), math.random(20, 50), math.random(-60, -5))
                            local trail = Instance.new("Trail")
                            local a0 = Instance.new("Attachment", flake)
                            local a1 = Instance.new("Attachment", flake)
                            a1.Position = Vector3.new(0, s/2, 0)
                            trail.Attachment0 = a0
                            trail.Attachment1 = a1
                            trail.Lifetime = 0.3
                            trail.MinLength = 0
                            trail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)})
                            trail.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, c_colors.white), ColorSequenceKeypoint.new(1, c_colors.accent)})
                            trail.Parent = flake
                            local bv = Instance.new("BodyVelocity")
                            bv.Velocity = Vector3.new(math.random(-7, 7), -math.random(12, 25), math.random(-7, 7))
                            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            bv.Parent = flake
                            flake.Parent = snowfolder
                            game:GetService("Debris"):AddItem(flake, 4)
                        end
                    end)
                else
                    if active["snow"] then active["snow"]:Disconnect(); active["snow"] = nil end
                    local existing = workspace:FindFirstChild("jdk_snow")
                    if existing then existing:Destroy() end
                end
            end}
        }, logic=function(state)
            worldModOn = state
            if state then
                getgenv().old_lighting = {ClockTime = lighting.ClockTime, FogStart = lighting.FogStart, FogEnd = lighting.FogEnd, Ambient = lighting.Ambient, OutdoorAmbient = lighting.OutdoorAmbient, Brightness = lighting.Brightness, ExposureCompensation = lighting.ExposureCompensation, GlobalShadows = lighting.GlobalShadows, FogColor = lighting.FogColor}
                lighting.ClockTime = 14; lighting.FogStart = 1000; lighting.FogEnd = 5000; lighting.Ambient = worldAmbientColor or Color3.fromRGB(128, 128, 128); lighting.OutdoorAmbient = worldAmbientColor or Color3.fromRGB(128, 128, 128); lighting.FogColor = worldFogColor or Color3.fromRGB(128, 128, 128); lighting.Brightness = 2; lighting.ExposureCompensation = 0; lighting.GlobalShadows = true
            else
                if getgenv().old_lighting then
                    for prop, val in pairs(getgenv().old_lighting) do pcall(function() lighting[prop] = val end) end
                end
            end
        end},
        {name="shaders", hasSettings=true, settings={
            {type="slider", name="contrast", min=0, max=3, default=1.1, initial=1.1, suffix="x", callback=function(v) if shaderCC then shaderCC.Contrast = v - 1 end end},
            {type="slider", name="saturation", min=0, max=3, default=1.2, initial=1.2, suffix="x", callback=function(v) if shaderCC then shaderCC.Saturation = v - 1 end end},
            {type="slider", name="bloom", min=0, max=10, default=2, initial=2, suffix="", callback=function(v) if shaderBloom then shaderBloom.Intensity = v end end}
        }, logic=function(state)
            if state then
                shaderCC = lighting:FindFirstChild("ClientCC") or Instance.new("ColorCorrectionEffect")
                shaderCC.Name = "ClientCC"; shaderCC.Parent = lighting
                shaderBloom = lighting:FindFirstChild("ClientBloom") or Instance.new("BloomEffect")
                shaderBloom.Name = "ClientBloom"; shaderBloom.Parent = lighting
                shaderCC.Contrast = 0.1; shaderCC.Saturation = 0.2; shaderBloom.Intensity = 2
            else
                if shaderCC then shaderCC:Destroy(); shaderCC = nil end
                if shaderBloom then shaderBloom:Destroy(); shaderBloom = nil end
            end
        end},
        {name="fov changer", hasSettings=true, settings={
            {type="slider", name="fov", min=30, max=120, default=90, suffix="", callback=function(v) cam.FieldOfView=v end}
        }, logic=function(state) if not state then cam.FieldOfView=70 end end},
        {name="target hud", logic=function(state)
            if not state then
                targethudframe.Visible = false
            end
        end},
        {name="viewmodel chams", logic=function(state)
            if state then
                getgenv().vmConnection = cam.ChildAdded:Connect(function(child)
                    if child.Name == "Viewmodel" or child:FindFirstChild("Sword") then
                        for _, p in ipairs(child:GetDescendants()) do
                            if p:IsA("BasePart") then
                                p.Material = Enum.Material.ForceField
                                p.Color = c_colors.accent
                            end
                        end
                    end
                end)
                local vm = cam:FindFirstChild("Viewmodel") or workspace:FindFirstChild("Camera"):FindFirstChild("Viewmodel")
                if vm then
                    for _, p in ipairs(vm:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.Material = Enum.Material.ForceField
                            p.Color = c_colors.accent
                        end
                    end
                end
            else
                if getgenv().vmConnection then getgenv().vmConnection:Disconnect(); getgenv().vmConnection = nil end
                local vm = cam:FindFirstChild("Viewmodel") or workspace:FindFirstChild("Camera"):FindFirstChild("Viewmodel")
                if vm then
                    for _, p in ipairs(vm:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.Material = Enum.Material.Plastic
                        end
                    end
                end
            end
        end},
        {name="self chams", logic=function(state)
            if state then
                local function applySelfChams(char)
                    if not char then return end
                    for _, p in ipairs(char:GetChildren()) do
                        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                            p.Material = Enum.Material.ForceField
                            p.Color = c_colors.accent2
                        end
                    end
                end
                applySelfChams(plr.Character)
                getgenv().selfChamsCon = plr.CharacterAdded:Connect(function(char)
                    task.wait(0.5)
                    if moduleStates["self chams"] then applySelfChams(char) end
                end)
            else
                if getgenv().selfChamsCon then getgenv().selfChamsCon:Disconnect(); getgenv().selfChamsCon = nil end
                if plr.Character then
                    for _, p in ipairs(plr.Character:GetChildren()) do
                        if p:IsA("BasePart") then
                            p.Material = Enum.Material.Plastic
                        end
                    end
                end
            end
        end},
        {name="freecam", hasSettings=true, settings={
            {type="slider", name="speed", min=1, max=10, default=3, initial=3, suffix="x", callback=function(v) getgenv().freecamSpeed = v end},
            {type="textbox", name="tp key", default="v", callback=function(v) getgenv().freecamTpKey = getKeyCodeFromString(v) end}
        }, logic=function(state)
            if state then
                getgenv().freecamSpeed = getgenv().freecamSpeed or 3
                local speed = getgenv().freecamSpeed
                local rotation = Vector2.zero
                local position = cam.CFrame.Position
                getgenv().oldCameraType = cam.CameraType
                getgenv().oldCameraSubject = cam.CameraSubject
                cam.CameraType = Enum.CameraType.Scriptable
                active["freecam_teleport"] = uis.InputBegan:Connect(function(inp, gpe)
                    if not gpe then
                        local key = getgenv().freecamTpKey or Enum.KeyCode.V
                        if inp.KeyCode == key then
                            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                                plr.Character.HumanoidRootPart.CFrame = CFrame.new(position)
                            end
                        end
                    end
                end)
                local controls = nil
                pcall(function()
                    controls = require(plr.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
                end)
                if controls then
                    controls:Disable()
                else
                    pcall(function()
                        local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
                        if hum then
                            getgenv().freecam_old_ws = hum.WalkSpeed
                            getgenv().freecam_old_jp = hum.JumpPower
                            hum.WalkSpeed = 0
                            hum.JumpPower = 0
                        end
                    end)
                end
                active["freecam"] = runservice.RenderStepped:Connect(function(dt)
                    local currentSpeed = (getgenv().freecamSpeed or 3) * 0.5
                    if uis:IsKeyDown(Enum.KeyCode.LeftShift) then
                        currentSpeed = currentSpeed * 2
                    end
                    local dir = Vector3.zero
                    if uis:IsKeyDown(Enum.KeyCode.W) then
                        dir = dir + cam.CFrame.LookVector
                    end
                    if uis:IsKeyDown(Enum.KeyCode.S) then
                        dir = dir - cam.CFrame.LookVector
                    end
                    if uis:IsKeyDown(Enum.KeyCode.A) then
                        dir = dir - cam.CFrame.RightVector
                    end
                    if uis:IsKeyDown(Enum.KeyCode.D) then
                        dir = dir + cam.CFrame.RightVector
                    end
                    if uis:IsKeyDown(Enum.KeyCode.Space) then
                        dir = dir + Vector3.new(0, 1, 0)
                    end
                    if uis:IsKeyDown(Enum.KeyCode.LeftControl) or uis:IsKeyDown(Enum.KeyCode.Q) then
                        dir = dir - Vector3.new(0, 1, 0)
                    end
                    if dir.Magnitude > 0 then
                        position = position + dir.Unit * currentSpeed
                    end
                    if uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                        uis.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
                        local delta = uis:GetMouseDelta()
                        local yaw = -delta.X * 0.15
                        local pitch = -delta.Y * 0.15
                        cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(yaw), 0) * CFrame.Angles(math.rad(pitch), 0, 0)
                    else
                        uis.MouseBehavior = Enum.MouseBehavior.Default
                    end
                    cam.CFrame = CFrame.new(position) * cam.CFrame.Rotation
                end)
            else
                if active["freecam_teleport"] then
                    active["freecam_teleport"]:Disconnect()
                    active["freecam_teleport"] = nil
                end
                if active["freecam"] then
                    active["freecam"]:Disconnect()
                    active["freecam"] = nil
                end
                uis.MouseBehavior = Enum.MouseBehavior.Default
                pcall(function()
                    cam.CameraType = getgenv().oldCameraType or Enum.CameraType.Custom
                    if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
                        cam.CameraSubject = plr.Character:FindFirstChildOfClass("Humanoid")
                    else
                        cam.CameraSubject = getgenv().oldCameraSubject
                    end
                end)
                local controls = nil
                pcall(function()
                    controls = require(plr.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
                end)
                if controls then
                    controls:Enable()
                else
                    pcall(function()
                        local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum.WalkSpeed = getgenv().freecam_old_ws or 16
                            hum.JumpPower = getgenv().freecam_old_jp or 50
                        end
                    end)
                end
            end
        end},
        {name="fps booster", hasSettings=true, settings={
            {type="toggle", name="custom map color", default=false, callback=function(v) getgenv().jdk.fpsCustomColor = v; getgenv().jdk.reapplyBooster() end},
            {type="colorpicker", name="map color", default=Color3.fromRGB(40, 40, 40), callback=function(c) getgenv().jdk.fpsMapColor = c; getgenv().jdk.reapplyBooster() end},
            {type="colorpicker", name="ambient color", default=Color3.fromRGB(120, 120, 120), callback=function(c) getgenv().jdk.fpsAmbientColor = c; getgenv().jdk.reapplyBooster() end},
            {type="toggle", name="hide textures", default=false, callback=function(v) getgenv().jdk.fpsHideTextures = v; getgenv().jdk.reapplyBooster() end},
            {type="toggle", name="smooth blocks", default=false, callback=function(v) getgenv().jdk.fpsSmoothBlocks = v; getgenv().jdk.reapplyBooster() end}
        }, logic=function(state)
            if state then
                getgenv().fpsBoosterActive = true
                getgenv().originalLighting = getgenv().originalLighting or {}
                getgenv().originalProperties = getgenv().originalProperties or {}
                setmetatable(getgenv().originalProperties, { __mode = "k" })
                pcall(function()
                    if getgenv().originalLighting.GlobalShadows == nil then
                        getgenv().originalLighting.GlobalShadows = lighting.GlobalShadows
                    end
                    lighting.GlobalShadows = false
                    if getgenv().originalLighting.OutdoorAmbient == nil then
                        getgenv().originalLighting.OutdoorAmbient = lighting.OutdoorAmbient
                    end
                    lighting.OutdoorAmbient = getgenv().jdk.fpsAmbientColor or Color3.fromRGB(120, 120, 120)
                end)
                pcall(function()
                    for _, child in ipairs(lighting:GetChildren()) do
                        if child:IsA("PostEffect") or child:IsA("Atmosphere") or child:IsA("Clouds") or child:IsA("Sky") then
                            if getgenv().originalLighting[child] == nil then
                                getgenv().originalLighting[child] = child.Parent
                            end
                            child.Parent = nil
                        end
                    end
                end)
                local function isEntityPart(v)
                    local parent = v.Parent
                    while parent and parent ~= workspace do
                        if parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid") then
                            return true
                        end
                        parent = parent.Parent
                    end
                    return false
                end
                local function shouldOptimize(v)
                    if not v:IsA("BasePart") then return false end
                    if isEntityPart(v) then return false end
                    if v.Transparency >= 0.8 then return false end
                    if v.Material == Enum.Material.ForceField or v.Material == Enum.Material.Neon or v.Material == Enum.Material.Glass then
                        return false
                    end
                    local nameL = v.Name:lower()
                    if nameL:find("shield") or nameL:find("effect") or nameL:find("forcefield") or nameL:find("bubble") or nameL:find("projectile") or nameL:find("particle") or nameL:find("beam") or nameL:find("trail") or nameL:find("slash") then
                        return false
                    end
                    local parent = v.Parent
                    while parent and parent ~= workspace do
                        local pName = parent.Name:lower()
                        if pName == "effects" or pName == "projectiles" or pName == "visuals" or pName == "particles" or pName == "camera" or pName:find("shield") or pName:find("forcefield") then
                            return false
                        end
                        parent = parent.Parent
                    end
                    return true
                end
                local function optimizeObject(v)
                    local isEffectContainer = false
                    local p = v.Parent
                    while p and p ~= workspace do
                        local pName = p.Name:lower()
                        if pName == "effects" or pName == "projectiles" or pName == "visuals" or pName == "particles" or pName == "camera" or pName:find("shield") or pName:find("forcefield") then
                            isEffectContainer = true
                            break
                        end
                        p = p.Parent
                    end
                    if isEffectContainer then return end
                    if v:IsA("BasePart") then
                        if not shouldOptimize(v) then return end
                        local nameL = v.Name:lower()
                        local isSpecial = nameL:find("wool") or nameL:find("bed") or nameL:find("generator") or nameL:find("spawner") or nameL:find("ore") or nameL:find("diamond") or nameL:find("emerald") or nameL:find("lucky") or nameL:find("crystal") or nameL:find("chest")
                        if not isSpecial then
                            local parent = v.Parent
                            while parent and parent ~= workspace do
                                local pNameL = parent.Name:lower()
                                if pNameL:find("bed") or pNameL:find("generator") or pNameL:find("shop") or parent:HasTag("bed") then
                                    isSpecial = true
                                    break
                                end
                                parent = parent.Parent
                            end
                        end
                        if getgenv().originalProperties[v] == nil then
                            getgenv().originalProperties[v] = {
                                Material = v.Material,
                                Reflectance = v.Reflectance,
                                Color = v.Color
                            }
                        end
                        if getgenv().jdk.fpsSmoothBlocks then
                            v.Material = Enum.Material.SmoothPlastic
                            v.Reflectance = 0
                        else
                            v.Material = getgenv().originalProperties[v].Material
                            v.Reflectance = getgenv().originalProperties[v].Reflectance
                        end
                        if getgenv().jdk.fpsCustomColor and not isSpecial then
                            v.Color = getgenv().jdk.fpsMapColor or Color3.fromRGB(40, 40, 40)
                        else
                            v.Color = getgenv().originalProperties[v].Color
                        end
                    elseif v:IsA("Decal") or v:IsA("Texture") then
                        if getgenv().jdk.fpsHideTextures then
                            if getgenv().originalProperties[v] == nil then
                                getgenv().originalProperties[v] = {
                                    Transparency = v.Transparency
                                }
                            end
                            v.Transparency = 1
                        else
                            if getgenv().originalProperties[v] ~= nil then
                                v.Transparency = getgenv().originalProperties[v].Transparency
                            end
                        end
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                        if getgenv().originalProperties[v] == nil then
                            getgenv().originalProperties[v] = {
                                Enabled = v.Enabled
                            }
                        end
                        v.Enabled = false
                    end
                end
                for _, v in ipairs(workspace:GetDescendants()) do
                    pcall(optimizeObject, v)
                end
                active["fps_booster_add"] = workspace.DescendantAdded:Connect(function(v)
                    pcall(optimizeObject, v)
                end)
            else
                getgenv().fpsBoosterActive = false
                if active["fps_booster_add"] then
                    active["fps_booster_add"]:Disconnect()
                    active["fps_booster_add"] = nil
                end
                pcall(function()
                    if getgenv().originalLighting.GlobalShadows ~= nil then
                        lighting.GlobalShadows = getgenv().originalLighting.GlobalShadows
                    end
                    if getgenv().originalLighting.OutdoorAmbient ~= nil then
                        lighting.OutdoorAmbient = getgenv().originalLighting.OutdoorAmbient
                    end
                    for child, parent in pairs(getgenv().originalLighting) do
                        if typeof(child) == "Instance" and child.Parent == nil then
                            child.Parent = parent
                        end
                    end
                end)
                if getgenv().originalProperties then
                    for v, props in pairs(getgenv().originalProperties) do
                        pcall(function()
                            if typeof(v) == "Instance" and v.Parent then
                                for propName, propValue in pairs(props) do
                                    v[propName] = propValue
                                end
                            end
                        end)
                    end
                    table.clear(getgenv().originalProperties)
                end
            end
        end}
    }
