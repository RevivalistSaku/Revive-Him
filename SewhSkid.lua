if not game:IsLoaded() then game.Loaded:Wait() end
local a = game:GetService("ReplicatedStorage")
local b, c = nil, nil

for _, d in ipairs(a:GetDescendants()) do
	if d:IsA("ModuleScript") then
		local e = d.Name:lower()
		if not b and (e:find("staminadrain") or e:find("module_6_upvr")) then
			local f, g = pcall(require, d)
			if f and type(g) == "table" and g.GetStaminaAfterDrain then
				b = g
			end
		elseif not c and (e:find("sprint") or e:find("module_8_upvr")) then
			local f, g = pcall(require, d)
			if f and type(g) == "table" and g.initialize and g.drainStamina then
				c = g
			end
		end
		if b and c then break end
	end
end

if b and b.GetStaminaAfterDrain then
	b.GetStaminaAfterDrain = function(_, _, _, _, j) return j end
end

if c and c.drainStamina then
	c.drainStamina = function() end
end

if b and b.CancelExpires then
	pcall(b.CancelExpires)
end

if b and b.GetDrainer then
	local k = b.GetDrainer("BaseDrain")
	if k then
		k.Amount = 0
	end
end
