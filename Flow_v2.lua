--[[
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   ·▸  F L O W  ◂·   UI Library  v2.0.0                     ║
║                                                              ║
║   Clean. Sharp. Effortless.                                  ║
║   Volt · Synapse X · KRNL · Fluxus · Evon                   ║
║                                                              ║
║   local Flow = loadstring(game:HttpGet("URL"))()             ║
║   local Win  = Flow:Window({ Title = "Hub", Sub = "v1" })   ║
║   local Tab  = Win:Tab({ Name = "Home", Icon = "⌂" })       ║
║   Tab:Toggle({ Name = "Fly", Callback = function(v) end })  ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
]]

-- ─────────────────────────────────────────────────────────────
--  SERVICES
-- ─────────────────────────────────────────────────────────────
local cloneref = (cloneref or clonereference or function(x) return x end)

local Players      = cloneref(game:GetService("Players"))
local TweenSvc     = cloneref(game:GetService("TweenService"))
local UIS          = cloneref(game:GetService("UserInputService"))
local RunSvc       = cloneref(game:GetService("RunService"))
local CoreGui      = cloneref(game:GetService("CoreGui"))

local LP           = Players.LocalPlayer
local GUI_PARENT   = (gethui and gethui()) or CoreGui

-- ─────────────────────────────────────────────────────────────
--  THEME
-- ─────────────────────────────────────────────────────────────
local C = {
    -- Base surfaces
    BG          = Color3.fromRGB(10,  10,  13 ),
    SIDEBAR     = Color3.fromRGB(14,  14,  18 ),
    SURFACE     = Color3.fromRGB(12,  12,  16 ),
    CARD        = Color3.fromRGB(19,  19,  25 ),
    CARD_H      = Color3.fromRGB(25,  25,  33 ),
    CARD_P      = Color3.fromRGB(30,  30,  40 ),   -- pressed
    INPUT       = Color3.fromRGB(16,  16,  21 ),

    -- Borders
    LINE        = Color3.fromRGB(30,  30,  40 ),
    LINE_B      = Color3.fromRGB(48,  48,  64 ),

    -- Text
    TXT         = Color3.fromRGB(230, 230, 240),
    TXT2        = Color3.fromRGB(115, 115, 140),
    TXT3        = Color3.fromRGB(55,  55,  75 ),

    -- Accent (electric indigo-blue)
    ACC         = Color3.fromRGB(100, 150, 255),
    ACC_DIM     = Color3.fromRGB(38,  58,  130),
    ACC_GLOW    = Color3.fromRGB(72,  110, 210),

    -- Status
    GREEN       = Color3.fromRGB(72,  205, 125),
    YELLOW      = Color3.fromRGB(235, 175, 55 ),
    RED         = Color3.fromRGB(235, 72,  65 ),

    -- Toggle
    TRK_OFF     = Color3.fromRGB(33,  33,  44 ),
    TRK_ON      = Color3.fromRGB(42,  85,  205),
    THUMB       = Color3.fromRGB(230, 230, 240),
}

-- ─────────────────────────────────────────────────────────────
--  TWEEN / INSTANCE HELPERS
-- ─────────────────────────────────────────────────────────────
local function tw(obj, props, t, es, ed)
    local ti = TweenInfo.new(t or 0.16, es or Enum.EasingStyle.Quint, ed or Enum.EasingDirection.Out)
    TweenSvc:Create(obj, ti, props):Play()
end

local function new(cls, props, parent)
    local o = Instance.new(cls)
    for k,v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function crn(r, p)  return new("UICorner",  {CornerRadius = UDim.new(0,r)}, p) end
local function stk(c,t,p) return new("UIStroke",  {Color=c,Thickness=t,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, p) end
local function pad(tp,rt,bt,lt, p)
    return new("UIPadding",{
        PaddingTop=UDim.new(0,tp),PaddingRight=UDim.new(0,rt),
        PaddingBottom=UDim.new(0,bt),PaddingLeft=UDim.new(0,lt)
    }, p)
end
local function list(fd,ha,sp, p)
    return new("UIListLayout",{
        FillDirection=fd or Enum.FillDirection.Vertical,
        HorizontalAlignment=ha or Enum.HorizontalAlignment.Left,
        SortOrder=Enum.SortOrder.LayoutOrder,
        Padding=UDim.new(0,sp or 0),
    }, p)
end

-- ─────────────────────────────────────────────────────────────
--  DRAG
-- ─────────────────────────────────────────────────────────────
local function drag(handle, frame)
    local down, ds, sp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            down = true; ds = i.Position; sp = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if down and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then down = false end
    end)
end

-- ─────────────────────────────────────────────────────────────
--  NOTIFICATIONS
-- ─────────────────────────────────────────────────────────────
local _nsg = new("ScreenGui",{
    Name="FlowNotifs", IgnoreGuiInset=true,
    DisplayOrder=99999, ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling
}, GUI_PARENT)
if protectgui then pcall(protectgui, _nsg) end

local _nstack = new("Frame",{
    Name="Stack",
    AnchorPoint=Vector2.new(1,1),
    Position=UDim2.new(1,-14,1,-14),
    Size=UDim2.new(0,300,1,-28),
    BackgroundTransparency=1
}, _nsg)
local _nl = list(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right, 8, _nstack)
_nl.VerticalAlignment = Enum.VerticalAlignment.Bottom

local function Notify(opts)
    opts = opts or {}
    local ttl  = opts.Title    or "Flow"
    local body = opts.Body     or ""
    local dur  = opts.Duration or 4
    local col  = opts.Color    or C.ACC

    local card = new("Frame",{
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundColor3=C.CARD, BackgroundTransparency=1, ClipsDescendants=true
    }, _nstack)
    crn(8,card); stk(C.LINE_B,1,card)

    -- left color strip
    new("Frame",{Size=UDim2.new(0,3,1,0), BackgroundColor3=col, BorderSizePixel=0}, card)

    local inner = new("Frame",{
        Position=UDim2.new(0,11,0,0), Size=UDim2.new(1,-14,1,0),
        BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y
    }, card)
    pad(10,10,10,0, inner)
    list(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 3, inner)

    new("TextLabel",{
        Size=UDim2.new(1,0,0,16), BackgroundTransparency=1,
        Text=ttl, TextColor3=C.TXT, TextSize=13, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left
    }, inner)

    if body ~= "" then
        new("TextLabel",{
            Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1, Text=body, TextColor3=C.TXT2,
            TextSize=12, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true
        }, inner)
    end

    local pbar = new("Frame",{
        AnchorPoint=Vector2.new(0,1), Position=UDim2.new(0,0,1,0),
        Size=UDim2.new(1,0,0,2), BackgroundColor3=col, BorderSizePixel=0
    }, card)

    tw(card, {BackgroundTransparency=0}, 0.18)
    tw(pbar, {Size=UDim2.new(0,0,0,2)}, dur, Enum.EasingStyle.Linear)
    task.delay(dur, function()
        tw(card, {BackgroundTransparency=1}, 0.22)
        task.wait(0.25); card:Destroy()
    end)
end

-- ─────────────────────────────────────────────────────────────
--  ELEMENT BUILDERS  (defined first so Tab can reference them)
-- ─────────────────────────────────────────────────────────────

-- shared row factory
local function Row(parent, h)
    local r = new("Frame",{
        Size=UDim2.new(1,0,0,h or 42),
        BackgroundColor3=C.CARD
    }, parent)
    crn(7,r); pad(0,14,0,14,r)
    return r
end

local function RowHover(row, accent)
    row.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseMovement then
            tw(row,{BackgroundColor3=accent and C.CARD_H or C.CARD_H},0.1)
        end
    end)
    row.MouseEnter:Connect(function() tw(row,{BackgroundColor3=C.CARD_H},0.1) end)
    row.MouseLeave:Connect(function() tw(row,{BackgroundColor3=accent or C.CARD},0.1) end)
end

local function LblBlock(parent, name, desc)
    local blk = new("Frame",{
        Name="LblBlock",
        AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,0,0.5,0),
        Size=UDim2.new(0,0,0,0), AutomaticSize=Enum.AutomaticSize.XY,
        BackgroundTransparency=1
    }, parent)
    list(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 2, blk)

    if name and name ~= "" then
        new("TextLabel",{
            Size=UDim2.new(0,210,0,15), BackgroundTransparency=1,
            Text=name, TextColor3=C.TXT, TextSize=13, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left
        }, blk)
    end
    if desc and desc ~= "" then
        new("TextLabel",{
            Size=UDim2.new(0,210,0,12), BackgroundTransparency=1,
            Text=desc, TextColor3=C.TXT2, TextSize=11, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left
        }, blk)
    end
    return blk
end

-- ── DIVIDER ──────────────────────────────────────────────────
local function MakeDivider(parent)
    new("Frame",{
        Name="Divider",
        Size=UDim2.new(1,0,0,1),
        BackgroundColor3=C.LINE, BorderSizePixel=0
    }, parent)
end

-- ── LABEL ────────────────────────────────────────────────────
local function MakeLabel(parent, opts)
    opts = opts or {}
    local row = new("Frame",{
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundColor3=C.CARD
    }, parent)
    crn(7,row); pad(10,14,10,14,row)

    new("TextLabel",{
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,
        Text=opts.Text or "", TextColor3=opts.Color or C.TXT2,
        TextSize=opts.TextSize or 12, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true
    }, row)
end

-- ── TOGGLE ───────────────────────────────────────────────────
local function MakeToggle(parent, opts)
    opts = opts or {}
    local name     = opts.Name     or ""
    local desc     = opts.Desc     or ""
    local state    = opts.Default  or false
    local callback = opts.Callback or function() end

    local TW, TH  = 40, 22
    local TP       = 3

    local row = Row(parent, desc ~= "" and 52 or 42)
    RowHover(row)

    LblBlock(row, name, desc)

    -- track
    local track = new("Frame",{
        Name="Track",
        AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,0,0.5,0),
        Size=UDim2.fromOffset(TW,TH),
        BackgroundColor3=state and C.TRK_ON or C.TRK_OFF
    }, row)
    crn(99,track); stk(C.LINE_B,1,track)

    -- inner glow line
    local glow = new("Frame",{
        Size=UDim2.new(1,0,0,1), BackgroundColor3=C.ACC,
        BackgroundTransparency=state and 0.5 or 1, BorderSizePixel=0
    }, track)

    -- thumb
    local thumb = new("Frame",{
        Name="Thumb",
        AnchorPoint=Vector2.new(0,0.5),
        Position=state and UDim2.new(0,TW-TH+TP,0.5,0) or UDim2.new(0,TP,0.5,0),
        Size=UDim2.fromOffset(TH-TP*2, TH-TP*2),
        BackgroundColor3=C.THUMB
    }, track)
    crn(99,thumb)

    local overlay = new("TextButton",{
        Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text=""
    }, row)

    local function set(v, silent)
        state = v
        tw(track, {BackgroundColor3=v and C.TRK_ON or C.TRK_OFF}, 0.18)
        tw(thumb, {Position=v and UDim2.new(0,TW-TH+TP,0.5,0) or UDim2.new(0,TP,0.5,0)}, 0.18)
        tw(glow,  {BackgroundTransparency=v and 0.5 or 1}, 0.18)
        if not silent then callback(state) end
    end

    overlay.MouseButton1Click:Connect(function() set(not state) end)

    return {
        Set = function(_,v) set(v,true) end,
        Get = function(_) return state end,
    }
end

-- ── BUTTON ───────────────────────────────────────────────────
local function MakeButton(parent, opts)
    opts = opts or {}
    local name     = opts.Name     or "Button"
    local desc     = opts.Desc     or ""
    local callback = opts.Callback or function() end
    local accent   = opts.Color
    local baseCol  = accent or C.CARD

    local row = Row(parent, desc ~= "" and 52 or 42)
    if accent then row.BackgroundColor3 = accent end
    crn(7,row); pad(0,14,0,14,row)

    -- name label
    local nl = new("TextLabel",{
        AnchorPoint=Vector2.new(0,0.5),
        Position=desc ~= "" and UDim2.new(0,0,0.32,0) or UDim2.new(0,0,0.5,0),
        Size=UDim2.new(1,-28,0,16),
        BackgroundTransparency=1,
        Text=name,
        TextColor3=accent and C.BG or C.TXT,
        TextSize=13, Font=Enum.Font.GothamSemibold,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, row)

    if desc ~= "" then
        new("TextLabel",{
            AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,0,0.68,0),
            Size=UDim2.new(1,-28,0,13), BackgroundTransparency=1,
            Text=desc, TextColor3=accent and Color3.fromRGB(190,190,190) or C.TXT2,
            TextSize=11, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left
        }, row)
    end

    -- arrow indicator
    new("TextLabel",{
        AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,0,0.5,0),
        Size=UDim2.fromOffset(20,20), BackgroundTransparency=1,
        Text="›", TextColor3=accent and C.BG or C.TXT3,
        TextSize=20, Font=Enum.Font.GothamBold
    }, row)

    local btn = new("TextButton",{
        Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text=""
    }, row)

    btn.MouseEnter:Connect(function()
        tw(row,{BackgroundColor3=accent and C.ACC_GLOW or C.CARD_H},0.1)
    end)
    btn.MouseLeave:Connect(function()
        tw(row,{BackgroundColor3=baseCol},0.1)
    end)
    btn.MouseButton1Click:Connect(function()
        tw(row,{BackgroundColor3=C.CARD_P},0.07)
        task.delay(0.12, function() tw(row,{BackgroundColor3=baseCol},0.12) end)
        callback()
    end)

    return { SetName=function(_,n) nl.Text=n end }
end

-- ── SLIDER ───────────────────────────────────────────────────
local function MakeSlider(parent, opts)
    opts = opts or {}
    local name     = opts.Name     or ""
    local mn       = opts.Min      or 0
    local mx       = opts.Max      or 100
    local def      = math.clamp(opts.Default or mn, mn, mx)
    local step     = opts.Step     or 1
    local suffix   = opts.Suffix   or ""
    local callback = opts.Callback or function() end
    local val      = def

    local row = new("Frame",{
        Size=UDim2.new(1,0,0,60), BackgroundColor3=C.CARD
    }, parent)
    crn(7,row); pad(9,14,9,14,row)
    list(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 5, row)

    -- top row: name + val
    local top = new("Frame",{
        Size=UDim2.new(1,0,0,16), BackgroundTransparency=1
    }, row)

    new("TextLabel",{
        Size=UDim2.new(0.65,0,1,0), BackgroundTransparency=1,
        Text=name, TextColor3=C.TXT, TextSize=13, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left
    }, top)

    local vl = new("TextLabel",{
        AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,0,0,0),
        Size=UDim2.new(0.35,0,1,0), BackgroundTransparency=1,
        Text=tostring(val)..suffix, TextColor3=C.ACC,
        TextSize=12, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Right
    }, top)

    -- track
    local trk = new("Frame",{
        Size=UDim2.new(1,0,0,5), BackgroundColor3=C.TRK_OFF
    }, row)
    crn(99,trk)

    local fill = new("Frame",{
        Size=UDim2.new((val-mn)/(mx-mn),0,1,0),
        BackgroundColor3=C.ACC, BorderSizePixel=0
    }, trk)
    crn(99,fill)

    -- glowing fill overlay
    local fillGlow = new("Frame",{
        AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,0,0.5,0),
        Size=UDim2.fromOffset(8,8), BackgroundColor3=C.ACC,
        ZIndex=2
    }, fill)
    crn(99,fillGlow)

    local function setV(v)
        v = math.clamp(math.round((v-mn)/step)*step+mn, mn, mx)
        val = v
        local pct = (v-mn)/(mx-mn)
        tw(fill,  {Size=UDim2.new(pct,0,1,0)},  0.07)
        vl.Text = tostring(v)..suffix
        callback(v)
    end

    local held = false
    local function fromMouse()
        local px = trk.AbsolutePosition.X
        local pw = trk.AbsoluteSize.X
        local mx2 = UIS:GetMouseLocation().X
        setV(mn + math.clamp((mx2-px)/pw,0,1)*(mx-mn))
    end

    trk.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            held=true; fromMouse()
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if held and i.UserInputType==Enum.UserInputType.MouseMovement then fromMouse() end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then held=false end
    end)

    return {
        Set=function(_,v) setV(v) end,
        Get=function(_) return val end,
    }
end

-- ── INPUT ────────────────────────────────────────────────────
local function MakeInput(parent, opts)
    opts = opts or {}
    local name    = opts.Name        or ""
    local ph      = opts.Placeholder or "Type here..."
    local def     = opts.Default     or ""
    local cb      = opts.Callback    or function() end
    local live    = opts.LiveUpdate  or false

    local rowH = name ~= "" and 60 or 44
    local row = new("Frame",{
        Size=UDim2.new(1,0,0,rowH), BackgroundColor3=C.CARD
    }, parent)
    crn(7,row); pad(8,14,8,14,row)
    list(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 5, row)

    if name ~= "" then
        new("TextLabel",{
            Size=UDim2.new(1,0,0,14), BackgroundTransparency=1,
            Text=name, TextColor3=C.TXT, TextSize=12, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left
        }, row)
    end

    local box = new("Frame",{
        Size=UDim2.new(1,0,0,28), BackgroundColor3=C.INPUT
    }, row)
    crn(6,box)
    local bstk = stk(C.LINE,1,box)
    pad(0,10,0,10,box)

    local tb = new("TextBox",{
        Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
        PlaceholderText=ph, PlaceholderColor3=C.TXT3,
        Text=def, TextColor3=C.TXT, TextSize=12, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left, ClearTextOnFocus=false
    }, box)

    tb.Focused:Connect(function()
        tw(box,{BackgroundColor3=C.CARD_H},0.12)
        bstk.Color = C.ACC
    end)
    tb.FocusLost:Connect(function()
        tw(box,{BackgroundColor3=C.INPUT},0.12)
        bstk.Color = C.LINE
        cb(tb.Text)
    end)
    if live then
        tb:GetPropertyChangedSignal("Text"):Connect(function() cb(tb.Text) end)
    end

    return {
        Set=function(_,v) tb.Text=v end,
        Get=function(_) return tb.Text end,
    }
end

-- ── DROPDOWN ─────────────────────────────────────────────────
local function MakeDropdown(parent, sgParent, opts)
    opts = opts or {}
    local name     = opts.Name     or ""
    local options  = opts.Options  or {}
    local multi    = opts.Multi    or false
    local callback = opts.Callback or function() end
    local def      = opts.Default

    local selected
    if multi then
        selected = (type(def)=="table") and def or (def and {def} or {})
    else
        selected = def or options[1] or ""
    end

    local isOpen = false

    local row = Row(parent, 42)
    RowHover(row)
    LblBlock(row, name, "")

    local valLbl = new("TextLabel",{
        AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-22,0.5,0),
        Size=UDim2.new(0.5,0,0,15), BackgroundTransparency=1,
        TextColor3=C.TXT2, TextSize=12, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Right,
        TextTruncate=Enum.TextTruncate.AtEnd
    }, row)

    local arrLbl = new("TextLabel",{
        AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,2,0.5,0),
        Size=UDim2.fromOffset(18,18), BackgroundTransparency=1,
        Text="⌄", TextColor3=C.TXT2, TextSize=15, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Center
    }, row)

    -- floating drop panel (parented to screenGui layer)
    local panel = new("Frame",{
        Name="FlowDrop_"..name,
        BackgroundColor3=C.SIDEBAR, ZIndex=100,
        Visible=false, Size=UDim2.fromOffset(200,8),
        ClipsDescendants=false,
        AutomaticSize=Enum.AutomaticSize.Y,
    }, sgParent)
    crn(8,panel); stk(C.LINE_B,1,panel)

    -- shadow frame
    local shadow = new("Frame",{
        AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,4),
        Size=UDim2.new(1,6,1,6), BackgroundColor3=Color3.new(0,0,0),
        BackgroundTransparency=0.65, ZIndex=99, BorderSizePixel=0
    }, panel)
    crn(10,shadow)

    local pInner = new("Frame",{
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1
    }, panel)
    pad(5,6,5,6,pInner)
    list(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 3, pInner)

    local function dispTxt()
        if multi then
            local s = table.concat(selected,", ")
            valLbl.Text = s=="" and "None" or s
        else
            valLbl.Text = tostring(selected)
        end
    end
    dispTxt()

    local function buildItems()
        for _,c in ipairs(pInner:GetChildren()) do
            if c:IsA("TextButton") or (c:IsA("Frame") and c.Name~="shadow") then c:Destroy() end
        end
        for _,opt in ipairs(options) do
            local isSel = multi and (table.find(selected,opt)~=nil) or (selected==opt)
            local item = new("TextButton",{
                Size=UDim2.new(1,0,0,30), BackgroundColor3=isSel and C.ACC_DIM or C.CARD,
                AutoButtonColor=false, Text=""
            }, pInner)
            crn(6,item); pad(0,8,0,8,item)

            new("TextLabel",{
                Size=UDim2.new(1,-20,1,0), BackgroundTransparency=1,
                Text=tostring(opt),
                TextColor3=isSel and C.ACC or C.TXT,
                TextSize=12, Font=isSel and Enum.Font.GothamBold or Enum.Font.Gotham,
                TextXAlignment=Enum.TextXAlignment.Left
            }, item)

            if isSel then
                new("TextLabel",{
                    AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,0,0.5,0),
                    Size=UDim2.fromOffset(16,16), BackgroundTransparency=1,
                    Text="✓", TextColor3=C.ACC,
                    TextSize=11, Font=Enum.Font.GothamBold
                }, item)
            end

            item.MouseEnter:Connect(function() tw(item,{BackgroundColor3=C.CARD_H},0.08) end)
            item.MouseLeave:Connect(function() tw(item,{BackgroundColor3=isSel and C.ACC_DIM or C.CARD},0.08) end)
            item.MouseButton1Click:Connect(function()
                if multi then
                    local idx = table.find(selected,opt)
                    if idx then table.remove(selected,idx) else table.insert(selected,opt) end
                    callback(selected); dispTxt(); buildItems()
                else
                    selected = opt; callback(opt); dispTxt()
                    isOpen = false; panel.Visible = false
                    tw(arrLbl,{Rotation=0},0.14)
                    buildItems()
                end
            end)
        end
    end
    buildItems()

    local obtn = new("TextButton",{
        Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", ZIndex=3
    }, row)

    local function openDrop()
        isOpen = not isOpen
        if isOpen then
            -- position relative to row
            local rp = row.AbsolutePosition
            local rs = row.AbsoluteSize
            panel.Position = UDim2.fromOffset(rp.X, rp.Y + rs.Y + 4)
            panel.Size     = UDim2.fromOffset(rs.X, 0)
            panel.AutomaticSize = Enum.AutomaticSize.Y
            buildItems()
        end
        panel.Visible = isOpen
        tw(arrLbl, {Rotation=isOpen and 180 or 0}, 0.14)
    end

    obtn.MouseButton1Click:Connect(openDrop)

    -- close when clicking elsewhere
    UIS.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 and isOpen then
            task.defer(function()
                local mp = UIS:GetMouseLocation()
                local pp = panel.AbsolutePosition
                local ps = panel.AbsoluteSize
                if mp.X<pp.X or mp.X>pp.X+ps.X or mp.Y<pp.Y or mp.Y>pp.Y+ps.Y then
                    isOpen = false; panel.Visible = false
                    tw(arrLbl,{Rotation=0},0.14)
                end
            end)
        end
    end)

    return {
        Set     = function(_,v) selected=v; dispTxt(); buildItems() end,
        Get     = function(_) return selected end,
        Refresh = function(_,newOpts) options=newOpts; buildItems() end,
    }
end

-- ── KEYBIND ──────────────────────────────────────────────────
local function MakeKeybind(parent, opts)
    opts = opts or {}
    local name     = opts.Name     or "Keybind"
    local def      = opts.Default  or Enum.KeyCode.Unknown
    local callback = opts.Callback or function() end

    local bound   = def
    local waiting = false

    local row = Row(parent, 42)
    RowHover(row)
    LblBlock(row, name, "")

    local kb = new("TextButton",{
        AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,0,0.5,0),
        Size=UDim2.fromOffset(76,26),
        BackgroundColor3=C.INPUT, AutoButtonColor=false,
        Text=bound.Name, TextColor3=C.ACC,
        TextSize=11, Font=Enum.Font.GothamBold
    }, row)
    crn(5,kb); stk(C.LINE,1,kb)

    kb.MouseButton1Click:Connect(function()
        if waiting then return end
        waiting = true
        kb.Text = "..."
        tw(kb,{BackgroundColor3=C.ACC_DIM},0.12)
    end)

    UIS.InputBegan:Connect(function(i,gpe)
        if not waiting then return end
        if i.UserInputType==Enum.UserInputType.Keyboard then
            bound=i.KeyCode; kb.Text=bound.Name
            waiting=false
            tw(kb,{BackgroundColor3=C.INPUT},0.12)
            callback(bound)
        end
    end)

    UIS.InputBegan:Connect(function(i,gpe)
        if gpe or waiting then return end
        if i.KeyCode==bound then callback(bound) end
    end)

    return {
        Set=function(_,k) bound=k; kb.Text=k.Name end,
        Get=function(_) return bound end,
    }
end

-- ── COLOR PICKER ─────────────────────────────────────────────
local function MakeColorpicker(parent, opts)
    opts = opts or {}
    local name     = opts.Name     or "Color"
    local def      = opts.Default  or Color3.fromRGB(100,150,255)
    local callback = opts.Callback or function() end

    local row = Row(parent, 42)
    RowHover(row)
    LblBlock(row, name, "")

    -- preview swatch
    local swatch = new("Frame",{
        AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,0,0.5,0),
        Size=UDim2.fromOffset(56,26), BackgroundColor3=def
    }, row)
    crn(6,swatch); stk(C.LINE_B,1,swatch)

    -- hex label inside swatch
    local hexLbl = new("TextLabel",{
        Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
        Text=string.format("#%02X%02X%02X",
            math.floor(def.R*255),math.floor(def.G*255),math.floor(def.B*255)),
        TextColor3=Color3.new(1,1,1), TextSize=10, Font=Enum.Font.GothamBold
    }, swatch)

    -- simple rgb sliders popup
    local pickerOpen = false
    local pickerFrame = new("Frame",{
        AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,0,1,6),
        Size=UDim2.fromOffset(200,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundColor3=C.SIDEBAR, Visible=false, ZIndex=20
    }, row)
    crn(8,pickerFrame); stk(C.LINE_B,1,pickerFrame); pad(10,12,12,12,pickerFrame)
    list(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 8, pickerFrame)

    local r,g,b = def.R*255, def.G*255, def.B*255

    local function updateColor()
        local col = Color3.fromRGB(math.floor(r),math.floor(g),math.floor(b))
        swatch.BackgroundColor3 = col
        hexLbl.Text = string.format("#%02X%02X%02X",
            math.floor(r),math.floor(g),math.floor(b))
        callback(col)
    end

    local channels = {{"R",Color3.fromRGB(220,80,80)},{"G",Color3.fromRGB(80,210,120)},{"B",Color3.fromRGB(80,140,255)}}
    for _, ch in ipairs(channels) do
        local label = ch[1]
        local color = ch[2]
        local initVal = (label=="R" and r) or (label=="G" and g) or b

        local row2 = new("Frame",{
            Size=UDim2.new(1,0,0,24), BackgroundTransparency=1
        }, pickerFrame)

        new("TextLabel",{
            Size=UDim2.fromOffset(14,24), BackgroundTransparency=1,
            Text=label, TextColor3=color, TextSize=11, Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left
        }, row2)

        local slkbg = new("Frame",{
            AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,20,0.5,0),
            Size=UDim2.new(1,-50,0,4), BackgroundColor3=C.TRK_OFF
        }, row2)
        crn(99,slkbg)

        local slkfill = new("Frame",{
            Size=UDim2.new(initVal/255,0,1,0), BackgroundColor3=color, BorderSizePixel=0
        }, slkbg)
        crn(99,slkfill)

        local numLbl = new("TextLabel",{
            AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,0,0.5,0),
            Size=UDim2.fromOffset(26,24), BackgroundTransparency=1,
            Text=tostring(math.floor(initVal)), TextColor3=C.TXT2,
            TextSize=10, Font=Enum.Font.GothamBold
        }, row2)

        local held2 = false
        slkbg.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then held2=true end
        end)
        UIS.InputChanged:Connect(function(i)
            if held2 and i.UserInputType==Enum.UserInputType.MouseMovement then
                local px = slkbg.AbsolutePosition.X
                local pw = slkbg.AbsoluteSize.X
                local v  = math.clamp((UIS:GetMouseLocation().X-px)/pw,0,1)*255
                if label=="R" then r=v elseif label=="G" then g=v else b=v end
                slkfill.Size = UDim2.new(v/255,0,1,0)
                numLbl.Text  = tostring(math.floor(v))
                updateColor()
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then held2=false end
        end)
    end

    local obtn = new("TextButton",{
        Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", ZIndex=3
    }, swatch)
    obtn.MouseButton1Click:Connect(function()
        pickerOpen = not pickerOpen
        pickerFrame.Visible = pickerOpen
    end)

    return {
        Set=function(_,col)
            swatch.BackgroundColor3=col; r=col.R*255; g=col.G*255; b=col.B*255
            hexLbl.Text=string.format("#%02X%02X%02X",math.floor(r),math.floor(g),math.floor(b))
        end,
        Get=function(_) return swatch.BackgroundColor3 end,
    }
end

-- ─────────────────────────────────────────────────────────────
--  SECTION BUILDER
-- ─────────────────────────────────────────────────────────────
local function BuildSection(page, sgParent, sectionName)
    local wrap = new("Frame",{
        Name="Sec_"..sectionName,
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1
    }, page)
    list(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 0, wrap)

    -- Header
    local hdr = new("Frame",{
        Size=UDim2.new(1,0,0,24), BackgroundTransparency=1
    }, wrap)
    list(Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 7, hdr)
    hdr.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    new("TextLabel",{
        Size=UDim2.new(0,0,0,12), AutomaticSize=Enum.AutomaticSize.X,
        BackgroundTransparency=1,
        Text=string.upper(sectionName),
        TextColor3=C.TXT3, TextSize=9, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left
    }, hdr)

    -- accent dot
    new("Frame",{
        Size=UDim2.fromOffset(4,4), BackgroundColor3=C.ACC, BorderSizePixel=0
    }, hdr)

    -- separator line
    new("Frame",{
        Size=UDim2.new(1,0,0,1), BackgroundColor3=C.LINE, BorderSizePixel=0
    }, wrap)

    -- 6px spacer before elements
    new("Frame",{Size=UDim2.new(1,0,0,4), BackgroundTransparency=1}, wrap)

    -- element container
    local container = new("Frame",{
        Name="Container",
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1
    }, wrap)
    list(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 5, container)

    local Sec = {}
    function Sec:Toggle(o)      return MakeToggle(container, o) end
    function Sec:Button(o)      return MakeButton(container, o) end
    function Sec:Slider(o)      return MakeSlider(container, o) end
    function Sec:Input(o)       return MakeInput(container, o) end
    function Sec:Dropdown(o)    return MakeDropdown(container, sgParent, o) end
    function Sec:Keybind(o)     return MakeKeybind(container, o) end
    function Sec:Colorpicker(o) return MakeColorpicker(container, o) end
    function Sec:Label(o)       return MakeLabel(container, o) end
    function Sec:Divider()      return MakeDivider(container) end
    return Sec
end

-- ─────────────────────────────────────────────────────────────
--  FLOW LIBRARY
-- ─────────────────────────────────────────────────────────────
local Flow = {}
Flow.__index = Flow

function Flow:Window(opts)
    opts = opts or {}
    local title    = opts.Title    or "Flow"
    local sub      = opts.Sub      or ""
    local togKey   = opts.ToggleKey or Enum.KeyCode.RightShift
    local winSize  = opts.Size     or Vector2.new(640, 440)

    local Win = {}
    Win._tabs    = {}
    Win._active  = nil
    Win._visible = true
    Win._key     = togKey
    Win.Notify   = Notify

    -- ScreenGui
    local sg = new("ScreenGui",{
        Name="FlowUI", ResetOnSpawn=false, IgnoreGuiInset=true,
        DisplayOrder=100, ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    }, GUI_PARENT)
    if protectgui then pcall(protectgui,sg) end
    Win._sg = sg

    -- Root
    local root = new("Frame",{
        Name="Root",
        AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.fromOffset(winSize.X, winSize.Y),
        BackgroundColor3=C.BG, ClipsDescendants=true
    }, sg)
    crn(11,root); stk(C.LINE,1,root)
    Win._root = root

    -- open anim
    root.BackgroundTransparency = 1
    tw(root,{BackgroundTransparency=0},0.22)

    -- ── TOPBAR ──────────────────────────────────────────────
    local topbar = new("Frame",{
        Name="Topbar",
        Size=UDim2.new(1,0,0,44),
        BackgroundColor3=C.SIDEBAR, ZIndex=2
    }, root)
    pad(0,16,0,16,topbar)

    -- bottom border
    new("Frame",{
        AnchorPoint=Vector2.new(0,1), Position=UDim2.new(0,0,1,0),
        Size=UDim2.new(1,0,0,1), BackgroundColor3=C.LINE, BorderSizePixel=0
    }, topbar)

    -- MAC DOTS
    local dotRow = new("Frame",{
        AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,0,0.5,0),
        Size=UDim2.new(0,56,0,12), BackgroundTransparency=1
    }, topbar)
    list(Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 8, dotRow)
    dotRow.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local dotCols = {C.RED, C.YELLOW, C.GREEN}
    for i,dc in ipairs(dotCols) do
        local dot = new("Frame",{Size=UDim2.fromOffset(11,11), BackgroundColor3=dc}, dotRow)
        crn(99,dot)
        if i==1 then
            local dotBtn = new("TextButton",{
                Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text=""
            }, dot)
            dotBtn.MouseButton1Click:Connect(function() Win:Destroy() end)
        end
        if i==2 then
            local dotBtn = new("TextButton",{
                Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text=""
            }, dot)
            dotBtn.MouseButton1Click:Connect(function() Win:Toggle() end)
        end
    end

    -- Title (centered)
    new("TextLabel",{
        AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X,
        BackgroundTransparency=1,
        Text=title, TextColor3=C.TXT, TextSize=14, Font=Enum.Font.GothamBold
    }, topbar)

    -- Subtitle
    if sub ~= "" then
        new("TextLabel",{
            AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,0,0.5,0),
            Size=UDim2.new(0,130,0,14),
            BackgroundTransparency=1,
            Text=sub, TextColor3=C.TXT3, TextSize=11, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Right
        }, topbar)
    end

    drag(topbar, root)

    -- ── BODY ────────────────────────────────────────────────
    local body = new("Frame",{
        Name="Body",
        Position=UDim2.new(0,0,0,44),
        Size=UDim2.new(1,0,1,-44),
        BackgroundTransparency=1
    }, root)

    -- SIDEBAR
    local sidebar = new("Frame",{
        Name="Sidebar",
        Size=UDim2.new(0,152,1,0),
        BackgroundColor3=C.SIDEBAR
    }, body)

    -- sidebar right border
    new("Frame",{
        AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,0,0,0),
        Size=UDim2.new(0,1,1,0), BackgroundColor3=C.LINE, BorderSizePixel=0
    }, sidebar)

    -- Logo strip at top of sidebar
    local logoStrip = new("Frame",{
        Size=UDim2.new(1,0,0,36), BackgroundTransparency=1
    }, sidebar)
    pad(0,12,0,12,logoStrip)
    list(Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 6, logoStrip)
    logoStrip.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    -- accent line left edge
    local accentBar = new("Frame",{
        Size=UDim2.fromOffset(3,20), BackgroundColor3=C.ACC, BorderSizePixel=0
    }, logoStrip)
    crn(99,accentBar)

    new("TextLabel",{
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text="flow", TextColor3=C.ACC,
        TextSize=16, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left
    }, logoStrip)

    -- divider under logo strip
    new("Frame",{
        Position=UDim2.new(0,0,0,36),
        Size=UDim2.new(1,0,0,1), BackgroundColor3=C.LINE, BorderSizePixel=0
    }, sidebar)

    -- Tab scroll list
    local tabScroll = new("ScrollingFrame",{
        Name="TabList",
        Position=UDim2.new(0,0,0,44),
        Size=UDim2.new(1,0,1,-44),
        BackgroundTransparency=1,
        ScrollBarThickness=0,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ElasticBehavior=Enum.ElasticBehavior.Never,
    }, sidebar)
    pad(6,8,8,8,tabScroll)
    list(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 4, tabScroll)
    Win._tabList = tabScroll

    -- CONTENT AREA
    local content = new("Frame",{
        Name="Content",
        Position=UDim2.new(0,152,0,0),
        Size=UDim2.new(1,-152,1,0),
        BackgroundColor3=C.SURFACE,
        ClipsDescendants=true
    }, body)
    Win._content = content
    Win._sg_overlay = sg  -- for dropdowns

    -- ── TOGGLE KEY ──────────────────────────────────────────
    UIS.InputBegan:Connect(function(i,gpe)
        if gpe then return end
        if i.KeyCode == Win._key then Win:Toggle() end
    end)

    -- ── WIN METHODS ─────────────────────────────────────────
    function Win:Toggle()
        self._visible = not self._visible
        self._root.Visible = self._visible
    end

    function Win:Destroy()
        tw(root,{BackgroundTransparency=1},0.18)
        task.delay(0.2, function() sg:Destroy() end)
    end

    function Win:SetKey(k)
        self._key = k
    end

    -- ── TAB ─────────────────────────────────────────────────
    function Win:Tab(o)
        o = o or {}
        local tabName = o.Name or ("Tab "..tostring(#self._tabs+1))
        local tabIcon = o.Icon or ""

        local T = {}
        T._win = self

        -- ── Sidebar button ──
        local sbtn = new("TextButton",{
            Name="SBtn_"..tabName,
            Size=UDim2.new(1,0,0,36),
            BackgroundColor3=C.SIDEBAR,
            AutoButtonColor=false, Text=""
        }, self._tabList)
        crn(8,sbtn)

        -- active indicator bar (left)
        local indBar = new("Frame",{
            Name="Ind",
            Position=UDim2.new(0,-2,0.18,0),
            Size=UDim2.new(0,3,0.64,0),
            BackgroundColor3=C.ACC, BackgroundTransparency=1,
            BorderSizePixel=0
        }, sbtn)
        crn(99,indBar)

        -- inner layout
        local sbtnInner = new("Frame",{
            Position=UDim2.new(0,10,0,0),
            Size=UDim2.new(1,-10,1,0),
            BackgroundTransparency=1
        }, sbtn)
        list(Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 8, sbtnInner)
        sbtnInner.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

        if tabIcon ~= "" then
            new("TextLabel",{
                Size=UDim2.fromOffset(16,36), BackgroundTransparency=1,
                Text=tabIcon, TextColor3=C.TXT2, TextSize=14, Font=Enum.Font.GothamBold,
            }, sbtnInner)
        end

        local nameLbl = new("TextLabel",{
            Name="NameLbl",
            Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
            Text=tabName, TextColor3=C.TXT2,
            TextSize=13, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left
        }, sbtnInner)

        -- ── Content page ──
        local page = new("ScrollingFrame",{
            Name="Page_"..tabName,
            Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1,
            ScrollBarThickness=3,
            ScrollBarImageColor3=C.LINE_B,
            CanvasSize=UDim2.new(0,0,0,0),
            AutomaticCanvasSize=Enum.AutomaticSize.Y,
            ElasticBehavior=Enum.ElasticBehavior.Never,
            Visible=false
        }, self._content)
        pad(14,16,16,16,page)
        list(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 8, page)

        T._page    = page
        T._sbtn    = sbtn
        T._indBar  = indBar
        T._nameLbl = nameLbl

        -- ── Activation ──
        local function activate()
            -- deactivate all
            for _,t in ipairs(self._tabs) do
                t._page.Visible = false
                tw(t._sbtn,    {BackgroundColor3=C.SIDEBAR},       0.14)
                tw(t._nameLbl, {TextColor3=C.TXT2},                0.14)
                tw(t._indBar,  {BackgroundTransparency=1},         0.14)
            end
            -- activate this
            page.Visible = true
            tw(sbtn,    {BackgroundColor3=C.CARD},    0.14)
            tw(nameLbl, {TextColor3=C.TXT},           0.14)
            tw(indBar,  {BackgroundTransparency=0},   0.14)
            self._active = T
        end

        sbtn.MouseButton1Click:Connect(activate)
        sbtn.MouseEnter:Connect(function()
            if self._active ~= T then tw(sbtn,{BackgroundColor3=C.CARD_H},0.1) end
        end)
        sbtn.MouseLeave:Connect(function()
            if self._active ~= T then tw(sbtn,{BackgroundColor3=C.SIDEBAR},0.1) end
        end)

        table.insert(self._tabs, T)
        if #self._tabs == 1 then activate() end

        -- ── Tab methods ──
        local sg_ = self._sg

        function T:Section(name) return BuildSection(page, sg_, name) end

        function T:Toggle(o)      return MakeToggle(page, o) end
        function T:Button(o)      return MakeButton(page, o) end
        function T:Slider(o)      return MakeSlider(page, o) end
        function T:Input(o)       return MakeInput(page, o) end
        function T:Dropdown(o)    return MakeDropdown(page, sg_, o) end
        function T:Keybind(o)     return MakeKeybind(page, o) end
        function T:Colorpicker(o) return MakeColorpicker(page, o) end
        function T:Label(o)       return MakeLabel(page, o) end
        function T:Divider()      return MakeDivider(page) end

        return T
    end

    return Win
end

return Flow
