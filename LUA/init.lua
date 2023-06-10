--// Services
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

--// Modules
local Network = require(ReplicatedStorage.Network)
local Config = require(script.Config)
local GameData = Network:GetModule("GameData")
local Utilities = Network:GetModule("Utilities")
local Janitor = Network:GetModule("Janitor")
local Multipliers = Network:GetModule("Multipliers")

--// General
local ServerInfo = ReplicatedStorage.ServerInfo
local HUD = {}
HUD.__index = HUD
local Create = Utilities.Create
local Player = Players.LocalPlayer
local Assets = ReplicatedStorage.Assets
local GUI = Assets.GUI



--// State Icon Class \\--
local StateIcon = {}
StateIcon.__index = StateIcon

function StateIcon.new(State)

    local NewIcon = setmetatable({},StateIcon)

    local IconTemplate = Instance.new("ImageButton")
    IconTemplate.Name = "IconTemplate"
    IconTemplate.ZIndex = 2
    IconTemplate.AnchorPoint = Vector2.new(0, 1)
    IconTemplate.Size = UDim2.new(1, 0, 1, 0)
    IconTemplate.BackgroundTransparency = 1
    IconTemplate.Position = UDim2.new(0.5, 0, 0.5, 0)
    IconTemplate.BorderSizePixel = 0
    IconTemplate.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    IconTemplate.Image = "rbxassetid://12195753422"

    local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
    UIAspectRatioConstraint.Parent = IconTemplate

    local Icon = Instance.new("ImageLabel")
    Icon.Name = "Icon"
    Icon.Size = UDim2.new(1, 0, 1, 0)
    Icon.BackgroundTransparency = 1
    Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Icon.Image = Config.VisualStates[State]
    Icon.Parent = IconTemplate

    local Border = Instance.new("ImageLabel")
    Border.Name = "Border"
    Border.ZIndex = 0
    Border.Size = UDim2.new(1, 0, 1, 0)
    Border.BackgroundTransparency = 1
    Border.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Border.Image = "rbxassetid://12195756113"
    Border.Parent = IconTemplate

    NewIcon.Instance = IconTemplate

    return NewIcon

end

function StateIcon:Destroy()

    self.Instance:Destroy()
    self = nil

end
--// End Of STATE ICON Class \\--









local function GetY()

    local _, y, _ = workspace.CurrentCamera.CFrame:ToOrientation()

    local deg = math.deg(y)

    return deg > 0 and deg or 360 + deg

end

local function CreateMouse()

    UIS.MouseIconEnabled = false

    local Frame = Create("Frame",{
        Size = UDim2.new(.025,0,.025,0),
        AnchorPoint = Vector2.new(.5,.5),
        Name = "MouseIcon",
        BackgroundTransparency = 1
    })

    Create("UIAspectRatioConstraint",{
        Parent = Frame,
    })

    Create("ImageLabel",{
        Size = UDim2.new(1,0,1,0),
        Position = UDim2.new(.5,0,.5,0),
        AnchorPoint = Vector2.new(.5,.5),
        Name = "Icon",
        Image = "rbxassetid://12976263936",
        Parent = Frame,
        BackgroundTransparency = 1,
        ZIndex = math.huge
    })

    return Frame

end

function HUD.new()

    local self = setmetatable({}, HUD)

    self.Instance = Create(GUI.HUD:Clone(),{
        Parent = Player.PlayerGui
    })

    self.Player = Player
    self.Character = Player.Character
    self.File = Utilities.GetFile(Player)
    self.Humanoid = self.Character.Humanoid
    self.Backpack = Network:GetModule("Backpack")
    self.Backpack.MainFrame.Parent = self.Instance.Background
    self.Background = self.Instance.Background
    self.Core = self.Background.Core
    self.Compass = self.Background.Compass
    self.SkillsTab = self.Background.SkillsTab
    self.ExpBar = self.Background.Core.Background.Exp
    self.StateIcons = {}
    self.Folder = Utilities.GetFile(Player)
    self.Janitor = Janitor.new()
    self.MouseIcon = CreateMouse()
    self.MouseIcon.Parent = self.Instance
    self.Mouse = Player:GetMouse()
    self.TopBar = self.Background.TopBar
    self:Run()

    return self

end

function HUD:Run()
    
    local HealthBar,StaminaBar,MagicBar = self.Core.HealthBar.Bar,self.Core.StaminaBar.Bar,self.Core.MagicBar.Bar
    local Left,Right = self.ExpBar.LeftClip.Left.UIGradient,self.ExpBar.RightClip.Right.UIGradient
    local YulLabel = self.Core.Yul
    local LastHealth = self.Humanoid.Health
    local FPS = self.Core.Background.FPS
    local LastIteration,Start,TimeFunction,FrameUpdateTable = nil,nil,RunService:IsRunning() and time or os.clock,{}
    local Janitor = self.Janitor

    --// Connectors
    local function UpdateHealthBar()

        local Diff = (LastHealth - self.Humanoid.Health)
        LastHealth = self.Humanoid.Health

        if Diff > 0 then

            Network.BindableEvent:Fire{
                Directory = "Tint",
                FunctionData = {
                    Duration = .1 * (Diff/self.Humanoid.MaxHealth)
                }
            }
 
        end

        local Percent = (self.Humanoid.Health/self.Humanoid.MaxHealth)
        local oneOverProgress

        if Percent == 0 then

            oneOverProgress = 0

        else

            oneOverProgress = 1/Percent

        end

        TweenService:Create(HealthBar.Clipping,TweenInfo.new(.5),{Size = UDim2.new(Percent, 0, 1, 0)}):Play()
        TweenService:Create(HealthBar.Clipping.Top,TweenInfo.new(.5),{Size = UDim2.new(oneOverProgress, 0, 1, 0)}):Play()
        TweenService:Create(HealthBar.Clipping.Glow,TweenInfo.new(.5),{Size = UDim2.new(oneOverProgress, 0, 1, 0)}):Play()

    end

    local function UpdateStaminaBar()

        local Percent = (self.Character:GetAttribute("Stamina")/self.Character:GetAttribute("MaxStamina"))
        local oneOverProgress
 
        if Percent == 0 then

            oneOverProgress = 0

        else

            oneOverProgress = 1/Percent

        end

        TweenService:Create(StaminaBar.Clipping,TweenInfo.new(.5),{Size = UDim2.new(Percent, 0, 1, 0)}):Play()
        TweenService:Create(StaminaBar.Clipping.Top,TweenInfo.new(.5),{Size = UDim2.new(oneOverProgress, 0, 1, 0)}):Play()
        TweenService:Create(StaminaBar.Clipping.Glow,TweenInfo.new(.5),{Size = UDim2.new(oneOverProgress, 0, 1, 0)}):Play()

    end

    local function UpdateMagicBar()

        local Percent = (self.Character:GetAttribute("Magic")/self.Character:GetAttribute("MaxMagic"))
        local oneOverProgress

        if Percent == 0 then

            oneOverProgress = 0

        else

            oneOverProgress = 1/Percent

        end

        TweenService:Create(MagicBar.Clipping,TweenInfo.new(.5),{Size = UDim2.new(Percent, 0, 1, 0)}):Play()
        TweenService:Create(MagicBar.Clipping.Top,TweenInfo.new(.5),{Size = UDim2.new(oneOverProgress, 0, 1, 0)}):Play()
        TweenService:Create(MagicBar.Clipping.Glow,TweenInfo.new(.5),{Size = UDim2.new(oneOverProgress, 0, 1, 0)}):Play()

    end

    local function UpdateExp()

        local Exp = self.Folder.Exp.Value
        local Level = self.Folder.Exp.MaxValue / Multipliers.Exp
        local ExpPercent = Exp / self.Folder.Exp.MaxValue
        
        self.Core.Background.Exp.Level.Text = Level

        local FillDegree = ExpPercent * 360
        FillDegree = math.fmod(FillDegree, 360)

        if FillDegree < 180 and FillDegree > -180 then
            TweenService:Create(Right,TweenInfo.new(.25),{Rotation = FillDegree}):Play()
            TweenService:Create(Left,TweenInfo.new(.25),{Rotation = 0}):Play()
        else
            TweenService:Create(Right,TweenInfo.new(.25),{Rotation = 180}):Play()
            TweenService:Create(Left,TweenInfo.new(.25),{Rotation = FillDegree - 180}):Play()
        end

    end

    local function AddVisualStatus(State)

        if not Config.VisualStates[State] then return end

        if self.Character:GetAttribute(State) and not self.StateIcons[State] then

            local Icon = StateIcon.new(State)
            Icon.Instance.Parent = self.Core.States
            self.StateIcons[State] = Icon

        elseif self.StateIcons[State] then

            self.StateIcons[State]:Destroy()
            self.StateIcons[State] = nil

        end

    end

    local function BarEffect(Parent,Math)

        local f = Create("Frame",{
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.new(1, 1, 1),
            ZIndex = 2,
            BackgroundTransparency = Random.new():NextNumber(0.2, 0.4),
            Size = UDim2.new(0, math.random(1, 2), 0, math.random(1, 35)),
            Position = UDim2.new(Random.new():NextNumber(0.01, 0.95), 0, 1, 0),
            Parent = Parent
        })
        
	    local length = Random.new():NextNumber(1, 2)

        TweenService:Create(f, TweenInfo.new(length, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1,
            Position = UDim2.new(f.Position.X.Scale, 0, -1, 0)
        }):Play()
	
        Debris:AddItem(f,length)

	    task.wait(math.clamp(0.5 - Math, 0.05, 0.5))

    end

    local function UpdateCompass()

        for _, v in pairs(self.Compass:GetChildren()) do

            if not (v:IsA("TextLabel") or v:IsA("Frame")) then continue end
    
            local num = tonumber(v.Name:match("%d+"))
            local off = math.rad(num/(16 + 8) * 360)
            local angle = math.rad((360 - GetY()) + -105)
            local x, y = math.cos(angle + off) * Vector2.new(0.55, 0.475).X, math.sin(angle + off) * Vector2.new(0.55, 0.475).Y

            v.Position = UDim2.fromScale(0.5 + x, 0.5 + y + (v:IsA("Frame") and -0.15 or 0))

        end

    end

	local function UpdateYul()

		TweenService:Create(Janitor:Get("FakeYul"),TweenInfo.new(1),{Value = self.Folder.Yul.Value}):Play()
        
    end

    local function OnFakeYulChanged()

        YulLabel.Text = Janitor:Get("FakeYul").Value

    end

    local function ToolSensory(Tool)

        if not Tool:IsA("Tool") then return end

        self.CurrentTool = self.Character:FindFirstChildOfClass("Tool")

        self:OpenSkillTab()

    end
    
    local function UpdateFPS()

        LastIteration = TimeFunction()
        for Index = #FrameUpdateTable, 1, -1 do
            FrameUpdateTable[Index + 1] = FrameUpdateTable[Index] >= LastIteration - 1 and FrameUpdateTable[Index] or nil
        end

        FrameUpdateTable[1] = LastIteration

        FPS.Text = tostring(math.floor(TimeFunction() - Start >= 1 and #FrameUpdateTable or #FrameUpdateTable / (TimeFunction() - Start))).."|"..ServerInfo.Region.Value

    end

    local function UpdateMouse()

        self.MouseIcon.Position = UDim2.fromOffset(self.Mouse.X,self.Mouse.Y+36)
        self.MouseIcon.Icon.Rotation +=1

    end

    local function Leaderboard()

        local PlayerCache = {}

        local function OnPlayerAdded(Plr)

            if PlayerCache[Plr] then return end

            local Entry = Config.LeaderboardClass(Plr)
            Entry.Instance.Parent = self.Background.Leaderboard
            PlayerCache[Plr] = Entry
            
        end

        local function OnPlayerRemoved(Plr)

            if not PlayerCache[Plr] then return end

            PlayerCache[Plr]:Destroy()
            
        end

        
        for _,Entry in ipairs(Players:GetChildren()) do
            OnPlayerAdded(Entry)
        end
        
        Players.PlayerAdded:Connect(OnPlayerAdded)
        Players.PlayerRemoving:Connect(OnPlayerRemoved)


    end
    
    local function SetPing()

        self.TopBar.Ping.Ping.Text = Player:GetNetworkPing()
        task.wait(1)
        
    end

    local function SetTopbarData()

        self.TopBar.Version.Entry.Text = GameData.Version
        self.TopBar.Info.Title.Text = self.File.Firstname.Value.." "..self.File.Family.Value
        self.TopBar.Info.ID.Text = Player.UserId.." : "..self.File.Parent.CurrentFile.Value

    end
    --// End Of Connectors \\--

    Start = TimeFunction()

    --// Nests % Connections
    Janitor:Add(self.Humanoid.HealthChanged:Connect(UpdateHealthBar))
    Janitor:Add(self.Character.AttributeChanged:Connect(AddVisualStatus))
    Janitor:Add(self.Folder.Exp.Changed:Connect(UpdateExp))
    Janitor:Add(self.Character:GetAttributeChangedSignal("MaxStamina"):Connect(UpdateStaminaBar))
    Janitor:Add(self.Character:GetAttributeChangedSignal("Stamina"):Connect(UpdateStaminaBar))
    Janitor:Add(self.Character:GetAttributeChangedSignal("MaxMagic"):Connect(UpdateMagicBar))
    Janitor:Add(self.Character:GetAttributeChangedSignal("Magic"):Connect(UpdateMagicBar))
    Janitor:Add(RunService.Heartbeat:Connect(function() BarEffect(HealthBar.Clipping.Top,(self.Humanoid.Health/self.Humanoid.MaxHealth)) end))
    Janitor:Add(RunService.Heartbeat:Connect(function() BarEffect(StaminaBar.Clipping.Top,(1)) end))
    Janitor:Add(RunService.Heartbeat:Connect(function() BarEffect(MagicBar.Clipping.Top,(1)) end))
	Janitor:Add(RunService.Heartbeat:Connect(UpdateCompass))
	Janitor:Add(Create("IntValue",{Value = 0}),"Destroy","FakeYul")
    Janitor:Add(self.Folder.Yul.Changed:Connect(UpdateYul))
    Janitor:Add(Janitor:Get("FakeYul").Changed:Connect(OnFakeYulChanged))
    Janitor:Add(self.Character.ChildAdded:Connect(ToolSensory))
    Janitor:Add(self.Character.ChildRemoved:Connect(ToolSensory))
    Janitor:Add(self.Character:GetAttributeChangedSignal("ComboString"):Connect(function() self.Background.Combo.Text = self.Character:GetAttribute("ComboString") end))
    Janitor:Add(RunService.Heartbeat:Connect(UpdateFPS))
    Janitor:Add(RunService.Heartbeat:Connect(UpdateMouse))
    Janitor:Add(RunService.Heartbeat:Connect(SetPing))

    UpdateYul()
    UpdateExp()
    Leaderboard()
    SetTopbarData()

end 

function HUD:OpenSkillTab()

    local MasteryFill = self.SkillsTab.Mastery.Fill.UIGradient
    

	if self.CurrentTool then

        local MasteryObj = self.File.Mastery[self.CurrentTool.Name]
		TweenService:Create(self.SkillsTab, Config.tinfos.frame, {GroupTransparency = 0}):Play()

		for _, k in pairs(self.SkillsTab:GetChildren()) do

			if k:IsA("Frame") then  
            
                TweenService:Create(k, Config.tinfos.frameRot, {Rotation = 0}):Play()
 
            elseif k.Name == "Mastery" then

                TweenService:Create(k, Config.tinfos.frameRot, {Position = UDim2.new(.325,0,.64,0)}):Play()

                local function UpdateMastery()

                    local Level = (MasteryObj.MaxValue) / Multipliers.Mastery
                    self.SkillsTab.Mastery.Level.Value.Text = Level
                    local Exp = MasteryObj.Value / MasteryObj.MaxValue
                    local FillDegree = Exp * 180
                    FillDegree = math.fmod(FillDegree,180)
                    TweenService:Create(MasteryFill,TweenInfo.new(.25),{Rotation = FillDegree}):Play()

                end

                UpdateMastery()

                self.Janitor:Add(
                    self.File.Mastery[self.CurrentTool.Name].Changed:Connect(UpdateMastery),
                    "Disconnect",
                    "MasteryUpdate"
                )

                self.Janitor:Get("MasteryUpdate")

            end

		end

	else

		TweenService:Create(self.SkillsTab, Config.tinfos.frame, {GroupTransparency = 1}):Play()

		for _, k in pairs(self.SkillsTab:GetChildren()) do

            if k:IsA("Frame") then  
            
                TweenService:Create(k, Config.tinfos.frameRot, {Rotation = -180}):Play()

            elseif k.Name == "Mastery" then
                TweenService:Create(k, Config.tinfos.frameRot, {Position = UDim2.new(.75,0,.64,0)}):Play()
                self.Janitor:Remove("MasteryUpdate")

            end
	
		end

	end


end

function HUD:Destroy()

    self.Janitor:Destroy()

    setmetatable(self,nil)

    self = nil

end
















return HUD
