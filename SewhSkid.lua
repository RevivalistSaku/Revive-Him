-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Create main window
local Window = Rayfield:CreateWindow({
   Name = "SewhSkids",
   Icon = 0,
   LoadingTitle = "Rayfield Interface Suite",
   LoadingSubtitle = "by Sleafyness",
   Theme = "Default",
   ToggleUIKeybind = "K",

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "SewhSkidsHub"
   },

   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },

   KeySystem = false,
   KeySettings = {
      Title = "SewhSkids",
      Subtitle = "Key System",
      Note = "",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Hello"}
   }
})

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Find stamina modules
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
        if staminaDrainer and sprintHandler then
            break
        end
    end
end

-- Godmode logic
local godmodeEnabled = false
local godConnection
local lastHealth

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

-- Infinite stamina logic
local staminaEnabled = false
local originalGetStaminaAfterDrain = staminaDrainer and staminaDrainer.GetStaminaAfterDrain
local originalDrainStamina = sprintHandler and sprintHandler.drainStamina

local function enableStaminaPatch()
    if staminaDrainer and staminaDrainer.GetStaminaAfterDrain then
        staminaDrainer.GetStaminaAfterDrain = function(identifier, x2, x3, isActive, maxStamina)
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

-- Create tab and section
local Tab = Window:CreateTab("Main", "rewind")
local Section = Tab:CreateSection("Features")

-- Godmode toggle using Rayfield
Tab:CreateToggle({
   Name = "Godmode",
   CurrentValue = false,
   Callback = function(Value)
      godmodeEnabled = Value
      if Value then
         enableGodmode()
      else
         disableGodmode()
      end
   end,
})

-- Infinite Stamina toggle using Rayfield
Tab:CreateToggle({
   Name = "Infinite Stamina",
   CurrentValue = false,
   Callback = function(Value)
      staminaEnabled = Value
      if Value then
         enableStaminaPatch()
      else
         disableStaminaPatch()
      end
   end,
})
