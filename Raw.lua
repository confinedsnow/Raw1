local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")

local player = Players.LocalPlayer
while not player do task.wait() player = Players.LocalPlayer end

local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("AutoToggleGui")
if old then old:Destroy() end

local autoResetEnabled    = false
local autoReturnEnabled   = false
local abandonedEnabled    = false
local lastCFrame          = nil
local savedDeathCFrame    = nil
local isAlive             = false
local abandonedTriggered  = false
local characterConnections = {}

local function getCharRoot()
    local c = player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getFurthestSpawn()
    local root = getCharRoot()
    if not root then return nil end
    local furthestSpawn = nil
    local furthestDist  = -1
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") then
            local dist = (root.Position - obj.Position).Magnitude
            if dist > furthestDist then
                furthestDist  = dist
                furthestSpawn = obj
            end
        end
    end
    return furthestSpawn
end

-- ============ GUI ============
local screenGui = Instance.new("ScreenGui")
screenGui.Name           = "AutoToggleGui"
screenGui.ResetOnSpawn   = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Enabled        = true
screenGui.IgnoreGuiInset = true

-- Outer frame
local toggleFrame = Instance.new("Frame", screenGui)
toggleFrame.Size             = UDim2.new(0, 160, 0, 148)
toggleFrame.Position         = UDim2.new(0, 16, 0, 150)
toggleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleFrame.BorderSizePixel  = 0

-- Hard left border accent
local accent = Instance.new("Frame", toggleFrame)
accent.Size             = UDim2.new(0, 3, 1, 0)
accent.Position         = UDim2.new(0, 0, 0, 0)
accent.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
accent.BorderSizePixel  = 0

-- Title
local titleLabel = Instance.new("TextLabel", toggleFrame)
titleLabel.Size              = UDim2.new(1, -12, 0, 28)
titleLabel.Position          = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text              = "TOGGLES"
titleLabel.TextColor3        = Color3.fromRGB(220, 220, 220)
titleLabel.Font              = Enum.Font.GothamBold
titleLabel.TextSize          = 13
titleLabel.TextXAlignment    = Enum.TextXAlignment.Left

-- Divider
local divider = Instance.new("Frame", toggleFrame)
divider.Size             = UDim2.new(1, -12, 0, 1)
divider.Position         = UDim2.new(0, 12, 0, 28)
divider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
divider.BorderSizePixel  = 0

-- Button factory
local function makeToggle(label, yPos)
    local btn = Instance.new("TextButton", toggleFrame)
    btn.Size             = UDim2.new(1, -24, 0, 28)
    btn.Position         = UDim2.new(0, 12, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextColor3       = Color3.fromRGB(180, 180, 180)
    btn.Font             = Enum.Font.Gotham
    btn.TextSize         = 12
    btn.Text             = label .. ": OFF"
    btn.TextXAlignment   = Enum.TextXAlignment.Left
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false

    local tickMark = Instance.new("Frame", btn)
    tickMark.Size             = UDim2.new(0, 2, 0, 14)
    tickMark.Position         = UDim2.new(0, 0, 0.5, -7)
    tickMark.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tickMark.BorderSizePixel  = 0

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end)

    return btn, tickMark
end

local resetBtn,   resetTick   = makeToggle("AUTO RESET",    36)
local returnBtn,  returnTick  = makeToggle("AUTO RETURN",   72)
local abandonBtn, abandonTick = makeToggle("ABANDONED",     108)

local function setState(btn, tick, label, on)
    btn.Text        = label .. ": " .. (on and "ON" or "OFF")
    btn.TextColor3  = on and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(90, 90, 90)
    tick.BackgroundColor3 = on and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(60, 60, 60)
end

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

screenGui.Parent = playerGui

-- ============ CHARACTER LOGIC ============
local function clearCharacterConnections()
    for _, conn in ipairs(characterConnections) do
        pcall(function() conn:Disconnect() end)
    end
    characterConnections = {}
end

local function setupCharacter(character)
    clearCharacterConnections()
    isAlive            = false
    abandonedTriggered = false
    local humanoid = character:WaitForChild("Humanoid", 10)
    local rootPart  = character:WaitForChild("HumanoidRootPart", 10)
    if not humanoid or not rootPart then return end
    if autoReturnEnabled and savedDeathCFrame then
        local cf = savedDeathCFrame
        savedDeathCFrame = nil
        task.defer(function()
            if rootPart and rootPart.Parent then
                pcall(function() rootPart.CFrame = cf end)
            end
        end)
    else
        savedDeathCFrame = nil
    end
    isAlive = true
    table.insert(characterConnections, RunService.Heartbeat:Connect(function()
        if isAlive and rootPart and rootPart.Parent then
            lastCFrame = rootPart.CFrame
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
            local spawn = getFurthestSpawn()
            if spawn then
                pcall(function()
                    rootPart.CFrame = CFrame.new(spawn.Position + Vector3.new(0, 5, 0))
                end)
            end
        end
    end))
    table.insert(characterConnections, humanoid.Died:Connect(function()
        isAlive = false
        if autoReturnEnabled and lastCFrame then
            savedDeathCFrame = lastCFrame
        end
        abandonedTriggered = false
    end))
end

player.CharacterAdded:Connect(function(char)
    task.spawn(setupCharacter, char)
end)
if player.Character then
    task.spawn(setupCharacter, player.Character)
end
