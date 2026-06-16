return {
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
                                        pcall(function()
                                            local vel = hrp.AssemblyLinearVelocity
                                            hrp.AssemblyLinearVelocity = Vector3.new(vel.X, 38, vel.Z)
                                        end)
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
    }
