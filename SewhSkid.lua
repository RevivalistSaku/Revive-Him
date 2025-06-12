-- Wait for game to load
if not game:IsLoaded() then game.Loaded:Wait() end

-- UI Setup
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- "Yo Skidder" popup
local popup = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
popup.Name = "SkidderPopup"
popup.ResetOnSpawn = false

local msg = Instance.new("TextLabel", popup)
msg.Size = UDim2.new(0.3, 0, 0.1, 0)
msg.Position = UDim2.new(0.35, 0, 0.4, 0)
msg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
msg.TextColor3 = Color3.fromRGB(255, 255, 255)
msg.TextScaled = true
msg.Font = Enum.Font.GothamBold
msg.Text = "Yo Skidder"
msg.BackgroundTransparency = 0.1
msg.BorderSizePixel = 0
msg.TextStrokeTransparency = 0.5
msg.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
msg.ZIndex = 2
msg.AnchorPoint = Vector2.new(0.5, 0.5)
msg.ClipsDescendants = true
msg.UICorner = Instance.new("UICorner", msg)
msg.UICorner.CornerRadius = UDim.new(0, 8)

task.delay(2, function()
	popup:Destroy()
end)

-- Button GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "TogglePanel"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 80)
frame.Position = UDim2.new(0.5, -100, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.1
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local toggle1 = Instance.new("TextButton", frame)
toggle1.Size = UDim2.new(1, -10, 0.5, -5)
toggle1.Position = UDim2.new(0, 5, 0, 5)
toggle1.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
toggle1.Text = "Infinite Stamina [OFF]"
toggle1.TextColor3 = Color3.new(1, 1, 1)
toggle1.Font = Enum.Font.Gotham
toggle1.TextScaled = true
Instance.new("UICorner", toggle1).CornerRadius = UDim.new(0, 6)

local toggle2 = Instance.new("TextButton", frame)
toggle2.Size = UDim2.new(1, -10, 0.5, -5)
toggle2.Position = UDim2.new(0, 5, 0.5, 5)
toggle2.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
toggle2.Text = "God Mode [OFF]"
toggle2.TextColor3 = Color3.new(1, 1, 1)
toggle2.Font = Enum.Font.Gotham
toggle2.TextScaled = true
Instance.new("UICorner", toggle2).CornerRadius = UDim.new(0, 6)

-- Feature toggles
local staminaEnabled = false
local godmodeEnabled = false

local drainBackup, sprintBackup, drainerBackup

toggle1.MouseButton1Click:Connect(function()
	staminaEnabled = not staminaEnabled
	toggle1.Text = "Infinite Stamina [" .. (staminaEnabled and "ON" or "OFF") .. "]"

	if staminaEnabled then
		local a = game:GetService("ReplicatedStorage")
		for _, d in ipairs(a:GetDescendants()) do
			if d:IsA("ModuleScript") then
				local name = d.Name:lower()
				if not drainBackup and (name:find("staminadrain") or name:find("module_6_upvr")) then
					local s, m = pcall(require, d)
					if s and type(m) == "table" and m.GetStaminaAfterDrain then
						drainBackup = m
						drainBackup.GetStaminaAfterDrain = function(_, _, _, _, j) return j end
						if drainBackup.CancelExpires then pcall(drainBackup.CancelExpires) end
						if drainBackup.GetDrainer then
							local base = drainBackup.GetDrainer("BaseDrain")
							if base then base.Amount = 0 end
						end
					end
				elseif not sprintBackup and (name:find("sprint") or name:find("module_8_upvr")) then
					local s, m = pcall(require, d)
					if s and type(m) == "table" and m.initialize and m.drainStamina then
						sprintBackup = m
						sprintBackup.drainStamina = function() end
					end
				end
			end
		end
	end
end)

toggle2.MouseButton1Click:Connect(function()
	godmodeEnabled = not godmodeEnabled
	toggle2.Text = "God Mode [" .. (godmodeEnabled and "ON" or "OFF") .. "]"

	if godmodeEnabled then
		local char = player.Character or player.CharacterAdded:Wait()
		local hum = char:WaitForChild("Humanoid")
		local lastHealth = hum.Health

		hum:GetPropertyChangedSignal("Health"):Connect(function()
			if not godmodeEnabled then return end
			if hum.Health < lastHealth then
				hum.Health = lastHealth
			else
				lastHealth = hum.Health
			end
		end)
	end
end)
