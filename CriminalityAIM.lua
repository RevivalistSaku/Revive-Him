-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- SETTINGS
local MAX_DISTANCE = 300
local PREDICTION = 0.10
local FOV_RADIUS = 100

-- AIM PART MODE
local AIM_PART = "HumanoidRootPart" -- default TORSO

-- STATE
local locked = false
local target = nil
local connection = nil

--------------------------------------------------
-- GUI
--------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "CamlockGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

--------------------------------------------------
-- AIM BUTTON
--------------------------------------------------
local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(70, 70)
button.Position = UDim2.new(1, -25, 0, 25)
button.AnchorPoint = Vector2.new(1, 0)
button.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
button.TextColor3 = Color3.new(0, 0, 0)
button.Text = "AIM"
button.Font = Enum.Font.GothamBold
button.TextScaled = true
button.Parent = gui

Instance.new("UICorner", button).CornerRadius = UDim.new(1, 0)

--------------------------------------------------
-- HEAD / TORSO TOGGLE BUTTON (SMALL RECTANGLE)
--------------------------------------------------
local partButton = Instance.new("TextButton")
partButton.Size = UDim2.fromOffset(55, 20)
partButton.Position = UDim2.new(1, -90, 0, 5)
partButton.AnchorPoint = Vector2.new(1, 0)
partButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
partButton.TextColor3 = Color3.new(1, 1, 1)
partButton.Text = "TORSO"
partButton.Font = Enum.Font.GothamBold
partButton.TextScaled = true
partButton.Parent = gui

Instance.new("UICorner", partButton).CornerRadius = UDim.new(0, 6)

--------------------------------------------------
-- FOV CIRCLE
--------------------------------------------------
local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.fromOffset(FOV_RADIUS * 2, FOV_RADIUS * 2)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.fromScale(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.Parent = gui

Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Transparency = 0.1
stroke.Color = Color3.new(1, 1, 1)
stroke.Parent = fovCircle

--------------------------------------------------
-- TARGET SEARCH (FOV)
--------------------------------------------------
local function getNearestFOVPlayer()
	local center = camera.ViewportSize / 2
	local closest, closestDist = nil, math.huge

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local part = plr.Character:FindFirstChild(AIM_PART)
			local hum = plr.Character:FindFirstChild("Humanoid")
			if not part or not hum or hum.Health <= 0 then continue end

			local dist = (part.Position - camera.CFrame.Position).Magnitude
			if dist > MAX_DISTANCE then continue end

			local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
			if not onScreen then continue end

			local screenDist =
				(Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude

			if screenDist <= FOV_RADIUS and dist < closestDist then
				closestDist = dist
				closest = plr
			end
		end
	end

	return closest
end

--------------------------------------------------
-- HARD CAMLOCK
--------------------------------------------------
local function startCamlock()
	connection = RunService.RenderStepped:Connect(function()
		if not locked or not target or not target.Character then return end

		local part = target.Character:FindFirstChild(AIM_PART)
		local hum = target.Character:FindFirstChild("Humanoid")
		if not part or not hum or hum.Health <= 0 then
			locked = false
			connection:Disconnect()
			return
		end

		local predicted =
			part.Position + (part.AssemblyLinearVelocity * PREDICTION)

		camera.CFrame = CFrame.new(camera.CFrame.Position, predicted)
	end)
end

--------------------------------------------------
-- AIM TOGGLE
--------------------------------------------------
button.MouseButton1Click:Connect(function()
	if not locked then
		target = getNearestFOVPlayer()
		if target then
			locked = true
			startCamlock()
		end
	else
		locked = false
		target = nil
		if connection then connection:Disconnect() end
	end
end)

--------------------------------------------------
-- HEAD / TORSO TOGGLE
--------------------------------------------------
partButton.MouseButton1Click:Connect(function()
	if AIM_PART == "HumanoidRootPart" then
		AIM_PART = "Head"
		partButton.Text = "HEAD"
	else
		AIM_PART = "HumanoidRootPart"
		partButton.Text = "TORSO"
	end
end)
