local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

local Character = LocalPlayer.Character
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local ENABLED = true
local SPOOF_RADIUS = 50      -- How far the fake position is from your real one
local SPOOF_RATE = 0.05      -- How often fake position updates (lower = faster)

local lastSpoof = 0

-- ============ CLEANUP ============
if LocalPlayer.PlayerGui:FindFirstChild("SpoofGui") then
    LocalPlayer.PlayerGui:FindFirstChild("SpoofGui"):Destroy()
end

-- ============ FAKE PART (what others lock onto) ============
local fakePart = Instance.new("Part")
fakePart.Name = "FakeRoot"
fakePart.Size = Vector3.new(2, 2, 1)
fakePart.Transparency = 1
fakePart.CanCollide = false
fakePart.Anchored = true
fakePart.CastShadow = false
fakePart.Parent = workspace

-- ============ SPOOF LOOP ============
local connection
connection = RunService.Heartbeat:Connect(function()
    if not Character or not Character.Parent or not HumanoidRootPart or not HumanoidRootPart.Parent then
        connection:Disconnect()
        fakePart:Destroy()
        return
    end

    if not ENABLED then
        fakePart.Position = Vector3.new(0, -9999, 0) -- hide it
        return
    end

    if tick() - lastSpoof >= SPOOF_RATE then
        lastSpoof = tick()

        local realPos = HumanoidRootPart.Position

        -- Generate random offset position around real position
        local angle = math.random() * math.pi * 2
        local radius = math.random(SPOOF_RADIUS / 2, SPOOF_RADIUS)
        local fakePos = Vector3.new(
            realPos.X + math.cos(angle) * radius,
            realPos.Y + math.random(-5, 10),
            realPos.Z + math.sin(angle) * radius
        )

        fakePart.CFrame = CFrame.new(fakePos)
    end
end)

-- ============ RESPAWN ============
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- ============ GUI ============
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Name = "SpoofGui"
gui.IgnoreGuiInset = true
gui.Parent = LocalPlayer.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 90)
frame.Position = UDim2.new(0, 16, 0, 290)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = gui

local accent = Instance.new("Frame", frame)
accent.Size = UDim2.new(0, 3, 1, 0)
accent.Position = UDim2.new(0, 0, 0, 0)
accent.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
accent.BorderSizePixel = 0

local titleLabel = Instance.new("TextLabel", frame)
titleLabel.Size = UDim2.new(1, -12, 0, 28)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "SPOOFER"
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local divider = Instance.new("Frame", frame)
divider.Size = UDim2.new(1, -12, 0, 1)
divider.Position = UDim2.new(0, 12, 0, 28)
divider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
divider.BorderSizePixel = 0

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(1, -24, 0, 28)
btn.Position = UDim2.new(0, 12, 0, 36)
btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
btn.TextColor3 = Color3.fromRGB(220, 220, 220)
btn.Font = Enum.Font.Gotham
btn.TextSize = 12
btn.Text = "SPOOF: ON"
btn.TextXAlignment = Enum.TextXAlignment.Left
btn.BorderSizePixel = 0
btn.AutoButtonColor = false

local tickMark = Instance.new("Frame", btn)
tickMark.Size = UDim2.new(0, 2, 0, 14)
tickMark.Position = UDim2.new(0, 0, 0.5, -7)
tickMark.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
tickMark.BorderSizePixel = 0

btn.MouseEnter:Connect(function()
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
end)
btn.MouseLeave:Connect(function()
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
end)

btn.MouseButton1Click:Connect(function()
    ENABLED = not ENABLED
    btn.Text = "SPOOF: " .. (ENABLED and "ON" or "OFF")
    btn.TextColor3 = ENABLED and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(90, 90, 90)
    tickMark.BackgroundColor3 = ENABLED and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(60, 60, 60)
end)
