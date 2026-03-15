local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do task.wait() LocalPlayer = Players.LocalPlayer end

repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

local Character = LocalPlayer.Character
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("MasterGui") then
    playerGui:FindFirstChild("MasterGui"):Destroy()
end
for _, v in pairs(workspace:GetChildren()) do
    if v.Name:sub(1, 6) == "Ghost_" or v.Name == "FakeRoot" then v:Destroy() end
end

-- ============ STATE ============
local DESYNC_ENABLED     = true
local SHOW_GHOST         = true
local SPOOF_ENABLED      = true
local autoResetEnabled   = false
local autoReturnEnabled  = false
local abandonedEnabled   = false
local BHOP_ENABLED       = false
local SPEED_ENABLED      = false
local ANTIAIM_ENABLED    = false

local GHOST_COLOR        = Color3.fromRGB(0, 120, 255)
local DESYNC_DELAY       = 0.2
local SPOOF_RADIUS       = 50
local SPOOF_RATE         = 0.05
local SPEED_AMOUNT       = 32
local ANTIAIM_SPEED      = 10

local ghostParts           = {}
local positionHistory      = {}
local characterConnections = {}
local desyncConnection     = nil
local lastCFrame           = nil
local savedDeathCFrame     = nil
local isAlive              = false
local abandonedTriggered   = false
local lastSpoof            = 0
local antitick             = 0

-- ============ FAKE PART ============
local fakePart = Instance.new("Part")
fakePart.Name         = "FakeRoot"
fakePart.Size         = Vector3.new(2, 2, 1)
fakePart.Transparency = 1
fakePart.CanCollide   = false
fakePart.Anchored     = true
fakePart.CastShadow   = false
fakePart.Parent       = workspace

-- ============ GHOST ============
local function cleanupGhosts()
    for _, ghost in pairs(ghostParts) do pcall(function() ghost:Destroy() end) end
    ghostParts = {}
    positionHistory = {}
    if desyncConnection then
        pcall(function() desyncConnection:Disconnect() end)
        desyncConnection = nil
    end
end

local function buildGhost(char)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local ghost = Instance.new("Part")
            ghost.Size         = part.Size
            ghost.Material     = Enum.Material.Neon
            ghost.Color        = GHOST_COLOR
            ghost.Transparency = 0.4
            ghost.CanCollide   = false
            ghost.Anchored     = true
            ghost.CastShadow   = false
            ghost.Name         = "Ghost_" .. part.Name
            ghost.Parent       = workspace
            ghostParts[part]   = ghost
        end
    end
end

local function startDesync(char, hrp)
    pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)
    desyncConnection = RunService.Heartbeat:Connect(function(dt)
        if not char or not char.Parent or not hrp or not hrp.Parent then
            cleanupGhosts()
            return
        end
        local clientCFrame = hrp.CFrame
        local snapshot = {}
        for part in pairs(ghostParts) do
            if part and part.Parent then snapshot[part] = part.CFrame end
        end
        table.insert(positionHistory, { time = tick(), cframes = snapshot })
        while positionHistory[1] and tick() - positionHistory[1].time > 1 do
            table.remove(positionHistory, 1)
        end
        if SHOW_GHOST then
            local targetTime = tick() - DESYNC_DELAY
            local best = nil
            for _, entry in ipairs(positionHistory) do
                if entry.time <= targetTime then best = entry end
            end
            if best then
                for part, ghost in pairs(ghostParts) do
                    if ghost and ghost.Parent and best.cframes[part] then
                        ghost.CFrame = best.cframes[part]
                        ghost.Transparency = 0.4
                    end
                end
            end
        else
            for _, ghost in pairs(ghostParts) do
                if ghost and ghost.Parent then ghost.Transparency = 1 end
            end
        end
        if DESYNC_ENABLED then
            task.defer(function()
                if hrp and hrp.Parent then hrp.CFrame = clientCFrame end
            end)
        end
        if SPOOF_ENABLED and tick() - lastSpoof >= SPOOF_RATE then
            lastSpoof = tick()
            local realPos = hrp.Position
            local angle = math.random() * math.pi * 2
            local radius = math.random(SPOOF_RADIUS / 2, SPOOF_RADIUS)
            fakePart.CFrame = CFrame.new(Vector3.new(
                realPos.X + math.cos(angle) * radius,
                realPos.Y + math.random(-5, 10),
                realPos.Z + math.sin(angle) * radius
            ))
        elseif not SPOOF_ENABLED then
            fakePart.Position = Vector3.new(0, -9999, 0)
        end
        if ANTIAIM_ENABLED then
            antitick = antitick + dt * ANTIAIM_SPEED
            local j1 = math.sin(antitick * 20) * 60
            local j2 = math.cos(antitick * 15) * 30
            task.defer(function()
                if hrp and hrp.Parent then
                    hrp.CFrame = CFrame.new(hrp.Position)
                        * CFrame.Angles(0, math.rad(j1), 0)
                        * CFrame.Angles(math.rad(j2), 0, 0)
                end
            end)
        end
        if SPEED_ENABLED then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = SPEED_AMOUNT end
        end
    end)
end

local function setupBhop(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    table.insert(characterConnections, hum.StateChanged:Connect(function(_, new)
        if not BHOP_ENABLED then return end
        if new == Enum.HumanoidStateType.Landed then
            task.wait(0.05)
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end))
end

local function getFurthestSpawn(hrp)
    if not hrp then return nil end
    local furthest, dist = nil, -1
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") then
            local d = (hrp.Position - obj.Position).Magnitude
            if d > dist then dist = d furthest = obj end
        end
    end
    return furthest
end

local function clearCharConnections()
    for _, c in ipairs(characterConnections) do pcall(function() c:Disconnect() end) end
    characterConnections = {}
end

local function setupCharacter(char)
    cleanupGhosts()
    clearCharConnections()
    isAlive = false
    abandonedTriggered = false
    local hrp      = char:WaitForChild("HumanoidRootPart", 10)
    local humanoid = char:WaitForChild("Humanoid", 10)
    if not hrp or not humanoid then return end
    task.wait(0.5)
    buildGhost(char)
    startDesync(char, hrp)
    setupBhop(char)
    humanoid.WalkSpeed = SPEED_ENABLED and SPEED_AMOUNT or 16
    if autoReturnEnabled and savedDeathCFrame then
        local cf = savedDeathCFrame
        savedDeathCFrame = nil
        task.defer(function()
            if hrp and hrp.Parent then pcall(function() hrp.CFrame = cf end) end
        end)
    else
        savedDeathCFrame = nil
    end
    isAlive = true
    Character = char
    table.insert(characterConnections, RunService.Heartbeat:Connect(function()
        if isAlive and hrp and hrp.Parent then lastCFrame = hrp.CFrame end
        if not SPEED_ENABLED and humanoid and humanoid.Parent and humanoid.WalkSpeed == SPEED_AMOUNT then
            humanoid.WalkSpeed = 16
        end
    end))
    table.insert(characterConnections, humanoid.HealthChanged:Connect(function(health)
        if not isAlive then return end
        if autoResetEnabled and health <= 1 then
            isAlive = false
            pcall(function() humanoid.Health = 0 end)
            return
        end
        if abandonedEnabled and not abandonedTriggered and health <= 25 and health > 0 then
            abandonedTriggered = true
            local sp = getFurthestSpawn(hrp)
            if sp then pcall(function() hrp.CFrame = CFrame.new(sp.Position + Vector3.new(0,5,0)) end) end
        end
    end))
    table.insert(characterConnections, humanoid.Died:Connect(function()
        isAlive = false
        if autoReturnEnabled and lastCFrame then savedDeathCFrame = lastCFrame end
        abandonedTriggered = false
    end))
end

LocalPlayer.CharacterAdded:Connect(function(char) task.spawn(setupCharacter, char) end)
task.spawn(setupCharacter, Character)

-- ============ GUI ============
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn   = false
gui.Name           = "MasterGui"
gui.IgnoreGuiInset = true
gui.Parent         = playerGui

local FRAME_W = 170
local TAB_H   = 28
local BODY_H  = 160

-- Outer container
local container = Instance.new("Frame")
container.Size             = UDim2.new(0, FRAME_W, 0, TAB_H + BODY_H)
container.Position         = UDim2.new(0, 16, 0, 16)
container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
container.BorderSizePixel  = 0
container.Active           = true
container.Selectable       = false
container.Parent           = gui

local accent = Instance.new("Frame", container)
accent.Size             = UDim2.new(0, 3, 1, 0)
accent.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
accent.BorderSizePixel  = 0

-- ============ DRAG ============
local dragging, dragStart, startPos
container.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = input.Position
        startPos  = container.Position
    end
end)
container.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        container.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ============ TAB BAR ============
local tabBar = Instance.new("Frame", container)
tabBar.Size             = UDim2.new(1, 0, 0, TAB_H)
tabBar.Position         = UDim2.new(0, 0, 0, 0)
tabBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
tabBar.BorderSizePixel  = 0

local tabNames = {"DESYNC", "TOGGLE", "COMBAT"}
local tabBtns  = {}
local pages    = {}
local TAB_W    = (FRAME_W - 3) / #tabNames

for i, name in ipairs(tabNames) do
    local tb = Instance.new("TextButton", tabBar)
    tb.Size             = UDim2.new(0, TAB_W, 1, 0)
    tb.Position         = UDim2.new(0, 3 + (i-1) * TAB_W, 0, 0)
    tb.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    tb.TextColor3       = Color3.fromRGB(100, 100, 100)
    tb.Font             = Enum.Font.GothamBold
    tb.TextSize         = 10
    tb.Text             = name
    tb.BorderSizePixel  = 0
    tb.AutoButtonColor  = false
    tabBtns[i] = tb

    local page = Instance.new("Frame", container)
    page.Size             = UDim2.new(1, 0, 0, BODY_H)
    page.Position         = UDim2.new(0, 0, 0, TAB_H)
    page.BackgroundTransparency = 1
    page.BorderSizePixel  = 0
    page.Visible          = false
    pages[i] = page
end

-- Tab underline indicator
local underline = Instance.new("Frame", tabBar)
underline.Size             = UDim2.new(0, TAB_W, 0, 2)
underline.Position         = UDim2.new(0, 3, 1, -2)
underline.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
underline.BorderSizePixel  = 0

local activeTab = 1
local function switchTab(i)
    activeTab = i
    for j, page in ipairs(pages) do
        page.Visible = (j == i)
        tabBtns[j].TextColor3 = (j == i) and Color3.fromRGB(220,220,220) or Color3.fromRGB(100,100,100)
    end
    underline.Position = UDim2.new(0, 3 + (i-1) * TAB_W, 1, -2)
end

for i, tb in ipairs(tabBtns) do
    tb.MouseButton1Click:Connect(function() switchTab(i) end)
end

-- ============ UI HELPERS ============
local function makeBtn(parent, label, yPos, on)
    local btn = Instance.new("TextButton", parent)
    btn.Size             = UDim2.new(1, -24, 0, 30)
    btn.Position         = UDim2.new(0, 12, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextColor3       = on and Color3.fromRGB(220,220,220) or Color3.fromRGB(90,90,90)
    btn.Font             = Enum.Font.Gotham
    btn.TextSize         = 12
    btn.Text             = label .. ": " .. (on and "ON" or "OFF")
    btn.TextXAlignment   = Enum.TextXAlignment.Left
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    local tick = Instance.new("Frame", btn)
    tick.Size             = UDim2.new(0, 2, 0, 14)
    tick.Position         = UDim2.new(0, 0, 0.5, -7)
    tick.BackgroundColor3 = on and Color3.fromRGB(220,220,220) or Color3.fromRGB(60,60,60)
    tick.BorderSizePixel  = 0
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(45,45,45) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(35,35,35) end)
    return btn, tick
end

local function setState(btn, tick, label, on)
    btn.Text       = label .. ": " .. (on and "ON" or "OFF")
    btn.TextColor3 = on and Color3.fromRGB(220,220,220) or Color3.fromRGB(90,90,90)
    tick.BackgroundColor3 = on and Color3.fromRGB(220,220,220) or Color3.fromRGB(60,60,60)
end

local function divider(parent, yPos)
    local d = Instance.new("Frame", parent)
    d.Size             = UDim2.new(1, -12, 0, 1)
    d.Position         = UDim2.new(0, 12, 0, yPos)
    d.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    d.BorderSizePixel  = 0
end

-- ============ PAGE 1: DESYNC ============
local p1 = pages[1]
divider(p1, 0)
local desyncBtn, desyncTick = makeBtn(p1, "DESYNC",  8,  true)
local ghostBtn,  ghostTick  = makeBtn(p1, "GHOST",   46, true)
divider(p1, 84)
local spoofBtn,  spoofTick  = makeBtn(p1, "SPOOF",   92, true)

-- ============ PAGE 2: TOGGLES ============
local p2 = pages[2]
divider(p2, 0)
local resetBtn,   resetTick   = makeBtn(p2, "AUTO RESET",  8,  false)
local returnBtn,  returnTick  = makeBtn(p2, "AUTO RETURN", 46, false)
local abandonBtn, abandonTick = makeBtn(p2, "ABANDONED",   84, false)

-- ============ PAGE 3: COMBAT ============
local p3 = pages[3]
divider(p3, 0)
local antitBtn, antitTick = makeBtn(p3, "ANTI-AIM", 8,  false)
local bhopBtn,  bhopTick  = makeBtn(p3, "BHOP",     46, false)
local speedBtn, speedTick = makeBtn(p3, "SPEED",    84, false)

-- show first tab
switchTab(1)

-- ============ BUTTON LOGIC ============
desyncBtn.MouseButton1Click:Connect(function()
    DESYNC_ENABLED = not DESYNC_ENABLED
    setState(desyncBtn, desyncTick, "DESYNC", DESYNC_ENABLED)
end)
ghostBtn.MouseButton1Click:Connect(function()
    SHOW_GHOST = not SHOW_GHOST
    setState(ghostBtn, ghostTick, "GHOST", SHOW_GHOST)
end)
spoofBtn.MouseButton1Click:Connect(function()
    SPOOF_ENABLED = not SPOOF_ENABLED
    setState(spoofBtn, spoofTick, "SPOOF", SPOOF_ENABLED)
end)
resetBtn.MouseButton1Click:Connect(function()
    autoResetEnabled = not autoResetEnabled
    setState(resetBtn, resetTick, "AUTO RESET", autoResetEnabled)
end)
returnBtn.MouseButton1Click:Connect(function()
    autoReturnEnabled = not autoReturnEnabled
    setState(returnBtn, returnTick, "AUTO RETURN", autoReturnEnabled)
end)
abandonBtn.MouseButton1Click:Connect(function()
    abandonedEnabled = not abandonedEnabled
    setState(abandonBtn, abandonTick, "ABANDONED", abandonedEnabled)
    abandonedTriggered = false
end)
antitBtn.MouseButton1Click:Connect(function()
    ANTIAIM_ENABLED = not ANTIAIM_ENABLED
    setState(antitBtn, antitTick, "ANTI-AIM", ANTIAIM_ENABLED)
end)
bhopBtn.MouseButton1Click:Connect(function()
    BHOP_ENABLED = not BHOP_ENABLED
    setState(bhopBtn, bhopTick, "BHOP", BHOP_ENABLED)
end)
speedBtn.MouseButton1Click:Connect(function()
    SPEED_ENABLED = not SPEED_ENABLED
    setState(speedBtn, speedTick, "SPEED", SPEED_ENABLED)
    local hum = Character and Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = SPEED_ENABLED and SPEED_AMOUNT or 16 end
end)
