-- ============================================
-- REMOTE SCANNER & KILL AURA FIX
-- Version: 5.0 (Full Debug + Auto-Detect)
-- ============================================

warn("=== REMOTE SCANNER V5.0 ===")
print("Script started at: " .. os.time())

repeat task.wait(0.1) until game:IsLoaded() and game:GetService("Players").LocalPlayer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ============================================
-- PHẦN 1: SCANNER REMOTE TOÀN DIỆN
-- ============================================
warn("=== SCANNING REMOTES ===")

local function ScanRemote(container, path)
    path = path or ""
    for _, child in ipairs(container:GetChildren()) do
        local fullPath = path .. "/" .. child.Name
        if child:IsA("RemoteEvent") then
            warn("[REMOTE_EVENT] " .. fullPath)
            print("RemoteEvent found: " .. fullPath)
        elseif child:IsA("RemoteFunction") then
            warn("[REMOTE_FUNCTION] " .. fullPath)
            print("RemoteFunction found: " .. fullPath)
        elseif child:IsA("BindableEvent") then
            warn("[BINDABLE_EVENT] " .. fullPath)
        elseif child:IsA("BindableFunction") then
            warn("[BINDABLE_FUNCTION] " .. fullPath)
        end
        if child:IsA("Instance") and child:GetChildren() then
            ScanRemote(child, fullPath)
        end
    end
end

-- Scan toàn bộ game
warn("Scanning ReplicatedStorage...")
ScanRemote(ReplicatedStorage, "ReplicatedStorage")

warn("Scanning workspace...")
ScanRemote(workspace, "workspace")

warn("Scanning Players...")
for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        ScanRemote(player.Character, player.Name .. ".Character")
    end
end

-- ============================================
-- PHẦN 2: TÌM ZOMBIE NPC
-- ============================================
warn("=== SCANNING ZOMBIE NPC ===")

local ZombieList = {}
local function FindAllZombies()
    ZombieList = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            local humanoid = obj:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                table.insert(ZombieList, obj)
                warn("[ZOMBIE_FOUND] " .. obj.Name .. " | Health: " .. humanoid.Health)
            end
        end
    end
    return ZombieList
end

FindAllZombies()

-- ============================================
-- PHẦN 3: KILL AURA ENGINE (FIXED)
-- ============================================
warn("=== KILL AURA ENGINE STARTING ===")

local CONFIG = {
    Range = 50,
    Damage = 9999,
    AttackSpeed = 0.05,
    TargetLock = true,
    Enabled = true
}

local Target = nil
local AttackCooldown = 0

-- Hàm gây sát thương tối ưu
local function DealDamage(target)
    if not target then return false end
    local char = target.Character or target
    if not char then return false end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    local success = false
    
    -- === PHƯƠNG THỨC 1: TAKE DAMAGE ===
    pcall(function()
        humanoid:TakeDamage(CONFIG.Damage)
        success = true
    end)
    
    -- === PHƯƠNG THỨC 2: SET HEALTH ===
    if not success then
        pcall(function()
            humanoid.Health = humanoid.Health - CONFIG.Damage
            if humanoid.Health <= 0 then humanoid.Health = 0 end
            success = true
        end)
    end
    
    -- === PHƯƠNG THỨC 3: BREAK JOINTS ===
    if not success then
        pcall(function()
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part:BreakJoints()
                end
            end
            humanoid.Health = 0
            success = true
        end)
    end
    
    -- === PHƯƠNG THỨC 4: TÌM REMOTE TỰ ĐỘNG ===
    if not success then
        -- Tìm Remote trong ReplicatedStorage
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(char, CONFIG.Damage)
                    else
                        remote:InvokeServer(char, CONFIG.Damage)
                    end
                    success = true
                end)
                if success then break end
            end
        end
    end
    
    -- Hiệu ứng
    pcall(function()
        local part = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        if part then
            local bp = Instance.new("Part")
            bp.Size = Vector3.new(2, 2, 2)
            bp.CFrame = part.CFrame
            bp.BrickColor = BrickColor.new("Bright red")
            bp.Material = Enum.Material.Neon
            bp.Anchored = true
            bp.CanCollide = false
            bp.Transparency = 0.3
            game:GetService("Debris"):AddItem(bp, 0.2)
        end
    end)
    
    return success
end

-- Hàm tìm zombie gần nhất
local function GetClosestZombie()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local pos = root.Position
    
    local closest, minDist = nil, math.huge
    
    -- Quét NPC Zombie
    for _, zombie in ipairs(FindAllZombies()) do
        if zombie and zombie:FindFirstChild("Humanoid") then
            local humanoid = zombie:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local zRoot = zombie:FindFirstChild("HumanoidRootPart") or zombie:FindFirstChild("Head")
                if zRoot then
                    local dist = (zRoot.Position - pos).Magnitude
                    if dist < CONFIG.Range and dist < minDist then
                        minDist = dist
                        closest = zombie
                    end
                end
            end
        end
    end
    
    -- Quét Player (nếu có PvP)
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

-- Vòng lặp chính
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
    
    -- Tìm target
    if not Target then
        Target = GetClosestZombie()
    else
        -- Kiểm tra target
        local tChar = Target.Character or Target
        if not tChar then
            Target = nil
            return
        end
        local tHumanoid = tChar:FindFirstChild("Humanoid")
        if not tHumanoid or tHumanoid.Health <= 0 then
            Target = nil
            return
        end
        local tRoot = tChar:FindFirstChild("HumanoidRootPart") or tChar:FindFirstChild("Head")
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
            local tChar = Target.Character or Target
            if tChar then
                local tRoot = tChar:FindFirstChild("HumanoidRootPart") or tChar:FindFirstChild("Head")
                if tRoot then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, tRoot.Position)
                end
            end
        end
        
        if tick() - AttackCooldown >= CONFIG.AttackSpeed then
            local success = DealDamage(Target)
            if success then
                AttackCooldown = tick()
            else
                -- Nếu không gây được sát thương, thử remote khác
                warn("Attack failed on: " .. tostring(Target.Name))
            end
        end
    end
end

-- ============================================
-- PHẦN 4: UI ĐƠN GIẢN
-- ============================================
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KillAuraUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5)
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 240)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -120)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 32)
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, 0, 1, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "⚡ Kill Aura v5.0"
    TitleText.TextColor3 = Color3.fromRGB(255, 80, 80)
    TitleText.TextScaled = true
    TitleText.Font = Enum.Font.GothamBold
    TitleText.Parent = TitleBar
    
    local function AddLabel(text, y)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 24)
        label.Position = UDim2.new(0, 10, 0, y)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 200, 215)
        label.TextScaled = true
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = MainFrame
        return label
    end
    
    local function AddToggle(text, default, callback, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 28)
        frame.Position = UDim2.new(0, 10, 0, y)
        frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        frame.BorderSizePixel = 0
        frame.Parent = MainFrame
        
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
        btn.Position = UDim2.new(1, -44, 0, 3)
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
    
    local y = 40
    AddLabel("Zombies found: " .. #ZombieList, y); y = y + 28
    AddToggle("Bật Kill Aura", true, function(val) CONFIG.Enabled = val end, y); y = y + 32
    AddToggle("Khóa mục tiêu", true, function(val) CONFIG.TargetLock = val end, y)
    
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
end

-- ============================================
-- INIT
-- ============================================
CreateUI()

RunService.Heartbeat:Connect(UpdateKillAura)

LocalPlayer.CharacterAdded:Connect(function()
    Target = nil
    task.wait(1)
    FindAllZombies()
end)

-- Force scan mỗi 5 giây
task.spawn(function()
    while task.wait(5) do
        FindAllZombies()
    end
end)

warn("=== KILL AURA V5.0 LOADED ===")
print("Zombies found: " .. #ZombieList)
print("Range: " .. CONFIG.Range)
print("Damage: " .. CONFIG.Damage)
print("Status: Running")

-- In hướng dẫn
print("=== HƯỚNG DẪN ===")
print("1. Nếu có remote: script tự động phát hiện và dùng")
print("2. Nếu không có remote: script dùng Humanoid:TakeDamage()")
print("3. Kiểm tra Output để xem danh sách Remote đã scan")
print("4. Nếu vẫn không kill được, gửi tôi danh sách Remote đã scan")
