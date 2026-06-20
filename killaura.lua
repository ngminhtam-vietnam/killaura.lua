-- ============================================
-- Kill Aura Script for Zombie Rush Survival
-- Version: 1.0
-- Compatible: Roblox (Executors: Synapse X, Krnl, Script-Ware)
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- === CONFIGURATION ===
local CONFIG = {
    Range = 20,                    -- Bán kính tấn công (studs)
    Damage = 25,                   -- Sát thương mỗi đòn
    AttackSpeed = 0.1,             -- Tốc độ đánh (giây)
    TargetLock = true,            -- Tự động xoay camera về mục tiêu
    HitboxPart = "Head"           -- Bộ phận tấn công (Head/HumanoidRootPart)
}

-- === UI (Rayfield) ===
local Rayfield
local function LoadRayfield()
    if not game:IsLoaded() then game.Loaded:Wait() end
    local success, rf = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua"))()
    end)
    if success then Rayfield = rf else
        warn("Không tải được Rayfield, sử dụng UI mặc định.")
        return nil
    end
end

-- === KILL AURA ENGINE ===
local KillAura = {}
local Target = nil
local AttackCooldown = 0
local Enabled = true

-- Lấy zombie gần nhất
function KillAura:GetClosestZombie()
    local closest, minDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.Health > 0 then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if dist < CONFIG.Range and dist < minDist then
                        minDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    -- Thêm zombie NPC nếu có (tùy game)
    -- for _, zombie in ipairs(workspace.Zombies:GetChildren()) do ... end
    return closest
end

-- Tấn công mục tiêu
function KillAura:Attack(target)
    if not target or not target.Character then return end
    local humanoid = target.Character:FindFirstChild("Humanoid")
    local hitPart = target.Character:FindFirstChild(CONFIG.HitboxPart) or target.Character:FindFirstChild("HumanoidRootPart")
    if humanoid and humanoid.Health > 0 and hitPart then
        -- Mô phỏng đòn đánh (gọi hàm damage của game)
        -- Thường game có RemoteEvent hoặc hàm TakeDamage
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("DamageRemote")
        if remote then
            remote:FireServer(hitPart, CONFIG.Damage)
        else
            -- Fallback: gây sát thương trực tiếp (nếu game cho phép)
            humanoid:TakeDamage(CONFIG.Damage)
        end
        -- Hiệu ứng (tùy chọn)
        if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local bp = Instance.new("Part")
            bp.Size = Vector3.new(1,1,1)
            bp.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3)
            bp.BrickColor = BrickColor.new("Bright red")
            bp.Material = Enum.Material.Neon
            bp.Anchored = true
            bp.CanCollide = false
            game:GetService("Debris"):AddItem(bp, 0.2)
        end
    end
end

-- Vòng lặp chính
function KillAura:Update()
    if not Enabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Target = nil
        return
    end

    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        Target = nil
        return
    end

    -- Tìm mục tiêu mới nếu chưa có hoặc target chết
    if not Target or not Target.Character or not Target.Character:FindFirstChild("Humanoid") or Target.Character.Humanoid.Health <= 0 then
        Target = KillAura:GetClosestZombie()
    end

    if Target and Target.Character then
        local root = Target.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local dist = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if dist > CONFIG.Range then
                Target = nil
                return
            end
            -- Xoay camera về target
            if CONFIG.TargetLock then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, root.Position)
            end
            -- Tấn công theo nhịp
            if tick() - AttackCooldown >= CONFIG.AttackSpeed then
                KillAura:Attack(Target)
                AttackCooldown = tick()
            end
        end
    end
end

-- === UI (Rayfield) ===
function CreateUI()
    if not Rayfield then return end
    local Window = Rayfield:CreateWindow({
        Name = "Kill Aura - Zombie Rush",
        Icon = 0,
        LoadingTitle = "Loading...",
        LoadingSubtitle = "by palofsc",
        Theme = "Dark"
    })

    local MainTab = Window:CreateTab("Main", 4483362458)
    local Section = MainTab:CreateSection("Cấu hình Kill Aura")

    MainTab:CreateToggle({
        Name = "Bật/Tắt Kill Aura",
        Default = true,
        Callback = function(Value)
            Enabled = Value
        end
    })

    MainTab:CreateSlider({
        Name = "Phạm vi (Range)",
        Range = {5, 50},
        Increment = 1,
        Default = 20,
        Callback = function(Value)
            CONFIG.Range = Value
        end
    })

    MainTab:CreateSlider({
        Name = "Sát thương (Damage)",
        Range = {1, 100},
        Increment = 1,
        Default = 25,
        Callback = function(Value)
            CONFIG.Damage = Value
        end
    })

    MainTab:CreateSlider({
        Name = "Tốc độ đánh (giây)",
        Range = {0.05, 1},
        Increment = 0.05,
        Default = 0.1,
        Callback = function(Value)
            CONFIG.AttackSpeed = Value
        end
    })

    MainTab:CreateToggle({
        Name = "Khóa mục tiêu (Camera Lock)",
        Default = true,
        Callback = function(Value)
            CONFIG.TargetLock = Value
        end
    })

    MainTab:CreateDropdown({
        Name = "Bộ phận tấn công",
        Options = {"Head", "HumanoidRootPart"},
        Default = "Head",
        Callback = function(Value)
            CONFIG.HitboxPart = Value
        end
    })
end

-- === INIT ===
local function Init()
    LoadRayfield()
    CreateUI()
    -- Chạy vòng lặp
    RunService.Heartbeat:Connect(function()
        KillAura:Update()
    end)
    print("Kill Aura loaded. Command: killaura_toggle")
end

-- Khởi động
pcall(Init)

-- === COMMAND CONSOLE ===
local Commands = {
    killaura_toggle = function()
        Enabled = not Enabled
        print("Kill Aura: " .. tostring(Enabled))
    end,
    killaura_range = function(val)
        CONFIG.Range = tonumber(val) or 20
        print("Range = " .. CONFIG.Range)
    end
}
-- Lưu global để dùng qua console
_G.KillAuraCommands = Commands

-- === HƯỚNG DẪN COMMIT GITHUB ===
-- 1. Tạo file "killaura.lua" và dán code này.
-- 2. Tạo repository trên GitHub, upload file.
-- 3. Lấy raw URL: https://raw.githubusercontent.com/username/repo/branch/killaura.lua
-- 4. Dùng lệnh: loadstring(game:HttpGet("RAW_URL"))()
-- Lưu ý: Thay "username", "repo", "branch" bằng thông tin thực tế.
