-- SERVICES
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------
-- PLAYER ESP (UNCHANGED)
--------------------------------------------------
local function createPlayerESP(player)
	if player == LocalPlayer then return end

	local function onCharacter(char)
		local highlight = Instance.new("Highlight")
		highlight.Name = "PlayerESP"
		highlight.Adornee = char
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 0
		highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = char

		local head = char:WaitForChild("Head", 5)
		if not head then return end

		local gui = Instance.new("BillboardGui")
		gui.Name = "UsernameESP"
		gui.Adornee = head
		gui.Size = UDim2.fromScale(4, 1)
		gui.StudsOffset = Vector3.new(0, 2.5, 0)
		gui.AlwaysOnTop = true
		gui.Parent = head

		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Text = player.Name
		label.TextColor3 = Color3.fromRGB(255, 0, 0)
		label.TextStrokeTransparency = 0
		label.TextScaled = true
		label.Font = Enum.Font.SourceSansBold
		label.Parent = gui
	end

	if player.Character then
		onCharacter(player.Character)
	end
	player.CharacterAdded:Connect(onCharacter)
end

for _, player in ipairs(Players:GetPlayers()) do
	createPlayerESP(player)
end
Players.PlayerAdded:Connect(createPlayerESP)

--------------------------------------------------
-- COMPUTER ESP (OUTLINE ONLY)
--------------------------------------------------
local function createComputerESP(model)
	if not model:IsA("Model") or model.Name ~= "Computer" then return end

	-- Highlight (OUTLINE ONLY)
	local highlight = Instance.new("Highlight")
	highlight.Name = "ComputerESP"
	highlight.Adornee = model
	highlight.FillTransparency = 1 -- no fill at all
	highlight.OutlineTransparency = 0
	highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = model

	local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not primary then return end

	local gui = Instance.new("BillboardGui")
	gui.Name = "ProgressESP"
	gui.Adornee = primary
	gui.Size = UDim2.fromScale(6, 1.6)
	gui.StudsOffset = Vector3.new(0, 3.5, 0)
	gui.AlwaysOnTop = true
	gui.Parent = model

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 0)
	label.TextStrokeTransparency = 0
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.Parent = gui

	local function updateText()
		local progress = model:GetAttribute("Progress")
		if typeof(progress) == "number" then
			label.Text = "Progress: " .. math.floor(progress)
		else
			label.Text = "Progress: ?"
		end
	end

	updateText()
	model:GetAttributeChangedSignal("Progress"):Connect(updateText)
end

-- Existing computers
for _, obj in ipairs(Workspace:GetDescendants()) do
	createComputerESP(obj)
end

-- New computers
Workspace.DescendantAdded:Connect(createComputerESP)
