-- Wait for game to load
if not game:IsLoaded() then
	game.Loaded:Wait()
end

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- GUI Setup
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "SkidderGUI"

-- "Yo Skidder" Text
local label = Instance.new("TextLabel", screenGui)
label.Text = "Yo Skidder"
label.Size = UDim2.new(0.5, 0, 0.1, 0)
label.Position = UDim2.new(0.25, 0, 0.45, 0)
label.BackgroundTransparency = 1
label.TextScaled = true
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.GothamBold

task.delay(3, function()
	label:Destroy()
end)

-- TopBar Toggle Button
local topBar = Instance.new("Frame", screenGui)
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
topBar.Visible = true

local toggleBtn = Instance.new("TextButton", topBar)
toggleBtn.Text = "▼"
toggleBtn.Size = UDim2.new(0, 40, 1, 0)
toggleBtn.Position = UDim2.new(0, 0, 0, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)

-- Main Panel
local panel = Instance.new("Frame", screenGui)
panel.Size = UDim2.new(0, 200, 0, 100)
panel.Position = UDim2.new(0, 10, 0, 50)
panel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
panel.Visible = true

-- Toggle visibility
toggleBtn.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)

-- Infinite Stamina Setup
local staminaEnabled = false
local originalStaminaFn = nil
local originalSprintFn = nil

local function toggleStamina()
	staminaEnabled = not staminaEnabled

	if staminaEnabled then
		-- Scan for modules
		local staminaDrainer, sprintHandler
		for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
			if obj:IsA("ModuleScript") then
				local name = obj.Name:lower()
				if not staminaDrainer and (name:find("staminadrain") or name:find("module_6_upvr")) then
					local ok, mod = pcall(require, obj)
					if ok and mod.GetStaminaAfterDrain then
						staminaDrainer = mod
					end
				elseif not sprintHandler and (name:find("sprint") or name:find("module_8_upvr")) then
					local ok, mod = pcall(require, obj)
					if ok and mod.drainStamina then
						sprintHandler = mod
					end
				end
			end
		end

		-- Patch
		if staminaDrainer then
			originalStaminaFn = staminaDrainer.GetStaminaAfterDrain
			staminaDrainer.GetStaminaAfterDrain = function(_, _, _, _, max)
				return max
			end
		end
		if sprintHandler then
			originalSprintFn = sprintHandler.drainStamina
			sprintHandler.drainStamina = function() end
		end
	else
		-- Restore if possible
		for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
			if obj:IsA("ModuleScript") then
				local name = obj.Name:lower()
				local ok, mod = pcall(require, obj)
				if ok then
					if mod.GetStaminaAfterDrain and originalStaminaFn then
						mod.GetStaminaAfterDrain = originalStaminaFn
					end
					if mod.drainStamina and originalSprintFn then
						mod.drainStamina = originalSprintFn
					end
				end
			end
		end
	end
end

-- Health Lock Setup
local godmodeEnabled = false
local healthConn

local function toggleGodmode()
	godmodeEnabled = not godmodeEnabled

	if godmodeEnabled then
		local last = humanoid.Health
		healthConn = humanoid.HealthChanged:Connect(function(h)
			if h < last then
				humanoid.Health = last
			else
				last = h
			end
		end)
	else
		if healthConn then
			healthConn:Disconnect()
		end
	end
end

-- Stamina Button
local staminaBtn = Instance.new("TextButton", panel)
staminaBtn.Text = "Toggle Infinite Stamina"
staminaBtn.Size = UDim2.new(1, -10, 0, 40)
staminaBtn.Position = UDim2.new(0, 5, 0, 5)
staminaBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
staminaBtn.TextColor3 = Color3.new(1, 1, 1)
staminaBtn.Font = Enum.Font.Gotham
staminaBtn.TextScaled = true
staminaBtn.MouseButton1Click:Connect(toggleStamina)

-- Godmode Button
local godBtn = Instance.new("TextButton", panel)
godBtn.Text = "Toggle Health Lock"
godBtn.Size = UDim2.new(1, -10, 0, 40)
godBtn.Position = UDim2.new(0, 5, 0, 55)
godBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
godBtn.TextColor3 = Color3.new(1, 1, 1)
godBtn.Font = Enum.Font.Gotham
godBtn.TextScaled = true
godBtn.MouseButton1Click:Connect(toggleGodmode)
