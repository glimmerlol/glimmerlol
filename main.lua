local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

------------------------------------------------------------------------
-- CONFIG
------------------------------------------------------------------------
local function getConfig()
    shared.glimmer = shared.glimmer or {}

    shared.glimmer['General'] =
        shared.glimmer['General'] or {}

    shared.glimmer['Skin Changer'] =
        shared.glimmer['Skin Changer'] or {}

    shared.glimmer['Rapid Fire'] =
        shared.glimmer['Rapid Fire'] or {
            ['Enabled'] = true,
            ['Delay'] = 0.1,
            ['Keybind'] = 'B',
        }

    return shared.glimmer
end

------------------------------------------------------------------------
-- SKIN CHANGER
------------------------------------------------------------------------
local function SkinChanger()
    local cfg = getConfig()['Skin Changer']

    pcall(function()
        RunService:UnbindFromRenderStep("Glimmer Skin Changer")
    end)

    if not cfg['Enabled'] then
        return
    end

    -- Keep your existing Skins table here, unchanged.
    -- Example structure:
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
    }

    RunService:BindToRenderStep(
        "Glimmer Skin Changer",
        0,
        function()
            local character = player.Character
            if not character then return end

            for weapon, skin in pairs(cfg['Weapons'] or {}) do
                local tool = character:FindFirstChild(weapon)
                local skinTable = Skins[skin]
                local id = skinTable and skinTable[weapon]

                if tool and id then
                    local part = tool:FindFirstChild("Default")
                    if part and part:IsA("MeshPart") then
                        local texture = "rbxassetid://" .. tostring(id)

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
-- DISPLAY KEYBINDS
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
        'Ragebot',
        'Speed',
        'ESP',
    }

    local state = {}
    for _, name in ipairs(features) do
        state[name] = false
    end

    local parent = game:GetService("CoreGui")

    local gui = Instance.new("ScreenGui")
    gui.Name = "GlimmerDisplay"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = parent

    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1
    holder.AnchorPoint = Vector2.new(0.5, 0)
    holder.Position = UDim2.new(0.5, 0, 0, 10)
    holder.Size = UDim2.new(0, 320, 0, 0)
    holder.AutomaticSize = Enum.AutomaticSize.Y
    holder.Parent = gui

    local layout = Instance.new("UIListLayout")
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 1)
    layout.Parent = holder

    local function makeLabel()
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 0, 16)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0.4
        label.RichText = true
        label.Parent = holder
        return label
    end

    local function color(c)
        return "#" .. c:ToHex()
    end

    local title = makeLabel()
    title.Text = string.format(
        '<font color="%s">%s</font>',
        color(disp['Glimmer Title'] or Color3.fromRGB(255, 50, 50)),
        disp['Title'] or 'Glimmerlol'
    )

    local labels = {}
    for _, name in ipairs(features) do
        labels[name] = makeLabel()
    end

    local function refresh()
        for name, label in pairs(labels) do
            local enabled = state[name]
            local key = binds[name] or '?'
            local c = enabled
                and Color3.fromRGB(0, 255, 0)
                or (disp['Key Color'] or Color3.fromRGB(255, 0, 0))

            if disp['Type'] == '2' then
                label.Text = string.format(
                    '[%s] %s - <font color="%s">%s</font>',
                    key,
                    name,
                    color(c),
                    enabled and 'on' or 'off'
                )
            else
                label.Text = string.format(
                    '%s - <font color="%s">[%s]</font>',
                    name:lower(),
                    color(c),
                    enabled and 'on' or 'off'
                )
            end
        end
    end

    refresh()

    local connection = UserInputService.InputBegan:Connect(
        function(input, processed)
            if processed
                or input.UserInputType ~= Enum.UserInputType.Keyboard then
                return
            end

            for _, name in ipairs(features) do
                if binds[name]
                    and input.KeyCode.Name == binds[name] then
                    state[name] = not state[name]
                end
            end

            refresh()
        end
    )

    shared.glimmer_display = {
        State = state,

        Destroy = function()
            connection:Disconnect()
            gui:Destroy()
        end,
    }
end

------------------------------------------------------------------------
-- RAPID FIRE
------------------------------------------------------------------------
local function RapidFire()
    local cfg = getConfig()['Rapid Fire']

    if not cfg['Enabled'] then
        return
    end

    local keyCode = Enum.KeyCode[cfg['Keybind'] or 'B']
    if not keyCode then
        warn("Rapid Fire: invalid keybind")
        return
    end

    local enabled = false
    local mouseHeld = false

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end

        if input.KeyCode == keyCode then
            enabled = not enabled
            print("Rapid Fire:", enabled and "ON" or "OFF")
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            mouseHeld = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            mouseHeld = false
        end
    end)

    player.CharacterAdded:Connect(function()
        mouseHeld = false
    end)

    task.spawn(function()
        while true do
            task.wait(math.max(tonumber(cfg['Delay']) or 0.1, 0.1))

            if enabled and mouseHeld then
                local character = player.Character
                local tool = character
                    and character:FindFirstChildOfClass("Tool")

                if tool and tool:FindFirstChild("Ammo") then
                    tool:Activate()
                end
            end
        end
    end)
end

------------------------------------------------------------------------
-- INITIALIZE
------------------------------------------------------------------------
SkinChanger()
DisplayKeybinds()
RapidFire()
