
-- GLIMMER | Minimal HUD
-- Visual display only — no gameplay automation

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- Clean up an earlier copy
pcall(function()
    local parent = (gethui and gethui()) or CoreGui
    local old = parent:FindFirstChild("GlimmerHUD")
    if old then
        old:Destroy()
    end
end)

local parent = (gethui and gethui()) or CoreGui

local gui = Instance.new("ScreenGui")
gui.Name = "GlimmerHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 20
gui.Parent = parent

local holder = Instance.new("Frame")
holder.Name = "Holder"
holder.AnchorPoint = Vector2.new(0.5, 0)
holder.Position = UDim2.new(0.5, 0, 0, 12)
holder.Size = UDim2.fromOffset(360, 0)
holder.AutomaticSize = Enum.AutomaticSize.Y
holder.BackgroundTransparency = 1
holder.Parent = gui

local layout = Instance.new("UIListLayout")
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 0)
layout.Parent = holder

local function makeLine(order, leftText, rightText, color)
    local line = Instance.new("TextLabel")
    line.Name = "Line" .. order
    line.LayoutOrder = order
    line.Size = UDim2.new(1, 0, 0, 17)
    line.BackgroundTransparency = 1
    line.Font = Enum.Font.GothamBold
    line.TextSize = 12
    line.TextColor3 = Color3.fromRGB(235, 235, 235)
    line.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    line.TextStrokeTransparency = 0.2
    line.RichText = true
    line.TextXAlignment = Enum.TextXAlignment.Center
    line.Text = string.format(
        '%s = <font color="#%s">%s</font>',
        leftText,
        color,
        rightText
    )
    line.Parent = holder
    return line
end

local green = "55FF66"
local yellow = "FFD966"
local red = "FF6666"

local labels = {
    silent = makeLine(1, "silent aimbot", "false", red),
    camera = makeLine(2, "camera aimbot", "false", red),
    trigger = makeLine(3, "trigger bot", "false", red),
    target = makeLine(4, "target", "None", yellow),
    range = makeLine(5, "range", "-- studs", green),
    footer = makeLine(6, "", "thanks for proper fps 🙂", yellow),
}

-- Update visual status labels
local function setStatus(label, name, enabled)
    if not labels[label] then return end

    local value = enabled and "true" or "false"
    local color = enabled and green or red

    labels[label].Text = string.format(
        '%s = <font color="#%s">%s</font>',
        name,
        color,
        value
    )
end

-- Public visual controls for other UI code
local api = {}

function api.SetStatus(name, enabled)
    if name == "Silent Aim" then
        setStatus("silent", "silent aimbot", enabled)
    elseif name == "Camera Aim" then
        setStatus("camera", "camera aimbot", enabled)
    elseif name == "Trigger Bot" then
        setStatus("trigger", "trigger bot", enabled)
    end
end

function api.SetTarget(name, distance)
    labels.target.Text = string.format(
        'target = <font color="#%s">%s</font>',
        yellow,
        tostring(name or "None")
    )

    labels.range.Text = string.format(
        'range = <font color="#%s">%s</font>',
        green,
        distance and (tostring(math.floor(distance)) .. " studs")
            or "-- studs"
    )
end

function api.Destroy()
    if gui then
        gui:Destroy()
    end
end

shared.glimmer_hud = api
