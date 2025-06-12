-- 🛠 Wait for game to initialize
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Require the stamina drainer module
local staminaDrainer = nil
local sprintHandler = nil

-- Attempt to locate both modules in common paths
for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("ModuleScript") then
        local name = obj.Name:lower()
        if not staminaDrainer and (name:find("staminadrain") or name:find("module_6_upvr")) then
            local ok, mod = pcall(require, obj)
            if ok and type(mod) == "table" and mod.GetStaminaAfterDrain then
                staminaDrainer = mod
                print("[+] Found StaminaDrainer module:", obj:GetFullName())
            end
        elseif not sprintHandler and (name:find("sprint") or name:find("module_8_upvr")) then
            local ok, mod = pcall(require, obj)
            if ok and type(mod) == "table" and mod.initialize and mod.drainStamina then
                sprintHandler = mod
                print("[+] Found SprintHandler module:", obj:GetFullName())
            end
        end
        if staminaDrainer and sprintHandler then
            break
        end
    end
end

-- Ensure we found the modules
if not staminaDrainer then
    warn("[!] Could not find StaminaDrainer module. Stamina will still drain.")
end
if not sprintHandler then
    warn("[!] Could not find SprintHandler module. Some sprint logic may still apply.")
end

-- 1️⃣ Patch StaminaDrainer to disable drain completely
if staminaDrainer and staminaDrainer.GetStaminaAfterDrain then
    staminaDrainer.GetStaminaAfterDrain = function(identifier, x2, x3, isActive, maxStamina)
        return maxStamina  -- always full stamina
    end
    print("[+] Patched GetStaminaAfterDrain to always return max stamina.")
end

-- 2️⃣ Patch SprintHandler's drainStamina loop (safety override)
if sprintHandler and sprintHandler.drainStamina then
    sprintHandler.drainStamina = function(...) end
    print("[+] Nullified SprintHandler.drainStamina function.")
end

-- 3️⃣ Disable any existing active drain entries
if staminaDrainer and staminaDrainer.CancelExpires then
    pcall(staminaDrainer.CancelExpires)
    print("[+] Cancelled all existing stamina drain entries.")
end

-- 🪄 Optional: boost base stamina to insane
if staminaDrainer and staminaDrainer.GetDrainer then
    local drainer = staminaDrainer.GetDrainer("BaseDrain")
    if drainer then
        drainer.Amount = 0
    end
end

print("[✔] All stamina drain disabled!")
