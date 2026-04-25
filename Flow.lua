--[[
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   ·▸  F L O W  ◂·   UI Library  v1.0.0                  ║
║                                                           ║
║   Clean. Sharp. Effortless.                               ║
║   Compatible: Volt · Synapse X · KRNL · Fluxus           ║
║                                                           ║
║   Usage:                                                  ║
║     local Flow = loadstring(game:HttpGet("..."))()        ║
║     local Win = Flow.new({ Title = "My Hub" })            ║
║     local Tab = Win:Tab("Home")                           ║
║     Tab:Toggle({ Name = "Fly", Callback = fn })           ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
]]

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SERVICES
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local cloneref = (cloneref or clonereference or function(i) return i end)

local Players          = cloneref(game:GetService("Players"))
local TweenService     = cloneref(game:GetService("TweenService"))
local UIS              = cloneref(game:GetService("UserInputService"))
local RunService       = cloneref(game:GetService("RunService"))
local CoreGui          = cloneref(game:GetService("CoreGui"))

local LocalPlayer      = Players.LocalPlayer
local GUIParent        = (gethui and gethui()) or CoreGui

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  THEME  (Dark & Sleek)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local T = {
    -- Window layers
    Win        = Color3.fromRGB(11,  11,  14),   -- outermost
    Panel      = Color3.fromRGB(15,  15,  19),   -- sidebar
    Content    = Color3.fromRGB(13,  13,  17),   -- content area
    Card       = Color3.fromRGB(20,  20,  26),   -- element row bg
    CardHover  = Color3.fromRGB(26,  26,  34),   -- hover
    Input      = Color3.fromRGB(18,  18,  23),   -- input fields

    -- Borders
    Line       = Color3.fromRGB(32,  32,  42),   -- subtle divider
    LineBright = Color3.fromRGB(50,  50,  65),   -- active border

    -- Text
    Text       = Color3.fromRGB(232, 232, 240),  -- primary
    TextDim    = Color3.fromRGB(120, 120, 145),  -- secondary
    TextFaint  = Color3.fromRGB(60,  60,  80),   -- muted/placeholder

    -- Accent — icy electric blue-white
    Accent     = Color3.fromRGB(108, 158, 255),  -- main accent
    AccentLow  = Color3.fromRGB(40,  65,  140),  -- dim accent bg
    AccentGlow = Color3.fromRGB(80, 120, 220),   -- glow / indicator

    -- Status
    Good       = Color3.fromRGB(80,  210, 130),
    Warn       = Color3.fromRGB(240, 180, 60),
    Bad        = Color3.fromRGB(240, 80,  70),

    -- Toggle track
    TrackOff   = Color3.fromRGB(35,  35,  45),
    TrackOn    = Color3.fromRGB(45,  90,  210),
}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  TWEENING HELPERS
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local function tween(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    local tw   = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

local function tweenColor(obj, prop, col, t)
    tween(obj, { [prop] = col }, t or 0.14)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  INSTANCE FACTORY
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    if parent then obj.Parent = parent end
    return obj
end

local function corner(r, parent)
    return make("UICorner", { CornerRadius = UDim.new(0, r or 6) }, parent)
end

local function stroke(col, thick, parent)
    return make("UIStroke", {
        Color = col or T.Line,
        Thickness = thick or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, parent)
end

local function padding(top, right, bottom, left, parent)
    return make("UIPadding", {
        PaddingTop    = UDim.new(0, top    or 0),
        PaddingRight  = UDim.new(0, right  or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        PaddingLeft   = UDim.new(0, left   or 0),
    }, parent)
end

local function listLayout(dir, align, spacing, parent)
    return make("UIListLayout", {
        FillDirection       = dir     or Enum.FillDirection.Vertical,
        HorizontalAlignment = align   or Enum.HorizontalAlignment.Left,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Padding             = UDim.new(0, spacing or 0),
    }, parent)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  DRAGGING
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local function makeDraggable(handle, frame)
    local dragging, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = inp.Position
            startPos  = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  NOTIFICATION QUEUE
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local NotifGui = make("ScreenGui", {
    Name            = "FlowNotifications",
    IgnoreGuiInset  = true,
    DisplayOrder    = 9999,
    ResetOnSpawn    = false,
    ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
}, GUIParent)

if protectgui then pcall(protectgui, NotifGui) end

local NotifStack = make("Frame", {
    Name              = "Stack",
    AnchorPoint       = Vector2.new(1, 1),
    Position          = UDim2.new(1, -16, 1, -16),
    Size              = UDim2.new(0, 300, 1, -32),
    BackgroundTransparency = 1,
}, NotifGui)

listLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right, 8, NotifStack)
NotifStack.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

local function notify(opts)
    opts = opts or {}
    local title   = opts.Title   or "Flow"
    local body    = opts.Body    or ""
    local dur     = opts.Duration or 4
    local accent  = opts.Color   or T.Accent

    local card = make("Frame", {
        Name              = "Notif",
        Size              = UDim2.new(1, 0, 0, 0),
        AutomaticSize     = Enum.AutomaticSize.Y,
        BackgroundColor3  = T.Card,
        ClipsDescendants  = true,
    }, NotifStack)
    corner(8, card)
    stroke(T.LineBright, 1, card)

    -- accent strip
    make("Frame", {
        Size             = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
    }, card)

    local inner = make("Frame", {
        Position          = UDim2.new(0, 10, 0, 0),
        Size              = UDim2.new(1, -13, 1, 0),
        BackgroundTransparency = 1,
        AutomaticSize     = Enum.AutomaticSize.Y,
    }, card)
    padding(10, 10, 10, 0, inner)
    listLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 3, inner)

    make("TextLabel", {
        Size              = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text              = title,
        TextColor3        = T.Text,
        TextSize          = 13,
        Font              = Enum.Font.GothamBold,
        TextXAlignment    = Enum.TextXAlignment.Left,
    }, inner)

    if body ~= "" then
        make("TextLabel", {
            Size              = UDim2.new(1, 0, 0, 0),
            AutomaticSize     = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text              = body,
            TextColor3        = T.TextDim,
            TextSize          = 12,
            Font              = Enum.Font.Gotham,
            TextXAlignment    = Enum.TextXAlignment.Left,
            TextWrapped       = true,
        }, inner)
    end

    -- progress bar
    local bar = make("Frame", {
        AnchorPoint      = Vector2.new(0, 1),
        Position         = UDim2.new(0, 0, 1, 0),
        Size             = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
    }, card)

    card.BackgroundTransparency = 1
    tween(card, { BackgroundTransparency = 0 }, 0.2)
    tween(bar, { Size = UDim2.new(0, 0, 0, 2) }, dur, Enum.EasingStyle.Linear)

    task.delay(dur, function()
        tween(card, { BackgroundTransparency = 1 }, 0.25)
        task.wait(0.28)
        card:Destroy()
    end)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  FLOW LIBRARY TABLE
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local Flow = {}
Flow.__index = Flow

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  WINDOW
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

function Flow.new(opts)
    opts = opts or {}
    local title    = opts.Title    or "Flow"
    local subtitle = opts.Subtitle or ""
    local key      = opts.ToggleKey or Enum.KeyCode.RightShift
    local size     = opts.Size or Vector2.new(620, 420)

    local self = setmetatable({}, Flow)
    self._tabs     = {}
    self._active   = nil
    self._visible  = true
    self._key      = key
    self.Notify    = notify

    -- ── ScreenGui ──
    local sg = make("ScreenGui", {
        Name           = "FlowUI",
        ResetOnSpawn   = false,
        IgnoreGuiInset = true,
        DisplayOrder   = 100,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, GUIParent)
    if protectgui then pcall(protectgui, sg) end
    self._sg = sg

    -- ── Root frame ──
    local root = make("Frame", {
        Name             = "Root",
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = UDim2.fromOffset(size.X, size.Y),
        BackgroundColor3 = T.Win,
        ClipsDescendants = true,
    }, sg)
    corner(10, root)
    stroke(T.Line, 1, root)
    self._root = root

    -- entry animation
    root.BackgroundTransparency = 1
    tween(root, { BackgroundTransparency = 0 }, 0.25)

    -- ── Topbar ──
    local topbar = make("Frame", {
        Name             = "Topbar",
        Size             = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = T.Panel,
        ZIndex           = 2,
    }, root)
    -- bottom border
    make("Frame", {
        AnchorPoint      = Vector2.new(0, 1),
        Position         = UDim2.new(0, 0, 1, 0),
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = T.Line,
        BorderSizePixel  = 0,
    }, topbar)

    padding(0, 14, 0, 14, topbar)

    -- dot cluster (mac-style)
    local dots = make("Frame", {
        Name                  = "Dots",
        AnchorPoint           = Vector2.new(0, 0.5),
        Position              = UDim2.new(0, 0, 0.5, 0),
        Size                  = UDim2.new(0, 60, 0, 12),
        BackgroundTransparency = 1,
    }, topbar)
    listLayout(Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 8, dots)

    local dotColors = { T.Bad, T.Warn, T.Good }
    for i, col in ipairs(dotColors) do
        local d = make("Frame", {
            Name             = "Dot"..i,
            Size             = UDim2.fromOffset(11, 11),
            BackgroundColor3 = col,
        }, dots)
        corner(99, d)
        -- close dot closes window
        if i == 1 then
            local btn = make("TextButton", {
                Size                  = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Text                  = "",
            }, d)
            btn.MouseButton1Click:Connect(function()
                self:Destroy()
            end)
        end
    end

    -- title
    local titleLbl = make("TextLabel", {
        Name              = "Title",
        AnchorPoint       = Vector2.new(0.5, 0.5),
        Position          = UDim2.new(0.5, 0, 0.5, 0),
        Size              = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1,
        Text              = title,
        TextColor3        = T.Text,
        TextSize          = 14,
        Font              = Enum.Font.GothamBold,
    }, topbar)

    if subtitle ~= "" then
        make("TextLabel", {
            Name              = "Subtitle",
            AnchorPoint       = Vector2.new(1, 0.5),
            Position          = UDim2.new(1, 0, 0.5, 0),
            Size              = UDim2.new(0, 120, 1, 0),
            BackgroundTransparency = 1,
            Text              = subtitle,
            TextColor3        = T.TextFaint,
            TextSize          = 11,
            Font              = Enum.Font.Gotham,
            TextXAlignment    = Enum.TextXAlignment.Right,
        }, topbar)
    end

    makeDraggable(topbar, root)

    -- ── Body (sidebar + content) ──
    local body = make("Frame", {
        Name             = "Body",
        Position         = UDim2.new(0, 0, 0, 40),
        Size             = UDim2.new(1, 0, 1, -40),
        BackgroundTransparency = 1,
    }, root)

    -- Sidebar
    local sidebar = make("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, 148, 1, 0),
        BackgroundColor3 = T.Panel,
    }, body)
    -- right border
    make("Frame", {
        AnchorPoint      = Vector2.new(1, 0),
        Position         = UDim2.new(1, 0, 0, 0),
        Size             = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = T.Line,
        BorderSizePixel  = 0,
    }, sidebar)

    local tabList = make("ScrollingFrame", {
        Name                   = "TabList",
        Position               = UDim2.new(0, 0, 0, 8),
        Size                   = UDim2.new(1, 0, 1, -8),
        BackgroundTransparency = 1,
        ScrollBarThickness     = 0,
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
    }, sidebar)
    padding(0, 10, 8, 10, tabList)
    listLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 3, tabList)

    self._tabList = tabList

    -- Content area
    local contentArea = make("Frame", {
        Name             = "ContentArea",
        Position         = UDim2.new(0, 148, 0, 0),
        Size             = UDim2.new(1, -148, 1, 0),
        BackgroundColor3 = T.Content,
        ClipsDescendants = true,
    }, body)
    self._contentArea = contentArea

    -- ── Toggle key ──
    UIS.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        if inp.KeyCode == self._key then
            self:Toggle()
        end
    end)

    return self
end

function Flow:Toggle()
    self._visible = not self._visible
    self._root.Visible = self._visible
end

function Flow:Destroy()
    tween(self._root, { BackgroundTransparency = 1 }, 0.2)
    task.delay(0.22, function()
        self._sg:Destroy()
    end)
end

function Flow:SetKey(k)
    self._key = k
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  TAB
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

function Flow:Tab(name, icon)
    local Tab = {}
    Tab._win = self

    -- ── Sidebar button ──
    local btn = make("TextButton", {
        Name             = "Tab_"..name,
        Size             = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = T.Panel,
        AutoButtonColor  = false,
        Text             = "",
    }, self._tabList)
    corner(7, btn)

    -- accent indicator bar (left edge)
    local bar = make("Frame", {
        Name             = "Bar",
        Position         = UDim2.new(0, 0, 0.15, 0),
        Size             = UDim2.new(0, 2, 0.7, 0),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        BackgroundTransparency = 1,
    }, btn)
    corner(99, bar)

    local btnInner = make("Frame", {
        Name             = "Inner",
        Position         = UDim2.new(0, 10, 0, 0),
        Size             = UDim2.new(1, -10, 1, 0),
        BackgroundTransparency = 1,
    }, btn)
    listLayout(Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 7, btnInner)
    btnInner.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    if icon and icon ~= "" then
        make("TextLabel", {
            Name              = "Icon",
            Size              = UDim2.fromOffset(16, 34),
            BackgroundTransparency = 1,
            Text              = icon,
            TextSize          = 15,
            Font              = Enum.Font.GothamBold,
            TextColor3        = T.TextDim,
        }, btnInner)
    end

    local nameLbl = make("TextLabel", {
        Name              = "Name",
        Size              = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text              = name,
        TextColor3        = T.TextDim,
        TextSize          = 13,
        Font              = Enum.Font.Gotham,
        TextXAlignment    = Enum.TextXAlignment.Left,
    }, btnInner)

    -- ── Content page ──
    local page = make("ScrollingFrame", {
        Name                   = "Page_"..name,
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness     = 3,
        ScrollBarImageColor3   = T.LineBright,
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        Visible                = false,
    }, self._contentArea)
    padding(10, 14, 14, 14, page)
    listLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 6, page)

    Tab._page   = page
    Tab._btn    = btn
    Tab._bar    = bar
    Tab._name   = nameLbl

    -- ── Activate logic ──
    local function activate()
        for _, t in ipairs(self._tabs) do
            -- deactivate all
            t._page.Visible = false
            tween(t._btn, { BackgroundColor3 = T.Panel }, 0.14)
            tween(t._name, { TextColor3 = T.TextDim }, 0.14)
            tween(t._bar, { BackgroundTransparency = 1 }, 0.14)
        end
        page.Visible = true
        tween(btn, { BackgroundColor3 = T.Card }, 0.14)
        tween(nameLbl, { TextColor3 = T.Text }, 0.14)
        tween(bar, { BackgroundTransparency = 0 }, 0.14)
        self._active = Tab
    end

    btn.MouseButton1Click:Connect(activate)

    btn.MouseEnter:Connect(function()
        if self._active ~= Tab then
            tween(btn, { BackgroundColor3 = T.CardHover }, 0.1)
        end
    end)
    btn.MouseLeave:Connect(function()
        if self._active ~= Tab then
            tween(btn, { BackgroundColor3 = T.Panel }, 0.1)
        end
    end)

    table.insert(self._tabs, Tab)

    -- auto-activate first tab
    if #self._tabs == 1 then
        activate()
    end

    -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    --  SECTION (visual grouping header)
    -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    function Tab:Section(title)
        local wrap = make("Frame", {
            Name             = "Section_"..title,
            Size             = UDim2.new(1, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
        }, page)
        listLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 0, wrap)

        -- header row
        local header = make("Frame", {
            Name             = "Header",
            Size             = UDim2.new(1, 0, 0, 26),
            BackgroundTransparency = 1,
        }, wrap)
        listLayout(Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 8, header)
        header.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

        make("TextLabel", {
            Name              = "Label",
            Size              = UDim2.new(0, 0, 0, 14),
            AutomaticSize     = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text              = string.upper(title),
            TextColor3        = T.TextFaint,
            TextSize          = 10,
            Font              = Enum.Font.GothamBold,
            LetterSpacingPercent = 8,
        }, header)

        -- line after
        make("Frame", {
            Name             = "Line",
            Size             = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = T.Line,
            BorderSizePixel  = 0,
        }, wrap)

        -- elements go in a container below
        local container = make("Frame", {
            Name             = "Container",
            Size             = UDim2.new(1, 0, 0, 6),  -- spacing top
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
        }, wrap)
        listLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 5, container)

        -- Return a proxy that adds elements into this container
        local Sec = {}
        Sec._container = container
        Sec._page = page

        function Sec:Toggle(opts) return addToggle(container, opts) end
        function Sec:Button(opts) return addButton(container, opts) end
        function Sec:Slider(opts) return addSlider(container, opts) end
        function Sec:Dropdown(opts) return addDropdown(container, opts) end
        function Sec:Input(opts) return addInput(container, opts) end
        function Sec:Label(opts) return addLabel(container, opts) end
        function Sec:Keybind(opts) return addKeybind(container, opts) end
        function Sec:Divider() return addDivider(container) end

        return Sec
    end

    -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    --  ELEMENT HELPERS (forward declared)
    -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    -- Bind element methods to the page directly too
    function Tab:Toggle(opts) return addToggle(page, opts) end
    function Tab:Button(opts) return addButton(page, opts) end
    function Tab:Slider(opts) return addSlider(page, opts) end
    function Tab:Dropdown(opts) return addDropdown(page, opts) end
    function Tab:Input(opts) return addInput(page, opts) end
    function Tab:Label(opts) return addLabel(page, opts) end
    function Tab:Keybind(opts) return addKeybind(page, opts) end
    function Tab:Divider() return addDivider(page) end

    return Tab
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ELEMENT: ROW BASE
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local function makeRow(parent, h)
    h = h or 42
    local row = make("Frame", {
        Size             = UDim2.new(1, 0, 0, h),
        BackgroundColor3 = T.Card,
    }, parent)
    corner(7, row)
    padding(0, 14, 0, 14, row)
    return row
end

local function rowHover(row)
    row.MouseEnter:Connect(function()
        tweenColor(row, "BackgroundColor3", T.CardHover)
    end)
    row.MouseLeave:Connect(function()
        tweenColor(row, "BackgroundColor3", T.Card)
    end)
end

local function makeLabelBlock(parent, name, desc)
    local block = make("Frame", {
        Name             = "Labels",
        AnchorPoint      = Vector2.new(0, 0.5),
        Position         = UDim2.new(0, 0, 0.5, 0),
        Size             = UDim2.new(0, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
    }, parent)
    listLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 1, block)

    if name and name ~= "" then
        make("TextLabel", {
            Size              = UDim2.new(0, 200, 0, 16),
            BackgroundTransparency = 1,
            Text              = name,
            TextColor3        = T.Text,
            TextSize          = 13,
            Font              = Enum.Font.Gotham,
            TextXAlignment    = Enum.TextXAlignment.Left,
        }, block)
    end

    if desc and desc ~= "" then
        make("TextLabel", {
            Size              = UDim2.new(0, 200, 0, 13),
            BackgroundTransparency = 1,
            Text              = desc,
            TextColor3        = T.TextDim,
            TextSize          = 11,
            Font              = Enum.Font.Gotham,
            TextXAlignment    = Enum.TextXAlignment.Left,
        }, block)
    end

    return block
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ELEMENT: DIVIDER
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

addDivider = function(parent)
    make("Frame", {
        Name             = "Divider",
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = T.Line,
        BorderSizePixel  = 0,
    }, parent)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ELEMENT: LABEL / PARAGRAPH
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

addLabel = function(parent, opts)
    opts = opts or {}
    local row = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = T.Card,
    }, parent)
    corner(7, row)
    padding(10, 14, 10, 14, row)

    make("TextLabel", {
        Size              = UDim2.new(1, 0, 0, 0),
        AutomaticSize     = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text              = opts.Text or "",
        TextColor3        = opts.Color or T.TextDim,
        TextSize          = opts.Size or 12,
        Font              = Enum.Font.Gotham,
        TextXAlignment    = Enum.TextXAlignment.Left,
        TextWrapped       = true,
    }, row)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ELEMENT: TOGGLE
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

addToggle = function(parent, opts)
    opts = opts or {}
    local name     = opts.Name     or ""
    local desc     = opts.Desc     or ""
    local default  = opts.Default  or false
    local callback = opts.Callback or function() end

    local state = default

    local row = makeRow(parent, (desc ~= "") and 50 or 40)
    rowHover(row)

    makeLabelBlock(row, name, desc)

    -- Track
    local trackW, trackH = 38, 20
    local track = make("Frame", {
        Name             = "Track",
        AnchorPoint      = Vector2.new(1, 0.5),
        Position         = UDim2.new(1, 0, 0.5, 0),
        Size             = UDim2.fromOffset(trackW, trackH),
        BackgroundColor3 = state and T.TrackOn or T.TrackOff,
    }, row)
    corner(99, track)
    stroke(T.LineBright, 1, track)

    -- Thumb
    local thumbPad = 3
    local thumb = make("Frame", {
        Name             = "Thumb",
        AnchorPoint      = Vector2.new(0, 0.5),
        Position         = state
            and UDim2.new(0, trackW - trackH + thumbPad, 0.5, 0)
            or  UDim2.new(0, thumbPad, 0.5, 0),
        Size             = UDim2.fromOffset(trackH - thumbPad*2, trackH - thumbPad*2),
        BackgroundColor3 = T.Text,
    }, track)
    corner(99, thumb)

    local btn = make("TextButton", {
        Size                   = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text                   = "",
    }, row)

    local function setToggle(v, silent)
        state = v
        tween(track, {
            BackgroundColor3 = state and T.TrackOn or T.TrackOff
        }, 0.17)
        tween(thumb, {
            Position = state
                and UDim2.new(0, trackW - trackH + thumbPad, 0.5, 0)
                or  UDim2.new(0, thumbPad, 0.5, 0)
        }, 0.17)
        if not silent then callback(state) end
    end

    btn.MouseButton1Click:Connect(function()
        setToggle(not state)
    end)

    local api = {}
    function api:Set(v) setToggle(v, true) end
    function api:Get() return state end
    return api
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ELEMENT: BUTTON
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

addButton = function(parent, opts)
    opts = opts or {}
    local name     = opts.Name     or "Button"
    local desc     = opts.Desc     or ""
    local callback = opts.Callback or function() end
    local accent   = opts.Color    or nil

    local row = make("Frame", {
        Size             = UDim2.new(1, 0, 0, (desc ~= "") and 50 or 40),
        BackgroundColor3 = accent or T.Card,
    }, parent)
    corner(7, row)
    padding(0, 14, 0, 14, row)
    if accent then
        -- slightly darker variant on hover
    end

    -- Label center
    local lbl = make("TextLabel", {
        AnchorPoint       = Vector2.new(0, 0.5),
        Position          = UDim2.new(0, 0, 0.5, 0),
        Size              = UDim2.new(1, -24, 0, 18),
        BackgroundTransparency = 1,
        Text              = name,
        TextColor3        = accent and T.Win or T.Text,
        TextSize          = 13,
        Font              = Enum.Font.GothamSemibold,
        TextXAlignment    = Enum.TextXAlignment.Left,
    }, row)

    if desc ~= "" then
        lbl.Position = UDim2.new(0, 0, 0.3, 0)
        make("TextLabel", {
            AnchorPoint       = Vector2.new(0, 0),
            Position          = UDim2.new(0, 0, 0.58, 0),
            Size              = UDim2.new(1, -24, 0, 13),
            BackgroundTransparency = 1,
            Text              = desc,
            TextColor3        = accent and Color3.fromRGB(200,200,200) or T.TextDim,
            TextSize          = 11,
            Font              = Enum.Font.Gotham,
            TextXAlignment    = Enum.TextXAlignment.Left,
        }, row)
    end

    -- arrow
    make("TextLabel", {
        AnchorPoint       = Vector2.new(1, 0.5),
        Position          = UDim2.new(1, 0, 0.5, 0),
        Size              = UDim2.fromOffset(18, 18),
        BackgroundTransparency = 1,
        Text              = "›",
        TextColor3        = accent and T.Win or T.TextFaint,
        TextSize          = 18,
        Font              = Enum.Font.GothamBold,
    }, row)

    local btn = make("TextButton", {
        Size                  = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text                  = "",
    }, row)

    btn.MouseEnter:Connect(function()
        tweenColor(row, "BackgroundColor3", accent and T.AccentGlow or T.CardHover)
    end)
    btn.MouseLeave:Connect(function()
        tweenColor(row, "BackgroundColor3", accent or T.Card)
    end)
    btn.MouseButton1Click:Connect(function()
        tween(row, { BackgroundColor3 = T.AccentLow }, 0.07)
        tween(row, { BackgroundColor3 = accent or T.Card }, 0.15)
        callback()
    end)

    local api = {}
    function api:SetName(n) lbl.Text = n end
    return api
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ELEMENT: SLIDER
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

addSlider = function(parent, opts)
    opts = opts or {}
    local name     = opts.Name     or ""
    local desc     = opts.Desc     or ""
    local min      = opts.Min      or 0
    local max      = opts.Max      or 100
    local default  = opts.Default  or min
    local step     = opts.Step     or 1
    local suffix   = opts.Suffix   or ""
    local callback = opts.Callback or function() end

    local val = math.clamp(default, min, max)

    local row = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = T.Card,
    }, parent)
    corner(7, row)
    padding(8, 14, 8, 14, row)
    listLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 4, row)

    -- top: label + value
    local topRow = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
    }, row)

    make("TextLabel", {
        Size              = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text              = name,
        TextColor3        = T.Text,
        TextSize          = 13,
        Font              = Enum.Font.Gotham,
        TextXAlignment    = Enum.TextXAlignment.Left,
    }, topRow)

    local valLbl = make("TextLabel", {
        AnchorPoint       = Vector2.new(1, 0),
        Position          = UDim2.new(1, 0, 0, 0),
        Size              = UDim2.new(0.3, 0, 1, 0),
        BackgroundTransparency = 1,
        Text              = tostring(val)..suffix,
        TextColor3        = T.Accent,
        TextSize          = 12,
        Font              = Enum.Font.GothamBold,
        TextXAlignment    = Enum.TextXAlignment.Right,
    }, topRow)

    -- track
    local trackBg = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 6),
        BackgroundColor3 = T.TrackOff,
    }, row)
    corner(99, trackBg)

    local fill = make("Frame", {
        Size             = UDim2.new((val-min)/(max-min), 0, 1, 0),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
    }, trackBg)
    corner(99, fill)

    -- thumb
    local thumbSize = 14
    local thumb = make("Frame", {
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new((val-min)/(max-min), 0, 0.5, 0),
        Size             = UDim2.fromOffset(thumbSize, thumbSize),
        BackgroundColor3 = T.Text,
        ZIndex           = 2,
    }, trackBg)
    corner(99, thumb)

    local dragging = false

    local function setVal(v)
        v = math.clamp(math.round((v - min) / step) * step + min, min, max)
        val = v
        local pct = (v - min) / (max - min)
        tween(fill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.08)
        tween(thumb, { Position = UDim2.new(pct, 0, 0.5, 0) }, 0.08)
        valLbl.Text = tostring(v)..suffix
        callback(v)
    end

    local function updateFromMouse()
        local trackPos  = trackBg.AbsolutePosition.X
        local trackSize = trackBg.AbsoluteSize.X
        local mouseX    = UIS:GetMouseLocation().X
        local pct       = math.clamp((mouseX - trackPos) / trackSize, 0, 1)
        setVal(min + pct * (max - min))
    end

    trackBg.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateFromMouse()
        end
    end)

    UIS.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromMouse()
        end
    end)

    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    local api = {}
    function api:Set(v) setVal(v) end
    function api:Get() return val end
    return api
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ELEMENT: INPUT
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

addInput = function(parent, opts)
    opts = opts or {}
    local name        = opts.Name        or ""
    local desc        = opts.Desc        or ""
    local placeholder = opts.Placeholder or "Type here..."
    local default     = opts.Default     or ""
    local callback    = opts.Callback    or function() end

    local row = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = T.Card,
    }, parent)
    corner(7, row)
    padding(8, 14, 8, 14, row)
    listLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 5, row)

    -- label
    if name ~= "" then
        make("TextLabel", {
            Size              = UDim2.new(1, 0, 0, 15),
            BackgroundTransparency = 1,
            Text              = name,
            TextColor3        = T.Text,
            TextSize          = 12,
            Font              = Enum.Font.Gotham,
            TextXAlignment    = Enum.TextXAlignment.Left,
        }, row)
    end

    -- input box
    local box = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = T.Input,
    }, row)
    corner(6, box)
    stroke(T.Line, 1, box)
    padding(0, 10, 0, 10, box)

    local tb = make("TextBox", {
        Size              = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        PlaceholderText   = placeholder,
        PlaceholderColor3 = T.TextFaint,
        Text              = default,
        TextColor3        = T.Text,
        TextSize          = 12,
        Font              = Enum.Font.Gotham,
        TextXAlignment    = Enum.TextXAlignment.Left,
        ClearTextOnFocus  = false,
    }, box)

    tb.Focused:Connect(function()
        tween(box, { BackgroundColor3 = T.CardHover }, 0.12)
        stroke(T.Accent, 1, box)
    end)
    tb.FocusLost:Connect(function(enter)
        tween(box, { BackgroundColor3 = T.Input }, 0.12)
        stroke(T.Line, 1, box)
        callback(tb.Text)
    end)

    local api = {}
    function api:Set(v) tb.Text = v end
    function api:Get() return tb.Text end
    return api
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ELEMENT: DROPDOWN
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

addDropdown = function(parent, opts)
    opts = opts or {}
    local name     = opts.Name     or ""
    local options  = opts.Options  or {}
    local default  = opts.Default  or (options[1] or "")
    local multi    = opts.Multi    or false
    local callback = opts.Callback or function() end

    local selected = multi and {} or default
    if multi and default then
        if type(default) == "table" then selected = default
        else selected = { default } end
    end

    local open = false

    -- Row
    local row = makeRow(parent, 40)
    rowHover(row)

    makeLabelBlock(row, name, "")

    -- value display + arrow
    local valLbl = make("TextLabel", {
        AnchorPoint       = Vector2.new(1, 0.5),
        Position          = UDim2.new(1, -22, 0.5, 0),
        Size              = UDim2.new(0.45, 0, 0, 16),
        BackgroundTransparency = 1,
        Text              = multi and (table.concat(selected, ", ") == "" and "None" or table.concat(selected, ", ")) or tostring(selected),
        TextColor3        = T.TextDim,
        TextSize          = 12,
        Font              = Enum.Font.Gotham,
        TextXAlignment    = Enum.TextXAlignment.Right,
        TextTruncate      = Enum.TextTruncate.AtEnd,
    }, row)

    local arrow = make("TextLabel", {
        AnchorPoint       = Vector2.new(1, 0.5),
        Position          = UDim2.new(1, 0, 0.5, 0),
        Size              = UDim2.fromOffset(18, 18),
        BackgroundTransparency = 1,
        Text              = "⌄",
        TextColor3        = T.TextDim,
        TextSize          = 14,
        Font              = Enum.Font.GothamBold,
    }, row)

    -- Dropdown panel (rendered in contentArea's parent ScreenGui for overlay)
    local dropPanel = make("Frame", {
        Name             = "DropPanel",
        BackgroundColor3 = T.Card,
        ZIndex           = 50,
        Visible          = false,
        Size             = UDim2.fromOffset(200, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
    }, parent.Parent or parent)
    corner(8, dropPanel)
    stroke(T.LineBright, 1, dropPanel)

    local dropList = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
    }, dropPanel)
    padding(5, 6, 5, 6, dropList)
    listLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 3, dropList)

    local function updateDisplay()
        if multi then
            local s = table.concat(selected, ", ")
            valLbl.Text = s == "" and "None" or s
        else
            valLbl.Text = tostring(selected)
        end
    end

    local function buildItems()
        for _, c in ipairs(dropList:GetChildren()) do
            if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
        end
        for _, opt in ipairs(options) do
            local isSelected = multi and table.find(selected, opt) or (selected == opt)
            local item = make("TextButton", {
                Name             = "Item_"..tostring(opt),
                Size             = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = isSelected and T.AccentLow or T.Card,
                AutoButtonColor  = false,
                Text             = "",
            }, dropList)
            corner(5, item)
            padding(0, 8, 0, 8, item)

            make("TextLabel", {
                Size              = UDim2.new(1, -20, 1, 0),
                BackgroundTransparency = 1,
                Text              = tostring(opt),
                TextColor3        = isSelected and T.Accent or T.Text,
                TextSize          = 12,
                Font              = isSelected and Enum.Font.GothamBold or Enum.Font.Gotham,
                TextXAlignment    = Enum.TextXAlignment.Left,
            }, item)

            if isSelected then
                make("TextLabel", {
                    AnchorPoint       = Vector2.new(1, 0.5),
                    Position          = UDim2.new(1, 0, 0.5, 0),
                    Size              = UDim2.fromOffset(16, 16),
                    BackgroundTransparency = 1,
                    Text              = "✓",
                    TextColor3        = T.Accent,
                    TextSize          = 12,
                    Font              = Enum.Font.GothamBold,
                }, item)
            end

            item.MouseEnter:Connect(function()
                tweenColor(item, "BackgroundColor3", T.CardHover)
            end)
            item.MouseLeave:Connect(function()
                tweenColor(item, "BackgroundColor3", isSelected and T.AccentLow or T.Card)
            end)

            item.MouseButton1Click:Connect(function()
                if multi then
                    local idx = table.find(selected, opt)
                    if idx then table.remove(selected, idx)
                    else table.insert(selected, opt) end
                    callback(selected)
                else
                    selected = opt
                    callback(opt)
                    open = false
                    dropPanel.Visible = false
                    tween(arrow, { Rotation = 0 }, 0.15)
                end
                updateDisplay()
                buildItems()
            end)
        end
    end

    buildItems()

    local openBtn = make("TextButton", {
        Size                  = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text                  = "",
        ZIndex                = 2,
    }, row)

    openBtn.MouseButton1Click:Connect(function()
        open = not open
        dropPanel.Visible = open
        tween(arrow, { Rotation = open and 180 or 0 }, 0.15)
        if open then
            local absPos  = row.AbsolutePosition
            local absSize = row.AbsoluteSize
            dropPanel.Position = UDim2.fromOffset(absPos.X, absPos.Y + absSize.Y + 4)
            dropPanel.Size = UDim2.fromOffset(absSize.X, 0)
            dropPanel.AutomaticSize = Enum.AutomaticSize.Y
        end
    end)

    -- close on outside click
    RunService.Heartbeat:Connect(function()
        if open and not openBtn:IsDescendantOf(game) then
            open = false
            dropPanel.Visible = false
        end
    end)

    local api = {}
    function api:Set(v) selected = v; updateDisplay(); buildItems() end
    function api:Get() return selected end
    function api:Refresh(newOpts) options = newOpts; buildItems() end
    return api
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ELEMENT: KEYBIND
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

addKeybind = function(parent, opts)
    opts = opts or {}
    local name     = opts.Name     or "Keybind"
    local default  = opts.Default  or Enum.KeyCode.Unknown
    local callback = opts.Callback or function() end

    local bound   = default
    local waiting = false

    local row = makeRow(parent, 40)
    rowHover(row)

    makeLabelBlock(row, name, "")

    local keyBox = make("TextButton", {
        AnchorPoint       = Vector2.new(1, 0.5),
        Position          = UDim2.new(1, 0, 0.5, 0),
        Size              = UDim2.fromOffset(70, 24),
        BackgroundColor3  = T.Input,
        AutoButtonColor   = false,
        Text              = tostring(bound.Name),
        TextColor3        = T.Accent,
        TextSize          = 11,
        Font              = Enum.Font.GothamBold,
    }, row)
    corner(5, keyBox)
    stroke(T.Line, 1, keyBox)

    keyBox.MouseButton1Click:Connect(function()
        if waiting then return end
        waiting = true
        keyBox.Text = "..."
        tweenColor(keyBox, "BackgroundColor3", T.AccentLow)
    end)

    UIS.InputBegan:Connect(function(inp, gpe)
        if not waiting then return end
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            bound = inp.KeyCode
            keyBox.Text = tostring(bound.Name)
            waiting = false
            tweenColor(keyBox, "BackgroundColor3", T.Input)
            callback(bound)
        end
    end)

    -- listen
    UIS.InputBegan:Connect(function(inp, gpe)
        if gpe or waiting then return end
        if inp.KeyCode == bound then
            callback(bound)
        end
    end)

    local api = {}
    function api:Set(k) bound = k; keyBox.Text = tostring(k.Name) end
    function api:Get() return bound end
    return api
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  RETURN LIBRARY
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

return Flow
