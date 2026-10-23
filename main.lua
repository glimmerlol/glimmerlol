local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
 
------------------------------------------------------------------------
-- SKIN CHANGER
------------------------------------------------------------------------
local function SkinChanger()
    local cfg = shared.glimmer and shared.glimmer['Skin Changer']
 
    local function asset(id)
        return "rbxassetid://" .. tostring(id)
    end
 
    -- Skins[skinName][weaponName] = texture id
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
 
        -- Add IDs for the new skins here, for example:
        -- ['Love Kukri'] = { ['[Knife]'] = 0000000000 },
        -- ['Balloon']    = { ['[Deagle]'] = 0000000000 },
        -- ['Grumpy']     = { ['[Rifle]']  = 0000000000 },
    }
 
    -- Always clear any previous bind so toggling Enabled works on re-execute
    pcall(function()
        RunService:UnbindFromRenderStep("Glimmer Skin Changer")
    end)
 
    if not (cfg and cfg['Enabled']) then
        return
    end
 
    RunService:BindToRenderStep("Glimmer Skin Changer", 0, function()
        local char = player.Character
        if not char then return end
 
        for weapon, skin in pairs(cfg['Weapons'] or {}) do
            local tool = char:FindFirstChild(weapon)
            local id = Skins[skin] and Skins[skin][weapon]
            if tool and id then
                local part = tool:FindFirstChild("Default")
                if part then
                    local tex = asset(id)
                    if part.TextureID ~= tex then
                        part.TextureID = tex
                    end
                end
            end
        end
    end)
end
 
------------------------------------------------------------------------
-- DISPLAY KEYBINDS (top-of-screen HUD)
------------------------------------------------------------------------
local function DisplayKeybinds()
    local general = shared.glimmer and shared.glimmer['General']
    local disp = general and general['Display Keybinds']
    local binds = general and general['Keybinds']
 
    -- Remove old HUD if the script is re-executed
    if shared.glimmer_display and shared.glimmer_display.Destroy then
        pcall(shared.glimmer_display.Destroy)
    end
 
    if not (disp and disp['Enabled'] and binds) then
        return
    end
 
    local ON_COLOR = Color3.fromRGB(0, 255, 0)
    local OFF_COLOR = disp['Key Color'] or Color3.fromRGB(255, 0, 0)
    local TITLE_COLOR = disp['Glimmer Title'] or Color3.fromRGB(255, 50, 50)
    local TARGET_COLOR = disp['Target Color'] or Color3.fromRGB(255, 80, 80)
 
    -- Which features show in the list (in this order)
    local Features = { 'Silent Aim', 'Aim Assist', 'Trigger Bot', 'Ragebot', 'Speed', 'ESP' }
 
    -- Your other scripts read/write this: shared.glimmer_display.State['Silent Aim']
    local State = {}
    for _, name in ipairs(Features) do
        State[name] = false
    end
 
    -- GUI ----------------------------------------------------------------
    local parent = (gethui and gethui()) or game:GetService("CoreGui")
 
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
 
    local order = 0
    local function makeLabel()
        order += 1
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Size = UDim2.new(1, 0, 0, 16)
        l.Font = Enum.Font.GothamBold
        l.TextSize = 14
        l.TextColor3 = Color3.new(1, 1, 1)
        l.TextStrokeTransparency = 0.4
        l.RichText = true
        l.LayoutOrder = order
        l.Text = ""
        l.Parent = holder
        return l
    end
 
    local function color(c)
        return "#" .. c:ToHex()
    end
 
    local titleLabel = makeLabel()
    titleLabel.Text = string.format('<font color="%s">%s</font>', color(TITLE_COLOR), disp['Title'] or 'glimmer')
 
    local featureLabels = {}
    for _, name in ipairs(Features) do
        featureLabels[name] = makeLabel()
    end
 
    local targetLabel = makeLabel()
    local rangeLabel = makeLabel()
 
    local function refresh()
        for name, label in pairs(featureLabels) do
            local on = State[name]
            local key = binds[name] or "?"
            if disp['Type'] == '2' then
                label.Text = string.format('[%s] %s - <font color="%s">%s</font>',
                    key, name, color(on and ON_COLOR or OFF_COLOR), on and "on" or "off")
            else
                label.Text = string.format('%s - <font color="%s">[%s]</font>',
                    name:lower(), color(on and ON_COLOR or OFF_COLOR), on and "on" or "off")
            end
        end
    end
    refresh()
 
    -- Keybinds -----------------------------------------------------------
    local conn = UserInputService.InputBegan:Connect(function(input, processed)
        if processed or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        for _, name in ipairs(Features) do
            if binds[name] and input.KeyCode.Name == binds[name] then
                State[name] = not State[name]
            end
        end
        refresh()
    end)
 
    -- Public API ---------------------------------------------------------
    local API = { State = State }
 
    -- Call this from your own code when you have a target
    function API.SetTarget(name, health, maxHealth, studs)
        if not name then
            targetLabel.Text = ""
            rangeLabel.Text = ""
            return
        end
        targetLabel.Text = string.format('target - <font color="%s">%s</font> %d/%d',
            color(TARGET_COLOR), name, health or 0, maxHealth or 100)
        rangeLabel.Text = string.format('range - %d studs', studs or 0)
    end
 
    function API.Destroy()
        conn:Disconnect()
        gui:Destroy()
    end
 
    shared.glimmer_display = API
end
 
------------------------------------------------------------------------
SkinChanger()
DisplayKeybinds()
 
