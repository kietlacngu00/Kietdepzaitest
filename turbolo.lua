--[[
    Turbo Lite Hub V3 - FIXED
    Đã sửa lỗi không farm, thêm UI đầy đủ
--]]

-- ========================================
-- SERVICES
-- ========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer
local commE = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommE")
local commF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- ========================================
-- SAVE SYSTEM
-- ========================================
local FolderName = "Turbo Lite Hub"
local FileName = "Settings.json"
local FullPath = FolderName .. "/" .. FileName

if makefolder and not isfolder(FolderName) then makefolder(FolderName) end

_G.SaveData = _G.SaveData or {}

local function SaveSettings()
    if not writefile then return false end
    local success = pcall(function()
        writefile(FullPath, HttpService:JSONEncode(_G.SaveData))
    end)
    return success
end

local function LoadSettings()
    if not (isfile and isfile(FullPath)) then return false end
    local success, result = pcall(function()
        return HttpService:JSONDecode(readfile(FullPath))
    end)
    if success and result then _G.SaveData = result return true end
    return false
end

local function GetSetting(name, default)
    return _G.SaveData[name] ~= nil and _G.SaveData[name] or default
end

LoadSettings()

-- ========================================
-- GLOBALS (có lưu)
-- ========================================
_G.MobHeight = GetSetting("MobHeight", 30)
_G.BringRange = GetSetting("BringRange", 250)
_G.MaxBringMobs = GetSetting("MaxBringMobs", 15)
_G.SelectWeapon = GetSetting("SelectWeapon", "Melee")
_G.StartFarm = GetSetting("StartFarm", false)
_G.AcceptQuest = GetSetting("AcceptQuest", false)
_G.AutoKen = GetSetting("AutoKen", true)
_G.BringMobs = GetSetting("BringMobs", true)
_G.AutoAttack = GetSetting("AutoAttack", true)
_G.FarmMode = GetSetting("FarmMode", "Level") -- Level, Bone, Cake

-- ========================================
-- WORLD DETECTION
-- ========================================
local placeId = game.PlaceId
local World1 = placeId == 2753915549 or placeId == 85211729168715
local World2 = placeId == 4442272183 or placeId == 79091703265657
local World3 = placeId == 7449423635 or placeId == 100117331123089

if not (World1 or World2 or World3) then
    player:Kick("World not supported")
end

-- ========================================
-- UTILITIES
-- ========================================
local function HasKen()
    local char = player.Character
    return char and CollectionService:HasTag(char, "Ken")
end

local function EquipWeapon(weaponName)
    if not weaponName then return end
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local tool = player.Backpack:FindFirstChild(weaponName) or char:FindFirstChild(weaponName)
    if tool and tool.Parent ~= char then
        hum:EquipTool(tool)
    end
end

local function UseSkill(key)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.03)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end)
end

local function IsAlive(entity)
    local hum = entity and entity:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

local function TeleportTo(cframe)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and cframe then
        hrp.CFrame = cframe
    end
end

-- ========================================
-- AUTO KEN
-- ========================================
task.spawn(function()
    while _G.AutoKen do
        task.wait(0.3)
        if not HasKen() then
            pcall(function() commE:FireServer("Ken", true) end)
        end
    end
end)

-- ========================================
-- TEAM (chỉ set 1 lần)
-- ========================================
task.spawn(function()
    task.wait(2)
    if player.Team then
        if player.Team.Name ~= "Marines" then
            pcall(function() commF:InvokeServer("SetTeam", "Marines") end)
        end
    else
        pcall(function() commF:InvokeServer("SetTeam", "Marines") end)
    end
end)

-- ========================================
-- LIGHTING (full bright)
-- ========================================
Lighting.Ambient = Color3.new(0.695, 0.695, 0.695)
Lighting.Brightness = 2
Lighting.FogEnd = 9e9
Lighting.GlobalShadows = false
Lighting.ClockTime = 12

-- ========================================
-- QUEST DATA
-- ========================================
local QuestData = {}

if World1 then
    QuestData = {
        [1] = {Mon = "Bandit", Qname = "BanditQuest1", Qdata = 1, PosQ = CFrame.new(1045.96, 27, 1560.82), PosM = CFrame.new(1045.96, 27, 1560.82)},
        [15] = {Mon = "Gorilla", Qname = "JungleQuest", Qdata = 2, PosQ = CFrame.new(-1598.08, 35.55, 153.37), PosM = CFrame.new(-1129.88, 40.46, -525.42)},
        [30] = {Mon = "Pirate", Qname = "BuggyQuest1", Qdata = 1, PosQ = CFrame.new(-1141.07, 4.1, 3831.54), PosM = CFrame.new(-1103.51, 13.75, 3896.09)},
        [60] = {Mon = "Desert Bandit", Qname = "DesertQuest", Qdata = 1, PosQ = CFrame.new(894.48, 5.14, 4392.43), PosM = CFrame.new(924.79, 6.44, 4481.58)},
        [90] = {Mon = "Snow Bandit", Qname = "SnowQuest", Qdata = 1, PosQ = CFrame.new(1389.74, 88.15, -1298.9), PosM = CFrame.new(1354.34, 87.27, -1393.94)},
        [120] = {Mon = "Chief Petty Officer", Qname = "MarineQuest2", Qdata = 1, PosQ = CFrame.new(-5039.58, 27.35, 4324.68), PosM = CFrame.new(-4881.23, 22.65, 4273.75)},
        [150] = {Mon = "Sky Bandit", Qname = "SkyQuest", Qdata = 1, PosQ = CFrame.new(-4839.53, 716.36, -2619.44), PosM = CFrame.new(-4953.2, 295.74, -2899.22)},
        [190] = {Mon = "Prisoner", Qname = "PrisonerQuest", Qdata = 1, PosQ = CFrame.new(5308.93, 1.65, 475.12), PosM = CFrame.new(5098.97, -0.32, 474.23)},
        [250] = {Mon = "Toga Warrior", Qname = "ColosseumQuest", Qdata = 1, PosQ = CFrame.new(-1580.04, 6.35, -2986.47), PosM = CFrame.new(-1820.21, 51.68, -2740.66)},
        [300] = {Mon = "Military Soldier", Qname = "MagmaQuest", Qdata = 1, PosQ = CFrame.new(-5313.37, 10.95, 8515.29), PosM = CFrame.new(-5411.16, 11.08, 8454.29)},
        [375] = {Mon = "Fishman Warrior", Qname = "FishmanQuest", Qdata = 1, PosQ = CFrame.new(61122.65, 18.49, 1569.39), PosM = CFrame.new(60878.3, 18.48, 1543.75)},
        [450] = {Mon = "God's Guard", Qname = "SkyExp1Quest", Qdata = 1, PosQ = CFrame.new(-4721.88, 843.87, -1949.96), PosM = CFrame.new(-4710.04, 845.27, -1927.3)},
        [525] = {Mon = "Royal Squad", Qname = "SkyExp2Quest", Qdata = 1, PosQ = CFrame.new(-7906.81, 5634.66, -1411.99), PosM = CFrame.new(-7624.25, 5658.13, -1467.35)},
        [625] = {Mon = "Galley Pirate", Qname = "FountainQuest", Qdata = 1, PosQ = CFrame.new(5259.81, 37.35, 4050.02), PosM = CFrame.new(5551.02, 78.9, 3930.41)},
        [650] = {Mon = "Galley Captain", Qname = "FountainQuest", Qdata = 2, PosQ = CFrame.new(5259.81, 37.35, 4050.02), PosM = CFrame.new(5441.95, 42.5, 4950.09)},
    }
elseif World2 then
    QuestData = {
        [700] = {Mon = "Raider", Qname = "Area1Quest", Qdata = 1, PosQ = CFrame.new(-429.54, 71.76, 1836.18), PosM = CFrame.new(-728.32, 52.77, 2345.77)},
        [775] = {Mon = "Swan Pirate", Qname = "Area2Quest", Qdata = 1, PosQ = CFrame.new(638.43, 71.76, 918.28), PosM = CFrame.new(1068.66, 137.61, 1322.1)},
        [875] = {Mon = "Marine Lieutenant", Qname = "MarineQuest3", Qdata = 1, PosQ = CFrame.new(-2440.79, 71.71, -3216.06), PosM = CFrame.new(-2821.37, 75.89, -3070.08)},
        [950] = {Mon = "Zombie", Qname = "ZombieQuest", Qdata = 1, PosQ = CFrame.new(-5497.06, 47.59, -795.23), PosM = CFrame.new(-5657.77, 78.96, -928.68)},
        [1000] = {Mon = "Snow Trooper", Qname = "SnowMountainQuest", Qdata = 1, PosQ = CFrame.new(609.85, 400.11, -5372.25), PosM = CFrame.new(549.14, 427.38, -5563.69)},
        [1100] = {Mon = "Lab Subordinate", Qname = "IceSideQuest", Qdata = 1, PosQ = CFrame.new(-6064.06, 15.24, -4902.97), PosM = CFrame.new(-5707.47, 15.95, -4513.39)},
        [1175] = {Mon = "Magma Ninja", Qname = "FireSideQuest", Qdata = 1, PosQ = CFrame.new(-5428.03, 15.06, -5299.43), PosM = CFrame.new(-5449.67, 76.65, -5808.2)},
        [1250] = {Mon = "Ship Deckhand", Qname = "ShipQuest1", Qdata = 1, PosQ = CFrame.new(1037.8, 125.09, 32911.6), PosM = CFrame.new(1212.01, 150.79, 33059.24)},
        [1350] = {Mon = "Arctic Warrior", Qname = "FrostQuest", Qdata = 1, PosQ = CFrame.new(5667.65, 26.79, -6486.08), PosM = CFrame.new(5966.24, 62.97, -6179.38)},
        [1425] = {Mon = "Sea Soldier", Qname = "ForgottenQuest", Qdata = 1, PosQ = CFrame.new(-3054.44, 235.54, -10142.81), PosM = CFrame.new(-3028.22, 64.67, -9775.42)},
        [1450] = {Mon = "Water Fighter", Qname = "ForgottenQuest", Qdata = 2, PosQ = CFrame.new(-3054.44, 235.54, -10142.81), PosM = CFrame.new(-3352.9, 285.01, -10534.84)},
    }
elseif World3 then
    QuestData = {
        [1500] = {Mon = "Pirate Millionaire", Qname = "PiratePortQuest", Qdata = 1, PosQ = CFrame.new(-290.07, 42.9, 5581.59), PosM = CFrame.new(-246, 47.31, 5584.1)},
        [1575] = {Mon = "Dragon Crew Warrior", Qname = "DragonCrewQuest", Qdata = 1, PosQ = CFrame.new(6737.06, 127.41, -712.3), PosM = CFrame.new(6709.76, 52.34, -1139.02)},
        [1625] = {Mon = "Hydra Enforcer", Qname = "VenomCrewQuest", Qdata = 1, PosQ = CFrame.new(5206.4, 1004.1, 748.35), PosM = CFrame.new(4547.11, 1003.1, 334.19)},
        [1700] = {Mon = "Marine Commodore", Qname = "MarineTreeIsland", Qdata = 1, PosQ = CFrame.new(2180.54, 27.81, -6741.54), PosM = CFrame.new(2286, 73.13, -7159.8)},
        [1775] = {Mon = "Fishman Raider", Qname = "DeepForestIsland3", Qdata = 1, PosQ = CFrame.new(-10581.65, 330.87, -8761.18), PosM = CFrame.new(-10407.52, 331.76, -8368.51)},
        [1825] = {Mon = "Forest Pirate", Qname = "DeepForestIsland", Qdata = 1, PosQ = CFrame.new(-13234.04, 331.48, -7625.4), PosM = CFrame.new(-13274.47, 332.37, -7769.58)},
        [1900] = {Mon = "Jungle Pirate", Qname = "DeepForestIsland2", Qdata = 1, PosQ = CFrame.new(-12680.38, 389.97, -9902.01), PosM = CFrame.new(-12256.16, 331.73, -10485.83)},
        [1975] = {Mon = "Reborn Skeleton", Qname = "HauntedQuest1", Qdata = 1, PosQ = CFrame.new(-9479.21, 141.21, 5566.09), PosM = CFrame.new(-8763.72, 165.72, 6159.86)},
        [2025] = {Mon = "Demonic Soul", Qname = "HauntedQuest2", Qdata = 1, PosQ = CFrame.new(-9516.99, 172.01, 6078.46), PosM = CFrame.new(-9505.87, 172.1, 6158.99)},
        [2075] = {Mon = "Peanut Scout", Qname = "NutsIslandQuest", Qdata = 1, PosQ = CFrame.new(-2104.39, 38.1, -10194.21), PosM = CFrame.new(-2143.24, 47.72, -10029.99)},
        [2125] = {Mon = "Ice Cream Chef", Qname = "IceCreamIslandQuest", Qdata = 1, PosQ = CFrame.new(-820.64, 65.81, -10965.79), PosM = CFrame.new(-872.24, 65.81, -10919.95)},
        [2200] = {Mon = "Cookie Crafter", Qname = "CakeQuest1", Qdata = 1, PosQ = CFrame.new(-2021.32, 37.79, -12028.72), PosM = CFrame.new(-2374.13, 37.79, -12125.3)},
        [2250] = {Mon = "Baking Staff", Qname = "CakeQuest2", Qdata = 1, PosQ = CFrame.new(-1927.91, 37.79, -12842.53), PosM = CFrame.new(-1887.8, 77.61, -12998.35)},
        [2300] = {Mon = "Cocoa Warrior", Qname = "ChocQuest1", Qdata = 1, PosQ = CFrame.new(233.22, 29.87, -12201.23), PosM = CFrame.new(-21.55, 80.57, -12352.38)},
        [2350] = {Mon = "Sweet Thief", Qname = "ChocQuest2", Qdata = 1, PosQ = CFrame.new(150.5, 30.69, -12774.5), PosM = CFrame.new(165.18, 76.05, -12600.83)},
        [2400] = {Mon = "Candy Pirate", Qname = "CandyQuest1", Qdata = 1, PosQ = CFrame.new(-1150.04, 20.37, -14446.33), PosM = CFrame.new(-1310.5, 26.01, -14562.4)},
        [2450] = {Mon = "Isle Outlaw", Qname = "TikiQuest1", Qdata = 1, PosQ = CFrame.new(-16548.81, 55.6, -172.81), PosM = CFrame.new(-16479.9, 226.61, -300.31)},
        [2500] = {Mon = "Sun-kissed Warrior", Qname = "TikiQuest2", Qdata = 1, PosQ = CFrame.new(-16538, 55, 1049), PosM = CFrame.new(-16347, 64, 984)},
        [2550] = {Mon = "Serpent Hunter", Qname = "TikiQuest3", Qdata = 1, PosQ = CFrame.new(-16665.08, 105.27, 1577.61), PosM = CFrame.new(-16645.64, 163.09, 1352.87)},
        [2575] = {Mon = "Skull Slayer", Qname = "TikiQuest3", Qdata = 2, PosQ = CFrame.new(-16665.08, 105.27, 1577.61), PosM = CFrame.new(-16709.49, 419.68, 1751.09)},
    }
end

local function GetCurrentQuest()
    local level = player.Data.Level.Value
    local best = nil
    local bestLevel = 0
    for reqLevel, data in pairs(QuestData) do
        if level >= reqLevel and reqLevel > bestLevel then
            bestLevel = reqLevel
            best = data
        end
    end
    return best
end

-- ========================================
-- BONE FARM MODE
-- ========================================
local BoneMobs = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"}
local BoneQuestPos = CFrame.new(-9516.99, 172.01, 6078.46)
local BoneFarmPos = CFrame.new(-9495.68, 453.58, 5977.34)

-- ========================================
-- CAKE FARM MODE
-- ========================================
local CakeMobs = {"Cookie Crafter", "Cake Guard", "Baking Staff", "Head Baker"}
local CakeQuestPos = CFrame.new(-1927.91, 37.79, -12842.53)
local CakeFarmPos = CFrame.new(-1943.67, 251.5, -12337.88)

-- ========================================
-- FARM LOOP CHÍNH (QUAN TRỌNG NHẤT)
-- ========================================
local currentTarget = nil
local lastAttack = 0
local lastTeleport = 0

task.spawn(function()
    while true do
        if _G.StartFarm then
            pcall(function()
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then 
                    task.wait(1) 
                    return 
                end
                
                -- ===== MODE BONE =====
                if _G.FarmMode == "Bone" and World3 then
                    local questUI = player.PlayerGui:FindFirstChild("Main") and player.PlayerGui.Main:FindFirstChild("Quest")
                    local hasQuest = questUI and questUI.Visible
                    
                    if _G.AcceptQuest and not hasQuest then
                        if (hrp.Position - BoneQuestPos.Position).Magnitude > 10 then
                            TeleportTo(BoneQuestPos)
                        else
                            task.wait(0.5)
                            commF:InvokeServer("StartQuest", "HauntedQuest1", 1)
                        end
                        return
                    end
                    
                    -- Tìm mob bone gần nhất
                    local closest = nil
                    local shortest = math.huge
                    for _, mob in pairs(Workspace.Enemies:GetChildren()) do
                        for _, name in pairs(BoneMobs) do
                            if mob.Name == name and IsAlive(mob) then
                                local root = mob:FindFirstChild("HumanoidRootPart")
                                if root then
                                    local dist = (root.Position - hrp.Position).Magnitude
                                    if dist < shortest then
                                        shortest = dist
                                        closest = mob
                                    end
                                end
                            end
                        end
                    end
                    
                    if closest then
                        local root = closest:FindFirstChild("HumanoidRootPart")
                        if root then
                            if (hrp.Position - root.Position).Magnitude > 15 then
                                TeleportTo(root.CFrame * CFrame.new(0, _G.MobHeight, 0))
                            end
                            if tick() - lastAttack > 0.15 then
                                EquipWeapon(_G.SelectWeapon)
                                UseSkill("Z")
                                UseSkill("X")
                                UseSkill("C")
                                lastAttack = tick()
                            end
                        end
                    else
                        TeleportTo(BoneFarmPos)
                    end
                    return
                end
                
                -- ===== MODE CAKE =====
                if _G.FarmMode == "Cake" and World3 then
                    local questUI = player.PlayerGui:FindFirstChild("Main") and player.PlayerGui.Main:FindFirstChild("Quest")
                    local hasQuest = questUI and questUI.Visible
                    
                    if _G.AcceptQuest and not hasQuest then
                        if (hrp.Position - CakeQuestPos.Position).Magnitude > 10 then
                            TeleportTo(CakeQuestPos)
                        else
                            task.wait(0.5)
                            commF:InvokeServer("StartQuest", "CakeQuest1", 1)
                        end
                        return
                    end
                    
                    local closest = nil
                    local shortest = math.huge
                    for _, mob in pairs(Workspace.Enemies:GetChildren()) do
                        for _, name in pairs(CakeMobs) do
                            if mob.Name == name and IsAlive(mob) then
                                local root = mob:FindFirstChild("HumanoidRootPart")
                                if root then
                                    local dist = (root.Position - hrp.Position).Magnitude
                                    if dist < shortest then
                                        shortest = dist
                                        closest = mob
                                    end
                                end
                            end
                        end
                    end
                    
                    if closest then
                        local root = closest:FindFirstChild("HumanoidRootPart")
                        if root then
                            if (hrp.Position - root.Position).Magnitude > 15 then
                                TeleportTo(root.CFrame * CFrame.new(0, _G.MobHeight, 0))
                            end
                            if tick() - lastAttack > 0.15 then
                                EquipWeapon(_G.SelectWeapon)
                                UseSkill("Z")
                                UseSkill("X")
                                UseSkill("C")
                                lastAttack = tick()
                            end
                        end
                    else
                        TeleportTo(CakeFarmPos)
                    end
                    return
                end
                
                -- ===== MODE LEVEL (DEFAULT) =====
                local quest = GetCurrentQuest()
                if not quest then 
                    task.wait(1) 
                    return 
                end
                
                local questUI = player.PlayerGui:FindFirstChild("Main") and player.PlayerGui.Main:FindFirstChild("Quest")
                local hasQuest = questUI and questUI.Visible
                
                if _G.AcceptQuest and not hasQuest then
                    if (hrp.Position - quest.PosQ.Position).Magnitude > 10 then
                        TeleportTo(quest.PosQ)
                    else
                        task.wait(0.5)
                        commF:InvokeServer("StartQuest", quest.Qname, quest.Qdata)
                    end
                    return
                end
                
                if not currentTarget or not IsAlive(currentTarget) or currentTarget.Name ~= quest.Mon then
                    local closest = nil
                    local shortest = math.huge
                    for _, mob in pairs(Workspace.Enemies:GetChildren()) do
                        if mob.Name == quest.Mon and IsAlive(mob) then
                            local root = mob:FindFirstChild("HumanoidRootPart")
                            if root then
                                local dist = (root.Position - hrp.Position).Magnitude
                                if dist < shortest then
                                    shortest = dist
                                    closest = mob
                                end
                            end
                        end
                    end
                    currentTarget = closest
                end
                
                if currentTarget and IsAlive(currentTarget) then
                    local root = currentTarget:FindFirstChild("HumanoidRootPart")
                    if root then
                        if (hrp.Position - root.Position).Magnitude > 15 then
                            TeleportTo(root.CFrame * CFrame.new(0, _G.MobHeight, 0))
                            lastTeleport = tick()
                        end
                        if tick() - lastAttack > 0.15 then
                            EquipWeapon(_G.SelectWeapon)
                            UseSkill("Z")
                            UseSkill("X")
                            UseSkill("C")
                            lastAttack = tick()
                        end
                    end
                else
                    if tick() - lastTeleport > 2 then
                        TeleportTo(quest.PosM)
                        lastTeleport = tick()
                    end
                end
            end)
        end
        task.wait(0.1)
    end
end)

-- ========================================
-- BRING MOBS
-- ========================================
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)

task.spawn(function()
    while true do
        if _G.BringMobs and _G.StartFarm then
            pcall(function()
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local count = 0
                    for _, mob in pairs(Workspace.Enemies:GetChildren()) do
                        if count >= _G.MaxBringMobs then break end
                        local hum = mob:FindFirstChild("Humanoid")
                        local root = mob:FindFirstChild("HumanoidRootPart")
                        if hum and root and hum.Health > 0 and not root:GetAttribute("Tweening") then
                            if (root.Position - hrp.Position).Magnitude <= _G.BringRange then
                                count = count + 1
                                root:SetAttribute("Tweening", true)
                                local tween = TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(hrp.Position)})
                                tween:Play()
                                tween.Completed:Once(function()
                                    if root then root:SetAttribute("Tweening", false) end
                                end)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(1)
    end
end)

-- ========================================
-- AUTO ATTACK (FAST HIT)
-- ========================================
local net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local registerAttack = net:WaitForChild("RE/RegisterAttack")
local registerHit = net:WaitForChild("RE/RegisterHit")

task.spawn(function()
    while true do
        if _G.AutoAttack and _G.StartFarm then
            pcall(function()
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local enemies = {}
                    for _, mob in pairs(Workspace.Enemies:GetChildren()) do
                        if IsAlive(mob) then
                            local root = mob:FindFirstChild("HumanoidRootPart")
                            if root and (root.Position - hrp.Position).Magnitude <= 60 then
                                table.insert(enemies, {mob, root})
                            end
                        end
                    end
                    if #enemies > 0 then
                        registerAttack:FireServer(-math.huge)
                        local hitData = {nil, {}}
                        for i, data in ipairs(enemies) do
                            if not hitData[1] then 
                                hitData[1] = data[1]:FindFirstChild("Head") or data[2]
                            end
                            hitData[2][i] = data
                        end
                        registerHit:FireServer(unpack(hitData))
                    end
                end
            end)
        end
        task.wait(0.05)
    end
end)

-- ========================================
-- UI (RAYFIELD) - FULL TABS
-- ========================================
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

local Window = Rayfield:CreateWindow({
    Name = "Turbo Lite Hub V3",
    Icon = 0,
    LoadingTitle = "Turbo Lite Hub",
    LoadingSubtitle = "by TurboLite",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "TurboLiteHub",
        FileName = "Settings"
    }
})

-- Tab Farm
local FarmTab = Window:CreateTab("Farm", 0)
FarmTab:CreateSection("Control")

FarmTab:CreateToggle({
    Name = "Start Farm",
    CurrentValue = _G.StartFarm,
    Flag = "StartFarm",
    Callback = function(v)
        _G.StartFarm = v
        _G.SaveData["StartFarm"] = v
        SaveSettings()
        Rayfield:Notify({
            Title = "Farm",
            Content = v and "Started" or "Stopped",
            Duration = 1
        })
    end
})

FarmTab:CreateDropdown({
    Name = "Farm Mode",
    Options = {"Level", "Bone", "Cake"},
    CurrentOption = _G.FarmMode,
    Flag = "FarmMode",
    Callback = function(v)
        _G.FarmMode = v
        _G.SaveData["FarmMode"] = v
        SaveSettings()
    end
})

FarmTab:CreateToggle({
    Name = "Accept Quest",
    CurrentValue = _G.AcceptQuest,
    Flag = "AcceptQuest",
    Callback = function(v)
        _G.AcceptQuest = v
        _G.SaveData["AcceptQuest"] = v
        SaveSettings()
    end
})

FarmTab:CreateToggle({
    Name = "Bring Mobs",
    CurrentValue = _G.BringMobs,
    Flag = "BringMobs",
    Callback = function(v)
        _G.BringMobs = v
        _G.SaveData["BringMobs"] = v
        SaveSettings()
    end
})

FarmTab:CreateToggle({
    Name = "Auto Attack",
    CurrentValue = _G.AutoAttack,
    Flag = "AutoAttack",
    Callback = function(v)
        _G.AutoAttack = v
        _G.SaveData["AutoAttack"] = v
        SaveSettings()
    end
})

FarmTab:CreateToggle({
    Name = "Auto Ken",
    CurrentValue = _G.AutoKen,
    Flag = "AutoKen",
    Callback = function(v)
        _G.AutoKen = v
        _G.SaveData["AutoKen"] = v
        SaveSettings()
    end
})

FarmTab:CreateSection("Settings")

FarmTab:CreateDropdown({
    Name = "Select Weapon",
    Options = {"Melee", "Sword", "Blox Fruit", "Gun"},
    CurrentOption = _G.SelectWeapon,
    Flag = "SelectWeapon",
    Callback = function(v)
        _G.SelectWeapon = v
        _G.SaveData["SelectWeapon"] = v
        SaveSettings()
    end
})

FarmTab:CreateInput({
    Name = "Mob Height",
    CurrentValue = tostring(_G.MobHeight),
    Flag = "MobHeight",
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 then
            _G.MobHeight = num
            _G.SaveData["MobHeight"] = num
            SaveSettings()
        end
    end
})

FarmTab:CreateInput({
    Name = "Bring Range",
    CurrentValue = tostring(_G.BringRange),
    Flag = "BringRange",
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 then
            _G.BringRange = num
            _G.SaveData["BringRange"] = num
            SaveSettings()
        end
    end
})

-- Tab Teleport
local TeleportTab = Window:CreateTab("Teleport", 1)

TeleportTab:CreateButton({
    Name = "Sea 1",
    Callback = function()
        commF:InvokeServer("TravelMain")
    end
})

TeleportTab:CreateButton({
    Name = "Sea 2",
    Callback = function()
        commF:InvokeServer("TravelDressrosa")
    end
})

TeleportTab:CreateButton({
    Name = "Sea 3",
    Callback = function()
        commF:InvokeServer("TravelZou")
    end
})

-- Tab Misc
local MiscTab = Window:CreateTab("Misc", 2)

MiscTab:CreateButton({
    Name = "Set Team Marines",
    Callback = function()
        commF:InvokeServer("SetTeam", "Marines")
        Rayfield:Notify({Title = "Team", Content = "Changed to Marines", Duration = 1})
    end
})

MiscTab:CreateButton({
    Name = "Set Team Pirates",
    Callback = function()
        commF:InvokeServer("SetTeam", "Pirates")
        Rayfield:Notify({Title = "Team", Content = "Changed to Pirates", Duration = 1})
    end
})

MiscTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, player)
    end
})

MiscTab:CreateButton({
    Name = "Hop Server",
    Callback = function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        if servers and servers.data and #servers.data > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers.data[1].id, player)
        end
    end
})

MiscTab:CreateButton({
    Name = "Save Settings",
    Callback = function()
        SaveSettings()
        Rayfield:Notify({Title = "Save", Content = "Settings saved!", Duration = 1})
    end
})

-- Tab Info
local InfoTab = Window:CreateTab("Info", 3)

InfoTab:CreateParagraph({
    Title = "Turbo Lite Hub V3",
    Content = "Optimized Blox Fruit Script\nWorld: " .. (World1 and "Sea 1" or World2 and "Sea 2" or "Sea 3")
})

local StatusLabel = InfoTab:CreateParagraph({
    Title = "Status",
    Content = "Farm: OFF\nLevel: " .. player.Data.Level.Value
})

task.spawn(function()
    while true do
        task.wait(1)
        StatusLabel:SetContent("Farm: " .. (_G.StartFarm and "ON" or "OFF") .. "\nLevel: " .. player.Data.Level.Value .. "\nMode: " .. _G.FarmMode)
    end
end)

-- ========================================
-- ANTI AFK
-- ========================================
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

-- ========================================
-- LOW CPU
-- ========================================
Workspace.Terrain.WaterWaveSize = 0
Workspace.Terrain.WaterWaveSpeed = 0
settings().Rendering.QualityLevel = "Level01"

print("Turbo Lite Hub V3 loaded! Bật Start Farm để bắt đầu farm")
Rayfield:Notify({
    Title = "Turbo Lite Hub",
    Content = "Loaded! Bật Start Farm để bắt đầu",
    Duration = 3
})