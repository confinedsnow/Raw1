local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local ghostParts = {}
local positionHistory = {}
local connection = nil
local ENABLED = true
local SHOW_SERVER_GHOST = true
local GHOST_COLOR = Color3.fromRGB(0, 120, 255)
local DESYNC_DELAY = 0.2

local function cleanupGhosts()
    for _, ghost in pairs(ghostParts) do
        pcall(function() ghost:Destroy() end)
    end
    ghostParts = {}
    positionHistory = {}
    if connection then
        pcall(function() connection:Disconnect() end)
        connection = nil
    end
end

local function setupCharacter(Character)
    cleanupGhosts()
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 10)
    if not HumanoidRootPart then return end
    task.wait(0.5)
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local ghost = Instance.new("Part")
            ghost.Size = part.Size
            ghost.Material = Enum.Material.Neon
            ghost.Color = GHOST_COLOR
            ghost.Transparency = 0.4
            ghost.CanCollide = false
            ghost.Anchored = true
            ghost.CastShadow = false
            ghost.Name = "Ghost_" .. part.Name
            ghost.Parent = workspace
            ghostParts[part] = ghost
        end
    end
    pcall(function() HumanoidRootPart:SetNetworkOwner(LocalPlayer) end)
    connection = RunService.Heartbeat:Connect(function()
        if not Character or not Character.Parent or not HumanoidRootPart or not HumanoidRootPart.Parent then
            cleanupGhosts()
            return
        end
        local clientCFrame = HumanoidRootPart.CFrame
        local snapshot = {}
        for part in pairs(ghostParts) do
            if part and part.Parent then snapshot[part] = part.CFrame end
        end
        table.insert(positionHistory, { time = tick(), cframes = snapshot })
        while positionHistory[1] and tick() - positionHistory[1].time > 1 do
            table.remove(positionHistory, 1)
        end
        if SHOW_SERVER_GHOST then
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
        if ENABLED then
            task.defer(function()
                if HumanoidRootPart and HumanoidRootPart.Parent then
                    HumanoidRootPart.CFrame = clientCFrame
                end
            end)
        end
    end)
end

-- ============ GUI ============
if LocalPlayer.PlayerGui:FindFirstChild("DesyncGui") then
    LocalPlayer.PlayerGui:FindFirstChild("DesyncGui"):Destroy()
end

local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Name = "DesyncGui"
gui.IgnoreGuiInset = true
gui.Parent = LocalPlayer.PlayerGui

-- Outer frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 120)
frame.Position = UDim2.new(0, 16, 0, 16)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = gui

-- Hard left border accent
local accent = Instance.new("Frame")
accent.Size = UDim2.new(0, 3, 1, 0)
accent.Position = UDim2.new(0, 0, 0, 0)
accent.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
accent.BorderSizePixel = 0
accent.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -12, 0, 28)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "DESYNC"
title.TextColor3 = Color3.fromRGB(220, 220, 220)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- Divider
local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -12, 0, 1)
divider.Position = UDim2.new(0, 12, 0, 28)
divider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
divider.BorderSizePixel = 0
divider.Parent = frame

local function makeButton(text, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 28)
    btn.Position = UDim2.new(0, 12, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Text = text .. ": ON"
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = frame

    -- Left tick indicator
    local tick = Instance.new("Frame")
    tick.Size = UDim2.new(0, 2, 0, 14)
    tick.Position = UDim2.new(0, 0, 0.5, -7)
    tick.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    tick.BorderSizePixel = 0
    tick.Parent = btn

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end)

    return btn, tick
end

local desyncBtn, desyncTick = makeButton("DESYNC", 36)
local ghostBtn,  ghostTick  = makeButton("GHOST",  72)

local function setState(btn, tick, label, on)
    btn.Text = label .. ": " .. (on and "ON" or "OFF")
    btn.TextColor3 = on and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(90, 90, 90)
    tick.BackgroundColor3 = on and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(60, 60, 60)
end

desyncBtn.MouseButton1Click:Connect(function()
    ENABLED = not ENABLED
    setState(desyncBtn, desyncTick, "DESYNC", ENABLED)
end)

ghostBtn.MouseButton1Click:Connect(function()
    SHOW_SERVER_GHOST = not SHOW_SERVER_GHOST
    setState(ghostBtn, ghostTick, "GHOST", SHOW_SERVER_GHOST)
end)

-- ============ RESPAWN HANDLER ============
LocalPlayer.CharacterAdded:Connect(function(char)
    task.spawn(setupCharacter, char)
end)

if LocalPlayer.Character then
    task.spawn(setupCharacter, LocalPlayer.Character)
end
