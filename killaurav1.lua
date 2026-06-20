-- ============================================
-- Kill Aura Script for Zombie Rush Survival
-- Version: 4.0 (Executor Real - Debug + Fallback)
-- ============================================

-- === FORCE DEBUG OUTPUT ===
warn("=== KILL AURA V4.0 LOADING ===")
print("Script started at: " .. os.time())

-- === CRITICAL FIX: ĐỢI GAME LOAD ===
repeat
    task.wait(0.1)
until game:IsLoaded() and game:GetService("Players").LocalPlayer

warn("Game loaded, LocalPlayer found")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- === FIX: TẠO UI AN TOÀN ===
local function CreateSafeUI()
    local success, result = pcall(function()
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "KillAuraUI"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5)
        return ScreenGui
    end)
    if success then
        warn("UI created successfully")
        return result
    else
        warn("UI creation failed: " .. tostring(result))
        return nil
    end
end

local ScreenGui = CreateSafeUI()
if not ScreenGui then
    warn("Falling back to no-UI mode")
end

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

-- === BUILD UI (CHỈ KHI CÓ GUI) ===
if ScreenGui then
    warn("Building UI...")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 320, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 36)
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -50, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "⚡ Kill Aura v4.0"
    TitleText.TextColor3 = Color3.fromRGB(255, 80, 80)
    TitleText.TextScaled = true
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 26, 0, 26)
    CloseBtn.Position = UDim2.new(1, -32, 0, 5)
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

    -- Content
    local function CreateLabel(text, parent, y)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 24)
        label.Position = UDim2.new(0, 10, 0, y)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 200, 215)
        label.TextScaled = true
        label.Font = Enum.Font.GothamSemibold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = parent
        return label
    end

    local function CreateToggle(text, default, callback, parent, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 30)
        frame.Position = UDim2.new(0, 10, 0, y)
        frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        frame.BorderSizePixel = 0
        frame.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -50, 1, 0)
        label.Position = UDim2.new(0, 6, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(220, 220, 235)
        label.TextScaled = true
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 40, 0, 22)
        btn.Position = UDim2.new(1, -44, 0, 4)
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
        return frame
    end

    local function CreateSlider(text, min, max, default, callback, parent, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 44)
        frame.Position = UDim2.new(0, 10, 0, y)
        frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        frame.BorderSizePixel = 0
        frame.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -50, 0, 18)
        label.Position = UDim2.new(0, 4, 0, 2)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. tostring(default)
        label.TextColor3 = Color3.fromRGB(220, 220, 235)
        label.TextScaled = true
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local valueDisplay = Instance.new("TextLabel")
        valueDisplay.Size = UDim2.new(0, 36, 0, 18)
        valueDisplay.Position = UDim2.new(1, -40, 0, 2)
        valueDisplay.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        valueDisplay.BorderSizePixel = 0
        valueDisplay.Text = tostring(default)
        valueDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
        valueDisplay.TextScaled = true
        valueDisplay.Font = Enum.Font.GothamBold
        valueDisplay.Parent = frame

        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(1, -8, 0, 6)
        slider.Position = UDim2.new(0, 4, 0, 28)
        slider.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
        slider.BorderSizePixel = 0
        slider.Parent = frame

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
        fill.BorderSizePixel = 0
        fill.Parent = slider

        local drag = Instance.new("TextButton")
        drag.Size = UDim2.new(0, 14, 0, 14)
        drag.Position = UDim2.new((default - min) / (max - min), -7, 0, -4)
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
                drag.Position = UDim2.new(pos, -7, 0, -4)
                valueDisplay.Text = tostring(value)
                label.Text = text .. ": " .. tostring(value)
                callback(value)
            end
        end)
        return frame
    end

    -- UI Elements
    local y = 45
    CreateLabel("═══ ĐIỀU KHIỂN ═══", MainFrame, y); y = y + 28
    CreateToggle("Bật/Tắt Kill Aura", true, function(val) CONFIG.Enabled = val end, MainFrame, y); y = y + 34
    CreateLabel("═══ CẤU HÌNH ═══", MainFrame, y); y = y + 28
    CreateSlider("Phạm vi", 5, 80, 30, function(val) CONFIG.Range = val end, MainFrame, y); y = y + 48
    CreateSlider("Tốc độ (s)", 0.01, 0.5, 0.05, function(val) CONFIG.AttackSpeed = val end, MainFrame, y); y = y + 48
    CreateToggle("Khóa mục tiêu", true, function(val) CONFIG.TargetLock = val end, MainFrame, y); y = y + 34
    CreateToggle("One Hit Kill", true, function(val) 
        CONFIG.OneHitKill = val
        CONFIG.Damage = val and 9999 or 25
    end, MainFrame, y)

    -- Drag
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
    
    warn("UI built successfully")
end

-- === KILL AURA ENGINE ===
warn("Starting Kill Aura Engine...")

local Target = nil
local AttackCooldown = 0

local function GetClosestZombie()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local pos = root.Position
    
    local closest, minDist = nil, math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local pRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if pRoot then
                    local dist = (pRoot.Position - pos).Magnitude
                    if dist < CONFIG.Range and dist < minDist then
                        minDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    
    return closest
end

local function AttackTarget(target)
    if not target then return end
    local char = target.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    
    local hitPart = char:FindFirstChild(CONFIG.HitboxPart) or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    if not hitPart then return end
    
    -- Gây sát thương trực tiếp
    local success = pcall(function()
        -- Method 1: Humanoid TakeDamage
        humanoid:TakeDamage(CONFIG.Damage)
    end)
    
    if not success then
        pcall(function()
            -- Method 2: Set Health
            humanoid.Health = math.max(0, humanoid.Health - CONFIG.Damage)
        end)
    end
    
    -- Method 3: Remote (nếu có)
    pcall(function()
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("DamageRemote")
        if remote then
            remote:FireServer(hitPart, CONFIG.Damage)
        end
    end)
    
    -- Hiệu ứng
    pcall(function()
        local bp = Instance.new("Part")
        bp.Size = Vector3.new(1.5, 1.5, 1.5)
        bp.CFrame = hitPart.CFrame
        bp.BrickColor = BrickColor.new("Bright red")
        bp.Material = Enum.Material.Neon
        bp.Anchored = true
        bp.CanCollide = false
        bp.Transparency = 0.4
        game:GetService("Debris"):AddItem(bp, 0.15)
    end)
end

local function UpdateKillAura()
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
        Target = GetClosestZombie()
    else
        -- Kiểm tra target
        local tChar = Target.Character
        if not tChar then
            Target = nil
            return
        end
        local tHumanoid = tChar:FindFirstChild("Humanoid")
        if not tHumanoid or tHumanoid.Health <= 0 then
            Target = nil
            return
        end
        local tRoot = tChar:FindFirstChild("HumanoidRootPart")
        if tRoot then
            if (tRoot.Position - root.Position).Magnitude > CONFIG.Range then
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
            local tChar = Target.Character
            if tChar then
                local tRoot = tChar:FindFirstChild("HumanoidRootPart") or tChar:FindFirstChild("Head")
                if tRoot then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, tRoot.Position)
                end
            end
        end
        
        if tick() - AttackCooldown >= CONFIG.AttackSpeed then
            AttackTarget(Target)
            AttackCooldown = tick()
        end
    end
end

-- === VÒNG LẶP CHÍNH ===
RunService.Heartbeat:Connect(UpdateKillAura)

-- Reset target khi respawn
LocalPlayer.CharacterAdded:Connect(function()
    Target = nil
    warn("Player respawned, target reset")
end)

-- === DEBUG OUTPUT ===
warn("=== KILL AURA V4.0 LOADED SUCCESSFULLY ===")
print("Status: Running")
print("Range: " .. CONFIG.Range)
print("Damage: " .. CONFIG.Damage)
print("Speed: " .. CONFIG.AttackSpeed)
print("One Hit Kill: " .. tostring(CONFIG.OneHitKill))
print("UI: " .. (ScreenGui and "Visible" or "Disabled"))

-- Force output
task.wait(0.5)
warn("If you see this, script is working!")
