return {
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
        {name="cannon assister", logic=function(state) end},
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
                    if plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local hum=plr.Character.Humanoid
                        local hrp2=plr.Character.HumanoidRootPart
                        local vel = hrp2.AssemblyLinearVelocity
                        if vel.Y < -50 then
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
            {type="textbox", name="hold key", default="v", callback=function(v) getgenv().jdk.blockInKey = getKeyCodeFromString(v) end},
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
                        local hrpVel = hrp.AssemblyLinearVelocity
                        if (hrpVel * Vector3.new(1, 0, 1)).Magnitude < 2 and hrpVel.Y > -2 and hum:GetState() == Enum.HumanoidStateType.Running then
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
    }
