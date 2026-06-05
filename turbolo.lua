-- ========================================
-- UI ĐƠN GIẢN BẰNG DROP DOWN MENU (Console)
-- ========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TurboLiteHub"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 500)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Text = "Turbo Lite Hub V3"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -40)
ScrollFrame.Position = UDim2.new(0, 0, 0, 40)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

-- Hàm tạo Section
local function AddSection(text)
    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(1, -20, 0, 30)
    section.Position = UDim2.new(0, 10, 0, 0)
    section.BackgroundTransparency = 1
    section.Text = text
    section.TextColor3 = Color3.fromRGB(255, 200, 100)
    section.Font = Enum.Font.GothamBold
    section.TextSize = 14
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.Parent = ScrollFrame
    return section
end

-- Hàm tạo Toggle
local function AddToggle(name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    frame.BackgroundTransparency = 0.3
    frame.Parent = ScrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 50, 0, 25)
    toggle.Position = UDim2.new(1, -60, 0, 5)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
    toggle.Text = default and "ON" or "OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 12
    toggle.Parent = frame
    
    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
        toggle.Text = state and "ON" or "OFF"
        callback(state)
    end)
    
    return {SetValue = function(v) state = v; toggle.BackgroundColor3 = v and Color3.fromRGB(0,200,0) or Color3.fromRGB(100,100,100); toggle.Text = v and "ON" or "OFF"; callback(v) end}
end

-- Hàm tạo Button
local function AddButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = ScrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
end

-- Hàm tạo Dropdown
local function AddDropdown(name, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 55)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    frame.BackgroundTransparency = 0.3
    frame.Parent = ScrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(1, -20, 0, 25)
    dropdownBtn.Position = UDim2.new(0, 10, 0, 25)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    dropdownBtn.Text = default or options[1]
    dropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdownBtn.Font = Enum.Font.Gotham
    dropdownBtn.TextSize = 12
    dropdownBtn.Parent = frame
    
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 4)
    corner2.Parent = dropdownBtn
    
    local isOpen = false
    local listFrame = nil
    
    dropdownBtn.MouseButton1Click:Connect(function()
        if isOpen then
            if listFrame then listFrame:Destroy() end
            isOpen = false
            return
        end
        
        listFrame = Instance.new("Frame")
        listFrame.Size = UDim2.new(1, 0, 0, #options * 30)
        listFrame.Position = UDim2.new(0, 0, 0, 55)
        listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        listFrame.BackgroundTransparency = 0.1
        listFrame.Parent = frame
        
        local listCorner = Instance.new("UICorner")
        listCorner.CornerRadius = UDim.new(0, 4)
        listCorner.Parent = listFrame
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 2)
        listLayout.Parent = listFrame
        
        for _, opt in pairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 28)
            optBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            optBtn.Text = opt
            optBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextSize = 11
            optBtn.Parent = listFrame
            
            optBtn.MouseButton1Click:Connect(function()
                dropdownBtn.Text = opt
                callback(opt)
                listFrame:Destroy()
                isOpen = false
            end)
        end
        
        isOpen = true
        
        local function closeOnClick(other)
            if other ~= dropdownBtn and other ~= listFrame and not listFrame:IsDescendantOf(other) then
                if listFrame then listFrame:Destroy() end
                isOpen = false
                game:GetService("UserInputService").InputBegan:Disconnect(closeConn)
            end
        end
        
        local closeConn = game:GetService("UserInputService").InputBegan:Connect(closeOnClick)
    end)
end

-- Xây dựng UI
AddSection("=== AUTO FARM ===")

local startFarmToggle = AddToggle("Start Farm", _G.StartFarm, function(v)
    _G.StartFarm = v
    _G.SaveData["StartFarm"] = v
    SaveSettings()
end)

AddDropdown("Farm Mode", {"Level", "Bone", "Cake"}, _G.FarmMode, function(v)
    _G.FarmMode = v
    _G.SaveData["FarmMode"] = v
    SaveSettings()
end)

AddToggle("Accept Quest", _G.AcceptQuest, function(v)
    _G.AcceptQuest = v
    _G.SaveData["AcceptQuest"] = v
    SaveSettings()
end)

AddToggle("Bring Mobs", _G.BringMobs, function(v)
    _G.BringMobs = v
    _G.SaveData["BringMobs"] = v
    SaveSettings()
end)

AddToggle("Auto Attack", _G.AutoAttack, function(v)
    _G.AutoAttack = v
    _G.SaveData["AutoAttack"] = v
    SaveSettings()
end)

AddToggle("Auto Ken", _G.AutoKen, function(v)
    _G.AutoKen = v
    _G.SaveData["AutoKen"] = v
    SaveSettings()
end)

AddSection("=== WEAPON ===")

AddDropdown("Select Weapon", {"Melee", "Sword", "Blox Fruit", "Gun"}, _G.SelectWeapon, function(v)
    _G.SelectWeapon = v
    _G.SaveData["SelectWeapon"] = v
    SaveSettings()
end)

AddSection("=== SETTINGS ===")

AddButton("Set Team Marines", function()
    commF:InvokeServer("SetTeam", "Marines")
end)

AddButton("Set Team Pirates", function()
    commF:InvokeServer("SetTeam", "Pirates")
end)

AddButton("Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, player)
end)

AddButton("Save Settings", function()
    SaveSettings()
end)

AddSection("=== INFO ===")

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 0, 60)
infoLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
infoLabel.BackgroundTransparency = 0.3
infoLabel.Text = "World: " .. (World1 and "Sea 1" or World2 and "Sea 2" or "Sea 3") .. "\nLevel: " .. player.Data.Level.Value .. "\nFarm: OFF"
infoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 12
infoLabel.Parent = ScrollFrame

local cornerInfo = Instance.new("UICorner")
cornerInfo.CornerRadius = UDim.new(0, 4)
cornerInfo.Parent = infoLabel

-- Cập nhật info
task.spawn(function()
    while true do
        task.wait(1)
        infoLabel.Text = "World: " .. (World1 and "Sea 1" or World2 and "Sea 2" or "Sea 3") .. "\nLevel: " .. player.Data.Level.Value .. "\nFarm: " .. (_G.StartFarm and "ON" or "OFF") .. "\nMode: " .. _G.FarmMode
    end
end)

-- Cập nhật Canvas size
local function updateCanvas()
    task.wait(0.1)
    local contentHeight = 0
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") then
            contentHeight = contentHeight + child.Size.Y.Offset + 8
        end
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 20)
end

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
updateCanvas()

-- Kéo thả UI
local dragging = false
local dragInput
local dragStart
local startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("UI đã tạo! Nếu không thấy, kiểm tra CoreGui hoặc dùng lệnh: game.CoreGui.TurboLiteHub.Enabled = true")