local a=game:GetService("Players")
local b=a.LocalPlayer
local c=game:GetService("ReplicatedStorage")
local d=nil
local e=nil
for _,f in ipairs(c:GetDescendants())do
    if f:IsA("ModuleScript")then
        local g=f.Name:lower()
        if(not d and(g:find("staminadrain")or g:find("module_6_upvr")))then
            local h,i=pcall(require,f)
            if h and type(i)=="table"and i.GetStaminaAfterDrain then d=i end
        elseif(not e and(g:find("sprint")or g:find("module_8_upvr")))then
            local j,k=pcall(require,f)
            if j and type(k)=="table"and k.initialize and k.drainStamina then e=k end
        end
        if d and e then break end
    end
end

local l=false
local m
local n

local function o()
    local p=b.Character or b.CharacterAdded:Wait()
    local q=p:FindFirstChildOfClass("Humanoid")
    if not q then return end
    n=q.Health
    m=q.HealthChanged:Connect(function(r)
        if r<n then q.Health=n else n=r end
    end)
end

local function s()
    if m then
        m:Disconnect()
        m=nil
    end
end

local t=false

local function u()
    if d and d.GetStaminaAfterDrain then
        d.GetStaminaAfterDrain=function(_,_,_,_,v)return v end
    end
    if e and e.drainStamina then
        e.drainStamina=function(...)end
    end
    if d and d.CancelExpires then
        pcall(d.CancelExpires)
    end
end

local w=d and d.GetStaminaAfterDrain
local x=e and e.drainStamina

local function y()
    if d and w then d.GetStaminaAfterDrain=w end
    if e and x then e.drainStamina=x end
end

local z=Instance.new("ScreenGui")
z.Name="FeatureToggleGui"
z.ResetOnSpawn=false
z.Parent=b:WaitForChild("PlayerGui")

local A=Instance.new("TextButton")
A.Size=UDim2.new(0,120,0,35)
A.Position=UDim2.new(0.5,-60,0,10)
A.AnchorPoint=Vector2.new(0.5,0)
A.Text="Show Features"
A.BackgroundColor3=Color3.fromRGB(35,35,35)
A.TextColor3=Color3.new(1,1,1)
A.Parent=z

local B=Instance.new("Frame")
B.Size=UDim2.new(0,200,0,100)
B.Position=UDim2.new(0.5,-100,0,50)
B.AnchorPoint=Vector2.new(0.5,0)
B.BackgroundColor3=Color3.fromRGB(25,25,25)
B.Visible=false
B.Parent=z

local C=Instance.new("TextButton")
C.Size=UDim2.new(1,-20,0,40)
C.Position=UDim2.new(0,10,0,10)
C.Text="Godmode OFF"
C.BackgroundColor3=Color3.fromRGB(50,50,50)
C.TextColor3=Color3.new(1,1,1)
C.Parent=B

local D=Instance.new("TextButton")
D.Size=UDim2.new(1,-20,0,40)
D.Position=UDim2.new(0,10,0,55)
D.Text="Infinite Stamina OFF"
D.BackgroundColor3=Color3.fromRGB(50,50,50)
D.TextColor3=Color3.new(1,1,1)
D.Parent=B

A.MouseButton1Click:Connect(function()
    B.Visible=not B.Visible
    A.Text=B.Visible and"Hide Features"or"Show Features"
end)

C.MouseButton1Click:Connect(function()
    l=not l
    if l then
        o()
        C.Text="Godmode ON"
        C.BackgroundColor3=Color3.fromRGB(0,170,0)
    else
        s()
        C.Text="Godmode OFF"
        C.BackgroundColor3=Color3.fromRGB(50,50,50)
    end
end)

D.MouseButton1Click:Connect(function()
    t=not t
    if t then
        u()
        D.Text="Infinite Stamina ON"
        D.BackgroundColor3=Color3.fromRGB(0,170,0)
    else
        y()
        D.Text="Infinite Stamina OFF"
        D.BackgroundColor3=Color3.fromRGB(50,50,50)
    end
end)
