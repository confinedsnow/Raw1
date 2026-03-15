local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

local Character = LocalPlayer.Character
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local ENABLED = true
local SHOW_SERVER_GHOST = true
local GHOST_COLOR = Color3.fromRGB(0, 120, 255)
local DESYNC_DELAY = 0.2

if LocalPlayer.PlayerGui:FindFirstChild("DesyncGui") then
    LocalPlayer.PlayerGui:FindFirstChild("DesyncGui"):Destroy()
end
for _, v in pairs(workspace:GetChildren()) do
    if v.Name:sub(1, 6) == "Ghost_" then v:Destroy() end
end

local ghostParts = {}
local positionHistory = {}

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

pcall(function()
    HumanoidRootPart:SetNetworkOwner(LocalPlayer)
end)

local connection
connection = RunService.Heartbeat:Connect(function()
    if not Character or not Character.Parent or not HumanoidRootPart or not HumanoidRootPart.Parent then
        connection:Disconnect()
        for _, ghost in pairs(ghostParts) do
            pcall(function() ghost:Destroy() end)
        end
        return
    end
    local clientCFrame = HumanoidRootPart.CFrame
    local snapshot = {}
    for part in pairs(ghostParts) do
        if part and part.Parent then
            snapshot[part] = part.CFrame
        end
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
            if ghost and ghost.Parent then
                ghost.Transparency = 1
            end
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

local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Name = "DesyncGui"
gui.IgnoreGuiInset = true
gui.Parent = LocalPlayer.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 130)
frame.Position = UDim2.new(0, 20, 0.5, -65)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "DESYNC"
title.TextColor3 = Color3.fromRGB(0, 120, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local function makeButton(text, yPos, onColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = onColor
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local desyncBtn = makeButton("Desync: ON", 32, Color3.fromRGB(0, 200, 80))
local ghostBtn = makeButton("Ghost: ON", 75, Color3.fromRGB(0, 120, 255))

desyncBtn.MouseButton1Click:Connect(function()
    ENABLED = not ENABLED
    desyncBtn.Text = ENABLED and "Desync: ON" or "Desync: OFF"
    desyncBtn.BackgroundColor3 = ENABLED and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(180, 50, 50)
end)

ghostBtn.MouseButton1Click:Connect(function()
    SHOW_SERVER_GHOST = not SHOW_SERVER_GHOST
    ghostBtn.Text = SHOW_SERVER_GHOST and "Ghost: ON" or "Ghost: OFF"
    ghostBtn.BackgroundColor3 = SHOW_SERVER_GHOST and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(180, 50, 50)
end)
