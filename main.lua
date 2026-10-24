if not LPH_OBFUSCATED then
    LPH_JIT_MAX = function(...) return ... end
    LPH_NO_VIRTUALIZE = function(...) return ... end
    LPH_ENCSTR = function(...) return ... end
    LPH_ENCFUNC = function(...) return ... end
    LPH_CRASH = function() end
end


    -- removed unused whitelist key
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local Workspace = game.Workspace
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Self = Players.LocalPlayer
    local Mouse = Self:GetMouse()
    local Camera = game:FindFirstChild("Workspace").CurrentCamera
    local GuiInsetOffsetY = game:GetService('GuiService'):GetGuiInset().Y
    local CanTriggerbotShoot = true
    local Script = {
        RBXConnections = {},
        Locals = {},
        Visuals = {}
    }
    local WeaponMap = {}
    local Velocity_Data = {
        Tick = tick(),
        Sample = nil,
        State = Enum.HumanoidStateType.Running,
        Y = nil,
        Recorded = {
            Alpha = nil,
            B_0 = nil,
            V_T = nil,
            V_B = nil
        }
    }
    local aliases = {
        ["[Double-Barrel SG]"] = {"db", "double barrel", "double-barrel", "dbl sg", "double sg", "db sg"},
        ["[TacticalShotgun]"] = {"tac", "tac sg", "tactical shotgun", "tactical sg", "tacshot", "tactical"},
        ["[Drum-Shotgun]"] = {"drum sg", "drum shotgun", "auto sg", "drum auto", "drum"},
        ["[Shotgun]"] = {"sg", "shotgun", "pump", "pump sg", "pump shotgun", "buckshot"},
        ["[Revolver]"] = {"rev", "revolver", "six shooter", "wheel gun", "colt", "magnum"},
        ["[Silencer]"] = {"silencer", "suppressed", "supp pistol", "silenced pistol", "quiet gun"},
        ["[Glock]"] = {"glock", "g17", "glock 17", "pistol", "semi", "9mm"},
        ["[Rifle]"] = {"rifle", "ar", "assault rifle", "m4", "m4a1", "m16"},
        ["[AUG]"] = {"aug", "steyr aug", "bullpup", "aug rifle"},
        ["[AR]"] = {"ar", "assault rifle", "m4", "m4a1", "rifle"},
        ["[SMG]"] = {"smg", "submachine gun", "uzi", "mp5", "mp7", "vector"},
        ["[LMG]"] = {"lmg", "light machine gun", "m249", "saw", "negev"},
        ["[P90]"] = {"p90", "fn p90", "pdw", "personal defense weapon"},
        ["[AK47]"] = {"ak", "ak47", "kalashnikov", "akm", "russian rifle"},
        ["[SilencerAR]"] = {"silencer ar", "suppressed ar", "silenced rifle", "quiet ar"},
        ["[DrumGun]"] = {"drum gun", "tommy gun", "thompson", "drum ar", "drum rifle"}
    }
    for weapon, names in pairs(aliases) do
        for _, alias in ipairs(names) do
            WeaponMap[alias] = weapon
        end
    end
    local Modules = { Cache = {} }
    function Modules.Get(Id)
        if not Modules.Cache[Id] then
            Modules.Cache[Id] = {
                c = Modules[Id](),
            }
        end
    
        return Modules.Cache[Id].c
    end
    local function InitializeLocals()
        local defaults = {
            LPH_ENCSTR("GunScriptDisabled"), LPH_ENCSTR("IsTriggerBotting"), LPH_ENCSTR("TriggerbotTarget"), LPH_ENCSTR("IsDoubleTapping"), LPH_ENCSTR("SilentAimTarget"), 
            LPH_ENCSTR("AimAssistTarget"), LPH_ENCSTR("IsWalkSpeeding"), LPH_ENCSTR("DoubleTapState"), LPH_ENCSTR("CurrentWeapon"), 
            LPH_ENCSTR("IsBoxFocused"), LPH_ENCSTR("TriggerState"), LPH_ENCSTR("HitPosition"), LPH_ENCSTR("HitTrigger"), LPH_ENCSTR("MoveVector"), LPH_ENCSTR("LastShot"), 
            LPH_ENCSTR("IsAimed"), LPH_ENCSTR("HitPart"), LPH_ENCSTR("CodeRegion"), LPH_ENCSTR("FieldOfViewOne"), LPH_ENCSTR("FieldOfViewTwo"), LPH_ENCSTR("IsOverriding")
                                                                                             -- Silent Aim        Silent Aim Circle       
        }
        
        for _, v in ipairs(defaults) do Script.Locals[v] = nil end
        Script.Locals.LastShot = 0
        Script.Locals.CodeRegion = "Initialization"
        Script.Locals.HitPosition = Vector3.new()
    end
    local function SetRegion(Region)
        Script.Locals.CodeRegion = Region
    end
    local function GetRegion()
        return Script.Locals.CodeRegion
    end
    InitializeLocals()
    local ESP, Resolver = {
        Priority = {}, PriorityLines = {}, PriorityTexts = {}, PrioritySquares = {},
        PriorityLabels = {}, PriorityTools = {}, PrioritySquaresOutlines = {}
    }, {
        Connections = {}, ToolConnections = {}, Tracked = {}, Previous = {}, Current = nil, Tick = tick()
    }
    local WeaponInfo = {
        Shotguns = {"[TacticalShotgun]", "[Shotgun]", "[Double-Barrel SG]"},
        AutoShotguns = {"[Drum-Shotgun]"},
        Pistols = {"[Revolver]", "[Silencer]", "[Glock]"},
        Rifles = {"[AR]", "[SilencerAR]", "[AK47]", "[LMG]", "[DrumGun]"},
        Bursts = {"[AUG]"},
        SMG = {"[SMG]", "[P90]"},
        Snipers = {"[Rifle]"},
        Offsets = {
            ["[Double-Barrel SG]"] = CFrame.new(0, 0.35, -2.2),
            ["[TacticalShotgun]"] = CFrame.new(0, 0.25, -2.5),
            ["[Drum-Shotgun]"] = CFrame.new(-0.1, 0.5, -2.5),
            ["[Shotgun]"] = CFrame.new(0, 0.25, -2.5),
            ["[Revolver]"] = CFrame.new(-1, 0.4, 0),
            ["[Silencer]"] = CFrame.new(0, 0.4, 1.3),
            ["[Glock]"] = CFrame.new(0.6, 0.25, 0),
            ["[Rifle]"] = CFrame.new(0, 0.25, 2.5),
            ["[AUG]"] = CFrame.new(-0.1, 0.4, 1.8),
            ["[AR]"] = CFrame.new(2, 0.35, 0),
            ["[SMG]"] = CFrame.new(0, 1, 0.5),
            ["[LMG]"] = CFrame.new(0, 0.7, -3.8),
            ["[P90]"] = CFrame.new(0, 0.2, -1.7),
            ["[AK47]"] = CFrame.new(-0.1, 0.5, -2.5),
            ["[SilencerAR]"] = CFrame.new(2.5, 0.35, 0),
            ["[DrumGun]"] = CFrame.new(0, 0.4, 2.4)
        },
        Delays = {
            ["[Double-Barrel SG]"] = 0.0595, ["[TacticalShotgun]"] = 0.0095, ["[Drum-Shotgun]"] = 0.415,
            ["[Shotgun]"] = 1.2, ["[Revolver]"] = 0.0095, ["[Silencer]"] = 0.0095, ["[Glock]"] = 0.0095,
            ["[Rifle]"] = 1.3095, ["[AUG]"] = 0.0095, ["[AR]"] = 0.15, ["[SMG]"] = 0.6,
            ["[LMG]"] = 0.62, ["[P90]"] = 0.6, ["[AK47]"] = 0.15, ["[SilencerAR]"] = 0.02
        }
    }
    local CurrentFOV, CurrentFOVX, CurrentFOVY = nil, nil, nil
    local TriggerPart = Instance.new("Part")
    TriggerPart.Name = math.random(1, 99999999)
    local SilentAimPart = Instance.new("Part")
    TriggerPart.Name = math.random(1, 99999999)
    
    
    local IsSilentAiming = true
       -- Silent Aim, Triggerbot, WalkSpeed, DoubleTap, Override
    local LabelOne, LabelTwo, LabelThree, LabelFour, LabelFive
    local function GameFunctions()
        SetRegion("Game Functions")
        return {
            IsKnocked = function(Player)
                return Player and Player:FindFirstChild('BodyEffects') and 
                       Player.BodyEffects['K.O'].Value or false
            end,
            IsGrabbed = function(Player)
                return Player and Player.Character and Player.Character:FindFirstChild('GRABBING_CONSTRAINT') ~= nil
            end,
        }
    end
    local Games = {
        [LPH_ENCSTR('Da Hood')] = { HoodGame = true, Functions = GameFunctions() },
        [LPH_ENCSTR('Dee Hood')] = { HoodGame = true, Updater = "", Functions = GameFunctions(),
                          RemotePath = function() return game.ReplicatedStorage.MainEvent end },
        [LPH_ENCSTR('Der Hood')] = { HoodGame = true, Updater = LPH_ENCSTR("DERHOODMOUSEPOS666^"), Functions = GameFunctions(),
                          RemotePath = function() return game.ReplicatedStorage.MainRemotes.MainRemoteEvent end },
        [LPH_ENCSTR('Dea Hood')] = { HoodGame = true, Updater = LPH_ENCSTR("DEAHOODMOUSEPOSx3^3"), Functions = GameFunctions(),
                          RemotePath = function() return game.ReplicatedStorage.MainRemotes.MainRemoteEvent end },
        [LPH_ENCSTR('a literal baseplate.')] = { HoodGame = false, Functions = GameFunctions() },
        [LPH_ENCSTR('Universal')] = { HoodGame = false, Functions = GameFunctions() }
    }
    local MarketplaceService = game:GetService("MarketplaceService")
    local Success, Info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    local GameName = Success and Info.Name or "Universal"
    local Match
    for Index in pairs(Games) do
        if string.match(GameName, Index) then
            Match = Index
            break
        end
    end
    local CurrentGame = Games[Match] or Games.Universal
    SetRegion("Threading")
    local function ThreadLoop(Wait, Func)
        task.spawn(function()
            while true do
                local Delta = task.wait(Wait)
                local Success, Result = pcall(Func, Delta)
                if not Success then
                    warn("Thread error:", Result)
                elseif Result == "break" then
                    break
                end
            end
        end)
    end
    
    local function ThreadFunction(Func, Name, ...)
        local WrappedFunc = Name and function()
            local Passed, Statement = pcall(Func)
            if not Passed then
                warn('ThreadFunction Error:\n', '              ' .. Name .. ':', Statement)
            end
        end or Func
        local Thread = coroutine.create(WrappedFunc)
        coroutine.resume(Thread, ...)  
        return Thread
    end
    
    local function RBXConnection(Signal, Callback)
        local connection = Signal:Connect(Callback)
        Script.RBXConnections[#Script.RBXConnections + 1] = connection
        return connection
    end
    do
        SetRegion("Drawing")
        local CustomLibIndex = 0
        local UtilityUI = Instance.new('ScreenGui'); UtilityUI.Parent = game:GetService("CoreGui"); UtilityUI.IgnoreGuiInset = true
        local UserInputService = game:GetService("UserInputService")
        local Clamp = math.clamp
        local Atan2 = math.atan2
        local Deg = math.deg
        local LibraryMeta = setmetatable({
            Visible = true,
            ZIndex = 0,
            Transparency = 1,
            Color = Color3.new(),
            Remove = function(self)
                setmetatable(self, nil)
            end,
            Destroy = function(self)
                setmetatable(self, nil)
            end
        }, {
            __add = function(t1, t2)
                local result = table.clone(t1)
    
                for index, value in t2 do
                    result[index] = value
                end
                return result
            end
        })
        local function ClampTransparency(number)
            return Clamp(1 - number, 0, 1)
        end
        function Script.Visuals.new(ClassType)
            CustomLibIndex += 1
            if ClassType == 'Line' then
                local LineObject = ({
                    From = Vector2.zero,
                    To = Vector2.zero,
                    Thickness = 1
                } + LibraryMeta)
                --
                local Line = Instance.new('Frame')
                --
                Line.Name = CustomLibIndex
                Line.AnchorPoint = (Vector2.one * .5)
                Line.BorderSizePixel = 0
                Line.BackgroundColor3 = LineObject.Color
                Line.Visible = LineObject.Visible
                Line.ZIndex = LineObject.ZIndex
                Line.BackgroundTransparency = ClampTransparency(LineObject.Transparency)
                Line.Size = UDim2.new()
                Line.Parent = UtilityUI
                --
                return setmetatable(table.create(0), {
                    __newindex = function(_, Property, Value)
                        if Property == 'From' then
                            local Direction = (LineObject.To - Value)
                            local Center = (LineObject.To + Value) / 2
                            local Magnitude = Direction.Magnitude
                            local Theta = Deg(Atan2(Direction.Y, Direction.X))
                            --
                            Line.Position = UDim2.fromOffset(Center.X, Center.Y)
                            Line.Rotation = Theta
                            Line.Size = UDim2.fromOffset(Magnitude, LineObject.Thickness)
                        elseif Property == 'To' then
                            local Direction = (Value - LineObject.From)
                            local Center = (Value + LineObject.From) / 2
                            local Magnitude = Direction.Magnitude
                            local Theta = Deg(Atan2(Direction.Y, Direction.X))
                            --
                            Line.Position = UDim2.fromOffset(Center.X, Center.Y)
                            Line.Rotation = Theta
                            Line.Size = UDim2.fromOffset(Magnitude, LineObject.Thickness)
                        elseif Property == 'Thickness' then
                            local Thickness = (LineObject.To - LineObject.From).Magnitude
                            Line.Size = UDim2.fromOffset(Thickness, Value)
                        elseif Property == 'Visible' then
                            Line.Visible = Value
                        elseif Property == 'ZIndex' then
                            Line.ZIndex = Value
                        elseif Property == 'Transparency' then
                            Line.BackgroundTransparency = ClampTransparency(Value)
                        elseif Property == 'Color' then
                            Line.BackgroundColor3 = Value
                        end
                        LineObject[Property] = Value
                    end,
                    __index = function(self, index)
                        if index == 'Remove' or index == 'Destroy' then
                            return function()
                                Line:Destroy()
                                LineObject.Remove(self)
                                return LineObject:Remove()
                            end
                        end
                        return LineObject[index]
                    end,
                    __tostring = function() return 'CustomLib' end
                })
            elseif ClassType == 'Circle' then
                local circleObj = ({
                    Radius = 150,
                    Position = Vector2.zero,
                    Thickness = .7,
                    Filled = false
                } + LibraryMeta)
    
                local circleFrame, uiCorner, uiStroke = Instance.new('Frame'), Instance.new('UICorner'), Instance.new('UIStroke')
                circleFrame.Name = CustomLibIndex
                circleFrame.AnchorPoint = (Vector2.one * .5)
                circleFrame.BorderSizePixel = 0
    
                circleFrame.BackgroundTransparency = (circleObj.Filled and ClampTransparency(circleObj.Transparency) or 1)
                circleFrame.BackgroundColor3 = circleObj.Color
                circleFrame.Visible = circleObj.Visible
                circleFrame.ZIndex = circleObj.ZIndex
    
                uiCorner.CornerRadius = UDim.new(1, 0)
                circleFrame.Size = UDim2.fromOffset(circleObj.Radius, circleObj.Radius)
    
                uiStroke.Thickness = circleObj.Thickness
                uiStroke.Enabled = not circleObj.Filled
                uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
                circleFrame.Parent, uiCorner.Parent, uiStroke.Parent = UtilityUI, circleFrame, circleFrame
                return setmetatable(table.create(0), {
                    __newindex = function(_, index, value)
                        if typeof(circleObj[index]) == 'nil' then return end
    
                        if index == 'Radius' then
                            local radius = value * 2
                            circleFrame.Size = UDim2.fromOffset(radius, radius)
                        elseif index == 'Position' then
                            circleFrame.Position = UDim2.fromOffset(value.X, value.Y)
                        elseif index == 'Thickness' then
                            value = Clamp(value, .6, 0x7fffffff)
                            uiStroke.Thickness = value
                        elseif index == 'Filled' then
                            circleFrame.BackgroundTransparency = (circleObj.Filled and ClampTransparency(circleObj.Transparency) or 1)
                            uiStroke.Enabled = not value
                        elseif index == 'Visible' then
                            circleFrame.Visible = value
                        elseif index == 'ZIndex' then
                            circleFrame.ZIndex = value
                        elseif index == 'Transparency' then
                            local transparency = ClampTransparency(value)
    
                            circleFrame.BackgroundTransparency = (circleObj.Filled and transparency or 1)
                            uiStroke.Transparency = transparency
                        elseif index == 'Color' then
                            circleFrame.BackgroundColor3 = value
                            uiStroke.Color = value
                        end
                        circleObj[index] = value
                    end,
                    __index = function(self, index)
                        if index == 'Remove' or index == 'Destroy' then
                            return function()
                                circleFrame:Destroy()
                                circleObj.Remove(self)
                                return circleObj:Remove()
                            end
                        end
                        return circleObj[index]
                    end,
                    __tostring = function() return 'CustomLib' end
                })
            elseif ClassType == 'Square' then
                local squareObj = ({
                    Size = Vector2.zero,
                    Position = Vector2.zero,
                    Thickness = .7,
                    Filled = false,
                    Drag = false,
                } + LibraryMeta)
    
                local squareFrame, uiStroke = Instance.new('Frame'), Instance.new('UIStroke')
                squareFrame.Name = CustomLibIndex
                squareFrame.BorderSizePixel = 0
                local transparency
                if squareObj.Filled then
                    transparency = ClampTransparency(squareObj.Transparency)
                else
                    transparency = 1
                end
                squareFrame.BackgroundTransparency = transparency
                squareFrame.ZIndex = squareObj.ZIndex
                squareFrame.BackgroundColor3 = squareObj.Color
                squareFrame.Visible = squareObj.Visible
                uiStroke.Thickness = squareObj.Thickness
                uiStroke.Enabled = not squareObj.Filled
                uiStroke.LineJoinMode = Enum.LineJoinMode.Miter
                squareFrame.Parent, uiStroke.Parent = UtilityUI, squareFrame
                local dragging = false
                local dragStart = nil
                local startPos = nil
                squareFrame.MouseEnter:Connect(function()
                    if squareObj.Drag then
                        local inputConnection
                        inputConnection = UserInputService.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                dragging = true
                                dragStart = input.Position
                                startPos = squareFrame.Position
                            end
                        end)
                        local leaveConnection
                        leaveConnection = squareFrame.MouseLeave:Connect(function()
                            inputConnection:Disconnect()
                            leaveConnection:Disconnect()
                        end)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if squareObj.Drag then
                        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            local delta = input.Position - dragStart
                            local newX = startPos.X.Offset + delta.X
                            local newY = startPos.Y.Offset + delta.Y
                            squareFrame.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
                        end
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if squareObj.Drag then
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                        end
                    end
                end)
                return setmetatable(table.create(0), {
                    __newindex = function(_, index, value)
                        if typeof(squareObj[index]) == 'nil' then return end
    
                        if index == 'Size' then
                            squareFrame.Size = UDim2.fromOffset(value.X, value.Y)
                        elseif index == 'Position' then
                            squareFrame.Position = UDim2.fromOffset(value.X, value.Y)
                        elseif index == 'Thickness' then
                            value = Clamp(value, 0.6, 0x7fffffff)
                            uiStroke.Thickness = value
                        elseif index == 'Visible' then
                            squareFrame.Visible = value
                        elseif index == 'Transparency' then
                            local transparency = ClampTransparency(value)
                            squareFrame.BackgroundTransparency = 1
                            uiStroke.Transparency = transparency
                        elseif index == 'Color' then
                            uiStroke.Color = value
                            squareFrame.BackgroundColor3 = value
                        end
                        squareObj[index] = value
                    end,
                    __index = function(self, index)
                        if index == 'Remove' or index == 'Destroy' then
                            return function()
                                squareFrame:Destroy()
                                squareObj.Remove(self)
                                return squareObj:Remove()
                            end
                        end
                        return squareObj[index]
                    end,
                    __tostring = function() return 'CustomLib' end
                })
            elseif ClassType == 'Text' then
                local textObj = ({
                    Text = '',
                    Font = Enum.Font.SourceSansBold,
                    Size = 0,
                    Position = Vector2.zero,
                    Center = false,
                    Outline = false,
                    OutlineColor = Color3.new()
                } + LibraryMeta)
    
                local textLabel, uiStroke = Instance.new('TextLabel'), Instance.new('UIStroke')
                textLabel.Name = CustomLibIndex
                textLabel.AnchorPoint = (Vector2.one * .5)
                textLabel.BorderSizePixel = 0
                textLabel.BackgroundTransparency = 1
                textLabel.RichText = true
                textLabel.Visible = textObj.Visible
                textLabel.TextColor3 = textObj.Color
                textLabel.TextTransparency = ClampTransparency(textObj.Transparency)
                textLabel.ZIndex = textObj.ZIndex
    
                textLabel.Font = Enum.Font.SourceSansBold
                textLabel.TextSize = textObj.Size
    
                textLabel:GetPropertyChangedSignal('TextBounds'):Connect(function()
                    local textBounds = textLabel.TextBounds
                    local offset = textBounds / 2
    
                    local offsetX
                    if not textObj.Center then
                        offsetX = offset.X
                    else
                        offsetX = 0
                    end
    
                    textLabel.Position = UDim2.fromOffset(textObj.Position.X + offsetX, textObj.Position.Y + offset.Y)
                end)
    
                uiStroke.Thickness = 1
                uiStroke.Enabled = textObj.Outline
                uiStroke.Color = textObj.Color
    
                textLabel.Parent, uiStroke.Parent = UtilityUI, textLabel
                return setmetatable(table.create(0), {
                    __newindex = function(_, index, value)
                        if typeof(textObj[index]) == 'nil' then return end
    
                        if index == 'Text' then
                            textLabel.Text = value
                        elseif index == 'Font' then
                            value = Clamp(value, 0, 3)
                        elseif index == 'Size' then
                            textLabel.TextSize = value
                        elseif index == 'Position' then
                            local offset = textLabel.TextBounds / 2
    
                            local offsetX
                            if not textObj.Center then
                                offsetX = offset.X
                            else
                                offsetX = 0
                            end
    
                            textLabel.Position = UDim2.fromOffset(textObj.Position.X + offsetX, textObj.Position.Y + offset.Y)
                        elseif index == 'Center' then
                            local position
                            if value then
                                position = game:FindFirstChild("Workspace").CurrentCamera.ViewportSize / 2
                            else
                                position = textObj.Position
                            end
                            textLabel.Position = UDim2.fromOffset(position.X, position.Y)
                        elseif index == 'Outline' then
                            uiStroke.Enabled = value
                        elseif index == 'OutlineColor' then
                            uiStroke.Color = value
                        elseif index == 'Visible' then
                            textLabel.Visible = value
                        elseif index == 'ZIndex' then
                            textLabel.ZIndex = value
                        elseif index == 'Transparency' then
                            local transparency = ClampTransparency(value)
    
                            textLabel.TextTransparency = transparency
                            uiStroke.Transparency = transparency
                        elseif index == 'Color' then
                            textLabel.TextColor3 = value
                        end
                        textObj[index] = value
                    end,
                    __index = function(self, index)
                        if index == 'Remove' or index == 'Destroy' then
                            return function()
                                textLabel:Destroy()
                                textObj.Remove(self)
                                return textObj:Remove()
                            end
                        elseif index == 'TextBounds' then
                            return textLabel.TextBounds
                        end
                        return textObj[index]
                    end,
                    __tostring = function() return 'CustomLib' end
                })
            end
        end
    end
    do
        SetRegion("Game")
        function Script:RayCast(Part, Origin, Ignore, Distance)
            Ignore = Ignore or {}
            Distance = Distance or 2000
            local Direction = (Part.Position - Origin).Unit * Distance
            local Cast = Ray.new(Origin, Direction)
            local Hit = Workspace:FindPartOnRayWithIgnoreList(Cast, Ignore)
            return Hit and Hit:IsDescendantOf(Part.Parent), Hit
        end
        
        function Script:ValidateClient(Player)
            local Object = Player.Character
            local Humanoid = (Object and Object:FindFirstChild("Humanoid")) or false
            local RootPart = (Humanoid and Humanoid.RootPart) or false
            return Object, Humanoid, RootPart
        end
    
        function Script:GetOrigin(Origin)
            local Object, Humanoid, RootPart = Script:ValidateClient(Self)
            if Origin == 'Head' then
                local Head = Object:FindFirstChild('Head')
                if Head and Head:IsA('RootPart') then
                    return Head.CFrame.Position
                end
            elseif Origin == 'Torso' and RootPart then
                return RootPart.CFrame.Position
            end
            return Workspace.CurrentCamera.CFrame.Position
        end
    
        function Script:CalculateAngle(v1, v2)
            local dotProduct = v1:Dot(v2)
            local magnitude1 = v1.Magnitude
            local magnitude2 = v2.Magnitude
            local cosTheta = dotProduct / (magnitude1 * magnitude2)
            return math.acos(cosTheta) * (180 / math.pi) 
        end
        
        function Script:GetClosestPlayerToCursor(Max, FOV)
            local CurrentCamera = game:FindFirstChild("Workspace").CurrentCamera
            local MousePosition = UserInputService:GetMouseLocation()
            local Closest
            local Distance = Max or math.huge
            FOV = FOV or math.huge
    
            for _, Player in ipairs(Players:GetPlayers()) do
                if (Player == Self) then
                    continue
                end
        
                local Character = Player.Character
    
                if Player and Player.Character then
                    
                    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                    if (not HumanoidRootPart) then
                        continue
                    end
    
                    local Position, OnScreen = CurrentCamera:WorldToViewportPoint(HumanoidRootPart.Position)
    
                    if not OnScreen then
                        continue
                    end
                    
                    if shared.Saved['C​o​n​d​i​t​i​o​n​s']['P​l​a​y​e​r​ ​P​r​o​t​e​c​t​e​d'] and Character:FindFirstChild("Forcefield") then
                        continue
                    end
    
                    if shared.Saved['C​o​n​d​i​t​i​o​n​s']['P​l​a​y​e​r​ ​M​o​v​i​n​g'] then
                        local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
                        if Humanoid and Humanoid.MoveDirection.Magnitude < 0.001 then
                            continue
                        end
                    end
    
                    if shared.Saved['C​o​n​d​i​t​i​o​n​s']['P​l​a​y​e​r​ ​V​i​s​i​b​l​e'] then
                        if not Script:RayCast(Character.HumanoidRootPart, Script:GetOrigin('Camera'), {Self.Character, TriggerPart, SilentAimPart}) then
                            continue
                        end
                    end
    
                    if shared.Saved['C​o​n​d​i​t​i​o​n​s']['P​l​a​y​e​r​ ​K​n​o​c​k​e​d'] and Player.Character and CurrentGame.Functions.IsKnocked(Player.Character) then
                        continue
                    end
    
                    if shared.Saved['C​o​n​d​i​t​i​o​n​s']['S​e​l​f​ ​K​n​o​c​k​e​d'] and CurrentGame.Functions.IsKnocked(Self.Character) then
                        continue
                    end
    
                    if shared.Saved['C​o​n​d​i​t​i​o​n​s']['P​l​a​y​e​r​ ​K​n​o​c​k​e​d'] and CurrentGame.Functions.IsGrabbed(Player) then
                        continue
                    end
    
    
                    local Magnitude = (Vector2.new(Position.X, Position.Y) - MousePosition).Magnitude
                    if (Magnitude < Distance and Magnitude < FOV) then
                        Closest = Player
                        Distance = Magnitude
                    end
                end
            end
            return Closest
        end
    end
    do
        SetRegion("Gun System")
        function Modules.DaHood()
            if string.find(GameName, "Da Hood") then
                local IsClient = RunService:IsClient()
                local PlaceIDCheck = game.PlaceId == 88976059384565
                local function CanShoot(Character)
                    if Character then
                        local Humanoid = Character:FindFirstChild("Humanoid")
                        if Humanoid and (Humanoid.Health > 0 and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead) then
                            local BodyEffects = Character:FindFirstChild("BodyEffects")
                            if BodyEffects then
                                local Tool = Character:FindFirstChildWhichIsA("Tool")
                                if Tool and (Tool:FindFirstChild("Handle") and Tool:FindFirstChild("Ammo")) then
                                    if not PlaceIDCheck and IsClient then
                                        if BodyEffects:FindFirstChild("Block") then
                                            shared.playerShot(Tool.Handle)
                                            Tool.Handle.NoAmmo:Play()
                                            return
                                        end
                                        if Tool.Ammo.Value == 0 then
                                            Tool.Handle.NoAmmo:Play()
                                            return
                                        end
                                    end
                                    if Character:FindFirstChild("FULLY_LOADED_CHAR") == nil then
                                        return
                                    elseif Character:FindFirstChild("FORCEFIELD") then
                                        return
                                    elseif Character:FindFirstChild("GRABBING_CONSTRAINT") then
                                        return
                                    elseif Character:FindFirstChild("Christmas_Sock") then
                                        return
                                    elseif BodyEffects.Cuff.Value == true then
                                        return
                                    elseif BodyEffects.Attacking.Value == true then
                                        return
                                    elseif BodyEffects["K.O"].Value == true then
                                        return
                                    elseif BodyEffects.Grabbed.Value then
                                        return
                                    elseif BodyEffects.Reload.Value == true then
                                        return
                                    elseif BodyEffects.Dead.Value == true then
                                        return
                                    elseif not Tool:GetAttribute("Cooldown") then
                                        local LastShot = Character:GetAttribute("LastGunShot")
                                        Character:SetAttribute("LastGunShot", Tool.Name)
                                        if not IsClient or (LastShot == Tool.Name or not Character:GetAttribute("ShotgunDebounce")) then
                                            if not IsClient and (not Character:GetAttribute("ShotgunDebounce") and (Tool.Name == "[Shotgun]" or (Tool.Name == "[Double-Barrel SG]" or (Tool.Name == "TacticalShotgun" or Tool.Name == "Drum-Shotgun")))) then
                                                
                                                Character:SetAttribute("ShotgunDebounce", true)
                                                task.delay(0.65, function()
                                                    Character:SetAttribute("ShotgunDebounce", nil)
                                                end)
                                                
                                                --Character:SetAttribute("ShotgunDebounce", nil)
                                            end
                                            return true
                                        end
                                    end
                                else
                                    return
                                end
                            else
                                return
                            end
                        else
                            return
                        end
                    else
                        return
                    end
                end
        
        
                local function ColorTransform(p14, p15)
                    if p15 == 0 then
                        return p14.Keypoints[1].Value
                    end
                    if p15 == 1 then
                        return p14.Keypoints[#p14.Keypoints].Value
                    end
                    for v16 = 1, #p14.Keypoints - 1 do
                        local v17 = p14.Keypoints[v16]
                        local v18 = p14.Keypoints[v16 + 1]
                        if v17.Time <= p15 and p15 < v18.Time then
                            local v19 = (p15 - v17.Time) / (v18.Time - v17.Time)
                            return Color3.new((v18.Value.R - v17.Value.R) * v19 + v17.Value.R, (v18.Value.G - v17.Value.G) * v19 + v17.Value.G, (v18.Value.B - v17.Value.B) * v19 + v17.Value.B)
                        end
                    end
                end
        
                local weaponNames = {
                    "[Shotgun]",
                    "[Drum-Shotgun]",
                    "[Rifle]",
                    "[TacticalShotgun]",
                    "[AR]",
                    "[AUG]",
                    "[AK47]",
                    "[LMG]",
                    "[SilencerAR]",
                }
                
                local replicatedStorage = game:GetService("ReplicatedStorage")
                local playersService = game:GetService("Players")
                local localPlayer = playersService.LocalPlayer
                local playerCharacter = Self.Character or Self.CharacterAdded:Wait()
                local shootAnimation = playerCharacter.Humanoid.Animator:LoadAnimation(
                    replicatedStorage:WaitForChild("Animations"):WaitForChild("GunCombat"):WaitForChild("Shoot")
                )
                local aimShootAnimation = playerCharacter.Humanoid.Animator:LoadAnimation(
                    replicatedStorage:WaitForChild("Animations"):WaitForChild("GunCombat"):WaitForChild("AimShoot")
                )
                
                local v_u_14 = {}
        
                local function changefunc()
                    local v_u_38 = {
                        ["functions"] = {},
                    }
        
                    function v_u_38.connect(_, p36)
                        local v37 = v_u_38.functions
                        table.insert(v37, p36)
                    end
                    local v_u_39 = nil
                    function v_u_38.updatechanges(_, p_u_40)
                        -- upvalues: (copy) v_u_38, (ref) v_u_39
                        for _, v_u_41 in pairs(v_u_38.functions) do
                            spawn(function()
                                -- upvalues: (copy) v_u_41, (copy) p_u_40, (ref) v_u_39
                                v_u_41(p_u_40.Press, p_u_40.Time, v_u_39)
                            end)
                        end
                        v_u_39 = p_u_40.Time
                    end
                    return v_u_38
                end
        
        
                setmetatable(v_u_14, {
                    ["__index"] = function(_, p42)
                        -- upvalues: (copy) v_u_14
                        local v43 = v_u_14
                        if getmetatable(v43)[p42] == nil then
                            v_u_14[p42] = {}
                        end
                        local v44 = v_u_14
                        return getmetatable(v44)[p42]
                    end,
                    ["__newindex"] = function(_, p45, p46)
                        -- upvalues: (copy) v_u_14
                        local v47 = v_u_14
                        if getmetatable(v47)[p45] == nil then
                            local v48 = v_u_14
                            getmetatable(v48)[p45] = {
                                ["val"] = p46,
                                ["changed"] = changefunc()
                            }
                        else
                            local v49 = v_u_14
                            getmetatable(v49)[p45].val = p46
                            local v50 = v_u_14
                            getmetatable(v50)[p45].changed:updatechanges(p46)
                        end
                    end
                })
        
                UserInputService.InputBegan:connect(function(p51, p52)
                    if not p52 or p51.UserInputType == Enum.UserInputType.Keyboard and p51.KeyCode == Enum.KeyCode.LeftShift or p51.UserInputType == Enum.UserInputType.Gamepad1 and p51.KeyCode == Enum.KeyCode.ButtonL2 then
                        if p51.UserInputType == Enum.UserInputType.Keyboard or p51.UserInputType == Enum.UserInputType.Gamepad1 then
                            v_u_14[p51.KeyCode.Name] = {
                                ["Press"] = true,
                                ["Time"] = tick()
                            }
                            return
                        end
                        if p51.UserInputType == Enum.UserInputType.MouseButton2 then
                            v_u_14[Enum.UserInputType.MouseButton2.Name] = {
                                ["Press"] = true,
                                ["Time"] = tick()
                            }
                        end
                    end
                end)
                UserInputService.InputEnded:connect(function(p53, p54)
                    if not p54 or p53.UserInputType == Enum.UserInputType.Keyboard and p53.KeyCode == Enum.KeyCode.LeftShift or p53.UserInputType == Enum.UserInputType.Gamepad1 and p53.KeyCode == Enum.KeyCode.ButtonL2 then
                        if p53.UserInputType == Enum.UserInputType.Keyboard or p53.UserInputType == Enum.UserInputType.Gamepad1 then
                            v_u_14[p53.KeyCode.Name] = {
                                ["Press"] = false,
                                ["Time"] = tick()
                            }
                            return
                        end
                        if p53.UserInputType == Enum.UserInputType.MouseButton2 then
                            v_u_14[Enum.UserInputType.MouseButton2.Name] = {
                                ["Press"] = false,
                                ["Time"] = tick()
                            }
                        end
                    end
                end)
        
        
        
                local v_u_70 = true
                v_u_14.MouseButton2.changed:connect(function(p71, _, _)
                    -- upvalues: (ref) v_u_70, (ref) v_u_20
                    if v_u_70 ~= false then
                        Script.Locals.IsAimed = p71
                        if Script.Locals.IsAimed == false then
                            v_u_70 = false
                            wait(0.1)
                            v_u_70 = true
                        end
                    end
                end)
        
                local function Animate(target)
                    playerCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()
                
                    if playerCharacter and playerCharacter:FindFirstChild("Humanoid") and playerCharacter.Humanoid:FindFirstChild("Animator") then
                        shootAnimation = playerCharacter.Humanoid.Animator:LoadAnimation(replicatedStorage.Animations.GunCombat.Shoot)
                        aimShootAnimation = playerCharacter.Humanoid.Animator:LoadAnimation(replicatedStorage.Animations.GunCombat.AimShoot)
                
                        if Script.Locals.IsAimed or table.find(weaponNames, target.Parent.Name) then
                            aimShootAnimation:Play()
                        else
                            shootAnimation:Play()
                        end
                    end
                end
                
        
            
                shared.playerShot = Animate
                local v3 = game:GetService("Players")
                local v_u_5 = game:GetService("TweenService")
                local v_u_7 = v3.LocalPlayer
                local v_u_9 = ReplicatedStorage.SkinAssets
                local v_u_13 = game:FindFirstChild("Workspace"):GetServerTimeNow()
                local _ = game.PlaceId == 88976059384565
                local SoundsPlaying = {}
        
                
                local function GetAim(Position)
            
                    if _G.MobileShiftLock then
                        return (Camera.CFrame.p + Camera.CFrame.LookVector * 60 - Position).unit
                    end
                    local v24
                    if Mouse.Target then
                        v24 = Mouse.Hit.p
                    else
                        local v25 = Camera.CFrame
                        local v26 = v25.p + v25.LookVector * 60
                        local v27 = v25.LookVector
                        local v28 = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
                        local v29 = v28.Direction
                        local v30 = v28.Origin
                        v24 = v30 + v29 * ((v26 - v30):Dot(v27) / v29:Dot(v27))
                    end
                    return (v24 - Position).Unit, (v24 - Position).Magnitude
                end
                
                local function ShootGun(p34)
                
                    local v35 = p34.Shooter
                    local v_u_36 = p34.Handle
                    local v37 = p34.AimPosition
                    local v38 = p34.BeamColor
                    local v39 = p34.isReflecting
                    local v40 = p34.Hit
                    local v41 = p34.Range or 200
                    local LegitPosition = p34.LegitPosition
                    local v_u_42
                    if v_u_36 then
                        v_u_42 = v_u_36:GetAttribute("SkinName")
                    else
                        v_u_42 = v_u_36
                    end
                    local _, v43 = GetAim(v_u_36.Position)
                    local v_u_44 = p34.ForcedOrigin or v_u_36.Muzzle.WorldPosition
                    local v45 = (v37 - v_u_44).Unit
                    local v46 = RaycastParams.new()
                    local v47 = {}
                    local function set_list(targetTable, index, values)
                        for i, v in ipairs(values) do
                            targetTable[index + i - 1] = v
                        end
                    end
                    
                    local v48 = { game:FindFirstChild("Workspace"):WaitForChild("Bush"), game:FindFirstChild("Workspace"):WaitForChild("Ignored"), TriggerPart, SilentAimPart }
                    set_list(v47, 1, {v35, unpack(v48)})
                    
                    v46.FilterDescendantsInstances = v47
                    v46.FilterType = Enum.RaycastFilterType.Exclude
                    v46.IgnoreWater = true
                    local v_u_49, v_u_50, v_u_51
                    if v40 then
                        v_u_49 = p34.Hit
                        v_u_50 = p34.AimPosition
                        v_u_51 = p34.Normal
                    else
                        local v52 = game:FindFirstChild("Workspace"):Raycast(v_u_44, v45 * v41, v46)
                        if v52 then
                            v_u_49 = v52.Instance
                            v_u_50 = v52.Position
                            v_u_51 = v52.Normal
                        else
                            v_u_50 = v_u_44 + v45 * math.min(v43, v41)
                            v_u_51 = nil
                            v_u_49 = nil
                        end
                    end
                    
                    
                    local v_u_53 = Instance.new("Part")
                    v_u_53:SetAttribute("OwnerCharacter", v35.Name)
                    v_u_53.Name = "BULLET_RAYS"
                    v_u_53.Anchored = true
                    v_u_53.CanCollide = false
                    v_u_53.Size = Vector3.new(0, 0, 0)
                    v_u_53.Transparency = 1
                    game.Debris:AddItem(v_u_53, 1)
                    local Tool = Self.Character:FindFirstChildWhichIsA("Tool")
                    if shared.Saved['S​i​l​e​n​t​ ​A​i​m']['C​l​i​e​n​t​ ​R​e​d​i​r​e​c​t​i​o​n']['E​n​a​b​l​e​d'] then
                        v_u_53.CFrame = CFrame.new(v_u_44, LegitPosition)
                    else
                        v_u_53.CFrame = CFrame.new(v_u_44, v_u_50)
                    end
                    v_u_53.Material = Enum.Material.SmoothPlastic
                    v_u_53.Parent = game:FindFirstChild("Workspace").Ignored.Siren.Radius
                    local v54 = Instance.new("Attachment")
                    v54.Position = Vector3.new(0, 0, 0)
                    v54.Parent = v_u_53
                    local v55 = Instance.new("Attachment")
                    local v56 = -(v_u_50 - v_u_44).magnitude
                    v55.Position = Vector3.new(0, 0, v56)
                    v55.Parent = v_u_53
                    local v_u_57 = false
                    local v_u_58 = nil
                    local v59
                    if v_u_36 then
                        local v60 = v_u_36.Parent.Name
                        if v_u_42 and v_u_42 ~= "" then
                            if v_u_9.GunSkinMuzzleParticle:FindFirstChild(v_u_42) then
                                if not v39 then
                                    if v_u_9.GunSkinMuzzleParticle[v_u_42]:FindFirstChild("Muzzle") then
                                        if v_u_36.Parent:FindFirstChild("Default") and (v_u_36.Parent.Default:FindFirstChild("Mesh") and v_u_36.Parent.Default.Mesh:FindFirstChild("Muzzle")) then
                                            local v61
                                            if v_u_9.GunSkinMuzzleParticle[v_u_42].Muzzle:FindFirstChild("Different_GunMuzzle") then
                                                v61 = v_u_9.GunSkinMuzzleParticle[v_u_42].Muzzle.Different_GunMuzzle[v60]
                                            else
                                                v61 = v_u_9.GunSkinMuzzleParticle[v_u_42].Muzzle
                                            end
                                            for _, v62 in pairs(v61:GetChildren()) do
                                                local v63 = v62:GetAttribute("EmitCount") or 1
                                                local v_u_64 = v62:Clone()
                                                v_u_64.Parent = v_u_36.Parent.Default.Mesh.Muzzle
                                                v_u_64:Emit(v63)
                                                task.delay(v_u_64.Lifetime.Max, function()
                                                    -- upvalues: (copy) v_u_64
                                                    v_u_64:Destroy()
                                                end)
                                            end
                                        end
                                    else
                                        local v65 = v_u_9.GunSkinMuzzleParticle[v_u_42]:GetChildren()
                                        local v66 = v65[math.random(#v65)]:Clone()
                                        v66.Parent = v54
                                        v66:Emit(v66.Rate)
                                    end
                                end
                                v_u_57 = true
                            end
                            if v_u_9.GunBeam:FindFirstChild(v_u_42) then
                                if v_u_9.GunBeam[v_u_42].GunBeam:IsA("BasePart") then
                                    v59 = {
                                        ["Parent"] = nil,
                                        ["Attachment0"] = nil,
                                        ["Attachment1"] = nil
                                    }
                                    if v_u_9.GunBeam[v_u_42].GunBeam:FindFirstChild("Different_GunBeam") then
                                        if v_u_9.GunBeam[v_u_42].GunBeam.Different_GunBeam[v60].GunBeam:IsA("BasePart") then
                                            v_u_58 = v_u_9.GunBeam[v_u_42].GunBeam.Different_GunBeam[v60].GunBeam:Clone()
                                        else
                                            v59 = v_u_9.GunBeam[v_u_42].GunBeam.Different_GunBeam[v60].GunBeam:Clone()
                                        end
                                    else
                                        v_u_58 = v_u_9.GunBeam[v_u_42].GunBeam:Clone()
                                    end
                                else
                                    v59 = v_u_9.GunBeam[v_u_42].GunBeam:Clone()
                                end
                            else
                                v59 = game.ReplicatedStorage.GunBeam:Clone()
                                v59.Color = v38 and ColorSequence.new(v38) or v59.Color
                            end
                        else
                            v59 = game.ReplicatedStorage.GunBeam:Clone()
                            v59.Color = v38 and ColorSequence.new(v38) or v59.Color
                        end
                    else
                        v59 = nil
                    end
                    task.spawn(function()
                        if v_u_58 then
                            local v67 = (v_u_50 - v_u_44).magnitude
                            local v68 = v67 / 725
                            v_u_58.Anchored = true
                            v_u_58.CanCollide = false
                            v_u_58.CanQuery = false
                            v_u_58.CFrame = CFrame.new(v_u_44, v_u_50)
                            local v69 = v_u_58.CFrame * CFrame.new(0, 0, -v67)
                            v_u_58.Parent = game:FindFirstChild("Workspace").Ignored.Siren.Radius
                            task.delay(v68 + 5, function()
                                -- upvalues: (ref) v_u_58
                                v_u_58:Destroy()
                                v_u_58 = nil
                            end)
                            if v_u_58:GetAttribute("SpecialEffects") then
                                for _, v70 in pairs(v_u_58:GetDescendants()) do
                                    if v70:IsA("Trail") and v70:GetAttribute("ColorRandom") then
                                        local v71 = v70:GetAttribute("ColorRandom")
                                        v70.Color = ColorSequence.new(ColorTransform(v71, math.random()))
                                    end
                                end
                            end
                            local v72 = game:GetService("TweenService"):Create(v_u_58, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
                                ["CFrame"] = v_u_58.CFrame * CFrame.new(0, 0, -0.1)
                            })
                            v72:Play()
                            task.wait(0.05)
                            if v72.PlaybackState ~= Enum.PlaybackState.Completed then
                                v72:Pause()
                            end
                            local v73 = nil
                            if _G.Reduce_Lag and not v_u_58:GetAttribute("NoSlow") or v_u_58:GetAttribute("LOWGFX") then
                                v_u_58.CFrame = v69
                            else
                                v73 = game:GetService("TweenService"):Create(v_u_58, TweenInfo.new(v68, Enum.EasingStyle.Linear), {
                                    ["CFrame"] = v69
                                })
                                v73:Play()
                                task.wait(v68)
                            end
                            if v_u_58:FindFirstChild("Impact") and (v_u_49 and (v_u_51 and not v_u_49.Parent:FindFirstChild("Humanoid"))) then
                                if v73 and v73.PlaybackState ~= Enum.PlaybackState.Completed then
                                    task.wait(0.05)
                                end
                                if not v_u_58:FindFirstChild("NoNormal") then
                                    v_u_58.CFrame = CFrame.new(v_u_50, v_u_50 - v_u_51)
                                end
                                for _, v74 in pairs(v_u_58.Impact:GetChildren()) do
                                    if v74:IsA("ParticleEmitter") then
                                        v74:Emit(v74:GetAttribute("EmitCount") or 1)
                                    end
                                end
                            else
                                for _, v75 in pairs(v_u_58:GetChildren()) do
                                    if v75:IsA("BasePart") then
                                        v75.Transparency = 1
                                    end
                                end
                            end
                            if v_u_58 then
                                for _, v76 in pairs(v_u_58:GetDescendants()) do
                                    if v76:IsA("ParticleEmitter") then
                                        v76.Enabled = false
                                    end
                                end
                            end
                        elseif v_u_49 and (v_u_49:IsDescendantOf(game:FindFirstChild("Workspace").MAP) and (v_u_42 and (v_u_9.GunBeam:FindFirstChild(v_u_42) and v_u_9.GunBeam[v_u_42]:FindFirstChild("Impact")))) then
                            local v_u_77 = v_u_9.GunBeam[v_u_42].Impact:Clone()
                            v_u_77.Parent = game:FindFirstChild("Workspace").Ignored
                            v_u_77:PivotTo(CFrame.new(v_u_50, v_u_50 + v_u_51 * 5) * CFrame.Angles(-1.5707963267948966, 0, 0))
                            for _, v78 in pairs(v_u_77:GetDescendants()) do
                                if v78:IsA("ParticleEmitter") then
                                    v78:Emit(v78:GetAttribute("EmitCount") or 1)
                                end
                            end
                            task.delay(1.5, function()
                                v_u_77:Destroy()
                                v_u_77 = nil
                            end)
                        end
                        local v79 = Instance.new("PointLight")
                        v79.Brightness = 0.5
                        v79.Range = 15
                        v79.Shadows = true
                        v79.Color = Color3.new(1, 1, 1)
                        v79.Parent = v_u_53
                        local v80 = v_u_36:FindFirstChild("ShootBBGUI")
                        local v81 = v80 and (not v_u_57 and v80:FindFirstChild("Shoot"))
                        if v81 then
                            v81.Size = UDim2.new(0, 0, 0, 0)
                            v81.ImageTransparency = 1
                            v81.Visible = true
                            v_u_5:Create(v81, TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.In, 0, false, 0), {
                                ["Size"] = UDim2.new(1, 0, 1, 0),
                                ["ImageTransparency"] = 0.4
                            }):Play()
                            v_u_5:Create(v79, TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.In, 0, false, 0), {
                                ["Range"] = 0
                            }):Play()
                            wait(0.4)
                            v_u_53:Destroy()
                            v_u_5:Create(v81, TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.In, 0, false, 0), {
                                ["Size"] = UDim2.new(1, 0, 1, 0),
                                ["ImageTransparency"] = 1
                            }):Play()
                            wait(0.2)
                            v81.Visible = false
                        end
                    end)
                    v59.Attachment0 = v54
                    v59.Attachment1 = v55
                    v59.Name = "NewGunBeam"
                    v59.Parent = v_u_53
                    if v35 == v_u_7.Character and game:FindFirstChild("Workspace"):GetServerTimeNow() - v_u_13 > 0.95 then
                        Animate(v_u_36)
                    end
                    local playsound = function(p1, p2)
                        local v3 = p1.ShootSound:GetAttribute("SequenceSFX")
                        if v3 then
                            if p1.ShootSound:GetAttribute("CurrentSequence") == nil then
                                p1.ShootSound:SetAttribute("CurrentSequence", 1)
                            else
                                p1.ShootSound:SetAttribute("CurrentSequence", p1.ShootSound:GetAttribute("CurrentSequence") + 1)
                            end
                            local v4 = p1.ShootSound:GetAttribute("CurrentSequence")
                            local v5 = {}
                            for v6 in string.gmatch(v3, "%d+") do
                                table.insert(v5, v6)
                            end
                            p1.ShootSound.SoundId = "rbxassetid://" .. v5[v4 % #v5 + 1]
                        end
                        if p2 then
                            local v_u_7 = p1.ShootSound:Clone()
                            v_u_7.Name = "MG"
                            v_u_7.Parent = p1
                            v_u_7:Play()
                            delay(1, function()
                                v_u_7:Destroy()
                            end)
                        else
                            p1.ShootSound:Play()
                        end
                    end    
        
                    if not SoundsPlaying[v_u_36] then
                        task.spawn(playsound, v_u_36, true)
                        SoundsPlaying[v_u_36] = true
                        task.delay(0.021, function()
                            SoundsPlaying[v_u_36] = nil
                        end)
                    end
                    if game.Lighting:GetAttribute("printhits") then
                        local v82 = print
                        local v83 = v_u_49
                        if v83 then
                            v83 = v_u_49:GetFullName()
                        end
                        v82(v83)
                    end
                    return v_u_50, v_u_49, v_u_51
                end
                return {
                    CanShoot = CanShoot,
                    Animate = Animate,
                    GetAim = GetAim,
                    ColorTransform = ColorTransform,
                    ShootGun = ShootGun,
                }
            else
                return {}
            end
        end
    end
    do
        SetRegion("Main")
        local DaHood = Modules.Get("DaHood")
        function Script:GetClosestPointOnPart(Part, Scale)
            local PartCFrame = Part.CFrame
            local PartSize = Part.Size
            local PartSizeTransformed = PartSize * (Scale / 2)
    
            local MousePosition = UserInputService:GetMouseLocation()
            local CurrentCamera = Workspace.CurrentCamera
    
            local MouseRay = CurrentCamera:ViewportPointToRay(MousePosition.X, MousePosition.Y)
            local Transformed = PartCFrame:PointToObjectSpace(MouseRay.Origin + (MouseRay.Direction * MouseRay.Direction:Dot(PartCFrame.Position - MouseRay.Origin)))
    
    
            
            if (Mouse.Target == Part) then
                return Vector3.new(Mouse.Hit.X, Mouse.Hit.Y, Mouse.Hit.Z)
            end
    
            return PartCFrame * Vector3.new(
                math.clamp(Transformed.X, -PartSizeTransformed.X, PartSizeTransformed.X),
                math.clamp(Transformed.Y, -PartSizeTransformed.Y, PartSizeTransformed.Y),
                math.clamp(Transformed.Z, -PartSizeTransformed.Z, PartSizeTransformed.Z)
            )
        end
    
        function Script:GetClosestPointOnPartBasic(Part)
            if Part then
                local MouseRay = Mouse.UnitRay
                MouseRay = MouseRay.Origin + (MouseRay.Direction * (Part.Position - MouseRay.Origin).Magnitude)
                local Point = (MouseRay.Y >= (Part.Position - Part.Size / 2).Y and MouseRay.Y <= (Part.Position + Part.Size / 2).Y) and (Part.Position + Vector3.new(0, -Part.Position.Y + MouseRay.Y, 0)) or Part.Position
                local Check = RaycastParams.new()
                Check.FilterType = Enum.RaycastFilterType.Whitelist
                Check.FilterDescendantsInstances = {Part}
                local Ray = Workspace:Raycast(MouseRay, (Point - MouseRay), Check)
    
                if Mouse.Target == Part then
                    return Mouse.Hit.Position
                end
    
                if Ray then
                    return Ray.Position
                else
                    return Mouse.Hit.Position
                end
            end 
        end
    
        function Script:GetClosestPartToCursor(Character)
            local CurrentCamera = Workspace.CurrentCamera
            local Closest
            local Distance = 1/0
            for _, Part in ipairs(Character:GetChildren()) do
                if (not Part:IsA("BasePart")) then
                    continue
                end
    
                local Position = CurrentCamera:WorldToViewportPoint(Part.Position)
                Position = Vector2.new(Position.X, Position.Y)
                local Magnitude = (UserInputService:GetMouseLocation() - Position).Magnitude
    
                if (Magnitude < Distance) then
                    Closest = Part
                    Distance = Magnitude
                end
            end
    
            return Closest
        end
        
        function Script:GetClosestPartToCursorFilter(Character, PartsToCheck)
            local CurrentCamera = Workspace.CurrentCamera
            local Closest
            local Distance = 1/0
            
            for _, Part in ipairs(Character:GetChildren()) do
                if not Part:IsA("BasePart") or (PartsToCheck and not table.find(PartsToCheck, Part.Name)) then
                    continue
                end
        
                local Position = CurrentCamera:WorldToViewportPoint(Part.Position)
                Position = Vector2.new(Position.X, Position.Y)
                local Magnitude = (UserInputService:GetMouseLocation() - Position).Magnitude
        
                if Magnitude < Distance then
                    Closest = Part
                    Distance = Magnitude
                end
            end
        
            return Closest
        end
    
        function Script:ApplyNormalPredictionFormula(Humanoid, Position, Velocity)
            local IsInAir = Humanoid:GetState() == Enum.HumanoidStateType.Freefall or Humanoid:GetState() == Enum.HumanoidStateType.Jumping
            local TargetVelocity = Velocity                         --//TargetVelocity.Y
            local PredictionVelocity = Vector3.new(TargetVelocity.X, shared.Saved['S​i​l​e​n​t​ ​A​i​m']['YAxis'] and TargetVelocity.Y or 0, TargetVelocity.Z) * Vector3.new(shared.Saved['S​i​l​e​n​t​ ​A​i​m']['P​r​e​d​i​c​t​i​o​n']['X'], shared.Saved['S​i​l​e​n​t​ ​A​i​m']['P​r​e​d​i​c​t​i​o​n']['Y'], shared.Saved['S​i​l​e​n​t​ ​A​i​m']['P​r​e​d​i​c​t​i​o​n']['Z'])
            local Gravity = Workspace.Gravity
            if IsInAir and shared.Saved['S​i​l​e​n​t​ ​A​i​m']['YStabilizer'] > 0 then
                local TimeToHit = 2 * PredictionVelocity.Y / Gravity
                local GravityAdjustment = Vector3.new(0, -0.5 * Gravity * TimeToHit * TimeToHit, 0)
                PredictionVelocity = PredictionVelocity + GravityAdjustment
            
                local YOffset = Vector3.new(0, shared.Saved['S​i​l​e​n​t​ ​A​i​m']['YStabilizer'], 0) 
                PredictionVelocity = PredictionVelocity + YOffset
            end
            local ClosestPoint = Position
            local PredictedCFrame = ClosestPoint + PredictionVelocity
            
            return Vector3.new(PredictedCFrame.X, PredictedCFrame.Y, PredictedCFrame.Z)
        end
        
    
        function Script:ApplyRecalculatedPredictionFormula(RootPart, Position)
            local PredictionVelocity = Script:GetResolvedVelocity(RootPart) * Vector3.new(shared.Saved['S​i​l​e​n​t​ ​A​i​m']['P​r​e​d​i​c​t​i​o​n']['X'], shared.Saved['S​i​l​e​n​t​ ​A​i​m']['P​r​e​d​i​c​t​i​o​n']['Y'], shared.Saved['S​i​l​e​n​t​ ​A​i​m']['P​r​e​d​i​c​t​i​o​n']['Z'])
            local PredictedCFrame = Position + PredictionVelocity
            return PredictedCFrame
        end    
    
        function Script:GetResolvedVelocity(Part)
            local LastPosition = Part.Position
            task.wait(0.085)
            local CurrentPosition = Part.Position
            local Velocity = (CurrentPosition - LastPosition) / 0.085
            return Velocity --[[* Vector3.new(1, 0, 1)]]
        end
    
        local smoothedVelocity = Vector3.new(0, 0, 0)  
        
        local function getDynamicSmoothingFactor(velocityMagnitude)
            if velocityMagnitude < 5 then
                return 0.05  
            elseif velocityMagnitude < 20 then
                return 0.1  -- Medium speeds
            else
                return 0.2 
            end
        end
        
        local function GetResolvedVelocity(Part)
            local LastPosition = Part.Position
            task.wait(0.085)
            local CurrentPosition = Part.Position
            local Velocity = (CurrentPosition - LastPosition) / 0.085
        
            local velocityMagnitude = Velocity.Magnitude
            local dynamicSmoothing = getDynamicSmoothingFactor(velocityMagnitude)
        
        
            smoothedVelocity = smoothedVelocity * (1 - dynamicSmoothing) + Velocity * dynamicSmoothing
        
        
            return smoothedVelocity * Vector3.new(1, 0, 1)
        end
        
        function Script:GetHitPosition(Mode)
            if Mode == 'Assist' then
                local Config = shared.Saved['A​i​m​ ​B​o​t']
                local Object = Script.Locals.AimAssistTarget.Character
                if not Object then return end  
            
                local Humanoid = Object:FindFirstChild("Humanoid")
                if not Humanoid then return end 
            
                local NearestPart = Script:GetClosestPartToCursor(Object)
                local HitPosition
            
                if Config['H​i​t​ ​P​a​r​t'] == 'Closest Point' then
                    local NearestPoint
                    if Config['C​l​o​s​e​s​t​ ​P​o​i​n​t']['M​o​d​e'] == 'Advanced' then
                        NearestPoint = Script:GetClosestPointOnPart(NearestPart, Config['C​l​o​s​e​s​t​ ​P​o​i​n​t']['S​c​a​l​e'])
                    else
                        NearestPoint = Script:GetClosestPointOnPartBasic(NearestPart)
                    end
                    HitPosition = NearestPoint
            
                elseif Config['H​i​t​ ​P​a​r​t'] == 'Closest Part' then
                    HitPosition = NearestPart.Position
            
                elseif typeof(Config['H​i​t​ ​P​a​r​t']) == 'table' then
                    HitPosition = Script:GetClosestPartToCursorFilter(Object, Config['H​i​t​ ​P​a​r​t']).Position
            
                else
                    HitPosition = Object[Config['H​i​t​ ​P​a​r​t']].Position
                end
            
                if Config['P​r​e​d​i​c​t​i​o​n']['E​n​a​b​l​e​d'] then
                    local BasePrediction = Vector3.new(Config['P​r​e​d​i​c​t​i​o​n']['X'], Config['P​r​e​d​i​c​t​i​o​n']['Y'], Config['P​r​e​d​i​c​t​i​o​n']['Z'])
                    local Prediction = HitPosition + Script:GetResolvedVelocity(Object.HumanoidRootPart) * BasePrediction
            
                    return Prediction
                else
                    return HitPosition
                end
            end
            
            if Mode == 'Silent' then 
                local Config = shared.Saved['S​i​l​e​n​t​ ​A​i​m']
                local Object = Script.Locals.SilentAimTarget.Character
                if not Object then return end  
                
                local Humanoid = Object:FindFirstChild("Humanoid")
                if not Humanoid then return end 
                
                local NearestPart = Script:GetClosestPartToCursor(Object)
                local HitPosition
                
                local HitPart = Config['H​i​t​ ​P​a​r​t']
                if Config['H​i​t​ ​P​a​r​t Override']['E​n​a​b​l​e​d'] and Script.Locals.IsOverriding then
                    HitPart = Config['H​i​t​ ​P​a​r​t Override'][1] 
                end
                
                if HitPart == 'Closest Point' then
                    local NearestPoint
                    if Config['C​l​o​s​e​s​t​ ​P​o​i​n​t']['M​o​d​e'] == 'Advanced' then
                        NearestPoint = Script:GetClosestPointOnPart(NearestPart, Config['C​l​o​s​e​s​t​ ​P​o​i​n​t']['S​c​a​l​e'])
                    else
                        NearestPoint = Script:GetClosestPointOnPartBasic(NearestPart)
                    end
                    HitPosition = NearestPoint
                
                elseif HitPart == 'Closest Part' then
                    HitPosition = NearestPart.Position
                
                elseif typeof(HitPart) == 'table' then
                    HitPosition = Script:GetClosestPartToCursorFilter(Object, HitPart).Position
                
                else
                    HitPosition = Object[HitPart].Position
                end
                
                if Config['P​r​e​d​i​c​t​i​o​n']['E​n​a​b​l​e​d'] then
                    if Config['P​r​e​d​i​c​t​i​o​n']['M​o​d​e'] == 'HitScan' then
                        local RootPart = Object.HumanoidRootPart
                        local Velocity = RootPart.Velocity
                        
                        if Humanoid.FloorMaterial == Enum.Material.Air and Velocity_Data.State == Enum.HumanoidStateType.Jumping then
                            return HitPosition + GetResolvedVelocity(RootPart) * Vector3.new(Config['P​r​e​d​i​c​t​i​o​n']['X'], Config['P​r​e​d​i​c​t​i​o​n']['Y'] --[[Velocity_Data.Y]], Config['P​r​e​d​i​c​t​i​o​n']['X'])
                        else
                            return HitPosition + GetResolvedVelocity(RootPart) * Vector3.new(Config['P​r​e​d​i​c​t​i​o​n']['X'], Config['P​r​e​d​i​c​t​i​o​n']['Y'], Config['P​r​e​d​i​c​t​i​o​n']['X'])
                        end
                    else
                        return Script:ApplyNormalPredictionFormula(Humanoid, HitPosition, Object.HumanoidRootPart.Velocity)
                    end
                else
                    return HitPosition
                end
            end            
        end    
    
        function Script:UpdateBox()
            if Script.Locals.SilentAimTarget and Script.Locals.SilentAimTarget.Character then
                local Object, Humanoid, RootPart = Script:ValidateClient(Script.Locals.SilentAimTarget)
                if (Object and Humanoid and RootPart) then		
                    local Pos
                    Pos = RootPart.Position
                    local Position, Visible = Camera:WorldToViewportPoint(Pos)
                    local Size = RootPart.Size.Y
                    local scaleFactor = (Size * Camera.ViewportSize.Y) / (Position.Z * 2) * 80 / game:FindFirstChild("Workspace").CurrentCamera.FieldOfView
                    local w, h = CurrentFOVX * scaleFactor, CurrentFOVY * scaleFactor
                    
                    Script.Locals.FieldOfViewOne.Position = Vector2.new(Position.X - w / 2, Position.Y - h / 2)
                    Script.Locals.FieldOfViewOne.Size = Vector2.new(w, h)
                    Script.Locals.FieldOfViewOne.Visible = (Visible and shared.Saved['S​i​l​e​n​t​ ​A​i​m']['F​O​V']['T​y​p​e'] == 'Box' and shared.Saved['S​i​l​e​n​t​ ​A​i​m']['F​O​V']['V​i​s​i​b​l​e']) or false
    
                    local mouseLocation = UserInputService:GetMouseLocation()
                    local boxPos = Script.Locals.FieldOfViewOne.Position
                    local boxSize = Script.Locals.FieldOfViewOne.Size
                
                    if mouseLocation.X >= boxPos.X and mouseLocation.X <= boxPos.X + boxSize.X and
                        mouseLocation.Y >= boxPos.Y and mouseLocation.Y <= boxPos.Y + boxSize.Y then
                        Script.Locals.IsBoxFocused = true
                        Script.Locals.FieldOfViewOne.Color = Color3.fromRGB(255, 0, 0)
                        else
                            Script.Locals.IsBoxFocused = false
                        Script.Locals.FieldOfViewOne.Color =Color3.fromRGB(255, 255, 255)
                    end
                else
                    Script.Locals.FieldOfViewOne.Visible = false
                end
            else
                Script.Locals.FieldOfViewOne.Visible = false
            end
        end
    
        function Script:UpdateLabels()
            if shared.Saved['G​e​n​e​r​a​l​']['S​h​o​w​ ​H​o​t​k​e​y​s'] then
                if LabelOne == nil then
                    LabelOne = Script.Visuals.new("Text")
                end
        
                if LabelTwo == nil then
                    LabelTwo = Script.Visuals.new("Text")
                end
    
                if LabelThree == nil then
                    LabelThree = Script.Visuals.new("Text")
                end
    
                if LabelFour == nil then
                    LabelFour = Script.Visuals.new("Text")
                end
        
                if LabelFive == nil then
                    LabelFive = Script.Visuals.new("Text")
                end
        
                local viewportSize = Camera.ViewportSize
                local offsetY = 50 
                if shared.Saved['S​i​l​e​n​t​ ​A​i​m']['E​n​a​b​l​e​d'] and IsSilentAiming then
                    LabelOne.Color = Color3.fromRGB(143, 174, 211)
                    LabelOne.Outline = true
                    LabelOne.Size = 13
                    LabelOne.Center = true
                    LabelOne.Visible = true
                
                    if Script.Locals.SilentAimTarget then
                        LabelOne.Text = '<font color="rgb(143, 174, 211)">S​i​l​e​n​t​ ​A​i​m</font> <font color="rgb(255, 100, 100)">(' 
                                        .. Script.Locals.SilentAimTarget.DisplayName .. ')</font>'
                    else
                        LabelOne.Text = '<font color="rgb(143, 174, 211)">S​i​l​e​n​t​ ​A​i​m</font> <font color="rgb(255, 100, 100)">(N/A)</font>'
                    end
                
                    LabelOne.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2 + offsetY)
                    offsetY = offsetY + 15 
                else
                    LabelOne.Visible = false
                end
        
                if shared.Saved['T​r​i​g​g​e​r​ ​B​o​t']['E​n​a​b​l​e​d'] and Script.Locals.TriggerState then
                    LabelTwo.Color = Color3.fromRGB(143, 174, 211)
                    LabelTwo.Outline = true
                    LabelTwo.Size = 13
                    LabelTwo.Center = true
                    LabelTwo.Visible = true
                
                    if Script.Locals.TriggerbotTarget then
                        LabelTwo.Text = '<font color="rgb(143, 174, 211)">T​r​i​g​g​e​r​ ​B​o​t</font> <font color="rgb(255, 100, 100)">(' 
                                        .. Script.Locals.TriggerbotTarget.DisplayName .. ')</font>'
                    else
                        LabelTwo.Text = '<font color="rgb(143, 174, 211)">T​r​i​g​g​e​r​ ​B​o​t</font> <font color="rgb(255, 100, 100)">(N/A)</font>'
                    end
                
                    LabelTwo.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2 + offsetY)
                    offsetY = offsetY + 15 
                else
                    LabelTwo.Visible = false
                end
    
                if shared.Saved['P​l​a​y​e​r​ ​M​o​d​i​f​i​c​a​t​i​o​n​s']['W​a​l​k​ ​S​p​e​e​d']['E​n​a​b​l​e​d'] and Script.Locals.IsWalkSpeeding then
                    LabelThree.Color = Color3.fromRGB(143, 174, 211)
                    LabelThree.Outline = true
                    LabelThree.Size = 13
                    LabelThree.Center = true
                    LabelThree.Visible = true
                    LabelThree.Text = "WalkSpeed"
        
                    LabelThree.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2 + offsetY)
                    offsetY = offsetY + 15 
                else
                    LabelThree.Visible = false
                end

                if shared.Saved['G​u​n​ ​M​o​d​i​f​i​c​a​t​i​o​n​s']['D​o​u​b​l​e​ ​T​a​p']['E​n​a​b​l​e​d'] and Script.Locals.IsDoubleTapping then
                    LabelFour.Color = Color3.fromRGB(143, 174, 211)
                    LabelFour.Outline = true
                    LabelFour.Size = 13
                    LabelFour.Center = true
                    LabelFour.Visible = true
                    LabelFour.Text = "DoubleTap"
        
                    LabelFour.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2 + offsetY)
                    offsetY = offsetY + 15 
                else
                    LabelFour.Visible = false
                end
    
                if shared.Saved['S​i​l​e​n​t​ ​A​i​m']['H​i​t​ ​P​a​r​t Override']['E​n​a​b​l​e​d'] and Script.Locals.IsOverriding then
                    LabelFive.Color = Color3.fromRGB(143, 174, 211)
                    LabelFive.Outline = true
                    LabelFive.Size = 13
                    LabelFive.Center = true
                    LabelFive.Visible = true
                    LabelFive.Text = "Override"
        
                    LabelFive.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2 + offsetY)
                    offsetY = offsetY + 15 
                else
                    LabelFive.Visible = false
                end
            end
        end
        
        function Script:ShouldShoot(Target)
            if not Target then 
                SilentAimPart.Position = Vector3.zero
                return false 
            end
            if not Target.Character then 
                SilentAimPart.Position = Vector3.zero
                return false 
            end
            
            local allConditionsPassed = true
            
            if not IsSilentAiming then
                allConditionsPassed = false
                SilentAimPart.Position = Vector3.zero
            end
    
            if shared.Saved['C​o​n​d​i​t​i​o​n​s']['P​l​a​y​e​r​ ​P​r​o​t​e​c​t​e​d'] and Target.Character:FindFirstChild("Forcefield") then
                allConditionsPassed = false
                SilentAimPart.Position = Vector3.zero
            end
        
            if shared.Saved['C​o​n​d​i​t​i​o​n​s']['P​l​a​y​e​r​ ​M​o​v​i​n​g'] then
                local Humanoid = Target.Character:FindFirstChildWhichIsA("Humanoid")
                if Humanoid and Humanoid.MoveDirection.Magnitude < 0.001 then
                    allConditionsPassed = false
                    SilentAimPart.Position = Vector3.zero
                end
            end
        
            if shared.Saved['C​o​n​d​i​t​i​o​n​s']['P​l​a​y​e​r​ ​V​i​s​i​b​l​e'] then
                if not Script:RayCast(Target.Character.HumanoidRootPart, Script:GetOrigin('Camera'), {Self.Character, TriggerPart, SilentAimPart}) then
                    allConditionsPassed = false
                    SilentAimPart.Position = Vector3.zero
                end
            end
        
            if shared.Saved['C​o​n​d​i​t​i​o​n​s']['P​l​a​y​e​r​ ​K​n​o​c​k​e​d'] and CurrentGame.Functions.IsKnocked(Target.Character) then
                allConditionsPassed = false
                SilentAimPart.Position = Vector3.zero
            end
        
            if shared.Saved['C​o​n​d​i​t​i​o​n​s']['S​e​l​f​ ​K​n​o​c​k​e​d'] and CurrentGame.Functions.IsKnocked(Self.Character) then
                allConditionsPassed = false
                SilentAimPart.Position = Vector3.zero
            end
        
            if shared.Saved['C​o​n​d​i​t​i​o​n​s']['P​l​a​y​e​r​ ​G​r​a​b​b​e​d'] and CurrentGame.Functions.IsGrabbed(Target) then
                allConditionsPassed = false
                SilentAimPart.Position = Vector3.zero
            end
        
    
    
            local screen, _ = Camera:WorldToViewportPoint(Script.Locals.HitPosition)
    
            local DistanceX = math.abs(screen.X - Mouse.X)
            local DistanceY = math.abs(screen.Y - Mouse.Y)
            local Box = Vector2.new(0, 0)
            local RadiusX 
            local RadiusY 
            if Script.Locals.IsBoxFocused then
                Box = Vector2.new(1000, 1000)
            else
                Box = Vector2.new(0, 0)
            end
    
    
            if shared.Saved['S​i​l​e​n​t​ ​A​i​m']['F​O​V']['T​y​p​e'] == 'Box' then
                RadiusX = Box.X
                RadiusY = Box.Y
            else
                RadiusX = CurrentFOV
                RadiusY = CurrentFOV
            end
            
            if shared.Saved['S​i​l​e​n​t​ ​A​i​m']['F​O​V']['E​n​a​b​l​e​d'] and shared.Saved['S​i​l​e​n​t​ ​A​i​m']['F​O​V']['T​y​p​e'] == 'Box' or shared.Saved['S​i​l​e​n​t​ ​A​i​m']['F​O​V']['T​y​p​e'] == 'Circle' and not (RadiusX > DistanceX and RadiusY > DistanceY and (DistanceX^2 + DistanceY^2) < (1/0)^2) then
                allConditionsPassed = false
            elseif shared.Saved['S​i​l​e​n​t​ ​A​i​m']['F​O​V']['E​n​a​b​l​e​d'] and shared.Saved['S​i​l​e​n​t​ ​A​i​m']['F​O​V']['T​y​p​e'] == '3D' then
                local function Ray(origin, direction, raycastParams)
                    local result = workspace:Raycast(origin, direction, raycastParams)
                
                    if result and result.Instance then
                        if result.Instance ~= SilentAimPart then
                            origin = result.Position + direction.Unit * 0.1
                            return Ray(origin, direction, raycastParams)
                        else
                            return result
                        end
                    end
                    return nil 
                end        
    
                local mouseLocation = UserInputService:GetMouseLocation()
                local ray = Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
                local result = Ray(ray.Origin, ray.Direction * 1000, raycastParams)
    
     
                SilentAimPart.Size = Vector3.new(shared.Saved['S​i​l​e​n​t​ ​A​i​m']['F​O​V']['3D'][1], shared.Saved['S​i​l​e​n​t​ ​A​i​m']['F​O​V']['3D'][2], shared.Saved['S​i​l​e​n​t​ ​A​i​m']['F​O​V']['3D'][3])
                SilentAimPart.Parent = game:FindFirstChild("Workspace")
                SilentAimPart.Anchored = true
                SilentAimPart.CanCollide = false
                SilentAimPart.Transparency = shared.Saved['S​i​l​e​n​t​ ​A​i​m']['F​O​V']['V​i​s​i​b​l​e'] and 0.7 or 1
                SilentAimPart.Color = Color3.new(1, 0, 0)
                
                if allConditionsPassed then
                    SilentAimPart.Position = Target.Character.HumanoidRootPart.Position
                else
                    SilentAimPart.Position = Vector3.zero
                end
                if result and result.Instance ~= SilentAimPart then
                    allConditionsPassed = false
                    SilentAimPart.Position = Vector3.zero
                end    
            end
        

            return allConditionsPassed
        end   
    
        local Ticks = {}
        local SGTick = tick()
        
        function Script:GetGunCategory()
            if Self and Self.Character then
                local Tool = Self.Character:FindFirstChildWhichIsA("Tool")
                if Tool then
                    if table.find(WeaponInfo.Shotguns, Tool.Name) then
                        return "Shotgun"
                    end
        
                    if table.find(WeaponInfo.Pistols, Tool.Name) then
                        return "Pistol"
                    end
    
                    if table.find(WeaponInfo.Rifles, Tool.Name) then
                        return "Rifle"
                    end
    
                    if table.find(WeaponInfo.Bursts, Tool.Name) then
                        return "Burst"
                    end
    
                    if table.find(WeaponInfo.SMG, Tool.Name) then
                        return "SMG"
                    end
    
                    if table.find(WeaponInfo.Snipers, Tool.Name) then
                        return "Sniper"
                    end
    
                    if table.find(WeaponInfo.AutoShotguns, Tool.Name) then
                        return "Auto"
                    end
                end
            end
            return nil
        end
    
        function Script:SilentAimFunc(Tool)
            if string.find(GameName, "Dee Hood") or string.find(GameName, "Der Hood") and shared.Saved['S​i​l​e​n​t​ ​A​i​m']['E​n​a​b​l​e​d'] then
                if Script.Locals.SilentAimTarget and Script.Locals.SilentAimTarget.Character then
                    local Player = Script.Locals.SilentAimTarget
                    local Character = Player.Character
               
                    local Position, OnScreen = Camera:WorldToViewportPoint(Script.Locals.HitPosition)
        
                    if not OnScreen then
                        return
                    end
                    
                    if Script:ShouldShoot(Script.Locals.SilentAimTarget) then
                        local Arguments = {
                            [1] = CurrentGame.Updater,
                            [2] = Script.Locals.HitPosition
                        }
        
                        CurrentGame.RemotePath():FireServer(unpack(Arguments))
                    else
                        SilentAimPart.Position = Vector3.zero
                    end
                end
            else
                if string.find(GameName, "Da Hood") then
                    if not Ticks[Tool.Name] then
                        Ticks[Tool.Name] = 0
                    end

                    local WeaponOffset = WeaponInfo.Offsets[Tool.Name]
                    local Gun = Script:GetGunCategory()
                    local ToolHandle = Tool:WaitForChild("Handle")
                    local LocalCharacter = Self.Character or Self.CharacterAdded:Wait()
                    local Cooldown = Tool:WaitForChild("ShootingCooldown").Value
                    local NoClueWhatThisIs = game.PlaceId == 88976059384565 and {
                        ["Value"] = 5
                    } or Tool.Ammo
                    local Time = game:FindFirstChild("Workspace"):GetServerTimeNow()
                    local Check = tick() - Ticks[Tool.Name] >= Cooldown + WeaponInfo.Delays[Tool.Name]
                    local ToolEvent = Tool:WaitForChild("RemoteEvent", 2) or {
                        ["FireServer"] = function(_, _) end
                    }
    
                    local DoubleTap
                    if shared.Saved['G​u​n​ ​M​o​d​i​f​i​c​a​t​i​o​n​s']['D​o​u​b​l​e​ ​T​a​p']['E​n​a​b​l​e​d']  then
                        if Script.Locals.IsDoubleTapping then
                            DoubleTap = true
                        else
                            DoubleTap = false
                        end
                    else
                        DoubleTap = false
                    end
    
                    local BeamCol = Color3.new(1, 0.545098, 0.14902)
    
                    local function ShootFunc(GunType, SilentAim)
                        if GunType == "Shotgun" then
                            if Check and (NoClueWhatThisIs.Value >= 1 and (not _G.GUN_COMBAT_TOGGLE and DaHood.CanShoot(Self.Character))) then
                                Ticks[Tool.Name] = tick()
                                ToolEvent:FireServer("Shoot")
                                for _ = 1, 5 do
                                    local HitPosition = Script.Locals.HitPosition 
                                    local SpreadX 
                                    local SpreadY
                                    local SpreadZ
                
                                    if shared.Saved['G​u​n​ ​M​o​d​i​f​i​c​a​t​i​o​n​s']['S​p​r​e​a​d​ ​M​o​d​i​f​i​e​r']['E​n​a​b​l​e​d'] then
                                        local toolName = Tool.Name
                                        local spreadReduction = shared.Saved['G​u​n​ ​M​o​d​i​f​i​c​a​t​i​o​n​s']['S​p​r​e​a​d​ ​M​o​d​i​f​i​e​r']['Value'] or 1
                                        local randomizer = shared.Saved['G​u​n​ ​M​o​d​i​f​i​c​a​t​i​o​n​s']['S​p​r​e​a​d​ ​M​o​d​i​f​i​e​r']['R​a​n​d​o​m​i​z​e​r']
                                    

                                        spreadReduction = math.clamp(spreadReduction, 0, 1)
                                    
                                        local spreadFactor = spreadReduction 
                                    
                                        if randomizer['E​n​a​b​l​e​d'] then
                                            spreadFactor = spreadFactor * (1 - math.random() * randomizer['V​a​l​u​e'])
                                        end
                                    
                                        SpreadX = math.random() > 0.5 and math.random() * 0.05 * spreadFactor or -math.random() * 0.05 * spreadFactor
                                        SpreadY = math.random() > 0.5 and math.random() * 0.1 * spreadFactor or -math.random() * 0.1 * spreadFactor
                                        SpreadZ = math.random() > 0.5 and math.random() * 0.05 * spreadFactor or -math.random() * 0.05 * spreadFactor
                                    
                                    else
                                        SpreadX = math.random() > 0.5 and math.random() * 0.05 or -math.random() * 0.05
                                        SpreadY = math.random() > 0.5 and math.random() * 0.1 or -math.random() * 0.1
                                        SpreadZ = math.random() > 0.5 and math.random() * 0.05 or -math.random() * 0.05
                                    end
                                    
                    
                                    local ForcedOrigin = Tool:FindFirstChild("Default") and (Tool.Default:FindFirstChild("Mesh") and Tool.Default.Mesh:FindFirstChild("Muzzle")) or {
                                        ["WorldPosition"] = (ToolHandle.CFrame * WeaponOffset).Position
                                    }
                    
                                    local TotalSpread = Vector3.new(SpreadX, SpreadY, SpreadZ)
                        
                                    local AimPosition
                                    local WeaponRange = Tool:FindFirstChild("Range")
                                    if SilentAim and (Self.Character.HumanoidRootPart.Position - Script.Locals.SilentAimTarget.Character.HumanoidRootPart.Position).Magnitude < WeaponRange.Value then
                                        AimPosition = ForcedOrigin.WorldPosition + ((HitPosition - ForcedOrigin.WorldPosition).Unit + TotalSpread) * WeaponRange.Value
                                    else
                                        AimPosition = ForcedOrigin.WorldPosition + (DaHood.GetAim(ForcedOrigin.WorldPosition) + TotalSpread) * WeaponRange.Value
                                    end
    
                                    local Arg0, Arg1, Arg2 = DaHood.ShootGun({
                                        ["Shooter"] = LocalCharacter,
                                        ["Handle"] = ToolHandle,
                                        ["AimPosition"] = AimPosition,
                                        ["BeamColor"] = BeamCol,
                                        ["ForcedOrigin"] = ForcedOrigin.WorldPosition,
                                        ["LegitPosition"] = ForcedOrigin.WorldPosition + (DaHood.GetAim(ForcedOrigin.WorldPosition) + TotalSpread) * WeaponRange.Value,
                                        ["Range"] = WeaponRange.Value
                                    })
                                    ReplicatedStorage.MainEvent:FireServer("ShootGun", ToolHandle, ForcedOrigin.WorldPosition, Arg0, Arg1, Arg2, Time)
                                end
                                ToolEvent:FireServer()
                            end
                        elseif Gun == "Pistol" then
                            if Check and (NoClueWhatThisIs.Value >= 1 and (not _G.GUN_COMBAT_TOGGLE and DaHood.CanShoot(Self.Character))) then
                                Ticks[Tool.Name] = tick()
                                local HitPosition = Script.Locals.HitPosition 
                                if DoubleTap then
                                    ToolEvent:FireServer("Shoot")
                                    Script.Locals.DoubleTapState = true
                                    local AimPosition
                                    local ForcedOrigin = Tool:FindFirstChild("Default") and (Tool.Default:FindFirstChild("Mesh") and Tool.Default.Mesh:FindFirstChild("Muzzle")) or {
                                        ["WorldPosition"] = (ToolHandle.CFrame * WeaponOffset).Position
                                    }
                    
                                    local WeaponRange = Tool:WaitForChild("Range")
                                    if SilentAim and (Self.Character.HumanoidRootPart.Position - Script.Locals.SilentAimTarget.Character.HumanoidRootPart.Position).Magnitude < WeaponRange.Value then
                                        AimPosition = HitPosition
                                    else
                                        AimPosition = ForcedOrigin.WorldPosition + DaHood.GetAim(ForcedOrigin.WorldPosition) * 200  
                                    end
                                    local Arg0, Arg1, Arg2 = DaHood.ShootGun({
                                        ["Shooter"] = LocalCharacter,
                                        ["Handle"] = ToolHandle,
                                        ["ForcedOrigin"] = ForcedOrigin.WorldPosition or (ToolHandle.CFrame * WeaponOffset).Position,
                                        ["AimPosition"] = AimPosition,
                                        ["BeamColor"] = BeamCol,
                                        ["LegitPosition"] = ForcedOrigin.WorldPosition + DaHood.GetAim(ForcedOrigin.WorldPosition) * 200,
                                        ["Range"] = WeaponRange.Value
                                    })
                                    ReplicatedStorage.MainEvent:FireServer("ShootGun", ToolHandle, ForcedOrigin.WorldPosition, Arg0, Arg1, Arg2)
                                    ToolEvent:FireServer()
                                    Script.Locals.DoubleTapState = false
                                end
                                ToolEvent:FireServer("Shoot")
    
                                local AimPosition
                                local ForcedOrigin = Tool:FindFirstChild("Default") and (Tool.Default:FindFirstChild("Mesh") and Tool.Default.Mesh:FindFirstChild("Muzzle")) or {
                                    ["WorldPosition"] = (ToolHandle.CFrame * WeaponOffset).Position
                                }
                
                                local WeaponRange = Tool:WaitForChild("Range")
                                if SilentAim and (Self.Character.HumanoidRootPart.Position - Script.Locals.SilentAimTarget.Character.HumanoidRootPart.Position).Magnitude < WeaponRange.Value then
                                    AimPosition = HitPosition
                                else
                                    AimPosition = ForcedOrigin.WorldPosition + DaHood.GetAim(ForcedOrigin.WorldPosition) * 200  
                                end
                                local WeaponRange = Tool:WaitForChild("Range")
                                local Arg0, Arg1, Arg2 = DaHood.ShootGun({
                                    ["Shooter"] = LocalCharacter,
                                    ["Handle"] = ToolHandle,
                                    ["ForcedOrigin"] = ForcedOrigin.WorldPosition or (ToolHandle.CFrame * WeaponOffset).Position,
                                    ["AimPosition"] = AimPosition,
                                    ["BeamColor"] = BeamCol,
                                    ["LegitPosition"] = ForcedOrigin.WorldPosition + DaHood.GetAim(ForcedOrigin.WorldPosition) * 200,
                                    ["Range"] = WeaponRange.Value
                                })
                                ReplicatedStorage.MainEvent:FireServer("ShootGun", ToolHandle, ForcedOrigin.WorldPosition, Arg0, Arg1, Arg2)
                                ToolEvent:FireServer()
                            end
                        elseif Gun == "Auto" then
                            if Check and (not _G.GUN_COMBAT_TOGGLE and DaHood.CanShoot(LocalCharacter)) then
                                Ticks[Tool.Name] = tick()
                                ToolEvent:FireServer("Shoot")
                                local Flag = true
                                task.spawn(function()
                                    while Flag and (Tool.Parent == LocalCharacter and (NoClueWhatThisIs.Value > 0 and DaHood.CanShoot(LocalCharacter))) do
                                        local HitPosition = Script.Locals.HitPosition 
                                        local CurrentTime = game:FindFirstChild("Workspace"):GetServerTimeNow()
                                        for _ = 1, 5 do
                                            local SpreadX 
                                            local SpreadY
                                            local SpreadZ
                                            if shared.Saved['G​u​n​ ​M​o​d​i​f​i​c​a​t​i​o​n​s']['S​p​r​e​a​d​ ​M​o​d​i​f​i​e​r']['E​n​a​b​l​e​d'] then
                                                local toolName = Tool.Name
                                                local spreadReduction = shared.Saved['G​u​n​ ​M​o​d​i​f​i​c​a​t​i​o​n​s']['Value'] or 1
                                                local randomizer = shared.Saved['G​u​n​ ​M​o​d​i​f​i​c​a​t​i​o​n​s']['S​p​r​e​a​d​ ​M​o​d​i​f​i​e​r']['R​a​n​d​o​m​i​z​e​r']
                                                spreadReduction = math.clamp(spreadReduction, 0, 1)
                                                local spreadFactor = spreadReduction 
                                            
                                                if randomizer['E​n​a​b​l​e​d'] then
                                                    spreadFactor = spreadFactor * (1 - math.random() * randomizer['V​a​l​u​e'])
                                                end
                                                SpreadX = math.random() > 0.5 and math.random() * 0.05 * spreadFactor or -math.random() * 0.05 * spreadFactor
                                                SpreadY = math.random() > 0.5 and math.random() * 0.1 * spreadFactor or -math.random() * 0.1 * spreadFactor
                                                SpreadZ = math.random() > 0.5 and math.random() * 0.05 * spreadFactor or -math.random() * 0.05 * spreadFactor
                                            
                                            else
                                                SpreadX = math.random() > 0.5 and math.random() * 0.05 or -math.random() * 0.05
                                                SpreadY = math.random() > 0.5 and math.random() * 0.1 or -math.random() * 0.1
                                                SpreadZ = math.random() > 0.5 and math.random() * 0.05 or -math.random() * 0.05
                                            end
    
                                            local ForcedOrigin = Tool:FindFirstChild("Default") and (Tool.Default:FindFirstChild("Mesh") and Tool.Default.Mesh:FindFirstChild("Muzzle")) or {
                                                ["WorldPosition"] = (ToolHandle.CFrame * WeaponOffset).Position
                                            }
                            
                                            local TotalSpread = Vector3.new(SpreadX, SpreadY, SpreadZ)
                                            local AimPosition
                                            local WeaponRange = Tool:WaitForChild("Range")
                                            if SilentAim and (Self.Character.HumanoidRootPart.Position - Script.Locals.SilentAimTarget.Character.HumanoidRootPart.Position).Magnitude < WeaponRange.Value then
                                                AimPosition = ForcedOrigin.WorldPosition + ((HitPosition - ForcedOrigin.WorldPosition).Unit + TotalSpread) * WeaponRange.Value
                                            else
                                                AimPosition = ForcedOrigin.WorldPosition + (DaHood.GetAim(ForcedOrigin.WorldPosition) + TotalSpread) * WeaponRange.Value
                                            end
                                            local Arg0, Arg1, Arg2 = DaHood.ShootGun({
                                                ["Shooter"] = LocalCharacter,
                                                ["Handle"] = ToolHandle,
                                                ["AimPosition"] = AimPosition,
                                                ["BeamColor"] = BeamCol,
                                                ["ForcedOrigin"] = ForcedOrigin.WorldPosition,
                                                ["LegitPosition"] = ForcedOrigin.WorldPosition + (DaHood.GetAim(ForcedOrigin.WorldPosition) + TotalSpread) * WeaponRange.Value,
                                                ["Range"] = WeaponRange.Value
                                            })
                                            ReplicatedStorage.MainEvent:FireServer("ShootGun", ToolHandle, ForcedOrigin.WorldPosition, Arg0, Arg1, Arg2, CurrentTime)
                                        end
                                        task.wait(Cooldown + 0.0095)
                                        Ticks[Tool.Name] = tick()
                                    end
                                    ToolEvent:FireServer()
                                end)
                                Tool.Deactivated:Wait()
                                Flag = false
                            end
                        elseif Gun == "Burst" then
                            local Tolerance = Tool:WaitForChild("ToleranceCooldown").Value
                            local ShootingCool = Tool:WaitForChild("ShootingCooldown").Value
                            if tick() - Ticks[Tool.Name] >= Tolerance and (not _G.GUN_COMBAT_TOGGLE and DaHood.CanShoot(LocalCharacter)) then
                                Ticks[Tool.Name] = tick()
                                ToolEvent:FireServer("Shoot")
                                game:FindFirstChild("Workspace"):GetServerTimeNow()
                                task.spawn(function()
                                    for _ = 1, NoClueWhatThisIs.Value > 3 and 3 or NoClueWhatThisIs.Value do
                                        local HitPosition = Script.Locals.HitPosition 
                                        local v17
                                        local ForcedOrigin = Tool:FindFirstChild("Default") and (Tool.Default:FindFirstChild("Mesh") and Tool.Default.Mesh:FindFirstChild("Muzzle")) or {
                                            ["WorldPosition"] = (ToolHandle.CFrame * WeaponOffset).Position
                                        }
                                        local WeaponRange = Tool:WaitForChild("Range")
                                        if SilentAim and (Self.Character.HumanoidRootPart.Position - Script.Locals.SilentAimTarget.Character.HumanoidRootPart.Position).Magnitude < WeaponRange.Value then
                                            v17 = ForcedOrigin.WorldPosition + ((HitPosition - ForcedOrigin.WorldPosition).Unit) * 200
                                        else
                                            v17 = ForcedOrigin.WorldPosition + DaHood.GetAim(ForcedOrigin.WorldPosition) * 200
                                        end
                                        local v18, v19, v20 = DaHood.ShootGun({
                                            ["Shooter"] = LocalCharacter,
                                            ["Handle"] = ToolHandle,
                                            ["ForcedOrigin"] = ForcedOrigin.WorldPosition,
                                            ["AimPosition"] = v17,
                                            ["LegitPosition"] = ForcedOrigin.WorldPosition + DaHood.GetAim(ForcedOrigin.WorldPosition) * 200,
                                            ["BeamColor"] = BeamCol,
                                            ["Range"] = WeaponRange.Value
                                        })
                                        ReplicatedStorage.MainEvent:FireServer("ShootGun", ToolHandle, ForcedOrigin.WorldPosition, v18, v19, v20)
                                        task.wait(ShootingCool + 0.0095)
                                    end
                                    ToolEvent:FireServer()
                                end)
                            end
                        elseif Gun == "Rifle" or GunType == "SMG" then
                            local ShootingCool = Tool:WaitForChild("ShootingCooldown").Value
                            if Check and (not _G.GUN_COMBAT_TOGGLE and DaHood.CanShoot(LocalCharacter)) then
                                Ticks[Tool.Name] = tick()
                                ToolEvent:FireServer("Shoot")
                                local Flag = true
                                task.spawn(function()
                                    while task.wait(ShootingCool + 0.0095) and (Flag and (Tool.Parent == LocalCharacter and (NoClueWhatThisIs.Value > 0 and DaHood.CanShoot(LocalCharacter)))) do
                                        local HitPosition = Script.Locals.HitPosition 
                                        local ForcedOrigin = Tool:FindFirstChild("Default") and (Tool.Default:FindFirstChild("Mesh") and Tool.Default.Mesh:FindFirstChild("Muzzle")) or {
                                            ["WorldPosition"] = (ToolHandle.CFrame * WeaponOffset).Position
                                        }
                        
                                        local AimPosition
                                        local WeaponRange = Tool:WaitForChild("Range")
                                        if SilentAim and (Self.Character.HumanoidRootPart.Position - Script.Locals.SilentAimTarget.Character.HumanoidRootPart.Position).Magnitude < WeaponRange.Value then
                                            AimPosition =  ForcedOrigin.WorldPosition + ((HitPosition - ForcedOrigin.WorldPosition).Unit) * 200
                                        else
                                            AimPosition = ForcedOrigin.WorldPosition + DaHood.GetAim(ForcedOrigin.WorldPosition) * 200
                                        end
                                        local WeaponRange = Tool:WaitForChild("Range")
    
                                        local v18, v19, v20 = DaHood.ShootGun({
                                            ["Shooter"] = LocalCharacter,
                                            ["Handle"] = ToolHandle,
                                            ["ForcedOrigin"] = ForcedOrigin.WorldPosition,
                                            ["AimPosition"] = AimPosition,
                                            ["LegitPosition"] = ForcedOrigin.WorldPosition + DaHood.GetAim(ForcedOrigin.WorldPosition) * 200,
                                            ["BeamColor"] = BeamCol,
                                            ["Range"] = WeaponRange.Value
                                        })
                                        ReplicatedStorage.MainEvent:FireServer("ShootGun", ToolHandle, ForcedOrigin.WorldPosition, v18, v19, v20)
                                        Ticks[Tool.Name] = tick()
                                    end
                                    ToolEvent:FireServer()
                                end)
                                Tool.Deactivated:Wait()
                                Flag = false
                            end
                        elseif Gun == "Sniper" then
                            if Check and (not _G.GUN_COMBAT_TOGGLE and DaHood.CanShoot(LocalCharacter)) then
                                Ticks[Tool.Name] = tick()
                                ToolEvent:FireServer("Shoot")
                                local HitPosition = Script.Locals.HitPosition 
                                local ForcedOrigin = Tool:FindFirstChild("Default") and (Tool.Default:FindFirstChild("Mesh") and Tool.Default.Mesh:FindFirstChild("Muzzle")) or {
                                    ["WorldPosition"] = (ToolHandle.CFrame * WeaponOffset).Position
                                }
                
                                local AimPosition
                                local WeaponRange = Tool:WaitForChild("Range")
                                if SilentAim and (Self.Character.HumanoidRootPart.Position - Script.Locals.SilentAimTarget.Character.HumanoidRootPart.Position).Magnitude < WeaponRange.Value then
                                    AimPosition =  ForcedOrigin.WorldPosition + ((HitPosition - ForcedOrigin.WorldPosition).Unit) * 50
                                else
                                    AimPosition = ForcedOrigin.WorldPosition + DaHood.GetAim(ForcedOrigin.WorldPosition) * 50
                                end
        
                                local v16, v17, v18 = DaHood.ShootGun({
                                    ["Shooter"] = LocalCharacter,
                                    ["Handle"] = ToolHandle,
                                    ["ForcedOrigin"] = ForcedOrigin.WorldPosition,
                                    ["AimPosition"] = AimPosition,
                                    ["LegitPosition"] = ForcedOrigin.WorldPosition + DaHood.GetAim(ForcedOrigin.WorldPosition) * 50,
                                    ["BeamColor"] = BeamCol,
                                    ["Range"] = WeaponRange.Value
                                })
                                ReplicatedStorage.MainEvent:FireServer("ShootGun", ToolHandle, ForcedOrigin.WorldPosition, v16, v17, v18)
                                ToolEvent:FireServer()
                            end
                        end
                    end
                       
                    if shared.Saved['S​i​l​e​n​t​ ​A​i​m']['E​n​a​b​l​e​d'] and Script.Locals.SilentAimTarget and Script.Locals.SilentAimTarget.Character then
                        local target = Script.Locals.SilentAimTarget
                        ShootFunc(Gun, Script:ShouldShoot(target))
                    else
                        ShootFunc(Gun, false)
                    end
                end
            end
        end
    
        function Script:AimAssist()
            local Enabled = shared.Saved['A​i​m​ ​B​o​t']['E​n​a​b​l​e​d'] 
            if (Enabled and Script.Locals.AimAssistTarget and Script.Locals.AimAssistTarget.Character) then
                local Player = Script.Locals.AimAssistTarget
                local Character = Player.Character
                if shared.Saved['C​o​n​d​i​t​i​o​n​s']['P​l​a​y​e​r​ ​P​r​o​t​e​c​t​e​d'] and Character:FindFirstChild("Forcefield") then
                    return 
                end
            
                if shared.Saved['C​o​n​d​i​t​i​o​n​s']['P​l​a​y​e​r​ ​M​o​v​i​n​g'] then
                    local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
                    if Humanoid and Humanoid.MoveDirection.Magnitude < 0.001 then
                        return 
                    end
                end
            
                if shared.Saved['C​o​n​d​i​t​i​o​n​s']['P​l​a​y​e​r​ ​V​i​s​i​b​l​e'] then
                    if not Script:RayCast(Character.HumanoidRootPart, Script:GetOrigin('Camera'), {Self.Character, TriggerPart, SilentAimPart}) then
                        return 
                    end
                end
            
                if shared.Saved['C​o​n​d​i​t​i​o​n​s']['P​l​a​y​e​r​ ​K​n​o​c​k​e​d'] and CurrentGame.Functions.IsKnocked(Player.Character) then
                    return 
                end
            
                if shared.Saved['C​o​n​d​i​t​i​o​n​s']['S​e​l​f​ ​K​n​o​c​k​e​d'] and CurrentGame.Functions.IsKnocked(Self.Character) then
                    return 
                end
            
                if shared.Saved['C​o​n​d​i​t​i​o​n​s']['P​l​a​y​e​r​ ​G​r​a​b​b​e​d'] and CurrentGame.Functions.IsGrabbed(Player) then
                    return 
                end
    
                if shared.Saved['C​o​n​d​i​t​i​o​n​s']['C​h​a​t​ ​F​o​c​u​s​e​d'] and UserInputService:GetFocusedTextBox() then return end
    
                local Config = shared.Saved['A​i​m​ ​B​o​t'] 
                local CurrentCamera = Workspace.CurrentCamera
                local Center = Vector2.new(0.5, 0.5)
                local MousePosition = UserInputService:GetMouseLocation()
                local MouseDelta = (MousePosition.X / CurrentCamera.ViewportSize.X - Center.X) * Config['S​e​n​s​i​t​i​v​i​t​y']
        
                local Smoothing = Config['S​t​i​c​k​i​n​e​s​s']
                local EasedSmoothing = TweenService:GetValue(Smoothing, Enum.EasingStyle[Config['E​a​s​i​n​g ​S​t​y​l​e']], Enum.EasingDirection[Config['E​a​s​i​n​g ​D​i​r​e​c​t​i​o​n']])
                local Hit = Script:GetHitPosition("Assist")
    
                CurrentCamera.CFrame = CurrentCamera.CFrame:Lerp(
                    CFrame.new(CurrentCamera.CFrame.Position, Hit) * CFrame.Angles(0, MouseDelta, 0),
                    EasedSmoothing
                )
        
            end
        end
    
        local function ActivateTool()
            local Tool = Self.Character:FindFirstChildOfClass("Tool")
            if Tool ~= nil and Tool:IsDescendantOf(Self.Character) and Tool.Name ~= '[Knife]' then 
                Tool:Activate()
            end 
        end     
    
        local function raycast(origin, direction, raycastParams)
            local result = workspace:Raycast(origin, direction, raycastParams)
        
            if result and result.Instance then
                if result.Instance ~= TriggerPart then
                    -- Continue raycasting by updating origin if needed, or stop after first hit
                    origin = result.Position + direction.Unit * 0.1
                    -- Do the next raycast
                    return raycast(origin, direction, raycastParams)  -- Recursively call if needed
                else
                    -- If we hit the TriggerPart, return the result
                    return result
                end
            end
            return nil  -- No hit found
        end        
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
        raycastParams.FilterDescendantsInstances = {TriggerPart}
        
        function Script:Triggerbot()
            local triggerBotConfig = shared.Saved['T​r​i​g​g​e​r​ ​B​o​t'] 
            local locals = Script.Locals
            local target = locals.TriggerbotTarget and locals.TriggerbotTarget.Character
            local TriggerBotConfig = shared.Saved['T​r​i​g​g​e​r​ ​B​o​t']
            
            TriggerPart.Size = Vector3.new(shared.Saved['T​r​i​g​g​e​r​ ​B​o​t']['F​O​V']['X'], shared.Saved['T​r​i​g​g​e​r​ ​B​o​t']['F​O​V']['Y'], shared.Saved['T​r​i​g​g​e​r​ ​B​o​t']['F​O​V']['Z'])
            TriggerPart.Parent = game:FindFirstChild("Workspace")
            TriggerPart.Anchored = true
            TriggerPart.CanCollide = false
            TriggerPart.Transparency = shared.Saved['T​r​i​g​g​e​r​ ​B​o​t']['F​O​V']['V​i​s​i​b​l​e'] and 0.7 or 1
            TriggerPart.Color = Color3.new(1, 0, 0)
            
            
            if target then
                local selfCharacter = Self.Character
                local tool = selfCharacter:FindFirstChildOfClass("Tool")


                if not tool or not tool:FindFirstChild("Ammo") or tool.Name == "Knife" then 
                    TriggerPart.Position = Vector3.zero 
                    return 
                end
                
                if not (triggerBotConfig['E​n​a​b​l​e​d'] and locals.TriggerState and target) then
                    TriggerPart.Position = Vector3.zero
                    return
                end
            
                if not CanTriggerbotShoot then
                    TriggerPart.Position = Vector3.zero
                    return
                end

                local Player = locals.TriggerbotTarget
                local Character = locals.TriggerbotTarget.Character
                if shared.Saved['C​o​n​d​i​t​i​o​n​s']['P​l​a​y​e​r​ ​P​r​o​t​e​c​t​e​d'] and Character:FindFirstChild("Forcefield") then
                    TriggerPart.Position = Vector3.zero
                    return 
                end
            
                if shared.Saved['C​o​n​d​i​t​i​o​n​s']['P​l​a​y​e​r​ ​M​o​v​i​n​g'] then
                    local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
                    if Humanoid and Humanoid.MoveDirection.Magnitude < 0.001 then
                        TriggerPart.Position = Vector3.zero
                        return 
                    end
                end
            
                if shared.Saved['C​o​n​d​i​t​i​o​n​s']['P​l​a​y​e​r​ ​V​i​s​i​b​l​e'] then
                    if not Script:RayCast(TriggerPart, Script:GetOrigin('Camera'), {Self.Character, TriggerPart, SilentAimPart}) then
                        TriggerPart.Position = Vector3.zero
                        return 
                    end
                end
            
                if shared.Saved['C​o​n​d​i​t​i​o​n​s']['P​l​a​y​e​r​ ​K​n​o​c​k​e​d'] and CurrentGame.Functions.IsKnocked(Player.Character) then
                    TriggerPart.Position = Vector3.zero
                    return 
                end
            
                if shared.Saved['C​o​n​d​i​t​i​o​n​s']['S​e​l​f​ ​K​n​o​c​k​e​d'] and CurrentGame.Functions.IsKnocked(Self.Character) then
                    TriggerPart.Position = Vector3.zero
                    return 
                end
            
                if shared.Saved['C​o​n​d​i​t​i​o​n​s']['P​l​a​y​e​r​ ​G​r​a​b​b​e​d'] and CurrentGame.Functions.IsGrabbed(Player) then
                    TriggerPart.Position = Vector3.zero
                    return 
                end
    
                if shared.Saved['C​o​n​d​i​t​i​o​n​s']['C​h​a​t​ ​F​o​c​u​s​e​d'] and UserInputService:GetFocusedTextBox() then 
                    TriggerPart.Position = Vector3.zero
                    return 
                end

            
                local targetDistance = (selfCharacter.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude
                if targetDistance > 200 then TriggerPart.Position = Vector3.zero return end
        
                local velocity = GetResolvedVelocity(target.HumanoidRootPart)
                local prediction = triggerBotConfig['P​r​e​d​i​c​t​i​o​n']
    
                if prediction['E​n​a​b​l​e​d'] then
                    TriggerPart.Position = target.HumanoidRootPart.Position + Vector3.new(velocity.X * prediction[1], 0, velocity.Z * prediction[1]) 
                else
                    TriggerPart.Position = target.HumanoidRootPart.Position
                end
            
                local mouseLocation = UserInputService:GetMouseLocation()
                local ray = Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
                local result = raycast(ray.Origin, ray.Direction * 1000, raycastParams)
            
                if result and result.Instance == TriggerPart and tool.Name ~= '[Knife]' then
                    Script:TriggerShot(triggerBotConfig['C​o​o​l​d​o​w​n'])
                    TriggerPart.Color = Color3.new(0, 1, 0)
                else
                    TriggerPart.Color = Color3.new(1, 0, 0)
                end
            else
                TriggerPart.Position = Vector3.zero
            end
        end
        
        function Script:TriggerShot(interval)
            local locals = Script.Locals
            local currentTime = DateTime.now().UnixTimestampMillis
            if currentTime - locals.LastShot >= interval * 1000 then
                locals.LastShot = currentTime
                ActivateTool()
            end
        end    
    
        function Script:Physics()
            if not Self.Character then return end
            if shared.Saved['P​l​a​y​e​r​ ​M​o​d​i​f​i​c​a​t​i​o​n​s']['W​a​l​k​ ​S​p​e​e​d']['E​n​a​b​l​e​d'] and Script.Locals.IsWalkSpeeding then
                local Object, Humanoid, RootPart = Script:ValidateClient(Self)
                if (Humanoid and RootPart) then
    
                    if not shared.Saved['P​l​a​y​e​r​ ​M​o​d​i​f​i​c​a​t​i​o​n​s']['W​a​l​k​ ​S​p​e​e​d']['G​l​i​d​e'] then
                        RootPart.CustomPhysicalProperties = PhysicalProperties.new(100, .3, .5)
                    end
                    Humanoid.WalkSpeed = shared.Saved['P​l​a​y​e​r​ ​M​o​d​i​f​i​c​a​t​i​o​n​s']['W​a​l​k​ ​S​p​e​e​d']['S​p​e​e​d'] * 100
                end
            end
            if shared.Saved['P​l​a​y​e​r​ ​M​o​d​i​f​i​c​a​t​i​o​n​s']['N​o​ ​T​r​i​p​p​i​n​g'] then
                if Self.Character.Humanoid.Health > 1 and  Self.Character.Humanoid:GetState() == Enum.HumanoidStateType.FallingDown then
                    Self.Character.Humanoid:ChangeState("GettingUp")
                end
            end
        end
    end
    do
        local FOVConfig = shared.Saved['S​i​l​e​n​t​ ​A​i​m']['F​O​V']
        local SilentAimConfig = shared.Saved['S​i​l​e​n​t​ ​A​i​m']
        local TriggerBotConfig = shared.Saved['T​r​i​g​g​e​r​ ​B​o​t']
    
        local FieldOfViewSquare = Script.Visuals.new("Square")
        FieldOfViewSquare.Visible = FOVConfig['V​i​s​i​b​l​e']
        FieldOfViewSquare.Color = Color3.fromRGB(255, 255, 255)
        FieldOfViewSquare.Thickness = 1
        FieldOfViewSquare.Transparency = 1
    
        local FieldOfViewCircle = Script.Visuals.new("Circle")
        FieldOfViewCircle.Visible = FOVConfig['V​i​s​i​b​l​e']
        FieldOfViewCircle.Color = Color3.fromRGB(255, 255, 255)
        FieldOfViewCircle.Thickness = 1
        FieldOfViewCircle.Transparency = 1
        --[[
        local DebugCircle = Script.Visuals.new("Circle")
        DebugCircle.Visible = FOVConfig['V​i​s​i​b​l​e']
        DebugCircle.Color = Color3.fromRGB(255, 255, 255)
        DebugCircle.Thickness = 1
        DebugCircle.Transparency = 1
        ]]
        Script.Locals.FieldOfViewOne = FieldOfViewSquare
    
        local function GetBodySize(Character)
            local Part = Script:GetClosestPartToCursor(Character)
            if (Part) then
                local l = game:FindFirstChild("Workspace").CurrentCamera:WorldToScreenPoint(Part.Position - Part.Size / 2)
                local r = game:FindFirstChild("Workspace").CurrentCamera:WorldToScreenPoint(Part.Position + Part.Size / 2)
                local w = math.abs(l.X - r.X)
                local h = math.abs(l.Y - r.Y)
                --
                return w, h
            end
            --
            return 0, 0 
        end
        
        local function get_quad(a, b, c)
            local s = b^2 - 4 * a * c
            if s < 0 then
                return nil
            end
            local d = math.sqrt(s)
            local t1 = (-b + d) / (2 * a)
            local t2 = (-b - d) / (2 * a)
            --
            if t1 >= 0 and t2 >= 0 then
                return math.min(t1, t2)
            elseif t1 >= 0 then
                return t1
            elseif t2 >= 0 then
                return t2
            end
            --
            return nil
        end
        --
        local function get_interception(A, B0, v_t, v_b)
            local function getCoefficients(A_comp, B_comp, v_t_comp)
                local a = v_t_comp * v_t_comp - v_b^2
                local b = 2 * (A_comp - B_comp) * v_t_comp
                local c = (A_comp - B_comp) * (A_comp - B_comp)
                return a, b, c
            end
        
            local function solveDimension(A_comp, B_comp, v_t_comp)
                local a, b, c = getCoefficients(A_comp, B_comp, v_t_comp)
                return get_quad(a, b, c)
            end
        
            local t_x, err_x = solveDimension(A.x, B0.x, v_t.x)
            local t_y, err_y = solveDimension(A.y, B0.y, v_t.y)
            local t_z, err_z = solveDimension(A.z, B0.z, v_t.z)
        
            if not t_x or not t_y or not t_z then
                return nil, 'how did we end up here'
            end
        
            local t = math.max(t_x, t_y, t_z)
        
            local Bt = B0 + v_t * t
            return Bt, t_x, t_y, t_z
        end
        --
        local function get_ground(position)
            local ray = Ray.new(position, Vector3.new(0, -1000, 0))
            local hitPart, hitPosition = game:FindFirstChild("Workspace"):FindPartOnRay(ray)
            --
            if hitPart then
                return hitPosition.Y
            else
                return position.Y
            end
        end
        --
        local function backup_velocity(t, width, height)
            local average_size = (width + height) / 2
            local base_size = 100
            local size_factor = (average_size / base_size) - 1
            size_factor = math.clamp(size_factor, -1, 1)
            local min_adjustment = 0.05
            local max_adjustment = 0.145
            local adjustment_range = max_adjustment - min_adjustment
            local adjusted_t = min_adjustment + (size_factor ^ 2) * adjustment_range
            return adjusted_t
        end
        --
        local function get_velocity(t, width, height)
            local average_size = (width + height) / 2
            local base_size = 100
            local size_factor = (average_size / base_size) - 1
            size_factor = math.clamp(size_factor, -1, 1)
        
            local min_adjustment = 0.05
            local max_adjustment = 0.145
            local adjustment_range = max_adjustment - min_adjustment
        
            local adjustment = min_adjustment + (size_factor ^ 2) * adjustment_range
            return Vector3.new(adjustment, adjustment, adjustment) * t
        end
        
        local function m_wait()
            local t = tick()
            game.ReplicatedStorage.DefaultChatSystemChatEvents.MutePlayerRequest:InvokeServer()
            return (tick() - t) * 1000 / 0.5
        end
        
        local function AutomatedPrediction()
            local silentAimSettings = shared.Saved['S​i​l​e​n​t​ ​A​i​m']
            local TargetPlayerData = Script.Locals.SilentAimTarget
        
            local silentAimTarget = TargetPlayerData
            local playerCharacter = Self.Character
        
            if silentAimTarget and silentAimTarget.Character and playerCharacter and silentAimSettings['M​o​d​e'] == 'HitScan' then
                local tool = playerCharacter:FindFirstChildOfClass('Tool')
                local handle = tool and tool:FindFirstChild('Handle')
                local shootBBGUI = handle and handle:FindFirstChild('ShootBBGUI')
        
                if not silentAimTarget.Character:FindFirstChild("Humanoid") then
                    return
                end
                if handle and shootBBGUI then
                    local humanoidRootPart = TargetPlayerData.Character.HumanoidRootPart
                    local Velocity = humanoidRootPart.Velocity
                    local handlePosition = handle.Position
                    local origin = handlePosition + handle.CFrame:VectorToWorldSpace(shootBBGUI.StudsOffsetWorldSpace)
        
                    Velocity_Data.Recorded = {
                        Alpha = origin,
                        B_0 = humanoidRootPart.Position,
                        V_T = Velocity,
                        V_B = m_wait() * silentAimSettings['P​r​e​d​i​c​t​i​o​n']['S​c​a​l​e']
                    }
                    
                    local Bt, t_x, t_y, t_z = get_interception(
                        origin,
                        humanoidRootPart.Position,
                        Velocity,
                        Velocity_Data.Recorded.V_B
                    )
        
                    if Bt then
                        local predictionVector = Vector3.new(t_x, t_y, t_z)
                        local width, height = GetBodySize(silentAimTarget)
                        silentAimSettings['P​r​e​d​i​c​t​i​o​n']['X'] = backup_velocity(predictionVector.Magnitude, width, height)
                        silentAimSettings['P​r​e​d​i​c​t​i​o​n']['Y'] = backup_velocity(predictionVector.Magnitude, width, height)
        
                        local adjustedPrediction = get_velocity(predictionVector, width, height)
                        if adjustedPrediction then
                            local groundLevel = get_ground(Bt)
                            Bt = Vector3.new(Bt.X, math.max(Bt.Y, groundLevel), Bt.Z)
        
                            local heightAdjustment = math.max(0, Bt.Y - humanoidRootPart.Position.Y)
                            Velocity_Data.Y = adjustedPrediction.Y * (heightAdjustment / (Bt.Y - humanoidRootPart.Position.Y + 1))
                            Velocity_Data.State = TargetPlayerData.Character.Humanoid:GetState()
                        end
                    end
                end
            end
        end
    
        if string.find(GameName, "Dee Hood") then
            local function GetArgument() 
                for _, Player in next, game:GetService("Players"):GetPlayers() do
                    if Player.Backpack:GetAttribute(string.upper("muv")) then
                        return Player.Backpack:GetAttribute(string.upper("muv"))
                    end
                end
                return nil
            end
            
            local Argument = GetArgument()
            if Argument then
                CurrentGame.Updater = Argument
            end
        end
    
        local Activated
        local function OnLocalCharacterAdded(Character)
            if (not Character) then
                return
            end
    
            Character.ChildAdded:Connect(function(Tool)
                if (not Tool:IsA("Tool")) then
                    return
                end
                Activated = Tool.Activated:Connect(function()
                    Script:SilentAimFunc(Tool)
                end)
            end)
    
            Character.ChildRemoved:Connect(function(Tool)
                if (not Tool:IsA("Tool")) then
                    return
                end
    
                if Activated then
                    Activated:Disconnect()
                end
            end)
        end
        local DebugCircle = Script.Visuals.new("Circle")
        OnLocalCharacterAdded(Self.Character)
        Self.CharacterAdded:Connect(OnLocalCharacterAdded)
        local WeaponConfigs = shared.Saved['S​i​l​e​n​t​ ​A​i​m']['F​O​V']['W​e​a​p​o​n​ ​C​o​n​f​i​g​s']
        local function UpdateDrawings()
            local Character = Self.Character
            if not Character then return end
            local Tool = Character:FindFirstChildWhichIsA("Tool")
            if WeaponConfigs['E​n​a​b​l​e​d'] and Tool then
                if table.find(WeaponInfo.Shotguns, Tool.Name) then
                    CurrentFOV = WeaponConfigs['S​h​o​t​g​u​n​s']['C​i​r​c​l​e']
                    CurrentFOVX = WeaponConfigs['S​h​o​t​g​u​n​s']['B​o​x'][1]
                    CurrentFOVY = WeaponConfigs['S​h​o​t​g​u​n​s']['B​o​x'][2]
                elseif table.find(WeaponInfo.Pistols, Tool.Name) then
                    CurrentFOV = WeaponConfigs['P​i​s​t​o​l​s']['C​i​r​c​l​e']
                    CurrentFOVX = WeaponConfigs['P​i​s​t​o​l​s']['B​o​x'][1]
                    CurrentFOVY = WeaponConfigs['P​i​s​t​o​l​s']['B​o​x'][2]
                else
                    CurrentFOV = WeaponConfigs['O​t​h​e​r​s']['C​i​r​c​l​e']
                    CurrentFOVX = WeaponConfigs['O​t​h​e​r​s']['B​o​x'][1]
                    CurrentFOVY = WeaponConfigs['O​t​h​e​r​s']['B​o​x'][2]
                end
            else
                CurrentFOV = shared.Saved['S​i​l​e​n​t​ ​A​i​m']['F​O​V']['C​i​r​c​l​e']
                CurrentFOVX = shared.Saved['S​i​l​e​n​t​ ​A​i​m']['F​O​V']['B​o​x'][1]
                CurrentFOVY = shared.Saved['S​i​l​e​n​t​ ​A​i​m']['F​O​V']['B​o​x'][2]
            end 
         
            DebugCircle.Visible = false
            Script.Locals.FieldOfViewTwo = FieldOfViewCircle
            Script.Locals.FieldOfViewTwo.Visible = shared.Saved['S​i​l​e​n​t​ ​A​i​m']['F​O​V']['T​y​p​e'] == 'Circle' and shared.Saved['S​i​l​e​n​t​ ​A​i​m']['F​O​V']['V​i​s​i​b​l​e'] 
            Script.Locals.FieldOfViewTwo.Radius = CurrentFOV
            Script.Locals.FieldOfViewTwo.Position = Vector2.new(Mouse.X, Mouse.Y + GuiInsetOffsetY)
            Script:UpdateBox()
            Script:UpdateLabels() 
        end
        
        ThreadLoop(0.0001, function() --// make it wait to reduce fps intake
            
            if string.find(GameName, "Da Hood") then
                local GunType = Script:GetGunCategory()
                local Tool = Self.Character:FindFirstChildWhichIsA("Tool")
                if Tool then
                    if GunType == "Pistol" or GunType == "Sniper" then
                        for I, v in pairs(Tool:GetChildren()) do
                            if v.Name == "GunClient" then
                                v:Destroy()
                            end
                        end
                    elseif GunType == "Shotgun" then
                        for I, v in pairs(Tool:GetChildren()) do
                            if v.Name == "GunClientShotgun" then
                                v:Destroy()
                            end
                        end
                    elseif GunType == "Auto" then
                        for I, v in pairs(Tool:GetChildren()) do
                            if v.Name == "GunClientAutomaticShotgun" then
                                v:Destroy()
                            end
                        end
                    elseif GunType == "Burst" then
                        for I, v in pairs(Tool:GetChildren()) do
                            if v.Name == "GunClientBurst" then
                                v:Destroy()
                            end
                        end
                    elseif GunType == "Rifle" or GunType == "SMG" then
                        for I, v in pairs(Tool:GetChildren()) do
                            if v.Name == "GunClientAutomatic" then
                                v:Destroy()
                            end
                        end
                    end    
                end
            end
        end)
        local SP = false
        local SP2 = false
        local SP3 = false
        RBXConnection(UserInputService.InputBegan, function(Input, Processed)
            if shared.Saved['C​o​n​d​i​t​i​o​n​s']['C​h​a​t​ ​F​o​c​u​s​e​d'] and UserInputService:GetFocusedTextBox() then return end
            local AimAssist = Enum.KeyCode[shared.Saved['G​e​n​e​r​a​l​']['​H​o​t​k​e​y​s​']['A​i​m​ ​B​o​t']:upper()]
            local WalkSpeed = Enum.KeyCode[shared.Saved['G​e​n​e​r​a​l​']['​H​o​t​k​e​y​s​']['W​a​l​k​ ​S​p​e​e​d']:upper()]
            local DoubleTap = Enum.KeyCode[shared.Saved['G​e​n​e​r​a​l​']['​H​o​t​k​e​y​s​']['D​o​u​b​l​e​ ​T​a​p']:upper()]
            local TriggerBotTarget = Enum.KeyCode[shared.Saved['G​e​n​e​r​a​l​']['​H​o​t​k​e​y​s​']['T​r​i​g​g​e​r​ ​B​o​t​ ​T​a​r​g​e​t']:upper()]
            local SilentAimTarget = Enum.KeyCode[shared.Saved['G​e​n​e​r​a​l​']['​H​o​t​k​e​y​s​']['S​i​l​e​n​t​ ​A​i​m​ ​T​a​r​g​e​t']:upper()]
            local SilentAim = Enum.KeyCode[shared.Saved['G​e​n​e​r​a​l​']['​H​o​t​k​e​y​s​']['S​i​l​e​n​t​ ​A​i​m']:upper()]
            local HitPartOverride = Enum.KeyCode[shared.Saved['G​e​n​e​r​a​l​']['​H​o​t​k​e​y​s​']['H​i​t​ ​P​a​r​t Override'] :upper()]
            if Input.KeyCode == SilentAim then
                IsSilentAiming = not IsSilentAiming
            end
    
            if Input.KeyCode == HitPartOverride then
                Script.Locals.IsOverriding = not Script.Locals.IsOverriding
            end
    
            if Input.KeyCode == SilentAimTarget and SilentAimConfig['S​e​l​e​c​t​i​o​n'] == 'Target' then
                SP = not SP
                if SP then 
                    Script.Locals.SilentAimTarget = Script:GetClosestPlayerToCursor(
                        SilentAimConfig['M​a​x​ ​D​i​s​t​a​n​c​e'] * 100,
                        SilentAimConfig['F​O​V']['E​n​a​b​l​e​d'] and CurrentFOV or math.huge
                    )    
                else
                    if Script.Locals.SilentAimTarget then
                        Script.Locals.SilentAimTarget = nil
                    end
                end
            end
            
            if Input.KeyCode == TriggerBotTarget and TriggerBotConfig['S​e​l​e​c​t​i​o​n'] == 'Target' then
                SP3 = not SP3
                if SP3 then 
                    Script.Locals.TriggerbotTarget = Script:GetClosestPlayerToCursor(
                        TriggerBotConfig['M​a​x​ ​D​i​s​t​a​n​c​e'] * 100,
                        TriggerBotConfig['R​a​d​i​u​s'] * 5
                    )  
                else
                    if Script.Locals.TriggerbotTarget then
                        Script.Locals.TriggerbotTarget = nil
                    end
                end
            end
    
            if Input.KeyCode == AimAssist then
                SP2 = not SP2
                if SP2 then
                    Script.Locals.AimAssistTarget = Script:GetClosestPlayerToCursor(
                        SilentAimConfig['M​a​x​ ​D​i​s​t​a​n​c​e'] * 100,
                        shared.Saved['A​i​m​ ​B​o​t']['F​O​V']['E​n​a​b​l​e​d'] and shared.Saved['A​i​m​ ​B​o​t']['F​O​V']['S​i​z​e'] or math.huge
                    )
                else
                    if Script.Locals.AimAssistTarget then
                        Script.Locals.AimAssistTarget = nil
                    end
                end
            end
    
            if Input.KeyCode == WalkSpeed then
                Script.Locals.IsWalkSpeeding = not Script.Locals.IsWalkSpeeding
            end
    
            if Input.KeyCode == DoubleTap then
                Script.Locals.IsDoubleTapping = not Script.Locals.IsDoubleTapping
            end
    
    
            local triggerConfig = shared.Saved['T​r​i​g​g​e​r​ ​B​o​t']
            local isMouseInput = triggerConfig['A​c​t​i​v​a​t​i​o​n']['M​o​d​e'] == 'Mouse'
            local isKeyboardInput = triggerConfig['A​c​t​i​v​a​t​i​o​n']['M​o​d​e'] == 'Keybind'
            local toggleKey = shared.Saved['G​e​n​e​r​a​l​']['​H​o​t​k​e​y​s​']['T​r​i​g​g​e​r​ ​B​o​t']
            local success, keyCode = pcall(function()
                return Enum.KeyCode[toggleKey:upper()]
            end)
    
            if isMouseInput and table.find({"MouseButton1", "MouseButton2"}, toggleKey) and Input.UserInputType == Enum.UserInputType[toggleKey] then
                if triggerConfig['A​c​t​i​v​a​t​i​o​n']['T​y​p​e'] == "Toggle" then
                    Script.Locals.TriggerState = not Script.Locals.TriggerState
                elseif triggerConfig['A​c​t​i​v​a​t​i​o​n']['T​y​p​e'] == "Hold" then
                    Script.Locals.TriggerState = true
                end
            elseif isKeyboardInput and success and table.find(Enum.KeyCode:GetEnumItems(), keyCode) and Input.KeyCode == keyCode then
                if triggerConfig['A​c​t​i​v​a​t​i​o​n']['T​y​p​e'] == "Toggle" then
                    Script.Locals.TriggerState = not Script.Locals.TriggerState
                elseif triggerConfig['A​c​t​i​v​a​t​i​o​n']['T​y​p​e'] == "Hold" then
                    Script.Locals.TriggerState = true
                end
            end

            if Input.KeyCode == Enum.KeyCode.LeftControl then
                CanTriggerbotShoot = false
            end

            if shared.Saved['G​a​m​e ​U​t​i​l​i​t​i​e​s']['I​n​v​e​n​t​o​r​y ​H​e​l​p​e​r']['E​n​a​b​l​e​d'] and Input.KeyCode == Enum.KeyCode[shared.Saved['G​e​n​e​r​a​l​']['​H​o​t​k​e​y​s​']['I​n​v​e​n​t​o​r​y ​S​o​r​t​e​r']:upper()] then
                local GunOrder = shared.Saved['G​a​m​e ​U​t​i​l​i​t​i​e​s']['I​n​v​e​n​t​o​r​y ​H​e​l​p​e​r']['O​r​d​e​r']
                local BackPack = Self:FindFirstChildOfClass("Backpack")
                if not BackPack then
                    return
                end
                local CurrentTime = tick()
                local Order_V = 10 - #GunOrder
                local Cooldown = true
                --
                if Cooldown then
                    local FakeFolder = Instance.new('Folder')
                    FakeFolder.Name = 'FakeFolder'
                    FakeFolder.Parent = Workspace
                    local FakeFolderID = Workspace.FakeFolder
                    --
                    for _, v in pairs(BackPack:GetChildren()) do
                        if v:IsA('Tool') then
                            v.Parent = Workspace.FakeFolder
                        end
                    end
                    --
                    for _, v in pairs(GunOrder) do
                        local Gun = FakeFolderID:FindFirstChild(v)
                        if Gun then
                            Gun.Parent = BackPack
                            wait(0.05)
                        else
                            Order_V = Order_V + 1
                        end
                    end
                    --
                    for _, v in pairs(FakeFolderID:GetChildren()) do
                        if v:FindFirstChild('Drink') or v:FindFirstChild('Eat') then
                            v.Parent = BackPack
                            Order_V = Order_V - 1
                        end
                    end
                    --
                    if Order_V > 0 then
                        for i = 1, Order_V do
                            local Tool = Instance.new('Tool')
                            Tool.Name = ''
                            Tool.ToolTip = 'PlaceHolder'
                            Tool.GripPos = Vector3.new(0, 1, 0)
                            Tool.RequiresHandle = false
                            Tool.Parent = BackPack
                        end
                    end
                    --
                    for _, v in pairs(FakeFolderID:GetChildren()) do
                        if v:IsA('Tool') then
                            v.Parent = BackPack
                        end
                    end
                    --
                    for _, v in pairs(BackPack:GetChildren()) do
                        if v.Name == '' then
                            v:Destroy()
                        end
                    end
                    --
                    FakeFolder:Destroy()
                end
            end
        end)
    
        RBXConnection(UserInputService.InputEnded, function(Input, Processed)
            if shared.Saved['C​o​n​d​i​t​i​o​n​s']['C​h​a​t​ ​F​o​c​u​s​e​d'] and UserInputService:GetFocusedTextBox() then return end
            local triggerConfig = shared.Saved['T​r​i​g​g​e​r​ ​B​o​t']
            local isMouseInput = triggerConfig['A​c​t​i​v​a​t​i​o​n']['M​o​d​e'] == 'Mouse'
            local isKeyboardInput = triggerConfig['A​c​t​i​v​a​t​i​o​n']['M​o​d​e'] == 'Keybind'
            local toggleKey = shared.Saved['G​e​n​e​r​a​l​']['​H​o​t​k​e​y​s​']['T​r​i​g​g​e​r​ ​B​o​t']
            local success, keyCode = pcall(function()
                return Enum.KeyCode[toggleKey:upper()]
            end)
    
            if triggerConfig['A​c​t​i​v​a​t​i​o​n']['T​y​p​e'] == "Hold" then
                
                if isMouseInput and table.find({"MouseButton1", "MouseButton2"}, toggleKey) and Input.UserInputType == Enum.UserInputType[toggleKey] then
                    Script.Locals.TriggerState = false
                elseif isKeyboardInput and success and table.find(Enum.KeyCode:GetEnumItems(), keyCode) and Input.KeyCode == keyCode then
                    Script.Locals.TriggerState = false
                end
            end

            if Input.KeyCode == Enum.KeyCode.LeftControl then
                CanTriggerbotShoot = true
            end
        end)
        RBXConnection(RunService.PreRender, LPH_NO_VIRTUALIZE(function()
            if SilentAimConfig['S​e​l​e​c​t​i​o​n'] == 'Automatic' then
                Script.Locals.SilentAimTarget = Script:GetClosestPlayerToCursor(
                    SilentAimConfig['M​a​x​ ​D​i​s​t​a​n​c​e'] * 100,
                    SilentAimConfig['F​O​V']['Hit Scan']
                )    
            end
    
            if TriggerBotConfig['S​e​l​e​c​t​i​o​n'] == 'Automatic' then
                Script.Locals.TriggerbotTarget = Script:GetClosestPlayerToCursor(
                    TriggerBotConfig['M​a​x​ ​D​i​s​t​a​n​c​e'] * 100,
                    TriggerBotConfig['R​a​d​i​u​s'] * 5
                ) 
            end
            
            if Script.Locals.SilentAimTarget and Script.Locals.SilentAimTarget.Character then
                Script.Locals.HitPosition = Script:GetHitPosition('Silent')
            end
            Script:ShouldShoot(Script.Locals.SilentAimTarget)
            if Script.Locals.TriggerbotTarget and Script.Locals.TriggerbotTarget.Character then
                Script.Locals.HitTrigger = Script:GetClosestPartToCursor(Script.Locals.TriggerbotTarget.Character)
            end
    
    
            ThreadFunction(Script.AimAssist)
            ThreadFunction(Script.Triggerbot)
            ThreadFunction(Script.Physics)
            UpdateDrawings()
            AutomatedPrediction()
        end))
    end
