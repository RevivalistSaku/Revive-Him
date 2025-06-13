local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Fluent UI Setup
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "SewhSkids " .. Fluent.Version,
    SubTitle = "by Sleafyness",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- Modules lookup
local staminaDrainer, sprintHandler
for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("ModuleScript") then
        local name = obj.Name:lower()
        if not staminaDrainer and (name:find("staminadrain") or name:find("module_6_upvr")) then
            local ok, mod = pcall(require, obj)
            if ok and type(mod) == "table" and mod.GetStaminaAfterDrain then
                staminaDrainer = mod
            end
        elseif not sprintHandler and (name:find("sprint") or name:find("module_8_upvr")) then
            local ok, mod = pcall(require, obj)
            if ok and type(mod) == "table" and mod.initialize and mod.drainStamina then
                sprintHandler = mod
            end
        end
        if staminaDrainer and sprintHandler then break end
    end
end

-- Godmode logic
local godConnection
local lastHealth = 100

local function enableGodmode()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    lastHealth = humanoid.Health
    godConnection = humanoid.HealthChanged:Connect(function(newHealth)
        if newHealth < lastHealth then
            humanoid.Health = lastHealth
        else
            lastHealth = newHealth
        end
    end)
end

local function disableGodmode()
    if godConnection then
        godConnection:Disconnect()
        godConnection = nil
    end
end

-- Infinite Stamina logic
local originalGetStaminaAfterDrain = staminaDrainer and staminaDrainer.GetStaminaAfterDrain
local originalDrainStamina = sprintHandler and sprintHandler.drainStamina

local function enableStaminaPatch()
    if staminaDrainer and staminaDrainer.GetStaminaAfterDrain then
        staminaDrainer.GetStaminaAfterDrain = function(_, _, _, _, maxStamina)
            return maxStamina
        end
    end
    if sprintHandler and sprintHandler.drainStamina then
        sprintHandler.drainStamina = function(...) end
    end
    if staminaDrainer and staminaDrainer.CancelExpires then
        pcall(staminaDrainer.CancelExpires)
    end
end

local function disableStaminaPatch()
    if staminaDrainer and originalGetStaminaAfterDrain then
        staminaDrainer.GetStaminaAfterDrain = originalGetStaminaAfterDrain
    end
    if sprintHandler and originalDrainStamina then
        sprintHandler.drainStamina = originalDrainStamina
    end
end

-- GUI Toggles using Fluent
local GodToggle = Tabs.Main:AddToggle("Godmode", {Title = "Godmode", Default = false})
GodToggle:OnChanged(function(state)
    if state then
        enableGodmode()
    else
        disableGodmode()
    end
end)

local StaminaToggle = Tabs.Main:AddToggle("InfStam", {Title = "Infinite Stamina", Default = false})
StaminaToggle:OnChanged(function(state)
    if state then
        enableStaminaPatch()
    else
        disableStaminaPatch()
    end
end)

-- Optional: Auto-notify
Fluent:Notify({
    Title = "SewhSkids",
    Content = "The script has been loaded.",
    Duration = 8
})

-- Fluent Addons
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
