-- ============================================
-- Kill Aura Script for Zombie Rush Survival
-- Version: 3.0 (Executor Real - 9999 Damage)
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- === CONFIGURATION ===
local CONFIG = {
    Range = 30,
    Damage = 9999,
    AttackSpeed = 0.05,
    TargetLock = true,
    HitboxPart = "Head",
    Enabled = true,
    OneHitKill = true
}

-- === CUSTOM UI ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KillAuraUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 460)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Shadow
local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.7
Shadow.BorderSizePixel = 0
Shadow.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -60, 1, 0)
TitleText.Position = UDim2.new(0, 12, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "⚡ Kill Aura v3.0 | 9999 DMG"
TitleText.TextColor3 = Color3.fromRGB(255, 80, 80)
TitleText.TextScaled = true
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -36, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Scroll Container
local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Size = UDim2.new(1, -20, 1, -60)
ScrollContainer.Position = UDim2.new(0, 10, 0, 50)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.BorderSizePixel = 0
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollContainer.ScrollBarThickness = 4
ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 95)
ScrollContainer.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 8)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = ScrollContainer

-- === UI HELPER FUNCTIONS ===
local function CreateLabel(text, order, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 26)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(200, 200, 215)
    label.TextScaled = true
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = order
    label.Parent = ScrollContainer
    return label
end

local function CreateToggle(text, default, callback, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    frame.Parent = ScrollContainer

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 235)
    label.TextScaled = true
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 44, 0, 26)
    btn.Position = UDim2.new(1, -50, 0, 4)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(80, 80, 95)
    btn.BorderSizePixel = 0
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(80, 80, 95)
        btn.Text = state and "ON" or "OFF"
        callback(state)
    end)
    return btn
end

local function CreateSlider(text, min, max, default, callback, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 52)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    frame.Parent = ScrollContainer

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -8, 0, 22)
    label.Position = UDim2.new(0, 4, 0, 2)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(220, 220, 235)
    label.TextScaled = true
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local valueDisplay = Instance.new("TextLabel")
    valueDisplay.Size = UDim2.new(0, 44, 0, 22)
    valueDisplay.Position = UDim2.new(1, -48, 0, 2)
    valueDisplay.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    valueDisplay.BorderSizePixel = 0
    valueDisplay.Text = tostring(default)
    valueDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueDisplay.TextScaled = true
    valueDisplay.Font = Enum.Font.GothamBold
    valueDisplay.Parent = frame

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, -8, 0, 8)
    slider.Position = UDim2.new(0, 4, 0, 34)
    slider.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
    slider.BorderSizePixel = 0
    slider.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
    fill.BorderSizePixel = 0
    fill.Parent = slider

    local drag = Instance.new("TextButton")
    drag.Size = UDim2.new(0, 18, 0, 18)
    drag.Position = UDim2.new((default - min) / (max - min), -9, 0, -5)
    drag.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    drag.BorderSizePixel = 0
    drag.Text = ""
    drag.Parent = slider

    local dragging = false
    drag.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    drag.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local value = math.round(min + pos * (max - min))
            fill.Size = UDim2.new(pos, 0, 1, 0)
            drag.Position = UDim2.new(pos, -9, 0, -5)
            valueDisplay.Text = tostring(value)
            label.Text = text .. ": " .. tostring(value)
            callback(value)
        end
    end)

    return {fill, drag, valueDisplay, label}
end

local function CreateDropdown(text, options, default, callback, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    frame.Parent = ScrollContainer

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -100, 1, 0)
    label.Position = UDim2.new(0, 4, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 235)
    label.TextScaled = true
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0, 94, 0, 30)
    dropdown.Position = UDim2.new(1, -98, 0, 4)
    dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    dropdown.BorderSizePixel = 0
    dropdown.Text = default
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.TextScaled = true
    dropdown.Font = Enum.Font.GothamBold
    dropdown.Parent = frame

    local state = default
    local index = 1
    for i, opt in ipairs(options) do
        if opt == default then index = i break end
    end

    dropdown.MouseButton1Click:Connect(function()
        index = index % #options + 1
        state = options[index]
        dropdown.Text = state
        callback(state)
    end)
    return dropdown
end

-- === BUILD UI ===
local order = 0
CreateLabel("═══ ĐIỀU KHIỂN ═══", order, Color3.fromRGB(255, 100, 100)); order = order + 1

local toggleBtn = CreateToggle("Bật/Tắt Kill Aura", true, function(val)
    CONFIG.Enabled = val
end, order); order = order + 1

CreateLabel("═══ CẤU HÌNH ═══", order, Color3.fromRGB(100, 200, 255)); order = order + 1

CreateSlider("Phạm vi (Range)", 5, 80, 30, function(val)
    CONFIG.Range = val
end, order); order = order + 1

CreateSlider("Tốc độ đánh (s)", 0.01, 0.5, 0.05, function(val)
    CONFIG.AttackSpeed = val
end, order); order = order + 1

CreateToggle("Khóa mục tiêu (Lock)", true, function(val)
    CONFIG.TargetLock = val
end, order); order = order + 1

CreateToggle("One Hit Kill (1 đòn chết)", true, function(val)
    CONFIG.OneHitKill = val
    CONFIG.Damage = val and 9999 or 25
end, order); order = order + 1

CreateDropdown("Bộ phận tấn công", {"Head", "HumanoidRootPart", "UpperTorso"}, "Head", function(val)
    CONFIG.HitboxPart = val
end, order); order = order + 1

-- Status display
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, 0, 0, 28)
statusFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
statusFrame.BorderSizePixel = 0
statusFrame.LayoutOrder = order
statusFrame.Parent = ScrollContainer

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "◆ Trạng thái: ĐANG KÍCH HOẠT ◆"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Parent = statusFrame

-- Update canvas size
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, order * 44 + 40)

-- === DRAG UI ===
local draggingUI = false
local dragStart, frameStart

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingUI = true
        dragStart = input.Position
        frameStart = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingUI and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingUI = false
    end
end)

-- === KILL AURA ENGINE (OPTIMIZED) ===
local KillAura = {}
local Target = nil
local AttackCooldown = 0
local ZombieCache = {}

function KillAura:GetClosestZombie()
    local closest, minDist = nil, math.huge
    local playerPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not playerPos then return nil end
    local pos = playerPos.Position
    
    -- Quét Players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (root.Position - pos).Magnitude
                    if dist < CONFIG.Range and dist < minDist then
                        minDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    
    -- Quét Zombie NPC (nếu có trong workspace)
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            local humanoid = obj:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
                if root then
                    local dist = (root.Position - pos).Magnitude
                    if dist < CONFIG.Range and dist < minDist then
                        minDist = dist
                        closest = obj
                    end
                end
            end
        end
    end
    
    return closest
end

function KillAura:Attack(target)
    if not target then return end
    local char = target.Character or target
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    
    local hitPart = char:FindFirstChild(CONFIG.HitboxPart) or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    if not hitPart then return end
    
    -- === PHƯƠNG THỨC GÂY SÁT THƯƠNG TỐI ƯU ===
    local success = false
    
    -- Method 1: Remote Event
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("DamageRemote")
    if remote then
        pcall(function()
            remote:FireServer(hitPart, CONFIG.Damage)
            success = true
        end)
    end
    
    -- Method 2: Remote Function
    if not success then
        local remoteFunc = game:GetService("ReplicatedStorage"):FindFirstChild("Damage")
        if remoteFunc then
            pcall(function()
                remoteFunc:InvokeServer(hitPart, CONFIG.Damage)
                success = true
            end)
        end
    end
    
    -- Method 3: Direct Humanoid Damage
    if not success then
        pcall(function()
            humanoid:TakeDamage(CONFIG.Damage)
            success = true
        end)
    end
    
    -- Method 4: Break Joints (kill instantly)
    if not success and CONFIG.OneHitKill then
        pcall(function()
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part:BreakJoints()
                end
            end
            humanoid.Health = 0
            success = true
        end)
    end
    
    -- Method 5: Set Health to 0
    if not success then
        pcall(function()
            humanoid.Health = 0
        end)
    end
    
    -- Visual Effect
    pcall(function()
        local bp = Instance.new("Part")
        bp.Size = Vector3.new(2, 2, 2)
        bp.CFrame = hitPart.CFrame
        bp.BrickColor = BrickColor.new("Bright red")
        bp.Material = Enum.Material.Neon
        bp.Anchored = true
        bp.CanCollide = false
        bp.Transparency = 0.3
        game:GetService("Debris"):AddItem(bp, 0.2)
    end)
end

function KillAura:Update()
    if not CONFIG.Enabled then
        Target = nil
        return
    end
    
    local char = LocalPlayer.Character
    if not char then Target = nil; return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then Target = nil; return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then Target = nil; return end
    
    -- Tìm target mới
    if not Target then
        Target = KillAura:GetClosestZombie()
    else
        -- Kiểm tra target còn sống
        local targetChar = Target.Character or Target
        if not targetChar then
            Target = nil
            return
        end
        local targetHumanoid = targetChar:FindFirstChild("Humanoid")
        if not targetHumanoid or targetHumanoid.Health <= 0 then
            Target = nil
            return
        end
        -- Kiểm tra khoảng cách
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Head")
        if targetRoot then
            local dist = (targetRoot.Position - root.Position).Magnitude
            if dist > CONFIG.Range then
                Target = nil
                return
            end
        else
            Target = nil
            return
        end
    end
    
    -- Tấn công
    if Target then
        if CONFIG.TargetLock then
            local targetChar = Target.Character or Target
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Head")
            if targetRoot then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetRoot.Position)
            end
        end
        
        if tick() - AttackCooldown >= CONFIG.AttackSpeed then
            KillAura:Attack(Target)
            AttackCooldown = tick()
        end
    end
end

-- === INIT ===
RunService.Heartbeat:Connect(function()
    KillAura:Update()
end)

-- Reset target khi player respawn
LocalPlayer.CharacterAdded:Connect(function()
    Target = nil
end)

print("Kill Aura v3.0 loaded | 9999 DAMAGE | UI Custom")
print("Lệnh điều khiển: killaura_toggle (bật/tắt)")
print("Nhấn ✕ để ẩn/hiện UI")
