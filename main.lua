
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

------------------------------------------------------------------------
-- CONFIG VALIDATION
------------------------------------------------------------------------
local function getConfig()
    shared.glimmer = shared.glimmer or {}

    shared.glimmer['General'] =
        shared.glimmer['General'] or {}

    shared.glimmer['Skin Changer'] =
        shared.glimmer['Skin Changer'] or {}

    return shared.glimmer
end

------------------------------------------------------------------------
-- SKIN CHANGER
------------------------------------------------------------------------
local function SkinChanger()
    local cfg = getConfig()['Skin Changer']

    pcall(function()
        RunService:UnbindFromRenderStep("GlimmerSkinChanger")
    end)

    if not cfg['Enabled'] then
        return
    end

    -- Texture IDs from your original main.lua.
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

        -- Add the original Inferno, Matrix, RedDeath,
        -- and GoldGlory tables here if you still use them.
    }

    RunService:BindToRenderStep(
        "GlimmerSkinChanger",
        Enum.RenderPriority.Last.Value,
        function()
            local character = player.Character
            if not character then return end

            for weapon, skin in pairs(cfg['Weapons'] or {}) do
                local tool = character:FindFirstChild(weapon)
                local skinData = Skins[skin]
                local textureId = skinData and skinData[weapon]

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

    if shared.glimmer_display
        and shared.glimmer_display.Destroy then
        pcall(function()
            shared.glimmer_display.Destroy()
        end)
    end

    if not (disp and disp['Enabled'] and binds) then
        return
    end

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

    local parent
    if gethui then
        local ok, result = pcall(gethui)
        if ok then
            parent = result
        end
    end

    parent = parent or player:WaitForChild("PlayerGui")

    local oldGui = parent:FindFirstChild("GlimmerDisplay")
    if oldGui then
        oldGui:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "GlimmerDisplay"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 20
    gui.Parent = parent

    local main = Instance.new("Frame")
    main.Name = "Container"
    main.AnchorPoint = Vector2.new(0.5, 0)
    main.Position = UDim2.new(0.5, 0, 0, 16)
    main.Size = UDim2.new(0, 235, 0, 0)
    main.AutomaticSize = Enum.AutomaticSize.Y
    main.BackgroundColor3 = Color3.fromRGB(19, 19, 24)
    main.BackgroundTransparency = 0.05
    main.BorderSizePixel = 0
    main.Parent = gui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = main

    local outline = Instance.new("UIStroke")
    outline.Color = Color3.fromRGB(95, 37, 48)
    outline.Thickness = 1
    outline.Transparency = 0.1
    outline.Parent = main

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = main

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = main

    local function rounded(instance, radius)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, radius)
        corner.Parent = instance
    end

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 23)
    title.LayoutOrder = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Text = disp['Title'] or "Glimmerlol"
    title.TextColor3 =
        disp['Glimmer Title'] or Color3.fromRGB(255, 55, 70)
    title.Parent = main

    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Size = UDim2.new(1, 0, 0, 2)
    accent.LayoutOrder = 2
    accent.BackgroundColor3 = Color3.fromRGB(255, 55, 70)
    accent.BorderSizePixel = 0
    accent.Parent = main
    rounded(accent, 2)

    local labels = {}

    for index, name in ipairs(features) do
        local row = Instance.new("Frame")
        row.Name = name:gsub("%s+", "")
        row.Size = UDim2.new(1, 0, 0, 24)
        row.LayoutOrder = index + 2
        row.BackgroundColor3 = Color3.fromRGB(30, 30, 37)
        row.BorderSizePixel = 0
        row.Parent = main
        rounded(row, 5)

        local featureLabel = Instance.new("TextLabel")
        featureLabel.BackgroundTransparency = 1
        featureLabel.Position = UDim2.new(0, 8, 0, 0)
        featureLabel.Size = UDim2.new(1, -64, 1, 0)
        featureLabel.Font = Enum.Font.GothamMedium
        featureLabel.TextSize = 11
        featureLabel.TextXAlignment = Enum.TextXAlignment.Left
        featureLabel.TextColor3 = Color3.fromRGB(225, 225, 232)
        featureLabel.Text = string.lower(name)
        featureLabel.Parent = row

        local status = Instance.new("TextLabel")
        status.Name = "Status"
        status.AnchorPoint = Vector2.new(1, 0.5)
        status.Position = UDim2.new(1, -6, 0.5, 0)
        status.Size = UDim2.new(0, 43, 0, 17)
        status.BackgroundColor3 = Color3.fromRGB(67, 31, 38)
        status.BorderSizePixel = 0
        status.Font = Enum.Font.GothamBold
        status.TextSize = 10
        status.Text = "OFF"
        status.TextColor3 = Color3.fromRGB(255, 105, 115)
        status.Parent = row
        rounded(status, 4)

        labels[name] = {
            row = row,
            feature = featureLabel,
            status = status,
        }
    end

    local function refresh()
        for _, name in ipairs(features) do
            local item = labels[name]
            local enabled = state[name]

            item.status.Text = enabled and "ON" or "OFF"

            item.status.TextColor3 = enabled
                and Color3.fromRGB(105, 255, 160)
                or Color3.fromRGB(255, 105, 115)

            item.status.BackgroundColor3 = enabled
                and Color3.fromRGB(24, 67, 46)
                or Color3.fromRGB(67, 31, 38)

            item.feature.TextColor3 = enabled
                and Color3.fromRGB(255, 255, 255)
                or Color3.fromRGB(190, 190, 200)
        end
    end

    refresh()

    local connection = UserInputService.InputBegan:Connect(
        function(input, processed)
            if processed then return end
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
SkinChanger()
DisplayKeybinds()
