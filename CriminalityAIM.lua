-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- SETTINGS
local MAX_DISTANCE = 300
local PREDICTION = 0.10

local FOV_MOBILE = 100
local FOV_PC = 300

-- STATE
local locked = false
local target = nil
local connection = nil
local AIM_PART = "HumanoidRootPart"
local IS_MOBILE = UserInputService.TouchEnabled

-- SELECTION
local selecting = false
local excluded = {}
local highlights = {}

--------------------------------------------------
-- GUI ROOT
--------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--------------------------------------------------
-- FOV CIRCLE (MOBILE ONLY VISIBLE)
--------------------------------------------------
local fovCircle
if IS_MOBILE then
	fovCircle = Instance.new("Frame")
	fovCircle.Size = UDim2.fromOffset(FOV_MOBILE * 2, FOV_MOBILE * 2)
	fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
	fovCircle.Position = UDim2.fromScale(0.5, 0.5)
	fovCircle.BackgroundTransparency = 1
	fovCircle.Parent = gui

	Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = Color3.new(1, 1, 1)
	stroke.Transparency = 0.1
	stroke.Parent = fovCircle
end

--------------------------------------------------
-- MOBILE UI
--------------------------------------------------
local aimButton, partButton, selectButton

if IS_MOBILE then
	aimButton = Instance.new("TextButton")
	aimButton.Size = UDim2.fromOffset(70, 70)
	aimButton.Position = UDim2.new(1, -25, 0, 25)
	aimButton.AnchorPoint = Vector2.new(1, 0)
	aimButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	aimButton.TextColor3 = Color3.new(0, 0, 0)
	aimButton.Text = "AIM"
	aimButton.TextScaled = true
	aimButton.Font = Enum.Font.GothamBold
	aimButton.Parent = gui
	Instance.new("UICorner", aimButton).CornerRadius = UDim.new(1, 0)

	partButton = Instance.new("TextButton")
	partButton.Size = UDim2.fromOffset(55, 20)
	partButton.Position = UDim2.new(1, -90, 0, 5)
	partButton.AnchorPoint = Vector2.new(1, 0)
	partButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	partButton.TextColor3 = Color3.new(1, 1, 1)
	partButton.Text = "TORSO"
	partButton.TextScaled = true
	partButton.Font = Enum.Font.GothamBold
	partButton.Parent = gui
	Instance.new("UICorner", partButton).CornerRadius = UDim.new(0, 6)

	selectButton = Instance.new("TextButton")
	selectButton.Size = UDim2.fromOffset(55, 20)
	selectButton.Position = UDim2.new(1, -150, 0, 5)
	selectButton.AnchorPoint = Vector2.new(1, 0)
	selectButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	selectButton.TextColor3 = Color3.new(1, 1, 1)
	selectButton.Text = "OFF"
	selectButton.TextScaled = true
	selectButton.Font = Enum.Font.GothamBold
	selectButton.Parent = gui
	Instance.new("UICorner", selectButton).CornerRadius = UDim.new(0, 6)
end

--------------------------------------------------
-- EXCLUSION
--------------------------------------------------
local function toggleExclude(plr)
	if excluded[plr] then
		excluded[plr] = nil
		if highlights[plr] then
			highlights[plr]:Destroy()
			highlights[plr] = nil
		end
	else
		excluded[plr] = true
		if plr.Character then
			local h = Instance.new("Highlight")
			h.FillTransparency = 1
			h.OutlineColor = Color3.fromRGB(0, 140, 255)
			h.OutlineTransparency = 0
			h.Adornee = plr.Character
			h.Parent = gui
			highlights[plr] = h
		end
	end
end

--------------------------------------------------
-- TARGET SEARCH (FOV BASED FOR BOTH)
--------------------------------------------------
local function getTarget()
	local center = camera.ViewportSize / 2
	local radius = IS_MOBILE and FOV_MOBILE or FOV_PC

	local closest, closestDist = nil, math.huge

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and not excluded[plr] and plr.Character then
			local part = plr.Character:FindFirstChild(AIM_PART)
			local hum = plr.Character:FindFirstChild("Humanoid")
			if not part or hum.Health <= 0 then continue end

			local worldDist = (part.Position - camera.CFrame.Position).Magnitude
			if worldDist > MAX_DISTANCE then continue end

			local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
			if not onScreen then continue end

			local screenDist =
				(Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude

			if screenDist <= radius and worldDist < closestDist then
				closestDist = worldDist
				closest = plr
			end
		end
	end

	return closest
end

--------------------------------------------------
-- CAMLOCK
--------------------------------------------------
local function startCamlock()
	connection = RunService.RenderStepped:Connect(function()
		if not locked or not target or not target.Character then return end
		if excluded[target] then return end

		local part = target.Character:FindFirstChild(AIM_PART)
		local hum = target.Character:FindFirstChild("Humanoid")
		if not part or hum.Health <= 0 then return end

		local predicted = part.Position + part.AssemblyLinearVelocity * PREDICTION
		camera.CFrame = CFrame.new(camera.CFrame.Position, predicted)
	end)
end

--------------------------------------------------
-- TOGGLES
--------------------------------------------------
local function toggleAimPart()
	if AIM_PART == "HumanoidRootPart" then
		AIM_PART = "Head"
		if IS_MOBILE then
			partButton.Text = "HEAD"
		else
			StarterGui:SetCore("SendNotification", {
				Title = "AIM MODE",
				Text = "Aiming at HEAD",
				Duration = 2
			})
		end
	else
		AIM_PART = "HumanoidRootPart"
		if IS_MOBILE then
			partButton.Text = "TORSO"
		else
			StarterGui:SetCore("SendNotification", {
				Title = "AIM MODE",
				Text = "Aiming at TORSO",
				Duration = 2
			})
		end
	end
end

local function toggleSelect()
	selecting = not selecting
	if IS_MOBILE then
		selectButton.Text = selecting and "ON" or "OFF"
	else
		StarterGui:SetCore("SendNotification", {
			Title = "SELECTION",
			Text = selecting and "Select Players" or "Selection OFF",
			Duration = 2
		})
	end
end

--------------------------------------------------
-- PLAYER CLICK (SELECTION)
--------------------------------------------------
mouse.Button1Down:Connect(function()
	if not selecting then return end
	local t = mouse.Target
	if not t then return end
	local char = t:FindFirstAncestorOfClass("Model")
	local plr = char and Players:GetPlayerFromCharacter(char)
	if plr and plr ~= player then
		toggleExclude(plr)
	end
end)

--------------------------------------------------
-- INPUT
--------------------------------------------------
if IS_MOBILE then
	aimButton.MouseButton1Click:Connect(function()
		if not locked then
			target = getTarget()
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

	partButton.MouseButton1Click:Connect(toggleAimPart)
	selectButton.MouseButton1Click:Connect(toggleSelect)

else
	-- PC HOLD TO LOCK
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end

		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			target = getTarget()
			if target then
				locked = true
				startCamlock()
			end

		elseif input.KeyCode == Enum.KeyCode.E then
			toggleAimPart()

		elseif input.KeyCode == Enum.KeyCode.X then
			toggleSelect()
		end
	end)

	UserInputService.InputEnded:Connect(function(input, gp)
		if gp then return end
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			locked = false
			target = nil
			if connection then
				connection:Disconnect()
				connection = nil
			end
		end
	end)
end
