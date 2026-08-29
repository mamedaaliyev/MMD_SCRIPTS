local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function WaitForCharacter()
    if LocalPlayer.Character then
        return LocalPlayer.Character
    end
    return LocalPlayer.CharacterAdded:Wait()
end
WaitForCharacter()

local TargetGuiParent
if gethui then
    TargetGuiParent = gethui()
else
    local success = pcall(function()
        TargetGuiParent = CoreGui
        local test = TargetGuiParent.Name
    end)
    if not success or not TargetGuiParent then
        TargetGuiParent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

if getgenv().mmd_scripts_cheat then
    pcall(function()
        getgenv().mmd_scripts_cheat:Destroy()
    end)
end

getgenv().mmd_scripts_cheat = {}
local ScriptConnections = {}
local EspInstances = {}
local IsCheatLoaded = false
local IsCompletelyHidden = false
local UIUpdaters = {}
local AnimatedGradients = {}
local ScrollFrames = {}

local ConfigPath = "mmd_scripts_settings.json"
local CheatSettings = {
    MenuHue = 0.33,
    MenuSat = 100,
    MenuVal = 100,
    PanicKey = "Insert",
    
    AimbotEnabled = false,
    AimbotMode = "Always",
    TeamCheck = true,
    HeadChance = 100,
    MaxDistance = 1000,
    
    FovVisible = true,
    FovRadius = 150,
    FovHue = 0.33,
    FovSat = 100,
    FovVal = 100,
    FovTransparency = 0,
    
    EspEnabled = false,
    EspEnemies = true,
    EspEnemyHue = 0.0,
    EspEnemySat = 100,
    EspEnemyVal = 100,
    EspEnemyTransp = 0,
    EspAllies = false,
    EspAllyHue = 0.6,
    EspAllySat = 100,
    EspAllyVal = 100,
    EspAllyTransp = 0
}

local function SaveSettings()
    if type(writefile) == "function" then
        pcall(function()
            local jsonString = HttpService:JSONEncode(CheatSettings)
            writefile(ConfigPath, jsonString)
        end)
    end
end

local function LoadSettings()
    if type(isfile) == "function" and isfile(ConfigPath) and type(readfile) == "function" then
        pcall(function()
            local fileData = readfile(ConfigPath)
            local decoded = HttpService:JSONDecode(fileData)
            if type(decoded) == "table" then
                for key, value in pairs(decoded) do
                    if CheatSettings[key] ~= nil then
                        CheatSettings[key] = value
                    end
                end
            end
        end)
    end
end
LoadSettings()

local IsRightMousePressed = false

table.insert(ScriptConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsRightMousePressed = true
    end
end))

table.insert(ScriptConnections, UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsRightMousePressed = false
    end
end))

local function IsAimKeyPressed()
    if CheatSettings.AimbotMode == "Always" then return true end
    local success, isDown = pcall(function()
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    end)
    if success then
        return isDown
    end
    return IsRightMousePressed
end

local CurrentAccentColor = Color3.fromHSV(CheatSettings.MenuHue, CheatSettings.MenuSat / 100, CheatSettings.MenuVal / 100)
local DynamicUIElements = {
    Backgrounds = {},
    Strokes = {},
    Texts = {}
}

local UITheme = {
    Background = Color3.fromRGB(15, 15, 17),
    Header = Color3.fromRGB(22, 22, 25),
    Container = Color3.fromRGB(30, 30, 35),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(150, 150, 160),
    Red = Color3.fromRGB(255, 60, 60),
    DarkRed = Color3.fromRGB(180, 40, 40)
}

local function CreateTween(instance, properties, duration, style)
    local tweenInfo = TweenInfo.new(
        duration or 0.35,
        style or Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local isMobileDevice = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local WindowWidth = 260
local WindowHeight = 450

local MainGui = Instance.new("ScreenGui")
MainGui.Name = HttpService:GenerateGUID(false)
MainGui.ResetOnSpawn = false
MainGui.IgnoreGuiInset = true
MainGui.Parent = TargetGuiParent
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local LoadingContainer = Instance.new("Frame")
LoadingContainer.Size = UDim2.new(1, 0, 1, 0)
LoadingContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LoadingContainer.BackgroundTransparency = 1
LoadingContainer.BorderSizePixel = 0
LoadingContainer.ZIndex = 1000
LoadingContainer.Parent = MainGui

local WaveFrame = Instance.new("Frame")
WaveFrame.Size = UDim2.new(0, 400, 0, 100)
WaveFrame.Position = UDim2.new(-0.5, 0, 0.5, 0)
WaveFrame.AnchorPoint = Vector2.new(0.5, 0.5)
WaveFrame.BackgroundTransparency = 1
WaveFrame.Parent = LoadingContainer

local WaveLayout = Instance.new("UIListLayout")
WaveLayout.FillDirection = Enum.FillDirection.Horizontal
WaveLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
WaveLayout.VerticalAlignment = Enum.VerticalAlignment.Center
WaveLayout.SortOrder = Enum.SortOrder.LayoutOrder
WaveLayout.Padding = UDim.new(0, 2)
WaveLayout.Parent = WaveFrame

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = UITheme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.Parent = MainGui

local MainFrameCorner = Instance.new("UICorner")
MainFrameCorner.CornerRadius = UDim.new(0, 10)
MainFrameCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = CurrentAccentColor
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame
table.insert(DynamicUIElements.Strokes, MainStroke)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = UITheme.Header
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local TopBarDivider = Instance.new("Frame")
TopBarDivider.Size = UDim2.new(1, 0, 0, 1)
TopBarDivider.Position = UDim2.new(0, 0, 1, -1)
TopBarDivider.BackgroundColor3 = UITheme.Container
TopBarDivider.BorderSizePixel = 0
TopBarDivider.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "MMD SCRIPTS"
TitleLabel.Font = Enum.Font.Code
TitleLabel.TextSize = 14
TitleLabel.TextColor3 = CurrentAccentColor
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar
table.insert(DynamicUIElements.Texts, TitleLabel)

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 24, 0, 24)
MinimizeButton.Position = UDim2.new(1, -34, 0, 8)
MinimizeButton.Text = "-"
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 20
MinimizeButton.TextColor3 = UITheme.TextDim
MinimizeButton.BackgroundColor3 = UITheme.Container
MinimizeButton.BorderSizePixel = 0
MinimizeButton.AutoButtonColor = false
MinimizeButton.Parent = TopBar

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(1, 0)
MinimizeCorner.Parent = MinimizeButton

local TabBar = Instance.new("ScrollingFrame")
TabBar.Size = UDim2.new(1, 0, 0, 35)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = UITheme.Header
TabBar.BorderSizePixel = 0
TabBar.ScrollBarThickness = 0
TabBar.ScrollingDirection = Enum.ScrollingDirection.X
TabBar.AutomaticCanvasSize = Enum.AutomaticSize.X
TabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
TabBar.Parent = MainFrame

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingLeft = UDim.new(0, 15)
TabPadding.PaddingRight = UDim.new(0, 15)
TabPadding.Parent = TabBar

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 15)
TabLayout.Parent = TabBar

local TabDivider = Instance.new("Frame")
TabDivider.Size = UDim2.new(1, 0, 0, 1)
TabDivider.Position = UDim2.new(0, 0, 0, 74)
TabDivider.BackgroundColor3 = UITheme.Container
TabDivider.BorderSizePixel = 0
TabDivider.ZIndex = 5
TabDivider.Parent = MainFrame

local BottomDragBar = Instance.new("Frame")
BottomDragBar.Size = UDim2.new(1, 0, 0, 15)
BottomDragBar.Position = UDim2.new(0, 0, 1, -15)
BottomDragBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BottomDragBar.BackgroundTransparency = 0.95
BottomDragBar.BorderSizePixel = 0
BottomDragBar.ZIndex = 10
BottomDragBar.Parent = MainFrame

local FloatingBall = Instance.new("TextButton")
FloatingBall.Size = UDim2.new(0, 0, 0, 0)
FloatingBall.Position = UDim2.new(0.5, 0, 0.5, 0)
FloatingBall.AnchorPoint = Vector2.new(0.5, 0.5)
FloatingBall.BackgroundColor3 = UITheme.Header
FloatingBall.BorderSizePixel = 0
FloatingBall.Visible = false
FloatingBall.Text = ""
FloatingBall.ZIndex = 999
FloatingBall.Parent = MainGui

local FloatingBallCorner = Instance.new("UICorner")
FloatingBallCorner.CornerRadius = UDim.new(1, 0)
FloatingBallCorner.Parent = FloatingBall

local FBStroke = Instance.new("UIStroke")
FBStroke.Thickness = 2
FBStroke.Color = CurrentAccentColor
FBStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
FBStroke.Parent = FloatingBall
table.insert(DynamicUIElements.Strokes, FBStroke)

local FBLabel = Instance.new("TextLabel")
FBLabel.Size = UDim2.new(1, 0, 1, 0)
FBLabel.BackgroundTransparency = 1
FBLabel.Text = "MMD"
FBLabel.Font = Enum.Font.GothamBold
FBLabel.TextSize = 18
FBLabel.TextColor3 = CurrentAccentColor
FBLabel.Parent = FloatingBall
table.insert(DynamicUIElements.Texts, FBLabel)

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, 0, 1, -90)
ContentContainer.Position = UDim2.new(0, 0, 0, 75)
ContentContainer.BackgroundTransparency = 1
ContentContainer.BorderSizePixel = 0
ContentContainer.Parent = MainFrame

local function CreateTabScroll(name)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = name
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 2
    scroll.ScrollBarImageColor3 = UITheme.Container
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.None
    scroll.CanvasSize = UDim2.new(0, 0, 0, 800)
    scroll.Visible = false
    scroll.Parent = ContentContainer

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.Parent = scroll

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    table.insert(ScrollFrames, {frame = scroll, layout = layout, axis = "Y"})
    return scroll
end

local TabAimbot = CreateTabScroll("AimbotTab")
local TabEsp = CreateTabScroll("EspTab")
local TabSettings = CreateTabScroll("SettingsTab")
local TabAbout = CreateTabScroll("AboutTab")
TabAimbot.Visible = true

local ActiveTabButton = nil

local function CreateTabButton(text, targetScroll, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 95, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.Font = Enum.Font.Code
    btn.TextSize = 12
    btn.TextColor3 = UITheme.TextDim
    btn.LayoutOrder = order
    btn.Parent = TabBar

    local highlight = Instance.new("Frame")
    highlight.Size = UDim2.new(0, 0, 0, 2)
    highlight.Position = UDim2.new(0.5, 0, 1, -2)
    highlight.AnchorPoint = Vector2.new(0.5, 0)
    highlight.BackgroundColor3 = CurrentAccentColor
    highlight.BorderSizePixel = 0
    highlight.Parent = btn
    table.insert(DynamicUIElements.Backgrounds, highlight)

    if order == 1 then
        ActiveTabButton = btn
        btn.TextColor3 = CurrentAccentColor
        table.insert(DynamicUIElements.Texts, btn)
        highlight.Size = UDim2.new(0.8, 0, 0, 2)
    end

    btn.MouseButton1Click:Connect(function()
        if ActiveTabButton == btn then return end
        
        for i, v in ipairs(DynamicUIElements.Texts) do
            if v == ActiveTabButton then table.remove(DynamicUIElements.Texts, i) break end
        end
        
        ActiveTabButton.TextColor3 = UITheme.TextDim
        CreateTween(ActiveTabButton:FindFirstChild("Frame"), {Size = UDim2.new(0, 0, 0, 2)}, 0.3)
        
        ActiveTabButton = btn
        btn.TextColor3 = CurrentAccentColor
        table.insert(DynamicUIElements.Texts, btn)
        CreateTween(highlight, {Size = UDim2.new(0.8, 0, 0, 2)}, 0.3)

        TabAimbot.Visible = false
        TabEsp.Visible = false
        TabSettings.Visible = false
        TabAbout.Visible = false
        targetScroll.Visible = true
    end)
end

CreateTabButton("AIMBOT", TabAimbot, 1)
CreateTabButton("ESP", TabEsp, 2)
CreateTabButton("SETTINGS", TabSettings, 3)
CreateTabButton("ABOUT US", TabAbout, 4)

table.insert(ScriptConnections, RunService.RenderStepped:Connect(function()
    for _, data in pairs(ScrollFrames) do
        if data.frame and data.layout then
            if data.axis == "Y" then
                data.frame.CanvasSize = UDim2.new(0, 0, 0, data.layout.AbsoluteContentSize.Y + 20)
            else
                data.frame.CanvasSize = UDim2.new(0, data.layout.AbsoluteContentSize.X + 20, 0, 0)
            end
        end
    end
end))

local function UpdateUIColors()
    CurrentAccentColor = Color3.fromHSV(CheatSettings.MenuHue, CheatSettings.MenuSat / 100, CheatSettings.MenuVal / 100)
    for _, obj in pairs(DynamicUIElements.Backgrounds) do
        if obj and obj.Parent then obj.BackgroundColor3 = CurrentAccentColor end
    end
    for _, obj in pairs(DynamicUIElements.Strokes) do
        if obj and obj.Parent then obj.Color = CurrentAccentColor end
    end
    for _, obj in pairs(DynamicUIElements.Texts) do
        if obj and obj.Parent then obj.TextColor3 = CurrentAccentColor end
    end
end

local function TriggerUpdaters()
    for _, fn in ipairs(UIUpdaters) do pcall(fn) end
    UpdateUIColors()
end

local function CreateToggle(parent, titleText, settingKey, colorOff, order, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 38)
    button.BackgroundTransparency = 0
    button.BorderSizePixel = 0
    button.Text = ""
    button.LayoutOrder = order
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Code
    label.TextSize = 13
    label.TextColor3 = UITheme.Text
    label.Parent = button

    local function updateUI()
        local state = CheatSettings[settingKey]
        label.Text = titleText .. "  " .. (state and "ON" or "OFF")
        if state then
            local found = false
            for _,v in ipairs(DynamicUIElements.Backgrounds) do if v == button then found = true break end end
            if not found then table.insert(DynamicUIElements.Backgrounds, button) end
            button.BackgroundColor3 = CurrentAccentColor
        else
            for i,v in ipairs(DynamicUIElements.Backgrounds) do if v == button then table.remove(DynamicUIElements.Backgrounds, i) break end end
            button.BackgroundColor3 = colorOff
        end
    end
    table.insert(UIUpdaters, updateUI)

    button.MouseButton1Click:Connect(function()
        CheatSettings[settingKey] = not CheatSettings[settingKey]
        updateUI()
        SaveSettings()
        if callback then callback() end
    end)
    return button, label
end

local function CreateModeToggle(parent, titleText, settingKey, modes, order, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 38)
    button.BackgroundColor3 = UITheme.Container
    button.BackgroundTransparency = 0
    button.BorderSizePixel = 0
    button.Text = ""
    button.LayoutOrder = order
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Code
    label.TextSize = 13
    label.TextColor3 = UITheme.Text
    label.Parent = button

    local function updateUI()
        label.Text = titleText .. "  " .. CheatSettings[settingKey]
    end
    table.insert(UIUpdaters, updateUI)

    button.MouseButton1Click:Connect(function()
        if CheatSettings[settingKey] == modes[1] then 
            CheatSettings[settingKey] = modes[2] 
        else 
            CheatSettings[settingKey] = modes[1] 
        end
        updateUI()
        SaveSettings()
        if callback then callback() end
    end)
    return button, label
end

local function CreateAction(parent, titleText, colorOff, order, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 38)
    button.BackgroundColor3 = colorOff
    button.BackgroundTransparency = 0
    button.BorderSizePixel = 0
    button.Text = ""
    button.LayoutOrder = order
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = titleText
    label.Font = Enum.Font.Code
    label.TextSize = 13
    label.TextColor3 = UITheme.Text
    label.Parent = button

    button.MouseButton1Click:Connect(function()
        if callback then callback(button, label) end
    end)
    return button, label
end

local function CreateSlider(parent, labelTitle, settingKey, minVal, maxVal, order)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 44)
    container.BackgroundColor3 = UITheme.Container
    container.BackgroundTransparency = 0.4
    container.BorderSizePixel = 0
    container.LayoutOrder = order
    container.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -16, 0, 16)
    title.Position = UDim2.new(0, 8, 0, 6)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.Code
    title.TextSize = 11
    title.TextColor3 = UITheme.TextDim
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = container

    local sBg = Instance.new("Frame")
    sBg.Size = UDim2.new(1, -16, 0, 6)
    sBg.Position = UDim2.new(0, 8, 0, 26)
    sBg.BackgroundColor3 = UITheme.Background
    sBg.BorderSizePixel = 0
    sBg.Parent = container
    Instance.new("UICorner", sBg).CornerRadius = UDim.new(1, 0)

    local sFill = Instance.new("Frame")
    sFill.BackgroundColor3 = CurrentAccentColor
    sFill.BorderSizePixel = 0
    sFill.Parent = sBg
    Instance.new("UICorner", sFill).CornerRadius = UDim.new(1, 0)
    table.insert(DynamicUIElements.Backgrounds, sFill)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.BackgroundColor3 = UITheme.Text
    knob.BorderSizePixel = 0
    knob.Parent = sBg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function updateUI()
        local val = CheatSettings[settingKey]
        local r = (maxVal - minVal) > 0 and (val - minVal) / (maxVal - minVal) or 0
        sFill.Size = UDim2.new(r, 0, 1, 0)
        knob.Position = UDim2.new(r, -7, 0.5, -7)
        title.Text = labelTitle .. ": " .. tostring(val)
    end
    table.insert(UIUpdaters, updateUI)

    local isDragging = false
    local function Update(mouseX)
        local ap = sBg.AbsolutePosition.X
        local as = sBg.AbsoluteSize.X
        if as <= 0 then return end
        local r = math.clamp((mouseX - ap) / as, 0, 1)
        CheatSettings[settingKey] = math.floor(r * (maxVal - minVal) + minVal)
        updateUI()
    end

    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true 
            Update(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Update(UserInputService:GetMouseLocation().X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            isDragging = false 
            SaveSettings()
        end
    end)
    return container
end

local function CreateHueMenu(parent, titleText, order, hueKey, satKey, valKey, alphaKey)
    local wrap = Instance.new("Frame")
    
    local sliderCount = 1
    if satKey then sliderCount = sliderCount + 1 end
    if valKey then sliderCount = sliderCount + 1 end
    if alphaKey then sliderCount = sliderCount + 1 end
    local expandedHeight = 36 + (sliderCount * 45) + 10

    wrap.Size = UDim2.new(1, 0, 0, 36)
    wrap.BackgroundColor3 = UITheme.Container
    wrap.BackgroundTransparency = 0.5
    wrap.BorderSizePixel = 0
    wrap.LayoutOrder = order
    wrap.ClipsDescendants = true
    wrap.Parent = parent
    Instance.new("UICorner", wrap).CornerRadius = UDim.new(0, 8)

    local tBtn = Instance.new("TextButton")
    tBtn.Size = UDim2.new(1, 0, 0, 36)
    tBtn.BackgroundTransparency = 1
    tBtn.Text = titleText .. " ▼"
    tBtn.Font = Enum.Font.Code
    tBtn.TextSize = 13
    tBtn.TextColor3 = UITheme.Text
    tBtn.Parent = wrap

    local sCont = Instance.new("Frame")
    sCont.Size = UDim2.new(1, 0, 0, expandedHeight - 36)
    sCont.Position = UDim2.new(0, 0, 0, 36)
    sCont.BackgroundTransparency = 1
    sCont.Parent = wrap

    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, 8)
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    l.Parent = sCont
    
    local isOpen = false
    tBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        tBtn.Text = titleText .. (isOpen and " ▲" or " ▼")
        CreateTween(wrap, {Size = isOpen and UDim2.new(1, 0, 0, expandedHeight) or UDim2.new(1, 0, 0, 36)}, 0.3)
    end)

    local function makeSingleSlider(lbl, maxVal, sliderType, settingKey)
        local f = Instance.new("Frame", sCont)
        f.Size = UDim2.new(0.9, 0, 0, 35)
        f.BackgroundTransparency = 1
        
        local t = Instance.new("TextLabel", f)
        t.Size = UDim2.new(1, 0, 0, 14)
        t.BackgroundTransparency = 1
        t.Font = Enum.Font.Code
        t.TextSize = 10
        t.TextColor3 = UITheme.TextDim
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = f

        local b = Instance.new("Frame", f)
        b.Size = UDim2.new(1, 0, 0, 6)
        b.Position = UDim2.new(0, 0, 0, 22)
        b.BackgroundColor3 = UITheme.Background
        b.BorderSizePixel = 0
        b.Parent = f
        Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)

        local fl = nil
        if sliderType == "Hue" then
            local gradient = Instance.new("UIGradient", b)
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                ColorSequenceKeypoint.new(0.166, Color3.fromHSV(0.166, 1, 1)),
                ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
                ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
                ColorSequenceKeypoint.new(0.666, Color3.fromHSV(0.666, 1, 1)),
                ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
            })
            b.BackgroundColor3 = Color3.new(1, 1, 1)
        elseif sliderType == "Sat" or sliderType == "Val" then
            fl = Instance.new("Frame", b)
            fl.BackgroundColor3 = UITheme.Text
            fl.Parent = b
            Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)
        elseif sliderType == "Alpha" then
            fl = Instance.new("Frame", b)
            fl.BackgroundColor3 = CurrentAccentColor
            fl.Parent = b
            Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)
            table.insert(DynamicUIElements.Backgrounds, fl)
        end

        local k = Instance.new("Frame", b)
        k.Size = UDim2.new(0, 14, 0, 14)
        k.BackgroundColor3 = UITheme.Text
        k.Parent = b
        Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)

        local function updateUI()
            local val = CheatSettings[settingKey]
            local r = (sliderType == "Hue") and val or (val / maxVal)
            
            if sliderType == "Hue" then
                k.BackgroundColor3 = Color3.fromHSV(r, 1, 1)
                t.Text = lbl
            else
                if fl then fl.Size = UDim2.new(r, 0, 1, 0) end
                t.Text = lbl .. ": " .. val .. "%"
            end
            k.Position = UDim2.new(r, -7, 0.5, -7)
        end
        table.insert(UIUpdaters, updateUI)
        
        local d = false
        local function mv(x)
            local ap = b.AbsolutePosition.X
            local as = b.AbsoluteSize.X
            if as <= 0 then return end
            local r = math.clamp((x - ap) / as, 0, 1)
            CheatSettings[settingKey] = (sliderType == "Hue") and r or math.floor(r * maxVal)
            updateUI()
            
            if settingKey == "MenuHue" or settingKey == "MenuSat" or settingKey == "MenuVal" then 
                TriggerUpdaters() 
            end
        end
        
        f.InputBegan:Connect(function(ip) 
            if ip.UserInputType == Enum.UserInputType.MouseButton1 or ip.UserInputType == Enum.UserInputType.Touch then 
                d = true mv(ip.Position.X) 
            end 
        end)
        UserInputService.InputChanged:Connect(function(ip) 
            if d and (ip.UserInputType == Enum.UserInputType.MouseMovement or ip.UserInputType == Enum.UserInputType.Touch) then 
                mv(UserInputService:GetMouseLocation().X) 
            end 
        end)
        UserInputService.InputEnded:Connect(function(ip) 
            if d and (ip.UserInputType == Enum.UserInputType.MouseButton1 or ip.UserInputType == Enum.UserInputType.Touch) then 
                d = false 
                SaveSettings() 
            end 
        end)
    end
    
    makeSingleSlider("Color (Hue)", 1, "Hue", hueKey)
    if satKey then makeSingleSlider("Saturation (0=White)", 100, "Sat", satKey) end
    if valKey then makeSingleSlider("Brightness (0=Black)", 100, "Val", valKey) end
    if alphaKey then makeSingleSlider("Transparency", 100, "Alpha", alphaKey) end
    return wrap
end

local SliderFovRadius, MenuFovColor
local BtnEspEnemy, MenuEspEnemy
local BtnEspAlly, MenuEspAlly

local function UpdateMenuVisibility()
    if SliderFovRadius then SliderFovRadius.Visible = CheatSettings.AimbotEnabled or CheatSettings.FovVisible end
    if MenuFovColor then MenuFovColor.Visible = CheatSettings.FovVisible end
    if BtnEspEnemy then BtnEspEnemy.Visible = CheatSettings.EspEnabled end
    if MenuEspEnemy then MenuEspEnemy.Visible = CheatSettings.EspEnabled end
    if BtnEspAlly then BtnEspAlly.Visible = CheatSettings.EspEnabled end
    if MenuEspAlly then MenuEspAlly.Visible = CheatSettings.EspEnabled end
end
table.insert(UIUpdaters, UpdateMenuVisibility)

CreateToggle(TabAimbot, "[ AIMBOT ]", "AimbotEnabled", UITheme.Red, 1, UpdateMenuVisibility)
CreateModeToggle(TabAimbot, "[ AIM MODE ]", "AimbotMode", {"Always", "On RMB"}, 2)
CreateToggle(TabAimbot, "[ TEAM CHECK ]", "TeamCheck", UITheme.Red, 3)
CreateSlider(TabAimbot, "Head Chance %", "HeadChance", 0, 100, 4)
CreateSlider(TabAimbot, "Max Distance", "MaxDistance", 0, 5000, 5)

CreateToggle(TabAimbot, "[ FOV CIRCLE ]", "FovVisible", UITheme.Red, 6, UpdateMenuVisibility)
SliderFovRadius = CreateSlider(TabAimbot, "FOV Radius", "FovRadius", 0, 1000, 7)
MenuFovColor = CreateHueMenu(TabAimbot, "FOV Options", 8, "FovHue", "FovSat", "FovVal", "FovTransparency")

CreateToggle(TabEsp, "[ ESP ]", "EspEnabled", UITheme.Red, 1, UpdateMenuVisibility)
BtnEspEnemy, _ = CreateToggle(TabEsp, "[ ENEMIES ESP ]", "EspEnemies", UITheme.Red, 2)
MenuEspEnemy = CreateHueMenu(TabEsp, "Enemies Color", 3, "EspEnemyHue", "EspEnemySat", "EspEnemyVal", "EspEnemyTransp")
BtnEspAlly, _ = CreateToggle(TabEsp, "[ ALLIES ESP ]", "EspAllies", UITheme.Red, 4)
MenuEspAlly = CreateHueMenu(TabEsp, "Allies Color", 5, "EspAllyHue", "EspAllySat", "EspAllyVal", "EspAllyTransp")

CreateHueMenu(TabSettings, "UI Accent Color", 1, "MenuHue", "MenuSat", "MenuVal", nil)

local isBinding = false
local PanicKeyLabel
_, PanicKeyLabel = CreateAction(TabSettings, "[ PANIC KEY ] : " .. CheatSettings.PanicKey, UITheme.Container, 2, function(btn, lbl)
    if isBinding then return end
    isBinding = true
    lbl.Text = "Press any key..."
    local conn
    conn = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            CheatSettings.PanicKey = input.KeyCode.Name
            lbl.Text = "[ PANIC KEY ] : " .. CheatSettings.PanicKey
            SaveSettings()
            isBinding = false
            conn:Disconnect()
        end
    end)
end)
table.insert(UIUpdaters, function()
    if PanicKeyLabel then PanicKeyLabel.Text = "[ PANIC KEY ] : " .. CheatSettings.PanicKey end
end)

CreateAction(TabSettings, "[ RESET SETTINGS ]", UITheme.DarkRed, 3, function(btn, lbl)
    CheatSettings.AimbotEnabled = false
    CheatSettings.AimbotMode = "Always"
    CheatSettings.TeamCheck = false
    CheatSettings.HeadChance = 0
    CheatSettings.MaxDistance = 0
    CheatSettings.FovVisible = false
    CheatSettings.FovRadius = 0
    CheatSettings.FovHue = 0.33
    CheatSettings.FovSat = 100
    CheatSettings.FovVal = 100
    CheatSettings.FovTransparency = 0
    CheatSettings.EspEnabled = false
    CheatSettings.EspEnemies = false
    CheatSettings.EspEnemyHue = 0.0
    CheatSettings.EspEnemySat = 100
    CheatSettings.EspEnemyVal = 100
    CheatSettings.EspEnemyTransp = 0
    CheatSettings.EspAllies = false
    CheatSettings.EspAllyHue = 0.6
    CheatSettings.EspAllySat = 100
    CheatSettings.EspAllyVal = 100
    CheatSettings.EspAllyTransp = 0
    CheatSettings.MenuHue = 0.33
    CheatSettings.MenuSat = 100
    CheatSettings.MenuVal = 100
    
    TriggerUpdaters()
    SaveSettings()
    
    lbl.Text = "RESET SUCCESSFUL!"
    task.delay(1.5, function() lbl.Text = "[ RESET SETTINGS ]" end)
end)

CreateAction(TabAbout, "[ YOUTUBE ] @mmd_scripts", UITheme.Container, 1, function(btn, lbl)
    if setclipboard then
        pcall(function() setclipboard("https://youtube.com/@mmd_scripts") end)
        lbl.Text = "Copied YouTube!"
    else
        lbl.Text = "@mmd_scripts"
    end
    task.delay(1.5, function() lbl.Text = "[ YOUTUBE ] @mmd_scripts" end)
end)

CreateAction(TabAbout, "[ TIKTOK ] @mmd_scripts", UITheme.Container, 2, function(btn, lbl)
    if setclipboard then
        pcall(function() setclipboard("https://tiktok.com/@mmd_scripts") end)
        lbl.Text = "Copied TikTok!"
    else
        lbl.Text = "@mmd_scripts"
    end
    task.delay(1.5, function() lbl.Text = "[ TIKTOK ] @mmd_scripts" end)
end)

local isDraggingWindow = false
local dragInputPoint = nil
local dragStartScreenPos = nil
local hasDragged = false

local function SetupDrag(triggerFrame)
    local dragBegan = triggerFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingWindow = true
            hasDragged = false
            dragInputPoint = input.Position
            local targetObj = MainFrame.Visible and MainFrame or FloatingBall
            dragStartScreenPos = targetObj.Position
        end
    end)
    table.insert(ScriptConnections, dragBegan)
end

SetupDrag(TopBar)
SetupDrag(FloatingBall)
SetupDrag(BottomDragBar)

local dragChanged = UserInputService.InputChanged:Connect(function(input)
    if isDraggingWindow and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragInputPoint
        if delta.Magnitude > 3 then
            hasDragged = true
        end
        local targetObj = MainFrame.Visible and MainFrame or FloatingBall
        
        local newXOffset = dragStartScreenPos.X.Offset + delta.X
        local newYOffset = dragStartScreenPos.Y.Offset + delta.Y
        
        local screenSize = Camera.ViewportSize
        local objSize = targetObj.AbsoluteSize
        
        local minX = objSize.X / 2
        local maxX = screenSize.X - (objSize.X / 2)
        local minY = objSize.Y / 2
        local maxY = screenSize.Y - (objSize.Y / 2)
        
        newXOffset = math.clamp(newXOffset, minX, maxX)
        newYOffset = math.clamp(newYOffset, minY, maxY)

        targetObj.Position = UDim2.new(0, newXOffset, 0, newYOffset)
    end
end)
table.insert(ScriptConnections, dragChanged)

local dragEnded = UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        isDraggingWindow = false 
    end
end)
table.insert(ScriptConnections, dragEnded)

local isMinimized = false

local function ToggleMinimize()
    if not IsCheatLoaded or IsCompletelyHidden then return end
    isMinimized = not isMinimized
    
    if isMinimized then
        local tween = CreateTween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        tween.Completed:Connect(function()
            if isMinimized then
                MainFrame.Visible = false
                FloatingBall.Position = MainFrame.Position
                FloatingBall.Size = UDim2.new(0, 0, 0, 0)
                FloatingBall.Visible = true
                CreateTween(FloatingBall, {Size = UDim2.new(0, 50, 0, 50)}, 0.3)
            end
        end)
    else
        local tween = CreateTween(FloatingBall, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        tween.Completed:Connect(function()
            if not isMinimized then
                FloatingBall.Visible = false
                MainFrame.Position = FloatingBall.Position
                MainFrame.Size = UDim2.new(0, 0, 0, 0)
                MainFrame.Visible = true
                CreateTween(MainFrame, {Size = UDim2.new(0, WindowWidth, 0, WindowHeight)}, 0.3)
            end
        end)
    end
end

MinimizeButton.MouseButton1Click:Connect(function()
    ToggleMinimize()
end)

FloatingBall.MouseButton1Click:Connect(function()
    if hasDragged then return end
    ToggleMinimize()
end)

local panicConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if isBinding then return end
    if input.KeyCode.Name == CheatSettings.PanicKey then
        IsCompletelyHidden = not IsCompletelyHidden
        if IsCompletelyHidden then
            MainFrame.Visible = false
            FloatingBall.Visible = false
        else
            if isMinimized then
                FloatingBall.Visible = true
            else
                MainFrame.Visible = true
            end
        end
    end
end)
table.insert(ScriptConnections, panicConn)

local function IsTeammate(player)
    if not CheatSettings.TeamCheck then 
        return false 
    end
    if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then 
        return true 
    end
    local success, isSameColor = pcall(function()
        return player.TeamColor == LocalPlayer.TeamColor
    end)
    if success and isSameColor then
        return true
    end
    return false
end

local FovScreenGui = Instance.new("ScreenGui")
FovScreenGui.Name = HttpService:GenerateGUID(false)
FovScreenGui.ResetOnSpawn = false
FovScreenGui.IgnoreGuiInset = true
FovScreenGui.Parent = TargetGuiParent

local FovCircle = Instance.new("Frame")
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FovCircle.BackgroundTransparency = 1
FovCircle.Visible = false
FovCircle.Parent = FovScreenGui

local FovCircleCorner = Instance.new("UICorner")
FovCircleCorner.CornerRadius = UDim.new(1, 0)
FovCircleCorner.Parent = FovCircle

local FovCircleStroke = Instance.new("UIStroke")
FovCircleStroke.Thickness = 2
FovCircleStroke.Parent = FovCircle

local function AttachEspToPlayer(player)
    if player == LocalPlayer then return end
    
    local success, square = pcall(function()
        return Drawing.new("Square")
    end)
    
    if success and square then
        square.Thickness = 1.5
        square.Filled = false
        square.Visible = false
        EspInstances[player] = { box = square }
    end
end

local playerAddedConn = Players.PlayerAdded:Connect(AttachEspToPlayer)
table.insert(ScriptConnections, playerAddedConn)

local playerRemovedConn = Players.PlayerRemoving:Connect(function(player)
    if EspInstances[player] and EspInstances[player].box then 
        pcall(function()
            EspInstances[player].box:Remove() 
        end)
        EspInstances[player] = nil 
    end
end)
table.insert(ScriptConnections, playerRemovedConn)

for _, p in pairs(Players:GetPlayers()) do 
    AttachEspToPlayer(p) 
end

local espRenderConn = RunService.RenderStepped:Connect(function()
    if not IsCheatLoaded then
        FovCircle.Visible = false
        for _, espData in pairs(EspInstances) do 
            if espData.box then espData.box.Visible = false end 
        end
        return
    end

    if CheatSettings.FovVisible and CheatSettings.FovRadius > 0 then
        FovCircle.Size = UDim2.new(0, CheatSettings.FovRadius * 2, 0, CheatSettings.FovRadius * 2)
        FovCircleStroke.Color = Color3.fromHSV(CheatSettings.FovHue, CheatSettings.FovSat / 100, CheatSettings.FovVal / 100)
        FovCircleStroke.Transparency = CheatSettings.FovTransparency / 100
        FovCircle.Visible = true
    else
        FovCircle.Visible = false
    end

    for player, espData in pairs(EspInstances) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("Head"))
        
        if CheatSettings.EspEnabled and rootPart and humanoid and humanoid.Health > 0 then
            local isTeam = IsTeammate(player)
            local shouldShow = (isTeam and CheatSettings.EspAllies) or (not isTeam and CheatSettings.EspEnemies)
            
            if shouldShow then
                local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
                if distance <= CheatSettings.MaxDistance then
                    local screenPosition, isVisible = Camera:WorldToViewportPoint(rootPart.Position)
                    if isVisible then
                        espData.box.Size = Vector2.new(14, 14)
                        espData.box.Position = Vector2.new(screenPosition.X - 7, screenPosition.Y - 7)
                        
                        if isTeam then
                            espData.box.Color = Color3.fromHSV(CheatSettings.EspAllyHue, CheatSettings.EspAllySat / 100, CheatSettings.EspAllyVal / 100)
                            espData.box.Transparency = CheatSettings.EspAllyTransp / 100
                        else
                            espData.box.Color = Color3.fromHSV(CheatSettings.EspEnemyHue, CheatSettings.EspEnemySat / 100, CheatSettings.EspEnemyVal / 100)
                            espData.box.Transparency = CheatSettings.EspEnemyTransp / 100
                        end
                        
                        espData.box.Visible = true
                    else
                        espData.box.Visible = false
                    end
                else
                    espData.box.Visible = false
                end
            else
                espData.box.Visible = false
            end
        else
            espData.box.Visible = false
        end
    end
end)
table.insert(ScriptConnections, espRenderConn)

local function FetchOptimalTarget()
    local bestTarget = nil
    local bestDotProduct = -1
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        local skipPlayer = false
        if CheatSettings.TeamCheck and IsTeammate(player) then
            skipPlayer = true
        end
        
        if player ~= LocalPlayer and player.Character and not skipPlayer then
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            if head and humanoid and humanoid.Health > 0 then
                local dist = (head.Position - Camera.CFrame.Position).Magnitude
                if dist <= CheatSettings.MaxDistance then
                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                    
                    local origin = Camera.CFrame.Position
                    local direction = (head.Position - origin).Unit * dist
                    local hitResult = workspace:Raycast(origin, direction, rayParams)
                    
                    if not hitResult or (hitResult.Position - head.Position).Magnitude < 3 then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local distanceFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if distanceFromCenter <= CheatSettings.FovRadius then
                                local dotProduct = Camera.CFrame.LookVector:Dot((head.Position - Camera.CFrame.Position).Unit)
                                if dotProduct > bestDotProduct then 
                                    bestDotProduct = dotProduct
                                    bestTarget = player 
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

local activeTarget = nil
local activeBodyPart = nil

local aimbotRenderConn = RunService.RenderStepped:Connect(function()
    if not IsCheatLoaded or not CheatSettings.AimbotEnabled then 
        activeTarget = nil 
        return 
    end
    
    if not IsAimKeyPressed() then
        activeTarget = nil
        return
    end
    
    local foundTarget = FetchOptimalTarget()
    
    if foundTarget then
        if foundTarget ~= activeTarget then
            activeTarget = foundTarget
            
            local randomRoll = math.random(1, 100)
            if randomRoll <= CheatSettings.HeadChance then
                activeBodyPart = foundTarget.Character:FindFirstChild("Head")
            else
                activeBodyPart = foundTarget.Character:FindFirstChild("HumanoidRootPart") 
                              or foundTarget.Character:FindFirstChild("Torso") 
                              or foundTarget.Character:FindFirstChild("Head")
            end
        end
        
        if activeBodyPart and activeBodyPart.Parent then 
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, activeBodyPart.Position) 
        else 
            activeTarget = nil 
        end
    else
        activeTarget = nil
    end
end)
table.insert(ScriptConnections, aimbotRenderConn)

task.spawn(function()
    TriggerUpdaters()
    local textString = "BY MMD SCRIPTS"
    local letterLabels = {}
    
    for i = 1, #textString do
        local letter = textString:sub(i, i)
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Text = letter
        lbl.Font = Enum.Font.GothamBlack
        lbl.TextSize = 36
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.TextTransparency = 1
        
        if letter == " " then
            lbl.Size = UDim2.new(0, 10, 1, 0)
        else
            lbl.AutomaticSize = Enum.AutomaticSize.X
            lbl.Size = UDim2.new(0, 0, 1, 0)
        end
        
        lbl.Parent = WaveFrame
        table.insert(letterLabels, lbl)
    end
    
    local animTime = 0
    local rgbConnection
    
    CreateTween(LoadingContainer, {BackgroundTransparency = 0.2}, 0.5)
    task.wait(0.2)
    
    CreateTween(WaveFrame, {Position = UDim2.new(0.5, 0, 0.5, 0)}, 1.2, Enum.EasingStyle.Quart)
    
    rgbConnection = RunService.RenderStepped:Connect(function(dt)
        animTime = animTime + (dt * 3)
        for i, lbl in ipairs(letterLabels) do
            local waveOffset = math.sin(animTime + (i * 0.4)) * 12
            lbl.Position = UDim2.new(0, 0, 0, waveOffset)
            local colorPhase = (math.sin(animTime * 1.5 - (i * 0.2)) + 1) / 2
            lbl.TextColor3 = Color3.fromRGB(
                math.floor(colorPhase * 50),
                math.floor(100 + colorPhase * 155),
                255
            )
        end
    end)

    for i, lbl in ipairs(letterLabels) do
        CreateTween(lbl, {TextTransparency = 0}, 0.5)
        task.wait(0.03)
    end
    
    task.wait(2.5)
    
    CreateTween(WaveFrame, {Position = UDim2.new(1.5, 0, 0.5, 0)}, 1.0, Enum.EasingStyle.Quart)
    
    for i, lbl in ipairs(letterLabels) do
        CreateTween(lbl, {TextTransparency = 1}, 0.3)
        task.wait(0.02)
    end
    
    task.wait(0.5)
    if rgbConnection then rgbConnection:Disconnect() end
    CreateTween(LoadingContainer, {BackgroundTransparency = 1}, 0.5).Completed:Connect(function()
        LoadingContainer:Destroy()
        
        IsCheatLoaded = true
        MainFrame.Visible = true
        local viewportCenter = Camera.ViewportSize / 2
        MainFrame.Position = UDim2.new(0, viewportCenter.X, 0, viewportCenter.Y)
        CreateTween(MainFrame, {Size = UDim2.new(0, WindowWidth, 0, WindowHeight)}, 0.6, Enum.EasingStyle.Back)
    end)
end)

getgenv().mmd_scripts_cheat.Destroy = function()
    for _, connection in pairs(ScriptConnections) do 
        connection:Disconnect() 
    end
    if MainGui then MainGui:Destroy() end
    if FovScreenGui then FovScreenGui:Destroy() end
    for _, espData in pairs(EspInstances) do 
        if espData.box then 
            pcall(function() espData.box:Remove() end)
        end 
    end
end
