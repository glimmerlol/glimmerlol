local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
 
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
