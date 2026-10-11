local addonName, ns = ...

local DEFAULT_X = 0
local DEFAULT_Y = 0
local DEFAULT_SCALE = 100
local DEFAULT_ANCHOR = "bottomright"
local DEFAULT_ORIGIN = "bottomright"
local DEFAULT_FLIP = "off"
local DEFAULT_FADE = 0
local FADE_TIME = 1
local MAX_FADE = 5
local DEFAULT_CURSOR = 32
-- The hotspot is the tip. The visible tail ends about halfway across the texture,
-- so a 32x32 cursor spans about 16 pixels from the tip to the opposite corner.
local CURSOR_VISIBLE = 0.5
local CURSOR_BY_CVAR = {
    [0] = 32,
    [1] = 48,
    [2] = 64,
    [3] = 96,
    [4] = 128,
}
local MIN_SCALE = 10
local MAX_SCALE = 500

-- The named anchor is where the tooltip sits relative to the cursor.
-- The point is the tooltip corner or edge that stays on the cursor.
local ANCHOR_POINT = {
    topleft = "BOTTOMRIGHT",
    topmiddle = "BOTTOM",
    topright = "BOTTOMLEFT",
    middleleft = "RIGHT",
    center = "CENTER",
    middleright = "LEFT",
    bottomleft = "TOPRIGHT",
    bottommiddle = "TOP",
    bottomright = "TOPLEFT",
}

local ANCHOR_LABEL = {
    topleft = "top left",
    topmiddle = "top middle",
    topright = "top right",
    middleleft = "middle left",
    center = "center",
    middleright = "middle right",
    bottomleft = "bottom left",
    bottommiddle = "bottom middle",
    bottomright = "bottom right",
}

local ANCHOR_ALIAS = {
    topleft = "topleft",
    tl = "topleft",
    topmiddle = "topmiddle",
    top = "topmiddle",
    tm = "topmiddle",
    topright = "topright",
    tr = "topright",
    middleleft = "middleleft",
    left = "middleleft",
    ml = "middleleft",
    center = "center",
    middle = "center",
    c = "center",
    middleright = "middleright",
    right = "middleright",
    mr = "middleright",
    bottomleft = "bottomleft",
    bl = "bottomleft",
    bottommiddle = "bottommiddle",
    bottom = "bottommiddle",
    bm = "bottommiddle",
    bottomright = "bottomright",
    br = "bottomright",
}

local X_MIRROR = {
    topleft = "topright",
    topright = "topleft",
    middleleft = "middleright",
    middleright = "middleleft",
    bottomleft = "bottomright",
    bottomright = "bottomleft",
}

local Y_MIRROR = {
    topleft = "bottomleft",
    bottomleft = "topleft",
    topmiddle = "bottommiddle",
    bottommiddle = "topmiddle",
    topright = "bottomright",
    bottomright = "topright",
}

local FLIP_MODE = {
    x = true,
    y = true,
    xy = true,
    off = true,
}

-- Fraction of the cursor graphic, measured from the tip at the top-left.
local ORIGIN_FRACTION = {
    topleft = { 0, 0 },
    topmiddle = { 0.5, 0 },
    topright = { 1, 0 },
    middleleft = { 0, 0.5 },
    center = { 0.5, 0.5 },
    middleright = { 1, 0.5 },
    bottomleft = { 0, 1 },
    bottommiddle = { 0.5, 1 },
    bottomright = { 1, 1 },
}

ns.db = {
    enabled = true,
    offsetX = DEFAULT_X,
    offsetY = DEFAULT_Y,
    scale = DEFAULT_SCALE,
    anchor = DEFAULT_ANCHOR,
    origin = DEFAULT_ORIGIN,
    flip = DEFAULT_FLIP,
    fade = DEFAULT_FADE,
    cursorSize = nil,
}

local function IsCursorSize(size)
    return size == 32 or size == 48 or size == 64 or size == 96 or size == 128
end

local function ReadCVar(name)
    if C_CVar and C_CVar.GetCVar then
        return C_CVar.GetCVar(name)
    end
    if GetCVar then
        return GetCVar(name)
    end
end

local function NominalCursorSize()
    if IsCursorSize(ns.db.cursorSize) then
        return ns.db.cursorSize
    end
    local value = tonumber(ReadCVar("cursorSizePreferred"))
    if value and CURSOR_BY_CVAR[value] then
        return CURSOR_BY_CVAR[value]
    end
    return DEFAULT_CURSOR
end

local function OriginShift(origin, uiScale)
    local fraction = ORIGIN_FRACTION[origin] or ORIGIN_FRACTION[DEFAULT_ORIGIN]
    local size = (NominalCursorSize() * CURSOR_VISIBLE) / uiScale
    return fraction[1] * size, -fraction[2] * size
end

local function Placement(cursorX, cursorY, uiScale)
    local anchor = ns.db.anchor
    local origin = ns.db.origin
    local offsetX = ns.db.offsetX
    local offsetY = ns.db.offsetY
    local mode = ns.db.flip

    if (mode == "x" or mode == "xy") and cursorX < (GetScreenWidth() / 2) then
        anchor = X_MIRROR[anchor] or anchor
        origin = X_MIRROR[origin] or origin
        offsetX = -offsetX
    end
    if (mode == "y" or mode == "xy") and cursorY < (GetScreenHeight() / 2) then
        anchor = Y_MIRROR[anchor] or anchor
        origin = Y_MIRROR[origin] or origin
        offsetY = -offsetY
    end

    local shiftX, shiftY = OriginShift(origin, uiScale)
    return ANCHOR_POINT[anchor] or ANCHOR_POINT[DEFAULT_ANCHOR], offsetX + shiftX, offsetY + shiftY
end

local function EnsureDB()
    if type(JustTheTipDB) ~= "table" then
        JustTheTipDB = {}
    end
    if type(JustTheTipDB.enabled) ~= "boolean" then
        JustTheTipDB.enabled = true
    end
    if type(JustTheTipDB.offsetX) ~= "number" then
        JustTheTipDB.offsetX = DEFAULT_X
    end
    if type(JustTheTipDB.offsetY) ~= "number" then
        JustTheTipDB.offsetY = DEFAULT_Y
    end
    if type(JustTheTipDB.scale) ~= "number" or JustTheTipDB.scale < MIN_SCALE or JustTheTipDB.scale > MAX_SCALE then
        JustTheTipDB.scale = DEFAULT_SCALE
    end
    if not ANCHOR_POINT[JustTheTipDB.anchor] then
        JustTheTipDB.anchor = DEFAULT_ANCHOR
    end
    if not ORIGIN_FRACTION[JustTheTipDB.origin] then
        JustTheTipDB.origin = DEFAULT_ORIGIN
    end
    if not FLIP_MODE[JustTheTipDB.flip] then
        JustTheTipDB.flip = DEFAULT_FLIP
    end
    if type(JustTheTipDB.fade) ~= "number" or JustTheTipDB.fade < 0 or JustTheTipDB.fade > MAX_FADE then
        JustTheTipDB.fade = DEFAULT_FADE
    end
    if not IsCursorSize(JustTheTipDB.cursorSize) then
        JustTheTipDB.cursorSize = nil
    end
    ns.db = JustTheTipDB
end

local appliedScale

local function ApplyScale(tooltip)
    local scale = 1
    if ns.db.enabled then
        scale = ns.db.scale / 100
    end
    if appliedScale == scale then
        return
    end
    tooltip:SetScale(scale)
    appliedScale = scale
end

local function Position(tooltip)
    local uiScale = UIParent:GetEffectiveScale()
    if not uiScale or uiScale == 0 then
        return
    end
    ApplyScale(tooltip)
    -- SetOwner parents the tooltip to the hovered button. During a spell drag
    -- the action bar is raised above that button, so the bar paints over the tip.
    if tooltip:GetParent() ~= UIParent then
        tooltip:SetParent(UIParent)
    end
    if tooltip:GetFrameStrata() ~= "TOOLTIP" then
        tooltip:SetFrameStrata("TOOLTIP")
    end
    if tooltip:GetFrameLevel() < 9999 then
        tooltip:SetFrameLevel(9999)
    end
    local tipScale = tooltip:GetEffectiveScale() / uiScale
    if not tipScale or tipScale == 0 then
        return
    end
    local x, y = GetCursorPosition()
    x = x / uiScale
    y = y / uiScale
    local point, offsetX, offsetY = Placement(x, y, uiScale)
    -- SetPoint offsets are in the tooltip's own scale, so a 50% tooltip
    -- needs twice the coordinate to stay on the same screen pixel.
    tooltip:ClearAllPoints()
    tooltip:SetPoint(point, UIParent, "BOTTOMLEFT", (x + offsetX) / tipScale, (y + offsetY) / tipScale)
end

local driver = CreateFrame("Frame", nil, UIParent)
driver:Hide()

local fadeState = {
    pending = false,
    active = false,
    elapsed = 0,
}

local suppressShowReset = false

local function UpdateFade(elapsed)
    if fadeState.pending and GameTooltip:IsShown() then
        fadeState.pending = false
        fadeState.active = true
        fadeState.elapsed = 0
        -- Show aborts Blizzard's own fade. Called from this frame, not from
        -- the tooltip builder, so a secret loot line is not read while tainted.
        suppressShowReset = true
        GameTooltip:Show()
        suppressShowReset = false
        GameTooltip:SetAlpha(1)
    end
    if not fadeState.active or not GameTooltip:IsShown() then
        return
    end
    fadeState.elapsed = fadeState.elapsed + elapsed
    local hold = ns.db.fade
    if fadeState.elapsed < hold then
        GameTooltip:SetAlpha(1)
    elseif fadeState.elapsed < hold + FADE_TIME then
        GameTooltip:SetAlpha(1 - ((fadeState.elapsed - hold) / FADE_TIME))
    else
        fadeState.active = false
        GameTooltip:Hide()
    end
end

driver:SetScript("OnUpdate", function(_, elapsed)
    if ns.db.enabled then
        UpdateFade(elapsed or 0)
    end
    if ns.db.enabled and GameTooltip:IsShown() then
        Position(GameTooltip)
    else
        driver:Hide()
    end
end)

hooksecurefunc(GameTooltip, "FadeOut", function(self)
    if self ~= GameTooltip or not ns.db.enabled then
        return
    end
    fadeState.pending = true
    fadeState.active = false
    fadeState.elapsed = 0
    driver:Show()
end)

GameTooltip:HookScript("OnHide", function(self)
    fadeState.pending = false
    fadeState.active = false
    self:SetAlpha(1)
end)

hooksecurefunc(GameTooltip, "Show", function(self)
    if suppressShowReset then
        return
    end
    if fadeState.pending or fadeState.active then
        fadeState.pending = false
        fadeState.active = false
        self:SetAlpha(1)
    end
end)

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
    if not ns.db.enabled or tooltip ~= GameTooltip then
        return
    end
    tooltip:SetOwner(parent, "ANCHOR_NONE")
    tooltip.default = 1
    Position(tooltip)
    driver:Show()
end)

local function Print(text)
    print("|cffd4a85a[JustTheTip]|r " .. text)
end

local function PrintUsage()
    Print("Commands:")
    Print("/jtt [on||off||toggle]")
    Print("/jtt offset <x> <y>")
    Print("/jtt scale <10-500>")
    Print("/jtt anchor <position>")
    Print("/jtt origin <position>")
    Print("/jtt flip <x||y||xy||off>")
    Print("/jtt cursor <32||48||64||96||128||auto>")
    Print("/jtt fade <seconds>")
    Print("Add reset to a command, for example /jtt fade reset.")
    Print("/jtt reset all")
    Print("Positions: top left, top middle, top right, middle left, center, middle right, bottom left, bottom middle, bottom right.")
end

local function FollowIfShown()
    ApplyScale(GameTooltip)
    if not ns.db.enabled then
        if fadeState.pending or fadeState.active then
            fadeState.pending = false
            fadeState.active = false
            GameTooltip:SetAlpha(1)
            GameTooltip:Hide()
        end
        driver:Hide()
        return
    end
    if GameTooltip:IsShown() then
        driver:Show()
    else
        driver:Hide()
    end
end

local function ParseAnchor(text)
    local compact = text:lower():gsub("%s+", "")
    return ANCHOR_ALIAS[compact]
end

local function ParseScale(text)
    local token, extra = text:match("^(%S+)%s*(.*)$")
    if not token or strtrim(extra or "") ~= "" then
        return nil
    end
    token = token:gsub("%%$", "")
    local percent = tonumber(token)
    if not percent or percent < MIN_SCALE or percent > MAX_SCALE then
        return nil
    end
    return percent
end

local function ResetAll()
    ns.db.enabled = true
    ns.db.offsetX = DEFAULT_X
    ns.db.offsetY = DEFAULT_Y
    ns.db.scale = DEFAULT_SCALE
    ns.db.anchor = DEFAULT_ANCHOR
    ns.db.origin = DEFAULT_ORIGIN
    ns.db.flip = DEFAULT_FLIP
    ns.db.fade = DEFAULT_FADE
    ns.db.cursorSize = nil
end

local function HandleSlash(msg)
    msg = strtrim(msg or "")
    if msg == "" then
        PrintUsage()
        return
    end
    if msg:lower() == "toggle" then
        ns.db.enabled = not ns.db.enabled
        FollowIfShown()
        Print(ns.db.enabled and "On." or "Off.")
        return
    end

    local cmd, rest = msg:match("^(%S+)%s*(.*)$")
    cmd = cmd:lower()
    rest = strtrim(rest or "")

    if cmd == "on" or cmd == "off" then
        if rest ~= "" then
            PrintUsage()
            return
        end
        if cmd == "on" then
            ns.db.enabled = true
        else
            ns.db.enabled = false
        end
        FollowIfShown()
        Print(ns.db.enabled and "On." or "Off.")
        return
    end

    if cmd == "reset" then
        if rest:lower() ~= "all" then
            PrintUsage()
            return
        end
        ResetAll()
        FollowIfShown()
        Print("Reset all.")
        return
    end

    if cmd == "offset" then
        if rest:lower() == "reset" then
            ns.db.offsetX = DEFAULT_X
            ns.db.offsetY = DEFAULT_Y
            FollowIfShown()
            Print(string.format("Offset %g, %g.", DEFAULT_X, DEFAULT_Y))
            return
        end
        local xs, ys, extra = rest:match("^(%S+)%s+(%S+)%s*(.*)$")
        local x = xs and tonumber(xs)
        local y = ys and tonumber(ys)
        if not x or not y or strtrim(extra or "") ~= "" then
            PrintUsage()
            return
        end
        ns.db.offsetX = x
        ns.db.offsetY = y
        Print(string.format("Offset %g, %g.", x, y))
        return
    end

    if cmd == "scale" then
        if rest:lower() == "reset" then
            ns.db.scale = DEFAULT_SCALE
            FollowIfShown()
            Print(string.format("Scale %g%%.", DEFAULT_SCALE))
            return
        end
        local percent = ParseScale(rest)
        if not percent then
            PrintUsage()
            return
        end
        ns.db.scale = percent
        FollowIfShown()
        Print(string.format("Scale %g%%.", percent))
        return
    end

    if cmd == "anchor" then
        if rest:lower() == "reset" then
            ns.db.anchor = DEFAULT_ANCHOR
            FollowIfShown()
            Print(string.format("Anchor %s.", ANCHOR_LABEL[DEFAULT_ANCHOR]))
            return
        end
        local anchor = ParseAnchor(rest)
        if not anchor then
            PrintUsage()
            return
        end
        ns.db.anchor = anchor
        FollowIfShown()
        Print(string.format("Anchor %s.", ANCHOR_LABEL[anchor]))
        return
    end

    if cmd == "flip" then
        if rest:lower() == "reset" then
            ns.db.flip = DEFAULT_FLIP
            FollowIfShown()
            Print(string.format("Flip %s.", DEFAULT_FLIP))
            return
        end
        local mode = rest:lower():gsub("%s+", "")
        if not FLIP_MODE[mode] then
            PrintUsage()
            return
        end
        ns.db.flip = mode
        FollowIfShown()
        Print(string.format("Flip %s.", mode))
        return
    end

    if cmd == "cursor" then
        local token, extra = rest:match("^(%S+)%s*(.*)$")
        if not token or strtrim(extra or "") ~= "" then
            PrintUsage()
            return
        end
        token = token:lower()
        if token == "auto" or token == "default" or token == "reset" then
            ns.db.cursorSize = nil
            local size = NominalCursorSize()
            Print(string.format("Cursor auto (%dx%d).", size, size))
            return
        end
        local size = tonumber(token)
        if not IsCursorSize(size) then
            PrintUsage()
            return
        end
        ns.db.cursorSize = size
        Print(string.format("Cursor %dx%d.", size, size))
        return
    end

    if cmd == "fade" then
        local token, extra = rest:match("^(%S+)%s*(.*)$")
        if token and token:lower() == "reset" and strtrim(extra or "") == "" then
            ns.db.fade = DEFAULT_FADE
            Print(string.format("Fade %gs.", DEFAULT_FADE))
            return
        end
        local seconds = token and tonumber(token)
        if not seconds or seconds < 0 or seconds > MAX_FADE or strtrim(extra or "") ~= "" then
            PrintUsage()
            return
        end
        ns.db.fade = seconds
        Print(string.format("Fade %gs.", seconds))
        return
    end

    if cmd == "origin" then
        if rest:lower() == "reset" then
            ns.db.origin = DEFAULT_ORIGIN
            FollowIfShown()
            Print(string.format("Offset from %s.", ANCHOR_LABEL[DEFAULT_ORIGIN]))
            return
        end
        local origin = ParseAnchor(rest)
        if not origin then
            PrintUsage()
            return
        end
        ns.db.origin = origin
        FollowIfShown()
        Print(string.format("Offset from %s.", ANCHOR_LABEL[origin]))
        return
    end

    PrintUsage()
end

SLASH_JUSTTHETIP1 = "/jtt"
SLASH_JUSTTHETIP2 = "/justthetip"
SlashCmdList["JUSTTHETIP"] = HandleSlash

local eventFrame = CreateFrame("Frame")

function eventFrame:ADDON_LOADED(loaded)
    if loaded ~= addonName then
        return
    end
    EnsureDB()
    self:UnregisterEvent("ADDON_LOADED")
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if self[event] then
        self[event](self, ...)
    end
end)

eventFrame:RegisterEvent("ADDON_LOADED")
