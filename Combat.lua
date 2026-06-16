return {
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
                if not fovCircleObj and used then
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
    }
