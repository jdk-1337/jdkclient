tweenservice = game:GetService("TweenService")
uis = game:GetService("UserInputService")
runservice = game:GetService("RunService")
rep = game:GetService("ReplicatedStorage")
plr = game:GetService("Players").LocalPlayer
lighting = game:GetService("Lighting")
cam = workspace.CurrentCamera
players = game:GetService("Players")
hide_bind = Enum.KeyCode.RightShift
ww = 210
spacing = 225
local clientActive = true
local ClientConnections = {
    _connections = {},
    _objects = {},
    _threads = {}
}
function ClientConnections.add(conn)
    if not conn then return nil end
    table.insert(ClientConnections._connections, conn)
    return conn
end
function ClientConnections.addObject(obj)
    if not obj then return nil end
    table.insert(ClientConnections._objects, obj)
    return obj
end
function ClientConnections.addThread(thread)
    if not thread then return nil end
    table.insert(ClientConnections._threads, thread)
    return thread
end
function ClientConnections.cleanup()
    clientActive = false
    for _, conn in ipairs(ClientConnections._connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(ClientConnections._connections)
    for _, obj in ipairs(ClientConnections._objects) do
        pcall(function()
            if obj.Destroy then
                obj:Destroy()
            elseif obj.Remove then
                obj:Remove()
            end
        end)
    end
    table.clear(ClientConnections._objects)
    for _, thread in ipairs(ClientConnections._threads) do
        pcall(function()
            task.cancel(thread)
        end)
    end
    table.clear(ClientConnections._threads)
end
active = {}; uiconns = {}; toggleRefs = {}
moduleStates = {}; alLabels = {}; keybindOverrides = {}
reachVal = 18; reachActive = false
reachSwordEnabled = true
reachSwordRange = 18
reachBlockEnabled = true
reachBlockRange = 24
reachBreakEnabled = true
reachBreakRange = 18
saRange = 18
saAngle = 120
saSpeed = 6
saSilentAim = true
saPerfect = true
saLegit = false
saTargets = { Players = true, Guardians = true, Titans = true, Dummies = true, Ducks = true, Chickens = true }
getgenv().jdk = {
    bowAimPredict = true,
    bowAimPredictScale = 1.0,
    bowAimYOffset = 1.0,
    bowAimDistanceBased = false,
    bowAimPart = "Body",
    blockInKey = Enum.KeyCode.V,
    blockInBedRange = 25,
    blockInOnlyEnemy = false,
    fpsCustomColor = false,
    fpsMapColor = Color3.fromRGB(40, 40, 40),
    fpsAmbientColor = Color3.fromRGB(120, 120, 120),
    fpsHideTextures = false,
    fpsSmoothBlocks = false,
    fastBreakMultiplier = 2,
    fastBreakCooldown = 0,
    desyncRange = 15,
    antiHitDistance = 12,
    antiHitHeight = 12,
    reapplyBooster = function()
        if not getgenv().fpsBoosterActive then return end
        local lighting = game:GetService("Lighting")
        local function isEntityPart(part)
            local parent = part.Parent
            while parent and parent ~= workspace do
                if parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid") then
                    return true
                end
                parent = parent.Parent
            end
            return false
        end
        local function shouldOptimize(part)
            if not part:IsA("BasePart") then return false end
            if isEntityPart(part) then return false end
            if part.Transparency >= 0.8 then return false end
            if part.Material == Enum.Material.ForceField or part.Material == Enum.Material.Neon or part.Material == Enum.Material.Glass then
                return false
            end
            local nameL = part.Name:lower()
            if nameL:find("shield") or nameL:find("effect") or nameL:find("forcefield") or nameL:find("bubble") or nameL:find("projectile") or nameL:find("particle") or nameL:find("beam") or nameL:find("trail") or nameL:find("slash") then
                return false
            end
            local parent = part.Parent
            while parent and parent ~= workspace do
                local pName = parent.Name:lower()
                if pName == "effects" or pName == "projectiles" or pName == "visuals" or pName == "particles" or pName == "camera" or pName:find("shield") or pName:find("forcefield") then
                    return false
                end
                parent = parent.Parent
            end
            return true
        end
        for _, v in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if shouldOptimize(v) then
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
                end
            end)
        end
        pcall(function()
            lighting.OutdoorAmbient = getgenv().jdk.fpsAmbientColor or Color3.fromRGB(120, 120, 120)
        end)
    end,
    getKeyCodeFromString = function(str)
        str = string.lower(str)
        for _, k in ipairs(Enum.KeyCode:GetEnumItems()) do
            if string.lower(k.Name) == str then
                return k
            end
        end
        return Enum.KeyCode.V
    end
}
local function findRemote(name)
    local netManaged = rep:FindFirstChild("rbxts_include")
        and rep.rbxts_include:FindFirstChild("node_modules")
        and rep.rbxts_include.node_modules:FindFirstChild("@rbxts")
        and rep.rbxts_include.node_modules["@rbxts"]:FindFirstChild("net")
        and rep.rbxts_include.node_modules["@rbxts"].net:FindFirstChild("out")
        and rep.rbxts_include.node_modules["@rbxts"].net.out:FindFirstChild("_NetManaged")
    if not netManaged then return nil end
    local remote = netManaged:FindFirstChild(name)
    if remote then return remote end
    for _, child in ipairs(netManaged:GetChildren()) do
        if string.lower(child.Name) == string.lower(name) then
            return child
        end
    end
    return nil
end
local swordhitremote = nil
task.spawn(function()
    for _ = 1, 100 do
        local r = findRemote("SwordHit")
        if r then
            getgenv().SwordHitRemote = r
            swordhitremote = r
            break
        end
        task.wait(0.5)
    end
    if not swordhitremote then
        swordhitremote = rep:FindFirstChild("SwordHit", true)
        if swordhitremote then
            getgenv().SwordHitRemote = swordhitremote
        end
    end
end)
gui = Instance.new("ScreenGui")
gui.Name = "jdkclient"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
local s, _ = pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not s then gui.Parent = plr:WaitForChild("PlayerGui") end
espgui = Instance.new("ScreenGui")
espgui.Name = "jdkclient_esp"
espgui.ResetOnSpawn = false
espgui.DisplayOrder = 99
espgui.IgnoreGuiInset = true
pcall(function() espgui.Parent = gui.Parent end)
blur = Instance.new("BlurEffect")
blur.Size = 15; blur.Enabled = false; blur.Parent = lighting
windowsframe = Instance.new("Frame")
windowsframe.Size = UDim2.new(1, 0, 1, 0)
windowsframe.BackgroundTransparency = 1
windowsframe.BorderSizePixel = 0
windowsframe.Visible = false
windowsframe.Parent = gui
c_colors = {
    bg = Color3.fromRGB(12, 11, 16),
    header = Color3.fromRGB(8, 7, 10),
    text = Color3.fromRGB(255, 255, 255),
    dim = Color3.fromRGB(130, 130, 150),
    accent = Color3.fromRGB(150, 0, 255),
    accent2 = Color3.fromRGB(0, 220, 255),
    accent3 = Color3.fromRGB(255, 0, 150),
    outline = Color3.fromRGB(35, 30, 48),
    drop = Color3.fromRGB(18, 16, 24),
    sbg = Color3.fromRGB(25, 22, 35),
    sfill = Color3.fromRGB(0, 220, 255),
    white = Color3.fromRGB(255, 255, 255),
    green = Color3.fromRGB(0, 255, 120),
    yellow = Color3.fromRGB(255, 220, 0),
    red = Color3.fromRGB(255, 60, 100)
}
local function addshadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "shadow"
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.ZIndex = -1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = parent
end
local function addpattern(parent)
    local pattern = Instance.new("ImageLabel")
    pattern.Name = "pattern"
    pattern.BackgroundTransparency = 1
    pattern.Size = UDim2.new(1, 0, 1, 0)
    pattern.Image = "rbxassetid://9810151833"
    pattern.ImageColor3 = c_colors.accent
    pattern.ImageTransparency = 0.94
    pattern.ScaleType = Enum.ScaleType.Tile
    pattern.TileSize = UDim2.new(0, 24, 0, 24)
    pattern.ZIndex = 0
    pattern.Parent = parent
end
menuTransparency = 0.15
gradientAnimations = {}
local function updatecolors()
    for _, item in ipairs(gui:GetDescendants()) do
        if item:IsA("UIGradient") then
            local p = item.Parent
            local isColorPickerGrad = false
            if p and (p.Name == "SatFrame" or p.Name == "ValFrame" or p.Name == "HueSlider") then
                isColorPickerGrad = true
            end
            local isLoaderGrad = false
            local cur = item
            while cur and cur ~= gui do
                local success, parent = pcall(function() return cur.Parent end)
                if not success or not parent then
                    break
                end
                if cur.Name == "LoaderGroup" then
                    isLoaderGrad = true
                    break
                end
                cur = parent
            end
            if not isColorPickerGrad and not isLoaderGrad then
                item.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, c_colors.accent),
                    ColorSequenceKeypoint.new(0.5, c_colors.accent2),
                    ColorSequenceKeypoint.new(1, c_colors.accent3 or c_colors.accent)
                })
                local isAnimated = false
                for _, animGrad in ipairs(gradientAnimations) do
                    if animGrad == item then
                        isAnimated = true
                        break
                    end
                end
                if not isAnimated then
                    item.Rotation = 45
                end
            end
        elseif item:IsA("CanvasGroup") then
            item.BackgroundTransparency = menuTransparency or 0.15
        elseif item.Name == "pattern" and item:IsA("ImageLabel") then
            item.ImageColor3 = c_colors.accent
        end
    end
    for _, ref in pairs(toggleRefs) do
        if type(ref) == "table" and ref.set and ref.get then
            pcall(function() ref.set(ref.get()) end)
        end
    end
end
local function startGradientAnimation()
    table.insert(uiconns, runservice.Heartbeat:Connect(function()
        local time = tick()
        for _, grad in pairs(gradientAnimations) do
            if grad and grad.Parent then
                local baseRotation = 45
                grad.Rotation = baseRotation + math.sin(time * 2) * 12
                local offsetX = math.sin(time * 1.5) * 0.35
                local offsetY = math.cos(time * 1.5) * 0.35
                grad.Offset = Vector2.new(offsetX, offsetY)
            end
        end
    end))
end
pcall(startGradientAnimation)
local function showLoader()
    local loaderGroup = Instance.new("Frame")
    loaderGroup.Name = "LoaderGroup"
    loaderGroup.Size = UDim2.new(1, 0, 1, 0)
    loaderGroup.Position = UDim2.new(0, 0, 0, 0)
    loaderGroup.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    loaderGroup.BackgroundTransparency = 0.15
    loaderGroup.BorderSizePixel = 0
    loaderGroup.Parent = gui
    local centerGlow = Instance.new("ImageLabel")
    centerGlow.Size = UDim2.new(0, 600, 0, 600)
    centerGlow.Position = UDim2.new(0.5, -300, 0.5, -300)
    centerGlow.BackgroundTransparency = 1
    centerGlow.Image = "rbxassetid://13158652433"
    centerGlow.ImageColor3 = c_colors.accent
    centerGlow.ImageTransparency = 0.85
    centerGlow.Parent = loaderGroup
    local logoText = Instance.new("TextLabel")
    logoText.Size = UDim2.new(0, 200, 0, 50)
    logoText.Position = UDim2.new(0.5, -100, 0.5, -30)
    logoText.BackgroundTransparency = 1
    logoText.RichText = true
    logoText.Text = '<b><font color="#9600ff">JDK</font><font color="#ffffff">CLIENT</font></b>'
    pcall(function() logoText.Font = Enum.Font.GothamBold end)
    logoText.TextSize = 28
    logoText.TextXAlignment = Enum.TextXAlignment.Center
    logoText.Parent = loaderGroup
    local loadingBarBg = Instance.new("Frame")
    loadingBarBg.Size = UDim2.new(0, 180, 0, 2)
    loadingBarBg.Position = UDim2.new(0.5, -90, 0.5, 20)
    loadingBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    loadingBarBg.BorderSizePixel = 0
    loadingBarBg.Parent = loaderGroup
    local loadingBarFill = Instance.new("Frame")
    loadingBarFill.Size = UDim2.new(0, 0, 1, 0)
    loadingBarFill.BackgroundColor3 = c_colors.accent
    loadingBarFill.BorderSizePixel = 0
    loadingBarFill.Parent = loadingBarBg
    local fillgrad = Instance.new("UIGradient")
    fillgrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c_colors.accent),
        ColorSequenceKeypoint.new(0.5, c_colors.accent2),
        ColorSequenceKeypoint.new(1, c_colors.accent)
    })
    fillgrad.Parent = loadingBarFill
    table.insert(gradientAnimations, fillgrad)
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(0, 200, 0, 20)
    statusText.Position = UDim2.new(0.5, -100, 0.5, 30)
    statusText.BackgroundTransparency = 1
    statusText.Text = "authenticating"
    statusText.TextColor3 = Color3.fromRGB(150, 150, 160)
    pcall(function() statusText.Font = Enum.Font.GothamMedium end)
    statusText.TextSize = 11
    statusText.TextXAlignment = Enum.TextXAlignment.Center
    statusText.Parent = loaderGroup
    task.spawn(function()
        local success, err = pcall(function()
            local steps = {
                {pct = 0.20, text = "authenticating"},
                {pct = 0.45, text = "fetching modules"},
                {pct = 0.85, text = "bypassing anticheat"},
                {pct = 1.00, text = "injected"}
            }
            local currentPct = 0
            for _, step in ipairs(steps) do
                local startPct = currentPct
                local targetPct = step.pct
                statusText.Text = step.text
                local duration = 0.3 + math.random() * 0.2
                local elapsed = 0
                while elapsed < duration do
                    local dt = task.wait()
                    elapsed = elapsed + dt
                    local t = elapsed / duration
                    local smoothT = t * t * (3 - 2 * t)
                    currentPct = startPct + (targetPct - startPct) * smoothT
                    pcall(function()
                        loadingBarFill.Size = UDim2.new(currentPct, 0, 1, 0)
                    end)
                end
                currentPct = targetPct
                pcall(function() loadingBarFill.Size = UDim2.new(currentPct, 0, 1, 0) end)
                task.wait(0.1)
            end
            task.wait(0.2)
            local fadeDuration = 0.5
            local elapsed = 0
            while elapsed < fadeDuration do
                local dt = task.wait()
                elapsed = elapsed + dt
                local t = elapsed / fadeDuration
                pcall(function()
                    loaderGroup.BackgroundTransparency = 0.15 + (0.85 * t)
                    logoText.TextTransparency = t
                    statusText.TextTransparency = t
                    loadingBarBg.BackgroundTransparency = t
                    loadingBarFill.BackgroundTransparency = t
                    centerGlow.ImageTransparency = 0.85 + (0.15 * t)
                end)
            end
        end)
        if not success then warn("Loader err: " .. tostring(err)) end
        for idx, animGrad in ipairs(gradientAnimations) do
            if animGrad == fillgrad then table.remove(gradientAnimations, idx) break end
        end
        pcall(function() loaderGroup:Destroy() end)
        pcall(updatecolors)
        windowsframe.Visible = true
        if blur then blur.Enabled = moduleStates["blur effect"] end
        task.spawn(function()
            local windowsList = {}
            for _, win in pairs(categoryWindows) do table.insert(windowsList, win) end
            table.sort(windowsList, function(a, b) return a.Position.X.Offset < b.Position.X.Offset end)
            for _, win in ipairs(windowsList) do
                local originalPos = win.Position
                win.Position = originalPos - UDim2.new(0, 0, 0, 150)
                tweenservice:Create(win, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = originalPos}):Play()
                task.wait(0.08)
            end
        end)
    end)
end
pcall(showLoader)
local function makedrag(header, frame)
    local d, di, ds, sp
    header.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            d = true; ds = inp.Position; sp = frame.Position
            local c; c = inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then d = false; c:Disconnect() end end)
        end
    end)
    header.InputChanged:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseMovement then di = inp end end)
    table.insert(uiconns, uis.InputChanged:Connect(function(inp)
        if inp == di and d then
            local delta = inp.Position - ds
            frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset+delta.X, sp.Y.Scale, sp.Y.Offset+delta.Y)
        end
    end))
end
watermark = Instance.new("Frame")
watermark.Size = UDim2.new(0, 220, 0, 28); watermark.Position = UDim2.new(0, 15, 0, 15)
watermark.BackgroundColor3 = Color3.fromRGB(15, 15, 15); watermark.BackgroundTransparency = 0.1
watermark.BorderSizePixel = 0; watermark.Parent = gui
Instance.new("UICorner", watermark).CornerRadius = UDim.new(0, 6)
addshadow(watermark)
wmstroke = Instance.new("UIStroke")
wmstroke.Thickness = 1; wmstroke.Color = c_colors.outline
wmstroke.Transparency = 0; wmstroke.Parent = watermark
wmtitle = Instance.new("TextLabel")
wmtitle.Size = UDim2.new(0, 35, 1, 0); wmtitle.Position = UDim2.new(0, 10, 0, 0)
wmtitle.BackgroundTransparency = 1; wmtitle.Text = "jdk"
wmtitle.TextColor3 = c_colors.accent; wmtitle.Font = Enum.Font.MontserratBold; wmtitle.TextSize = 13
wmtitle.TextXAlignment = Enum.TextXAlignment.Left; wmtitle.Parent = watermark
wmtitle2 = Instance.new("TextLabel")
wmtitle2.Size = UDim2.new(0, 50, 1, 0); wmtitle2.Position = UDim2.new(0, 35, 0, 0)
wmtitle2.BackgroundTransparency = 1; wmtitle2.Text = "client"
wmtitle2.TextColor3 = c_colors.white; wmtitle2.Font = Enum.Font.Montserrat; wmtitle2.TextSize = 13
wmtitle2.TextXAlignment = Enum.TextXAlignment.Left; wmtitle2.Parent = watermark
wmtext = Instance.new("TextLabel")
wmtext.Size = UDim2.new(1, -85, 1, 0); wmtext.Position = UDim2.new(0, 75, 0, 0)
wmtext.BackgroundTransparency = 1; wmtext.Text = "fps: 60 | ping: 0ms"
wmtext.TextColor3 = c_colors.dim; wmtext.Font = Enum.Font.Montserrat; wmtext.TextSize = 11
wmtext.TextXAlignment = Enum.TextXAlignment.Right; wmtext.Parent = watermark
targethudframe = Instance.new("Frame")
targethudframe.Name = "jdk_targethud"
targethudframe.Size = UDim2.new(0, 190, 0, 60)
targethudframe.Position = UDim2.new(0.5, -95, 0.7, 0)
targethudframe.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
targethudframe.BackgroundTransparency = 0.2
targethudframe.BorderSizePixel = 0
targethudframe.Visible = false
targethudframe.Parent = gui
Instance.new("UICorner", targethudframe).CornerRadius = UDim.new(0, 8)
addshadow(targethudframe)
targethudBgGrad = Instance.new("UIGradient")
targethudBgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 35))
})
targethudBgGrad.Rotation = 90
targethudBgGrad.Parent = targethudframe
targethudstroke = Instance.new("UIStroke")
targethudstroke.Thickness = 1.5
targethudstroke.Color = c_colors.outline
targethudstroke.Parent = targethudframe
targethudgrad = Instance.new("UIGradient")
targethudgrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, c_colors.accent),
    ColorSequenceKeypoint.new(0.5, c_colors.accent2),
    ColorSequenceKeypoint.new(1, c_colors.accent3)
})
targethudgrad.Parent = targethudstroke
table.insert(gradientAnimations, targethudgrad)
targethudavatar = Instance.new("ImageLabel")
targethudavatar.Size = UDim2.new(0, 44, 0, 44)
targethudavatar.Position = UDim2.new(0, 8, 0.5, -22)
targethudavatar.BackgroundColor3 = c_colors.sbg
targethudavatar.BorderSizePixel = 0
targethudavatar.Parent = targethudframe
Instance.new("UICorner", targethudavatar).CornerRadius = UDim.new(0, 6)
targethudname = Instance.new("TextLabel")
targethudname.Size = UDim2.new(1, -64, 0, 16)
targethudname.Position = UDim2.new(0, 58, 0, 10)
targethudname.BackgroundTransparency = 1
targethudname.TextColor3 = c_colors.white
targethudname.TextSize = 11
targethudname.Font = Enum.Font.MontserratBold
targethudname.TextXAlignment = Enum.TextXAlignment.Left
targethudname.Parent = targethudframe
targethudhpbg = Instance.new("Frame")
targethudhpbg.Size = UDim2.new(1, -64, 0, 8)
targethudhpbg.Position = UDim2.new(0, 58, 0, 30)
targethudhpbg.BackgroundColor3 = c_colors.sbg
targethudhpbg.BorderSizePixel = 0
targethudhpbg.Parent = targethudframe
Instance.new("UICorner", targethudhpbg).CornerRadius = UDim.new(0, 4)
targethudhpbar = Instance.new("Frame")
targethudhpbar.Size = UDim2.new(1, 0, 1, 0)
targethudhpbar.BackgroundColor3 = c_colors.accent
targethudhpbar.BorderSizePixel = 0
targethudhpbar.Parent = targethudhpbg
Instance.new("UICorner", targethudhpbar).CornerRadius = UDim.new(0, 4)
targethudhpgrad = Instance.new("UIGradient")
targethudhpgrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, c_colors.accent),
    ColorSequenceKeypoint.new(0.5, c_colors.accent2),
    ColorSequenceKeypoint.new(1, c_colors.accent3)
})
targethudhpgrad.Parent = targethudhpbar
targethudhptext = Instance.new("TextLabel")
targethudhptext.Size = UDim2.new(1, -64, 0, 12)
targethudhptext.Position = UDim2.new(0, 58, 0, 40)
targethudhptext.BackgroundTransparency = 1
targethudhptext.TextColor3 = c_colors.dim
targethudhptext.TextSize = 9
targethudhptext.Font = Enum.Font.Montserrat
targethudhptext.TextXAlignment = Enum.TextXAlignment.Left
targethudhptext.Parent = targethudframe
local lastTargetUpdate = 0
local function updatetargethud(target)
    if not target or not target.char or not target.hrp then return end
    lastTargetUpdate = tick()
    targethudframe.Visible = true
    targethudname.Text = string.lower(target.nm or "unknown")
    local hp = target.char:GetAttribute("Health") or (target.char:FindFirstChildOfClass("Humanoid") and target.char:FindFirstChildOfClass("Humanoid").Health) or 100
    local maxHp = target.char:GetAttribute("MaxHealth") or (target.char:FindFirstChildOfClass("Humanoid") and target.char:FindFirstChildOfClass("Humanoid").MaxHealth) or 100
    hp = math.clamp(hp, 0, maxHp)
    maxHp = math.max(maxHp, 1)
    local pct = hp / maxHp
    tweenservice:Create(targethudhpbar, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
    targethudhptext.Text = string.format("hp: %d / %d", math.round(hp), math.round(maxHp))
    if target.isP and target.obj then
        targethudavatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(target.obj.UserId) .. "&width=150&height=150&format=png"
    else
        targethudavatar.Image = "rbxassetid://10747372990"
    end
end
task.spawn(function()
    while true do
        if targethudframe.Visible and tick() - lastTargetUpdate > 3 then
            targethudframe.Visible = false
        end
        task.wait(0.5)
    end
end)
makedrag(targethudframe, targethudframe)
task.spawn(function()
    local lasttime = tick(); local framecount = 0; local fps = 60
    table.insert(uiconns, runservice.Heartbeat:Connect(function()
        framecount = framecount + 1
        local now = tick()
        if now - lasttime >= 1 then
            fps = framecount; framecount = 0; lasttime = now
        end
    end))
    while gui and gui.Parent do
        local ping = 0
        pcall(function() ping = math.round(plr:GetNetworkPing() * 1000) end)
        pcall(function() wmtext.Text = string.format("fps: %d | ping: %dms", fps, ping) end)
        task.wait(0.5)
    end
end)
local function getkeyname(key)
    local names = {
        [Enum.KeyCode.LeftShift] = "lshift", [Enum.KeyCode.RightShift] = "rshift",
        [Enum.KeyCode.LeftControl] = "lctrl", [Enum.KeyCode.RightControl] = "rctrl",
        [Enum.KeyCode.LeftAlt] = "lalt", [Enum.KeyCode.RightAlt] = "ralt"
    }
    if names[key] then return names[key] end
    return string.lower(tostring(key):gsub("Enum.KeyCode.", ""))
end
local function createkeybindselector(cont, modulename, defaultkey)
    local fr = Instance.new("Frame"); fr.Size = UDim2.new(1,0,0,28); fr.BackgroundTransparency = 1; fr.Parent = cont
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5,-4,1,0); lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = "bind:"; lbl.TextColor3 = c_colors.dim; lbl.Font = Enum.Font.Montserrat; lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = fr
    local bindbtn = Instance.new("TextButton")
    bindbtn.Size = UDim2.new(0.5,-8,0,22); bindbtn.Position = UDim2.new(0.5,4,0.5,-11)
    bindbtn.BackgroundColor3 = c_colors.sbg; bindbtn.BorderSizePixel = 0; bindbtn.Text = ""
    bindbtn.Parent = fr
    Instance.new("UICorner", bindbtn).CornerRadius = UDim.new(0,4)
    local bindStroke = Instance.new("UIStroke")
    bindStroke.Color = c_colors.outline; bindStroke.Thickness = 1; bindStroke.Parent = bindbtn
    local btnlbl = Instance.new("TextLabel")
    btnlbl.Size = UDim2.new(1,0,1,0); btnlbl.BackgroundTransparency = 1
    btnlbl.Text = string.upper(getkeyname(defaultkey)); btnlbl.TextColor3 = c_colors.text; btnlbl.Font = Enum.Font.MontserratBold; btnlbl.TextSize = 10; btnlbl.Parent = bindbtn
    local listening = false; local currentkey = defaultkey
    local function setkey(key)
        if type(key) == "string" then
            for _, k in pairs(Enum.KeyCode:GetEnumItems()) do
                if string.lower(k.Name) == string.lower(key) then key = k; break end
            end
        end
        currentkey = key; btnlbl.Text = string.upper(getkeyname(currentkey)); btnlbl.TextColor3 = c_colors.text
        keybindOverrides[modulename] = currentkey
    end
    bindbtn.MouseButton1Click:Connect(function()
        listening = true; btnlbl.Text = "..."; btnlbl.TextColor3 = c_colors.accent
        pcall(function() tweenservice:Create(bindStroke, TweenInfo.new(0.2), {Color = c_colors.accent}):Play() end)
        local con
        con = uis.InputBegan:Connect(function(inp, gpe)
            if gpe then return end
            if inp.KeyCode ~= Enum.KeyCode.Unknown then
                setkey(inp.KeyCode); listening = false; con:Disconnect()
                pcall(function() tweenservice:Create(bindStroke, TweenInfo.new(0.2), {Color = c_colors.outline}):Play() end)
            end
        end)
        task.delay(5, function() if listening then listening = false; btnlbl.Text = string.upper(getkeyname(currentkey)); btnlbl.TextColor3 = c_colors.text; pcall(function() tweenservice:Create(bindStroke, TweenInfo.new(0.2), {Color = c_colors.outline}):Play() end) end end)
    end)
    return {get=function() return currentkey end, set=setkey}
end
local alframe = Instance.new("Frame")
alframe.Size = UDim2.new(0, 180, 0, 0); alframe.Position = UDim2.new(1, -185, 0, 50)
alframe.BackgroundTransparency = 1; alframe.Parent = gui
local allayout = Instance.new("UIListLayout")
allayout.SortOrder = Enum.SortOrder.LayoutOrder; allayout.Padding = UDim.new(0, 0); allayout.Parent = alframe
allayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
local arraylistcon = nil
local function updatearraylist()
    if not alframe then return end
    for _, lbl in pairs(alLabels) do pcall(function() lbl:Destroy() end) end; alLabels = {}
    local sorted = {}; for n,s in pairs(moduleStates) do if s then table.insert(sorted, n) end end
    table.sort(sorted, function(a, b) return #a > #b end)
    local labelstocolor = {}
    for i, n in ipairs(sorted) do
        local textw = #n * 7 + 25
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, textw, 0, 22)
        container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        container.BorderSizePixel = 0; container.ClipsDescendants = true
        container.Parent = alframe; container.LayoutOrder = i
        local bggrad = Instance.new("UIGradient")
        bggrad.Color = ColorSequence.new(Color3.fromRGB(0,0,0))
        bggrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0.3)
        })
        bggrad.Parent = container
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 2, 1, 0); bar.Position = UDim2.new(1, -2, 0, 0)
        bar.BackgroundColor3 = c_colors.accent; bar.BorderSizePixel = 0; bar.ZIndex = 2; bar.Parent = container
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -8, 1, 0); lbl.Position = UDim2.new(0, 0, 0, 0)
        lbl.BackgroundTransparency = 1; lbl.Text = string.lower(n); lbl.TextColor3 = c_colors.accent
        lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Right; lbl.Parent = container
        local txtstroke = Instance.new("UIStroke")
        txtstroke.Thickness = 1
        txtstroke.Transparency = 0.5
        txtstroke.Color = Color3.fromRGB(0,0,0)
        txtstroke.Parent = lbl
        container.Position = UDim2.new(0, 30, 0, 0)
        tweenservice:Create(container, TweenInfo.new(0.25 + i * 0.03, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        table.insert(labelstocolor, {lbl = lbl, bar = bar, index = i})
        table.insert(alLabels, container)
    end
    if arraylistcon then arraylistcon:Disconnect(); arraylistcon = nil end
    if #labelstocolor > 0 then
        arraylistcon = runservice.Heartbeat:Connect(function()
            if not alframe or not alframe.Parent then
                if arraylistcon then arraylistcon:Disconnect(); arraylistcon = nil end
                return
            end
            local t = tick()
            for _, item in ipairs(labelstocolor) do
                local phase = (t * 0.8 + item.index * 0.1) % 1
                local color = c_colors.accent
                if phase > 0.5 then
                    color = c_colors.accent:Lerp(c_colors.accent2, (phase - 0.5) * 2)
                else
                    color = c_colors.accent2:Lerp(c_colors.accent, phase * 2)
                end
                pcall(function() item.lbl.TextColor3 = color; item.bar.BackgroundColor3 = color end)
            end
        end)
    end
end
local httprequest = request or http_request or (syn and syn.request) or (http and http.request)
local function getnetworkfile(url)
    local s, r = pcall(function() return game:HttpGet(url) end)
    if s and r and #r > 0 then return r end
    if httprequest then
        local success, res = pcall(function() return httprequest({Url = url, Method = "GET"}) end)
        if success and res and res.StatusCode == 200 and res.Body then return res.Body end
    end
    return nil
end
local function downloadfile(filename)
    local localpath = "jdkclient/" .. filename
    if readfile then
        if pcall(readfile, localpath) or pcall(readfile, filename) then return end
    end
    local url = "https://raw.githubusercontent.com/jdk-1337/jdkclient/main/" .. filename
    local body = getnetworkfile(url)
    if body and #body > 0 then
        pcall(function()
            local folderexists = false
            if isfolder then pcall(function() folderexists = isfolder("jdkclient") end) end
            if not folderexists and makefolder then pcall(makefolder, "jdkclient") end
        end)
        if writefile then pcall(writefile, localpath, body) end
    end
end
local itemimages = {
    leather_boots = "Leather_Armor.png", leather_chestplate = "Leather_Armor.png", leather_helmet = "Leather_Armor.png",
    iron_boots = "Iron_Armor.png", iron_chestplate = "Iron_Armor.png", iron_helmet = "Iron_Armor.png",
    diamond_boots = "Diamond_Armor.png", diamond_chestplate = "Diamond_Armor.png", diamond_helmet = "Diamond_Armor.png",
    emerald_boots = "Emerald_Armor.png", emerald_chestplate = "Emerald_Armor.png", emerald_helmet = "Emerald_Armor.png",
    warrior_boots = "Warrior_Armor.png", warrior_chestplate = "Warrior_Armor.png", warrior_helmet = "Warrior_Armor.png",
    void_boots = "Void_Chestplate.png", void_chestplate = "Void_Chestplate.png", void_helmet = "Void_Chestplate.png",
    wood_sword = "Wood_Sword.png", stone_sword = "Stone_Sword.png", iron_sword = "Iron_Sword.png",
    diamond_sword = "Diamond_Sword.png", emerald_sword = "Emerald_Sword.png"
}
local uniquefiles = {
    "Leather_Armor.png", "Iron_Armor.png", "Diamond_Armor.png", "Emerald_Armor.png",
    "Warrior_Armor.png", "Void_Chestplate.png", "Wood_Sword.png", "Stone_Sword.png",
    "Iron_Sword.png", "Diamond_Sword.png", "Emerald_Sword.png"
}
task.spawn(function()
    for _, fn in ipairs(uniquefiles) do pcall(downloadfile, fn) end
end)
local function getactualpath(filename)
    local resolved = "jdkclient/" .. filename
    if isfile then
        if pcall(isfile, resolved) then return resolved end
        if pcall(isfile, filename) then return filename end
    end
    return resolved
end
local function applycustomasset(imgobj, filename)
    local path = getactualpath(filename)
    if getcustomasset then
        pcall(function()
            local asset = getcustomasset(path)
            if not asset then asset = getcustomasset("workspace/" .. path) end
            if asset then imgobj.Image = asset end
        end)
    end
end
local function isswordtool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local n = string.lower(tool.Name)
    local kw = {"sword", "blade", "dagger", "hammer", "scythe", "axe", "rageblade", "emerald_sword", "wood_sword", "stone_sword", "iron_sword", "diamond_sword"}
    for _, k in ipairs(kw) do if string.find(n, k) then return true end end
    if tool:FindFirstChild("SwordHandle") or tool:FindFirstChild("Handle") then
        local handle = tool:FindFirstChild("SwordHandle") or tool:FindFirstChild("Handle")
        if handle and handle:FindFirstChildOfClass("SpecialMesh") then return true end
    end
    return false
end
local function getsword()
    if not plr.Character then return nil end
    for _, item in ipairs(plr.Character:GetChildren()) do
        if isswordtool(item) then return item end
    end
    local bp = plr:FindFirstChild("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if isswordtool(item) then return item end
        end
    end
    return nil
end
local function equipsword(sword)
    if not sword or not plr.Character then return end
    if sword.Parent == plr.Character then return end
    pcall(function()
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(sword) end
    end)
end
local function getRemoteName(func)
    if not func or type(func) ~= "function" then return nil end
    if not debug or not debug.getconstants then return nil end
    local s, constants = pcall(debug.getconstants, func)
    if not s or not constants then return nil end
    for i, v in ipairs(constants) do
        if v == "Client" or v == "Get" then
            local nextval = constants[i + 1]
            if type(nextval) == "string" and #nextval > 0 then
                return nextval
            end
        end
    end
    for _, v in ipairs(constants) do
        if type(v) == "string" and v ~= "Client" and v ~= "Get" and #v > 0 then
            return v
        end
    end
    return nil
end
local function resolveRemotes()
    pcall(function()
        if not getgenv().PlaceBlockRemote then
            getgenv().PlaceBlockRemote = rep:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@easy-games"):WaitForChild("block-engine"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("PlaceBlock")
        end
    end)
    pcall(function()
        if bw.Flamework then
            local r = bw.Flamework:Get("SwordHit") or bw.Flamework:Get("swordHit")
            if r then
                getgenv().SwordHitWrapper = r
                getgenv().SwordHitRemote = r.instance
            end
        end
        if not getgenv().SwordHitWrapper and bw.Sword and bw.Flamework then
            local func = bw.Sword.sendServerRequest
            if not func then
                for _, f in pairs(bw.Sword) do
                    if type(f) == "function" then
                        local rn = getRemoteName(f)
                        if rn then
                            local r = bw.Flamework:Get(rn)
                            if r then
                                getgenv().SwordHitWrapper = r
                                getgenv().SwordHitRemote = r.instance
                                break
                            end
                        end
                    end
                end
            else
                local rn = getRemoteName(func)
                if rn then
                    local r = bw.Flamework:Get(rn)
                    if r then
                        getgenv().SwordHitWrapper = r
                        getgenv().SwordHitRemote = r.instance
                    end
                end
            end
        end
    end)
end
local function makeWritable(t)
    if type(t) ~= "table" then return end
    pcall(function() setreadonly(t, false) end)
    local mt = getrawmetatable and getrawmetatable(t)
    if mt then
        pcall(function() setreadonly(mt, false) end)
        mt.__newindex = nil
    end
end
local bw = {}; local knitok = false
bw.getBlockPosition = function(pos)
    if bw.BlockController then
        local success, res = pcall(function() return bw.BlockController:getBlockPosition(pos) end)
        if success and res then return res end
    end
    return Vector3.new(math.round(pos.X / 3), math.round(pos.Y / 3), math.round(pos.Z / 3))
end
bw.getBlockAt = function(gridPos)
    if bw.BlockController and bw.BlockController:getStore() then
        local success, res = pcall(function() return bw.BlockController:getStore():getBlockAt(gridPos) end)
        if success and res then return res end
    end
    local worldPos = gridPos * 3
    local parts = workspace:GetPartBoundsInBox(CFrame.new(worldPos), Vector3.new(2.9, 2.9, 2.9))
    for _, p in ipairs(parts) do
        if p:IsA("BasePart") and not p:IsDescendantOf(plr.Character) and p.CanCollide then
            return p
        end
    end
    return nil
end
bw.placeBlock = function(pos, item)
    if bw.blockplacerinst and bw.BlockController then
        local success, res = pcall(function()
            bw.blockplacerinst.blockType = item
            return bw.blockplacerinst:placeBlock(bw.getBlockPosition(pos))
        end)
        if success and res then return res end
    end
    local gridpos = bw.getBlockPosition(pos)
    local placedata = {blockType = item, position = gridpos, blockPosition = gridpos, blockData = 0}
    local remote = findRemote("PlaceBlock") or getgenv().PlaceBlockRemote
    if remote then
        if remote:IsA("RemoteFunction") then
            pcall(function() remote:InvokeServer(placedata) end)
        else
            pcall(function() remote:FireServer(placedata) end)
        end
    end
end
spawn(function()
    for i = 1, 100 do
        for _, v in ipairs(rep:GetDescendants()) do
            if v.Name == "KnitClient" and v:IsA("ModuleScript") then
                local s2, kn = pcall(function() return require(v) end)
                if s2 then
                    bw.Knit = kn; knitok = true
                    pcall(function()
                        bw.Spring = kn.Controllers.SprintController or kn.Controllers.SprintingController
                        bw.Sword = kn.Controllers.SwordController or kn.Controllers.WeaponController
                        bw.Viewmodel = kn.Controllers.ViewmodelController
                        bw.BlockBreak = kn.Controllers.BlockBreakController or kn.Controllers.BlockDestructionController
                        bw.Balloon = kn.Controllers.BalloonController
                        bw.ProjectileController = kn.Controllers.ProjectileController
                        pcall(function()
                             local CannonHandController = kn.Controllers.CannonHandController
                             if CannonHandController then
                                  getgenv().prehitCannons = getgenv().prehitCannons or {}
                                  local CannonAimRemoteName = nil
                                  pcall(function()
                                      local CannonController = kn.Controllers.CannonController
                                      if CannonController then
                                          for name, func in pairs(CannonController) do
                                              if type(func) == "function" then
                                                  local ok, consts = pcall(debug.getconstants, func)
                                                  if ok and consts then
                                                      local ind = table.find(consts, "Client")
                                                      if ind then
                                                          CannonAimRemoteName = consts[ind + 1]
                                                          break
                                                      end
                                                  end
                                                  for i = 1, 10 do
                                                      local ok2, proto = pcall(debug.getproto, func, i)
                                                      if ok2 and proto then
                                                          local ok3, consts2 = pcall(debug.getconstants, proto)
                                                          if ok3 and consts2 then
                                                              local ind2 = table.find(consts2, "Client")
                                                              if ind2 then
                                                                  CannonAimRemoteName = consts2[ind2 + 1]
                                                                  break
                                                              end
                                                          end
                                                      end
                                                  end
                                                  if CannonAimRemoteName then break end
                                              end
                                          end
                                      end
                                  end)
                                  pcall(function()
                                      local CannonController = kn.Controllers.CannonController
                                      if CannonController then
                                          if not getgenv().oldStartAiming then
                                              getgenv().oldStartAiming = CannonController.startAiming
                                              CannonController.startAiming = function(self, block, ...)
                                                  local res = getgenv().oldStartAiming(self, block, ...)
                                                  if moduleStates["cannon aimbot"] and block and getgenv().cannonWaypointPos then
                                                      task.spawn(function()
                                                          task.wait(0.1)
                                                          getgenv().aimCannonAtWaypoint(block)
                                                      end)
                                                  end
                                                  return res
                                              end
                                          end
                                      end
                                  end)
                                  getgenv().CannonAimRemoteName = CannonAimRemoteName
                                  getgenv().cannonWaypointPos = nil
                                  getgenv().cannonWaypointVisual = nil
                                  getgenv().aimedCannons = {}
                                  getgenv().cannonLaunchSpeed = getgenv().cannonLaunchSpeed or 120
                                  getgenv().aimCannonAtWaypoint = function(block)
                                      if not block or not getgenv().cannonWaypointPos then return end
                                      local pos
                                      if typeof(block) == "Instance" then
                                          pos = block:IsA("Model") and (block.PrimaryPart and block.PrimaryPart.Position or block:GetPivot().Position) or (block:IsA("BasePart") and block.Position)
                                      elseif typeof(block) == "Vector3" then
                                          pos = block
                                      end
                                      if not pos then return end
                                      local blockpos = bw.getBlockPosition(pos)
                                      local remoteName = getgenv().CannonAimRemoteName
                                      if not remoteName then
                                          pcall(function()
                                              local CannonController = kn.Controllers.CannonController
                                              if CannonController then
                                                  for name, func in pairs(CannonController) do
                                                      if type(func) == "function" then
                                                          local ok, consts = pcall(debug.getconstants, func)
                                                          if ok and consts then
                                                              local ind = table.find(consts, "Client")
                                                              if ind then
                                                                  remoteName = consts[ind + 1]
                                                                  break
                                                              end
                                                          end
                                                          for i = 1, 10 do
                                                              local ok2, proto = pcall(debug.getproto, func, i)
                                                              if ok2 and proto then
                                                                  local ok3, consts2 = pcall(debug.getconstants, proto)
                                                                  if ok3 and consts2 then
                                                                      local ind2 = table.find(consts2, "Client")
                                                                      if ind2 then
                                                                          remoteName = consts2[ind2 + 1]
                                                                          break
                                                                      end
                                                                  end
                                                              end
                                                          end
                                                          if remoteName then break end
                                                      end
                                                  end
                                              end
                                          end)
                                          getgenv().CannonAimRemoteName = remoteName
                                      end
                                      if blockpos and remoteName then
                                          local diff = getgenv().cannonWaypointPos - pos
                                          local horizontalDist = Vector3.new(diff.X, 0, diff.Z).Magnitude
                                          local v = getgenv().cannonLaunchSpeed
                                          local g = workspace.Gravity
                                          local d = horizontalDist
                                          local y = diff.Y
                                          local val = v^4 - g * (g * d^2 + 2 * y * v^2)
                                          local angle
                                          if val >= 0 and d > 0.1 then
                                              angle = math.atan((v^2 - math.sqrt(val)) / (g * d))
                                          else
                                              angle = math.rad(45)
                                          end
                                          local dir2D = Vector3.new(diff.X, 0, diff.Z).Unit
                                          local aimDir = dir2D * math.cos(angle) + Vector3.new(0, math.sin(angle), 0)
                                          local lookVector = aimDir * 200
                                          pcall(function()
                                              local flamework = bw.Flamework or (rep.TS:FindFirstChild("remotes") and require(rep.TS.remotes).default.Client)
                                              if flamework then
                                                  flamework:Get(remoteName):SendToServer({
                                                      cannonBlockPos = blockpos,
                                                      lookVector = lookVector
                                                  })
                                              end
                                          end)
                                          pcall(function()
                                              workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.p, pos + aimDir * 10)
                                          end)
                                      end
                                  end
                                  getgenv().getCannonFromSeat = function(seat)
                                      if not seat then return nil end
                                      if seat.Name == "cannon" or seat:GetAttribute("BlockName") == "cannon" then
                                          return seat
                                      end
                                      local p = seat.Parent
                                      while p and p ~= workspace do
                                          if p.Name == "cannon" or p:GetAttribute("BlockName") == "cannon" then
                                              return p
                                          end
                                          p = p.Parent
                                      end
                                      return nil
                                   end
                                  getgenv().cannonNotify = function(text)
                                      task.spawn(function()
                                          local label = Instance.new("TextLabel")
                                          label.Size = UDim2.new(0, 260, 0, 32)
                                          label.Position = UDim2.new(0.5, -130, 0, -50)
                                          label.BackgroundColor3 = c_colors.bg
                                          label.BackgroundTransparency = 0.1
                                          label.TextColor3 = c_colors.text
                                          label.TextSize = 12
                                          label.Font = Enum.Font.Montserrat
                                          label.Text = text
                                          label.BorderSizePixel = 0
                                          label.Parent = gui
                                          local corner = Instance.new("UICorner")
                                          corner.CornerRadius = UDim.new(0, 6)
                                          corner.Parent = label
                                          local stroke = Instance.new("UIStroke")
                                          stroke.Color = c_colors.outline
                                          stroke.Thickness = 1
                                          stroke.Parent = label
                                          label:TweenPosition(UDim2.new(0.5, -130, 0.08, 0), "Out", "Quint", 0.4, true)
                                          task.wait(2.2)
                                          label:TweenPosition(UDim2.new(0.5, -130, 0, -50), "In", "Quint", 0.4, true)
                                          task.wait(0.4)
                                          label:Destroy()
                                      end)
                                  end
                                  getgenv().createWaypointVisual = function(pos)
                                      if getgenv().cannonWaypointVisual then
                                          getgenv().cannonWaypointVisual:Destroy()
                                      end
                                      local folder = Instance.new("Folder")
                                      folder.Name = "jdkclient_waypoint"
                                      folder.Parent = workspace
                                      local ring = Instance.new("Part")
                                      ring.Shape = Enum.PartType.Cylinder
                                      ring.Size = Vector3.new(0.2, 5, 5)
                                      ring.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
                                      ring.Anchored = true
                                      ring.CanCollide = false
                                      ring.Material = Enum.Material.Neon
                                      ring.Color = c_colors.accent2
                                      ring.Transparency = 0.4
                                      ring.Parent = folder
                                      local innerRing = Instance.new("Part")
                                      innerRing.Shape = Enum.PartType.Cylinder
                                      innerRing.Size = Vector3.new(0.25, 2.5, 2.5)
                                      innerRing.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
                                      innerRing.Anchored = true
                                      innerRing.CanCollide = false
                                      innerRing.Material = Enum.Material.Neon
                                      innerRing.Color = c_colors.accent
                                      innerRing.Transparency = 0.5
                                      innerRing.Parent = folder
                                      local bb = Instance.new("BillboardGui")
                                      bb.Size = UDim2.new(0, 150, 0, 38)
                                      bb.StudsOffset = Vector3.new(0, 3, 0)
                                      bb.AlwaysOnTop = true
                                      bb.Adornee = ring
                                      bb.Parent = folder
                                      local frame = Instance.new("Frame")
                                      frame.Size = UDim2.new(1, 0, 1, 0)
                                      frame.BackgroundColor3 = c_colors.bg
                                      frame.BackgroundTransparency = 0.1
                                      frame.BorderSizePixel = 0
                                      frame.Parent = bb
                                      local corner = Instance.new("UICorner")
                                      corner.CornerRadius = UDim.new(0, 6)
                                      corner.Parent = frame
                                      local stroke = Instance.new("UIStroke")
                                      stroke.Color = c_colors.outline
                                      stroke.Thickness = 1
                                      stroke.Parent = frame
                                      local title = Instance.new("TextLabel")
                                      title.Size = UDim2.new(1, 0, 0.5, 0)
                                      title.BackgroundTransparency = 1
                                      title.Text = "Cannon Target"
                                      title.TextColor3 = c_colors.text
                                      title.TextSize = 11
                                      title.Font = Enum.Font.MontserratBold
                                      title.Parent = frame
                                      local distLabel = Instance.new("TextLabel")
                                      distLabel.Size = UDim2.new(1, 0, 0.5, 0)
                                      distLabel.Position = UDim2.new(0, 0, 0.5, 0)
                                      distLabel.BackgroundTransparency = 1
                                      distLabel.Text = "0m"
                                      distLabel.TextColor3 = c_colors.accent2
                                      distLabel.TextSize = 12
                                      distLabel.Font = Enum.Font.Montserrat
                                      distLabel.Parent = frame
                                      task.spawn(function()
                                          while folder.Parent do
                                              local char = plr.Character
                                              local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                              if hrp then
                                                  local distance = math.round((hrp.Position - pos).Magnitude)
                                                  distLabel.Text = tostring(distance) .. " studs"
                                              end
                                              task.wait(0.1)
                                          end
                                      end)
                                      getgenv().cannonWaypointVisual = folder
                                  end
                                 local _cachedInvUtil = nil
                                 local function getInvUtil()
                                     if not _cachedInvUtil then pcall(function() _cachedInvUtil = require(rep.TS.inventory["inventory-util"]).InventoryUtil end) end
                                     return _cachedInvUtil
                                 end
                                 getgenv().getWoodenPickaxe = function()
                                     local success, res = pcall(function()
                                         local inventoryutil = getInvUtil()
                                         if not inventoryutil then return nil end
                                         local inv = inventoryutil.getInventory(plr)
                                         if inv and inv.items then
                                             for _, item in ipairs(inv.items) do
                                                 if string.find(item.itemType, "pickaxe") then
                                                      return item
                                                 end
                                             end
                                         end
                                         return nil
                                     end)
                                     return success and res or nil
                                 end
                                 getgenv().switchItem = function(itemType)
                                     pcall(function()
                                         local inventoryutil = getInvUtil()
                                         if not inventoryutil then return end
                                         local inv = inventoryutil.getInventory(plr)
                                         if inv and inv.items then
                                             for _, item in ipairs(inv.items) do
                                                 if item.itemType == itemType then
                                                     local handCheck = plr.Character and plr.Character:FindFirstChild("HandInvItem")
                                                     if handCheck and handCheck.Value ~= item.tool then
                                                         local flamework = bw.Flamework or (rep.TS:FindFirstChild("remotes") and require(rep.TS.remotes).default.Client)
                                                         if flamework then
                                                             flamework:Get("EquipItem"):CallServerAsync({hand = item.tool})
                                                         end
                                                         handCheck.Value = item.tool
                                                     end
                                                     break
                                                 end
                                             end
                                         end
                                     end)
                                 end
                                  getgenv().damageBlockRemote = function(blockPos, itemType)
                                      pcall(function()
                                          local clientDmgBlock = require(rep['rbxts_include']['node_modules']['@easy-games']['block-engine'].out.shared.remotes).BlockEngineRemotes.Client:Get('DamageBlock')
                                          if clientDmgBlock then
                                              clientDmgBlock:CallServerAsync({
                                                  blockRef = {blockPosition = blockPos},
                                                  hitPosition = blockPos * 3,
                                                  hitNormal = Vector3.FromNormalId(Enum.NormalId.Top),
                                                  hitSource = itemType or "wood_pickaxe"
                                              })
                                          end
                                      end)
                                  end
                                 getgenv().destroyBlockLocally = function(blockPos)
                                     pcall(function()
                                         local bdata = bw.getBlockAt(blockPos)
                                         if bdata then
                                             if typeof(bdata) == "Instance" then
                                                 bdata:Destroy()
                                             elseif typeof(bdata) == "table" and bdata.blockInstance then
                                                 bdata.blockInstance:Destroy()
                                             end
                                         end
                                         local worldPos = blockPos * 3
                                         local parts = workspace:GetPartBoundsInBox(CFrame.new(worldPos), Vector3.new(3.1, 3.1, 3.1))
                                         for _, p in ipairs(parts) do
                                             if p.Name == "cannon" or p:GetAttribute("BlockName") == "cannon" then
                                                 p:Destroy()
                                             end
                                         end
                                     end)
                                 end
                                    local function performAssister(block)
                                        local pickaxe = getgenv().getWoodenPickaxe()
                                        if not pickaxe then return end
                                        local pos
                                        pcall(function()
                                            if typeof(block) == "Instance" then
                                                pos = block:IsA("BasePart") and block.Position or (block:IsA("Model") and (block.PrimaryPart and block.PrimaryPart.Position or block:GetPivot().Position))
                                            end
                                        end)
                                        if not pos then return end
                                        local blockPos = bw.getBlockPosition(pos)
                                        if not blockPos then return end
                                        task.wait(0.05)
                                        getgenv().switchItem(pickaxe.itemType)
                                        for i = 1, 2 do
                                            task.spawn(function()
                                                pcall(function()
                                                    getgenv().damageBlockRemote(blockPos, pickaxe.itemType)
                                                end)
                                            end)
                                        end
                                    end
                                  local oldLaunch = CannonHandController.launchSelf
                                  CannonHandController.launchSelf = function(self, block)
                                      local res = oldLaunch(self, block)
                                      if moduleStates["cannon assister"] and block then
                                          task.spawn(performAssister, block)
                                      end
                                      if moduleStates["cannon aimbot"] then
                                          pcall(function()
                                              local hum = plr.Character and plr.Character:FindFirstChild("Humanoid")
                                              if hum then
                                                  task.spawn(function()
                                                      task.wait(0.05)
                                                      hum:ChangeState(Enum.HumanoidStateType.Jumping)
                                                  end)
                                              end
                                          end)
                                      end
                                      return res
                                  end
                             end
                         end)
                        for name, controller in pairs(kn.Controllers) do
                            local ln = string.lower(name)
                            if string.find(ln, "placement") or string.find(ln, "placer") then
                                bw.BlockPlacerController = controller
                            end
                            if string.find(ln, "hand") or string.find(ln, "inventory") then
                                bw.HandController = controller
                            end
                        end
                        bw.CombatConstant = require(rep.TS.combat["combat-constant"]).CombatConstant
                        bw.ItemMeta = debug.getupvalue(require(rep.TS.item["item-meta"]).getItemMeta, 1) or {}
                        pcall(function() bw.Flamework = require(rep.TS.remotes).default.Client end)
                        pcall(function() bw.KB = require(rep.TS.damage["knockback-util"]).KnockbackUtil end)
                        pcall(function()
                            bw.BlockController = require(rep["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out).BlockEngine
                            bw.BlockEngine = require(plr.PlayerScripts.TS.lib["block-engine"]["client-block-engine"]).ClientBlockEngine
                            bw.BlockPlacer = require(rep["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client.placement["block-placer"]).BlockPlacer
                            bw.blockplacerinst = bw.BlockPlacer.new(bw.BlockEngine, "wool_white")
                        end)
                    end)
                end
            end
        end
        if not knitok and i % 4 == 0 then
            pcall(function()
                for _, v in ipairs(getgc(true)) do
                    if type(v) == "table" then
                        if rawget(v, "swingSwordAtMouse") and not bw.Sword then bw.Sword = v; knitok = true end
                        if rawget(v, "startSprinting") and not bw.Spring then bw.Spring = v end
                        if (rawget(v, "blockPlacer") or rawget(v, "placeBlock")) and not bw.BlockPlacerController then bw.BlockPlacerController = v end
                        if rawget(v, "calculateImportantLaunchValues") and not bw.ProjectileController then bw.ProjectileController = v end
                        if (rawget(v, "setHandInstance") or rawget(v, "equipItem")) and not bw.HandController then bw.HandController = v end
                    end
                end
            end)
            if knitok then
                pcall(function()
                    bw.CombatConstant = require(rep.TS.combat["combat-constant"]).CombatConstant
                    bw.ItemMeta = debug.getupvalue(require(rep.TS.item["item-meta"]).getItemMeta, 1) or {}
                    pcall(function() bw.Flamework = require(rep.TS.remotes).default.Client end)
                    pcall(function() bw.KB = require(rep.TS.damage["knockback-util"]).KnockbackUtil end)
                    pcall(function()
                        bw.BlockController = require(rep["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out).BlockEngine
                        bw.BlockEngine = require(plr.PlayerScripts.TS.lib["block-engine"]["client-block-engine"]).ClientBlockEngine
                        bw.BlockPlacer = require(rep["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client.placement["block-placer"]).BlockPlacer
                        bw.blockplacerinst = bw.BlockPlacer.new(bw.BlockEngine, "wool_white")
                    end)
                end)
            end
        end
        if knitok then break end
        task.wait(0.5)
    end
end)
pcall(function()
    if getgenv().oldnamecall then
        hookmetamethod(game, "__namecall", getgenv().oldnamecall)
        getgenv().oldnamecall = nil
    end
    getgenv().oldnamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
            local args = {...}
            local block = false
            pcall(function()
                if typeof(self) == "Instance" then
                    if active["no fall"] and (self.Name == "GroundHit" or self.Name == "FallDamage") then
                        block = true
                    end
                    if type(args[1]) == "table" then
                        if args[1].weapon and args[1].validate then
                            getgenv().SwordHitRemote = self
                            if reachActive and reachSwordEnabled and args[1].validate then
                                local vd = args[1].validate
                                if vd.selfPosition and vd.targetPosition and vd.selfPosition.value and vd.targetPosition.value then
                                    local sp = vd.selfPosition.value
                                    local tp = vd.targetPosition.value
                                    local dist = (tp - sp).Magnitude
                                    if dist > 14.4 and dist <= (reachSwordRange or 18) then
                                        local dir = (tp - sp).Unit
                                        vd.selfPosition.value = sp + dir * (dist - 14.39)
                                        if vd.raycast and vd.raycast.cameraPosition then
                                            vd.raycast.cameraPosition.value = vd.selfPosition.value + Vector3.new(0, 1.5, 0)
                                        end
                                    end
                                end
                            end
                        elseif args[1].blockType and args[1].position then
                            getgenv().PlaceBlockRemote = self
                        end
                    end
                    if self.Name == "ProjectileFire" or self.Name == "FireProjectile" or string.find(self.Name, "Projectile") then
                        if active["bowaimbot"] then
                            local t = nearest(300, false)
                            if t and t.hrp then
                                local targetpos = t.hrp.Position + (t.hrp.Velocity * 0.1) + Vector3.new(0, 1.5, 0)
                                local pos = type(args[1]) == "table" and args[1].position or args[4] or cam.CFrame.Position
                                local targetdir = pos and (targetpos - pos).Magnitude > 0 and CFrame.lookAt(pos, targetpos).LookVector or Vector3.new(0,0,0)
                                if type(args[1]) == "table" and typeof(args[1].velocity) == "Vector3" then
                                    args[1].velocity = targetdir * args[1].velocity.Magnitude
                                elseif typeof(args[6]) == "Vector3" then
                                    args[6] = targetdir * args[6].Magnitude
                                end
                            end
                        end
                    end
                end
            end)
            if block then return end
            return getgenv().oldnamecall(self, unpack(args, 1, select("#", ...)))
        end
        return getgenv().oldnamecall(self, ...)
    end)
end)
local function attackEntity(targetChar, sword, customReach)
    if not targetChar or not sword then return end
    pcall(function()
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        local myHRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if not targetHRP or not myHRP then return end
        local selfPosition = myHRP.Position
        local targetPosition = targetHRP.Position
        local cursorDirection = (targetPosition - selfPosition).Magnitude > 0 and (targetPosition - selfPosition).Unit or Vector3.new(0,0,-1)
        local dist = (selfPosition - targetPosition).Magnitude
        local needsTp = dist > 18.5 and dist <= 25
        local oldcf = nil
        if needsTp then
            oldcf = myHRP.CFrame
            myHRP.CFrame = myHRP.CFrame + cursorDirection * (dist - 18)
            selfPosition = myHRP.Position
            task.wait()
        end
        local currentDist = (selfPosition - targetPosition).Magnitude
        if currentDist > 14 then selfPosition = targetPosition - (cursorDirection * 13.5) end
        local cameraPosition = selfPosition + Vector3.new(0, 1.5, 0)
        local hitData = {
            ["weapon"] = sword,
            ["entityInstance"] = targetChar,
            ["validate"] = {
                ["raycast"] = {
                    ["cameraPosition"] = { ["value"] = cameraPosition },
                    ["cursorDirection"] = { ["value"] = cursorDirection }
                },
                ["targetPosition"] = { ["value"] = targetPosition },
                ["selfPosition"] = { ["value"] = selfPosition }
            },
            ["chargedAttack"] = { ["chargeRatio"] = 0 }
        }
        local sent = false
        if getgenv().SwordHitWrapper then
            local s2 = pcall(function() getgenv().SwordHitWrapper:SendToServer(hitData) end)
            if s2 then sent = true end
        end
        if not sent and bw.Flamework then
            local s2 = pcall(function()
                local r = bw.Flamework:Get("SwordHit") or bw.Flamework:Get("swordHit")
                if r then
                    getgenv().SwordHitWrapper = r
                    r:SendToServer(hitData)
                    sent = true
                end
            end)
        end
        if not sent and getgenv().SwordHitRemote then
            pcall(function()
                if getgenv().SwordHitRemote:IsA("RemoteFunction") then
                    getgenv().SwordHitRemote:InvokeServer(hitData)
                else
                    getgenv().SwordHitRemote:FireServer(hitData)
                end
                sent = true
            end)
        end
        if not sent then
            for _, v in ipairs(rep:GetDescendants()) do
                if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) and (v.Name == "SwordHit" or string.find(string.lower(v.Name), "swordhit") or string.find(string.lower(v.Name), "sword_hit")) then
                    getgenv().SwordHitRemote = v
                    pcall(function()
                        if v:IsA("RemoteFunction") then v:InvokeServer(hitData) else v:FireServer(hitData) end
                    end)
                    break
                end
            end
        end
        pcall(function()
            local sName = tostring(sword.Name or sword)
            if sName:find("summoner_claw") then
                local clawHand = bw.Knit and bw.Knit.Controllers and bw.Knit.Controllers.SummonerClawHandController
                local lastAttack = clawHand and clawHand.lastAttackTime or 0
                local cooldown = 0.38
                pcall(function()
                    local balance = require(rep.TS.games.bedwars.kit.kits.summoner["summoner-kit-balance"])
                    if balance and balance.SummonerKitBalance then
                        cooldown = balance.SummonerKitBalance.CLAW_COOLDOWN or cooldown
                    end
                end)
                if (workspace:GetServerTimeNow() - lastAttack) >= cooldown then
                    if clawHand then
                        pcall(function() clawHand.lastAttackTime = workspace:GetServerTimeNow() end)
                    end
                    local clawController = bw.Knit and bw.Knit.Controllers and bw.Knit.Controllers.SummonerClawController
                    if clawController and clawController.clawAttack then
                        clawController:clawAttack(plr, myHRP.Position, cursorDirection, sName)
                    end
                end
            end
            if bw.Sword then
                if bw.Sword.swing then
                    bw.Sword:swing()
                elseif bw.Sword.swingSwordAtMouse then
                    bw.Sword:swingSwordAtMouse()
                end
                local itemMeta = require(rep.TS.item["item-meta"]).getItemMeta
                local meta = itemMeta(sName)
                if meta and bw.Sword.playSwordEffect then
                    bw.Sword:playSwordEffect(meta)
                end
            end
        end)
        if needsTp and oldcf then
            myHRP.CFrame = oldcf
        end
    end)
end
local function isentity(char)
    if not char then return false end
    for _, p in ipairs(players:GetPlayers()) do if p.Character == char then return false end end
    if char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
        local hum = char:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 then
            local n = string.lower(char.Name)
            if string.find(n, "shop") or string.find(n, "vendor") or string.find(n, "npc") then return false end
            return true
        end
    end; return false
end
local cachedEntities = {}
local CollectionService = game:GetService("CollectionService")
ClientConnections.addThread(task.spawn(function()
    while clientActive do
        local newEntities = {}
        pcall(function()
            local candidates = {}
            for _, tag in ipairs({"entity", "damageable"}) do
                for _, obj in ipairs(CollectionService:GetTagged(tag)) do
                    candidates[obj] = true
                end
            end
            local hasEntities = false
            for obj in pairs(candidates) do
                hasEntities = true
                if isentity(obj) then
                    table.insert(newEntities, {obj=obj, char=obj, hrp=obj.HumanoidRootPart, isP=false, nm=obj.Name, isTeammate=false})
                end
            end
            if not hasEntities then
                for _, ch in ipairs(workspace:GetChildren()) do
                    if isentity(ch) then
                        table.insert(newEntities, {obj=ch, char=ch, hrp=ch.HumanoidRootPart, isP=false, nm=ch.Name, isTeammate=false})
                    end
                end
            end
        end)
        cachedEntities = newEntities
        task.wait(1)
    end
end))
local playerTargetCache = {}
ClientConnections.add(players.PlayerRemoving:Connect(function(p)
    if playerTargetCache[p] then
        playerTargetCache[p] = nil
    end
end))
local lastGetTargets = 0
local cachedTargets = {}
local function getalltargets()
    if tick() - lastGetTargets < 0.03 then
        return cachedTargets
    end
    lastGetTargets = tick()
    local t = {}
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
        cachedTargets = t
        return t
    end
    for _, p in ipairs(players:GetPlayers()) do
        if p ~= plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local isteammate = (p.Team and plr.Team and p.Team == plr.Team) or (p:GetAttribute("Team") and plr:GetAttribute("Team") and p:GetAttribute("Team") == plr:GetAttribute("Team")) or false
                if not playerTargetCache[p] or playerTargetCache[p].char ~= p.Character then
                    playerTargetCache[p] = {obj=p, char=p.Character, hrp=p.Character.HumanoidRootPart, isP=true, nm=p.Name, isTeammate=isteammate}
                else
                    playerTargetCache[p].isTeammate = isteammate
                end
                table.insert(t, playerTargetCache[p])
            end
        end
    end
    for _, ent in ipairs(cachedEntities) do
        if ent.char and ent.char.Parent and ent.hrp and ent.hrp.Parent then
            table.insert(t, ent)
        end
    end
    cachedTargets = t
    return t
end
local sharedRayParams = RaycastParams.new()
sharedRayParams.FilterType = Enum.RaycastFilterType.Exclude
local function isvisible(char)
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return false end
    sharedRayParams.FilterDescendantsInstances = {plr.Character, char}
    local ray = workspace:Raycast(plr.Character.HumanoidRootPart.Position, char.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position, sharedRayParams)
    return ray == nil
end
local function closestcursor(maxd, checkvis, skipTeammates)
    local best, bd = nil, maxd or 90; local mp = uis:GetMouseLocation()
    for _, t in ipairs(getalltargets()) do
        if skipTeammates and t.isTeammate then continue end
        local sp, on = cam:WorldToViewportPoint(t.hrp.Position)
        if not on then continue end
        local d = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
        if d < bd and (not checkvis or isvisible(t.char)) then bd = d; best = t end
    end; return best, bd
end
local function nearest(maxd, checkvis, skipTeammates)
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local best, bd = nil, maxd or 100; local origin = plr.Character.HumanoidRootPart.Position
    for _, t in ipairs(getalltargets()) do
        if skipTeammates and t.isTeammate then continue end
        local d = (t.hrp.Position - origin).Magnitude
        if d < bd and (not checkvis or isvisible(t.char)) then bd = d; best = t end
    end; return best, bd
end
local function getcharacter(td)
    if td.isP then
        return td.obj and td.obj.Character
    else
        return td.char
    end
end
local gearCache = setmetatable({}, { __mode = "k" })
local oresCache = setmetatable({}, { __mode = "k" })
local humCache = setmetatable({}, { __mode = "k" })
local function gethum(td)
    local ch = getcharacter(td)
    if not ch then return nil end
    local cached = humCache[ch]
    if cached and cached.Parent == ch then
        return cached
    end
    local hum = ch:FindFirstChildOfClass("Humanoid") or ch:FindFirstChild("Humanoid")
    if hum then
        humCache[ch] = hum
    end
    return hum
end
local function getores(td)
    local o = {iron=0, diamond=0, emerald=0}
    if not td or not td.isP or not td.obj then return o end
    local key = td.obj
    local cached = oresCache[key]
    if cached and tick() - cached.lastUpdate < 0.5 then
        return cached.value
    end
    pcall(function()
        local p = td.obj
        local leaderstats = p:FindFirstChild("leaderstats")
        if leaderstats then
            local ironval = leaderstats:FindFirstChild("Iron") or leaderstats:FindFirstChild("iron")
            if ironval then o.iron = ironval.Value end
            local diaval = leaderstats:FindFirstChild("Diamond") or leaderstats:FindFirstChild("diamond")
            if diaval then o.diamond = diaval.Value end
            local emval = leaderstats:FindFirstChild("Emerald") or leaderstats:FindFirstChild("emerald")
            if emval then o.emerald = emval.Value end
        end
    end)
    oresCache[key] = {lastUpdate = tick(), value = o}
    return o
end
local function gethp(td)
    local hum = gethum(td)
    return hum and math.floor(hum.Health) or 100
end
local function getmaxhp(td)
    local hum = gethum(td)
    return hum and hum.MaxHealth or 100
end
local function getgear(td)
    local key = td.obj or td.char
    if not key then return {sword = nil, bestarmor = nil} end
    local cached = gearCache[key]
    if cached and tick() - cached.lastUpdate < 0.5 then
        return cached.value
    end
    local gear = {sword = nil, bestarmor = nil}
    local ch = getcharacter(td)
    if not ch then return gear end
    pcall(function()
        local tool = ch:FindFirstChildOfClass("Tool")
        if tool then
            local n = string.lower(tool.Name)
            if itemimages[n] then gear.sword = n else
                if string.find(n, "wood") then gear.sword = "wood_sword"
                elseif string.find(n, "stone") then gear.sword = "stone_sword"
                elseif string.find(n, "iron") then gear.sword = "iron_sword"
                elseif string.find(n, "diamond") then gear.sword = "diamond_sword"
                elseif string.find(n, "emerald") then gear.sword = "emerald_sword"
                end
            end
        end
        local armortier = 0
        for _, child in ipairs(ch:GetChildren()) do
            if child:IsA("Accessory") or child:IsA("Model") then
                local n = string.lower(child.Name)
                local tiervalue = 0
                if string.find(n, "leather") then tiervalue = 1
                elseif string.find(n, "iron") then tiervalue = 2
                elseif string.find(n, "diamond") then tiervalue = 3
                elseif string.find(n, "emerald") then tiervalue = 4
                elseif string.find(n, "warrior") then tiervalue = 5
                elseif string.find(n, "void") then tiervalue = 6 end
                if tiervalue > armortier then
                    armortier = tiervalue
                    if string.find(n, "helmet") then gear.bestarmor = itemimages[n] and n or (string.match(n, "([%w_]+)") .. "_helmet")
                    elseif string.find(n, "chestplate") then gear.bestarmor = itemimages[n] and n or (string.match(n, "([%w_]+)") .. "_chestplate")
                    elseif string.find(n, "boots") then gear.bestarmor = itemimages[n] and n or (string.match(n, "([%w_]+)") .. "_boots") end
                end
            end
        end
    end)
    gearCache[key] = {lastUpdate = tick(), value = gear}
    return gear
end
local function getbbox(ch)
    if not ch then return nil end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local pos, onscreen = cam:WorldToViewportPoint(hrp.Position)
    if not onscreen then return nil end
    local top, _ = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.5, 0))
    local h = math.abs(pos.Y - top.Y) * 2
    local w = h * 0.6
    local x1 = pos.X - (w / 2)
    local x2 = pos.X + (w / 2)
    local y1 = pos.Y - (h / 2)
    local y2 = pos.Y + (h / 2)
    return {x1=x1, y1=y1, x2=x2, y2=y2, w=w, h=h, cx=pos.X, cy=pos.Y}
end
local function makeslider(cont, data)
    local nm = data.name or ""; local mn = data.min or 0; local mx = data.max or 100; local def = data.default or ((mn+mx)/2)
    local sfx = data.suffix or ""; local cb = type(data.callback) == "function" and data.callback or function() end; local val = data.initial or def
    local dragging = false
    local is_nested = cont:IsA("Frame")
    local fr = Instance.new("Frame")
    if is_nested then
        fr.Size = UDim2.new(1, -24, 0, 32)
        fr.BackgroundTransparency = 1
        fr.BorderSizePixel = 0
    else
        fr.Size = UDim2.new(1, -12, 0, 42)
        fr.BackgroundColor3 = c_colors.bg
        fr.BorderSizePixel = 0
    end
    fr.Parent = cont
    local frstroke = nil
    if not is_nested then
        Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 5)
        frstroke = Instance.new("UIStroke")
        frstroke.Thickness = 1
        frstroke.Color = c_colors.outline
        frstroke.Parent = fr
    end
    local lbl = Instance.new("TextLabel")
    if is_nested then
        lbl.Size = UDim2.new(0.6, 0, 0, 14)
        lbl.Position = UDim2.new(0, 12, 0, 0)
    else
        lbl.Size = UDim2.new(0.6, 0, 0, 16)
        lbl.Position = UDim2.new(0, 12, 0, 4)
    end
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(string.sub(tostring(nm), 1, 1)) .. string.sub(tostring(nm), 2)
    lbl.TextColor3 = c_colors.text
    lbl.Font = Enum.Font.Montserrat
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = fr
    local valLbl = Instance.new("TextLabel")
    if is_nested then
        valLbl.Size = UDim2.new(0.4, -12, 0, 14)
        valLbl.Position = UDim2.new(0.6, 0, 0, 0)
    else
        valLbl.Size = UDim2.new(0.4, -24, 0, 16)
        valLbl.Position = UDim2.new(0.6, 12, 0, 4)
    end
    valLbl.BackgroundTransparency = 1
    valLbl.Text = string.format("%.1f", val) .. sfx
    valLbl.TextColor3 = c_colors.accent2
    valLbl.Font = Enum.Font.MontserratBold
    valLbl.TextSize = 10
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = fr
    local bg = Instance.new("Frame")
    if is_nested then
        bg.Size = UDim2.new(1, -24, 0, 4)
        bg.Position = UDim2.new(0, 12, 0, 18)
    else
        bg.Size = UDim2.new(1, -24, 0, 5)
        bg.Position = UDim2.new(0, 12, 0, 26)
    end
    bg.BackgroundColor3 = c_colors.sbg
    bg.BorderSizePixel = 0
    bg.Parent = fr
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 3)
    local bgstroke = Instance.new("UIStroke")
    bgstroke.Thickness = 1
    bgstroke.Color = c_colors.outline
    bgstroke.Parent = bg
    local fill = Instance.new("Frame")
    local fillpct = (mx ~= mn) and ((val-mn)/(mx-mn)) or 0
    fill.Size = UDim2.new(fillpct, 0, 1, 0)
    fill.BackgroundColor3 = c_colors.sfill
    fill.BorderSizePixel = 0
    fill.Parent = bg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)
    local fillgrad = Instance.new("UIGradient")
    fillgrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c_colors.accent),
        ColorSequenceKeypoint.new(1, c_colors.accent2)
    })
    fillgrad.Parent = fill
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 10, 0, 10)
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(fillpct, 0, 0.5, 0)
    thumb.BackgroundColor3 = c_colors.white
    thumb.BorderSizePixel = 0
    thumb.Parent = bg
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(0.5, 0)
    local thumbstroke = Instance.new("UIStroke")
    thumbstroke.Thickness = 1.5
    thumbstroke.Color = c_colors.accent
    thumbstroke.Parent = thumb
    local function setval(nv)
        val = math.clamp(nv, mn, mx); val = math.floor(val * 10 + 0.5) / 10
        local pct = (mx ~= mn) and ((val-mn)/(mx-mn)) or 0
        tweenservice:Create(fill, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
        tweenservice:Create(thumb, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(pct, 0, 0.5, 0)}):Play()
        valLbl.Text = string.format("%.1f", val) .. sfx
        pcall(function() cb(val) end)
    end
    local function updateVisuals(hovering, activeDragging)
        local targetThumbSize = 10
        local targetThumbColor = c_colors.accent
        local targetTrackHeight = is_nested and 4 or 5
        local targetStrokeColor = c_colors.outline
        if activeDragging then
            targetThumbSize = 14
            targetThumbColor = c_colors.accent2
            targetTrackHeight = is_nested and 6 or 7
            targetStrokeColor = c_colors.accent2
        elseif hovering then
            targetThumbSize = 12
            targetThumbColor = c_colors.accent2
            targetTrackHeight = is_nested and 5 or 6
            targetStrokeColor = c_colors.accent
        end
        tweenservice:Create(thumb, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, targetThumbSize, 0, targetThumbSize)
        }):Play()
        tweenservice:Create(thumbstroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Color = targetThumbColor
        }):Play()
        tweenservice:Create(bg, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, -24, 0, targetTrackHeight)
        }):Play()
        if frstroke then
            tweenservice:Create(frstroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Color = targetStrokeColor
            }):Play()
        end
    end
    fr.MouseEnter:Connect(function() updateVisuals(true, dragging) end)
    fr.MouseLeave:Connect(function() updateVisuals(false, dragging) end)
    bg.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateVisuals(true, true)
            setval(math.clamp((inp.Position.X - bg.AbsolutePosition.X)/bg.AbsoluteSize.X, 0, 1) * (mx - mn) + mn)
        end
    end)
    table.insert(uiconns, uis.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            updateVisuals(false, false)
        end
    end))
    table.insert(uiconns, uis.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            setval(math.clamp((inp.Position.X - bg.AbsolutePosition.X)/bg.AbsoluteSize.X, 0, 1) * (mx - mn) + mn)
        end
    end))
    pcall(function() cb(val) end)
    return {set = setval, get = function() return val end}
end
local categoryIcons = {
    combat = "https://api.iconify.design/lucide:swords.png?color=ffffff",
    movement = "https://api.iconify.design/lucide:wind.png?color=ffffff",
    player = "https://api.iconify.design/lucide:user.png?color=ffffff",
    visuals = "https://api.iconify.design/lucide:eye.png?color=ffffff",
    world = "https://api.iconify.design/lucide:globe.png?color=ffffff",
    settings = "https://api.iconify.design/lucide:settings.png?color=ffffff",
    config = "https://api.iconify.design/lucide:sliders.png?color=ffffff",
    misc = "https://api.iconify.design/lucide:box.png?color=ffffff",
    exploit = "https://api.iconify.design/lucide:zap.png?color=ffffff",
    utility = "https://api.iconify.design/lucide:wrench.png?color=ffffff",
    render = "https://api.iconify.design/lucide:monitor.png?color=ffffff",
    target = "https://api.iconify.design/lucide:crosshair.png?color=ffffff",
    aim = "https://api.iconify.design/lucide:target.png?color=ffffff",
    scaffold = "https://api.iconify.design/lucide:layers.png?color=ffffff",
    autoclicker = "https://api.iconify.design/lucide:mouse-pointer-2.png?color=ffffff",
    reach = "https://api.iconify.design/lucide:arrows-out-horizontal.png?color=ffffff",
    velocity = "https://api.iconify.design/lucide:zap-fast.png?color=ffffff",
    fly = "https://api.iconify.design/lucide:plane.png?color=ffffff",
    speed = "https://api.iconify.design/lucide:gauge.png?color=ffffff",
    jump = "https://api.iconify.design/lucide:arrow-up.png?color=ffffff",
    hud = "https://api.iconify.design/lucide:layout-template.png?color=ffffff"
}
local function getcustomicon(name, url)
    local folder = "jdkclient_assets"
    local filename = folder .. "/" .. name .. ".png"
    local hasFolder = (makefolder ~= nil)
    local hasWrite = (writefile ~= nil)
    local hasAsset = (getcustomasset ~= nil)
    if hasFolder then pcall(makefolder, folder) end
    if isfile and isfile(filename) and hasAsset then
        local success, asset = pcall(function() return getcustomasset(filename) end)
        if success and asset then return asset end
    end
    if hasWrite and hasAsset then
        local success, content = pcall(function() return game:HttpGet(url) end)
        if success and content and #content > 0 then
            pcall(writefile, filename, content)
            local s2, asset = pcall(function() return getcustomasset(filename) end)
            if s2 and asset then return asset end
        end
    end
    return ""
end
local function preloadAssets()
    task.spawn(function()
        pcall(function()
            local items = {
                {"chevron_down", "https://api.iconify.design/lucide:chevron-down.png?color=ffffff"},
                {"chevron_right", "https://api.iconify.design/lucide:chevron-right.png?color=ffffff"}
            }
            for k, v in pairs(categoryIcons) do
                table.insert(items, {k, v})
            end
            for _, item in ipairs(items) do
                pcall(function() getcustomicon(item[1], item[2]) end)
            end
        end)
    end)
end
pcall(preloadAssets)
categoryWindows = {}
local function createwin(nm, sx)
    local fr = Instance.new("Frame")
    fr.Size = UDim2.new(0,ww,0,38); fr.Position = UDim2.new(0,sx,0,42)
    fr.BackgroundColor3 = c_colors.bg; fr.BackgroundTransparency = menuTransparency or 0.08; fr.BorderSizePixel = 0; fr.Parent = windowsframe
    fr.ClipsDescendants = true
    categoryWindows[string.lower(tostring(nm))] = fr
    Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 4)
    addshadow(fr)
    addpattern(fr)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2; stroke.Color = c_colors.white; stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; stroke.Parent = fr
    local strokegrad = Instance.new("UIGradient")
    strokegrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c_colors.accent),
        ColorSequenceKeypoint.new(0.5, c_colors.accent2),
        ColorSequenceKeypoint.new(1, c_colors.accent3)
    })
    strokegrad.Rotation = 135
    strokegrad.Parent = stroke
    table.insert(gradientAnimations, strokegrad)
    local head = Instance.new("Frame")
    head.Size = UDim2.new(1,0,0,38); head.BackgroundColor3 = Color3.fromRGB(255, 255, 255); head.BorderSizePixel = 0; head.Parent = fr
    local headgrad = Instance.new("UIGradient")
    headgrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c_colors.accent),
        ColorSequenceKeypoint.new(0.3, c_colors.accent2),
        ColorSequenceKeypoint.new(0.6, c_colors.accent3),
        ColorSequenceKeypoint.new(1, c_colors.accent)
    })
    headgrad.Rotation = 0
    headgrad.Parent = head
    table.insert(gradientAnimations, headgrad)
    local borderLine = Instance.new("Frame")
    borderLine.Size = UDim2.new(1, 0, 0, 1)
    borderLine.Position = UDim2.new(0, 0, 1, -1)
    borderLine.BackgroundColor3 = c_colors.outline
    borderLine.BorderSizePixel = 0
    borderLine.Parent = head
    local nameLower = string.lower(tostring(nm))
    local iconUrl = categoryIcons[nameLower]
    if iconUrl then
        local iconImg = Instance.new("ImageLabel")
        iconImg.Size = UDim2.new(0, 18, 0, 18)
        iconImg.Position = UDim2.new(0, 14, 0.5, -9)
        iconImg.BackgroundTransparency = 1
        iconImg.Image = getcustomicon(nameLower, iconUrl)
        iconImg.ImageColor3 = c_colors.accent
        iconImg.Parent = head
    end
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-60,1,0)
    title.Position = iconUrl and UDim2.new(0,40,0,0) or UDim2.new(0,14,0,0)
    title.BackgroundTransparency = 1; title.Text = string.upper(string.sub(nameLower, 1, 1)) .. string.sub(nameLower, 2)
    title.TextColor3 = c_colors.text; title.Font = Enum.Font.MontserratBold; title.TextSize = 12; title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = head
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
    minimizeBtn.Position = UDim2.new(1, -30, 0.5, -12)
    minimizeBtn.BackgroundTransparency = 1
    minimizeBtn.Text = ""
    minimizeBtn.Parent = head
    local minimizeIcon = Instance.new("ImageLabel")
    minimizeIcon.Size = UDim2.new(0, 10, 0, 10)
    minimizeIcon.Position = UDim2.new(0.5, -5, 0.5, -5)
    minimizeIcon.BackgroundTransparency = 1
    minimizeIcon.Image = getcustomicon("chevron_down", "https://api.iconify.design/lucide:chevron-down.png?color=ffffff")
    minimizeIcon.ImageColor3 = c_colors.dim
    minimizeIcon.Parent = minimizeBtn
    local cont = Instance.new("ScrollingFrame")
    cont.Size = UDim2.new(1,0,0,0); cont.Position = UDim2.new(0,0,0,38)
    cont.BackgroundTransparency = 1; cont.BorderSizePixel = 0
    cont.ScrollBarThickness = 0; cont.CanvasSize = UDim2.new(0,0,0,0)
    cont.AutomaticCanvasSize = Enum.AutomaticSize.Y; cont.ScrollingEnabled = true; cont.Parent = fr
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0, 6); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; layout.Parent = cont
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 6)
    pad.Parent = cont
    local minimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        cont.Visible = not minimized
        tweenservice:Create(minimizeIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Rotation = minimized and -90 or 0
        }):Play()
        if minimized then
            tweenservice:Create(fr, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, ww, 0, 38)}):Play()
        else
            local h = layout.AbsoluteContentSize.Y + 12
            tweenservice:Create(fr, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, ww, 0, 38 + math.min(h, 460))}):Play()
        end
    end)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if not minimized then
            local h = layout.AbsoluteContentSize.Y + 12
            cont.Size = UDim2.new(1,0,0,math.min(h, 460))
            fr.Size = UDim2.new(0,ww,0,38+math.min(h, 460))
        end
    end)
    makedrag(head, fr)
    return cont
end
local function createtoggle(cont, data)
    if type(data) ~= "table" then return {} end
    local nm = data.name or ""
    local cb = type(data.logic) == "function" and data.logic or function() end
    local hasS = data.hasSettings == true
    local state = false
    local open = false
    local sets = type(data.settings) == "table" and data.settings or {}
    local defKey = data.defaultKey or Enum.KeyCode.Unknown
    local keybindref = nil
    if data.type == "button" then
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 34); btn.BackgroundColor3 = c_colors.bg; btn.BorderSizePixel = 0; btn.Text = ""; btn.Parent = cont
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -20, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1; lbl.Text = string.lower(tostring(nm))
        lbl.TextColor3 = c_colors.text; lbl.Font = Enum.Font.MontserratBold; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Center; lbl.Parent = btn
        btn.MouseEnter:Connect(function() pcall(function() tweenservice:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = c_colors.drop}):Play() end) end)
        btn.MouseLeave:Connect(function() pcall(function() tweenservice:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = c_colors.bg}):Play() end) end)
        btn.MouseButton1Click:Connect(function() pcall(cb) end)
        return {}
    elseif data.type == "textbox" then
        local fr = Instance.new("Frame")
        fr.Size = UDim2.new(1, 0, 0, 34); fr.BackgroundColor3 = c_colors.bg; fr.BorderSizePixel = 0; fr.Parent = cont
        local tb = Instance.new("TextBox")
        tb.Size = UDim2.new(1, -20, 0, 24); tb.Position = UDim2.new(0, 10, 0.5, -12)
        tb.BackgroundColor3 = c_colors.drop; tb.BorderSizePixel = 1; tb.BorderColor3 = c_colors.outline
        tb.Text = ""; tb.PlaceholderText = string.lower(tostring(nm)); tb.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
        tb.TextColor3 = c_colors.text; tb.Font = Enum.Font.Montserrat; tb.TextSize = 10; tb.Parent = fr
        Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 4)
        local tbstroke = Instance.new("UIStroke")
        tbstroke.Thickness = 1; tbstroke.Color = c_colors.outline; tbstroke.Parent = tb
        tb.FocusLost:Connect(function(enter) pcall(function() cb(tb.Text) end) end)
        return tb
    elseif data.type == "label" then
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 24); lbl.BackgroundTransparency = 1; lbl.Text = string.lower(tostring(nm))
        lbl.TextColor3 = c_colors.dim; lbl.Font = Enum.Font.Montserrat; lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Center; lbl.Parent = cont
        return lbl
    elseif data.type == "dropdown" then
        local fr = Instance.new("Frame")
        fr.Size = UDim2.new(1, 0, 0, 34); fr.BackgroundColor3 = c_colors.bg; fr.BorderSizePixel = 0; fr.Parent = cont
        local titlelbl = Instance.new("TextLabel")
        titlelbl.Size = UDim2.new(1, -20, 0, 10); titlelbl.Position = UDim2.new(0, 12, 0, 2)
        titlelbl.BackgroundTransparency = 1; titlelbl.Text = string.lower(tostring(nm))
        titlelbl.TextColor3 = c_colors.dim; titlelbl.Font = Enum.Font.Montserrat; titlelbl.TextSize = 8
        titlelbl.TextXAlignment = Enum.TextXAlignment.Left; titlelbl.Parent = fr
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 18); btn.Position = UDim2.new(0, 10, 0.5, -5)
        btn.BackgroundColor3 = c_colors.drop; btn.BorderSizePixel = 0; btn.Text = ""
        btn.Parent = fr
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        local btnstroke = Instance.new("UIStroke")
        btnstroke.Thickness = 1; btnstroke.Color = c_colors.outline; btnstroke.Parent = btn
        local btnlbl = Instance.new("TextLabel")
        btnlbl.Size = UDim2.new(1, -24, 1, 0); btnlbl.Position = UDim2.new(0, 8, 0, 0)
        btnlbl.BackgroundTransparency = 1
        btnlbl.Text = string.lower(tostring(data.default or (data.options and data.options[1]) or "none"))
        btnlbl.TextColor3 = c_colors.text; btnlbl.Font = Enum.Font.Montserrat; btnlbl.TextSize = 9
        btnlbl.TextXAlignment = Enum.TextXAlignment.Left; btnlbl.Parent = btn
        local arrow = Instance.new("ImageLabel")
        arrow.Size = UDim2.new(0, 8, 0, 8); arrow.Position = UDim2.new(1, -14, 0.5, -4)
        arrow.BackgroundTransparency = 1; arrow.Image = getcustomicon("chevron_right", "https://api.iconify.design/lucide:chevron-right.png?color=ffffff")
        arrow.ImageColor3 = c_colors.dim; arrow.Parent = btn
        local listfr = Instance.new("Frame")
        listfr.Size = UDim2.new(1, 0, 0, 0); listfr.BackgroundColor3 = c_colors.drop; listfr.BorderSizePixel = 0
        listfr.Visible = false; listfr.ClipsDescendants = true; listfr.Parent = cont
        local listlayout = Instance.new("UIListLayout")
        listlayout.SortOrder = Enum.SortOrder.LayoutOrder; listlayout.Padding = UDim.new(0, 0); listlayout.Parent = listfr
        local open = false
        local selected = btnlbl.Text
        local function rebuild()
            for _, c in ipairs(listfr:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            for idx, opt in ipairs(data.options or {}) do
                local optbtn = Instance.new("TextButton")
                optbtn.Size = UDim2.new(1, 0, 0, 20); optbtn.BackgroundTransparency = 1; optbtn.Text = ""
                optbtn.Parent = listfr; optbtn.LayoutOrder = idx
                local optlbl = Instance.new("TextLabel")
                optlbl.Size = UDim2.new(1, -20, 1, 0); optlbl.Position = UDim2.new(0, 10, 0, 0)
                optlbl.BackgroundTransparency = 1; optlbl.Text = string.lower(tostring(opt))
                optlbl.TextColor3 = (optlbl.Text == selected) and c_colors.accent2 or c_colors.dim
                optlbl.Font = Enum.Font.Montserrat; optlbl.TextSize = 9; optlbl.TextXAlignment = Enum.TextXAlignment.Left
                optlbl.Parent = optbtn
                optbtn.MouseEnter:Connect(function() optlbl.TextColor3 = c_colors.white end)
                optbtn.MouseLeave:Connect(function() optlbl.TextColor3 = (optlbl.Text == selected) and c_colors.accent2 or c_colors.dim end)
                optbtn.MouseButton1Click:Connect(function()
                    selected = optlbl.Text
                    btnlbl.Text = selected
                    open = false
                    arrow.Image = getcustomicon("chevron_right", "https://api.iconify.design/lucide:chevron-right.png?color=ffffff")
                    tweenservice:Create(listfr, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                    listfr.Visible = false
                    pcall(cb, opt)
                end)
            end
        end
        rebuild()
        btn.MouseButton1Click:Connect(function()
            open = not open
            arrow.Image = open and getcustomicon("chevron_down", "https://api.iconify.design/lucide:chevron-down.png?color=ffffff") or getcustomicon("chevron_right", "https://api.iconify.design/lucide:chevron-right.png?color=ffffff")
            if open then
                listfr.Visible = true
                tweenservice:Create(listfr, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, listlayout.AbsoluteContentSize.Y)}):Play()
            else
                local tw = tweenservice:Create(listfr, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)})
                tw.Completed:Connect(function() if not open then listfr.Visible = false end end)
                tw:Play()
            end
        end)
        listlayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if open then listfr.Size = UDim2.new(1, 0, 0, listlayout.AbsoluteContentSize.Y) end
        end)
        local ref = {
            updateOptions = function(self, newOpts)
                data.options = newOpts
                rebuild()
            end,
            set = function(val)
                selected = string.lower(tostring(val))
                btnlbl.Text = selected
                rebuild()
            end,
            get = function() return selected end
        }
        if nm then toggleRefs[nm] = ref end
        return ref
    end
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 36)
    btn.BackgroundColor3 = c_colors.bg
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Parent = cont
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local btnstroke = Instance.new("UIStroke")
    btnstroke.Thickness = 1
    btnstroke.Color = c_colors.outline
    btnstroke.Parent = btn
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0, 0)
    indicator.Position = UDim2.new(0, 4, 0.5, 0)
    indicator.AnchorPoint = Vector2.new(0, 0.5)
    indicator.BackgroundColor3 = c_colors.accent2
    indicator.BorderSizePixel = 0
    indicator.Parent = btn
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 1.5)
    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0, 32, 0, 18)
    sw.Position = UDim2.new(1, -48, 0.5, -9)
    sw.BackgroundColor3 = c_colors.dim
    sw.BackgroundTransparency = 0.5
    sw.BorderSizePixel = 0
    sw.Parent = btn
    Instance.new("UICorner", sw).CornerRadius = UDim.new(0, 9)
    local swstroke = Instance.new("UIStroke")
    swstroke.Thickness = 1.5
    swstroke.Color = c_colors.outline
    swstroke.Parent = sw
    local swgrad = Instance.new("UIGradient")
    swgrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c_colors.accent),
        ColorSequenceKeypoint.new(0.5, c_colors.accent2),
        ColorSequenceKeypoint.new(1, c_colors.accent3)
    })
    swgrad.Parent = swstroke
    swgrad.Enabled = false
    local swdot = Instance.new("Frame")
    swdot.Size = UDim2.new(0, 14, 0, 14)
    swdot.Position = UDim2.new(0, 2, 0.5, -7)
    swdot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    swdot.BorderSizePixel = 0
    swdot.Parent = sw
    Instance.new("UICorner", swdot).CornerRadius = UDim.new(0, 7)
    btn.MouseEnter:Connect(function() pcall(function()
        if not moduleStates[nm] then
            tweenservice:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = c_colors.drop}):Play()
            tweenservice:Create(btnstroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = c_colors.accent}):Play()
        end
    end) end)
    btn.MouseLeave:Connect(function() pcall(function()
        if not moduleStates[nm] then
            tweenservice:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = c_colors.bg}):Play()
            tweenservice:Create(btnstroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = c_colors.outline}):Play()
        end
    end) end)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = string.upper(string.sub(string.lower(tostring(nm)), 1, 1)) .. string.sub(string.lower(tostring(nm)), 2)
    lbl.TextColor3 = c_colors.dim; lbl.Font = Enum.Font.Montserrat; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = btn
    local arrl = Instance.new("ImageLabel")
    arrl.Size = UDim2.new(0, 10, 0, 10)
    arrl.Position = UDim2.new(1, -64, 0.5, -5)
    arrl.BackgroundTransparency = 1; arrl.Image = getcustomicon("chevron_right", "https://api.iconify.design/lucide:chevron-right.png?color=ffffff")
    arrl.ImageColor3 = c_colors.dim; arrl.Visible = hasS; arrl.Parent = btn
    local cfg = Instance.new("Frame")
    cfg.Size = UDim2.new(1, 0, 0, 0); cfg.BackgroundColor3 = c_colors.drop; cfg.BorderSizePixel = 0; cfg.Visible = false; cfg.ClipsDescendants = true; cfg.Parent = cont
    local cl = Instance.new("UIListLayout"); cl.SortOrder = Enum.SortOrder.LayoutOrder; cl.Padding = UDim.new(0, 6); cl.HorizontalAlignment = Enum.HorizontalAlignment.Center; cl.Parent = cfg
    cl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if open then cfg.Size = UDim2.new(1, 0, 0, cl.AbsoluteContentSize.Y + 6) end
    end)
    local settingcontrols = {}
    for _, sd in ipairs(sets) do
        if type(sd) == "table" then
            if sd.type == "slider" then
                local ref = makeslider(cfg, {
                    name = sd.name, min = sd.min, max = sd.max,
                    default = sd.default, initial = sd.initial or sd.default, suffix = sd.suffix or "",
                    callback = function(v) pcall(function() if type(sd.callback) == "function" then sd.callback(v, state) end end) end
                })
                if sd.name then settingcontrols[sd.name] = ref end
            elseif sd.type == "toggle" then
                local subbtn = Instance.new("TextButton")
                subbtn.Size = UDim2.new(1, 0, 0, 24)
                subbtn.BackgroundTransparency = 1
                subbtn.BorderSizePixel = 0
                subbtn.Text = ""
                subbtn.Parent = cfg
                local subsw = Instance.new("Frame")
                subsw.Size = UDim2.new(0, 24, 0, 12)
                subsw.Position = UDim2.new(1, -36, 0.5, -6)
                subsw.BackgroundColor3 = c_colors.dim
                subsw.BackgroundTransparency = 0.5
                subsw.BorderSizePixel = 0
                subsw.Parent = subbtn
                Instance.new("UICorner", subsw).CornerRadius = UDim.new(0, 6)
                local subswstroke = Instance.new("UIStroke")
                subswstroke.Thickness = 1
                subswstroke.Color = c_colors.outline
                subswstroke.Parent = subsw
                local subswgrad = Instance.new("UIGradient")
                subswgrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, c_colors.accent),
                    ColorSequenceKeypoint.new(1, c_colors.accent2)
                })
                subswgrad.Parent = subswstroke
                subswgrad.Enabled = false
                local subswdot = Instance.new("Frame")
                subswdot.Size = UDim2.new(0, 8, 0, 8)
                subswdot.Position = UDim2.new(0, 2, 0.5, -4)
                subswdot.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
                subswdot.BorderSizePixel = 0
                subswdot.Parent = subsw
                Instance.new("UICorner", subswdot).CornerRadius = UDim.new(0, 4)
                local sublbl = Instance.new("TextLabel")
                sublbl.Size = UDim2.new(1, -56, 1, 0)
                sublbl.Position = UDim2.new(0, 12, 0, 0)
                sublbl.BackgroundTransparency = 1
                sublbl.Text = string.upper(string.sub(string.lower(tostring(sd.name or "")), 1, 1)) .. string.sub(string.lower(tostring(sd.name or "")), 2)
                sublbl.TextColor3 = c_colors.dim
                sublbl.Font = Enum.Font.Montserrat
                sublbl.TextSize = 10
                sublbl.TextXAlignment = Enum.TextXAlignment.Left
                sublbl.Parent = subbtn
                local substate = sd.default or false
                local function setsubvis(s)
                    substate = s
                    pcall(function()
                        tweenservice:Create(sublbl, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = s and c_colors.white or c_colors.dim}):Play()
                        if s then
                            tweenservice:Create(subsw, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = c_colors.accent2, BackgroundTransparency = 0}):Play()
                            tweenservice:Create(subswdot, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 14, 0.5, -4), BackgroundColor3 = c_colors.white}):Play()
                            subswgrad.Enabled = true
                        else
                            tweenservice:Create(subsw, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = c_colors.dim, BackgroundTransparency = 0.5}):Play()
                            tweenservice:Create(subswdot, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 2, 0.5, -4), BackgroundColor3 = Color3.fromRGB(180, 180, 180)}):Play()
                            subswgrad.Enabled = false
                        end
                    end)
                end
                setsubvis(substate)
                subbtn.MouseButton1Click:Connect(function()
                    setsubvis(not substate)
                    pcall(function() if type(sd.callback) == "function" then sd.callback(substate) end end)
                end)
                if sd.name then settingcontrols[sd.name] = {set = function(s) setsubvis(s); pcall(function() if type(sd.callback) == "function" then sd.callback(s) end end) end, get = function() return substate end} end
            elseif sd.type == "textbox" then
                local tb = Instance.new("TextBox")
                tb.Size = UDim2.new(1, -24, 0, 24)
                tb.BackgroundColor3 = c_colors.drop
                tb.BorderSizePixel = 0
                tb.Text = ""
                tb.PlaceholderText = string.upper(string.sub(tostring(sd.name), 1, 1)) .. string.sub(tostring(sd.name), 2)
                tb.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
                tb.TextColor3 = c_colors.text
                tb.Font = Enum.Font.Montserrat
                tb.TextSize = 10
                tb.Parent = cfg
                Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 4)
                local tbstroke = Instance.new("UIStroke")
                tbstroke.Thickness = 1
                tbstroke.Color = c_colors.outline
                tbstroke.Parent = tb
                tb.FocusLost:Connect(function() pcall(function() if type(sd.callback) == "function" then sd.callback(tb.Text) end end) end)
                if sd.name then settingcontrols[sd.name] = {set = function(s) tb.Text = s; pcall(function() if type(sd.callback) == "function" then sd.callback(s) end end) end, get = function() return tb.Text end} end
            elseif sd.type == "colorpicker" or sd.type == "color" then
                local cpBtn = Instance.new("TextButton")
                cpBtn.Size = UDim2.new(1, 0, 0, 24)
                cpBtn.BackgroundTransparency = 1
                cpBtn.BorderSizePixel = 0
                cpBtn.Text = ""
                cpBtn.Parent = cfg
                local cpLbl = Instance.new("TextLabel")
                cpLbl.Size = UDim2.new(1, -60, 1, 0)
                cpLbl.Position = UDim2.new(0, 12, 0, 0)
                cpLbl.BackgroundTransparency = 1
                cpLbl.Text = string.upper(string.sub(string.lower(tostring(sd.name or "")), 1, 1)) .. string.sub(string.lower(tostring(sd.name or "")), 2)
                cpLbl.TextColor3 = c_colors.dim
                cpLbl.Font = Enum.Font.Montserrat
                cpLbl.TextSize = 10
                cpLbl.TextXAlignment = Enum.TextXAlignment.Left
                cpLbl.Parent = cpBtn
                local cpPreview = Instance.new("Frame")
                cpPreview.Size = UDim2.new(0, 20, 0, 12)
                cpPreview.Position = UDim2.new(1, -32, 0.5, -6)
                cpPreview.BackgroundColor3 = sd.default or Color3.fromRGB(255, 255, 255)
                cpPreview.BorderSizePixel = 0
                cpPreview.Parent = cpBtn
                Instance.new("UICorner", cpPreview).CornerRadius = UDim.new(0, 3)
                local cpStroke = Instance.new("UIStroke")
                cpStroke.Thickness = 1
                cpStroke.Color = c_colors.outline
                cpStroke.Parent = cpPreview
                local cpExpand = Instance.new("Frame")
                cpExpand.Size = UDim2.new(1, 0, 0, 0)
                cpExpand.BackgroundTransparency = 1
                cpExpand.BorderSizePixel = 0
                cpExpand.Visible = false
                cpExpand.ClipsDescendants = true
                cpExpand.Parent = cfg
                local cpOpen = false
                cpBtn.MouseButton1Click:Connect(function()
                    cpOpen = not cpOpen
                    cpExpand.Visible = cpOpen
                    if cpOpen then
                        cpExpand.Size = UDim2.new(1, 0, 0, 24)
                    else
                        cpExpand.Size = UDim2.new(1, 0, 0, 0)
                    end
                end)
                local currentCol = sd.default or Color3.fromRGB(255, 255, 255)
                local presets = {
                    Color3.fromRGB(255, 60, 100),
                    Color3.fromRGB(255, 120, 0),
                    Color3.fromRGB(255, 220, 0),
                    Color3.fromRGB(0, 255, 120),
                    Color3.fromRGB(0, 220, 255),
                    Color3.fromRGB(0, 120, 255),
                    Color3.fromRGB(150, 0, 255),
                    Color3.fromRGB(255, 0, 150),
                    Color3.fromRGB(255, 255, 255)
                }
                local presetContainer = Instance.new("Frame")
                presetContainer.Size = UDim2.new(1, 0, 1, 0)
                presetContainer.BackgroundTransparency = 1
                presetContainer.Parent = cpExpand
                local presetLayout = Instance.new("UIListLayout")
                presetLayout.FillDirection = Enum.FillDirection.Horizontal
                presetLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                presetLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                presetLayout.Padding = UDim.new(0, 6)
                presetLayout.Parent = presetContainer
                for _, color in ipairs(presets) do
                    local pBtn = Instance.new("TextButton")
                    pBtn.Size = UDim2.new(0, 16, 0, 16)
                    pBtn.BackgroundColor3 = color
                    pBtn.BorderSizePixel = 0
                    pBtn.Text = ""
                    pBtn.Parent = presetContainer
                    Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0.5, 0)
                    local pStroke = Instance.new("UIStroke")
                    pStroke.Thickness = 1
                    pStroke.Color = c_colors.outline
                    pStroke.Parent = pBtn
                    pBtn.MouseButton1Click:Connect(function()
                        currentCol = color
                        cpPreview.BackgroundColor3 = color
                        pcall(function() if type(sd.callback) == "function" then sd.callback(color) end end)
                    end)
                end
                if sd.name then
                    settingcontrols[sd.name] = {
                        set = function(c)
                            currentCol = c
                            cpPreview.BackgroundColor3 = c
                            pcall(function() if type(sd.callback) == "function" then sd.callback(c) end end)
                        end,
                        get = function() return currentCol end
                    }
                end
            end
        end
    end
    if hasS then
        local sep = Instance.new("Frame"); sep.Size = UDim2.new(1,-22,0,1); sep.Position = UDim2.new(0,11,0,0); sep.BackgroundColor3 = c_colors.outline; sep.BorderSizePixel = 0; sep.Parent = cfg
        keybindref = createkeybindselector(cfg, nm, defKey)
    end
    local function setvis(s)
        state = s
        pcall(function()
            tweenservice:Create(lbl, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextColor3 = s and c_colors.white or c_colors.dim
            }):Play()
            if s then
                tweenservice:Create(btn, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = c_colors.sbg}):Play()
                tweenservice:Create(btnstroke, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = c_colors.accent2}):Play()
                tweenservice:Create(sw, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = c_colors.accent2, BackgroundTransparency = 0}):Play()
                tweenservice:Create(swdot, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 16, 0.5, -7), BackgroundColor3 = c_colors.white}):Play()
                swgrad.Enabled = true
                tweenservice:Create(indicator, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 3, 0, 24)}):Play()
            else
                tweenservice:Create(btn, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = c_colors.bg}):Play()
                tweenservice:Create(btnstroke, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = c_colors.outline}):Play()
                tweenservice:Create(sw, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = c_colors.dim, BackgroundTransparency = 0.5}):Play()
                tweenservice:Create(swdot, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(180, 180, 180)}):Play()
                swgrad.Enabled = false
                tweenservice:Create(indicator, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 3, 0, 0)}):Play()
            end
        end)
    end
    local function dotoggle()
        if string.lower(tostring(nm)) == "unload client" then pcall(function() cb(true) end); return end
        setvis(not state)
        if nm then moduleStates[nm] = state end
        task.spawn(function() pcall(function() cb(state) end) end)
        updatearraylist()
    end
    btn.MouseButton1Click:Connect(dotoggle)
    btn.MouseButton2Click:Connect(function()
        if not hasS then return end
        open = not open
        arrl.Image = open and getcustomicon("chevron_down", "https://api.iconify.design/lucide:chevron-down.png?color=ffffff") or getcustomicon("chevron_right", "https://api.iconify.design/lucide:chevron-right.png?color=ffffff")
        if open then
            cfg.Visible = true; cfg.Size = UDim2.new(1, 0, 0, 0)
            pcall(function() tweenservice:Create(cfg, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, cl.AbsoluteContentSize.Y + 4)}):Play() end)
        else
            pcall(function()
                local tw = tweenservice:Create(cfg, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)})
                local twcon
                twcon = tw.Completed:Connect(function() twcon:Disconnect(); if not open then cfg.Visible = false end end)
                tw:Play()
            end)
        end
    end)
    if nm then toggleRefs[nm] = {toggle = dotoggle, set = setvis, get = function() return state end, keybind = keybindref, settings = settingcontrols} end
    local keycon = uis.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        local activeKey = keybindOverrides[nm] or defKey
        if activeKey ~= Enum.KeyCode.Unknown and inp.KeyCode == activeKey then
            dotoggle()
        end
    end)
    table.insert(uiconns, keycon)
    if data.default == true then
        task.spawn(function()
            task.wait(0.2)
            if state == false then
                dotoggle()
            end
        end)
    end
    return {get=function() return state end, toggle=dotoggle, set=setvis}
end
local espon = false; local espc = {}; local espo = {}; local used = pcall(function() return Drawing.new end)
local esp = {box = true, corner = true, boxc = Color3.fromRGB(255,255,255), boxt = 1.5, hbar = true, hbarw = 3, hoff = -7, nm = true, nmc = Color3.fromRGB(255,255,255), dist = true, distc = Color3.fromRGB(180,180,200), hotbar = true, hotc = Color3.fromRGB(200,200,220), ores = true, orec = Color3.fromRGB(200,200,220), maxd = 500, textsize = 13, teamCheck = true, skeleton = false}
local ESP = esp
local r6joints = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"}
}
local r15joints = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}
local function createesp(td)
    local key = td.obj; if espo[key] then return end
    if used then
        local o = {}
        for i = 1, 8 do local l = Drawing.new("Line"); l.Thickness = esp.boxt + 1.5; l.Color = Color3.fromRGB(0,0,0); l.Visible = false; table.insert(o, l) end
        for i = 1, 8 do local l = Drawing.new("Line"); l.Thickness = esp.boxt; l.Color = esp.boxc; l.Visible = false; table.insert(o, l) end
        local hbg = Drawing.new("Line"); hbg.Thickness = esp.hbarw; hbg.Color = Color3.fromRGB(20,20,20); hbg.Visible = false; table.insert(o, hbg)
        local hfl = Drawing.new("Line"); hfl.Thickness = esp.hbarw; hfl.Color = Color3.fromRGB(0, 255, 120); hfl.Visible = false; table.insert(o, hfl)
        local nt = Drawing.new("Text"); nt.Size = esp.textsize; nt.Color = esp.nmc; nt.Center = true; nt.Outline = true; nt.OutlineColor = Color3.fromRGB(0,0,0); nt.Visible = false; table.insert(o, nt)
        local dt = Drawing.new("Text"); dt.Size = esp.textsize-2; dt.Color = esp.distc; dt.Center = true; dt.Outline = true; dt.OutlineColor = Color3.fromRGB(0,0,0); dt.Visible = false; table.insert(o, dt)
        local ot = Drawing.new("Text"); ot.Size = esp.textsize-2; ot.Color = esp.orec; ot.Center = true; ot.Outline = true; ot.OutlineColor = Color3.fromRGB(0,0,0); ot.Visible = false; table.insert(o, ot)
        local skellines = {}
        for i = 1, 15 do
            local l = Drawing.new("Line"); l.Thickness = 1.5; l.Color = Color3.fromRGB(255,255,255); l.Visible = false; table.insert(o, l); table.insert(skellines, l)
        end
        local iconfolder = Instance.new("Folder")
        iconfolder.Name = "esp_icons_" .. string.lower(tostring(td.nm))
        iconfolder.Parent = espgui
        local icons = {}
        for i = 1, 2 do
            local bg = Instance.new("Frame")
            bg.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
            bg.BackgroundTransparency = 0.5
            bg.BorderSizePixel = 1
            bg.BorderColor3 = Color3.fromRGB(50, 50, 60)
            bg.Visible = false
            bg.Parent = iconfolder
            local img = Instance.new("ImageLabel")
            img.Size = UDim2.new(1, -4, 1, -4)
            img.Position = UDim2.new(0, 2, 0, 2)
            img.BackgroundTransparency = 1
            img.Parent = bg
            table.insert(icons, {bg = bg, img = img})
        end
        local oreicons = {}
        for i = 1, 3 do
            local bg = Instance.new("Frame")
            bg.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
            bg.BackgroundTransparency = 0.5
            bg.BorderSizePixel = 1
            bg.BorderColor3 = Color3.fromRGB(50, 50, 60)
            bg.Visible = false
            bg.Parent = iconfolder
            local img = Instance.new("ImageLabel")
            img.Size = UDim2.new(1, -4, 1, -4)
            img.Position = UDim2.new(0, 2, 0, 2)
            img.BackgroundTransparency = 1
            img.Parent = bg
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(0, 16, 0, 10)
            txt.Position = UDim2.new(1, -6, 1, -6)
            txt.BackgroundTransparency = 1
            txt.TextSize = 10
            txt.Font = Enum.Font.MontserratBold
            txt.TextColor3 = Color3.new(1, 1, 1)
            txt.TextStrokeTransparency = 0
            txt.ZIndex = 2
            txt.Parent = bg
            table.insert(oreicons, {bg = bg, img = img, txt = txt})
        end
        espo[key] = {drawings = o, folder = iconfolder}
        local uc
        uc = runservice.RenderStepped:Connect(function()
            if not espon then
                for _,v in pairs(o) do v.Visible=false end
                iconfolder.Parent = nil
                if uc then uc:Disconnect() end return
            end
            if esp.teamCheck and td.isTeammate then
                for _,v in pairs(o) do v.Visible=false end
                for _, icon in ipairs(icons) do icon.bg.Visible = false end
                for _, icon in ipairs(oreicons) do icon.bg.Visible = false end
                return
            end
            local ch = getcharacter(td)
            if not ch or not ch:FindFirstChild("HumanoidRootPart") then
                for _,v in pairs(o) do v.Visible=false end
                for _, icon in ipairs(icons) do icon.bg.Visible = false end
                for _, icon in ipairs(oreicons) do icon.bg.Visible = false end
                return
            end
            local hrp=ch.HumanoidRootPart; local dist=(hrp.Position-cam.CFrame.Position).Magnitude
            if dist>esp.maxd then
                for _,v in pairs(o) do v.Visible=false end
                for _, icon in ipairs(icons) do icon.bg.Visible = false end
                for _, icon in ipairs(oreicons) do icon.bg.Visible = false end
                return
            end
            local bb=getbbox(ch)
            if not bb then
                for _,v in pairs(o) do v.Visible=false end
                for _, icon in ipairs(icons) do icon.bg.Visible = false end
                for _, icon in ipairs(oreicons) do icon.bg.Visible = false end
                return
            end
            local hp=gethp(td); local mx=getmaxhp(td); local pct=math.clamp(hp/mx,0,1)
            local hc=hp>60 and Color3.fromRGB(0, 255, 120) or hp>25 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 60, 60)
            local x1=bb.x1; local y1=bb.y1; local x2=bb.x2; local y2=bb.y2; local bx=bb.x1+esp.hoff
            local len = math.min(bb.w/4, bb.h/4, 18)
            if esp.box then
                if esp.corner then
                    o[1].From=Vector2.new(x1,y1); o[1].To=Vector2.new(x1+len,y1); o[2].From=Vector2.new(x1,y1); o[2].To=Vector2.new(x1,y1+len)
                    o[3].From=Vector2.new(x2,y1); o[3].To=Vector2.new(x2-len,y1); o[4].From=Vector2.new(x2,y1); o[4].To=Vector2.new(x2,y1+len)
                    o[5].From=Vector2.new(x1,y2); o[5].To=Vector2.new(x1+len,y2); o[6].From=Vector2.new(x1,y2); o[6].To=Vector2.new(x1,y2-len)
                    o[7].From=Vector2.new(x2,y2); o[7].To=Vector2.new(x2-len,y2); o[8].From=Vector2.new(x2,y2); o[8].To=Vector2.new(x2,y2-len)
                    o[9].From=Vector2.new(x1,y1); o[9].To=Vector2.new(x1+len,y1); o[10].From=Vector2.new(x1,y1); o[10].To=Vector2.new(x1,y1+len)
                    o[11].From=Vector2.new(x2,y1); o[11].To=Vector2.new(x2-len,y1); o[12].From=Vector2.new(x2,y1); o[12].To=Vector2.new(x2,y1+len)
                    o[13].From=Vector2.new(x1,y2); o[13].To=Vector2.new(x1+len,y2); o[14].From=Vector2.new(x1,y2); o[14].To=Vector2.new(x1,y2-len)
                    o[15].From=Vector2.new(x2,y2); o[15].To=Vector2.new(x2-len,y2); o[16].From=Vector2.new(x2,y2); o[16].To=Vector2.new(x2,y2-len)
                    for idx = 1, 8 do o[idx].Visible = true; o[idx].Color = Color3.fromRGB(0,0,0); o[idx].Thickness = esp.boxt + 1.5 end
                    for idx = 9, 16 do o[idx].Visible = true; o[idx].Color = esp.boxc; o[idx].Thickness = esp.boxt end
                else
                    o[1].From=Vector2.new(x1,y1); o[1].To=Vector2.new(x2,y1); o[2].From=Vector2.new(x2,y1); o[2].To=Vector2.new(x2,y2)
                    o[3].From=Vector2.new(x2,y2); o[3].To=Vector2.new(x1,y2); o[4].From=Vector2.new(x1,y2); o[4].To=Vector2.new(x1,y1)
                    for idx = 5, 8 do o[idx].Visible = false end
                    o[9].From=Vector2.new(x1,y1); o[9].To=Vector2.new(x2,y1); o[10].From=Vector2.new(x2,y1); o[10].To=Vector2.new(x2,y2)
                    o[11].From=Vector2.new(x2,y2); o[11].To=Vector2.new(x1,y2); o[12].From=Vector2.new(x1,y2); o[12].To=Vector2.new(x1,y1)
                    for idx = 13, 16 do o[idx].Visible = false end
                    for idx = 1, 4 do o[idx].Visible = true; o[idx].Color = Color3.fromRGB(0,0,0); o[idx].Thickness = esp.boxt + 1.5 end
                    for idx = 9, 12 do o[idx].Visible = true; o[idx].Color = esp.boxc; o[idx].Thickness = esp.boxt end
                end
            else
                for idx = 1, 16 do o[idx].Visible = false end
            end
            if esp.hbar then
                hbg.Thickness = esp.hbarw; hfl.Thickness = esp.hbarw
                hbg.From=Vector2.new(bx,y1); hbg.To=Vector2.new(bx,y2)
                hfl.From=Vector2.new(bx,y2); hfl.To=Vector2.new(bx,y2-(bb.h*pct)); hfl.Color=hc
                hbg.Visible=true; hfl.Visible=true
            else hbg.Visible=false; hfl.Visible=false end
            local _y=-18
            if esp.nm then nt.Color = esp.nmc; nt.Text=td.isP and string.lower(td.nm) or "[npc] "..string.lower(td.nm); nt.Position=Vector2.new(bb.cx,y1+_y); nt.Visible=true; _y=_y-16 else nt.Visible=false end
            if esp.dist then dt.Text=math.floor(dist).."m"; dt.Position=Vector2.new(bb.cx,y1+_y); dt.Visible=true; _y=_y-14 else dt.Visible=false end
            if esp.ores and td.isP then
                ot.Visible = false
                local ordata=getores(td)
                local startx = x1
                local orey = y2 + 5
                local oretable = {
                    {val=ordata.iron, url="https://raw.githubusercontent.com/jdk-1337/jdkclient/main/Iron.png"},
                    {val=ordata.diamond, url="https://raw.githubusercontent.com/jdk-1337/jdkclient/main/Diamond.png"},
                    {val=ordata.emerald, url="https://raw.githubusercontent.com/jdk-1337/jdkclient/main/Emerald.png"}
                }
                local iconsize = math.clamp(14 + (80 / math.max(dist, 1)), 10, 24)
                for i = 1, 3 do
                    local ore = oretable[i]
                    if ore.val > 0 then
                        oreicons[i].bg.Position = UDim2.new(0, startx, 0, orey)
                        oreicons[i].bg.Size = UDim2.new(0, iconsize, 0, iconsize)
                        oreicons[i].bg.Visible = true
                        if oreicons[i].lastUrl ~= ore.url then
                            oreicons[i].lastUrl = ore.url
                            applycustomasset(oreicons[i].img, ore.url)
                        end
                        oreicons[i].txt.Text = tostring(ore.val)
                        startx = startx + iconsize + 2
                    else
                        oreicons[i].bg.Visible = false
                    end
                end
            else
                ot.Visible=false
                for i=1,3 do oreicons[i].bg.Visible = false end
            end
            if esp.skeleton and ch:FindFirstChild("Humanoid") then
                local isR15 = (ch.Humanoid.RigType == Enum.HumanoidRigType.R15)
                local joints = isR15 and r15joints or r6joints
                local color = td.isTeammate and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 255, 255)
                for idx, joint in ipairs(joints) do
                    local partA = ch:FindFirstChild(joint[1])
                    local partB = ch:FindFirstChild(joint[2])
                    local line = skellines[idx]
                    if partA and partB and line then
                        local posA, onA = cam:WorldToViewportPoint(partA.Position)
                        local posB, onB = cam:WorldToViewportPoint(partB.Position)
                        if onA and onB then
                            line.From = Vector2.new(posA.X, posA.Y)
                            line.To = Vector2.new(posB.X, posB.Y)
                            line.Color = color
                            line.Visible = true
                        else
                            line.Visible = false
                        end
                    elseif line then
                        line.Visible = false
                    end
                end
                for idx = #joints + 1, 15 do
                    local line = skellines[idx]
                    if line then line.Visible = false end
                end
            else
                for _, line in ipairs(skellines) do line.Visible = false end
            end
            local gear = getgear(td)
            local iconsize = math.clamp(18 + (100 / math.max(dist, 1)), 12, 32)
            local padding = 2
            local startx = x2 + 3
            local starty = y1
            if gear.bestarmor and itemimages[gear.bestarmor] then
                icons[1].bg.Position = UDim2.new(0, startx, 0, starty)
                icons[1].bg.Size = UDim2.new(0, iconsize, 0, iconsize)
                icons[1].bg.Visible = true
                if icons[1].lastValue ~= gear.bestarmor then
                    icons[1].lastValue = gear.bestarmor
                    applycustomasset(icons[1].img, itemimages[gear.bestarmor])
                end
                starty = starty + iconsize + padding
            else
                icons[1].bg.Visible = false
                icons[1].lastValue = nil
            end
            if gear.sword and itemimages[gear.sword] then
                icons[2].bg.Position = UDim2.new(0, startx, 0, starty)
                icons[2].bg.Size = UDim2.new(0, iconsize, 0, iconsize)
                icons[2].bg.Visible = true
                if icons[2].lastValue ~= gear.sword then
                    icons[2].lastValue = gear.sword
                    applycustomasset(icons[2].img, itemimages[gear.sword])
                end
            else
                icons[2].bg.Visible = false
                icons[2].lastValue = nil
            end
            local isDead = false
            local ch = getcharacter(td)
            if ch then
                local hum = ch:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health <= 0 then
                    isDead = true
                end
            elseif not td.isP then
                isDead = true
            end
            if isDead or (td.isP and not players:FindFirstChild(td.nm)) then
                for _,v in pairs(o) do pcall(function() v:Remove() end) end
                pcall(function() iconfolder:Destroy() end)
                espo[key]=nil
                if uc then uc:Disconnect() end
            end
        end)
    end
end
local function toggleesp(state)
    espon = state
    if state then
        for _, t in ipairs(getalltargets()) do createesp(t) end
        if not espc["pa"] then
            espc["pa"] = ClientConnections.add(players.PlayerAdded:Connect(function(p)
                task.wait(1)
                for _,t in ipairs(getalltargets()) do
                    if t.obj==p then createesp(t) end
                end
            end))
        end
        if not espc["pr"] then
            espc["pr"] = ClientConnections.add(players.PlayerRemoving:Connect(function(p)
                if espo[p] then
                    for _,v in pairs(espo[p].drawings) do pcall(function() v:Remove() end) end
                    pcall(function() espo[p].folder:Destroy() end)
                    espo[p]=nil
                end
            end))
        end
        local espThrottle = 0
        local sc
        sc = ClientConnections.add(runservice.Heartbeat:Connect(function()
            if not espon then
                sc:Disconnect()
                return
            end
            espThrottle = espThrottle + 1
            if espThrottle % 30 ~= 0 then return end
            for _,t in ipairs(getalltargets()) do
                if not espo[t.obj] then createesp(t) end
            end
        end))
        table.insert(espc, sc)
    else
        for k,objs in pairs(espo) do
            for _,v in pairs(objs.drawings) do pcall(function() v:Remove() end) end
            pcall(function() objs.folder:Destroy() end)
        end
        espo = {}
        for k,c in pairs(espc) do pcall(function() c:Disconnect() end) end
        espc = {}
    end
end
local chamson = false; local chamso = {}; local chamsc = {}; local chamsTeamCheck = true
local chamsFillCol = Color3.fromRGB(160, 120, 255)
local chamsOutlineCol = Color3.fromRGB(255, 255, 255)
local chamsFillTrans = 0.5
local chamsOutlineTrans = 0.2
local chamsMaterial = "none"
local originalMaterials = {}
local function applyMaterials(ch, matName)
    if not ch then return end
    for _, part in ipairs(ch:GetDescendants()) do
        if part:IsA("BasePart") then
            if matName == "none" then
                if originalMaterials[part] then
                    pcall(function() part.Material = originalMaterials[part] end)
                    originalMaterials[part] = nil
                end
            else
                if not originalMaterials[part] then
                    originalMaterials[part] = part.Material
                end
                local enumMat = Enum.Material.Plastic
                if matName == "neon" then
                    enumMat = Enum.Material.Neon
                elseif matName == "forcefield" then
                    enumMat = Enum.Material.ForceField
                elseif matName == "glass" then
                    enumMat = Enum.Material.Glass
                elseif matName == "ice" then
                    enumMat = Enum.Material.Ice
                elseif matName == "wood" then
                    enumMat = Enum.Material.Wood
                elseif matName == "foil" then
                    enumMat = Enum.Material.Foil
                elseif matName == "metal" then
                    enumMat = Enum.Material.Metal
                elseif matName == "granite" then
                    enumMat = Enum.Material.Granite
                elseif matName == "marble" then
                    enumMat = Enum.Material.Marble
                elseif matName == "brick" then
                    enumMat = Enum.Material.Brick
                end
                pcall(function() part.Material = enumMat end)
            end
        end
    end
end
local function restoreMaterials()
    for part, mat in pairs(originalMaterials) do
        if part and part.Parent then
            pcall(function() part.Material = mat end)
        end
    end
    originalMaterials = {}
end
local function createchams(td)
    local key = td.obj; if chamso[key] then return end
    local ch = getcharacter(td)
    if ch then
        local hl = Instance.new("Highlight")
        hl.FillColor = td.isTeammate and Color3.fromRGB(0, 255, 100) or chamsFillCol
        hl.FillTransparency = chamsFillTrans
        hl.OutlineColor = chamsOutlineCol
        hl.OutlineTransparency = chamsOutlineTrans
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = ch
        hl.Parent = ch
        chamso[key] = hl
        applyMaterials(ch, chamsMaterial)
        local uc
        uc = runservice.RenderStepped:Connect(function()
            if not chamson then
                if uc then uc:Disconnect() end
                return
            end
            if chamsTeamCheck and td.isTeammate then
                hl.Enabled = false
                applyMaterials(ch, "none")
            else
                hl.Enabled = true
                hl.FillColor = td.isTeammate and Color3.fromRGB(0, 255, 100) or chamsFillCol
                hl.FillTransparency = chamsFillTrans
                hl.OutlineColor = chamsOutlineCol
                hl.OutlineTransparency = chamsOutlineTrans
                applyMaterials(ch, chamsMaterial)
            end
            if not ch.Parent then
                pcall(function() hl:Destroy() end)
                chamso[key] = nil
                if uc then uc:Disconnect() end
            end
        end)
    end
end
local function togglechams(state)
    chamson = state
    if state then
        for _, t in ipairs(getalltargets()) do createchams(t) end
        if not chamsc["pa"] then
            chamsc["pa"] = ClientConnections.add(players.PlayerAdded:Connect(function(p)
                task.wait(1)
                for _,t in ipairs(getalltargets()) do
                    if t.obj==p then createchams(t) end
                end
            end))
        end
        if not chamsc["pr"] then
            chamsc["pr"] = ClientConnections.add(players.PlayerRemoving:Connect(function(p)
                if chamso[p] then
                    pcall(function() chamso[p]:Destroy() end)
                    chamso[p] = nil
                end
            end))
        end
        local chamsThrottle = 0
        local sc
        sc = ClientConnections.add(runservice.Heartbeat:Connect(function()
            if not chamson then
                sc:Disconnect()
                return
            end
            chamsThrottle = chamsThrottle + 1
            if chamsThrottle % 30 ~= 0 then return end
            for _,t in ipairs(getalltargets()) do
                if not chamso[t.obj] then createchams(t) end
            end
        end))
        table.insert(chamsc, sc)
    else
        for k,hl in pairs(chamso) do pcall(function() hl:Destroy() end) end
        chamso = {}
        for k,c in pairs(chamsc) do pcall(function() c:Disconnect() end) end
        chamsc = {}
        restoreMaterials()
    end
end
local bedhighlights = {}
local chesthighlights = {}
local traceron = false; local tracero = {}; local tracerc = {}; local tracerTeamCheck = true
local tracerColor = Color3.fromRGB(110, 70, 255)
local bedespColor = Color3.fromRGB(255, 60, 60)
local chestespColor = Color3.fromRGB(240, 180, 40)
local worldAmbientColor = Color3.fromRGB(128, 128, 128)
local worldFogColor = Color3.fromRGB(128, 128, 128)
local function updateBedESPColor(c)
    bedespColor = c
    for _, h in ipairs(bedhighlights) do
        if h and h.Parent then h.Color3 = c end
    end
end
local function updateChestESPColor(c)
    chestespColor = c
    for _, h in ipairs(chesthighlights) do
        if h and h.Parent then h.Color3 = c end
    end
end
local function createtracer(td)
    local key = td.obj; if tracero[key] then return end
    if used then
        local l = Drawing.new("Line"); l.Thickness = 1; l.Color = tracerColor or Color3.fromRGB(110,70,255); l.Visible = false; tracero[key] = l
        local uc
        uc = runservice.RenderStepped:Connect(function()
            if not traceron then l.Visible = false if uc then uc:Disconnect() end return end
            if tracerTeamCheck and td.isTeammate then l.Visible = false return end
            local ch = getcharacter(td)
            if not ch or not ch:FindFirstChild("HumanoidRootPart") then l.Visible = false return end
            local sp, on = cam:WorldToViewportPoint(ch.HumanoidRootPart.Position)
            if on then
                l.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
                l.To = Vector2.new(sp.X, sp.Y)
                l.Color = tracerColor or Color3.fromRGB(110,70,255)
                l.Visible = true
            else
                l.Visible = false
            end
            local isDead = false
            if ch then
                local hum = ch:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health <= 0 then
                    isDead = true
                end
            elseif not td.isP then
                isDead = true
            end
            if isDead or (td.isP and not players:FindFirstChild(td.nm)) then
                pcall(function() l:Remove() end)
                tracero[key] = nil
                if uc then uc:Disconnect() end
            end
        end)
    end
end
local function toggletracers(state)
    traceron = state
    if state then
        for _, t in ipairs(getalltargets()) do createtracer(t) end
        if not tracerc["pa"] then
            tracerc["pa"] = ClientConnections.add(players.PlayerAdded:Connect(function(p)
                task.wait(1)
                for _,t in ipairs(getalltargets()) do
                    if t.obj==p then createtracer(t) end
                end
            end))
        end
        if not tracerc["pr"] then
            tracerc["pr"] = ClientConnections.add(players.PlayerRemoving:Connect(function(p)
                if tracero[p] then
                    pcall(function() tracero[p]:Remove() end)
                    tracero[p] = nil
                end
            end))
        end
        local tracerThrottle = 0
        local sc
        sc = ClientConnections.add(runservice.Heartbeat:Connect(function()
            if not traceron then
                sc:Disconnect()
                return
            end
            tracerThrottle = tracerThrottle + 1
            if tracerThrottle % 30 ~= 0 then return end
            for _,t in ipairs(getalltargets()) do
                if not tracero[t.obj] then createtracer(t) end
            end
        end))
        table.insert(tracerc, sc)
    else
        for k,l in pairs(tracero) do pcall(function() l:Remove() end) end
        tracero = {}
        for k,c in pairs(tracerc) do pcall(function() c:Disconnect() end) end
        tracerc = {}
    end
end
local function togglebedesp(state)
    if state then
        for _, bed in ipairs(game:GetService("CollectionService"):GetTagged("bed")) do
            for _, part in ipairs(bed:GetChildren()) do
                if part:IsA("BasePart") then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Size = part.Size + Vector3.new(0.05, 0.05, 0.05)
                    box.Color3 = bedespColor or Color3.fromRGB(255, 60, 60)
                    box.Transparency = 0.5
                    box.AlwaysOnTop = true
                    box.ZIndex = 5
                    box.Adornee = part
                    box.Parent = part
                    table.insert(bedhighlights, box)
                end
            end
        end
    else
        for _, h in ipairs(bedhighlights) do pcall(function() h:Destroy() end) end
        table.clear(bedhighlights)
    end
end
local function togglechestesp(state)
    if state then
        for _, chest in ipairs(game:GetService("CollectionService"):GetTagged("chest")) do
            local box = Instance.new("BoxHandleAdornment")
            box.Size = chest.Size + Vector3.new(0.1, 0.1, 0.1)
            box.Color3 = chestespColor or Color3.fromRGB(240, 180, 40)
            box.Transparency = 0.5
            box.AlwaysOnTop = true
            box.ZIndex = 5
            box.Adornee = chest
            box.Parent = chest
            table.insert(chesthighlights, box)
        end
    else
        for _, h in ipairs(chesthighlights) do pcall(function() h:Destroy() end) end
        table.clear(chesthighlights)
    end
end
local function unload()
    clientActive = false
    if getgenv().vmConnection then
        pcall(function() getgenv().vmConnection:Disconnect() end)
        getgenv().vmConnection = nil
    end
    if getgenv().selfChamsCon then
        pcall(function() getgenv().selfChamsCon:Disconnect() end)
        getgenv().selfChamsCon = nil
    end
    for nm, ref in pairs(toggleRefs) do
        if ref.get and ref.get() == true and string.lower(tostring(nm)) ~= "unload client" then
            pcall(function() ref.toggle() end)
        end
    end
    task.wait(0.15)
    if getgenv().oldnamecall then
        pcall(function() hookmetamethod(game, "__namecall", getgenv().oldnamecall) end)
        getgenv().oldnamecall = nil
    end
    table.clear(moduleStates)
    table.clear(toggleRefs)
    table.clear(gradientAnimations)
    stealerOn = false
    espon = false
    chamson = false
    traceron = false
    for k, c in pairs(active) do
        if c and typeof(c) == "RBXScriptConnection" then
            pcall(function() c:Disconnect() end)
        end
    end
    table.clear(active)
    for _, c in pairs(uiconns) do
        if c and typeof(c) == "RBXScriptConnection" then
            pcall(function() c:Disconnect() end)
        end
    end
    table.clear(uiconns)
    pcall(function() ClientConnections.cleanup() end)
    toggleesp(false)
    toggletracers(false)
    togglebedesp(false)
    togglechestesp(false)
    togglechams(false)
    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
        plr.Character.Humanoid.WalkSpeed = 16
        plr.Character.Humanoid.JumpPower = 50
        plr.Character.Humanoid.PlatformStand = false
    end
    workspace.Gravity = 196.2
    lighting.GlobalShadows = true
    lighting.Ambient = Color3.fromRGB(127, 127, 127)
    getgenv().fpsBoosterActive = false
    if active["fps_booster_add"] then
        pcall(function() active["fps_booster_add"]:Disconnect() end)
        active["fps_booster_add"] = nil
    end
    if getgenv().originalLighting then
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
    end
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
    cam.FieldOfView = 70
    if getgenv().old_kb and bw.KB then bw.KB.applyKnockback = getgenv().old_kb end
    if getgenv().old_bob and bw.Viewmodel then bw.Viewmodel.playAnimation = getgenv().old_bob end
    if getgenv().old_noclick and bw.Sword then bw.Sword.isClickingTooFast = getgenv().old_noclick end
    if getgenv().old_noslow and bw.Spring then
        local sprint = bw.Spring
        if sprint and sprint.getMovementStatusModifier then
            pcall(function() sprint:getMovementStatusModifier().addModifier = getgenv().old_noslow end)
        end
    end
    if getgenv().old_noclickdelay and bw.Sword then bw.Sword.isClickingTooFast = getgenv().old_noclickdelay end
    if getgenv().old_reach then
        pcall(function()
            local combatconstant = require(rep.TS.combat["combat-constant"]).CombatConstant
            if combatconstant then combatconstant.RAYCAST_SWORD_CHARACTER_DISTANCE = getgenv().old_reach end
        end)
    end
    if getgenv().old_bow_calc and bw.ProjectileController then
        bw.ProjectileController.calculateImportantLaunchValues = getgenv().old_bow_calc
        getgenv().old_bow_calc = nil
    end
    if getgenv().old_lighting then
        for prop, val in pairs(getgenv().old_lighting) do pcall(function() lighting[prop] = val end) end
    end
    if shaderCC then pcall(function() shaderCC:Destroy() end); shaderCC = nil end
    if shaderBloom then pcall(function() shaderBloom:Destroy() end); shaderBloom = nil end
    local fovcircle = workspace.CurrentCamera:FindFirstChild("jdk_fovcircle")
    if fovcircle then fovcircle:Destroy() end
    if fovCircleObj then pcall(function() fovCircleObj:Remove() end); fovCircleObj = nil end
    local existing = workspace:FindFirstChild("jdk_snow")
    if existing then existing:Destroy() end
    if getgenv().cannonWaypointVisual then
        pcall(function() getgenv().cannonWaypointVisual:Destroy() end)
        getgenv().cannonWaypointVisual = nil
    end
    getgenv().cannonWaypointPos = nil
    table.clear(getgenv().aimedCannons)
    if plr.Character then
        local cape = plr.Character:FindFirstChild("jdk_cape")
        if cape then cape:Destroy() end
        local hat = plr.Character:FindFirstChild("jdk_chinahat")
        if hat then hat:Destroy() end
    end
    if arraylistcon then pcall(function() arraylistcon:Disconnect() end); arraylistcon = nil end
    if gui then pcall(function() gui:Destroy() end) end
    if espgui then pcall(function() espgui:Destroy() end) end
    if blur then pcall(function() blur:Destroy() end) end
    print("jdkclient unloaded safely")
end
local rV = 18; local aS = 0.5; local aF = 110; local sV = 28; local flySpd = 35
local velH = 0; local velV = 0
local hjHeight = 100
local spiderSpd = 30
local stealerOn = false
local worldModOn = false
local snowOn = false
local fovCircleObj = nil
local capeId = "13374270273"
local shaderCC = nil; local shaderBloom = nil
local kaEnabled = true
local kaLegitAim = false
local kaBlatant = true
local kaTeamCheck = true
local kaToolCheck = false
local kaCPS = 12
local kaTargets = {
    Players = true,
    Guardians = true,
    Titans = true,
    Dummies = true,
    Ducks = true,
    Chickens = true,
}
local acCPS = 12
local scafDelay = 0.1; local scafJump = false; local scafLock = false; local scafExpand = 1; local scafDown = true; local scafDiag = true
local abVis = false; local abMaxDist = 300; local abTeamCheck = true
local httpservice = game:GetService("HttpService")
local function writefilesafe(path, content) if writefile then pcall(writefile, path, content) end end
local function readfilesafe(path) if readfile then local s, r = pcall(readfile, path) return s and r or nil end return nil end
local function isfoldersafe(path) if isfolder then local s, r = pcall(isfolder, path) return s and r or false end return false end
local function makefoldersafe(path) if makefolder then pcall(makefolder, path) end end
local function delfilesafe(path) if delfile then pcall(delfile, path) end end
local function getClientStore()
    local lp = game:GetService("Players").LocalPlayer
    if not lp then return nil end
    local ps = lp:FindFirstChild("PlayerScripts")
    if not ps then return nil end
    local ts = ps:FindFirstChild("TS")
    if not ts then return nil end
    local ui = ts:FindFirstChild("ui")
    if not ui then return nil end
    local store = ui:FindFirstChild("store")
    if not store then return nil end
    local success, storeMod = pcall(require, store)
    return success and storeMod and storeMod.ClientStore or nil
end
local currentconfigname = "default"
local newconfigname = nil
local lobbyConfigName = "default"
local matchConfigName = "default"
local autoexecEnabled = false
local function getconfigs()
    local configs = {"default"}
    if listfiles then
        local files = {}
        pcall(function() files = listfiles("jdkclient") or {} end)
        for _, file in ipairs(files) do
            local name = file:gsub("%.json$", ""):match("[^/\\]+$")
            if name and name ~= "default" and name ~= "autoconfig_settings" then
                table.insert(configs, name)
            end
        end
    end
    return configs
end
local function saveAutoConfigSettings()
    local settings = {
        lobbyConfig = lobbyConfigName or "default",
        matchConfig = matchConfigName or "default",
        autoexec = autoexecEnabled or false
    }
    local success, str = pcall(function() return httpservice:JSONEncode(settings) end)
    if success then
        writefilesafe("jdkclient/autoconfig_settings.json", str)
    end
end
local function saveconfig(name)
    local data = {}
    for modname, ref in pairs(toggleRefs) do
        local lower_mod = string.lower(modname)
        if lower_mod == "unload client" or lower_mod == "save config" or lower_mod == "load config" or lower_mod == "delete config"
           or lower_mod == "select config" or lower_mod == "new config name" or lower_mod == "auto execute"
           or lower_mod == "lobby config" or lower_mod == "match config" then
            continue
        end
        local moddata = {
            enabled = (ref.get and ref.get() == true) or false,
            keybind = ref.keybind and ref.keybind.get() and tostring(ref.keybind.get()):gsub("Enum.KeyCode.", "") or nil,
            settings = {}
        }
        if ref.settings then
            for setname, setref in pairs(ref.settings) do
                if setref and setref.get then
                    pcall(function()
                        local val = setref.get()
                        if typeof(val) == "Color3" then
                            moddata.settings[setname] = {r = val.R, g = val.G, b = val.B, isColor3 = true}
                        else
                            moddata.settings[setname] = val
                        end
                    end)
                end
            end
        end
        data[modname] = moddata
    end
    local success, str = pcall(function() return httpservice:JSONEncode(data) end)
    if success then
        if not isfoldersafe("jdkclient") then makefoldersafe("jdkclient") end
        writefilesafe("jdkclient/"..name..".json", str)
    else
        warn("jdkclient saveconfig failed to encode: " .. tostring(str))
    end
end
local function loadconfig(name)
    local str = readfilesafe("jdkclient/"..name..".json")
    if not str then return end
    local data
    local decodeSuccess = pcall(function() data = httpservice:JSONDecode(str) end)
    if not decodeSuccess or not data then return end
    for modname, moddata in pairs(data) do
        local ref = toggleRefs[modname]
        if ref then
            if moddata.settings and ref.settings then
                for setname, setval in pairs(moddata.settings) do
                    local setref = ref.settings[setname]
                    if setref and setref.set then
                        pcall(function()
                            if type(setval) == "table" and setval.isColor3 then
                                setref.set(Color3.new(setval.r, setval.g, setval.b))
                            else
                                setref.set(setval)
                            end
                        end)
                    end
                end
            end
            if moddata.keybind and ref.keybind and ref.keybind.set then
                pcall(function()
                    local matched = nil
                    for _, k in pairs(Enum.KeyCode:GetEnumItems()) do
                        if string.lower(k.Name) == string.lower(moddata.keybind) then matched = k; break end
                    end
                    if matched then ref.keybind.set(matched) end
                end)
            end
            if ref.get and ref.toggle then
                pcall(function()
                    local targetState = (moddata.enabled == true)
                    if (ref.get() == true) ~= targetState then
                        ref.toggle()
                    end
                end)
            end
        end
    end
end
local function loadAutoConfig()
    local autoSettingsStr = readfilesafe("jdkclient/autoconfig_settings.json")
    local autoSettings = nil
    if autoSettingsStr then
        pcall(function() autoSettings = httpservice:JSONDecode(autoSettingsStr) end)
    end
    local configToLoad = "default"
    if autoSettings then
        lobbyConfigName = autoSettings.lobbyConfig or "default"
        matchConfigName = autoSettings.matchConfig or "default"
        autoexecEnabled = autoSettings.autoexec or false
        local isLobby = (game.PlaceId == 6872274481 or game.PlaceId == 6872265039)
        if isLobby then
            configToLoad = lobbyConfigName
        else
            configToLoad = matchConfigName
        end
    end
    pcall(function() loadconfig(configToLoad) end)
    task.spawn(function()
        for i = 1, 20 do
            local success = pcall(function()
                if toggleRefs["lobby config"] and toggleRefs["lobby config"].set then
                    toggleRefs["lobby config"].set(lobbyConfigName)
                end
                if toggleRefs["match config"] and toggleRefs["match config"].set then
                    toggleRefs["match config"].set(matchConfigName)
                end
                if toggleRefs["auto execute"] then
                    local ref = toggleRefs["auto execute"]
                    if (ref.get() == true) ~= (autoexecEnabled == true) then
                        ref.toggle()
                    end
                end
                if toggleRefs["select config"] and toggleRefs["select config"].set then
                    toggleRefs["select config"].set(configToLoad)
                end
            end)
            if success and toggleRefs["lobby config"] then break end
            task.wait(0.2)
        end
    end)
end
local features = {
    {"combat", {
        {name="Kill Aura", hasSettings=true, defaultKey=Enum.KeyCode.K, settings={
            {type="toggle", name="enabled", default=true, callback=function(v) kaEnabled=v end},
            {type="toggle", name="blatant mode", default=true, callback=function(v) kaBlatant=v end},
            {type="toggle", name="legit aim", default=false, callback=function(v) kaLegitAim=v end},
            {type="toggle", name="team check", default=true, callback=function(v) kaTeamCheck=v end},
            {type="toggle", name="tool check", default=false, callback=function(v) kaToolCheck=v end},
            {type="slider", name="cps", min=5, max=25, default=12, initial=12, suffix=" cps", callback=function(v) kaCPS=v end},
            {type="slider", name="range", min=10, max=22, default=18, initial=18, suffix=" studs", callback=function(v) kaRange=v end},
            {type="toggle", name="players", default=true, callback=function(v) kaTargets.Players=v end},
            {type="toggle", name="guardians", default=true, callback=function(v) kaTargets.Guardians=v end},
            {type="toggle", name="titans", default=true, callback=function(v) kaTargets.Titans=v end}
        }, logic=function(state)
            if state then
                local kaConfig = {
                    Enabled = true,
                    Targets = kaTargets,
                    Weapons = {
                        "wood_scythe", "stone_scythe", "iron_scythe", "diamond_scythe", "mythic_scythe",
                        "wood_great_hammer", "stone_great_hammer", "iron_great_hammer", "diamond_great_hammer", "mythic_great_hammer",
                        "wood_dagger", "stone_dagger", "iron_dagger", "diamond_dagger", "mythic_dagger",
                        "wood_gauntlets", "stone_gauntlets", "iron_gauntlets", "diamond_gauntlets", "mythic_gauntlets",
                        "noctium_blade", "noctium_blade_2", "noctium_blade_3", "noctium_blade_4",
                        "wood_dao", "stone_dao", "iron_dao", "diamond_dao", "emerald_dao",
                        "wood_gun_blade", "stone_gun_blade", "iron_gun_blade", "diamond_gun_blade", "emerald_gun_blade",
                        "summoner_claw_1", "summoner_claw_2", "summoner_claw_3", "summoner_claw_4",
                        "wood_sword", "stone_sword", "iron_sword", "diamond_sword", "emerald_sword",
                        "laser_sword", "guards_spear", "mass_hammer", "baguette", "void_sword",
                        "tinkers_wrench", "rageblade", "ice_sword", "frosty_hammer", "wizard_stick", "light_sword",
                        "wood_chainsaw", "stone_chainsaw", "iron_chainsaw", "diamond_chainsaw", "emerald_chainsaw", "void_chainsaw", "hephaestus_chainsaw", "chainsaw", "void_scythe", "jade_hammer",
                    }
                }
                local SUMMONER_CLAWS = {
                    summoner_claw_1 = true,
                    summoner_claw_2 = true,
                    summoner_claw_3 = true,
                    summoner_claw_4 = true,
                }
                local weaponsSet = {}
                for _, name in ipairs(kaConfig.Weapons) do weaponsSet[name] = true end
                local function isWeaponName(wName)
                    if not wName then return false end
                    local wNameLower = wName:lower()
                    if weaponsSet[wName] or weaponsSet[wNameLower] then return true end
                    local normalized = wNameLower:gsub("-", "_")
                    if weaponsSet[normalized] then return true end
                    local normalized2 = wNameLower:gsub("_", "-")
                    if weaponsSet[normalized2] then return true end
                    if wNameLower:find("chainsaw")
                        or wNameLower:find("scythe")
                        or wNameLower:find("hammer")
                        or wNameLower:find("dagger")
                        or wNameLower:find("blade")
                        or wNameLower:find("dao")
                        or wNameLower:find("sword")
                        or wNameLower:find("claw")
                        or wNameLower:find("wrench")
                        or wNameLower:find("spear")
                        or wNameLower:find("rageblade")
                        or wNameLower:find("stick")
                        or wNameLower:find("baguette") then
                        return true
                    end
                    return false
                end
                local Guardians = {}
                local Titans = {}
                local Dummies = {}
                local Ducks = {}
                local Chickens = {}
                local function classify(model)
                    if not model:IsA("Model") then return end
                    if model.Name == "Diamond Guardian" then
                        table.insert(Guardians, model)
                    elseif model.Name == "Titan" then
                        table.insert(Titans, model)
                    elseif model.Name:find("Dummy") then
                        table.insert(Dummies, model)
                    elseif model.Name == "Duck" then
                        table.insert(Ducks, model)
                    elseif model.Name == "Chicken" then
                        table.insert(Chickens, model)
                    end
                end
                local function removeFrom(tbl, model)
                    for i, v in ipairs(tbl) do
                        if v == model then table.remove(tbl, i) break end
                    end
                end
                for _, obj in ipairs(workspace:GetChildren()) do classify(obj) end
                active["ka_classify"] = workspace.ChildAdded:Connect(classify)
                active["ka_remove"] = workspace.ChildRemoved:Connect(function(obj)
                    removeFrom(Guardians, obj) removeFrom(Titans, obj)
                    removeFrom(Dummies, obj)   removeFrom(Ducks, obj)
                    removeFrom(Chickens, obj)
                end)
                local function getRoot(model)
                    return model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                end
                local function getClosestTarget()
                    local myChar = plr.Character
                    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
                    if myHum and myHum.Health <= 0 then return nil end
                    local myRoot = myChar and getRoot(myChar)
                    if not myRoot then return nil end
                    local myPos = myRoot.Position
                    local maxRange = kaRange or 18
                    if kaBlatant == false then maxRange = math.min(maxRange, 14.4) end
                    local closest, shortest = nil, maxRange
                    local cfg = kaConfig.Targets
                    local function check(char)
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health <= 0 then return end
                        local root = getRoot(char)
                        if root then
                            local dist = (root.Position - myPos).Magnitude
                            if dist <= shortest then shortest = dist; closest = char end
                        end
                    end
                    if cfg.Players then
                        for _, player in ipairs(players:GetPlayers()) do
                            if player ~= plr and player.Character then
                                if kaTeamCheck then
                                    local isTeammate = (player.Team and plr.Team and player.Team == plr.Team) or (player:GetAttribute("Team") and plr:GetAttribute("Team") and player:GetAttribute("Team") == plr:GetAttribute("Team"))
                                    if isTeammate then continue end
                                end
                                check(player.Character)
                            end
                        end
                    end
                    if cfg.Guardians then for _, g in ipairs(Guardians) do check(g) end end
                    if cfg.Titans    then for _, t in ipairs(Titans)    do check(t) end end
                    if cfg.Dummies   then for _, d in ipairs(Dummies)   do check(d) end end
                    if cfg.Ducks     then for _, d in ipairs(Ducks)     do check(d) end end
                    if cfg.Chickens  then for _, c in ipairs(Chickens)  do check(c) end end
                    return closest
                end
                local function getWeapon()
                    local myChar = plr.Character
                    if not myChar then return nil end
                    for _, child in ipairs(myChar:GetChildren()) do
                        if child:IsA("Tool") and isWeaponName(child.Name) then
                            return child
                        end
                    end
                    if kaToolCheck then
                        return nil
                    end
                    local handCheck = myChar:FindFirstChild("HandInvItem")
                    if handCheck and handCheck.Value then
                        local wName = handCheck.Value.Name
                        if isWeaponName(wName) then
                            return handCheck.Value
                        end
                    end
                    return nil
                end
                local function getEquippedWeaponName()
                    local myChar = plr.Character
                    if not myChar then return nil end
                    for _, child in ipairs(myChar:GetChildren()) do
                        if child:IsA("Tool") and isWeaponName(child.Name) then
                            return child.Name
                        end
                    end
                    if kaToolCheck then
                        return nil
                    end
                    local handCheck = myChar:FindFirstChild("HandInvItem")
                    if handCheck and handCheck.Value then
                        local wName = handCheck.Value.Name
                        if isWeaponName(wName) then
                            return wName
                        end
                    end
                    return nil
                end
                local function findRemote(name)
                    local netManaged = rep:FindFirstChild("rbxts_include")
                        and rep.rbxts_include:FindFirstChild("node_modules")
                        and rep.rbxts_include.node_modules:FindFirstChild("@rbxts")
                        and rep.rbxts_include.node_modules["@rbxts"]:FindFirstChild("net")
                        and rep.rbxts_include.node_modules["@rbxts"].net:FindFirstChild("out")
                        and rep.rbxts_include.node_modules["@rbxts"].net.out:FindFirstChild("_NetManaged")
                    if not netManaged then return nil end
                    return netManaged:FindFirstChild(name)
                end
                local SwordHit = findRemote("SwordHit")
                local SummonerClawRemote = findRemote("SummonerClawAttackRequest")
                local function attackSummonerClaw(myRoot, targetRoot)
                    if not SummonerClawRemote then return end
                    local direction = (targetRoot.Position - myRoot.Position).Unit
                    local distance = (myRoot.Position - targetRoot.Position).Magnitude
                    local attackPos = myRoot.Position + direction * math.max(distance - 16, 0)
                    local args = {
                        position = attackPos,
                        direction = direction,
                        clientTime = tick()
                    }
                    pcall(function()
                        SummonerClawRemote:FireServer(args)
                    end)
                    pcall(function()
                        local wName = getEquippedWeaponName() or "summoner_claw_1"
                        local clawHand = bw.Knit and bw.Knit.Controllers and bw.Knit.Controllers.SummonerClawHandController
                        local lastAttack = clawHand and clawHand.lastAttackTime or 0
                        local cooldown = 0.38
                        pcall(function()
                            local balance = require(rep.TS.games.bedwars.kit.kits.summoner["summoner-kit-balance"])
                            if balance and balance.SummonerKitBalance then
                                cooldown = balance.SummonerKitBalance.CLAW_COOLDOWN or cooldown
                            end
                        end)
                        if (workspace:GetServerTimeNow() - lastAttack) >= cooldown then
                            if clawHand then
                                pcall(function() clawHand.lastAttackTime = workspace:GetServerTimeNow() end)
                            end
                            local clawController = bw.Knit and bw.Knit.Controllers and bw.Knit.Controllers.SummonerClawController
                            if clawController and clawController.clawAttack then
                                clawController:clawAttack(plr, myRoot.Position, direction, wName)
                            end
                        end
                        if bw.Sword then
                            if bw.Sword.swing then
                                bw.Sword:swing()
                            elseif bw.Sword.swingSwordAtMouse then
                                bw.Sword:swingSwordAtMouse()
                            end
                            local itemMeta = require(rep.TS.item["item-meta"]).getItemMeta
                            local meta = itemMeta(wName)
                            if meta and bw.Sword.playSwordEffect then
                                bw.Sword:playSwordEffect(meta)
                            end
                        end
                    end)
                end
                local function attackSword(target, weapon, myRoot, targetRoot)
                    if not SwordHit then return end
                    local myPos = myRoot.Position
                    local targetPos = targetRoot.Position
                    local direction = (targetPos - myPos).Unit
                    local distance = (myPos - targetPos).Magnitude
                    local pos = myPos + direction * math.max(distance - 14, 0)
                    if kaBlatant == false then pos = myPos end
                    local args = {
                        chargedAttack = { chargeRatio = 0 },
                        entityInstance = target,
                        validate = {
                            raycast = {
                                cameraPosition = { value = pos },
                                cursorDirection = { value = direction }
                            },
                            selfPosition   = { value = pos },
                            targetPosition = { value = targetPos },
                        },
                        weapon = weapon,
                    }
                    pcall(function()
                        SwordHit:FireServer(args)
                    end)
                    pcall(function()
                        if bw.Sword then
                            if bw.Sword.swing then
                                bw.Sword:swing()
                            elseif bw.Sword.swingSwordAtMouse then
                                bw.Sword:swingSwordAtMouse()
                            end
                            local itemMeta = require(rep.TS.item["item-meta"]).getItemMeta
                            local meta = itemMeta(weapon.Name or weapon)
                            if meta and bw.Sword.playSwordEffect then
                                bw.Sword:playSwordEffect(meta)
                            end
                        end
                    end)
                end
                local function attack()
                    local myChar = plr.Character
                    if not myChar then return end
                    local myRoot = getRoot(myChar)
                    if not myRoot then return end
                    local target = getClosestTarget()
                    if not target then return end
                    local targetRoot = getRoot(target)
                    if not targetRoot then return end
                    if moduleStates["target hud"] then
                        local isPlayer = players:GetPlayerFromCharacter(target) ~= nil
                        local pObj = isPlayer and players:GetPlayerFromCharacter(target) or target
                        pcall(function() updatetargethud({obj = pObj, char = target, hrp = targetRoot, nm = target.Name, isP = isPlayer}) end)
                    end
                    local weaponName = getEquippedWeaponName()
                    if not weaponName then return end
                    if SUMMONER_CLAWS[weaponName] or weaponName:find("summoner_claw") then
                        attackSummonerClaw(myRoot, targetRoot)
                    else
                        local weapon = getWeapon()
                        if not weapon then return end
                        attackSword(target, weapon, myRoot, targetRoot)
                    end
                end
                local lastPartSwitch = 0
                local currentMouseTargetPart = "HumanoidRootPart"
                local lastOffsetUpdate = 0
                local currentOffset = Vector3.zero
                active["ka_legit_aim"] = ClientConnections.add(runservice.RenderStepped:Connect(function()
                    if not (kaEnabled and (kaLegitAim or not kaBlatant) and not kaBlatant) then return end
                    local weapon = getWeapon()
                    if not weapon then return end
                    local myChar = plr.Character
                    if not myChar then return end
                    local myHum = myChar:FindFirstChildOfClass("Humanoid")
                    if myHum and myHum.Health <= 0 then return end
                    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                    local myHead = myChar:FindFirstChild("Head")
                    if not myRoot or not myHead then return end
                    local target = getClosestTarget()
                    if not target then return end
                    local targetHum = target:FindFirstChildOfClass("Humanoid")
                    if targetHum and targetHum.Health <= 0 then return end
                    local targetRoot = target:FindFirstChild("HumanoidRootPart")
                    if not targetRoot then return end
                    local isFirstPerson = (cam.CFrame.Position - myHead.Position).Magnitude < 2.0
                    local isShiftLock = uis.MouseBehavior == Enum.MouseBehavior.LockCenter
                    if tick() - lastOffsetUpdate > 0.4 then
                        currentOffset = Vector3.new(
                            math.random(-5, 5) / 10,
                            math.random(-6, 6) / 10,
                            math.random(-5, 5) / 10
                        )
                        lastOffsetUpdate = tick()
                    end
                    if isFirstPerson or isShiftLock then
                        local targetPos = targetRoot.Position + currentOffset
                        local targetDir = (targetPos - cam.CFrame.Position).Unit
                        local camDir = cam.CFrame.LookVector
                        local angle = math.acos(math.clamp(camDir:Dot(targetDir), -1, 1))
                        local angleDeg = math.deg(angle)
                        if angleDeg <= 65 and angleDeg > 0.8 then
                            local lerpSpeed = math.clamp(0.04 + (math.random(-8, 8) / 1000), 0.02, 0.07)
                            local targetCF = CFrame.new(cam.CFrame.Position, targetPos)
                            cam.CFrame = cam.CFrame:Lerp(targetCF, lerpSpeed)
                        end
                    else
                        if tick() - lastPartSwitch > math.random(15, 35) / 10 then
                            currentMouseTargetPart = (math.random() > 0.4) and "HumanoidRootPart" or "Head"
                            lastPartSwitch = tick()
                        end
                        local aimPart = target:FindFirstChild(currentMouseTargetPart) or targetRoot
                        local targetWorldPos = aimPart.Position + currentOffset
                        local screenPos, onScreen = cam:WorldToViewportPoint(targetWorldPos)
                        if onScreen then
                            local mouseLoc = uis:GetMouseLocation()
                            local dx = screenPos.X - mouseLoc.X
                            local dy = screenPos.Y - mouseLoc.Y
                            local dist = math.sqrt(dx^2 + dy^2)
                            if dist < 280 and dist > 3 then
                                local speedCoeff = math.clamp(0.12 + (math.random(-15, 15) / 1000), 0.08, 0.16)
                                if dist < 30 then
                                    speedCoeff = speedCoeff * 0.5
                                end
                                if mousemoverel then
                                    mousemoverel(dx * speedCoeff, dy * speedCoeff)
                                elseif mousemoveabs then
                                    mousemoveabs(mouseLoc.X + dx * speedCoeff, mouseLoc.Y + dy * speedCoeff)
                                end
                            end
                        end
                    end
                end))
                active["ka"] = ClientConnections.addThread(task.spawn(function()
                    task.wait(2)
                    while active["ka"] do
                        if kaEnabled then
                            pcall(attack)
                        end
                        local delay = (1 / (kaCPS or 12)) + (math.random(-15, 15) / 1000)
                        task.wait(math.max(delay, 0.01))
                    end
                end))
            else
                if active["ka"] then
                    pcall(task.cancel, active["ka"])
                    active["ka"] = nil
                end
                if active["ka_legit_aim"] then
                    pcall(function() active["ka_legit_aim"]:Disconnect() end)
                    active["ka_legit_aim"] = nil
                end
                if active["ka_classify"] then
                    pcall(function() active["ka_classify"]:Disconnect() end)
                    active["ka_classify"] = nil
                end
                if active["ka_remove"] then
                    pcall(function() active["ka_remove"]:Disconnect() end)
                    active["ka_remove"] = nil
                end
            end
        end},
        {name="Aimbot", hasSettings=true, defaultKey=Enum.KeyCode.L, settings={
            {type="slider", name="speed", min=0.1, max=1, default=0.5, initial=0.5, suffix="x", callback=function(v) aS=v end},
            {type="slider", name="fov", min=10, max=180, default=110, initial=110, suffix=" deg", callback=function(v) aF=v end},
            {type="slider", name="max dist", min=50, max=500, default=300, initial=300, suffix=" studs", callback=function(v) abMaxDist=v end},
            {type="toggle", name="visibility check", default=false, callback=function(v) abVis=v end},
            {type="toggle", name="team check", default=true, callback=function(v) abTeamCheck=v end},
            {type="toggle", name="fov circle", default=false, callback=function(v)
                if not fovCircleObj and pcall(function() return Drawing.new end) then
                    fovCircleObj = Drawing.new("Circle")
                    fovCircleObj.Thickness = 1
                    fovCircleObj.Color = c_colors.accent
                    fovCircleObj.Filled = false
                end
                if fovCircleObj then
                    fovCircleObj.Visible = v
                end
            end}
        }, logic=function(state)
            if state then
                if fovCircleObj then fovCircleObj.Visible = true end
                active["ab"]=runservice.RenderStepped:Connect(function()
                    if fovCircleObj and fovCircleObj.Visible then
                        fovCircleObj.Position = uis:GetMouseLocation()
                        fovCircleObj.Radius = aF
                    end
                    local t=closestcursor(aF, abVis, abTeamCheck)
                    if t and t.char and t.char:FindFirstChild("Head") and t.hrp then
                        local dist = (t.hrp.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= (abMaxDist or 300) then
                            local p=t.char:FindFirstChild("Head")
                            cam.CFrame=cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position,p.Position+Vector3.new(0,0.5,0)), aS*0.3)
                        end
                    end
                end)
            elseif active["ab"] then
                active["ab"]:Disconnect(); active["ab"]=nil
                if fovCircleObj then fovCircleObj.Visible = false end
            end
        end},
        {name="Bow Aimbot", hasSettings=true, settings={
            {type="toggle", name="distance based", default=false, callback=function(v) getgenv().jdk.bowAimDistanceBased = v end},
            {type="toggle", name="prediction", default=true, callback=function(v) getgenv().jdk.bowAimPredict = v end},
            {type="dropdown", name="target part", options={"Head", "Body", "Random"}, default="Body", callback=function(v) getgenv().jdk.bowAimPart = v end},
            {type="slider", name="predict scale", min=0.5, max=2.0, default=1.0, initial=1.0, suffix="x", callback=function(v) getgenv().jdk.bowAimPredictScale = v end},
            {type="slider", name="y offset", min=-2, max=3, default=1.0, initial=1.0, suffix=" studs", callback=function(v) getgenv().jdk.bowAimYOffset = v end}
        }, logic=function(state)
            active["bowaimbot"] = state
            if state then
                if bw.ProjectileController and not getgenv().old_bow_calc then
                    getgenv().old_bow_calc = bw.ProjectileController.calculateImportantLaunchValues
                    bw.ProjectileController.calculateImportantLaunchValues = function(self, projmeta, worldmeta, origin, shootpos)
                        if active["bowaimbot"] then
                            local t
                            if getgenv().jdk.bowAimDistanceBased then
                                t = nearest(300, false, true)
                            else
                                t = closestcursor(300, false, true)
                            end
                            if t and t.hrp then
                                local pos = shootpos or self:getLaunchPosition(origin)
                                if pos then
                                    local aimPartName = getgenv().jdk.bowAimPart or "Body"
                                    if aimPartName == "Random" then
                                        aimPartName = (math.random() > 0.5) and "Head" or "Body"
                                    end
                                    local aimPart
                                    if aimPartName == "Head" and t.char then
                                        aimPart = t.char:FindFirstChild("Head")
                                    end
                                    aimPart = aimPart or t.hrp
                                    local yOff = getgenv().jdk.bowAimYOffset or 1.0
                                    local targetPos = aimPart.Position + Vector3.new(0, yOff, 0)
                                    local targetVel = t.hrp.Velocity * (getgenv().jdk.bowAimPredictScale or 1.0)
                                    if not (getgenv().jdk.bowAimPredict == nil or getgenv().jdk.bowAimPredict) then
                                        targetVel = Vector3.zero
                                    end
                                    local speed = projmeta:getProjectileMeta().launchVelocity or 100
                                    local grav = (projmeta:getProjectileMeta().gravitationalAcceleration or 196.2) * projmeta.gravityMultiplier
                                    local tTime = (targetPos - pos).Magnitude / speed
                                    for i = 1, 3 do
                                        local predictedPos = targetPos + (targetVel * tTime) + Vector3.new(0, 0.5 * grav * (tTime ^ 2), 0)
                                        tTime = (predictedPos - pos).Magnitude / speed
                                    end
                                    local finalAimPos = targetPos + (targetVel * tTime) + Vector3.new(0, 0.5 * grav * (tTime ^ 2), 0)
                                    local dir = (finalAimPos - pos).Unit
                                    return {
                                        initialVelocity = dir * speed,
                                        positionFrom = pos,
                                        deltaT = 3,
                                        gravitationalAcceleration = grav,
                                        drawDurationSeconds = 5
                                    }
                                end
                            end
                        end
                        return getgenv().old_bow_calc(self, projmeta, worldmeta, origin, shootpos)
                    end
                end
            else
                if bw.ProjectileController and getgenv().old_bow_calc then
                    bw.ProjectileController.calculateImportantLaunchValues = getgenv().old_bow_calc
                    getgenv().old_bow_calc = nil
                end
            end
        end},
        {name="Bow Pierce", logic=function(state)
            local itemmeta = bw.ItemMeta
            if itemmeta then
                makeWritable(itemmeta)
                getgenv().old_pierce = getgenv().old_pierce or {}
                for name, meta in pairs(itemmeta) do
                    if type(meta) == "table" then
                        makeWritable(meta)
                        if meta.projectile then
                            makeWritable(meta.projectile)
                            if state then
                                if getgenv().old_pierce[name.."_proj"] == nil then
                                    getgenv().old_pierce[name.."_proj"] = meta.projectile.pierces
                                end
                                meta.projectile.pierces = true
                                meta.projectile.piercesBlocks = true
                            elseif getgenv().old_pierce[name.."_proj"] ~= nil then
                                meta.projectile.pierces = getgenv().old_pierce[name.."_proj"]
                                meta.projectile.piercesBlocks = false
                            end
                        end
                        if meta.projectileSource then
                            makeWritable(meta.projectileSource)
                            if state then
                                if getgenv().old_pierce[name.."_src"] == nil then
                                    getgenv().old_pierce[name.."_src"] = meta.projectileSource.pierces
                                end
                                meta.projectileSource.pierces = true
                                meta.projectileSource.piercesBlocks = true
                            elseif getgenv().old_pierce[name.."_src"] ~= nil then
                                meta.projectileSource.pierces = getgenv().old_pierce[name.."_src"]
                                meta.projectileSource.piercesBlocks = false
                            end
                        end
                    end
                end
            end
        end},
        {name="Bow Rapid Fire", logic=function(state)
            local itemmeta = bw.ItemMeta
            if itemmeta then
                makeWritable(itemmeta)
                getgenv().old_rapid = getgenv().old_rapid or {}
                for name, meta in pairs(itemmeta) do
                    if type(meta) == "table" and meta.projectileSource then
                        makeWritable(meta)
                        makeWritable(meta.projectileSource)
                        if state then
                            if getgenv().old_rapid[name] == nil then
                                getgenv().old_rapid[name] = {fireDelay = meta.projectileSource.fireDelay, chargeTime = meta.projectileSource.chargeTime}
                            end
                            meta.projectileSource.fireDelay = 0.01
                            meta.projectileSource.chargeTime = 0.01
                        elseif getgenv().old_rapid[name] ~= nil then
                            meta.projectileSource.fireDelay = getgenv().old_rapid[name].fireDelay
                            meta.projectileSource.chargeTime = getgenv().old_rapid[name].chargeTime
                        end
                    end
                end
            end
        end},
        {name="Reach", hasSettings=true, settings={
            {type="toggle", name="sword reach", default=true, callback=function(v) reachSwordEnabled=v end},
            {type="slider", name="sword range", min=14, max=18, default=18, initial=18, suffix=" studs", callback=function(v)
                reachSwordRange=v
                if reachActive and reachSwordEnabled and bw.CombatConstant then
                    pcall(function()
                        makeWritable(bw.CombatConstant)
                        bw.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = v + 2
                    end)
                end
            end},
            {type="toggle", name="block reach", default=true, callback=function(v) reachBlockEnabled=v end},
            {type="slider", name="block range", min=18, max=5000, default=24, initial=24, suffix=" studs", callback=function(v) reachBlockRange=v end},
            {type="toggle", name="break reach", default=true, callback=function(v) reachBreakEnabled=v end},
            {type="slider", name="break range", min=14, max=5000, default=18, initial=18, suffix=" studs", callback=function(v) reachBreakRange=v end},
            {type="toggle", name="tp bypass (far)", default=false, callback=function(v) reachTP=v end}
        }, logic=function(state)
            reachActive = state
            if state then
                if not bw.CombatConstant then pcall(function() bw.CombatConstant = require(rep.TS.combat["combat-constant"]).CombatConstant end) end
                if bw.CombatConstant then
                    makeWritable(bw.CombatConstant)
                    getgenv().old_reach = bw.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE
                    bw.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = reachSwordEnabled and ((reachSwordRange or 18) + 2) or 14.4
                end
                if knitok and not bw.BlockSelector then pcall(function() bw.BlockSelector = require(rep.TS.ui.core["block-selector"]).BlockSelector end) end
                if bw.BlockSelector and not getgenv().old_getmouseinfo then
                    makeWritable(bw.BlockSelector)
                    getgenv().old_getmouseinfo = bw.BlockSelector.getMouseInfo
                    bw.BlockSelector.getMouseInfo = function(...)
                        local Self, Select, Args = ...
                        if not Args then Args = {} end
                        if Select == 0 then
                            Args.range = reachBlockEnabled and (reachBlockRange or 24) or 24
                        elseif Select == 1 then
                            Args.range = reachBreakEnabled and (reachBreakRange or 18) or 18
                        end
                        return getgenv().old_getmouseinfo(Self, Select, Args)
                    end
                end
                active["reach_loop"] = runservice.Heartbeat:Connect(function()
                    if not (bw and bw.Knit and bw.Knit.Controllers) then return end
                    pcall(function()
                        local bbc = bw.BlockBreak or bw.Knit.Controllers.BlockBreakController
                        if bbc and bbc.blockBreaker then
                            bbc.blockBreaker:setRange(reachBreakEnabled and (reachBreakRange or 18) or 18)
                            if not getgenv().oldReachHitBlock then
                                getgenv().oldReachHitBlock = bbc.blockBreaker.hitBlock
                                bbc.blockBreaker.hitBlock = function(self, blockData, ...)
                                    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                                    if hrp and reachTP then
                                        local blockWorldPos = blockData.blockPosition * 3
                                        local dist = (hrp.Position - blockWorldPos).Magnitude
                                        if dist > 18 then
                                            local oldCFrame = hrp.CFrame
                                            hrp.CFrame = CFrame.new(blockWorldPos + Vector3.new(0, 3, 0))
                                            task.wait(0.05)
                                            local res = getgenv().oldReachHitBlock(self, blockData, ...)
                                            task.wait(0.05)
                                            hrp.CFrame = oldCFrame
                                            return res
                                        end
                                    end
                                    return getgenv().oldReachHitBlock(self, blockData, ...)
                                end
                            end
                        end
                    end)
                    pcall(function()
                        local bpc = bw.Knit.Controllers.BlockPlacementController
                        if bpc and bpc.blockPlacer then
                            bpc.blockPlacer.range = reachBlockEnabled and (reachBlockRange or 24) or 24
                            if not getgenv().oldReachPlaceBlock then
                                getgenv().oldReachPlaceBlock = bpc.blockPlacer.placeBlock
                                bpc.blockPlacer.placeBlock = function(self, blockPosition, ...)
                                    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                                    if hrp and reachTP then
                                        local blockWorldPos = blockPosition * 3
                                        local dist = (hrp.Position - blockWorldPos).Magnitude
                                        if dist > 18 then
                                            local oldCFrame = hrp.CFrame
                                            hrp.CFrame = CFrame.new(blockWorldPos + Vector3.new(0, 3, 0))
                                            task.wait(0.05)
                                            local res = getgenv().oldReachPlaceBlock(self, blockPosition, ...)
                                            task.wait(0.05)
                                            hrp.CFrame = oldCFrame
                                            return res
                                        end
                                    end
                                    return getgenv().oldReachPlaceBlock(self, blockPosition, ...)
                                end
                            end
                        end
                    end)
                end)
            else
                if active["reach_loop"] then active["reach_loop"]:Disconnect(); active["reach_loop"] = nil end
                if bw.CombatConstant and getgenv().old_reach then
                    makeWritable(bw.CombatConstant)
                    bw.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = getgenv().old_reach
                end
                if bw.BlockSelector and getgenv().old_getmouseinfo then
                    makeWritable(bw.BlockSelector)
                    bw.BlockSelector.getMouseInfo = getgenv().old_getmouseinfo
                    getgenv().old_getmouseinfo = nil
                end
            end
        end},
        {name="Auto Clicker", hasSettings=true, settings={
            {type="slider", name="cps", min=5, max=30, default=12, initial=12, suffix="", callback=function(v) acCPS=v end}
        }, logic=function(state)
            if state then
                local last=tick(); local nextclick = 0
                active["ac"]=runservice.RenderStepped:Connect(function()
                    if knitok and bw.Sword and uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                        if tick()-last>=nextclick then
                            pcall(function() bw.Sword:swingSwordAtMouse() end)
                            nextclick = (1 / (acCPS or 12)) + (math.random(-15, 15) / 1000)
                            last=tick()
                        end
                    end
                end)
            elseif active["ac"] then active["ac"]:Disconnect(); active["ac"]=nil end
        end},
        {name="No Click Delay", logic=function(state)
            if state then
                if knitok and bw.Sword then
                    getgenv().old_noclick = bw.Sword.isClickingTooFast
                    bw.Sword.isClickingTooFast = function() return false end
                end
            else
                if getgenv().old_noclick and bw.Sword then bw.Sword.isClickingTooFast = getgenv().old_noclick end
            end
        end},
        {name="No Slowdown", logic=function(state)
            if state then
                active["noslow"] = runservice.Heartbeat:Connect(function()
                    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                        if plr.Character.Humanoid.WalkSpeed < 20 and plr.Character.Humanoid.WalkSpeed > 0 then
                            plr.Character.Humanoid.WalkSpeed = 20
                        end
                    end
                end)
                if knitok and bw.Spring then
                    getgenv().old_sprint = bw.Spring.stopSprinting
                    bw.Spring.stopSprinting = function(...) return end
                end
            else
                if getgenv().old_sprint and bw.Spring then bw.Spring.stopSprinting=getgenv().old_sprint end
                if active["noslow"] then active["noslow"]:Disconnect(); active["noslow"] = nil end
            end
        end},
        {name="Hit Boxes", hasSettings=true, settings={
            {type="slider", name="expand", min=1, max=15, default=4, initial=4, suffix=" studs", callback=function(v)
                hbExpand = v
                if hbActive and knitok and bw.Sword and bw.Sword.swingSwordInRegion then
                    pcall(function() debug.setconstant(bw.Sword.swingSwordInRegion, 6, v / 3) end)
                end
            end}
        }, logic=function(state)
            hbActive = state
            if state then
                if knitok and bw.Sword and bw.Sword.swingSwordInRegion then
                    pcall(function() debug.setconstant(bw.Sword.swingSwordInRegion, 6, (hbExpand or 4) / 3) end)
                end
            else
                if knitok and bw.Sword and bw.Sword.swingSwordInRegion then
                    pcall(function() debug.setconstant(bw.Sword.swingSwordInRegion, 6, 3.8) end)
                end
            end
        end}
    }},
    {"movement", {
        {name="sprint", logic=function(state)
            if state then
                active["sp"]=runservice.RenderStepped:Connect(function()
                    if knitok and bw.Spring then pcall(function() bw.Spring:startSprinting() end) end
                end)
            elseif active["sp"] then active["sp"]:Disconnect(); active["sp"]=nil end
        end},
        {name="keep sprint", logic=function(state)
            if state then
                active["ks"]=runservice.RenderStepped:Connect(function()
                    if knitok and bw.Spring then pcall(function() bw.Spring:startSprinting() end) end
                end)
            elseif active["ks"] then active["ks"]:Disconnect(); active["ks"]=nil end
        end},
        {name="speed", hasSettings=true, settings={
            {type="slider", name="speed", min=10, max=100, default=28, initial=28, suffix="", callback=function(v) sV=v end}
        }, logic=function(state)
            if state then
                active["sd"]=runservice.Heartbeat:Connect(function(dt)
                    if plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.MoveDirection.Magnitude>0 then
                        plr.Character:TranslateBy(plr.Character.Humanoid.MoveDirection*(sV*dt))
                    end
                end)
            elseif active["sd"] then active["sd"]:Disconnect(); active["sd"]=nil end
        end},
        {name="jump power", hasSettings=true, settings={
            {type="slider", name="height", min=50, max=150, default=80, suffix="", callback=function() end}
        }, logic=function(state)
            if state then
                active["jp"]=runservice.Heartbeat:Connect(function()
                    if plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid:GetState()==Enum.HumanoidStateType.Jumping then
                        plr.Character.Humanoid.JumpPower=80
                     end
                end)
            elseif active["jp"] then
                active["jp"]:Disconnect(); active["jp"]=nil
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then plr.Character.Humanoid.JumpPower=50 end
            end
        end},
        {name="highjump", hasSettings=true, settings={
            {type="slider", name="height", min=20, max=250, default=100, initial=100, suffix=" studs", callback=function(v) hjHeight=v end}
        }, logic=function(state)
            if state then
                active["hj"]=uis.InputBegan:Connect(function(inp, gpe)
                    if not gpe and inp.KeyCode == Enum.KeyCode.Space then
                        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                            local hrp = plr.Character.HumanoidRootPart
                            hrp.Velocity = Vector3.new(hrp.Velocity.X, hjHeight, hrp.Velocity.Z)
                        end
                    end
                end)
            elseif active["hj"] then active["hj"]:Disconnect(); active["hj"]=nil end
        end},
        {name="flight", hasSettings=true, settings={
            {type="slider", name="speed", min=1, max=5, default=2, initial=2, suffix=" studs", callback=function(v) flySpd=v end}
        }, logic=function(state)
            if state then
                local bodypos = Instance.new("BodyPosition")
                bodypos.MaxForce = Vector3.new(40000, 40000, 40000); bodypos.P = 2000
                local spoofBlock = workspace:FindFirstChild("jdk_fly_spoof") or Instance.new("Part")
                spoofBlock.Name = "jdk_fly_spoof"
                spoofBlock.Size = Vector3.new(5, 1, 5)
                spoofBlock.Transparency = 1
                spoofBlock.CanCollide = false
                spoofBlock.Anchored = true
                spoofBlock.Parent = workspace
                active["fl"]=runservice.Heartbeat:Connect(function(dt)
                    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp=plr.Character.HumanoidRootPart
                        local hum=plr.Character:FindFirstChild("Humanoid")
                        if hum then hum.PlatformStand=true; hum.AutoRotate=false end
                        spoofBlock.CFrame = hrp.CFrame - Vector3.new(0, 3.2, 0)
                        local mv=Vector3.new()
                        if uis:IsKeyDown(Enum.KeyCode.W) then mv=mv+cam.CFrame.LookVector end
                        if uis:IsKeyDown(Enum.KeyCode.S) then mv=mv-cam.CFrame.LookVector end
                        if uis:IsKeyDown(Enum.KeyCode.A) then mv=mv-cam.CFrame.RightVector end
                        if uis:IsKeyDown(Enum.KeyCode.D) then mv=mv+cam.CFrame.RightVector end
                        if uis:IsKeyDown(Enum.KeyCode.Space) then mv=mv+Vector3.new(0,1,0) end
                        if uis:IsKeyDown(Enum.KeyCode.LeftShift) then mv=mv+Vector3.new(0,-1,0) end
                        local targetSpd = flySpd or 2
                        if mv.Magnitude>0 then mv=mv.Unit*(targetSpd*dt/0.016) end
                        hrp.CFrame=hrp.CFrame+mv
                        bodypos.Position = hrp.Position
                        bodypos.Parent = hrp
                    end
                end)
            else
                if active["fl"] then active["fl"]:Disconnect(); active["fl"]=nil end
                if workspace:FindFirstChild("jdk_fly_spoof") then workspace.jdk_fly_spoof:Destroy() end
                if plr.Character then
                    if plr.Character:FindFirstChild("Humanoid") then
                        plr.Character.Humanoid.PlatformStand=false; plr.Character.Humanoid.AutoRotate=true
                    end
                    if plr.Character:FindFirstChild("HumanoidRootPart") then
                        for _, v in ipairs(plr.Character.HumanoidRootPart:GetChildren()) do
                            if v:IsA("BodyPosition") or v:IsA("BodyVelocity") then v:Destroy() end
                        end
                    end
                end
            end
        end},
        {name="spider", hasSettings=true, settings={
            {type="slider", name="speed", min=10, max=100, default=30, initial=30, suffix="", callback=function(v) spiderSpd=v end}
        }, logic=function(state)
            if state then
                active["spider"]=runservice.Heartbeat:Connect(function()
                    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then
                        local hrp = plr.Character.HumanoidRootPart
                        local hum = plr.Character.Humanoid
                        if hum.MoveDirection.Magnitude > 0 then
                            local raycastparams = RaycastParams.new()
                            raycastparams.FilterDescendantsInstances = {plr.Character}
                            raycastparams.FilterType = Enum.RaycastFilterType.Exclude
                            local ray = workspace:Raycast(hrp.Position, hum.MoveDirection * 2.5, raycastparams)
                            if ray then hrp.Velocity = Vector3.new(hrp.Velocity.X, spiderSpd, hrp.Velocity.Z) end
                        end
                    end
                end)
            elseif active["spider"] then active["spider"]:Disconnect(); active["spider"]=nil end
        end},
        {name="no slowdown", logic=function(state)
            if state then
                if knitok and bw.Spring then
                    local sprint = bw.Spring
                    if sprint and sprint.getMovementStatusModifier then
                        getgenv().old_noslow = sprint:getMovementStatusModifier().addModifier
                        sprint:getMovementStatusModifier().addModifier = function(self, modifierdata)
                            if modifierdata and modifierdata.moveSpeedMultiplier then
                                modifierdata.moveSpeedMultiplier = math.max(modifierdata.moveSpeedMultiplier, 1.0)
                            end
                            return getgenv().old_noslow(self, modifierdata)
                        end
                    end
                end
            else
                if getgenv().old_noslow and bw.Spring then
                    local sprint = bw.Spring
                    if sprint and sprint.getMovementStatusModifier then
                        pcall(function() sprint:getMovementStatusModifier().addModifier = getgenv().old_noslow end)
                    end
                end
            end
        end},
        {name="anti void", logic=function(state)
            if state then
                active["av"]=runservice.Heartbeat:Connect(function()
                    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp=plr.Character.HumanoidRootPart
                        if hrp.Position.Y < -5 then hrp.CFrame = CFrame.new(hrp.Position.X, 30, hrp.Position.Z) end
                    end
                end)
            elseif active["av"] then active["av"]:Disconnect(); active["av"]=nil end
        end},
        {name="scaffold", hasSettings=true, settings={
            {type="slider", name="delay", min=0.01, max=1.0, default=0.03, initial=0.03, suffix="s", callback=function(v) scafDelay=v end},
            {type="slider", name="expand", min=1, max=6, default=1, initial=1, suffix=" blocks", callback=function(v) scafExpand=v end},
            {type="toggle", name="tower", default=true, callback=function(v) scafJump=v end},
            {type="toggle", name="lock rotation", default=false, callback=function(v) scafLock=v end},
            {type="toggle", name="downwards", default=true, callback=function(v) scafDown=v end},
            {type="toggle", name="diagonal", default=true, callback=function(v) scafDiag=v end},
            {type="toggle", name="hand block only", default=false, callback=function(v) scafHandBlock=v end}
        }, logic=function(state)
            local adjacent = {}
            for x = -3, 3, 3 do
                for y = -3, 3, 3 do
                    for z = -3, 3, 3 do
                        local vec = Vector3.new(x, y, z)
                        if vec ~= Vector3.zero then
                            table.insert(adjacent, vec)
                        end
                    end
                end
            end
            local lastpos = Vector3.zero
            local function getPlacedBlock(pos)
                if not pos then return nil, nil end
                local roundedPosition = bw.getBlockPosition(pos)
                return bw.getBlockAt(roundedPosition), roundedPosition
            end
            local function getBlocksInPoints(s, e)
                local list = {}
                if bw.BlockController and bw.BlockController:getStore() then
                    local success = pcall(function()
                        local store = bw.BlockController:getStore()
                        for x = s.X, e.X do
                            for y = s.Y, e.Y do
                                for z = s.Z, e.Z do
                                    local vec = Vector3.new(x, y, z)
                                    if store:getBlockAt(vec) then
                                        table.insert(list, vec * 3)
                                    end
                                end
                            end
                        end
                    end)
                    if success and #list > 0 then return list end
                end
                local center = (s + e) * 1.5
                local size = (e - s) * 3 + Vector3.new(3, 3, 3)
                local parts = workspace:GetPartBoundsInBox(CFrame.new(center), size)
                for _, p in ipairs(parts) do
                    if p:IsA("BasePart") and not p:IsDescendantOf(plr.Character) and p.CanCollide and p.Size.X >= 2.5 then
                        local gridPos = Vector3.new(math.round(p.Position.X/3), math.round(p.Position.Y/3), math.round(p.Position.Z/3))
                        table.insert(list, gridPos * 3)
                    end
                end
                return list
            end
            local function nearCorner(poscheck, pos)
                local startpos = poscheck - Vector3.new(3, 3, 3)
                local endpos = poscheck + Vector3.new(3, 3, 3)
                local check = poscheck + (pos - poscheck).Unit * 100
                return Vector3.new(math.clamp(check.X, startpos.X, endpos.X), math.clamp(check.Y, startpos.Y, endpos.Y), math.clamp(check.Z, startpos.Z, endpos.Z))
            end
            local function blockProximity(pos)
                local mag, returned = 60, nil
                local tab = getBlocksInPoints(bw.getBlockPosition(pos - Vector3.new(21, 21, 21)), bw.getBlockPosition(pos + Vector3.new(21, 21, 21)))
                for _, v in tab do
                    local blockpos = nearCorner(v, pos)
                    local newmag = (pos - blockpos).Magnitude
                    if newmag < mag then
                        mag, returned = newmag, blockpos
                    end
                end
                table.clear(tab)
                return returned
            end
            local function checkAdjacent(pos)
                for _, v in adjacent do
                    if getPlacedBlock(pos + v) then
                        return true
                    end
                end
                return false
            end
            local function getScaffoldBlock()
                local blockname, amount = nil, 0
                if scafHandBlock then
                    pcall(function()
                        local myChar = plr.Character
                        if not myChar then return end
                        local handCheck = myChar:FindFirstChild("HandInvItem")
                        if handCheck and handCheck.Value then
                            local itemType = handCheck.Value.Name
                            if bw.ItemMeta and bw.ItemMeta[itemType] and bw.ItemMeta[itemType].block then
                                blockname = itemType
                                amount = 999
                            end
                        end
                    end)
                    return blockname, amount
                end
                pcall(function()
                    local inventoryutil = require(rep.TS.inventory["inventory-util"]).InventoryUtil
                    local inv = inventoryutil.getInventory(plr)
                    if inv and inv.items then
                        for _, item in inv.items do
                            local name = item.itemType
                            if string.find(string.lower(name), "wool") then
                                blockname = name
                                amount = item.amount or 0
                                return
                            end
                        end
                        if not blockname then
                            for _, item in inv.items do
                                if bw.ItemMeta and bw.ItemMeta[item.itemType] and bw.ItemMeta[item.itemType].block then
                                    blockname = item.itemType
                                    amount = item.amount or 0
                                    return
                                end
                            end
                        end
                    end
                end)
                return blockname, amount
            end
            local function roundPos(vec)
                return Vector3.new(math.round(vec.X / 3) * 3, math.round(vec.Y / 3) * 3, math.round(vec.Z / 3) * 3)
            end
            if state then
                active["scaffold"] = true
                task.spawn(function()
                    repeat
                        pcall(function()
                            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then
                                local hrp = plr.Character.HumanoidRootPart
                                local hum = plr.Character.Humanoid
                                local wool, amount = getScaffoldBlock()
                                if wool then
                                    if scafJump and uis:IsKeyDown(Enum.KeyCode.Space) and (not uis:GetFocusedTextBox()) then
                                        hrp.Velocity = Vector3.new(hrp.Velocity.X, 38, hrp.Velocity.Z)
                                    end
                                    if scafLock and hum.MoveDirection.Magnitude > 0 then
                                        hum.AutoRotate = false
                                        local movedir = hum.MoveDirection
                                        local targetlook = Vector3.new(-movedir.X, 0, -movedir.Z).Unit
                                        if targetlook.Magnitude > 0 then
                                            local smoothlook = hrp.CFrame.LookVector:Lerp(targetlook, 0.25)
                                            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(smoothlook.X, 0, smoothlook.Z).Unit)
                                        end
                                    else
                                        hum.AutoRotate = true
                                    end
                                    local hipheight = hum.HipHeight + (hrp.Size.Y / 2)
                                    local downwardsoffset = (scafDown and uis:IsKeyDown(Enum.KeyCode.LeftShift) and not uis:GetFocusedTextBox()) and 4.5 or 1.5
                                    for i = (scafExpand or 1) - 1, 0, -1 do
                                        local currentpos = roundPos(hrp.Position - Vector3.new(0, hipheight + downwardsoffset, 0) + hum.MoveDirection * (i * 3))
                                        if scafDiag then
                                            if math.abs(math.round(math.deg(math.atan2(-hum.MoveDirection.X, -hum.MoveDirection.Z)) / 45) * 45) % 90 == 45 then
                                                local dt = (lastpos - currentpos)
                                                if ((dt.X == 0 and dt.Z ~= 0) or (dt.X ~= 0 and dt.Z == 0)) and ((lastpos - hrp.Position) * Vector3.new(1, 0, 1)).Magnitude < 2.5 then
                                                    currentpos = lastpos
                                                end
                                            end
                                        end
                                        local block, blockpos = getPlacedBlock(currentpos)
                                        if not block then
                                            blockpos = checkAdjacent(blockpos * 3) and blockpos * 3 or blockProximity(currentpos)
                                            if blockpos then
                                                task.spawn(bw.placeBlock, blockpos, wool)
                                            end
                                        end
                                        lastpos = currentpos
                                    end
                                end
                            end
                        end)
                        task.wait(scafDelay or 0.03)
                    until not active["scaffold"]
                end)
            elseif active["scaffold"] then
                active["scaffold"] = nil
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then plr.Character.Humanoid.AutoRotate = true end
            end
        end}
    }},
    {"player", {
        {name="no fall", logic=function(state)
            if state then
                local spoofBlock = workspace:FindFirstChild("jdk_nofall_spoof") or Instance.new("Part")
                spoofBlock.Name = "jdk_nofall_spoof"
                spoofBlock.Size = Vector3.new(5, 1, 5)
                spoofBlock.Transparency = 1
                spoofBlock.CanCollide = false
                spoofBlock.Anchored = true
                spoofBlock.Parent = workspace
                active["nofall"] = runservice.Heartbeat:Connect(function()
                    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        spoofBlock.CFrame = plr.Character.HumanoidRootPart.CFrame - Vector3.new(0, 3.2, 0)
                    end
                end)
            else
                if active["nofall"] then active["nofall"]:Disconnect(); active["nofall"] = nil end
                local b = workspace:FindFirstChild("jdk_nofall_spoof")
                if b then b:Destroy() end
            end
        end},
        {name="Velocity", hasSettings=true, settings={
            {type="slider", name="horizontal", min=0, max=100, default=0, initial=0, suffix="%", callback=function(v) velH=v end},
            {type="slider", name="vertical", min=0, max=100, default=0, initial=0, suffix="%", callback=function(v) velV=v end}
        }, logic=function(state)
            if state then
                if knitok and bw.KB then
                    getgenv().old_kb = bw.KB.applyKnockback
                    bw.KB.applyKnockback = function(root, mass, dir, knockback, ...)
                        knockback = knockback or {}
                        knockback.horizontal = (knockback.horizontal or 1) * ((velH or 0) / 100)
                        knockback.vertical = (knockback.vertical or 1) * ((velV or 0) / 100)
                        return getgenv().old_kb(root, mass, dir, knockback, ...)
                    end
                end
            else
                if getgenv().old_kb and bw.KB then bw.KB.applyKnockback=getgenv().old_kb end
            end
        end},
        {name="cannon assister", logic=function(state)
        end},
        {name="cannon aimbot", logic=function(state)
            if state then
                active["cannon_waypoint_bind"] = uis.InputBegan:Connect(function(inp, gpe)
                    if not gpe and inp.KeyCode == Enum.KeyCode.V then
                        if uis:IsKeyDown(Enum.KeyCode.LeftAlt) or uis:IsKeyDown(Enum.KeyCode.RightAlt) then
                            pcall(function()
                                local mouse = plr:GetMouse()
                                if mouse and mouse.Hit then
                                    getgenv().cannonWaypointPos = mouse.Hit.Position
                                    getgenv().createWaypointVisual(getgenv().cannonWaypointPos)
                                    getgenv().cannonNotify("Waypoint Set at Target!")
                                    local hum = plr.Character and plr.Character:FindFirstChild("Humanoid")
                                    local seat = hum and hum.SeatPart
                                    local cannon = getgenv().getCannonFromSeat(seat)
                                    if cannon then
                                        getgenv().aimCannonAtWaypoint(cannon)
                                    end
                                end
                            end)
                        end
                    end
                end)
            else
                if active["cannon_waypoint_bind"] then active["cannon_waypoint_bind"]:Disconnect(); active["cannon_waypoint_bind"]=nil end
                if getgenv().cannonWaypointVisual then
                    getgenv().cannonWaypointVisual:Destroy()
                    getgenv().cannonWaypointVisual = nil
                end
                getgenv().cannonWaypointPos = nil
                table.clear(getgenv().aimedCannons)
            end
        end},
        {name="anti fall", logic=function(state)
            if state then
                active["af"]=runservice.Heartbeat:Connect(function()
                    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                        local hum=plr.Character.Humanoid
                        if hum.Velocity and hum.Velocity.Y < -50 then
                            hum:ChangeState(Enum.HumanoidStateType.Seated)
                            task.wait(0.03)
                            hum:ChangeState(Enum.HumanoidStateType.Running)
                        end
                    end
                end)
            elseif active["af"] then active["af"]:Disconnect(); active["af"]=nil end
        end},
        {name="anti blind", logic=function(state)
            if state then
                active["abli"]=runservice.Heartbeat:Connect(function()
                    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                        local hum=plr.Character.Humanoid
                        if hum.WalkSpeed < 14 then hum.WalkSpeed = 14 end
                    end
                end)
            elseif active["abli"] then active["abli"]:Disconnect(); active["abli"]=nil end
        end},
        {name="fast break", hasSettings=true, settings={
            {type="slider", name="speed multiplier", min=1, max=5, default=2, initial=2, callback=function(v) getgenv().jdk.fastBreakMultiplier = v end},
            {type="slider", name="cooldown", min=0, max=100, default=0, initial=0, suffix="%", callback=function(v) getgenv().jdk.fastBreakCooldown = v end}
        }, logic=function(state)
            if state then
                if knitok and bw.BlockBreak and bw.BlockBreak.blockBreaker then
                    if not getgenv().oldHitBlock then
                        getgenv().oldHitBlock = bw.BlockBreak.blockBreaker.hitBlock
                    end
                    bw.BlockBreak.blockBreaker.hitBlock = function(self, blockData, ...)
                        pcall(function()
                            if bw.BlockBreak.blockBreaker.setCooldown then
                                local defaultCooldown = 0.3
                                local targetCooldown = defaultCooldown * (1 - (getgenv().jdk.fastBreakCooldown or 0)/100)
                                bw.BlockBreak.blockBreaker:setCooldown(targetCooldown)
                            end
                        end)
                        local res
                        local mult = getgenv().jdk.fastBreakMultiplier or 2
                        for i = 1, mult do
                            res = getgenv().oldHitBlock(self, blockData, ...)
                        end
                        return res
                    end
                end
                active["fb"] = runservice.Heartbeat:Connect(function()
                    if knitok and bw.BlockBreak and bw.BlockBreak.blockBreaker then
                        pcall(function()
                            if bw.BlockBreak.blockBreaker.setCooldown then
                                local defaultCooldown = 0.3
                                local targetCooldown = defaultCooldown * (1 - (getgenv().jdk.fastBreakCooldown or 0)/100)
                                bw.BlockBreak.blockBreaker:setCooldown(targetCooldown)
                            end
                        end)
                    end
                end)
            elseif active["fb"] then
                active["fb"]:Disconnect(); active["fb"] = nil
                if getgenv().oldHitBlock and knitok and bw.BlockBreak and bw.BlockBreak.blockBreaker then
                    bw.BlockBreak.blockBreaker.hitBlock = getgenv().oldHitBlock
                end
                if knitok and bw.BlockBreak and bw.BlockBreak.blockBreaker then
                    pcall(function()
                        if bw.BlockBreak.blockBreaker.setCooldown then
                            bw.BlockBreak.blockBreaker:setCooldown(0.3)
                        end
                    end)
                end
            end
        end},
        {name="auto balloon", logic=function(state)
            if state then
                active["aballoon"]=runservice.Heartbeat:Connect(function()
                    if knitok and bw.Balloon and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = plr.Character.HumanoidRootPart
                        if hrp.Position.Y < -20 then pcall(function() bw.Balloon:inflateBalloon() end) end
                    end
                end)
            elseif active["aballoon"] then active["aballoon"]:Disconnect(); active["aballoon"]=nil end
        end},
        {name="chest stealer", logic=function(state)
            stealerOn = state
            if state then
                local setObserved = findRemote("Inventory/SetObservedChest")
                local chestGetItem = findRemote("Inventory/ChestGetItem")
                active["stealer"]=task.spawn(function()
                    while stealerOn do
                        task.wait(0.2)
                        pcall(function()
                            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                                local hrp = plr.Character.HumanoidRootPart
                                for _, chest in ipairs(game:GetService("CollectionService"):GetTagged("chest")) do
                                    if (chest.Position - hrp.Position).Magnitude < 15 then
                                        local chestfolder = chest:FindFirstChild("ChestFolderValue")
                                        if chestfolder and chestfolder.Value then
                                            local chestitems = chestfolder.Value:GetChildren()
                                            if #chestitems > 0 then
                                                if setObserved then
                                                    if setObserved:IsA("RemoteEvent") then
                                                        setObserved:FireServer(chestfolder.Value)
                                                    else
                                                        setObserved:InvokeServer(chestfolder.Value)
                                                    end
                                                end
                                                for _, item in ipairs(chestitems) do
                                                    if not stealerOn then break end
                                                    if chestGetItem then
                                                        if chestGetItem:IsA("RemoteEvent") then
                                                            chestGetItem:FireServer(chestfolder.Value, item)
                                                        else
                                                            chestGetItem:InvokeServer(chestfolder.Value, item)
                                                        end
                                                    end
                                                    task.wait(0.05)
                                                end
                                                if setObserved then
                                                    if setObserved:IsA("RemoteEvent") then
                                                        setObserved:FireServer(nil)
                                                    else
                                                        setObserved:InvokeServer(nil)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end)
            else stealerOn = false end
        end},
        {name="bed nuker", logic=function(state)
            if state then
                active["bn"]=task.spawn(function()
                    while moduleStates["bed nuker"] do
                        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                            local hrp = plr.Character.HumanoidRootPart
                            for _, v in ipairs(game:GetService("CollectionService"):GetTagged("bed")) do
                                if (v.Position - hrp.Position).Magnitude < 14 then
                                    local isOwnTeam = false
                                    if plr.Team and v:GetAttribute("Team" .. tostring(plr.Team.Name) .. "NoBreak") then
                                        isOwnTeam = true
                                    end
                                    if plr:GetAttribute("Team") and v:GetAttribute("Team" .. tostring(plr:GetAttribute("Team")) .. "NoBreak") then
                                        isOwnTeam = true
                                    end
                                    if not isOwnTeam then
                                        local pos = bw.getBlockPosition(v.Position)
                                        local targetBlock = nil
                                        local offsets = {
                                            Vector3.new(0, 1, 0),
                                            Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0),
                                            Vector3.new(0, 0, 1), Vector3.new(0, 0, -1),
                                            Vector3.new(0, 0, 0)
                                        }
                                        for _, offset in ipairs(offsets) do
                                            local checkPos = pos + offset
                                            local b = bw.getBlockAt(checkPos)
                                            if b then
                                                targetBlock = checkPos
                                                break
                                            end
                                        end
                                        if targetBlock then
                                            pcall(function()
                                                local bdata = bw.getBlockAt(targetBlock)
                                                local dataToSend = bdata or {blockPosition = targetBlock}
                                                local hits = 1
                                                if moduleStates["fast break"] then
                                                    hits = getgenv().jdk.fastBreakMultiplier or 2
                                                end
                                                local bbc = bw.BlockBreak or (bw.Knit and bw.Knit.Controllers and bw.Knit.Controllers.BlockBreakController)
                                                for i = 1, hits do
                                                    if bbc and bbc.blockBreaker then
                                                        bbc.blockBreaker:hitBlock(dataToSend)
                                                    end
                                                end
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                        task.wait(0.1)
                    end
                end)
            else moduleStates["bed nuker"]=false end
        end},
        {name="bed prot", hasSettings=true, settings={
            {type="slider", name="radius", min=1, max=4, default=2, initial=2, suffix=" blks", callback=function(v) bedProtRadius = v end}
        }, logic=function(state)
            if state then
                active["bprot"]=task.spawn(function()
                    while moduleStates["bed prot"] do
                        if knitok and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                            local hrp = plr.Character.HumanoidRootPart
                            local myBed = nil
                            for _, v in ipairs(game:GetService("CollectionService"):GetTagged("bed")) do
                                local isOwnTeam = false
                                if plr.Team and v:GetAttribute("Team" .. tostring(plr.Team.Name) .. "NoBreak") then isOwnTeam = true end
                                if plr:GetAttribute("Team") and v:GetAttribute("Team" .. tostring(plr:GetAttribute("Team")) .. "NoBreak") then isOwnTeam = true end
                                if isOwnTeam then myBed = v; break end
                            end
                            if myBed and (hrp.Position - myBed.Position).Magnitude < 30 then
                                local bestBlock = nil
                                pcall(function()
                                    local inv = require(rep.TS.inventory["inventory-util"]).InventoryUtil.getInventory(plr)
                                    local bestScore = 0
                                    local scores = {obsidian=10, ceramic=9, end_stone=8, stone_brick=7, wood_plank=6, wood=6, wool=5}
                                    if inv and inv.items then
                                        for _, item in ipairs(inv.items) do
                                            local n = string.lower(item.itemType)
                                            for bName, score in pairs(scores) do
                                                if string.find(n, bName) and score > bestScore then
                                                    bestScore = score
                                                    bestBlock = item.itemType
                                                end
                                            end
                                        end
                                    end
                                end)
                                if bestBlock then
                                    local bedPos = bw.getBlockPosition(myBed.Position)
                                    local blocksPlaced = 0
                                    local r = bedProtRadius or 2
                                    for x = -r, r do
                                        for y = -1, r do
                                            for z = -r, r do
                                                local pos = bedPos + Vector3.new(x, y, z)
                                                local worldPos = pos * 3
                                                local dist = (worldPos - myBed.Position).Magnitude
                                                if dist > 3.5 and dist < (r * 4.5 + 2) then
                                                    local b = bw.getBlockAt(pos)
                                                    if not b then
                                                        pcall(function() bw.placeBlock(worldPos, bestBlock) end)
                                                        blocksPlaced = blocksPlaced + 1
                                                        task.wait(0.01)
                                                    end
                                                end
                                                if blocksPlaced > 25 then break end
                                            end
                                            if blocksPlaced > 25 then break end
                                        end
                                        if blocksPlaced > 25 then break end
                                    end
                                end
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            else moduleStates["bed prot"]=false end
        end},
        {name="block in", hasSettings=true, settings={
            {type="textbox", name="hold key", default="v", callback=function(v) getgenv().jdk.blockInKey = getgenv().jdk.getKeyCodeFromString(v) end},
            {type="slider", name="bed range", min=5, max=50, default=25, initial=25, suffix=" studs", callback=function(v) getgenv().jdk.blockInBedRange = v end},
            {type="toggle", name="only enemy beds", default=false, callback=function(v) getgenv().jdk.blockInOnlyEnemy = v end}
        }, logic=function(state)
            if state then
                local offsets = {
                    Vector3.new(0, -2, 0),
                    Vector3.new(1, -1, 0), Vector3.new(-1, -1, 0), Vector3.new(0, -1, 1), Vector3.new(0, -1, -1),
                    Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0), Vector3.new(0, 0, 1), Vector3.new(0, 0, -1),
                    Vector3.new(0, 1, 0)
                }
                local lastBlockIn = 0
                local function getWoolBlock()
                    local blockname = nil
                    pcall(function()
                        local inventoryutil = require(rep.TS.inventory["inventory-util"]).InventoryUtil
                        local inv = inventoryutil.getInventory(plr)
                        if inv and inv.items then
                            for _, item in inv.items do
                                local name = item.itemType
                                if string.find(string.lower(name), "wool") then
                                    blockname = name
                                    break
                                end
                            end
                            if not blockname then
                                for _, item in inv.items do
                                    if bw.ItemMeta and bw.ItemMeta[item.itemType] and bw.ItemMeta[item.itemType].block then
                                        blockname = item.itemType
                                        break
                                    end
                                end
                            end
                        end
                    end)
                    return blockname
                end
                local function isNearBed(maxDist)
                    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return false end
                    local myPos = plr.Character.HumanoidRootPart.Position
                    for _, v in ipairs(game:GetService("CollectionService"):GetTagged("bed")) do
                        if (v.Position - myPos).Magnitude <= maxDist then
                            if getgenv().jdk.blockInOnlyEnemy then
                                local isOwn = false
                                if plr.Team and v:GetAttribute("Team" .. tostring(plr.Team.Name) .. "NoBreak") then isOwn = true end
                                if plr:GetAttribute("Team") and v:GetAttribute("Team" .. tostring(plr:GetAttribute("Team")) .. "NoBreak") then isOwn = true end
                                if not isOwn then return true end
                            else
                                return true
                            end
                        end
                    end
                    return false
                end
                active["blockin"] = task.spawn(function()
                    while state do
                        local holdKey = getgenv().jdk.blockInKey or Enum.KeyCode.V
                        if uis:IsKeyDown(holdKey) and not uis:GetFocusedTextBox() then
                            if tick() - lastBlockIn > 0.3 then
                                if isNearBed(getgenv().jdk.blockInBedRange or 25) then
                                    local wool = getWoolBlock()
                                    if wool and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                                        local centerGrid = bw.getBlockPosition(plr.Character.HumanoidRootPart.Position)
                                        for _, offset in ipairs(offsets) do
                                            local gridPos = centerGrid + offset
                                            local block = bw.getBlockAt(gridPos)
                                            if not block then
                                                pcall(function() bw.placeBlock(gridPos * 3, wool) end)
                                                task.wait(0.01)
                                            end
                                        end
                                        lastBlockIn = tick()
                                    end
                                end
                            end
                        end
                        task.wait(0.05)
                    end
                end)
            else
                if active["blockin"] then
                    pcall(task.cancel, active["blockin"])
                    active["blockin"] = nil
                end
            end
        end},
        {name="desync", hasSettings=true, settings={
            {type="slider", name="range", min=5, max=50, default=15, initial=15, suffix=" studs", callback=function(v) getgenv().jdk.desyncRange = v end}
        }, logic=function(state)
            if state then
                active["desync"] = runservice.Heartbeat:Connect(function()
                    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = plr.Character.HumanoidRootPart
                        local oldCF = hrp.CFrame
                        local rng = getgenv().jdk.desyncRange or 15
                        hrp.CFrame = hrp.CFrame * CFrame.new(math.random(-rng, rng), 0, math.random(-rng, rng))
                        task.defer(function()
                            if hrp and hrp.Parent then
                                hrp.CFrame = oldCF
                            end
                        end)
                    end
                end)
            elseif active["desync"] then
                active["desync"]:Disconnect(); active["desync"] = nil
            end
        end},
        {name="anti hit", hasSettings=true, settings={
            {type="slider", name="dodge distance", min=5, max=20, default=12, initial=12, suffix=" studs", callback=function(v) getgenv().jdk.antiHitDistance = v end},
            {type="slider", name="dodge height", min=5, max=30, default=12, initial=12, suffix=" studs", callback=function(v) getgenv().jdk.antiHitHeight = v end},
            {type="slider", name="dodge duration", min=0.1, max=1.0, default=0.2, initial=0.2, suffix="s", callback=function(v) getgenv().jdk.antiHitTime = v end}
        }, logic=function(state)
            if state then
                local isDodging = false
                active["antihit"] = runservice.Heartbeat:Connect(function()
                    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = plr.Character.HumanoidRootPart
                        if isDodging then return end
                        for _, enemy in ipairs(players:GetPlayers()) do
                            if enemy ~= plr and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
                                local eh = enemy.Character:FindFirstChild("Humanoid")
                                if eh then
                                    local isSwinging = false
                                    for _, track in ipairs(eh:GetPlayingAnimationTracks()) do
                                        local animName = string.lower(track.Animation.AnimationId)
                                        if animName:find("sword") or animName:find("swing") or animName:find("attack") then
                                            isSwinging = true
                                            break
                                        end
                                    end
                                    if isSwinging then
                                        local dist = (enemy.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                                        if dist < (getgenv().jdk.antiHitDistance or 12) then
                                            isDodging = true
                                            local oldCF = hrp.CFrame
                                            hrp.CFrame = oldCF * CFrame.new(0, getgenv().jdk.antiHitHeight or 12, 0)
                                            task.spawn(function()
                                                local duration = getgenv().jdk.antiHitTime or 0.2
                                                hrp.Anchored = true
                                                task.wait(duration)
                                                hrp.Anchored = false
                                                hrp.CFrame = oldCF
                                                task.wait(0.2)
                                                isDodging = false
                                            end)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            elseif active["antihit"] then
                active["antihit"]:Disconnect(); active["antihit"] = nil
            end
        end},
        {name="auto play", hasSettings=true, settings={
            {type="slider", name="delay", min=1, max=10, default=3, initial=3, suffix="s", callback=function(v) getgenv().jdk.autoplayDelay = v end}
        }, logic=function(state)
            if state then
                active["autoplay"] = task.spawn(function()
                    while moduleStates["auto play"] do
                        task.wait(1)
                        if knitok and bw.Knit and bw.Knit.Controllers.QueueController then
                            local matchState = workspace:GetAttribute("MatchState")
                            if matchState == 2 then
                                task.wait(getgenv().jdk.autoplayDelay or 3)
                                pcall(function()
                                    bw.Knit.Controllers.QueueController:joinQueue("bedwars_test")
                                end)
                            end
                        end
                    end
                end)
            else
                if active["autoplay"] then task.cancel(active["autoplay"]); active["autoplay"]=nil end
            end
        end},
        {name="auto buy", logic=function(state)
            if state then
                active["autobuy"] = task.spawn(function()
                    while moduleStates["auto buy"] do
                        task.wait(1.5)
                        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then continue end
                        local inv = nil
                        pcall(function()
                            inv = require(rep.TS.inventory["inventory-util"]).InventoryUtil.getInventory(plr)
                        end)
                        if not inv or not inv.items then continue end
                        local iron, gold, emeralds = 0, 0, 0
                        local blocks = 0
                        local hasAxe, hasPick = false, false
                        local armorLvl, swordLvl = 0, 0
                        for _, item in ipairs(inv.items) do
                            local n = item.itemType
                            local amt = item.amount or 1
                            if n == "iron" then iron = iron + amt
                            elseif n == "gold" then gold = gold + amt
                            elseif n == "emerald" then emeralds = emeralds + amt
                            elseif string.find(n, "wool") or string.find(n, "wood") or string.find(n, "stone_brick") then
                                if not string.find(n, "sword") and not string.find(n, "pickaxe") and not string.find(n, "axe") then
                                    blocks = blocks + amt
                                end
                            elseif string.find(n, "axe") and not string.find(n, "pickaxe") then hasAxe = true
                            elseif string.find(n, "pickaxe") then hasPick = true
                            elseif n == "leather_armor" then armorLvl = math.max(armorLvl, 1)
                            elseif n == "iron_armor" then armorLvl = math.max(armorLvl, 2)
                            elseif n == "diamond_armor" then armorLvl = math.max(armorLvl, 3)
                            elseif n == "emerald_armor" then armorLvl = math.max(armorLvl, 4)
                            elseif n == "stone_sword" then swordLvl = math.max(swordLvl, 1)
                            elseif n == "iron_sword" then swordLvl = math.max(swordLvl, 2)
                            elseif n == "diamond_sword" then swordLvl = math.max(swordLvl, 3)
                            elseif n == "emerald_sword" then swordLvl = math.max(swordLvl, 4)
                            end
                        end
                        local function buy(itemname)
                            pcall(function()
                                local ItemShopController = bw.Knit and bw.Knit.Controllers and bw.Knit.Controllers.ItemShopController
                                if ItemShopController and ItemShopController.purchaseItem then
                                    ItemShopController:purchaseItem(itemname)
                                else
                                    local remote = findRemote("BedwarsPurchaseItemEvent") or findRemote("BedwarsPurchaseItem")
                                    if remote then
                                        if remote:IsA("RemoteEvent") then remote:FireServer({shopItem = {itemType = itemname}})
                                        else remote:InvokeServer({shopItem = {itemType = itemname}}) end
                                    end
                                end
                            end)
                        end
                        local blocksNeeded = getgenv().jdk_blocks_needed or 64
                        if blocks < blocksNeeded and iron >= 8 then buy("wool")
                        elseif not hasAxe and iron >= 20 then buy("wood_axe")
                        elseif not hasPick and iron >= 20 then buy("wood_pickaxe")
                        elseif armorLvl == 0 and iron >= 50 then buy("leather_armor")
                        elseif swordLvl == 0 and iron >= 20 then buy("stone_sword")
                        elseif armorLvl == 1 and iron >= 120 then buy("iron_armor")
                        elseif swordLvl == 1 and iron >= 70 then buy("iron_sword")
                        end
                    end
                end)
            else
                if active["autobuy"] then task.cancel(active["autobuy"]); active["autobuy"]=nil end
            end
        end},
        {name="auto win", hasSettings=true, settings={
            {type="toggle", name="rage mode", default=true, callback=function(v) autoWinRage=v end}
        }, logic=function(state)
            if state then
                local function ensureModule(name, s)
                    if toggleRefs[name] and moduleStates[name] ~= s then
                        pcall(function() toggleRefs[name]:set(s) end)
                    end
                end
                ensureModule("auto buy", true)
                ensureModule("auto play", true)
                ensureModule("Kill Aura", true)
                ensureModule("scaffold", true)
                ensureModule("bed nuker", true)
                ensureModule("sprint", true)
                if autoWinRage ~= false then
                    ensureModule("anti hit", true)
                    ensureModule("Reach", true)
                    ensureModule("fast break", true)
                else
                    ensureModule("anti hit", false)
                    ensureModule("Reach", false)
                    ensureModule("fast break", false)
                end
                active["autowin"] = task.spawn(function()
                    while moduleStates["auto win"] do
                        task.wait(0.1)
                        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") or not plr.Character:FindFirstChild("Humanoid") then continue end
                        local hrp = plr.Character.HumanoidRootPart
                        local hum = plr.Character.Humanoid
                        local isStuck = false
                        if (hrp.Velocity * Vector3.new(1, 0, 1)).Magnitude < 2 and hrp.Velocity.Y > -2 and hum:GetState() == Enum.HumanoidStateType.Running then
                            isStuck = true
                        end
                        local targetBed = nil
                        local bestBedDist = math.huge
                        for _, v in ipairs(game:GetService("CollectionService"):GetTagged("bed")) do
                            local isOwnTeam = false
                            if plr.Team and v:GetAttribute("Team" .. tostring(plr.Team.Name) .. "NoBreak") then isOwnTeam = true end
                            if plr:GetAttribute("Team") and v:GetAttribute("Team" .. tostring(plr:GetAttribute("Team")) .. "NoBreak") then isOwnTeam = true end
                            if not isOwnTeam then
                                local dist = (v.Position - hrp.Position).Magnitude
                                if dist < bestBedDist then
                                    bestBedDist = dist
                                    targetBed = v
                                end
                            end
                        end
                        local bestEnemy = nil
                        local bestEnemyDist = math.huge
                        if not targetBed then
                            for _, enemy in ipairs(game:GetService("Players"):GetPlayers()) do
                                if enemy ~= plr and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
                                    local isOwnTeam = false
                                    if plr.Team and enemy.Team == plr.Team then isOwnTeam = true end
                                    if plr:GetAttribute("Team") and enemy:GetAttribute("Team") == plr:GetAttribute("Team") then isOwnTeam = true end
                                    if not isOwnTeam then
                                        local dist = (enemy.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                                        if dist < bestEnemyDist then
                                            bestEnemyDist = dist
                                            bestEnemy = enemy.Character.HumanoidRootPart
                                        end
                                    end
                                end
                            end
                        end
                        local targetDist = targetBed and bestBedDist or bestEnemyDist
                        local blocksNeeded = 64
                        if targetDist ~= math.huge then
                            blocksNeeded = math.max(64, math.ceil(targetDist / 3) + 16)
                        end
                        getgenv().jdk_blocks_needed = blocksNeeded
                        local isAtBase = false
                        for _, v in ipairs(game:GetService("CollectionService"):GetTagged("bed")) do
                            local isOwnTeam = false
                            if plr.Team and v:GetAttribute("Team" .. tostring(plr.Team.Name) .. "NoBreak") then isOwnTeam = true end
                            if plr:GetAttribute("Team") and v:GetAttribute("Team" .. tostring(plr:GetAttribute("Team")) .. "NoBreak") then isOwnTeam = true end
                            if isOwnTeam and (v.Position - hrp.Position).Magnitude < 60 then
                                isAtBase = true
                                break
                            end
                        end
                        local inv = nil
                        pcall(function() inv = require(rep.TS.inventory["inventory-util"]).InventoryUtil.getInventory(plr) end)
                        local currentBlocks = 0
                        if inv and inv.items then
                            for _, item in ipairs(inv.items) do
                                local n = item.itemType
                                if (string.find(n, "wool") or string.find(n, "wood") or string.find(n, "stone_brick")) and not string.find(n, "sword") and not string.find(n, "pickaxe") and not string.find(n, "axe") then
                                    currentBlocks = currentBlocks + (item.amount or 1)
                                end
                            end
                        end
                        if isAtBase and currentBlocks < blocksNeeded then
                            hum:MoveTo(hrp.Position)
                            continue
                        end
                        if targetBed then
                            hum:MoveTo(targetBed.Position)
                            if (bestBedDist < 15 or isStuck) and hum:GetState() ~= Enum.HumanoidStateType.Freefall and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
                                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                            end
                        elseif bestEnemy then
                            hum:MoveTo(bestEnemy.Position)
                            if (bestEnemyDist < 18 or isStuck) and hum:GetState() ~= Enum.HumanoidStateType.Freefall and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
                                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                            end
                        end
                    end
                end)
            else
                if active["autowin"] then task.cancel(active["autowin"]); active["autowin"]=nil end
            end
        end}
    }},
    {"visuals", {
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
            {type="textbox", name="tp key", default="v", callback=function(v) getgenv().freecamTpKey = getgenv().jdk.getKeyCodeFromString(v) end}
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
    }},
    {"troll", {
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
    }},
    {"settings", {
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
    }},
    {"config", {
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
    }},
    {"hud", {
        {name="Combat Window", type="toggle", default=true, logic=function(state) if categoryWindows["combat"] then categoryWindows["combat"].Visible = state end end},
        {name="Movement Window", type="toggle", default=true, logic=function(state) if categoryWindows["movement"] then categoryWindows["movement"].Visible = state end end},
        {name="Visuals Window", type="toggle", default=true, logic=function(state) if categoryWindows["visuals"] then categoryWindows["visuals"].Visible = state end end},
        {name="Player Window", type="toggle", default=true, logic=function(state) if categoryWindows["player"] then categoryWindows["player"].Visible = state end end},
        {name="Troll Window", type="toggle", default=true, logic=function(state) if categoryWindows["troll"] then categoryWindows["troll"].Visible = state end end},
        {name="Settings Window", type="toggle", default=true, logic=function(state) if categoryWindows["settings"] then categoryWindows["settings"].Visible = state end end},
        {name="Config Window", type="toggle", default=true, logic=function(state) if categoryWindows["config"] then categoryWindows["config"].Visible = state end end}
    }}
}
local skingui = Instance.new("Frame")
skingui.Name = "jdk_skinchanger"
skingui.Size = UDim2.new(0, 520, 0, 380)
skingui.Position = UDim2.new(0.5, -260, 0.5, -190)
skingui.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
skingui.BorderSizePixel = 0
skingui.Visible = false
skingui.Parent = gui
Instance.new("UICorner", skingui).CornerRadius = UDim.new(0, 8)
addshadow(skingui)
local skinpattern = Instance.new("ImageLabel")
skinpattern.Size = UDim2.new(1, 0, 1, 0)
skinpattern.BackgroundTransparency = 1
skinpattern.Image = "rbxassetid://9810151833"
skinpattern.ImageColor3 = c_colors.accent
skinpattern.ImageTransparency = 0.94
skinpattern.ScaleType = Enum.ScaleType.Tile
skinpattern.TileSize = UDim2.new(0, 24, 0, 24)
skinpattern.Parent = skingui
Instance.new("UICorner", skinpattern).CornerRadius = UDim.new(0, 8)
local skinstroke = Instance.new("UIStroke")
skinstroke.Thickness = 1.5
skinstroke.Color = c_colors.outline
skinstroke.Parent = skingui
local skingrad = Instance.new("UIGradient")
skingrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, c_colors.accent),
    ColorSequenceKeypoint.new(0.5, c_colors.accent2),
    ColorSequenceKeypoint.new(1, c_colors.accent3)
})
skingrad.Rotation = 45
skingrad.Parent = skinstroke
table.insert(gradientAnimations, skingrad)
local skintop = Instance.new("Frame")
skintop.Size = UDim2.new(1, 0, 0, 45)
skintop.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
skintop.BackgroundTransparency = 0.4
skintop.BorderSizePixel = 0
skintop.Parent = skingui
Instance.new("UICorner", skintop).CornerRadius = UDim.new(0, 8)
local skintopline = Instance.new("Frame")
skintopline.Size = UDim2.new(1, 0, 0, 1)
skintopline.Position = UDim2.new(0, 0, 1, -1)
skintopline.BackgroundColor3 = c_colors.outline
skintopline.BorderSizePixel = 0
skintopline.Parent = skintop
local skintitle = Instance.new("TextLabel")
skintitle.Size = UDim2.new(1, -20, 1, 0)
skintitle.Position = UDim2.new(0, 16, 0, 0)
skintitle.BackgroundTransparency = 1
skintitle.Text = "SKINCHANGER"
skintitle.TextColor3 = c_colors.white
skintitle.Font = Enum.Font.GothamBold
skintitle.TextSize = 14
skintitle.TextXAlignment = Enum.TextXAlignment.Left
skintitle.Parent = skintop
makedrag(skintop, skingui)
local titlegrad = Instance.new("UIGradient")
titlegrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, c_colors.accent),
    ColorSequenceKeypoint.new(1, c_colors.accent2)
})
titlegrad.Parent = skintitle
local closebtn = Instance.new("TextButton")
closebtn.Size = UDim2.new(0, 30, 0, 30)
closebtn.Position = UDim2.new(1, -40, 0.5, -15)
closebtn.BackgroundTransparency = 1
closebtn.Text = "X"
closebtn.TextColor3 = c_colors.dim
closebtn.Font = Enum.Font.MontserratBold
closebtn.TextSize = 14
closebtn.Parent = skintop
closebtn.MouseButton1Click:Connect(function() skingui.Visible = false end)
local searchbox = Instance.new("TextBox")
searchbox.Size = UDim2.new(0, 150, 0, 26)
searchbox.Position = UDim2.new(1, -210, 0.5, -13)
searchbox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
searchbox.BorderSizePixel = 0
searchbox.Text = "Search..."
searchbox.TextColor3 = c_colors.dim
searchbox.Font = Enum.Font.Montserrat
searchbox.TextSize = 12
searchbox.Parent = skintop
Instance.new("UICorner", searchbox).CornerRadius = UDim.new(0, 6)
local searchstroke = Instance.new("UIStroke")
searchstroke.Thickness = 1
searchstroke.Color = c_colors.outline
searchstroke.Parent = searchbox
local currentSearchQuery = ""
local function updateSearch()
    if searchbox.Text == "" then
        searchbox.Text = "Search..."
        currentSearchQuery = ""
    elseif searchbox.Text ~= "Search..." then
        currentSearchQuery = searchbox.Text:lower()
    end
end
searchbox.Focused:Connect(function()
    if searchbox.Text == "Search..." then searchbox.Text = "" end
end)
local cattabs = Instance.new("ScrollingFrame")
cattabs.Size = UDim2.new(1, -20, 0, 34)
cattabs.Position = UDim2.new(0, 10, 0, 55)
cattabs.BackgroundTransparency = 1
cattabs.ScrollBarThickness = 0
cattabs.CanvasSize = UDim2.new(0, 480, 0, 0)
cattabs.Parent = skingui
local catlayout = Instance.new("UIListLayout")
catlayout.FillDirection = Enum.FillDirection.Horizontal
catlayout.SortOrder = Enum.SortOrder.LayoutOrder
catlayout.Padding = UDim.new(0, 8)
catlayout.Parent = cattabs
local skinlist = Instance.new("ScrollingFrame")
skinlist.Size = UDim2.new(1, -20, 1, -100)
skinlist.Position = UDim2.new(0, 10, 0, 95)
skinlist.BackgroundTransparency = 1
skinlist.BorderSizePixel = 0
skinlist.ScrollBarThickness = 3
skinlist.ScrollBarImageColor3 = c_colors.accent2
skinlist.Parent = skingui
local skinlayout = Instance.new("UIGridLayout")
skinlayout.CellSize = UDim2.new(0, 158, 0, 40)
skinlayout.CellPadding = UDim2.new(0, 8, 0, 8)
skinlayout.SortOrder = Enum.SortOrder.LayoutOrder
skinlayout.Parent = skinlist
local selectedWeaponType = "Swords"
local activeSkins = { Swords = "", Bows = "", Crossbows = "", Headhunter = "", Pickaxes = "", Axes = "", Shears = "" }
local weaponCategories = {"Swords", "Bows", "Crossbows", "Headhunter", "Pickaxes", "Axes", "Shears"}
local weaponSkins = { Swords = {}, Bows = {}, Crossbows = {}, Headhunter = {}, Pickaxes = {}, Axes = {}, Shears = {} }
cattabs.CanvasSize = UDim2.new(0, #weaponCategories * 108, 0, 0)
local activeSkinParts = {}
local function applySkinToTool(tool)
    if not tool or (not tool:IsA("Tool") and not tool:IsA("Model") and not tool:IsA("Accessory")) then return end
    local n = tool.Name:lower()
    local cat = nil
    if n:find("sword") or n:find("blade") or n:find("dagger") or n:find("hammer") or n:find("scythe") then cat = "Swords"
    elseif n:find("headhunter") then cat = "Headhunter"
    elseif n:find("crossbow") then cat = "Crossbows"
    elseif n:find("bow") then cat = "Bows"
    elseif n:find("pickaxe") then cat = "Pickaxes"
    elseif n:find("axe") then cat = "Axes"
    elseif n:find("shear") then cat = "Shears" end
    if cat and activeSkins[cat] and activeSkins[cat] ~= "" then
        local targetSkin = activeSkins[cat]
        local materials = {"wood", "stone", "iron", "diamond", "emerald"}
        local toolMaterial = ""
        for _, mat in ipairs(materials) do
            if n:sub(1, #mat) == mat then
                toolMaterial = mat
                break
            end
        end
        local skinMaterial = ""
        local baseSkinName = targetSkin
        for _, mat in ipairs(materials) do
            if targetSkin:lower():sub(1, #mat + 1) == mat .. "_" then
                skinMaterial = mat
                baseSkinName = targetSkin:sub(#mat + 2)
                break
            end
        end
        if toolMaterial ~= "" and skinMaterial ~= "" then
            local checkSkin = toolMaterial .. "_" .. baseSkinName
            if rep:FindFirstChild("Items") and rep.Items:FindFirstChild(checkSkin) then
                targetSkin = checkSkin
            end
        end
        local skinFolder = rep:FindFirstChild("Items") and rep.Items:FindFirstChild(targetSkin)
        if skinFolder then
            local handle = tool:FindFirstChild("Handle") or tool.PrimaryPart
            if not handle then
                for _, v in ipairs(tool:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name == "Handle" then handle = v; break end
                end
                if not handle then
                    for _, v in ipairs(tool:GetDescendants()) do
                        if v:IsA("BasePart") then handle = v; break end
                    end
                end
            end
            if not handle then return end
            local currentSkin = tool:FindFirstChild("JDKSkin")
            if currentSkin and currentSkin.Value == targetSkin then return end
            if currentSkin then currentSkin.Parent:Destroy() end
            for _, v in ipairs(tool:GetDescendants()) do
                if v:IsA("BasePart") and v.Name ~= "JDKSkin" and not v:FindFirstAncestor("JDKSkinMod") then
                    v.Transparency = 1
                elseif (v:IsA("Decal") or v:IsA("Texture")) and not v:FindFirstAncestor("JDKSkinMod") then
                    v.Transparency = 1
                end
            end
            local newMod = Instance.new("Model")
            newMod.Name = "JDKSkinMod"
            local str = Instance.new("StringValue")
            str.Name = "JDKSkin"
            str.Value = targetSkin
            str.Parent = newMod
            local skinSource = skinFolder
            local actualModel = skinFolder:FindFirstChild(targetSkin)
            if actualModel and (actualModel:IsA("Accessory") or actualModel:IsA("Model") or actualModel:IsA("Tool")) then
                skinSource = actualModel
            elseif skinFolder:FindFirstChild("HandModel") then
                skinSource = skinFolder:FindFirstChild("HandModel")
            end
            local skinHandle = skinSource:FindFirstChild("Handle") or skinSource.PrimaryPart
            if not skinHandle then
                for _, v in ipairs(skinSource:GetDescendants()) do
                    if v:IsA("BasePart") and not v.Name:lower():find("hitbox") and not (v.Parent and v.Parent.Name:lower():find("drop")) then skinHandle = v; break end
                end
            end
            local skinAttach = nil
            local handleAttach = nil
            for _, a in ipairs(handle:GetChildren()) do
                if a:IsA("Attachment") and (a.Name:find("Grip") or a.Name == "RightGripAttachment") then handleAttach = a; break end
            end
            if skinHandle then
                for _, a in ipairs(skinHandle:GetChildren()) do
                    if a:IsA("Attachment") and (a.Name:find("Grip") or a.Name == "RightGripAttachment") then skinAttach = a; break end
                end
                if not skinAttach then
                    for _, a in ipairs(skinHandle:GetChildren()) do
                        if a:IsA("Attachment") then skinAttach = a; break end
                    end
                end
            end
            local cframeOffset = skinHandle and skinHandle.CFrame:Inverse() or CFrame.new()
            for _, part in ipairs(skinSource:GetDescendants()) do
                if part:IsA("BasePart") and not part.Name:lower():find("hitbox") and not (part.Parent and part.Parent.Name:lower():find("drop")) and not part:FindFirstAncestor("ItemDrop") then
                    local p = part:Clone()
                    p.Anchored = false
                    p.CanCollide = false
                    p.CanQuery = false
                    p.CanTouch = false
                    p.Massless = true
                    p.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0, 0, 0, 0)
                    for _, s in ipairs(p:GetDescendants()) do
                        if s:IsA("Script") or s:IsA("LocalScript") or s:IsA("JointInstance") or s:IsA("Constraint") or s:IsA("BodyMover") or s:IsA("AlignPosition") or s:IsA("AlignOrientation") or s:IsA("LinearVelocity") or s:IsA("AngularVelocity") then
                            s:Destroy()
                        end
                    end
                    if skinHandle then
                        local relativeOffset = cframeOffset * part.CFrame
                        local handCFrame = handle.CFrame
                        if handleAttach then
                            handCFrame = handle.CFrame * handleAttach.CFrame
                        elseif tool:IsA("Tool") then
                            handCFrame = handle.CFrame * tool.Grip
                        end
                        local skinGrip = CFrame.new()
                        if skinAttach then
                            skinGrip = skinAttach.CFrame
                        elseif skinSource:IsA("Tool") then
                            skinGrip = skinSource.Grip
                        end
                        local finalCFrame = handCFrame * skinGrip:Inverse() * relativeOffset
                        p.CFrame = finalCFrame
                        activeSkinParts[p] = {handle = handle, offset = handle.CFrame:Inverse() * finalCFrame}
                    else
                        p.CFrame = handle.CFrame
                        activeSkinParts[p] = {handle = handle, offset = handle.CFrame:Inverse() * p.CFrame}
                    end
                    p.Anchored = true
                    p.Parent = newMod
                end
            end
            newMod.Parent = tool
        end
    end
end
local function applySkinsToAll()
    if plr.Character then
        for _, t in ipairs(plr.Character:GetChildren()) do applySkinToTool(t) end
    end
    if workspace.CurrentCamera:FindFirstChild("Viewmodel") then
        for _, t in ipairs(workspace.CurrentCamera.Viewmodel:GetChildren()) do applySkinToTool(t) end
    end
    if knitok and bw and bw.Knit and bw.Knit.Controllers and bw.Knit.Controllers.ViewmodelController then
        local vc = bw.Knit.Controllers.ViewmodelController
        if vc.heldItem then applySkinToTool(vc.heldItem) end
    end
end
game:GetService("RunService").RenderStepped:Connect(function()
    for p, data in pairs(activeSkinParts) do
        if p.Parent and data.handle and data.handle.Parent then
            p.CFrame = data.handle.CFrame * data.offset
            p.CanCollide = false
            p.CanTouch = false
            p.CanQuery = false
        else
            activeSkinParts[p] = nil
            if p.Parent then p:Destroy() end
        end
    end
end)
local originalImages = {}
local function updateItemMetaImages(ownedItems)
    local success, itemMetaModule = pcall(function() return require(rep.TS.item["item-meta"]) end)
    if not success or type(itemMetaModule) ~= "table" or not itemMetaModule.getItemMeta then return end
    if not ownedItems then
        ownedItems = {}
        local successStore, storeMod = pcall(function() return require(rep.TS.ui.store) end)
        local ClientStore = successStore and storeMod and storeMod.ClientStore
        if ClientStore then
            local state = ClientStore:getState()
            if state and state.Inventory and state.Inventory.observedInventory then
                local inv = state.Inventory.observedInventory
                if inv.hotbar then
                    for _, slot in pairs(inv.hotbar) do
                        if slot.item and slot.item.itemType then ownedItems[slot.item.itemType] = true end
                    end
                end
                if inv.inventory and inv.inventory.items then
                    for _, item in pairs(inv.inventory.items) do
                        if item.itemType then ownedItems[item.itemType] = true end
                    end
                end
            end
        end
    end
    local changed = false
    for cat, targetSkin in pairs(activeSkins) do
        local skinsList = weaponSkins[cat] or {}
        local materials = {"wood", "stone", "iron", "diamond", "emerald"}
        local skinMaterial = ""
        local baseSkinName = targetSkin
        if targetSkin ~= "" then
            for _, mat in ipairs(materials) do
                if targetSkin:lower():sub(1, #mat + 1) == mat .. "_" then
                    skinMaterial = mat
                    baseSkinName = targetSkin:sub(#mat + 2)
                    break
                end
            end
        end
        for _, weapon in ipairs(skinsList) do
            local meta = itemMetaModule.getItemMeta(weapon)
            if meta then
                if not originalImages[weapon] then originalImages[weapon] = meta.image end
                local desiredImage = originalImages[weapon]
                if targetSkin ~= "" and ownedItems[weapon] then
                    local weaponMaterial = ""
                    for _, mat in ipairs(materials) do
                        if weapon:lower():sub(1, #mat) == mat then
                            weaponMaterial = mat
                            break
                        end
                    end
                    local activeTargetSkin = targetSkin
                    if weaponMaterial ~= "" and skinMaterial ~= "" then
                        local checkSkin = weaponMaterial .. "_" .. baseSkinName
                        if rep:FindFirstChild("Items") and rep.Items:FindFirstChild(checkSkin) then
                            activeTargetSkin = checkSkin
                        end
                    end
                    local activeTargetMeta = itemMetaModule.getItemMeta(activeTargetSkin)
                    if activeTargetMeta and activeTargetMeta.image then
                        desiredImage = activeTargetMeta.image
                    end
                end
                if meta.image ~= desiredImage then
                    meta.image = desiredImage
                    changed = true
                end
            end
        end
    end
    if changed and knitok and bw and bw.Knit and bw.Knit.Controllers and bw.Knit.Controllers.HotbarController then
        pcall(function() bw.Knit.Controllers.HotbarController:mountHotbar() end)
    end
end
task.spawn(function()
    local lastInvStr = ""
    while task.wait(1) do
        if not knitok then continue end
        local successStore, storeMod = pcall(function() return require(rep.TS.ui.store) end)
        local ClientStore = successStore and storeMod and storeMod.ClientStore
        if not ClientStore then continue end
        local state = ClientStore:getState()
        if not state or not state.Inventory or not state.Inventory.observedInventory then continue end
        local inv = state.Inventory.observedInventory
        local ownedItems = {}
        local invStr = ""
        if inv.hotbar then
            for _, slot in pairs(inv.hotbar) do
                if slot.item and slot.item.itemType then
                    ownedItems[slot.item.itemType] = true
                    invStr = invStr .. slot.item.itemType .. ","
                end
            end
        end
        if inv.inventory and inv.inventory.items then
            for _, item in pairs(inv.inventory.items) do
                if item.itemType then
                    ownedItems[item.itemType] = true
                    invStr = invStr .. item.itemType .. ","
                end
            end
        end
        if invStr ~= lastInvStr then
            lastInvStr = invStr
            updateItemMetaImages(ownedItems)
        end
    end
end)
local function renderSkins()
    for _, v in ipairs(skinlist:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    local skins = weaponSkins[selectedWeaponType] or {}
    local renderCount = 0
    for _, skinName in ipairs(skins) do
        if currentSearchQuery == "" or skinName:lower():find(currentSearchQuery) then
            renderCount = renderCount + 1
            local btn = Instance.new("TextButton")
            btn.BackgroundColor3 = (activeSkins[selectedWeaponType] == skinName) and Color3.fromRGB(30, 30, 40) or Color3.fromRGB(20, 20, 25)
            btn.BorderSizePixel = 0
            btn.Text = ""
            btn.Parent = skinlist
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Color = (activeSkins[selectedWeaponType] == skinName) and c_colors.accent2 or c_colors.outline
            stroke.Parent = btn
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = skinName
            lbl.TextColor3 = (activeSkins[selectedWeaponType] == skinName) and c_colors.white or c_colors.dim
            lbl.Font = Enum.Font.Montserrat
            lbl.TextSize = 10
            lbl.Parent = btn
            btn.MouseButton1Click:Connect(function()
                if activeSkins[selectedWeaponType] == skinName then
                    activeSkins[selectedWeaponType] = ""
                else
                    activeSkins[selectedWeaponType] = skinName
                end
                renderSkins()
                applySkinsToAll()
                updateItemMetaImages()
            end)
        end
    end
    skinlist.CanvasSize = UDim2.new(0, 0, 0, math.ceil(renderCount / 3) * 48)
end
searchbox.FocusLost:Connect(function()
    updateSearch()
    renderSkins()
end)
for _, cat in ipairs(weaponCategories) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.BackgroundColor3 = (selectedWeaponType == cat) and c_colors.accent or Color3.fromRGB(20, 20, 25)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Parent = cattabs
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = (selectedWeaponType == cat) and c_colors.accent or c_colors.outline
    stroke.Parent = btn
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = cat
    lbl.TextColor3 = (selectedWeaponType == cat) and c_colors.white or c_colors.dim
    lbl.Font = Enum.Font.MontserratBold
    lbl.TextSize = 11
    lbl.Parent = btn
    btn.MouseButton1Click:Connect(function()
        selectedWeaponType = cat
        for _, v in ipairs(cattabs:GetChildren()) do
            if v:IsA("TextButton") then
                local slbl = v:FindFirstChildOfClass("TextLabel")
                local sstr = v:FindFirstChildOfClass("UIStroke")
                if slbl and slbl.Text == cat then
                    v.BackgroundColor3 = c_colors.accent
                    slbl.TextColor3 = c_colors.white
                    if sstr then sstr.Color = c_colors.accent end
                elseif slbl then
                    v.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
                    slbl.TextColor3 = c_colors.dim
                    if sstr then sstr.Color = c_colors.outline end
                end
            end
        end
        renderSkins()
    end)
end
task.spawn(function()
    local itemsFolder = rep:WaitForChild("Items", 5)
    if itemsFolder then
        for _, item in ipairs(itemsFolder:GetChildren()) do
            local n = item.Name:lower()
            if n:find("sword") or n:find("blade") or n:find("scythe") or n:find("dagger") or n:find("hammer") then
                table.insert(weaponSkins.Swords, item.Name)
            elseif n:find("headhunter") then
                table.insert(weaponSkins.Headhunter, item.Name)
            elseif n:find("crossbow") then
                table.insert(weaponSkins.Crossbows, item.Name)
            elseif n:find("bow") then
                table.insert(weaponSkins.Bows, item.Name)
            elseif n:find("pickaxe") then
                table.insert(weaponSkins.Pickaxes, item.Name)
            elseif n:find("axe") then
                table.insert(weaponSkins.Axes, item.Name)
            elseif n:find("shear") then
                table.insert(weaponSkins.Shears, item.Name)
            end
        end
        renderSkins()
    end
end)
ClientConnections.addThread(task.spawn(function()
    while clientActive do
        pcall(applySkinsToAll)
        task.wait(1)
    end
end))
ClientConnections.addThread(task.spawn(function()
    if knitok and bw and bw.Knit and bw.Knit.Controllers and bw.Knit.Controllers.ViewmodelController then
        bw.Knit.Controllers.ViewmodelController.heldItemChangedSignal:Connect(function(heldItem)
            if heldItem then
                task.wait(0.1)
                pcall(applySkinToTool, heldItem)
            end
        end)
    end
end))
ClientConnections.add(plr.CharacterAdded:Connect(function(c)
    c.ChildAdded:Connect(function(t) task.wait(0.1); pcall(applySkinToTool, t) end)
end))
if plr.Character then
    plr.Character.ChildAdded:Connect(function(t) task.wait(0.1); pcall(applySkinToTool, t) end)
end
ClientConnections.add(workspace.CurrentCamera.ChildAdded:Connect(function(v)
    if v.Name == "Viewmodel" then
        v.ChildAdded:Connect(function(t) task.wait(0.05); pcall(applySkinToTool, t) end)
    end
end))
if workspace.CurrentCamera:FindFirstChild("Viewmodel") then
    workspace.CurrentCamera.Viewmodel.ChildAdded:Connect(function(t) task.wait(0.05); pcall(applySkinToTool, t) end)
end
local hudCat = nil
for _, cat in ipairs(features) do
    if cat[1] == "hud" then
        hudCat = cat[2]
        break
    end
end
if hudCat then
    table.insert(hudCat, {name="Skinchanger Window", type="toggle", default=false, logic=function(state)
        if skingui then skingui.Visible = state end
    end})
end
do
    getgenv().StreamerMode = false
    local streamerSecuredLabels = {}
    local seenNamesMap = {}
    local sortedNames = {}
    local function addSeenPlayer(p)
        local changed = false
        if p.Name and p.Name ~= "" and not seenNamesMap[p.Name] then 
            seenNamesMap[p.Name] = p
            table.insert(sortedNames, p.Name)
            changed = true
        end
        if p.DisplayName and p.DisplayName ~= "" and not seenNamesMap[p.DisplayName] then 
            seenNamesMap[p.DisplayName] = p
            table.insert(sortedNames, p.DisplayName)
            changed = true
        end
        if changed then
            table.sort(sortedNames, function(a, b) return #a > #b end)
        end
    end
    local plrs = game:GetService("Players")
    for _, p in ipairs(plrs:GetPlayers()) do addSeenPlayer(p) end
    plrs.PlayerAdded:Connect(addSeenPlayer)
    local function escapePattern(str)
        return str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
    end
    local function secureLabel(lbl)
        if not lbl:IsA("TextLabel") and not lbl:IsA("TextButton") and not lbl:IsA("TextBox") then return end
        if streamerSecuredLabels[lbl] then return end
        streamerSecuredLabels[lbl] = true
        local isChecking = false
        local function check()
            if isChecking then return end
            if not getgenv().StreamerMode then return end
            local txt = lbl.Text
            if type(txt) ~= "string" or txt == "" then return end
            local newTxt = txt
            local changed = false
            for _, name in ipairs(sortedNames) do
                if string.len(name) >= 3 then
                    local p = seenNamesMap[name]
                    local safeName = escapePattern(name)
                    if newTxt:find(safeName) then
                        newTxt = newTxt:gsub("@" .. safeName, p == plrs.LocalPlayer and "@You" or "@Player")
                        newTxt = newTxt:gsub(safeName, p == plrs.LocalPlayer and "You" or "Player")
                        changed = true
                    end
                end
            end
            if changed then
                isChecking = true
                lbl.Text = newTxt
                isChecking = false
            end
        end
        lbl:GetPropertyChangedSignal("Text"):Connect(check)
        task.spawn(check)
    end
    local function applyStreamerModeTo(parent)
        pcall(function()
            for _, v in ipairs(parent:GetDescendants()) do secureLabel(v) end
            parent.DescendantAdded:Connect(secureLabel)
        end)
    end
    task.spawn(function()
        applyStreamerModeTo(plrs.LocalPlayer.PlayerGui)
        applyStreamerModeTo(game:GetService("CoreGui"))
        applyStreamerModeTo(workspace)
    end)
    local renderCat = nil
    for _, cat in ipairs(features) do
        if cat[1] == "visuals" or cat[1] == "render" then
            renderCat = cat[2]
            break
        end
    end
    if renderCat then
        table.insert(renderCat, {name="Streamer Mode", type="toggle", default=false, logic=function(state)
            getgenv().StreamerMode = state
            if state then
                for lbl, _ in pairs(streamerSecuredLabels) do
                    if lbl.Parent then
                        local txt = lbl.Text
                        lbl.Text = txt .. " "
                        lbl.Text = txt
                    end
                end
            end
        end})
    end
end
for i, data in ipairs(features) do
    local cn = data[1]; local hacks = data[2]
    local px = 30 + ((i-1) * spacing)
    local wc = createwin(cn, px)
    for _, h in ipairs(hacks) do
        pcall(function()
            createtoggle(wc, {
                name=h.name, type=h.type, hasSettings=h.hasSettings,
                settings=h.settings or {}, logic=h.logic, defaultKey=h.defaultKey or Enum.KeyCode.Unknown,
                options=h.options, default=h.default
            })
        end)
    end
end
table.insert(uiconns, uis.InputBegan:Connect(function(inp, gpe)
    if not gpe and inp.KeyCode == hide_bind then
        windowsframe.Visible = not windowsframe.Visible; if blur then blur.Enabled = (windowsframe.Visible and moduleStates["blur effect"]) end
    end
end))
moduleStates["watermark"] = true
updatearraylist()
pcall(function() loadAutoConfig() end)
print("=== jdkclient loaded ===")
