local plr = game.Players.LocalPlayer
local char = plr.Character
local hrp = char.HumanoidRootPart
local vim = game:GetService("VirtualInputManager")
local velocitys = Vector3.new(-1000,-1000,-1000)

if game.Lighting:FindFirstChild("Atmosphere") then
    game.Lighting.Atmosphere:Destroy()
end

for i,v in pairs(char:FindFirstChild("Injuries"):GetChildren()) do
    v:Destroy()
end

for i,v in pairs(workspace:FindFirstChild("Unclimbable"):GetDescendants()) do
    if v:IsA("BasePart") or v:IsA("MeshPart") then
        v.CanCollide = false
    end
end

for i,v in pairs(workspace:FindFirstChild("Climbable"):GetDescendants()) do
    if v:IsA("BasePart") or v:IsA("MeshPart") then
        v.CanCollide = false
    end
end

local function findNape(hitFolder)
    return hitFolder:FindFirstChild("Nape")
end

local function applyDamageToNape(napeObject)
    if napeObject then
        local humanoid = napeObject.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:TakeDamage(10)
        end
    end
end

local function expandAndHighlightNape(hitFolder)
    local napeObject = findNape(hitFolder)
    if napeObject then
        napeObject.Size = Vector3.new(450, 450, 450)
        napeObject.Transparency = 0.99
        napeObject.Color = Color3.new(1, 1, 1)
        napeObject.Material = Enum.Material.Neon
        napeObject.CanCollide = false
        napeObject.Anchored = false

        local billboardGui = napeObject:FindFirstChild("BillboardGui")
        if not billboardGui then
            billboardGui = Instance.new("BillboardGui")
            billboardGui.Name = "BillboardGui"
            billboardGui.AlwaysOnTop = true
            billboardGui.Size = UDim2.new(2, 0, 2, 0)
            billboardGui.StudsOffset = Vector3.new(0, 3, 0)
            billboardGui.MaxDistance = math.huge
            billboardGui.Adornee = napeObject
            billboardGui.Parent = napeObject

            local espText = Instance.new("TextLabel")
            espText.Text = "Titan"
            espText.Size = UDim2.new(1, 0, 1, 0)
            espText.TextColor3 = Color3.new(255, 0, 0)
            espText.Font = Enum.Font.SourceSansBold
            espText.TextSize = 20
            espText.BackgroundTransparency = 0.5
            espText.Parent = billboardGui
        end
    end
end

local function expandAndHighlightNapesInTitans(titan)
    local hitboxesFolder = titan:FindFirstChild("Hitboxes")
    if hitboxesFolder then
        local hitFolder = hitboxesFolder:FindFirstChild("Hit")
        if hitFolder then
            expandAndHighlightNape(hitFolder)
        end
    end
end

local function clickRetry()
    local retry = game.Players.LocalPlayer.PlayerGui.Interface.Rewards.Main.Info.Main.Buttons.Retry

    retry.Size = UDim2.new(1, 0, 1, 0)
    retry.Parent = game.Players.LocalPlayer.PlayerGui.Interface

    wait(0.5)
    
    mousemoveabs(50,50)
    vim:SendMouseButtonEvent(50, 50, 0, true, game, 0)
    wait()
    vim:SendMouseButtonEvent(50, 50, 0, false, game, 0)
end

task.defer(function()
    while wait(3) do
        if #workspace.Titans:GetChildren() == 0 or plr.PlayerGui.Interface.Rewards.Visible == true then
            clickRetry()
        end
    end
end)
local function checkReload()
    local sets = plr.PlayerGui.Interface.HUD.Main.Top.Blade.Sets
    local blades = sets.Parent.Inner.Bar.Gradient.Offset.X

    if blades == 0 and sets.Text ~= "0 / 3" then
        vim:SendKeyEvent(true, Enum.KeyCode.R, false, nil)
        wait()
        vim:SendKeyEvent(false, Enum.KeyCode.R, false, nil)
    end

    if sets.Text == "0 / 3" and blades == 0 then
        if #workspace.Unclimbable.Reloads:GetChildren() == 0 then
            for i,v in ipairs(workspace.Unclimbable.Props:GetDescendants()) do
                if #workspace.Unclimbable.Reloads:GetChildren() > 0 then
                    break
                end
        
                if v:IsA("MeshPart") or v:IsA("BasePart") then
                    hrp.CFrame = CFrame.new(v.Position.X, v.Position.Y + 500, v.Position.Z)
                    wait(0.5)
                end
            end
        
            if #workspace.Unclimbable.Reloads:GetChildren() == 0 then
                for i,v in ipairs(workspace.Unclimbable.Background:GetDescendants()) do
                    if #workspace.Unclimbable.Reloads:GetChildren() > 0 then
                        break
                    end
        
                    if v:IsA("MeshPart") or v:IsA("BasePart") then
                        hrp.CFrame = CFrame.new(v.Position.X, v.Position.Y + 500, v.Position.Z)
                        wait(0.5)
                    end
                end
            end
        end

        wait(1)

        hrp.CFrame = workspace.Unclimbable.Reloads:FindFirstChild("GasTanks").Refill.CFrame
        vim:SendKeyEvent(true, Enum.KeyCode.R, false, nil)
        wait()
        vim:SendKeyEvent(false, Enum.KeyCode.R, false, nil)
        wait(0.2)
        hrp.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y + 500, hrp.Position.Z)
    end
end

local function redirectHitToNape(hitPart)
    local titan = hitPart.Parent
    if titan then
        local hitboxesFolder = titan:FindFirstChild("Hitboxes")
        if hitboxesFolder then
            local hitFolder = hitboxesFolder:FindFirstChild("Hit")
            if hitFolder then
                applyDamageToNape(findNape(hitFolder))
            end
        end
    end
end

local function setupRedirector()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Touched:Connect(redirectHitToNape)
        end
    end
end

setupRedirector()

task.defer(function()
    while wait() do
        if hrp:FindFirstChild("BV") then
            hrp.BV.Velocity = velocitys
        end
    end
end)

local floatPart = Instance.new("Part")
floatPart.Size = Vector3.new(10, 1, 10)
floatPart.Anchored = true
floatPart.CanCollide = true
floatPart.Transparency = 1
floatPart.Parent = char

local function tweentp(x,y,z)
    local tween = game:GetService("TweenService"):Create(hrp, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {CFrame = CFrame.new(x,y,z)})
    tween:Play()
    tween.Completed:Wait()
end

game:GetService("RunService").Heartbeat:Connect(function()
    floatPart.CFrame = hrp.CFrame * CFrame.new(0,-3.1,0)
end)

local function killTitan(titan)
    if not titan:FindFirstChild("Hitboxes") then
        print("Hitbox not found")
        return
    end

    if titan:FindFirstChild("Head") then
        hrp.CFrame = CFrame.new(titan.Head.Position.X, titan.Head.Position.Y + 300, titan.Head.Position.Z)
    else
        return
    end

    expandAndHighlightNapesInTitans(titan)

    vim:SendMouseButtonEvent(25, 525, 0, true, game, 0)

    wait(1)

    vim:SendMouseButtonEvent(25, 525, 0, false, game, 0)

    if titan:FindFirstChild("Head") then
        tweentp(titan.Head.Position.X, titan.Head.Position.Y + 150, titan.Head.Position.Z)
    else
        return
    end

    wait(1)
end

repeat
    local titansArray = workspace.Titans:GetChildren()
    
    local referencePoint = hrp.Position

    local titanDistances = {}

    for i, v in ipairs(titansArray) do
        if v:FindFirstChild("Head") then
            local distance = (v.Head.Position - referencePoint).Magnitude
            table.insert(titanDistances, {titan = v, distance = distance})
        end
    end

    -- Sort titans by distance
    table.sort(titanDistances, function(a, b)
        return a.distance < b.distance
    end)

    -- Process titans
    for _, data in ipairs(titanDistances) do
        checkReload()
        killTitan(data.titan)
    end
until #workspace.Titans:GetChildren() == 0
