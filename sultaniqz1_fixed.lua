local Players =
game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Client = Players.LocalPlayer

local PlayerGui = Client:WaitForChild("PlayerGui")
local Connections = {}

local ConfigFileName = "TestHub_Config.json"
local DefaultConfig = {
    WalkSpeed = false,
    SpeedMultiplier = 1,
    JumpPower = false,
    InfStamina = false,
    AntiDead = false,
    AntiLock = false,
    AntiRagdoll = false,
    AntiAutoSit = false,
    HideName = false,
    AutoRespawn = false,
    Snap = false,
    SnapAmount = 10,
    FlyCar = false,
    FlyCarSpeed = 30,
    CarRamAura = false,
    CarSnap = false,
    ShowFOV = false,
    MultiShoot = false,
    FireRateGun = 850,   
    RecoilGun = 0,      
    AccuracyGun = 100,   
    AutomaticGun = false,  
    AimMode = "โหมดยิงเซฟ",
    FOVRadius = 150,
    SkeletonPlayerVisual = false,
    HealthPlayerVisual = false,
    NamePlayerVisual = false,
    DistancePlayerVisual = false,
    InventoryPlayerVisual = false,
    FireRateValue = 850,
    SettingsApplied = false,
    HoldFire = false,
    NoRecoilAccuracy = false,
}

local function LoadConfig()
    local cfg = {}
    for k, v in pairs(DefaultConfig) do cfg[k] = v end
    pcall(function()
        if isfile and readfile and isfile(ConfigFileName) then
            local decoded = HttpService:JSONDecode(readfile(ConfigFileName))
            if type(decoded) == "table" then
                for k, v in pairs(decoded) do cfg[k] = v end
            end
        end
    end)
    return cfg
end

getgenv().TestHubConfig = LoadConfig()
local function c() return getgenv().TestHubConfig end

local function SaveConfig()
    pcall(function()
        if writefile then
            writefile(ConfigFileName, HttpService:JSONEncode(c()))
        end
    end)
end

local Done = false

local function pressButton(guiObject)
    if not guiObject then return end
    pcall(function() guiObject:Activate() end)
    pcall(function() firesignal(guiObject.MouseButton1Click) end)
    pcall(function() firesignal(guiObject.Activated) end)
end

local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local Network
pcall(function()
    Network = require(ReplicatedStorage.Modules.Core.Net)
end)

local function checkInMenu()
    local splashScreenGui = PlayerGui:FindFirstChild("SplashScreenGui")
    if splashScreenGui and splashScreenGui.Enabled then
        local frame = splashScreenGui:FindFirstChild("Frame")
        local playButton = frame and frame:FindFirstChild("PlayButton")
        if playButton and playButton.Visible then
            return true
        end
    end
    return Client:GetAttribute("InMenuCharacterCreator") or false
end

local function ApplySalmonBypass()
    if getgenv then getgenv().identifyexecutor = nil end
    if getfenv then getfenv().identifyexecutor = nil end

    local Net = require(ReplicatedStorage.Modules.Core.Net)
    local getFunc = debug.getupvalue or getupvalue
    local setConst = debug.setconstant or setconstant

    if getFunc and setConst and not _G.SalmonBypassed then
        local func = getFunc(Net.get, 2)
        if type(func) == "function" then
            pcall(function()
                setConst(func, 3, "Bypass")
                setConst(func, 4, "Bypass")
            end)
        end
        _G.SalmonBypassed = true
    end
end

if checkInMenu() then
    local FONT = Enum.Font.GothamBold

    local blurEffect = Instance.new("DepthOfFieldEffect")
    blurEffect.Name = "TestHub_DOF"
    blurEffect.FarIntensity = 1.2
    blurEffect.FocusDistance = 2
    blurEffect.InFocusRadius = 1
    blurEffect.Parent = Lighting

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TestHub_Entry"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = PlayerGui

    local main = Instance.new("CanvasGroup")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, 330, 0, 172)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    main.BackgroundTransparency = 1
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = screenGui

    local uiScale = Instance.new("UIScale")
    uiScale.Scale = 0
    uiScale.Parent = main

    local bgImage = Instance.new("ImageLabel")
    bgImage.Name = "BackgroundImage"
    bgImage.Size = UDim2.new(1, 0, 1, 0)
    bgImage.Position = UDim2.new(0, 0, 0, 0)
    bgImage.BackgroundTransparency = 1
    bgImage.Image = "rbxassetid://103857318083299"
    bgImage.ScaleType = Enum.ScaleType.Crop
    bgImage.ImageTransparency = 0.1
    bgImage.ZIndex = 1
    bgImage.Parent = main
    Instance.new("UICorner", bgImage).CornerRadius = UDim.new(0, 17)

    local softVignette = Instance.new("Frame")
    softVignette.Size = UDim2.new(1, 0, 1, 0)
    softVignette.BackgroundTransparency = 0.75
    softVignette.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    softVignette.BorderSizePixel = 0
    softVignette.ZIndex = 1
    softVignette.Parent = main
    Instance.new("UICorner", softVignette).CornerRadius = UDim.new(0, 14)

    local borderFrame = Instance.new("Frame")
    borderFrame.Size = UDim2.new(1, -6, 1, -6)
    borderFrame.Position = UDim2.new(0, 3, 0, 3)
    borderFrame.BackgroundTransparency = 1
    borderFrame.ZIndex = 10
    borderFrame.Parent = main
    Instance.new("UICorner", borderFrame).CornerRadius = UDim.new(0, 14)

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Thickness = 4
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    mainStroke.Color = Color3.fromRGB(255, 255, 255)
    mainStroke.Parent = borderFrame

    local strokeGradient = Instance.new("UIGradient")
    strokeGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.55, Color3.fromRGB(140, 140, 145)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 40))
    })
    strokeGradient.Rotation = 50
    strokeGradient.Parent = mainStroke

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 32)
    title.Position = UDim2.new(0, 0, 0, 16)
    title.BackgroundTransparency = 1
    title.Text = "Sultaniqz"
    title.Font = FONT
    title.TextSize = 22
    title.TextColor3 = Color3.fromRGB(245, 245, 250)
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.ZIndex = 2
    title.Parent = main

    local function createModeButton(txt, yPos, isGodMode)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 285, 0, 44)
        btn.AnchorPoint = Vector2.new(0.5, 0.5)
        btn.Position = UDim2.new(0.5, 0, 0, yPos + 22)
        btn.Font = FONT
        btn.TextSize = 14
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = txt
        btn.AutoButtonColor = false
        btn.ZIndex = 2
        btn.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
        btn.BackgroundTransparency = 0.72
        btn.Parent = main

        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)

        local btnStroke = Instance.new("UIStroke")
        btnStroke.Thickness = 1
        btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        btnStroke.Parent = btn

        if isGodMode then
            btnStroke.Color = Color3.fromRGB(255, 255, 255)
            btnStroke.Transparency = 0.4
            local btnGradient = Instance.new("UIGradient")
            btnGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 90, 95))
            })
            btnGradient.Rotation = 45
            btnGradient.Parent = btnStroke
        else
            btnStroke.Color = Color3.fromRGB(200, 200, 210)
            btnStroke.Transparency = 0.68
        end

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 295, 0, 48),
                BackgroundTransparency = 0.5
            }):Play()
        end)

        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 285, 0, 44),
                BackgroundTransparency = 0.72
            }):Play()
        end)

        return btn
    end

    local normalBtn = createModeButton("โหมดปกติ", 60, false)
    local godBtn    = createModeButton("โหมดพระเจ้า", 112, true)

    task.delay(0.2, function()
        TweenService:Create(uiScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
    end)

    local function destroyUI()
        TweenService:Create(uiScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Scale = 0 }):Play()
        if blurEffect then
            TweenService:Create(blurEffect, TweenInfo.new(0.25), { FarIntensity = 0 }):Play()
            task.delay(0.25, function() blurEffect:Destroy() end)
        end
        task.wait(0.3)
        screenGui:Destroy()
    end

    local function StartFlow(isGodMode)
        destroyUI()
        task.spawn(function()
            local Net = require(ReplicatedStorage.Modules.Core.Net)
            ApplySalmonBypass()

            if isGodMode then
                local oldSend
                oldSend = hookfunction(Net.send, function(...)
                    local d = {...}
                    if d[1] == "leave_character_creator" or d[1] == "player_created_outfit" then
                        return nil
                    end
                    return oldSend(...)
                end)
            end

            task.wait(0.5)
            local splashGui = PlayerGui:FindFirstChild("SplashScreenGui")
            if splashGui and splashGui.Enabled then
                local frame = splashGui:FindFirstChild("Frame")
                local playBtn = frame and frame:FindFirstChild("PlayButton")
                if playBtn then pressButton(playBtn) end
            end

            local startWait = tick()
            while tick() - startWait < 6 do
                local charCreator = PlayerGui:FindFirstChild("CharacterCreator")
                local menuFrame = charCreator and charCreator:FindFirstChild("MenuFrame")
                local skipBtn = menuFrame and menuFrame:FindFirstChild("AvatarMenuSkipButton")
                if skipBtn and skipBtn.Visible then
                    pressButton(skipBtn)
                    break
                end
                task.wait(0.1)
            end

            if isGodMode then
                task.wait(3.5)
                pcall(function() replicatesignal(Client.Kill) end)
                task.wait(6)
                local respawnLimit = tick() + 8
                while tick() < respawnLimit do
                    Net.send("death_screen_request_respawn")
                    task.wait(0.25)
                    local newChar = Client.Character
                    if newChar and newChar:FindFirstChild("Humanoid") and newChar.Humanoid.Health > 0 then
                        break
                    end
                end
            end

            Done = true
        end)
    end

    normalBtn.MouseButton1Click:Connect(function() StartFlow(false) end)
    godBtn.MouseButton1Click:Connect(function() StartFlow(true) end)
else
    Done = true
end

repeat task.wait() until Done

local GC_Counter = nil
pcall(function()
    for _, item in ipairs(getgc(true)) do
        if typeof(item) == "table" and rawget(item, "event") and rawget(item, "func") then
            GC_Counter = item
            break
        end
    end
end)

task.spawn(function()
    local CrateController
    repeat
        pcall(function()
            CrateController = require(ReplicatedStorage.Modules.Game.CrateSystem.Crate)
        end)
        task.wait(0.5)
    until CrateController

    while true do
        pcall(function()
            if CrateController.class and CrateController.class.objects then
                for _, crate in pairs(CrateController.class.objects) do
                    if crate.states and crate.states.open and crate.states.open.set then
                        crate.states.open.set(true)
                    end
                    if CrateController.skipping and CrateController.skipping.set then
                        CrateController.skipping.set(true)
                    end
                end
            end
            if CrateController.spinning and CrateController.skip_spin then
                if not CrateController.spinning.get() then
                    CrateController.skip_spin()
                end
            end
        end)
        task.wait(0.05)
    end
end)

task.spawn(function()

    pcall(function()
        local FlagManager = require(ReplicatedStorage.Modules.Game.GameInfo.FlagManager)
        if FlagManager then
            FlagManager.FLAG_HOLD_SELL_BUTTON = false
        end
    end)

    pcall(function()
        local Util = require(ReplicatedStorage.Modules.Core.Util)
        if Util and Util.tween then
            local oldTween = Util.tween
            Util.tween = function(instance, tweenInfo, properties)
                if instance and instance:IsA("NumberValue") and properties and properties.Value ~= nil then
                    instance.Value = properties.Value
                    return { Cancel = function() end }
                end
                return oldTween(instance, tweenInfo, properties)
            end
        end
    end)

    pcall(function()
        local BuyPromptUI = require(ReplicatedStorage.Modules.Game.UI.BuyPromptUI)
        local sellBtn = BuyPromptUI.get("SellPromptSellButton")
        if sellBtn then
            local holdStroke = sellBtn:FindFirstChild("HoldStroke", true)
            if holdStroke then
                holdStroke.Enabled = false
                local gradient = holdStroke:FindFirstChildOfClass("UIGradient")
                if gradient then gradient.Enabled = false end
            end
            for _, desc in ipairs(sellBtn:GetDescendants()) do
                if desc:IsA("NumberValue") then desc.Value = 1 end
            end
        end
    end)
end)

local function HookDoorPart(part)
    if not part:IsA("BasePart") then return end
    local name = part.Name:lower()
    local parentName = part.Parent and part.Parent.Name:lower() or ""

    if name:find("door") or parentName:find("door") or name:find("gate") or parentName:find("gate") or name:find("hinge") then
        part.CanCollide = false

        part:GetPropertyChangedSignal("CanCollide"):Connect(function()
            if part.CanCollide then
                part.CanCollide = false
            end
        end)
    end
end

task.spawn(function()
    local map = workspace:WaitForChild("Map", 20) or workspace
    for _, desc in ipairs(map:GetDescendants()) do
        HookDoorPart(desc)
    end

    workspace.DescendantAdded:Connect(function(desc)
        HookDoorPart(desc)
    end)
end)

task.spawn(function()
    local FINISH_PROMPT_DISTANCE = 22

    local function ApplyFinishPromptReach(prompt)
        if prompt:IsA("ProximityPrompt") and prompt.Name == "FinishPrompt" then
            prompt.MaxActivationDistance = FINISH_PROMPT_DISTANCE
            prompt.RequiresLineOfSight = false 
        end
    end

    local function SetupPlayerPrompts(player)
        if player == Client then return end

        local function ScanCharacter(char)
            char.DescendantAdded:Connect(ApplyFinishPromptReach)
            for _, desc in ipairs(char:GetDescendants()) do
                ApplyFinishPromptReach(desc)
            end
        end

        player.CharacterAdded:Connect(ScanCharacter)
        if player.Character then
            ScanCharacter(player.Character)
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        SetupPlayerPrompts(player)
    end
    Players.PlayerAdded:Connect(SetupPlayerPrompts)
end)

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local SendRemote = RemotesFolder:WaitForChild("Send")

local function SendRemoteAction(...)
    local args = {...}
    if GC_Counter and typeof(GC_Counter.event) == "number" then
        GC_Counter.event = GC_Counter.event + 1
        pcall(function() SendRemote:FireServer(GC_Counter.event, table.unpack(args)) end)
    else
        pcall(function() SendRemote:FireServer(table.unpack(args)) end)
    end
end

local Character = Client.Character or Client.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

Client.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
end)

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Sultaniqz",
    Icon = "rbxassetid://122488606489577",
    Author = "[🔪] Block Spin",
    Folder = "TestHub",
    Size = UDim2.fromOffset(620, 500),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 230,
    HasOutline = true,
    User = {
        Enabled   = true,
        Anonymous = false,
        Name      = Client.Name,
        Image     = "rbxthumb://type=AvatarHeadShot&id=" .. Client.UserId .. "&w=150&h=150",
        Callback  = function()
        end
    }
})

Window:Tag({
    Title = "PVP | Paid",
    Icon = "github",
    Color = Color3.fromHex("#E60000"),
    Radius = 8, 
})

Window:EditOpenButton({
    Title = "Sultaniqz | Block Spin",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("#1a1a1a"), Color3.fromHex("#FF0000")),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

local MainTab = Window:Tab({ Title = "ผู้เล่น", Icon = "user" })
local AimTab = Window:Tab({ Title = "ล็อคเป้า", Icon = "crosshair" })
local swordsTab = Window:Tab({ Title = "อาวุธ", Icon = "layers" })
local VisualTab = Window:Tab({ Title = "ไฮไลท์", Icon = "eye" })
local VehicleTab = Window:Tab({ Title = "รถ", Icon = "car" })
local ServerTab = Window:Tab({ Title = "เซิร์ฟเวอร์", Icon = "server" })
local MiscTab = Window:Tab({ Title = "การตั้งค่า", Icon = "settings" })

MainTab:Section({ Title = "ข้อมูล" })

local BankDisplay = MainTab:Button({ Title = "ธนาคาร", Desc = "กำลังโหลด..." })
local HandDisplay = MainTab:Button({ Title = "เงินสด", Desc = "กำลังโหลด..." })

task.spawn(function()
    while task.wait(0.3) do
        local bankMoney, handMoney = 0, 0
        pcall(function()
            local pGui = Client:FindFirstChild("PlayerGui")
            if pGui then
                local topHud = pGui:FindFirstChild("TopRightHud")
                local moneyLabel = topHud and topHud:FindFirstChild("MoneyTextLabel", true)
                if moneyLabel and moneyLabel.Text then
                    handMoney = tonumber(moneyLabel.Text:match("%$(%d+)")) or 0
                end
                for _, obj in ipairs(pGui:GetDescendants()) do
                    if obj:IsA("TextLabel") and string.find(obj.Text, "Bank Balance") then
                        bankMoney = tonumber(obj.Text:match("%$(%d+)")) or 0
                    end
                end
            end
        end)
        BankDisplay:SetDesc('<b><font color="#FF0000">$' .. bankMoney .. '</font></b>')
        HandDisplay:SetDesc('<b><font color="#FF0000">$' .. handMoney .. '</font></b>')
    end
end)

MainTab:Section({ Title = "ทั่วไป" })

table.insert(Connections, RunService.RenderStepped:Connect(function()
    if c().WalkSpeed and Humanoid and RootPart and Humanoid.Health > 0 then
        if Humanoid.MoveDirection.Magnitude > 0 then
            local state = Humanoid:GetState()
            local isSeated = Humanoid.Sit or Humanoid.SeatPart ~= nil or state == Enum.HumanoidStateType.Seated
            if not isSeated then
                local R = (c().SpeedMultiplier or 2) * 0.05
                RootPart.CFrame = RootPart.CFrame + (Humanoid.MoveDirection.Unit * R)
            end
        end
    end
end))

MainTab:Toggle({
    Title = "วิ่งเร็ว",
    Value = c().WalkSpeed or false,
    Callback = function(a2)
        c().WalkSpeed = a2
    end
})

MainTab:Slider({ 
    Title = "ปรับความวิ่งเร็ว", 
    Step = 0.1, 
    Value = { 
        Min = 1, 
        Max = 3, 
        Default = 1 
    }, 
    Callback = function(a3) 
        if c and c() then
            c().SpeedMultiplier = a3 
        end
    end 
})

local isHoldingJump = false
local FLY_VELOCITY = 40

local function HookMobileJump()
    task.spawn(function()
        local pGui = Client:WaitForChild("PlayerGui", 5)
        local touchGui = pGui and pGui:WaitForChild("TouchGui", 5)
        local touchFrame = touchGui and touchGui:WaitForChild("TouchControlFrame", 5)
        local jumpButton = touchFrame and touchFrame:WaitForChild("JumpButton", 5)

        if jumpButton then
            table.insert(Connections, jumpButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    isHoldingJump = true
                end
            end))
            table.insert(Connections, jumpButton.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    isHoldingJump = false
                end
            end))
        end
    end)
end

HookMobileJump()

table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Space then
        isHoldingJump = true
    end
end))

table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        isHoldingJump = false
    end
end))

Client.CharacterAdded:Connect(function()
    isHoldingJump = false
    HookMobileJump()
end)

table.insert(Connections, RunService.RenderStepped:Connect(function()
    local isKeyDown = UserInputService:IsKeyDown(Enum.KeyCode.Space)
    
    if c().JumpPower and (isHoldingJump or isKeyDown) and RootPart and Humanoid and Humanoid.Health > 0 then
        
        local isSeated = Humanoid.Sit 
            or Humanoid.SeatPart ~= nil 
            or Humanoid:GetState() == Enum.HumanoidStateType.Seated
        if isSeated then return end

        RootPart.AssemblyLinearVelocity = Vector3.new(
            RootPart.AssemblyLinearVelocity.X,
            FLY_VELOCITY,
            RootPart.AssemblyLinearVelocity.Z
        )
    end
end))

MainTab:Toggle({
    Title = "ซุปเปอร์กระโดด",
    Value = c().JumpPower or false,
    Callback = function(enabled)
        c().JumpPower = enabled
        if not enabled then
            isHoldingJump = false
        end
    end
})

local OriginalSprintUpdate = nil
local StaminaLoopThread = nil

local function ToggleInfiniteStamina(state)
    c().InfStamina = state

    if state then
        local success, sprintMod = pcall(function() return require(ReplicatedStorage.Modules.Game.Sprint) end)
        if success and sprintMod then
            local consumeFunc = sprintMod.consume_stamina
            local sprintUpvalue = debug.getupvalue(consumeFunc, 2)
            local sprintBar = sprintUpvalue and sprintUpvalue.sprint_bar
            
            if sprintBar then
                OriginalSprintUpdate = sprintBar.update
                sprintBar.update = function(...) return OriginalSprintUpdate(function() return 1 end) end
            end
        end

        if StaminaLoopThread then task.cancel(StaminaLoopThread) end
        StaminaLoopThread = task.spawn(function()
            while c().InfStamina do
                pcall(function()
                    SendRemoteAction("set_sprinting_1", true)
                    task.wait(0.5)
                    SendRemoteAction("set_sprinting_1", false)
                end)
                task.wait(0.1)
            end
            pcall(function() SendRemoteAction("set_sprinting_1", false) end)
        end)
    else
        if StaminaLoopThread then task.cancel(StaminaLoopThread) StaminaLoopThread = nil end
        pcall(function() SendRemoteAction("set_sprinting_1", false) end)
        if success and sprintMod and OriginalSprintUpdate then
            local consumeFunc = sprintMod.consume_stamina
            local sprintUpvalue = debug.getupvalue(consumeFunc, 2)
            local sprintBar = sprintUpvalue and sprintUpvalue.sprint_bar
            if sprintBar then
                sprintBar.update = OriginalSprintUpdate
                OriginalSprintUpdate = nil
            end
        end
    end
end

MainTab:Toggle({
    Title = "สเตมิน่าไม่จำกัด",
    Value = c().InfStamina or false,
    Callback = function(state)
        ToggleInfiniteStamina(state)
    end
})

MainTab:Section({ Title = "ฟังก์ชันที่ควรเปิด" })

local v1_isBurrowed = false
local v1_isResetting = false
local v1_originalY = 0
local v1_basePos = Vector3.zero
local v1_baseRotation = CFrame.identity
local v1_camPart = nil
local v1_currentHum = nil
local v1_healthConn = nil
local v1_partOffsets = {}

local v1_flickerOffset = Vector3.zero
local v1_isFlickering = false
local V1_MOVE_RADIUS = 6

local function StartBurrowFlicker()
    if v1_isFlickering then return end
    v1_isFlickering = true
    task.spawn(function()
        while v1_isFlickering and v1_isBurrowed do
            local angle = math.random() * math.pi * 2
            v1_flickerOffset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * V1_MOVE_RADIUS
            task.wait(0.05)
            v1_flickerOffset = Vector3.zero
            task.wait(0.1)
        end
        v1_flickerOffset = Vector3.zero
        v1_isFlickering = false
    end)
end

local function ForceKillCharacter_V1(char, hum, root)
    task.spawn(function()
        local killTimeout = os.clock() + 3
        while hum and hum.Health > 0 and os.clock() < killTimeout do
            pcall(function() replicatesignal(Client.Kill) end)
            pcall(function()
                hum:ChangeState(Enum.HumanoidStateType.Dead)
                hum.Health = 0
            end)
            pcall(function()
                if root then
                    root.AssemblyLinearVelocity = Vector3.new(0, -2000, 0)
                    root.CFrame = CFrame.new(root.Position.X, -3000, root.Position.Z)
                end
            end)
            task.wait(0.1)
        end
    end)
end

local function RestorePlayer_V1(char, root, hum)
    v1_isBurrowed = false
    v1_isResetting = false
    v1_isFlickering = false
    v1_flickerOffset = Vector3.zero
    v1_partOffsets = {}

    if v1_camPart then
        v1_camPart:Destroy()
        v1_camPart = nil
    end
    if Workspace.CurrentCamera and hum then
        Workspace.CurrentCamera.CameraSubject = hum
    end

    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide = (p.Name == "HumanoidRootPart" or p.Name:find("Torso") or p.Name == "Head")
        end
    end

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local rayResult = Workspace:Raycast(Vector3.new(v1_basePos.X, v1_originalY + 20, v1_basePos.Z), Vector3.new(0, -150, 0), rayParams)

    root.AssemblyLinearVelocity = Vector3.new(0, 5, 0)
    root.CFrame = CFrame.new(v1_basePos.X, (rayResult and (rayResult.Position.Y + 3) or v1_originalY), v1_basePos.Z) * v1_baseRotation
    hum:ChangeState(Enum.HumanoidStateType.Running)
end

local function TriggerAntiDeathInstant(char, root, hum)
    if c().AntiDeathV1 and hum.Health <= 15 and hum.Health > 0 and not v1_isBurrowed then
        v1_isBurrowed = true
        v1_isResetting = false
        v1_originalY = root.Position.Y

        v1_basePos = Vector3.new(root.Position.X, v1_originalY - 45, root.Position.Z)
        v1_baseRotation = root.CFrame.Rotation

        if v1_camPart then v1_camPart:Destroy() end
        v1_camPart = Instance.new("Part")
        v1_camPart.Name = "AntiDeathCamPart"
        v1_camPart.Anchored = true
        v1_camPart.CanCollide = false
        v1_camPart.Transparency = 1
        v1_camPart.Size = Vector3.new(1, 1, 1)
        v1_camPart.Position = Vector3.new(root.Position.X, v1_originalY + 2, root.Position.Z)
        v1_camPart.Parent = Workspace

        Workspace.CurrentCamera.CameraSubject = v1_camPart

        v1_partOffsets = {}
        local initialRootCF = root.CFrame
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                v1_partOffsets[part] = initialRootCF:ToObjectSpace(part.CFrame)
            end
        end

        root.AssemblyLinearVelocity = Vector3.zero
        root.CFrame = CFrame.new(root.Position.X, v1_originalY + 65, root.Position.Z)

        StartBurrowFlicker()
    end
end

table.insert(Connections, RunService.Heartbeat:Connect(function()
    local char = Client.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    if hum ~= v1_currentHum then
        if v1_healthConn then v1_healthConn:Disconnect() end
        v1_currentHum = hum
        v1_healthConn = hum.HealthChanged:Connect(function()
            TriggerAntiDeathInstant(char, root, hum)
        end)
    end

    if hum.Health <= 0 then
        v1_isBurrowed = false
        v1_isResetting = false
        v1_isFlickering = false
        v1_flickerOffset = Vector3.zero
        v1_partOffsets = {}
        if v1_camPart then
            v1_camPart:Destroy()
            v1_camPart = nil
        end
        if Workspace.CurrentCamera and hum then
            Workspace.CurrentCamera.CameraSubject = hum
        end
        return
    end

    TriggerAntiDeathInstant(char, root, hum)

    if v1_isBurrowed then

        if v1_camPart and Workspace.CurrentCamera and Workspace.CurrentCamera.CameraSubject ~= v1_camPart then
            Workspace.CurrentCamera.CameraSubject = v1_camPart
        end

        if hum.Health >= 31 and not v1_isResetting then
            v1_isResetting = true
            task.delay(0.5, function()
                if v1_isBurrowed and hum and hum.Health > 0 then
                    ForceKillCharacter_V1(char, hum, root)
                    v1_isBurrowed = false
                    v1_isResetting = false
                    v1_isFlickering = false
                    v1_flickerOffset = Vector3.zero
                    v1_partOffsets = {}
                    if v1_camPart then
                        v1_camPart:Destroy()
                        v1_camPart = nil
                    end
                end
            end)
        end

        if not c().AntiDeathV1 then
            RestorePlayer_V1(char, root, hum)
        else

            local undergroundCFrame = CFrame.new(
                v1_basePos.X + v1_flickerOffset.X,
                v1_basePos.Y,
                v1_basePos.Z + v1_flickerOffset.Z
            ) * v1_baseRotation

            local loopTime = os.clock()
            local skyShakeTime = loopTime * 10
            local skyCFrame = CFrame.new(
                v1_basePos.X + (math.sin(skyShakeTime) * 0.6),
                v1_originalY + 65 + (math.sin(skyShakeTime * 2) * 0.5),
                v1_basePos.Z + (math.cos(skyShakeTime * 1.2) * 0.7)
            ) * v1_baseRotation

            for part, offset in pairs(v1_partOffsets) do
                if part and part.Parent then
                    part.AssemblyLinearVelocity = Vector3.zero
                    part.AssemblyAngularVelocity = Vector3.zero
                    part.CFrame = undergroundCFrame * offset
                end
            end

            RunService.RenderStepped:Wait()

            if v1_isBurrowed then
                for part, offset in pairs(v1_partOffsets) do
                    if part and part.Parent then
                        part.CFrame = skyCFrame * offset
                    end
                end
            end
        end
    end
end))

MainTab:Toggle({
    Title = "กันตาย",
    Value = c().AntiDeathV1 or false,
    Callback = function(state)
        c().AntiDeathV1 = state
        if not state and v1_isBurrowed then
            local char = Client.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if char and root and hum then
                RestorePlayer_V1(char, root, hum)
            end
        end
    end
})

local originalVelocity = Vector3.zero

table.insert(Connections, RunService.Heartbeat:Connect(function()
    if not c().AntiLock then return end
    if not RootPart or not Humanoid or Humanoid.Health <= 0 then return end

    local isSeated = Humanoid.Sit 
        or Humanoid.SeatPart ~= nil 
        or Humanoid:GetState() == Enum.HumanoidStateType.Seated
    if isSeated then return end

    if Humanoid.MoveDirection.Magnitude <= 0.05 then return end

    originalVelocity = RootPart.AssemblyLinearVelocity

    RootPart.AssemblyLinearVelocity = Vector3.new(
        math.random(-9999999, 9999999),
        math.random(-9999999, 9999999),
        math.random(-9999999, 9999999)
    )

    RunService.RenderStepped:Wait()
    if RootPart then
        RootPart.AssemblyLinearVelocity = originalVelocity
    end
end))

MainTab:Toggle({
    Title = "กันล็อค",
    Value = c().AntiLock or false,
    Callback = function(enabled)
        c().AntiLock = enabled
        if not enabled and RootPart and originalVelocity then
            RootPart.AssemblyLinearVelocity = originalVelocity
        end
    end
})

local AntiRagdollThread = nil
local function ToggleAntiRagdoll(state)
    c().AntiRagdoll = state
    if state then
        if AntiRagdollThread then task.cancel(AntiRagdollThread) end
        AntiRagdollThread = task.spawn(function()
            while c().AntiRagdoll do
                pcall(function()
                    SendRemoteAction("end_ragdoll_early")
                    task.wait(0.05)
                    if not c().AntiRagdoll then return end
                    SendRemoteAction("clear_ragdoll")
                    task.wait(0.05)
                end)
            end
        end)
    else
        if AntiRagdollThread then
            task.cancel(AntiRagdollThread)
            AntiRagdollThread = nil
        end
    end
end

MainTab:Toggle({
    Title = "กันเดินเซ",
    Desc = "เวลาโดนโจมตีหรือโดนรถชน",
    Value = c().AntiRagdoll or false,
    Callback = function(state)
        ToggleAntiRagdoll(state)
    end
})

local function IsVehicleSeat(seat)
    if not seat then return false end
    if seat:IsA("VehicleSeat") then return true end
    local vehiclesFolder = workspace:FindFirstChild("Vehicles")
    if vehiclesFolder and seat:IsDescendantOf(vehiclesFolder) then return true end
    local model = seat:FindFirstAncestorOfClass("Model")
    if model and (model:FindFirstChildOfClass("VehicleSeat") or model:FindFirstChild("DriveSeat") or model:GetAttribute("IsVehicle")) then
        return true
    end
    return false
end

local function SetNormalSeatsDisabled(disableState)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Seat") and not IsVehicleSeat(obj) then 
            obj.Disabled = disableState 
        end
    end
end

table.insert(Connections, workspace.DescendantAdded:Connect(function(obj)
    if c().AntiAutoSit and obj:IsA("Seat") and not IsVehicleSeat(obj) then 
        obj.Disabled = true 
    end
end))

local function SetupAntiSit(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    table.insert(Connections, hum.Seated:Connect(function(isSeated, seatPart)
        if isSeated and c().AntiAutoSit and seatPart then
            if not IsVehicleSeat(seatPart) then
                hum.Sit = false
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end))
end

if Client.Character then SetupAntiSit(Client.Character) end
table.insert(Connections, Client.CharacterAdded:Connect(SetupAntiSit))

task.spawn(function()
    task.wait(4)
    if c().AntiAutoSit then
        SetNormalSeatsDisabled(true)
    end
end)

MainTab:Toggle({
    Title = "กันนั่งโดยไม่ได้ตั้งใจ",
    Value = c().AntiAutoSit or false,
    Callback = function(state)
        c().AntiAutoSit = state
        SetNormalSeatsDisabled(state)
    end
})

local Net = require(ReplicatedStorage.Modules.Core.Net)
local itemRarityCache = {}
local itemsDataFolder = ReplicatedStorage:WaitForChild("Items")
local dropFolder = workspace:WaitForChild("DroppedItems")

local function BuildRarityCache()
    for _, item in ipairs(itemsDataFolder:GetDescendants()) do
        if not item:IsA("ModuleScript") and not item:IsA("Folder") then
            itemRarityCache[item.Name] = item:GetAttribute("RarityName") or "Common"
        end
    end
end

BuildRarityCache()

local function IsBlacklisted(item)
    if not item then return false end
    local dropName = item:GetAttribute("ItemName") or item.Name
    if not dropName then return false end
    local rarity = itemRarityCache[dropName]
    if rarity and c().BlacklistRarity then
        for _, blacklistedRarity in ipairs(c().BlacklistRarity) do
            if blacklistedRarity == rarity then
                return true
            end
        end
    end
    return false
end

local function TryPickItem(item)
    if not c().AutoPick then return end
    if item and not item:GetAttribute("Locked") and not IsBlacklisted(item) then
        local primary = item.PrimaryPart or item:FindFirstChild("PickUpZone") or item:FindFirstChildWhichIsA("BasePart")
        if primary and RootPart then
            local distance = (RootPart.Position - primary.Position).Magnitude
            if distance <= 30 then
                task.spawn(function()
                    pcall(function()
                        Net.get("pickup_dropped_item", item)
                    end)
                end)
            end
        end
    end
end

dropFolder.ChildAdded:Connect(function(newItem)
    task.wait()
    TryPickItem(newItem)
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if c().AutoPick then
            for _, item in ipairs(dropFolder:GetChildren()) do
                if not c().AutoPick then break end
                TryPickItem(item)
            end
        end
    end
end)

MainTab:Toggle({
    Title = "ดูดหรือเก็บของไกล",
    Value = c().AutoPick or false,
    Callback = function(enabled)
        c().AutoPick = enabled
    end
})

MainTab:Toggle({
    Title = "ซ่อนชื่อ", 
    Value = c().HideName or false,
    Callback = function(state)
        c().HideName = state
        if RootPart and RootPart:FindFirstChild("CharacterBillboardGui") then
            RootPart.CharacterBillboardGui.Enabled = not state
        end
    end
})

Client.CharacterAdded:Connect(function(newChar)
    task.wait(1)
    local hrp = newChar:WaitForChild("HumanoidRootPart", 5)
    if hrp and c().HideName then
        local bb = hrp:FindFirstChild("CharacterBillboardGui")
        if bb then bb.Enabled = false end
    end
end)

MainTab:Toggle({
    Title = "เกิดใหม่อัตโนมัติ",
    Value = c().AutoRespawn or false,
    Callback = function(state)
        c().AutoRespawn = state
        if state and PlayerGui and PlayerGui:FindFirstChild("DeathScreen") then
            local deathscreen = PlayerGui.DeathScreen:FindFirstChild("DeathScreenHolder")
            if deathscreen and deathscreen.Visible and deathscreen.Frame.RespawnButtonFrame.RespawnButton.TextLabel.Text == "Respawn" then
                SendRemoteAction("death_screen_request_respawn")
            end
        end
    end
})

task.spawn(function() 
    local deathScreenGui = PlayerGui and PlayerGui:WaitForChild("DeathScreen", 10) 
    local deathscreen = deathScreenGui and deathScreenGui:WaitForChild("DeathScreenHolder", 5) 
    
    if deathscreen then 
        local respawnBtn = deathscreen.Frame.RespawnButtonFrame.RespawnButton 
        
        table.insert(Connections, respawnBtn.TextLabel:GetPropertyChangedSignal("Text"):Connect(function() 
            if c().AutoRespawn and deathscreen.Visible and respawnBtn.TextLabel.Text == "Respawn" then 
                task.wait(0.5) 
                SendRemoteAction("death_screen_request_respawn") 
            end 
        end)) 
    end 
end)

MainTab:Section({ Title = "เก็บของใต้ดิน" })

local function GetDeltaY(basePositionY, currentPositionY, offset)
    return (basePositionY - offset) - currentPositionY
end

local function RunSnap()
    local myHrp = (Char and Char.get_hrp and Char.get_hrp()) or (Client.Character and Client.Character:FindFirstChild("HumanoidRootPart"))
    if not myHrp then return end

    local basePositionY = myHrp.Position.Y
    local offsetY = tonumber(c().SnapAmount) or 10

    while c().Snap do
        xpcall(function()
            local charObj = (Char and Char.get and Char.get()) or Client.Character
            local hum = charObj and charObj:FindFirstChildOfClass("Humanoid")
            local hrp = (Char and Char.get_hrp and Char.get_hrp()) or (charObj and charObj:FindFirstChild("HumanoidRootPart"))

            if hum and hum.Health > 0 and hrp then
                local currentOffset = tonumber(c().SnapAmount) or 10
                if currentOffset ~= offsetY then
                    offsetY = currentOffset
                end

                local currentY = hrp.Position.Y
                local deltaY = GetDeltaY(basePositionY, currentY, offsetY)

                charObj:PivotTo(hrp.CFrame * CFrame.new(0, deltaY, 0))
            end
        end, warn)

        task.wait()
    end

    xpcall(function()
        local charObj = (Char and Char.get and Char.get()) or Client.Character
        local hrp = (Char and Char.get_hrp and Char.get_hrp()) or (charObj and charObj:FindFirstChild("HumanoidRootPart"))
        if charObj and hrp then
            charObj:PivotTo(CFrame.new(hrp.Position.X, basePositionY, hrp.Position.Z) * hrp.CFrame.Rotation)
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end, warn)
end

local SnapToggle = MainTab:Toggle({
    Title = "มุดดิน [Z]",
    Value = c().Snap or false,
    Callback = function(state)
        c().Snap = state
        if state then
            task.spawn(RunSnap)
        end
    end
})

MainTab:Slider({
    Title = "ปรับความลึกในการมุดดิน",
    Step = 1,
    Value = {
        Min = 0,
        Max = 300,
        Default = c().SnapAmount or 10
    },
    Callback = function(val)
        c().SnapAmount = val
    end
})

table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Z then
        local newState = not c().Snap
        c().Snap = newState

        if newState then
            task.spawn(RunSnap)
        end

        if SnapToggle and SnapToggle.Set then
            SnapToggle:Set(newState)
        end
    end
end))

AimTab:Section({ Title = "ฟังก์ชันล็อคเป้า" })

local Debris = game:GetService("Debris")

local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
local CurrentTarget = nil

table.insert(Connections, Client.CharacterAdded:Connect(function(newChar)
    Character = newChar
    RootPart = newChar:WaitForChild("HumanoidRootPart", 5)
end))

local VisualsGui = Instance.new("ScreenGui")
VisualsGui.Name = "TestHub_Visuals"
VisualsGui.ResetOnSpawn = false
VisualsGui.IgnoreGuiInset = true
VisualsGui.Parent = (gethui and gethui()) or CoreGui or Client:WaitForChild("PlayerGui")

local FOVGui = Instance.new("ScreenGui")
FOVGui.Name = "TestHub_FOV"
FOVGui.ResetOnSpawn = false
FOVGui.IgnoreGuiInset = true
FOVGui.Parent = (gethui and gethui()) or CoreGui or Client:WaitForChild("PlayerGui")

local FOVFrame = Instance.new("Frame")
FOVFrame.Name = "FOVFrame"
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.fromScale(0.5, 0.5)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Visible = false
FOVFrame.Parent = FOVGui

local FOVCorner = Instance.new("UICorner", FOVFrame)
local FOVStroke = Instance.new("UIStroke", FOVFrame)
FOVStroke.Thickness = 1.5
FOVStroke.Color = Color3.fromRGB(255, 255, 255)

local FOVGradient = Instance.new("UIGradient", FOVStroke)
FOVGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255))
})
    FOVGradient.Enabled = false


local TracerLine = Instance.new("Frame")
TracerLine.Name = "TracerLine"
TracerLine.AnchorPoint = Vector2.new(0.5, 0.5)
TracerLine.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
TracerLine.BorderSizePixel = 0
TracerLine.Visible = false
TracerLine.Parent = FOVGui

local HitboxCache = {}
local PlayerPositionHistory = {}

local CachedPingLabel = nil
task.spawn(function()
    local pGui = Client:WaitForChild("PlayerGui", 5)
    local netStats = pGui and pGui:WaitForChild("NetworkStats", 5)
    CachedPingLabel = netStats and netStats:WaitForChild("PingLabel", 5)
end)

local function CleanupTargetData(player)
    if player then
        PlayerPositionHistory[player] = nil
        if player.Character then
            HitboxCache[player.Character] = nil
        end
    end
end

Players.PlayerRemoving:Connect(CleanupTargetData)

table.insert(Connections, Client.CharacterAdded:Connect(function()
    table.clear(PlayerPositionHistory)
    table.clear(HitboxCache)
end))

task.spawn(function()
    while true do
        task.wait(5)
        local now = os.clock()
        for char, data in pairs(HitboxCache) do
            if not char or not char.Parent or (now - data.LastUpdate > 15) then
                HitboxCache[char] = nil
            end
        end
    end
end)

local function IsAlive(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local FriendCache = {}
local function IsFriendCached(player)
    if not player then return false end
    if FriendCache[player.UserId] ~= nil then
        return FriendCache[player.UserId]
    end
    FriendCache[player.UserId] = false 
    task.spawn(function()
        pcall(function()
            FriendCache[player.UserId] = Client:IsFriendsWith(player.UserId)
        end)
    end)
    return false
end

Players.PlayerRemoving:Connect(function(plr)
    if plr then FriendCache[plr.UserId] = nil end
end)

local function IsTargetInVehicle(targetChar)
    local hum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
    local seat = hum and hum.SeatPart
    if not seat then return false end
    
    if seat:IsA("VehicleSeat") then return true end
    local model = seat:FindFirstAncestorOfClass("Model")
    return (model and (model:FindFirstChildOfClass("VehicleSeat") or model:FindFirstChild("DriveSeat") or model:GetAttribute("IsVehicle"))) and true or false
end

local function GetTargetPartAndPosition(targetChar, isShooting)
    if not targetChar then return nil, nil end

    if not HitboxCache[targetChar] then
        HitboxCache[targetChar] = { ShotCount = 1, LastUpdate = os.clock() }
    end

    local cache = HitboxCache[targetChar]
    cache.LastUpdate = os.clock()

    local root = targetChar:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil end 

    local head = targetChar:FindFirstChild("Head")
    local upperTorso = targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso")
    local lowerTorso = targetChar:FindFirstChild("LowerTorso") or targetChar:FindFirstChild("Torso")

    local currentMode = c().AimMode or "โหมดยิงเซฟ"
    local targetPart = root
    local exactPos = root.Position

    if currentMode == "โหมดยิงหัว" then
        targetPart = head or root
        exactPos = targetPart.Position
    elseif currentMode == "โหมดยิงตัว" then
        targetPart = lowerTorso or upperTorso or root
        exactPos = targetPart.Position
    else
        local inVehicle = IsTargetInVehicle(targetChar)

        if inVehicle then
            local vehicleCycle = cache.ShotCount % 5

            if vehicleCycle < 3 then

                targetPart = upperTorso or root
                exactPos = (targetPart.Name == "UpperTorso") and (targetPart.Position + Vector3.new(0, 0.35, 0)) or targetPart.Position
            else

                targetPart = head or root
                exactPos = targetPart.Position
            end
        else
            local shotCycle = cache.ShotCount % 4

            if shotCycle == 0 then

                targetPart = head or root
                exactPos = targetPart.Position
            else

                targetPart = lowerTorso or root
                exactPos = targetPart.Position
            end
        end
    end 

    if isShooting then
        cache.ShotCount = cache.ShotCount + 1
    end

    return targetPart, exactPos
end

local function IsProtected(char, player)
    if not char then return true end

    if c().IgnoreFriends and player and IsFriendCached(player) then
        return true
    end

    local isSafe = char:GetAttribute("IsSafeZoneProtected")
        or char:GetAttribute("InSafeZone")
        or char:GetAttribute("SafeZone")
        or (player and (player:GetAttribute("IsSafeZoneProtected") or player:GetAttribute("InSafeZone")))

    local isGod = char:FindFirstChildOfClass("ForceField")
        or char:GetAttribute("IsSpawnProtected")
        or char:GetAttribute("Invincible")
        or (player and player:GetAttribute("IsSpawnProtected"))

    return (isSafe or isGod) or false
end

local function GetClosestPlayerInFOV()
    local cam = Workspace.CurrentCamera
    if not cam then return nil end

    local MousePos = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local ClosestDistance = c().FOVRadius or 150
    local Target = nil

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Client and player.Character and IsAlive(player.Character) then
            if not IsProtected(player.Character, player) then
                local _, targetPos = GetTargetPartAndPosition(player.Character, false)
                if targetPos then
                    local ScreenPos, OnScreen = cam:WorldToViewportPoint(targetPos)
                    if OnScreen and ScreenPos.Z > 0 then
                        local TargetPos2D = Vector2.new(ScreenPos.X, ScreenPos.Y)
                        local Distance = (TargetPos2D - MousePos).Magnitude
                        if Distance <= ClosestDistance then
                            ClosestDistance = Distance
                            Target = player.Character
                        end
                    end
                end
            end
        end
    end
    return Target
end

table.insert(Connections, RunService.Heartbeat:Connect(function()
    if not c().AimAssist then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Client and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                PlayerPositionHistory[player] = PlayerPositionHistory[player] or {}
                table.insert(PlayerPositionHistory[player], {time = os.clock(), pos = root.Position})
                if #PlayerPositionHistory[player] > 6 then 
                    table.remove(PlayerPositionHistory[player], 1) 
                end
            else
                PlayerPositionHistory[player] = nil
            end
        end
    end
end))

local function CalculateTESTHUBVelocity(player)
    local history = PlayerPositionHistory[player]
    if not history or #history < 2 then return Vector3.zero end

    local totalVelocity = Vector3.zero
    local count = 0

    for i = 2, #history do
        local deltaTime = history[i].time - history[i-1].time
        if deltaTime > 0 then 
            totalVelocity = totalVelocity + (history[i].pos - history[i-1].pos) / deltaTime
            count = count + 1 
        end
    end

    if count == 0 then return Vector3.zero end
    local avgVelocity = totalVelocity / count

    if avgVelocity.Y > 150 then 
        return Vector3.new(avgVelocity.X * 1.15, math.clamp(avgVelocity.Y * 0.85, 0, 350), avgVelocity.Z * 1.15) 
    end
    return avgVelocity
end

local function GetRealPing()
    if CachedPingLabel and typeof(CachedPingLabel.Text) == "string" then
        local pingNum = tonumber(CachedPingLabel.Text:match("%d+"))
        if pingNum then return math.clamp(pingNum / 1000, 0.03, 0.45) end
    end
    return 0.12
end

local Network = require(ReplicatedStorage.Modules.Core.Net)

if typeof(Network.send) == "function" then
    if not getgenv().OldNetworkSend_TESTHUBEngine then
        getgenv().OldNetworkSend_TESTHUBEngine = hookfunction(Network.send, function(...)
            local args = {...}

            pcall(function()
                if args[1] == "shoot_gun" and c().AimAssist and CurrentTarget then
                    local myChar = Client.Character
                    local myHead = myChar and (myChar:FindFirstChild("Head") or myChar:FindFirstChild("HumanoidRootPart"))
                    
                    local targetChar = CurrentTarget
                    local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
                    local targetPlayer = Players:GetPlayerFromCharacter(targetChar)

                    local isDowned = targetHum and (targetHum:GetAttribute("HasBeenDowned") or targetHum.Health <= 0)

                    if myHead and targetHum and (targetHum.Health > 0 or isDowned) then
                        local ShootOrigin = myHead.Position
                        local TargetPart, ExactPosition = GetTargetPartAndPosition(targetChar, true)

                        if TargetPart and ExactPosition then
                            local Ping = GetRealPing()
                            local Velocity = CalculateTESTHUBVelocity(targetPlayer)
                            local PredictFactor = 1.05

                            local PredictedPosition = ExactPosition
                            if not isDowned and Velocity.Magnitude > 1.5 then
                                PredictedPosition = ExactPosition + (Velocity * Ping * PredictFactor)
                            end

                            local hitChance = tonumber(c().AccuracyGun) or 100
                            local isHit = (math.random(1, 100) <= hitChance)

                            if isHit then
                                if typeof(args[3]) == "CFrame" then
                                    args[3] = CFrame.lookAt(args[3].Position, PredictedPosition)
                                else
                                    args[3] = CFrame.lookAt(ShootOrigin, PredictedPosition)
                                end
                            end

                            local hitNormal = (ShootOrigin - PredictedPosition).Unit

                            if type(args[4]) == "table" and isHit then
                                for _, b in pairs(args[4]) do
                                    if type(b) == "table" then
                                        if b.Position ~= nil or b.Instance ~= nil then
                                            b.Normal = hitNormal
                                            b.Position = PredictedPosition
                                            b.Instance = TargetPart
                                        else
                                            for _, subB in pairs(b) do
                                                if type(subB) == "table" then
                                                    subB.Normal = hitNormal
                                                    subB.Position = PredictedPosition
                                                    subB.Instance = TargetPart
                                                end
                                            end
                                        end
                                    end
                                end
                            end

                            if isHit then
                                local laserLength = (PredictedPosition - ShootOrigin).Magnitude
                                if laserLength > 0.5 then
                                    local laser = Instance.new("Part")
                                    laser.Name = "TESTHUB_LaserTracer"
                                    laser.Size = Vector3.new(0.09, 0.09, laserLength)
                                    laser.CFrame = CFrame.lookAt(ShootOrigin, PredictedPosition) * CFrame.new(0, 0, -laserLength / 2)
                                    laser.Material = Enum.Material.Neon
                                    laser.Color = Color3.fromRGB(255, 0, 0)
                                    laser.Transparency = 0.3
                                    laser.CanCollide = false
                                    laser.Anchored = true
                                    laser.Parent = Workspace
                                    Debris:AddItem(laser, 2.5)
                                end
                            end
                            
                            if c().MultiShoot then
                                getgenv().OldNetworkSend_TESTHUBEngine(table.unpack(args))
                            end
                        end
                    end
                end
            end)

            return getgenv().OldNetworkSend_TESTHUBEngine(table.unpack(args))
        end)
    end
end

AimTab:Toggle({
    Title = "ล็อคเป้า",
    Value = c().AimAssist or false,
    Callback = function(state)
        c().AimAssist = state
        c().ShowFOV = state
    end
})

AimTab:Slider({
    Title = "ปรับขนาด FOV",
    Step = 5,
    Value = {
        Min = 50,
        Max = 1600,
        Default = c().FOVRadius
    },
    Callback = function(v)
        c().FOVRadius = v
    end
})

AimTab:Dropdown({
    Title = "เลือกโหมดล็อคเป้า",
    Values = { "โหมดยิงเซฟ", "โหมดยิงหัว", "โหมดยิงตัว" },
    Value = c().AimMode or "โหมดยิงเซฟ",
    Callback = function(mode)
        c().AimMode = mode
    end
})

AimTab:Toggle({
    Title = "ไม่ล็อคเพื่อน",
    Value = c().IgnoreFriends or false,
    Callback = function(state)
        c().IgnoreFriends = state
    end
})

swordsTab:Section({ Title = "ฟังก์ชันอาวุธ" })

local ValidGunNames = {
    ["Crossbow"] = true,
    ["Double Barrel"] = true,
    ["Draco"] = true,
    ["AK-47"] = true,
    ["MP5"] = true,
    ["M24"] = true,
    ["P226"] = true,
    ["Remington"] = true,
    ["Skorpion"] = true,
    ["Uzi"] = true,
    ["Glock"] = true,
    ["Hunting Rifle"] = true,
    ["M249"] = true,
    ["G3"] = true,
    ["C9"] = true,
    ["Sawnoff"] = true,
}

local FireLoopRunning = false
local CachedControllers = {}  
local OriginalRecoil = {}       
local RecoilConnections = {}    

local get_upvalue = debug.getupvalue or getupvalue
local set_upvalue = debug.setupvalue or setupvalue
local get_upvalues = debug.getupvalues or getupvalues

local function GetAllUpvalues(fn)
    if get_upvalues then
        local ok, res = pcall(get_upvalues, fn)
        if ok and type(res) == "table" then
            return res
        end
    end

    local res = {}
    local i = 1
    while true do
        local ok, name, val = pcall(get_upvalue, fn, i)
        if not ok or (name == nil and val == nil) then
            break
        end
        res[i] = val
        i = i + 1
    end
    return res
end

local function GetEquippedTool()
    local Character = LocalPlayer.Character
    if not Character then return nil end

    for _, obj in ipairs(Character:GetChildren()) do
        if obj:IsA("Tool") and ValidGunNames[obj.Name] then
            return obj
        end
    end
    return nil
end

local function ScanGunControllerForTool(targetTool)
    if not targetTool or not targetTool:IsA("Tool") then return nil end
    if not ValidGunNames[targetTool.Name] then return nil end
    if CachedControllers[targetTool] then return CachedControllers[targetTool] end
    if not getgc then return nil end

    local gc = getgc(true)
    local targetGunData = nil

    for i = 1, #gc do
        local obj = gc[i]
        if type(obj) == "table" then
            if rawget(obj, "instance") == targetTool then
                local states = rawget(obj, "states")
                if type(states) == "table" and rawget(states, "fire_rate") then
                    targetGunData = obj
                    break
                end
            end
        end
    end

    if not targetGunData then return nil end

    local matchedFireFn = nil
    local matchedDelayIdx = nil

    for i = 1, #gc do
        local fn = gc[i]
        if type(fn) == "function" then
            local ok, info = pcall(debug.getinfo, fn)
            if ok and info and info.nups and info.nups >= 15 then
                local upvals = GetAllUpvalues(fn)
                local belongs = false
                local delayIdx = nil

                for idx, val in pairs(upvals) do
                    if val == targetGunData or val == targetTool then
                        belongs = true
                    elseif type(val) == "number" and val > 0.005 and val < 2.0 then
                        delayIdx = idx
                    end
                end

                if belongs and delayIdx then
                    matchedFireFn = fn
                    matchedDelayIdx = delayIdx
                    break
                end
            end
        end
    end

    local controller = {
        data = targetGunData,
        fireFn = matchedFireFn,
        delayIdx = matchedDelayIdx
    }

    CachedControllers[targetTool] = controller
    return controller
end

local function ApplyRecoil(tool)
    if not tool or not tool:IsA("Tool") then return end
    if not ValidGunNames[tool.Name] then return end

    if OriginalRecoil[tool] == nil then
        OriginalRecoil[tool] = tool:GetAttribute("Recoil") or 0
    end

    local original = OriginalRecoil[tool]
    local newRecoil = c().NoRecoilAccuracy and 0 or original

    pcall(function()
        tool:SetAttribute("Recoil", newRecoil)
    end)

    if RecoilConnections[tool] then
        RecoilConnections[tool]:Disconnect()
        RecoilConnections[tool] = nil
    end

    RecoilConnections[tool] = tool:GetAttributeChangedSignal("Recoil"):Connect(function()
        if c().SettingsApplied and OriginalRecoil[tool] ~= nil then
            local wanted = c().NoRecoilAccuracy and 0 or OriginalRecoil[tool]
            if tool:GetAttribute("Recoil") ~= wanted then
                pcall(function()
                    tool:SetAttribute("Recoil", wanted)
                end)
            end
        end
    end)
end

local function ApplyToController(tool, controller)
    if not controller or not controller.data then return end
    local gun = controller.data
    local currentFR = tonumber(c().FireRateValue) or 850
    local targetDelay = 60 / currentFR

    if gun.states then
        if gun.states.fire_rate then
            pcall(gun.states.fire_rate.set, currentFR)
        end
        if gun.states.accuracy then
            pcall(gun.states.accuracy.set, c().NoRecoilAccuracy and 1 or 0.8)
        end
        if gun.states.automatic then
            pcall(gun.states.automatic.set, true)
        end
        if controller.fireFn and controller.delayIdx then
            pcall(set_upvalue, controller.fireFn, controller.delayIdx, targetDelay)
        end
    end

    ApplyRecoil(tool)
end

local function UpdateLiveValues()
    for tool, controller in pairs(CachedControllers) do
        if tool and tool.Parent and ValidGunNames[tool.Name] then
            ApplyToController(tool, controller)
        end
    end
end

local function FullApplyGunSettings()
    c().SettingsApplied = true

    local function checkContainer(container)
        if not container then return end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") and ValidGunNames[item.Name] then
                local ctrl = CachedControllers[item] or ScanGunControllerForTool(item)
                if ctrl then
                    ApplyToController(item, ctrl)
                end
            end
        end
    end

    checkContainer(LocalPlayer.Character)
    checkContainer(LocalPlayer:FindFirstChildOfClass("Backpack"))
end

local function StartHoldFire()
    if FireLoopRunning then return end
    FireLoopRunning = true

    task.spawn(function()
        local lastShotTime = 0

        while c().HoldFire do
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                local equipped = GetEquippedTool()
                if equipped and ValidGunNames[equipped.Name] then
                    local controller = CachedControllers[equipped] or ScanGunControllerForTool(equipped)
                    local now = os.clock()
                    local currentFR = tonumber(c().FireRateValue) or 850
                    local shotDelay = 60 / math.clamp(currentFR, 100, 3000)

                    if controller and controller.fireFn and (now - lastShotTime >= shotDelay) then
                        lastShotTime = now
                        pcall(controller.fireFn)
                    end
                end
            end

            RunService.Heartbeat:Wait()
        end
        FireLoopRunning = false
    end)
end

local function HookCharacter(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and c().SettingsApplied then
            if not ValidGunNames[child.Name] then
                return
            end

            if CachedControllers[child] then
                ApplyToController(child, CachedControllers[child])
                return
            end

            task.defer(function()
                local ctrl = ScanGunControllerForTool(child)
                if ctrl then
                    ApplyToController(child, ctrl)
                end
            end)
        end
    end)
end

if LocalPlayer.Character then
    HookCharacter(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(HookCharacter)

task.spawn(function()
    task.wait(0.5)
    if c().SettingsApplied then
        FullApplyGunSettings()
    end
    if c().HoldFire then
        StartHoldFire()
    end
end)

swordsTab:Slider({
    Title = "อัตราการยิง",
    Value = {
        Min = 600,
        Max = 1200,
        Default = c().FireRateValue or 850
    },
    Callback = function(value)
        c().FireRateValue = value
        if c().SettingsApplied then
            UpdateLiveValues() 
        end
    end
})

swordsTab:Toggle({
    Title = "เปิดอัตราการยิง",
    Value = c().SettingsApplied or false,
    Callback = function(state)
        c().SettingsApplied = state

        if state then
            FullApplyGunSettings()
            if c().HoldFire and not FireLoopRunning then
                StartHoldFire()
            end
        else
            local equipped = GetEquippedTool()
            if equipped and OriginalRecoil[equipped] ~= nil then
                pcall(function()
                    equipped:SetAttribute("Recoil", OriginalRecoil[equipped])
                end)
            end
        end
    end
})

swordsTab:Toggle({
    Title = "กดยิงค้าง",
    Value = c().HoldFire or false,
    Callback = function(state)
        c().HoldFire = state
        if state then
            StartHoldFire()
        end
    end
})

swordsTab:Toggle({
    Title = "ไม่มีแรงดีด & แม่นยำ",
    Value = c().NoRecoilAccuracy or false,
    Callback = function(state)
        c().NoRecoilAccuracy = state

        if not c().SettingsApplied then
            FullApplyGunSettings()
        else
            UpdateLiveValues()
        end
    end
})

swordsTab:Divider()

swordsTab:Toggle({
    Title = "ยิงเบิ้ล",
    Desc = "ยิง 1 นัดดาเมจเข้า 2 นัด",
    Value = c().MultiShoot or false,
    Callback = function(state)
        c().MultiShoot = state
    end
})

VisualTab:Section({ Title = "ฟังก์ชันไฮไลท์ผู้เล่น" })

local RarityData = {
    Common    = Color3.fromRGB(255, 255, 255),
    Uncommon  = Color3.fromRGB(99, 255, 52),
    Rare      = Color3.fromRGB(51, 170, 255),
    Epic      = Color3.fromRGB(237, 44, 255),
    Legendary = Color3.fromRGB(255, 150, 0),
    Omega     = Color3.fromRGB(255, 20, 51),
    Money     = Color3.fromRGB(0, 255, 80)
}
local RarityColors = RarityData 
local ItemRegistry = {}

local function RegisterCategory(folder)
    if not folder then return end
    for _, tool in ipairs(folder:GetChildren()) do
        if tool:IsA("Tool") then
            local handle = tool:FindFirstChild("Handle")
            local key = nil
            local dispName = tool:GetAttribute("DisplayName") or tool.Name
            local itemId = tool:GetAttribute("ItemId") or tool:GetAttribute("Id") or tool.Name
            local rarity = tool:GetAttribute("RarityName") or "Common"
            local imageId = tool:GetAttribute("ImageId")

            if imageId and imageId ~= "" and imageId ~= "rbxassetid://7072725737" then
                if handle then
                    local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                    if mesh and mesh.MeshId ~= "" then
                        key = mesh.MeshId .. (mesh.TextureId or "") .. "_RARITY_" .. rarity
                    elseif handle:IsA("MeshPart") and handle.MeshId ~= "" then
                        key = handle.MeshId .. (handle.TextureID or "") .. "_RARITY_" .. rarity
                    end
                end

                if not key and itemId and itemId ~= "" and itemId ~= tool.Name then
                    key = "ITEMID_" .. itemId .. "_RARITY_" .. rarity
                end

                if not key then
                    key = "NAME_" .. dispName .. "_" .. tool.Name .. "_RARITY_" .. rarity
                end

                ItemRegistry[key] = {
                    Name = dispName,
                    Rarity = rarity,
                    ImageId = imageId,
                    ToolName = tool.Name
                }
            end
        end
    end
end

local itemsDataFolder = ReplicatedStorage:WaitForChild("Items", 10)
if itemsDataFolder then
    for _, cat in ipairs({"gun", "melee", "throwable", "consumable", "farming", "misc", "rod", "fish"}) do
        local sub = itemsDataFolder:FindFirstChild(cat)
        if sub then RegisterCategory(sub) end
    end
end

local function GetItemLookupKey(tool)
    local handle = tool:FindFirstChild("Handle")
    local dispName = tool:GetAttribute("DisplayName") or tool.Name
    local itemId = tool:GetAttribute("ItemId") or tool:GetAttribute("Id") or tool.Name
    local rarity = tool:GetAttribute("RarityName") or "Common"

    if handle then
        local mesh = handle:FindFirstChildOfClass("SpecialMesh")
        if mesh and mesh.MeshId ~= "" then
            return mesh.MeshId .. (mesh.TextureId or "") .. "_RARITY_" .. rarity
        elseif handle:IsA("MeshPart") and handle.MeshId ~= "" then
            return handle.MeshId .. (handle.TextureID or "") .. "_RARITY_" .. rarity
        end
    end

    if itemId and itemId ~= "" and itemId ~= tool.Name then
        return "ITEMID_" .. itemId .. "_RARITY_" .. rarity
    end

    return "NAME_" .. dispName .. "_" .. tool.Name .. "_RARITY_" .. rarity
end

local function GetToolInfo(tool)
    if not tool or not tool:IsA("Tool") then return nil end
    local key = GetItemLookupKey(tool)
    local found = ItemRegistry[key]
    
    if found then return found end

    local rawImg = tool:GetAttribute("ImageId")
    if rawImg and rawImg ~= "" and rawImg ~= "rbxassetid://7072725737" then
        return {
            Name = tool:GetAttribute("DisplayName") or tool.Name,
            Rarity = tool:GetAttribute("RarityName") or "Common",
            ImageId = rawImg,
            ToolName = tool.Name
        }
    end

    return nil 
end

local function FetchPlayerWeapons(player)
    local weaponList = {}
    local addedTools = {}

    local containers = {"Backpack", "StarterGear", "StarterPack"}
    for _, contName in ipairs(containers) do
        local cont = player:FindFirstChild(contName)
        if cont then
            for _, t in ipairs(cont:GetChildren()) do
                if t:IsA("Tool") and t.Name ~= "Fists" and not addedTools[t] then
                    addedTools[t] = true
                    table.insert(weaponList, t)
                end
            end
        end
    end

    if player.Character then
        for _, t in ipairs(player.Character:GetChildren()) do
            if t:IsA("Tool") and t.Name ~= "Fists" and not addedTools[t] then
                addedTools[t] = true
                table.insert(weaponList, t)
            end
        end
    end

    return weaponList
end

local R15_Bones = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},

    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},

    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},

    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},

    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

local DrawingsData = { Players = {} }

local function NewPlayerDrawings(player)
    if player == Client then return end

    local folder = Instance.new("Folder")
    folder.Name = player.Name
    folder.Parent = VisualsGui

    local SkeletonLines = {}
    for i = 1, #R15_Bones do
        local line = Instance.new("Frame")
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.BorderSizePixel = 0
        line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        line.Visible = false
        line.Parent = folder
        SkeletonLines[i] = line
    end

    local HealthOutline = Instance.new("Frame")
    HealthOutline.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
    HealthOutline.BackgroundTransparency = 0.2
    HealthOutline.BorderSizePixel = 0
    HealthOutline.Visible = false
    HealthOutline.Parent = folder

    local OutlineCorner = Instance.new("UICorner")
    OutlineCorner.CornerRadius = UDim.new(0, 2)
    OutlineCorner.Parent = HealthOutline

    local OutlineStroke = Instance.new("UIStroke")
    OutlineStroke.Color = Color3.fromRGB(0, 0, 0)
    OutlineStroke.Thickness = 1
    OutlineStroke.Transparency = 0.3
    OutlineStroke.Parent = HealthOutline

    local HealthBar = Instance.new("Frame")
    HealthBar.BorderSizePixel = 0
    HealthBar.Visible = false
    HealthBar.Parent = folder

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(0, 1.5)
    BarCorner.Parent = HealthBar

    local NameText = Instance.new("TextLabel")
    NameText.BackgroundTransparency = 1
    NameText.Font = Enum.Font.Code
    NameText.TextSize = 13
    NameText.TextColor3 = Color3.new(1, 1, 1)
    NameText.TextStrokeTransparency = 0.4
    NameText.TextStrokeColor3 = Color3.new(0, 0, 0)
    NameText.AnchorPoint = Vector2.new(0.5, 0.5)
    NameText.Visible = false
    NameText.Parent = folder

    local DistText = Instance.new("TextLabel")
    DistText.BackgroundTransparency = 1
    DistText.Font = Enum.Font.Code
    DistText.TextSize = 12
    DistText.TextColor3 = Color3.fromRGB(220, 220, 220)
    DistText.TextStrokeTransparency = 0.4
    DistText.TextStrokeColor3 = Color3.new(0, 0, 0)
    DistText.AnchorPoint = Vector2.new(0.5, 0.5)
    DistText.Visible = false
    DistText.Parent = folder

    local InventoryFrame = Instance.new("Frame")
    InventoryFrame.Name = "InventoryFrame"
    InventoryFrame.BackgroundTransparency = 1
    InventoryFrame.AnchorPoint = Vector2.new(0.5, 0)
    InventoryFrame.Size = UDim2.new(0, 140, 0, 22)
    InventoryFrame.Visible = false
    InventoryFrame.Parent = folder

    local invLayout = Instance.new("UIListLayout")
    invLayout.FillDirection = Enum.FillDirection.Horizontal
    invLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    invLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    invLayout.Padding = UDim.new(0, 3)
    invLayout.Parent = InventoryFrame

    DrawingsData.Players[player] = {
        Folder = folder,
        Skeleton = SkeletonLines,
        HealthOutline = HealthOutline,
        HealthBar = HealthBar,
        Name = NameText,
        Distance = DistText,
        InventoryFrame = InventoryFrame
    }
end

local function RemovePlayerDrawings(player)
    if DrawingsData.Players[player] then
        if DrawingsData.Players[player].Folder then
            DrawingsData.Players[player].Folder:Destroy()
        end
        if DrawingsData.Players[player].Skeleton then
            for _, line in ipairs(DrawingsData.Players[player].Skeleton) do
                pcall(function() line:Remove() end)
            end
        end
        if DrawingsData.Players[player].Name then
            pcall(function() DrawingsData.Players[player].Name:Remove() end)
        end
        if DrawingsData.Players[player].Distance then
            pcall(function() DrawingsData.Players[player].Distance:Remove() end)
        end
        DrawingsData.Players[player] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do NewPlayerDrawings(p) end
table.insert(Connections, Players.PlayerAdded:Connect(NewPlayerDrawings))
table.insert(Connections, Players.PlayerRemoving:Connect(RemovePlayerDrawings))

local function GetBoxColor(char, player)
    local isFriend = c().IgnoreFriends and player and IsFriendCached(player)
    if isFriend then
        return Color3.fromRGB(7, 255, 44), false
    end

    local isTarget = (CurrentTarget and CurrentTarget == char)
    if isTarget then return Color3.fromRGB(255, 30, 30), true end

    local isSafe = char:GetAttribute("IsSafeZoneProtected") or char:GetAttribute("InSafeZone") or char:GetAttribute("SafeZone") or (player and (player:GetAttribute("IsSafeZoneProtected") or player:GetAttribute("InSafeZone")))
    if isSafe then return Color3.fromRGB(7, 255, 44), false end

    local isGod = char:FindFirstChildOfClass("ForceField") or char:GetAttribute("IsSpawnProtected") or char:GetAttribute("Invincible") or (player and player:GetAttribute("IsSpawnProtected"))
    if isGod then return Color3.fromRGB(0, 160, 255), false end

    return Color3.fromRGB(255, 255, 255), false
end

VisualTab:Toggle({
    Title = "เปิดดูโครงกระดูกผู้เล่น",
    Value = c().SkeletonPlayerVisual or false,
    Callback = function(s)
        c().SkeletonPlayerVisual = s
    end
})

VisualTab:Toggle({
    Title = "เปิดดูชื่อผู้เล่น",
    Value = c().NamePlayerVisual,
    Callback = function(s)
        c().NamePlayerVisual = s
    end
})

VisualTab:Toggle({
    Title = "เปิดดูหลอดเลือดผู้เล่น",
    Value = c().HealthPlayerVisual,
    Callback = function(s)
        c().HealthPlayerVisual = s
    end
})

VisualTab:Toggle({
    Title = "เปิดดูระยะห่างผู้เล่น",
    Value = c().DistancePlayerVisual,
    Callback = function(s)
        c().DistancePlayerVisual = s
    end
})

VisualTab:Toggle({
    Title = "เปิดดูของในตัวผู้เล่น",
    Value = c().InventoryPlayerVisual or false,
    Callback = function(state)
        c().InventoryPlayerVisual = state
        if not state then
            for _, player in ipairs(Players:GetPlayers()) do
                local drawData = DrawingsData.Players[player]
                if drawData and drawData.InventoryFrame then
                    for _, child in ipairs(drawData.InventoryFrame:GetChildren()) do
                        if child:IsA("Frame") then child:Destroy() end
                    end
                    drawData.InventoryFrame.Visible = false
                end
            end
        end
    end
})

local RarityColors = {
    Common    = Color3.fromRGB(255, 255, 255),
    Uncommon  = Color3.fromRGB(99, 255, 52),
    Rare      = Color3.fromRGB(51, 170, 255),
    Epic      = Color3.fromRGB(237, 44, 255),
    Legendary = Color3.fromRGB(255, 150, 0),
    Omega     = Color3.fromRGB(255, 20, 51),
    Money     = Color3.fromRGB(0, 255, 80)
}

local function IsInvalidImage(img)
    if not img then return true end
    local s = tostring(img):lower()
    if s == "" or s == "0" or s == "rbxassetid://0" then return true end
    if s:find("7072725737") then return true end
    return false
end

local function IsIgnoredTool(name)
    if not name then return true end
    if name == "Fists" or name == "หมัด" or name:lower() == "fists" then
        return true
    end
    if name == "Mop" then
        return true
    end
    return false
end

local function RegisterCategory(folder)
    if not folder then return end
    for _, tool in ipairs(folder:GetChildren()) do
        if tool:IsA("Tool") and not IsIgnoredTool(tool.Name) then
            local handle = tool:FindFirstChild("Handle")
            local key = nil
            local dispName = tool:GetAttribute("DisplayName") or tool.Name
            local itemId = tool:GetAttribute("ItemId") or tool:GetAttribute("Id") or tool.Name
            local rarity = tool:GetAttribute("RarityName") or "Common"
            local imageId = tool:GetAttribute("ImageId")

            if not IsInvalidImage(imageId) then
                if handle then
                    local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                    if mesh and mesh.MeshId ~= "" then
                        key = mesh.MeshId .. (mesh.TextureId or "") .. "_RARITY_" .. rarity
                    elseif handle:IsA("MeshPart") and handle.MeshId ~= "" then
                        key = handle.MeshId .. (handle.TextureID or "") .. "_RARITY_" .. rarity
                    end
                end

                if not key and itemId and itemId ~= "" and itemId ~= tool.Name then
                    key = "ITEMID_" .. itemId .. "_RARITY_" .. rarity
                end

                if not key then
                    key = "NAME_" .. dispName .. "_" .. tool.Name .. "_RARITY_" .. rarity
                end

                ItemRegistry[key] = {
                    Name = dispName,
                    Rarity = rarity,
                    ImageId = imageId,
                    ToolName = tool.Name
                }
            end
        end
    end
end

local itemsDataFolder = ReplicatedStorage:WaitForChild("Items", 10)
if itemsDataFolder then
    for _, cat in ipairs({"gun", "melee", "throwable", "consumable", "farming", "misc", "rod", "fish"}) do
        local sub = itemsDataFolder:FindFirstChild(cat)
        if sub then RegisterCategory(sub) end
    end
end

local function GetItemLookupKey(tool)
    local handle = tool:FindFirstChild("Handle")
    local dispName = tool:GetAttribute("DisplayName") or tool.Name
    local itemId = tool:GetAttribute("ItemId") or tool:GetAttribute("Id") or tool.Name
    local rarity = tool:GetAttribute("RarityName") or "Common"

    if handle then
        local mesh = handle:FindFirstChildOfClass("SpecialMesh")
        if mesh and mesh.MeshId ~= "" then
            return mesh.MeshId .. (mesh.TextureId or "") .. "_RARITY_" .. rarity
        elseif handle:IsA("MeshPart") and handle.MeshId ~= "" then
            return handle.MeshId .. (handle.TextureID or "") .. "_RARITY_" .. rarity
        end
    end

    if itemId and itemId ~= "" and itemId ~= tool.Name then
        return "ITEMID_" .. itemId .. "_RARITY_" .. rarity
    end

    return "NAME_" .. dispName .. "_" .. tool.Name .. "_RARITY_" .. rarity
end

local function GetToolInfo(tool)
    if not tool or not tool:IsA("Tool") or IsIgnoredTool(tool.Name) then return nil end
    local key = GetItemLookupKey(tool)
    local found = ItemRegistry[key]
    
    if found and not IsInvalidImage(found.ImageId) and not IsIgnoredTool(found.Name) then 
        return found 
    end

    local rawImg = tool:GetAttribute("ImageId")
    if not IsInvalidImage(rawImg) then
        local dispName = tool:GetAttribute("DisplayName") or tool.Name
        if not IsIgnoredTool(dispName) then
            return {
                Name = dispName,
                Rarity = tool:GetAttribute("RarityName") or "Common",
                ImageId = rawImg,
                ToolName = tool.Name
            }
        end
    end

    return nil 
end

local function FetchPlayerWeapons(player)
    local weaponList = {}
    local addedTools = {}

    local containers = {"Backpack", "StarterGear", "StarterPack"}
    for _, contName in ipairs(containers) do
        local cont = player:FindFirstChild(contName)
        if cont then
            for _, t in ipairs(cont:GetChildren()) do
                if t:IsA("Tool") and not IsIgnoredTool(t.Name) and not addedTools[t] then
                    addedTools[t] = true
                    table.insert(weaponList, t)
                end
            end
        end
    end

    if player.Character then
        for _, t in ipairs(player.Character:GetChildren()) do
            if t:IsA("Tool") and not IsIgnoredTool(t.Name) and not addedTools[t] then
                addedTools[t] = true
                table.insert(weaponList, t)
            end
        end
    end

    return weaponList
end

VisualTab:Section({ Title = "ฟังก์ชันไฮไลท์สิ่งของ" })

local function FormatNumber(value)
    local formatted = tostring(value or 0)
    while true do
        local k
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return formatted
end

local function GetItemInfo(itemModel)
    local rawName = itemModel:GetAttribute("ItemName") or itemModel.Name
    local rarity = itemModel:GetAttribute("RarityName") or itemModel:GetAttribute("Rarity")
    local imageId = itemModel:GetAttribute("ImageId")

    local amount = itemModel:GetAttribute("Amount") or itemModel:GetAttribute("Count") or itemModel:GetAttribute("Quantity") or itemModel:GetAttribute("Value") or itemModel:GetAttribute("Cash")

    local isMoney = rawName:lower():find("money") or rawName:lower():find("cash") or itemModel:GetAttribute("IsMoney") or (itemModel:FindFirstChild("PickUpZone") and itemModel.PickUpZone:GetAttribute("Amount"))

    if isMoney then
        local cashVal = amount or tonumber(rawName:match("%d+")) or 0
        local dispName = (cashVal and cashVal > 0) and string.format("Money\n$%s", FormatNumber(cashVal)) or "Money"
        return dispName, "Money", RarityData.Money, "rbxassetid://100024109821018"
    end

    if not rarity or not imageId then
        local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
        if itemsFolder then
            for _, folder in ipairs(itemsFolder:GetChildren()) do
                local found = folder:FindFirstChild(rawName)
                if found then
                    rarity = rarity or found:GetAttribute("RarityName") or found:GetAttribute("Rarity")
                    imageId = imageId or found:GetAttribute("ImageId")
                    break
                end
            end
        end
    end

    rarity = rarity or "Common"
    local color = RarityData[rarity] or Color3.fromRGB(255, 255, 255)

    local dispName = rawName
    if amount and tonumber(amount) and tonumber(amount) > 1 then dispName = string.format("%s\nx%s", rawName, amount) end
    return dispName, rarity, color, imageId
end

local function ApplyItemESP(itemModel, itemName, color, imageId, distance)
    if not itemModel:IsA("Model") then return end
    local primaryPart = itemModel.PrimaryPart or itemModel:FindFirstChild("PickUpZone") or itemModel:FindFirstChildWhichIsA("BasePart")

    local hl = itemModel:FindFirstChild("ItemHighlight")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "ItemHighlight"
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillTransparency = 0.35
        hl.OutlineTransparency = 0
        hl.Parent = itemModel
    end
    hl.FillColor = color
    hl.OutlineColor = color
    hl.Enabled = true

    if primaryPart then
        local billboard = primaryPart:FindFirstChild("ItemNameTag")
        if not billboard then
            billboard = Instance.new("BillboardGui")
            billboard.Name = "ItemNameTag"
            billboard.AlwaysOnTop = true

            billboard.Size = UDim2.fromOffset(88, 26)
            billboard.StudsOffset = Vector3.new(0, 0.8, 0)
            billboard.Adornee = primaryPart
            billboard.Parent = primaryPart

            local card = Instance.new("Frame")
            card.Name = "CardFrame"
            card.Size = UDim2.new(1, 0, 1, 0)
            card.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
            card.BackgroundTransparency = 0.25
            card.BorderSizePixel = 0
            card.Parent = billboard

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 5)
            cardCorner.Parent = card

            local cardStroke = Instance.new("UIStroke")
            cardStroke.Name = "CardStroke"
            cardStroke.Thickness = 1
            cardStroke.Transparency = 0.35
            cardStroke.Parent = card

            local iconSlot = Instance.new("Frame")
            iconSlot.Name = "IconSlot"
            iconSlot.Size = UDim2.fromOffset(18, 18)
            iconSlot.Position = UDim2.fromOffset(4, 4)
            iconSlot.BackgroundColor3 = Color3.fromRGB(26, 28, 34)
            iconSlot.BorderSizePixel = 0
            iconSlot.Parent = card

            local slotCorner = Instance.new("UICorner")
            slotCorner.CornerRadius = UDim.new(0, 4)
            slotCorner.Parent = iconSlot

            local slotStroke = Instance.new("UIStroke")
            slotStroke.Name = "SlotStroke"
            slotStroke.Thickness = 1
            slotStroke.Parent = iconSlot

            local iconImage = Instance.new("ImageLabel")
            iconImage.Name = "IconImage"
            iconImage.Size = UDim2.new(0.85, 0, 0.85, 0)
            iconImage.AnchorPoint = Vector2.new(0.5, 0.5)
            iconImage.Position = UDim2.new(0.5, 0, 0.5, 0)
            iconImage.BackgroundTransparency = 1
            iconImage.Parent = iconSlot

            local label = Instance.new("TextLabel")
            label.Name = "ItemLabel"
            label.Size = UDim2.new(1, -26, 0, 14)
            label.Position = UDim2.fromOffset(26, 2)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamMedium
            label.TextSize = 9
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextWrapped = true
            label.TextStrokeTransparency = 0.45
            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            label.Parent = card

            local distLabel = Instance.new("TextLabel")
            distLabel.Name = "DistLabel"
            distLabel.Size = UDim2.new(1, -26, 0, 9)
            distLabel.Position = UDim2.fromOffset(26, 15)
            distLabel.BackgroundTransparency = 1
            distLabel.Font = Enum.Font.GothamMedium
            distLabel.TextSize = 8
            distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            distLabel.TextXAlignment = Enum.TextXAlignment.Left
            distLabel.TextStrokeTransparency = 0.45
            distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            distLabel.Parent = card
        end

        local card = billboard:FindFirstChild("CardFrame")
        if card then
            local cardStroke = card:FindFirstChild("CardStroke")
            local iconSlot = card:FindFirstChild("IconSlot")
            local slotStroke = iconSlot and iconSlot:FindFirstChild("SlotStroke")
            local iconImage = iconSlot and iconSlot:FindFirstChild("IconImage")
            local label = card:FindFirstChild("ItemLabel")
            local distLabel = card:FindFirstChild("DistLabel")

            if cardStroke then cardStroke.Color = color end
            if slotStroke then slotStroke.Color = color end
            if iconImage then
                iconImage.Image = imageId or ""
                iconImage.Visible = (imageId ~= nil and imageId ~= "")
            end
            if label then label.Text = itemName end
            if distLabel then distLabel.Text = string.format("[%dm]", math.floor(distance)) end
        end
        billboard.Enabled = true
    end
end

local function RemoveItemESP(itemModel)
    local hl = itemModel:FindFirstChild("ItemHighlight")
    if hl then hl:Destroy() end
    for _, part in ipairs(itemModel:GetDescendants()) do
        if part:IsA("BillboardGui") and part.Name == "ItemNameTag" then part:Destroy() end
    end
end

local function ClearAllItemESP()
    local dropFolder = Workspace:FindFirstChild("DroppedItems")
    if dropFolder then
        for _, item in ipairs(dropFolder:GetChildren()) do RemoveItemESP(item) end
    end
end

VisualTab:Toggle({
    Title = "ไฮไลท์สิ่งของที่ตก", Value = c().ItemESP,
    Callback = function(state)
        c().ItemESP = state
        if not state then ClearAllItemESP() end
    end
})

VisualTab:Dropdown({
    Title = "เลือกระดับที่ต้องการจะปิด",
    Values = { "ไม่ปิดอะไรเลย", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Omega", "Money" },
    Value = "ไม่ปิดอะไรเลย",
    Multi = true,
    Callback = function(selectedList)
        local disabled = {}
        local isNone = false

        for _, r in ipairs(selectedList) do
            if r == "ไม่ปิดอะไรเลย" then
                isNone = true
                break
            end
            disabled[r] = true
        end

        c().ItemDisabledFilter = isNone and {} or disabled

        local dropFolder = Workspace:FindFirstChild("DroppedItems")
        if dropFolder then
            for _, item in ipairs(dropFolder:GetChildren()) do
                local _, rarity = GetItemInfo(item)
                if c().ItemDisabledFilter[rarity] then
                    RemoveItemESP(item)
                end
            end
        end
    end
})

table.insert(Connections, RunService.RenderStepped:Connect(function()
    if not c().ItemESP then return end
    local cam = Workspace.CurrentCamera
    local myRoot = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart")
    local dropFolder = Workspace:FindFirstChild("DroppedItems")

    if dropFolder then
        for _, item in ipairs(dropFolder:GetChildren()) do
            if item:IsA("Model") and item:FindFirstChild("PickUpZone") then
                local itemName, rarity, color, imageId = GetItemInfo(item)

                if not (c().ItemDisabledFilter and c().ItemDisabledFilter[rarity]) then
                    local primaryPart = item.PrimaryPart or item:FindFirstChild("PickUpZone") or item:FindFirstChildWhichIsA("BasePart")
                    local dist = primaryPart and myRoot and (myRoot.Position - primaryPart.Position).Magnitude
                        or (primaryPart and cam and (cam.CFrame.Position - primaryPart.Position).Magnitude) or 0

                    ApplyItemESP(item, itemName, color, imageId, dist)
                else
                    RemoveItemESP(item)
                end
            end
        end
    end
end))

table.insert(Connections, RunService.RenderStepped:Connect(function()
    pcall(function()
        local cam = Workspace.CurrentCamera
        if not cam then return end

        local myRoot = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart")
        local CenterPosition = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

        if c().ShowFOV then
            local radius = c().FOVRadius or 150
            FOVFrame.Size = UDim2.new(0, radius * 2, 0, radius * 2)
            FOVCorner.CornerRadius = UDim.new(1, 0)
            
            if c().RainbowFOV then
                FOVGradient.Enabled = true
                FOVGradient.Rotation = (os.clock() * 220) % 360
                FOVStroke.Color = Color3.fromRGB(255, 255, 255)
            else
                FOVGradient.Enabled = false
                FOVStroke.Color = Color3.fromRGB(255, 255, 255)
            end
            FOVFrame.Visible = true
        else
            FOVFrame.Visible = false
        end

        if c().AimAssist then
            CurrentTarget = GetClosestPlayerInFOV()
            if CurrentTarget and IsAlive(CurrentTarget) then
                local _, targetPos = GetTargetPartAndPosition(CurrentTarget, false)
                if targetPos then
                    local ScreenPos, OnScreen = cam:WorldToViewportPoint(targetPos)
                    if OnScreen and ScreenPos.Z > 0 then
                        local startPos = CenterPosition
                        local endPos = Vector2.new(ScreenPos.X, ScreenPos.Y)
                        local distance = (endPos - startPos).Magnitude
                        local center = (startPos + endPos) / 2
                        local angle = math.atan2(endPos.Y - startPos.Y, endPos.X - startPos.X)

                        TracerLine.Position = UDim2.new(0, center.X, 0, center.Y)
                        TracerLine.Size = UDim2.new(0, distance, 0, 1.5)
                        TracerLine.Rotation = math.deg(angle)
                        TracerLine.Visible = true
                    else
                        TracerLine.Visible = false
                    end
                else
                    TracerLine.Visible = false
                end
            else
                TracerLine.Visible = false
                CurrentTarget = nil
            end
        else
            TracerLine.Visible = false
            CurrentTarget = nil
        end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Client then
                local drawData = DrawingsData.Players[player]
                if drawData then
                    local char = player.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")

                    if char and root and hum and hum.Health > 0 then
                        local rootPos, onScreen = cam:WorldToViewportPoint(root.Position)

                        if onScreen and rootPos.Z > 0 then
                            local topPos = cam:WorldToViewportPoint(root.Position + Vector3.new(0, 2.7, 0))
                            local bottomPos = cam:WorldToViewportPoint(root.Position - Vector3.new(0, 3.2, 0))

                            local h = math.floor(math.abs(topPos.Y - bottomPos.Y))
                            local w = math.floor(h * 0.60)
                            local rx = math.floor(rootPos.X)
                            local y = math.floor(topPos.Y)
                            local boneColor, isTargeted = GetBoxColor(char, player)

                            if c().SkeletonPlayerVisual and R15_Bones then
                                for index, bonePair in ipairs(R15_Bones) do
                                    local partA = char:FindFirstChild(bonePair[1])
                                    local partB = char:FindFirstChild(bonePair[2])
                                    local line = drawData.Skeleton and drawData.Skeleton[index]

                                    if partA and partB and line then
                                        local posA = cam:WorldToViewportPoint(partA.Position)
                                        local posB = cam:WorldToViewportPoint(partB.Position)

                                        if posA.Z > 0 and posB.Z > 0 then
                                            local pA = Vector2.new(posA.X, posA.Y)
                                            local pB = Vector2.new(posB.X, posB.Y)
                                            local center = (pA + pB) / 2
                                            local dist = (pA - pB).Magnitude
                                            local angle = math.atan2(pB.Y - pA.Y, pB.X - pA.X)

                                            line.Position = UDim2.new(0, math.floor(center.X), 0, math.floor(center.Y))
                                            line.Size = UDim2.new(0, math.floor(dist), 0, 1.5)
                                            line.Rotation = math.deg(angle)
                                            line.BackgroundColor3 = boneColor
                                            line.Visible = true
                                        else
                                            line.Visible = false
                                        end
                                    elseif line then
                                        line.Visible = false
                                    end
                                end
                            else
                                if drawData.Skeleton then
                                    for _, line in ipairs(drawData.Skeleton) do line.Visible = false end
                                end
                            end

                            if c().NamePlayerVisual and drawData.Name then
                                drawData.Name.Text = player.Name
                                drawData.Name.Position = UDim2.new(0, rx, 0, y - 14)
                                drawData.Name.TextColor3 = isTargeted and Color3.fromRGB(255, 30, 30) or Color3.fromRGB(255, 255, 255)
                                drawData.Name.Visible = true
                            else
                                if drawData.Name then drawData.Name.Visible = false end
                            end

                            local barY = math.floor(y + h + 4)
                            local barHeight = 3
                            local barWidth = math.clamp(math.floor(w * 0.75), 28, 65)
                            local barX = math.floor(rx - (barWidth / 2))

                            local maxHp = (hum.MaxHealth and hum.MaxHealth > 0) and hum.MaxHealth or 100
                            local hpPercent = math.clamp(hum.Health / maxHp, 0, 1)

                            if c().HealthPlayerVisual then
                                drawData.HealthOutline.Position = UDim2.new(0, barX - 1, 0, barY - 1)
                                drawData.HealthOutline.Size = UDim2.new(0, barWidth + 2, 0, barHeight + 2)
                                drawData.HealthOutline.Visible = true

                                drawData.HealthBar.Position = UDim2.new(0, barX, 0, barY)
                                drawData.HealthBar.Size = UDim2.new(0, math.max(2, math.floor(barWidth * hpPercent)), 0, barHeight)
                                drawData.HealthBar.BackgroundColor3 = Color3.fromHSV(hpPercent * 0.33, 1, 1)
                                drawData.HealthBar.Visible = true
                            else
                                drawData.HealthOutline.Visible = false
                                drawData.HealthBar.Visible = false
                            end

                            local distOffsetY = c().HealthPlayerVisual and (barY + 14) or (y + h + 11)

                            if c().DistancePlayerVisual and drawData.Distance then
                                local distance = myRoot and (myRoot.Position - root.Position).Magnitude or (cam.CFrame.Position - root.Position).Magnitude

                                drawData.Distance.Text = "[" .. math.floor(distance) .. "m]"
                                drawData.Distance.Position = UDim2.new(0, rx, 0, math.floor(distOffsetY))
                                drawData.Distance.TextColor3 = isTargeted and Color3.fromRGB(255, 30, 30) or Color3.fromRGB(220, 220, 220)
                                drawData.Distance.Visible = true
                            else
                                if drawData.Distance then drawData.Distance.Visible = false end
                            end

                            if c().InventoryPlayerVisual and drawData.InventoryFrame then
                                local invOffsetY = c().DistancePlayerVisual and (distOffsetY + 14) or (distOffsetY + 2)
                                drawData.InventoryFrame.Position = UDim2.new(0, rx, 0, math.floor(invOffsetY))
                                drawData.InventoryFrame.Visible = true
                                
                                local bgFrame = drawData.InventoryFrame
                                local activeSlots = {}
                                local tools = FetchPlayerWeapons(player)

                                for _, tool in ipairs(tools) do
                                    local info = GetToolInfo(tool)
                                    if info and not IsInvalidImage(info.ImageId) then
                                        local slotKey = tool.Name .. "_" .. tostring(info.Rarity)
                                        activeSlots[slotKey] = true

                                        local slot = bgFrame:FindFirstChild(slotKey)
                                        if not slot then
                                            slot = Instance.new("Frame")
                                            slot.Name = slotKey
                                            slot.Size = UDim2.fromOffset(20, 20)
                                            slot.BackgroundColor3 = Color3.fromRGB(240, 248, 255)
                                            slot.BackgroundTransparency = 0.1
                                            slot.BorderSizePixel = 0
                                            slot.Parent = bgFrame

                                            local corner = Instance.new("UICorner")
                                            corner.CornerRadius = UDim.new(0, 6)
                                            corner.Parent = slot

                                            local stroke = Instance.new("UIStroke")
                                            stroke.Thickness = 2
                                            stroke.Color = RarityColors[info.Rarity] or Color3.fromRGB(255, 255, 255)
                                            stroke.Transparency = 0
                                            stroke.Parent = slot

                                            local iconImg = Instance.new("ImageLabel")
                                            iconImg.Name = "Icon"
                                            iconImg.Size = UDim2.fromScale(0.85, 0.85)
                                            iconImg.AnchorPoint = Vector2.new(0.5, 0.5)
                                            iconImg.Position = UDim2.fromScale(0.5, 0.5)
                                            iconImg.BackgroundTransparency = 1
                                            iconImg.BorderSizePixel = 0
                                            iconImg.Image = info.ImageId
                                            iconImg.Parent = slot
                                        else
                                            local stroke = slot:FindFirstChildOfClass("UIStroke")
                                            if stroke then
                                                stroke.Color = RarityColors[info.Rarity] or Color3.fromRGB(255, 255, 255)
                                            end
                                        end
                                    end
                                end

                                for _, child in ipairs(bgFrame:GetChildren()) do
                                    if child:IsA("Frame") and not activeSlots[child.Name] then
                                        child:Destroy()
                                    end
                                end
                            else
                                if drawData.InventoryFrame then 
                                    drawData.InventoryFrame.Visible = false 
                                    for _, child in ipairs(drawData.InventoryFrame:GetChildren()) do
                                        if child:IsA("Frame") then child:Destroy() end
                                    end
                                end
                            end

                        else
                            if drawData.Skeleton then for _, line in ipairs(drawData.Skeleton) do line.Visible = false end end
                            drawData.HealthOutline.Visible = false
                            drawData.HealthBar.Visible = false
                            if drawData.Name then drawData.Name.Visible = false end
                            if drawData.Distance then drawData.Distance.Visible = false end
                            if drawData.InventoryFrame then 
                                drawData.InventoryFrame.Visible = false 
                                for _, child in ipairs(drawData.InventoryFrame:GetChildren()) do
                                    if child:IsA("Frame") then child:Destroy() end
                                end
                            end
                        end
                    else
                        if drawData.Skeleton then for _, line in ipairs(drawData.Skeleton) do line.Visible = false end end
                        drawData.HealthOutline.Visible = false
                        drawData.HealthBar.Visible = false
                        if drawData.Name then drawData.Name.Visible = false end
                        if drawData.Distance then drawData.Distance.Visible = false end
                        if drawData.InventoryFrame then 
                            drawData.InventoryFrame.Visible = false 
                            for _, child in ipairs(drawData.InventoryFrame:GetChildren()) do
                                if child:IsA("Frame") then child:Destroy() end
                            end
                        end
                    end
                end 
            end
        end 
    end)
end))

local Camera = workspace.CurrentCamera
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera
end)

local EXACT_MPH_RATIO = 100 / 68

local currentCamFocusPart = nil
local lastActiveRoot = nil

local JoyGui = Instance.new("ScreenGui")
JoyGui.Name = "TESTHUB_FlyJoystick"
JoyGui.ResetOnSpawn = false
JoyGui.IgnoreGuiInset = true
JoyGui.Enabled = false
JoyGui.Parent = (gethui and gethui()) or PlayerGui

local JoyBase = Instance.new("Frame")
JoyBase.Name = "JoyBase"
JoyBase.Size = UDim2.fromOffset(130, 130)
JoyBase.AnchorPoint = Vector2.new(0.5, 0.5)
JoyBase.Position = UDim2.new(0, 110, 1, -110)
JoyBase.BackgroundColor3 = Color3.fromRGB(10, 16, 26)
JoyBase.BackgroundTransparency = 0.4
JoyBase.BorderSizePixel = 0
JoyBase.Parent = JoyGui

local BaseCorner = Instance.new("UICorner", JoyBase)
BaseCorner.CornerRadius = UDim.new(1, 0)

local BaseStroke = Instance.new("UIStroke", JoyBase)
BaseStroke.Thickness = 2.5
BaseStroke.Color = Color3.fromRGB(0, 195, 255)
BaseStroke.Transparency = 0.2

local JoyKnob = Instance.new("Frame")
JoyKnob.Name = "JoyKnob"
JoyKnob.Size = UDim2.fromOffset(60, 60)
JoyKnob.AnchorPoint = Vector2.new(0.5, 0.5)
JoyKnob.Position = UDim2.fromScale(0.5, 0.5)
JoyKnob.BackgroundColor3 = Color3.fromRGB(245, 250, 255)
JoyKnob.BackgroundTransparency = 0.05
JoyKnob.BorderSizePixel = 0
JoyKnob.Parent = JoyBase

local KnobCorner = Instance.new("UICorner", JoyKnob)
KnobCorner.CornerRadius = UDim.new(1, 0)

local KnobStroke = Instance.new("UIStroke", JoyKnob)
KnobStroke.Thickness = 1.2
KnobStroke.Color = Color3.fromRGB(180, 220, 255)
KnobStroke.Transparency = 0.5

local isDragging = false
local dragTouchObject = nil
local joystickVector = Vector2.zero 
local MAX_RADIUS = 42

local function GetKeyboardVector()
    local vec = Vector2.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then vec = vec + Vector2.new(0, 1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then vec = vec + Vector2.new(0, -1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then vec = vec + Vector2.new(-1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then vec = vec + Vector2.new(1, 0) end

    if vec.Magnitude > 1 then
        vec = vec.Unit
    end
    return vec
end

JoyBase.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragTouchObject = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input == dragTouchObject or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local baseCenter = JoyBase.AbsolutePosition + (JoyBase.AbsoluteSize / 2)
        local inputPos = Vector2.new(input.Position.X, input.Position.Y)
        local delta = inputPos - baseCenter

        local dist = delta.Magnitude
        local clampedDist = math.clamp(dist, 0, MAX_RADIUS)
        local dir = (dist > 0) and (delta / dist) or Vector2.zero

        local offset = dir * clampedDist
        JoyKnob.Position = UDim2.new(0.5, offset.X, 0.5, offset.Y)

        joystickVector = Vector2.new(offset.X / MAX_RADIUS, -offset.Y / MAX_RADIUS)
    end
end)

local function EndJoystickDrag(input)
    if input == dragTouchObject or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
        dragTouchObject = nil
    end
end

UserInputService.InputEnded:Connect(EndJoystickDrag)

local function GetCurrentVehicle()
    local char = Client.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return nil, nil, nil, nil, false end

    local seat = hum.SeatPart
    local isDriver = seat:IsA("VehicleSeat")
    local vehicleModel = seat:FindFirstAncestorOfClass("Model")
    local rootPart = (vehicleModel and vehicleModel.PrimaryPart) or seat

    return seat, rootPart, hum, vehicleModel, isDriver
end

local function CleanupPhysics(rootPart)
    if not rootPart then return end
    local lv = rootPart:FindFirstChild("FlyCarLV")
    local att = rootPart:FindFirstChild("FlyCarAtt")
    if lv then lv:Destroy() end
    if att then att:Destroy() end
end

local function ResetCameraFocus(hum, seat)
    if currentCamFocusPart then
        currentCamFocusPart:Destroy()
        currentCamFocusPart = nil
    end
    if Camera and hum then
        Camera.CameraSubject = seat or hum
    end
end

local function SetupCenteredCamera(vehicleModel, rootPart)
    if not vehicleModel or not rootPart then return end

    local cam = workspace.CurrentCamera
    if not cam then return end

    if not currentCamFocusPart or currentCamFocusPart.Parent ~= vehicleModel then
        if currentCamFocusPart then currentCamFocusPart:Destroy() end

        local modelCF, modelSize = vehicleModel:GetBoundingBox()
        local centerOffset = rootPart.CFrame:PointToObjectSpace(modelCF.Position)

        local camFocus = Instance.new("Part")
        camFocus.Name = "VehicleCamFocus"
        camFocus.Transparency = 1
        camFocus.CanCollide = false
        camFocus.Massless = true
        camFocus.Size = Vector3.new(0.5, 0.5, 0.5)
        camFocus.CFrame = rootPart.CFrame * CFrame.new(centerOffset + Vector3.new(0, 1.5, 0))

        local weld = Instance.new("WeldConstraint")
        weld.Part0 = camFocus
        weld.Part1 = rootPart
        weld.Parent = camFocus
        camFocus.Parent = vehicleModel
        
        currentCamFocusPart = camFocus
    end

    if cam.CameraSubject ~= currentCamFocusPart then
        cam.CameraSubject = currentCamFocusPart
    end
end

local function ManagePhysicsEngine(rootPart)
    local att = rootPart:FindFirstChild("FlyCarAtt") or Instance.new("Attachment", rootPart)
    att.Name = "FlyCarAtt"

    local lv = rootPart:FindFirstChild("FlyCarLV") or Instance.new("LinearVelocity", rootPart)
    lv.Name = "FlyCarLV"
    lv.Attachment0 = att
    lv.RelativeTo = Enum.ActuatorRelativeTo.World
    lv.ForceLimitMode = Enum.ForceLimitMode.PerAxis
    lv.MaxAxesForce = Vector3.new(0, 0, 0)

    return lv
end

table.insert(Connections, RunService.Heartbeat:Connect(function()
    local seat, rootPart, hum, vehicleModel, isDriver = GetCurrentVehicle()

    if not c().FlyCar or not seat or not isDriver then
        JoyGui.Enabled = false
        isDragging = false
        dragTouchObject = nil
        JoyKnob.Position = UDim2.fromScale(0.5, 0.5)

        if lastActiveRoot then
            CleanupPhysics(lastActiveRoot)
            lastActiveRoot = nil
        end
        if currentCamFocusPart then
            ResetCameraFocus(hum, seat)
        end
        return
    end

    JoyGui.Enabled = true
    lastActiveRoot = rootPart

    if UserInputService:GetFocusedTextBox() then return end

    SetupCenteredCamera(vehicleModel, rootPart)

    local engineLV = ManagePhysicsEngine(rootPart)
    local accelForce = rootPart.AssemblyMass * 550
    engineLV.MaxAxesForce = Vector3.new(accelForce, 0, accelForce)

    seat.Steer = 0
    seat.SteerFloat = 0

    if not isDragging then
        local kbVector = GetKeyboardVector()
        joystickVector = kbVector

        local targetX = kbVector.X * MAX_RADIUS
        local targetY = -kbVector.Y * MAX_RADIUS
        local currentX = JoyKnob.Position.X.Offset
        local currentY = JoyKnob.Position.Y.Offset

        JoyKnob.Position = UDim2.new(0.5, currentX + (targetX - currentX) * 0.35, 0.5, currentY + (targetY - currentY) * 0.35)
    end

    local camCF = Camera.CFrame
    local camLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
    if camLook.Magnitude > 0 then camLook = camLook.Unit end

    local camRight = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)
    if camRight.Magnitude > 0 then camRight = camRight.Unit end

    local moveDir = (camLook * joystickVector.Y) + (camRight * joystickVector.X)
    local inputMagnitude = math.clamp(joystickVector.Magnitude, 0, 1)

    if inputMagnitude > 0.05 then
        local targetDir = moveDir.Unit

        local currentDir = rootPart.CFrame.LookVector
        local cDir = Vector3.new(currentDir.X, 0, currentDir.Z).Unit
        local tDir = Vector3.new(targetDir.X, 0, targetDir.Z).Unit
        
        local cross = cDir:Cross(tDir).Y
        local dot = cDir:Dot(tDir)
        local angleDiff = math.atan2(cross, dot)
        
        local turnSpeed = math.clamp(angleDiff * 14, -12, 12)
        rootPart.AssemblyAngularVelocity = Vector3.new(0, turnSpeed, 0)

        local targetMPH = tonumber(c().FlyCarSpeed) or 30
        local targetStudsPerSec = targetMPH * EXACT_MPH_RATIO

        local currentVel = rootPart.AssemblyLinearVelocity
        local currentHorizontalSpeed = Vector3.new(currentVel.X, 0, currentVel.Z).Magnitude

        local speedDiff = targetStudsPerSec - currentHorizontalSpeed
        local trimAdjustment = 0
        if speedDiff > 0 then
            trimAdjustment = math.clamp(speedDiff * 0.35, 0, targetStudsPerSec * 0.15)
        end

        local finalSpeed = (targetStudsPerSec + trimAdjustment) * inputMagnitude
        engineLV.VectorVelocity = targetDir * finalSpeed

        seat.ThrottleFloat = 1
    else
        engineLV.VectorVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.new(0, rootPart.AssemblyAngularVelocity.Y * 0.8, 0)
        seat.ThrottleFloat = 0
    end
end))

VehicleTab:Toggle({
    Title = "รถบิน",
    Value = c().FlyCar or false,
    Callback = function(state)
        if c and c() then
            c().FlyCar = state
        end

        if not state then
            if currentCamFocusPart then
                currentCamFocusPart:Destroy()
                currentCamFocusPart = nil
            end
            local char = Client.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.SeatPart then
                local vehicleModel = hum.SeatPart:FindFirstAncestorOfClass("Model")
                local rootPart = vehicleModel and vehicleModel.PrimaryPart or hum.SeatPart
                CleanupPhysics(rootPart)
                if Workspace.CurrentCamera then
                    Workspace.CurrentCamera.CameraSubject = hum.SeatPart
                end
            end
        end
    end
})

VehicleTab:Slider({ 
    Title = "ปรับความเร็วรถบิน", 
    Step = 1, 
    Value = { 
        Min = 10, 
        Max = 120, 
        Default = c().FlyCarSpeed or 30 
    }, 
    Callback = function(val) 
        if c and c() then
            c().FlyCarSpeed = val
        end
    end 
})

local VechineModule
local CharModule

pcall(function() 
    VechineModule = require(ReplicatedStorage.Modules.Game.VehicleSystem.Vehicle) 
    CharModule = require(ReplicatedStorage.Modules.Core.Char) 
end)

local BUMP_DISTANCE = 150

local function BumpAuraLoop()
    while c().CarRamAura do
        task.wait(0.08)
        
        local car = VechineModule and VechineModule.get_car_player_is_in()
        local myChar = Client.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        
        if not car or not myRoot or not car:FindFirstChild("DriverSeat") then 
            task.wait(0.2) 
        else
            local allChars = (CharModule and CharModule.get_all and CharModule.get_all()) or {}
            
            for _, target in ipairs(allChars) do
                if target ~= myChar and target:IsA("Model") then
                    local targetHrp = target:FindFirstChild("HumanoidRootPart")
                    local targetHum = target:FindFirstChildOfClass("Humanoid")
                    
                    if targetHrp and targetHum and targetHum.Health > 0 then
                        local dist = (myRoot.Position - targetHrp.Position).Magnitude
                        
                        if dist <= BUMP_DISTANCE then
                            pcall(function()
                                local assembly = car.DriverSeat.AssemblyLinearVelocity + Vector3.new(65, 65, 65)
                                
                                if Network then
                                    Network.send("run_over", car, target, assembly)
                                else
                                    SendRemoteAction("run_over", car, target, assembly)
                                end
                            end)
                        end
                    end
                end
            end
        end
    end
end

VehicleTab:Toggle({ 
    Title = "ชนออร่า", 
    Value = c().CarRamAura or false, 
    Callback = function(state) 
        c().CarRamAura = state 
        if state then 
            task.spawn(BumpAuraLoop) 
        end 
    end 
})

local undergroundPlate = nil
local carBaseSurfaceY = nil
local activeVehicleModel = nil
local activeVehicleRoot = nil

local originalCollisions = {}
local originalCharCollisions = {}
local modifiedObstacles = {} 

local roadRayParams = RaycastParams.new()
roadRayParams.FilterType = Enum.RaycastFilterType.Exclude
roadRayParams.IgnoreWater = true

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Exclude

local UNDERGROUND_DEPTH = 13 

local function GetDriverVehicle()
    local char = Client.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local seat = hum and hum.SeatPart
    if not seat or not seat:IsA("VehicleSeat") then return nil, nil, nil, nil end

    local vehicleModel = seat:FindFirstAncestorOfClass("Model")
    local rootPart = (vehicleModel and vehicleModel.PrimaryPart) or seat

    return seat, rootPart, hum, vehicleModel
end

local function GetSurfaceY(referencePos)
    local filterList = {}
    if activeVehicleModel then table.insert(filterList, activeVehicleModel) end
    if Client.Character then table.insert(filterList, Client.Character) end
    if undergroundPlate then table.insert(filterList, undergroundPlate) end
    roadRayParams.FilterDescendantsInstances = filterList

    local expectedSurface = carBaseSurfaceY or (referencePos.Y + UNDERGROUND_DEPTH)
    local rayOrigin = Vector3.new(referencePos.X, expectedSurface + 4, referencePos.Z)
    local hit = Workspace:Raycast(rayOrigin, Vector3.new(0, -16, 0), roadRayParams)

    if hit then
        return hit.Position.Y
    end
    return expectedSurface
end

local function SetVehicleGhost(vehicleModel)
    if not vehicleModel then return end
    for _, p in ipairs(vehicleModel:GetDescendants()) do
        if p:IsA("BasePart") and not p.Name:lower():find("wheel") then
            if originalCollisions[p] == nil then
                originalCollisions[p] = p.CanCollide
            end
            p.CanCollide = false
        end
    end
end

local function SetCharGhost(char)
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            if originalCharCollisions[p] == nil then
                originalCharCollisions[p] = p.CanCollide
            end
            p.CanCollide = false
        end
    end
end

local function RestoreVehicleCollisions(targetModel)
    local mdl = targetModel or activeVehicleModel
    if not mdl then return end
    for part, state in pairs(originalCollisions) do
        if part and part.Parent and part:IsDescendantOf(mdl) then
            pcall(function() part.CanCollide = state end)
        end
    end
    table.clear(originalCollisions)
end

local function RestoreCharCollisions()
    for part, state in pairs(originalCharCollisions) do
        if part and part.Parent then
            pcall(function() part.CanCollide = state end)
        end
    end
    table.clear(originalCharCollisions)
end

local function RestoreObstacleCollisions()
    for part, wasCollidable in pairs(modifiedObstacles) do
        if part and part.Parent and wasCollidable == true then
            pcall(function() part.CanCollide = true end)
        end
    end
    table.clear(modifiedObstacles)
end

local function FreezeVehiclePhysics(vehicleModel)
    if not vehicleModel then return end
    for _, part in ipairs(vehicleModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.AssemblyLinearVelocity = Vector3.zero
            part.AssemblyAngularVelocity = Vector3.zero
        end
    end
end

local function GetOrCreateUndergroundPlate()
    if not undergroundPlate or not undergroundPlate.Parent then
        undergroundPlate = Instance.new("Part")
        undergroundPlate.Name = "TESTHUB_CarPlate"
        undergroundPlate.Size = Vector3.new(200, 2, 200)
        undergroundPlate.Transparency = 1
        undergroundPlate.Anchored = true
        undergroundPlate.CanCollide = true
        undergroundPlate.CastShadow = false

        undergroundPlate.CustomPhysicalProperties = PhysicalProperties.new(1, 1.5, 0, 100, 100)
        undergroundPlate.Parent = Workspace
    end
    return undergroundPlate
end

local function CleanupPlate()
    if undergroundPlate then
        undergroundPlate:Destroy()
        undergroundPlate = nil
    end
end

table.insert(Connections, RunService.Stepped:Connect(function()
    local seat, rootPart, hum, vehicleModel = GetDriverVehicle()

    if not c().CarSnap or not seat or not rootPart or not vehicleModel then
        if next(modifiedObstacles) ~= nil then
            RestoreObstacleCollisions()
        end
        return
    end

    local char = Client.Character
    if char then SetCharGhost(char) end
    SetVehicleGhost(vehicleModel)

    local filterList = {vehicleModel, char}
    if undergroundPlate then table.insert(filterList, undergroundPlate) end
    overlapParams.FilterDescendantsInstances = filterList

    local _, vehicleSize = vehicleModel:GetBoundingBox()
    local hitParts = Workspace:GetPartBoundsInBox(
        rootPart.CFrame * CFrame.new(0, 1, 0),
        Vector3.new(vehicleSize.X + 4, vehicleSize.Y + 4, vehicleSize.Z + 5),
        overlapParams
    )

    for _, obstacle in ipairs(hitParts) do
        if obstacle:IsA("BasePart") and not obstacle:IsA("Terrain") then
            if obstacle.CanCollide == true then
                if modifiedObstacles[obstacle] == nil then
                    modifiedObstacles[obstacle] = true
                end
                obstacle.CanCollide = false
            end
        end
    end

    for part, wasCollidable in pairs(modifiedObstacles) do
        if part and part.Parent then
            if (part.Position - rootPart.Position).Magnitude > 25 then
                if wasCollidable == true then
                    part.CanCollide = true
                end
                modifiedObstacles[part] = nil
            end
        else
            modifiedObstacles[part] = nil
        end
    end
end))

table.insert(Connections, RunService.Heartbeat:Connect(function()
    if not c().CarSnap then
        if undergroundPlate then CleanupPlate() end
        return
    end

    local char = Client.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local seat = hum and hum.SeatPart

    if hum and hum.Health <= 0 then
        if activeVehicleRoot then
            local surfaceY = GetSurfaceY(activeVehicleRoot.Position)
            if root then
                root.CFrame = CFrame.new(root.Position.X, surfaceY + 3.2, root.Position.Z)
                root.AssemblyLinearVelocity = Vector3.zero
            end
        end
        RestoreObstacleCollisions()
        RestoreCharCollisions()
        if activeVehicleModel then
            activeVehicleRoot.Anchored = false
            RestoreVehicleCollisions(activeVehicleModel)
        end
        CleanupPlate()
        activeVehicleModel = nil
        activeVehicleRoot = nil
        carBaseSurfaceY = nil
        return
    end

    if not seat or not seat:IsA("VehicleSeat") then
        if activeVehicleModel and activeVehicleRoot then
            RestoreObstacleCollisions()

            local surfaceY = GetSurfaceY(activeVehicleRoot.Position)
            local look = activeVehicleRoot.CFrame.LookVector
            local flatLook = Vector3.new(look.X, 0, look.Z)
            flatLook = (flatLook.Magnitude > 0 and flatLook.Unit) or Vector3.new(0, 0, -1)

            activeVehicleModel:PivotTo(CFrame.lookAt(
                Vector3.new(activeVehicleRoot.Position.X, surfaceY + 2.0, activeVehicleRoot.Position.Z),
                Vector3.new(activeVehicleRoot.Position.X, surfaceY + 2.0, activeVehicleRoot.Position.Z) + flatLook,
                Vector3.yAxis
            ))
            
            FreezeVehiclePhysics(activeVehicleModel)
            activeVehicleRoot.Anchored = false

            RestoreVehicleCollisions(activeVehicleModel)
            RestoreCharCollisions()

            if root and hum and hum.Health > 0 then
                hum.Sit = false
                task.spawn(function()
                    task.wait()
                    if root then
                        root.CFrame = CFrame.new(root.Position.X, surfaceY + 3.2, root.Position.Z) * root.CFrame.Rotation
                        root.AssemblyLinearVelocity = Vector3.zero
                        hum:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end)
            end

            CleanupPlate()
            activeVehicleModel = nil
            activeVehicleRoot = nil
            carBaseSurfaceY = nil
        end
        return
    end

    local vehicleModel = seat:FindFirstAncestorOfClass("Model")
    local rootPart = (vehicleModel and vehicleModel.PrimaryPart) or seat
    if not vehicleModel or not rootPart then return end

    if activeVehicleModel ~= vehicleModel then
        SetVehicleGhost(vehicleModel)
        rootPart.Anchored = false
        activeVehicleModel = vehicleModel
        activeVehicleRoot = rootPart

        carBaseSurfaceY = rootPart.Position.Y
        local targetY = carBaseSurfaceY - UNDERGROUND_DEPTH

        local look = rootPart.CFrame.LookVector
        local flatLook = Vector3.new(look.X, 0, look.Z)
        flatLook = (flatLook.Magnitude > 0 and flatLook.Unit) or Vector3.new(0, 0, -1)

        local plate = GetOrCreateUndergroundPlate()
        plate.CFrame = CFrame.new(rootPart.Position.X, targetY - 2.8, rootPart.Position.Z)

        vehicleModel:PivotTo(CFrame.lookAt(
            Vector3.new(rootPart.Position.X, targetY, rootPart.Position.Z),
            Vector3.new(rootPart.Position.X, targetY, rootPart.Position.Z) + flatLook,
            Vector3.yAxis
        ))

        FreezeVehiclePhysics(vehicleModel)
    end

    if not carBaseSurfaceY then
        carBaseSurfaceY = rootPart.Position.Y
    end

    local targetDepthY = carBaseSurfaceY - UNDERGROUND_DEPTH
    local plate = GetOrCreateUndergroundPlate()
    
    plate.CFrame = CFrame.new(rootPart.Position.X, targetDepthY - 2.8, rootPart.Position.Z)

    local curVel = rootPart.AssemblyLinearVelocity
    rootPart.AssemblyLinearVelocity = Vector3.new(curVel.X, 0, curVel.Z)

    local curAngVel = rootPart.AssemblyAngularVelocity
    rootPart.AssemblyAngularVelocity = Vector3.new(0, curAngVel.Y, 0)

    local look = rootPart.CFrame.LookVector
    local flatLook = Vector3.new(look.X, 0, look.Z)
    flatLook = (flatLook.Magnitude > 0 and flatLook.Unit) or Vector3.new(0, 0, -1)

    rootPart.CFrame = CFrame.lookAt(
        Vector3.new(rootPart.Position.X, targetDepthY, rootPart.Position.Z),
        Vector3.new(rootPart.Position.X, targetDepthY, rootPart.Position.Z) + flatLook,
        Vector3.yAxis
    )
end))

table.insert(Connections, Client.CharacterAdded:Connect(function(newChar)
    task.wait(0.2)
    local root = newChar:WaitForChild("HumanoidRootPart", 5)
    if root then
        roadRayParams.FilterDescendantsInstances = {newChar, undergroundPlate}
        local hit = Workspace:Raycast(root.Position + Vector3.new(0, 10, 0), Vector3.new(0, -25, 0), roadRayParams)
        if hit and root.Position.Y < (hit.Position.Y - 2) then
            root.CFrame = CFrame.new(root.Position.X, hit.Position.Y + 3.2, root.Position.Z)
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end
end))

local CarSnapToggle = VehicleTab:Toggle({
    Title = "รถมุดดิน [V]",
    Desc = "มุดดินเพื่อทะลุกำแพง (เปิดรถบินก่อนใช้งาน)",
    Value = c().CarSnap or false,
    Callback = function(state)
        c().CarSnap = state

        local seat, rootPart, hum, vehicleModel = GetDriverVehicle()

        if state then
            if rootPart and vehicleModel then
                SetVehicleGhost(vehicleModel)
                SetCharGhost(Client.Character)
                rootPart.Anchored = false
                activeVehicleModel = vehicleModel
                activeVehicleRoot = rootPart
                
                carBaseSurfaceY = rootPart.Position.Y
                local targetY = carBaseSurfaceY - UNDERGROUND_DEPTH

                local look = rootPart.CFrame.LookVector
                local flatLook = Vector3.new(look.X, 0, look.Z)
                flatLook = (flatLook.Magnitude > 0 and flatLook.Unit) or Vector3.new(0, 0, -1)

                local plate = GetOrCreateUndergroundPlate()
                plate.CFrame = CFrame.new(rootPart.Position.X, targetY - 2.8, rootPart.Position.Z)

                vehicleModel:PivotTo(CFrame.lookAt(
                    Vector3.new(rootPart.Position.X, targetY, rootPart.Position.Z),
                    Vector3.new(rootPart.Position.X, targetY, rootPart.Position.Z) + flatLook,
                    Vector3.yAxis
                ))
                FreezeVehiclePhysics(vehicleModel)
            end
        else
            local targetModel = vehicleModel or activeVehicleModel
            local targetRoot = rootPart or activeVehicleRoot

            if targetRoot and targetModel then
                targetRoot.Anchored = false
                local surfaceY = GetSurfaceY(targetRoot.Position)
                
                local look = targetRoot.CFrame.LookVector
                local flatLook = Vector3.new(look.X, 0, look.Z)
                flatLook = (flatLook.Magnitude > 0 and flatLook.Unit) or Vector3.new(0, 0, -1)

                targetModel:PivotTo(CFrame.lookAt(
                    Vector3.new(targetRoot.Position.X, surfaceY + 2.0, targetRoot.Position.Z),
                    Vector3.new(targetRoot.Position.X, surfaceY + 2.0, targetRoot.Position.Z) + flatLook,
                    Vector3.yAxis
                ))

                FreezeVehiclePhysics(targetModel)
                RestoreVehicleCollisions(targetModel)
            end

            RestoreObstacleCollisions()
            RestoreCharCollisions()
            
            CleanupPlate()
            activeVehicleModel = nil
            activeVehicleRoot = nil
            carBaseSurfaceY = nil
        end
    end
})

table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.V then
        local newState = not c().CarSnap
        if CarSnapToggle and CarSnapToggle.Set then
            CarSnapToggle:Set(newState)
        else
            c().CarSnap = newState
        end
    end
end))

local function BringMyVehicle()
    local char = Client.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local vehiclesFolder = Workspace:FindFirstChild("Vehicles") or Workspace:FindFirstChild("Cars")
    if not root or not vehiclesFolder then return end

    for _, vehicle in ipairs(vehiclesFolder:GetChildren()) do
        if vehicle:IsA("Model") then
            local ownerId = vehicle:GetAttribute("OwnerUserId") or vehicle:GetAttribute("Owner") or vehicle:GetAttribute("CarOwner")
            if ownerId and (ownerId == Client.UserId or tostring(ownerId) == tostring(Client.UserId) or ownerId == Client.Name) then
                vehicle:PivotTo(root.CFrame * CFrame.new(0, 3, -12) * CFrame.Angles(0, math.rad(90), 0))
                for _, part in ipairs(vehicle:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.AssemblyLinearVelocity = Vector3.zero
                        part.AssemblyAngularVelocity = Vector3.zero
                    end
                end
                return
            end
        end
    end
end

VehicleTab:Button({
    Title = "ดึงรถตัวเอง",
    Callback = BringMyVehicle
})

local function DestroyCurrentVehicle()
    local char = Client.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local seat = hum and hum.SeatPart
    if not seat then return end

    local car = nil

    pcall(function()
        local vehicleModule = require(ReplicatedStorage.Modules.Game.VehicleSystem.Vehicle)
        if vehicleModule and vehicleModule.get_car_player_is_in then
            car = vehicleModule.get_car_player_is_in()
        end
    end)

    if not car then
        car = seat:FindFirstAncestorOfClass("Model")
    end

    if not car then return end

    for _ = 1, 15 do
        pcall(function()
            if Network and typeof(Network.send) == "function" then
                Network.send("crashed_car", car, 150)
            elseif SendRemoteAction then
                SendRemoteAction("crashed_car", car, 150)
            end
        end)
    end
end

VehicleTab:Button({
    Title = "พังรถที่นั่งอยู่",
    Desc = "ต้องนั่งที่คนขับเท่านั้น",
    Callback = DestroyCurrentVehicle
})

local TeleportService = game:GetService("TeleportService")

ServerTab:Section({
    Title = "ข้อมูลเซิร์ฟเวอร์",
})

ServerTab:Code({
    Title = "รหัสเซิร์ฟเวอร์ปัจจุบัน",
    Code = "" .. (game.JobId or "Unknown"),
})

ServerTab:Divider()

ServerTab:Section({Title = "ฟังก์ชันเซิร์ฟเวอร์",})

local TargetServerCode = ""

ServerTab:Input({
    Title = "ใส่รหัสเซิร์ฟเวอร์",
    Placeholder = "วางรหัสเซิร์ฟเวอร์",
    Callback = function(Value)
        TargetServerCode = Value
    end,
})

ServerTab:Button({
    Title = "เข้าเซิร์ฟเวอร์",
    Callback = function()
        if not TargetServerCode or TargetServerCode:gsub("%s+", "") == "" then
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "TEST HUB",
                    Content = "กรุณากรอกรหัสเซิร์ฟเวอร์",
                    Icon = "rbxassetid://122488606489577", 
                    Duration = 2.5,
                })
            end
            return
        end

        TeleportService:TeleportToPlaceInstance(game.PlaceId, TargetServerCode:gsub("%s+", ""), Client)
    end,
})

ServerTab:Divider()

ServerTab:Button({
    Title = "รีจอยเซิร์ฟเวอร์",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Client)
    end,
})

ServerTab:Button({
    Title = "ย้ายไปเซิร์ฟคนน้อย",
    Callback = function()
        if WindUI and WindUI.Notify then
            WindUI:Notify({
                Title = "TEST HUB",
                Content = "กำลังค้นเซิร์ฟคนน้อย...",
                Icon = "rbxassetid://122488606489577", 
                Duration = 2,
            })
        end

        task.spawn(function()
            pcall(function()
                local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", game.PlaceId)
                local response = game:HttpGet(url)
                local data = HttpService:JSONDecode(response)

                if data and data.data then
                    local availableServers = {}

                    for _, s in ipairs(data.data) do
                        if s.id ~= game.JobId and s.playing < s.maxPlayers and s.playing > 0 then
                            table.insert(availableServers, s.id)
                        end
                    end

                    if #availableServers > 0 then
                        local pickIndex = math.random(1, math.min(3, #availableServers))
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, availableServers[pickIndex], Client)
                    else
                        if WindUI and WindUI.Notify then
                            WindUI:Notify({
                                Title = "TEST HUB",
                                Content = "ไม่พบเซิร์ฟเวอร์",
                                Icon = "rbxassetid://122488606489577", 
                                Duration = 2.5,
                            })
                        end
                    end
                end
            end)
        end)
    end,
})  

MiscTab:Section({ Title = "ฟังก์ชันการตั้งค่า" })

MiscTab:Button({
    Title = "บันทึกสิ่งที่เคยเปิดหรือปรับ",
    Desc = "จะบันทึกทั้งหมดที่เคยเปิดหรือปรับ เมื่อรันอีกครั้ง",
    Callback = function()
        SaveConfig()
        if WindUI and WindUI.Notify then
            WindUI:Notify({
                Title = "TEST HUB",
                Content = "บันทึกสิ่งที่เคยเปิดหรือปรับทั้งหมดแล้ว จะทำงานเมื่อออกเข้าใหม่",
                Icon = "rbxassetid://122488606489577", 
                Duration = 3.5,
            })
        end
    end
})

MiscTab:Button({
    Title = "รีเซ็ตสิ่งที่เคยเปิดหรือปรับ",
    Desc = "จะรีเช็ตทั้งหมดที่เคยเปิดหรือปรับ เมื่อรันอีกครั้ง",
    Callback = function()
        pcall(function()
            if delfile and isfile and isfile(ConfigFileName) then
                delfile(ConfigFileName)
            end
        end)
        if WindUI and WindUI.Notify then
            WindUI:Notify({
                Title = "TEST HUB",
                Content = "รีเซ็ตสิ่งที่เคยเปิดทั้งหมดแล้ว จะทำงานเมื่อออกเข้าใหม่",
                Icon = "rbxassetid://122488606489577", 
                Duration = 3.5,
            })
        end
    end
})

MiscTab:Divider()

local OriginalLighting = {}
local OriginalEffects = {}
local OriginalParts = {}
local OriginalDecals = {}

local function EnableFPSBoost()
    pcall(function()
        if next(OriginalLighting) == nil then
            OriginalLighting = {
                FogEnd = Lighting.FogEnd,
                FogStart = Lighting.FogStart,
                Brightness = Lighting.Brightness,
                GlobalShadows = Lighting.GlobalShadows,
                EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
                EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
                ShadowSoftness = Lighting.ShadowSoftness,
            }
        end

        Lighting.FogEnd = 1e10
        Lighting.FogStart = 1e10
        Lighting.Brightness = 1.2
        Lighting.GlobalShadows = false
        Lighting.EnvironmentDiffuseScale = 0.5
        Lighting.EnvironmentSpecularScale = 0.3
        Lighting.ShadowSoftness = 0

        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("BloomEffect") then
                OriginalEffects[effect] = OriginalEffects[effect] or { Intensity = effect.Intensity }
                effect.Intensity = 0.2
            elseif effect:IsA("BlurEffect") then
                OriginalEffects[effect] = OriginalEffects[effect] or { Size = effect.Size }
                effect.Size = 0
            elseif effect:IsA("SunRaysEffect") then
                OriginalEffects[effect] = OriginalEffects[effect] or { Intensity = effect.Intensity }
                effect.Intensity = 0.1
            elseif effect:IsA("ColorCorrectionEffect") then
                OriginalEffects[effect] = OriginalEffects[effect] or { Saturation = effect.Saturation }
                effect.Saturation = 0.7
            end
        end

        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                if OriginalParts[v] == nil then
                    OriginalParts[v] = {
                        Material = v.Material,
                        CastShadow = v.CastShadow,
                        Reflectance = v.Reflectance,
                    }
                end
                v.Material = Enum.Material.SmoothPlastic
                v.CastShadow = false
                v.Reflectance = 0
            elseif v:IsA("Decal") then
                if OriginalDecals[v] == nil then
                    OriginalDecals[v] = v.Transparency
                end
                v.Transparency = 1
            end
        end

        if setfpscap then setfpscap(240) end
    end)
end

local function DisableFPSBoost()
    pcall(function()
        for prop, val in pairs(OriginalLighting) do
            pcall(function() Lighting[prop] = val end)
        end
        table.clear(OriginalLighting)

        for effect, props in pairs(OriginalEffects) do
            if effect and effect.Parent then
                for prop, val in pairs(props) do
                    pcall(function() effect[prop] = val end)
                end
            end
        end
        table.clear(OriginalEffects)

        for part, props in pairs(OriginalParts) do
            if part and part.Parent then
                pcall(function()
                    part.Material = props.Material
                    part.CastShadow = props.CastShadow
                    part.Reflectance = props.Reflectance
                end)
            end
        end
        table.clear(OriginalParts)

        for decal, trans in pairs(OriginalDecals) do
            if decal and decal.Parent then
                pcall(function() decal.Transparency = trans end)
            end
        end
        table.clear(OriginalDecals)

        if setfpscap then setfpscap(60) end
    end)
end

MiscTab:Toggle({
    Title = "บูส FPS",
    Value = c().BoostFPS or false,
    Callback = function(state)
        c().BoostFPS = state
        if state then
            EnableFPSBoost()
        else
            DisableFPSBoost()
        end
    end
})