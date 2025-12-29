-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- SETTINGS
local MAX_DISTANCE = 300
local PREDICTION = 0.10
local FOV_RADIUS = 100 -- reduced size (pixels)

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
gui.IgnoreGuiInset = true -- 🔥 PERFECT CENTER (mobile + PC)
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

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = button

--------------------------------------------------
-- FOV CIRCLE (PERFECTLY CENTERED)
--------------------------------------------------
local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.fromOffset(FOV_RADIUS * 2, FOV_RADIUS * 2)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.fromScale(0.5, 0.5) -- exact center
fovCircle.BackgroundTransparency = 1
fovCircle.Parent = gui

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(255, 255, 255)
fovStroke.Thickness = 2
fovStroke.Transparency = 0.1
fovStroke.Parent = fovCircle

--------------------------------------------------
-- FIND NEAREST PLAYER INSIDE FOV
--------------------------------------------------
local function getNearestFOVPlayer()
	local viewport = camera.ViewportSize
	local screenCenter = Vector2.new(viewport.X / 2, viewport.Y / 2)

	local closestPlayer = nil
	local closestDistance = math.huge

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			local hum = plr.Character:FindFirstChild("Humanoid")

			if hrp and hum and hum.Health > 0 then
				local worldDist =
					(hrp.Position - camera.CFrame.Position).Magnitude
				if worldDist > MAX_DISTANCE then continue end

				local screenPos, onScreen =
					camera:WorldToViewportPoint(hrp.Position)
				if not onScreen then continue end

				local screenDistance =
					(Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude

				if screenDistance <= FOV_RADIUS then
					if worldDist < closestDistance then
						closestDistance = worldDist
						closestPlayer = plr
					end
				end
			end
		end
	end

	return closestPlayer
end

--------------------------------------------------
-- HARD CAMLOCK LOOP (NO SMOOTHING)
--------------------------------------------------
local function startCamlock()
	connection = RunService.RenderStepped:Connect(function()
		if not locked or not target or not target.Character then return end

		local hrp = target.Character:FindFirstChild("HumanoidRootPart")
		local hum = target.Character:FindFirstChild("Humanoid")

		if not hrp or not hum or hum.Health <= 0 then
			locked = false
			if connection then connection:Disconnect() end
			return
		end

		-- 🔒 Instant snap with prediction
		local predictedPos =
			hrp.Position + (hrp.AssemblyLinearVelocity * PREDICTION)

		camera.CFrame = CFrame.new(
			camera.CFrame.Position,
			predictedPos
		)
	end)
end

--------------------------------------------------
-- BUTTON TOGGLE
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
		if connection then
			connection:Disconnect()
		end
	end
end)
