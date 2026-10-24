
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

------------------------------------------------------------------------
-- CONFIG
------------------------------------------------------------------------

local function getConfig()
    shared.glimmer = shared.glimmer or {}

    local config = shared.glimmer

    config['General'] = config['General'] or {}
    config['General']['Keybinds'] =
        config['General']['Keybinds'] or {}

    config['General']['Display Keybinds'] =
        config['General']['Display Keybinds'] or {}

    config['Skin Changer'] = config['Skin Changer'] or {}

    return config
end

------------------------------------------------------------------------
-- CLEANUP
------------------------------------------------------------------------

local function cleanup()
    pcall(function()
        RunService:UnbindFromRenderStep("GlimmerSkinChanger")
    end)

    if shared.glimmer_display
        and shared.glimmer_display.Destroy then
        pcall(function()
            shared.glimmer_display.Destroy()
        end)
    end

    shared.glimmer_display = nil

    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    if playerGui then
        local oldGui = playerGui:FindFirstChild("GlimmerDisplay")
        if oldGui then
            oldGui:Destroy()
        end
    end
end

------------------------------------------------------------------------
-- SKIN CHANGER
------------------------------------------------------------------------

local function SkinChanger()
    local cfg = getConfig()['Skin Changer']

    if not cfg['Enabled'] then
        return
    end

    -- Original Galaxy texture IDs supplied in your script.
    -- Restore your other original skin tables here to support them.
    local Skins = {
        Galaxy = {
            ['[SilencerAR]'] = 9402007158,
            ['[SMG]'] = 9387614760,
            ['[TacticalShotgun]'] = 9402279010,
            ['[AK47]'] = 9402132929,
            ['[AUG]'] = 9401832956,
            ['[AR]'] = 9402007158,
            ['[Glock]'] = 9401709916,
            ['[Shotgun]'] = 9387933478,
            ['[Silencer]'] = 9401709916,
            ['[P90]'] = 9399887933,
            ['[Revolver]'] = 9370936730,
            ['[RPG]'] = 9399842353,
            ['[LMG]'] = 9400170566,
            ['[Flamethrower]'] = 9400558000,
            ['[DrumGun]'] = 9381577172,
            ['[Double-Barrel SG]'] = 9401441647,
        },

        Inferno = {
            ['[SilencerAR]'] = 9401972413,
            ['[SMG]'] = 9387593777,
            ['[TacticalShotgun]'] = 9402244359,
            ['[AK47]'] = 9402094255,
            ['[AUG]'] = 9401802930,
            ['[AR]'] = 9401972413,
            ['[Glock]'] = 9401670081,
            ['[Shotgun]'] = 9387831940,
            ['[Silencer]'] = 9401670081,
            ['[P90]'] = 9399878713,
            ['[Revolver]'] = 9370404463,
            ['[RPG]'] = 9399831924,
            ['[LMG]'] = 9400160302,
            ['[Flamethrower]'] = 9400503673,
            ['[DrumGun]'] = 9381496666,
            ['[Double-Barrel SG]'] = 9401416743,
        },

        Matrix = {
            ['[SilencerAR]'] = 9402023983,
            ['[SMG]'] = 9387681455,
            ['[TacticalShotgun]'] = 9402295362,
            ['[AK47]'] = 9402147406,
            ['[AUG]'] = 9401855319,
            ['[AR]'] = 9402023983,
            ['[Glock]'] = 9401727978,
            ['[Shotgun]'] = 9387945198,
            ['[Silencer]'] = 9401727978,
            ['[P90]'] = 9399894480,
            ['[Revolver]'] = 9380928144,
            ['[RPG]'] = 9399850204,
            ['[LMG]'] = 9400178599,
            ['[Flamethrower]'] = 9400582867,
            ['[DrumGun]'] = 9381601709,
            ['[Double-Barrel SG]'] = 9401457713,
        },

        RedDeath = {
            ['[SilencerAR]'] = 8213168054,
            ['[SMG]'] = 8199875638,
            ['[TacticalShotgun]'] = 9203641766,
            ['[AK47]'] = 8213572965,
            ['[AUG]'] = 8212802637,
            ['[AR]'] = 8213168054,
            ['[Glock]'] = 8212637463,
            ['[Shotgun]'] = 8200647420,
            ['[Silencer]'] = 8212637463,
            ['[P90]'] = 8205381104,
            ['[Revolver]'] = 8173928665,
            ['[RPG]'] = 8201055935,
            ['[LMG]'] = 8205713344,
            ['[Flamethrower]'] = 8206707126,
            ['[DrumGun]'] = 8186385983,
            ['[Double-Barrel SG]'] = 8212384179,
        },

        GoldGlory = {
            ['[SilencerAR]'] = 8213175568,
            ['[SMG]'] = 8199883519,
            ['[TacticalShotgun]'] = 9203647967,
            ['[AK47]'] = 8213606202,
            ['[AUG]'] = 8212809463,
            ['[AR]'] = 8213175568,
            ['[Glock]'] = 8212667115,
            ['[Shotgun]'] = 8200657428,
            ['[Silencer]'] = 8212667115,
            ['[P90]'] = 8205397990,
            ['[Revolver]'] = 8173955378,
            ['[RPG]'] = 8201059812,
            ['[LMG]'] = 8205719479,
            ['[Flamethrower]'] = 8208010648,
            ['[DrumGun]'] = 8186168230,
            ['[Double-Barrel SG]'] = 8212394280,
        },
    }

    RunService:BindToRenderStep(
        "GlimmerSkinChanger",
        Enum.RenderPriority.Last.Value,
        function()
            local character = player.Character
            if not character then
                return
            end

            for weapon, skinName in pairs(cfg['Weapons'] or {}) do
                local tool = character:FindFirstChild(weapon)
                local skin = Skins[skinName]
                local textureId = skin and skin[weapon]

                if tool and textureId then
                    local part = tool:FindFirstChild("Default")

                    if part and part:IsA("MeshPart") then
                        local texture =
                            "rbxassetid://" .. tostring(textureId)

                        if part.TextureID ~= texture then
                            part.TextureID = texture
                        end
                    end
                end
            end
        end
    )
end

------------------------------------------------------------------------
-- DISPLAY KEYBINDS HUD
------------------------------------------------------------------------

local function DisplayKeybinds()
    local general = getConfig()['General']
    local disp = general['Display Keybinds']
    local binds = general['Keybinds']

    if not (disp['Enabled'] and binds) then
        return
    end

    -- Ragebot and Rapid Fire are deliberately excluded.
    local features = {
        'Silent Aim',
        'Aim Assist',
        'Trigger Bot',
        'Speed',
        'ESP',
    }

    local state = {}
    for _, name in ipairs(features) do
        state[name] = false
    end

    local playerGui = player:WaitForChild("PlayerGui")

    local gui = Instance.new("ScreenGui")
    gui.Name = "GlimmerDisplay"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 100
    gui.Parent = playerGui

    local main = Instance.new("Frame")
    main.Name = "Panel"
    main.AnchorPoint = Vector2.new(0.5, 0)
    main.Position = UDim2.new(0.5, 0, 0, 20)
    main.Size = UDim2.fromOffset(250, 0)
    main.AutomaticSize = Enum.AutomaticSize.Y
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    main.BorderSizePixel = 0
    main.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = main

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(110, 38, 50)
    stroke.Thickness = 1
    stroke.Transparency = 0.15
    stroke.Parent = main

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = main

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = main

    local function round(instance, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius)
        c.Parent = instance
    end

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.LayoutOrder = 1
    title.Size = UDim2.new(1, 0, 0, 25)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.Text = disp['Title'] or "Glimmerlol"
    title.TextColor3 =
        disp['Glimmer Title'] or Color3.fromRGB(255, 55, 70)
    title.TextSize = 18
    title.Parent = main

    local subtitle = Instance.new("TextLabel")
    subtitle.LayoutOrder = 2
    subtitle.Size = UDim2.new(1, 0, 0, 13)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.Text = "FEATURE STATUS"
    subtitle.TextColor3 = Color3.fromRGB(135, 135, 150)
    subtitle.TextSize = 9
    subtitle.Parent = main

    local accent = Instance.new("Frame")
    accent.LayoutOrder = 3
    accent.Size = UDim2.new(1, 0, 0, 2)
    accent.BackgroundColor3 = Color3.fromRGB(255, 55, 75)
    accent.BorderSizePixel = 0
    accent.Parent = main
    round(accent, 2)

    local labels = {}

    for index, name in ipairs(features) do
        local row = Instance.new("Frame")
        row.Name = name:gsub("%s+", "")
        row.LayoutOrder = index + 3
        row.Size = UDim2.new(1, 0, 0, 33)
        row.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
        row.BorderSizePixel = 0
        row.Parent = main
        round(row, 7)

        local feature = Instance.new("TextLabel")
        feature.BackgroundTransparency = 1
        feature.Position = UDim2.new(0, 9, 0, 0)
        feature.Size = UDim2.new(1, -75, 1, 0)
        feature.Font = Enum.Font.GothamMedium
        feature.Text = name
        feature.TextColor3 = Color3.fromRGB(230, 230, 238)
        feature.TextSize = 12
        feature.TextXAlignment = Enum.TextXAlignment.Left
        feature.Parent = row

        local status = Instance.new("TextLabel")
        status.Name = "Status"
        status.AnchorPoint = Vector2.new(1, 0.5)
        status.Position = UDim2.new(1, -7, 0.5, 0)
        status.Size = UDim2.fromOffset(48, 21)
        status.BackgroundColor3 = Color3.fromRGB(66, 33, 40)
        status.BorderSizePixel = 0
        status.Font = Enum.Font.GothamBold
        status.Text = "OFF"
        status.TextColor3 = Color3.fromRGB(255, 105, 120)
        status.TextSize = 10
        status.Parent = row
        round(status, 5)

        labels[name] = {
            feature = feature,
            status = status,
        }
    end

    local function refresh()
        for _, name in ipairs(features) do
            local item = labels[name]
            local enabled = state[name]

            item.status.Text = enabled and "ON" or "OFF"
            item.status.TextColor3 = enabled
                and Color3.fromRGB(105, 255, 165)
                or Color3.fromRGB(255, 105, 120)

            item.status.BackgroundColor3 = enabled
                and Color3.fromRGB(25, 68, 46)
                or Color3.fromRGB(66, 33, 40)
        end
    end

    local connection = UserInputService.InputBegan:Connect(
        function(input, processed)
            if processed then
                return
            end

            if input.UserInputType ~= Enum.UserInputType.Keyboard then
                return
            end

            for _, name in ipairs(features) do
                local key = binds[name]

                if key and input.KeyCode.Name == key then
                    state[name] = not state[name]
                end
            end

            refresh()
        end
    )

    refresh()

    shared.glimmer_display = {
        State = state,

        SetState = function(name, enabled)
            if state[name] ~= nil then
                state[name] = enabled
                refresh()
            end
        end,

        Destroy = function()
            connection:Disconnect()
            gui:Destroy()
        end,
    }
end

------------------------------------------------------------------------
-- INITIALIZE
------------------------------------------------------------------------

cleanup()
SkinChanger()
DisplayKeybinds()
