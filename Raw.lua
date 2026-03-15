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

local function getHumanoid()
	local c = player.Character
	return c and c:FindFirstChildOfClass("Humanoid")
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

local screenGui = Instance.new("ScreenGui")
screenGui.Name           = "AutoToggleGui"
screenGui.ResetOnSpawn   = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Enabled        = true
screenGui.IgnoreGuiInset = true

local toggleFrame = Instance.new("Frame", screenGui)
toggleFrame.Size              = UDim2.new(0, 210, 0, 172)
toggleFrame.Position          = UDim2.new(0, 16, 0, 50)
toggleFrame.BackgroundColor3  = Color3.fromRGB(10, 12, 20)
toggleFrame.BorderSizePixel   = 0
Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 14)

local strip = Instance.new("Frame", toggleFrame)
strip.Size             = UDim2.new(1, 0, 0, 3)
strip.BackgroundColor3 = Color3.fromRGB(99, 179, 255)
strip.BorderSizePixel  = 0
Instance.new("UICorner", strip).CornerRadius = UDim.new(0, 14)

local tPad = Instance.new("UIPadding", toggleFrame)
tPad.PaddingTop    = UDim.new(0, 14)
tPad.PaddingBottom = UDim.new(0, 10)
tPad.PaddingLeft   = UDim.new(0, 12)
tPad.PaddingRight  = UDim.new(0, 12)

local tList = Instance.new("UIListLayout", toggleFrame)
tList.SortOrder = Enum.SortOrder.LayoutOrder
tList.Padding    = UDim.new(0, 8)

local function makeToggle(label, order)
	local btn = Instance.new("TextButton", toggleFrame)
	btn.Size             = UDim2.new(1, 0, 0, 38)
	btn.BackgroundColor3 = Color3.fromRGB(22, 26, 42)
	btn.TextColor3       = Color3.fromRGB(180, 195, 230)
	btn.Font             = Enum.Font.GothamMedium
	btn.TextSize         = 13
	btn.Text             = "⬜  " .. label .. ": OFF"
	btn.AutoButtonColor  = false
	btn.BorderSizePixel  = 0
	btn.LayoutOrder      = order
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)
	local stroke = Instance.new("UIStroke", btn)
	stroke.Color     = Color3.fromRGB(40, 50, 80)
	stroke.Thickness = 1
	btn.MouseEnter:Connect(function()
		TweenService:Create(stroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(99,179,255), Transparency = 0.4}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(stroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(40,50,80), Transparency = 0}):Play()
	end)
	return btn
end

local resetBtn   = makeToggle("Auto Reset",     1)
local returnBtn  = makeToggle("Auto Return",    2)
local abandonBtn = makeToggle("Abandoned Mode", 3)

local function setToggle(btn, label, on)
	if on then
		btn.Text             = "✅  " .. label .. ": ON"
		btn.BackgroundColor3 = Color3.fromRGB(20, 90, 45)
		btn.TextColor3       = Color3.fromRGB(130, 255, 160)
	else
		btn.Text             = "⬜  " .. label .. ": OFF"
		btn.BackgroundColor3 = Color3.fromRGB(22, 26, 42)
		btn.TextColor3       = Color3.fromRGB(180, 195, 230)
	end
end

resetBtn.MouseButton1Click:Connect(function()
	autoResetEnabled = not autoResetEnabled
	setToggle(resetBtn, "Auto Reset", autoResetEnabled)
end)
returnBtn.MouseButton1Click:Connect(function()
	autoReturnEnabled = not autoReturnEnabled
	setToggle(returnBtn, "Auto Return", autoReturnEnabled)
end)
abandonBtn.MouseButton1Click:Connect(function()
	abandonedEnabled = not abandonedEnabled
	setToggle(abandonBtn, "Abandoned Mode", abandonedEnabled)
	abandonedTriggered = false
end)

screenGui.Parent = playerGui

local function clearCharacterConnections()
	for _, conn in ipairs(characterConnections) do
		pcall(function() conn:Disconnect() end)
	end
	characterConnections = {}
end

local function setupCharacter(character)
	clearCharacterConnections()
	isAlive           = false
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
