--[[
╔══════════════════════════════════════════════════════════╗
║  ·▸ F L O W  ◂·   v3.0.0                               ║
║  Clean. Sharp. Effortless.                               ║
║  Volt · Synapse X · KRNL · Fluxus · Evon                ║
╚══════════════════════════════════════════════════════════╝

  USAGE:
    local Flow = loadstring(game:HttpGet("URL"))()

    local Win = Flow:Window({
        Title     = "My Hub",
        Sub       = "v1.0",
        ToggleKey = Enum.KeyCode.RightShift,
    })

    -- Tabs can go directly on the window (no section)
    local Tab = Win:Tab({ Name = "Home", Icon = "⌂" })
    Tab:Toggle({ Name = "Fly", Callback = function(v) end })

    -- OR group tabs under collapsible sidebar sections (like WindUI)
    local Sec = Win:Section({ Name = "Features", Opened = true })
    local Tab2 = Sec:Tab({ Name = "Combat", Icon = "⚔" })
    Tab2:Slider({ Name = "Speed", Min=1, Max=200, Default=16 })

    -- Notifications
    Flow:Notify({ Title="Done", Body="Loaded!", Duration=4 })
]]

-- ─────────────────────────────────────────────────────────────
--  SERVICES
-- ─────────────────────────────────────────────────────────────
local cloneref = (cloneref or clonereference or function(x) return x end)
local Players  = cloneref(game:GetService("Players"))
local TweenSvc = cloneref(game:GetService("TweenService"))
local UIS      = cloneref(game:GetService("UserInputService"))
local CoreGui  = cloneref(game:GetService("CoreGui"))
local LP       = Players.LocalPlayer
local GUIP     = (gethui and gethui()) or CoreGui

-- ─────────────────────────────────────────────────────────────
--  COLOURS
-- ─────────────────────────────────────────────────────────────
local C = {
    -- Backgrounds
    WIN       = Color3.fromRGB(11,  11,  14 ),
    SIDE      = Color3.fromRGB(15,  15,  19 ),
    SURF      = Color3.fromRGB(13,  13,  17 ),
    CARD      = Color3.fromRGB(20,  20,  26 ),
    CARDH     = Color3.fromRGB(26,  26,  34 ),
    CARDP     = Color3.fromRGB(30,  30,  42 ),
    INP       = Color3.fromRGB(17,  17,  22 ),

    -- Lines
    LN        = Color3.fromRGB(30,  30,  40 ),
    LNB       = Color3.fromRGB(46,  46,  62 ),

    -- Text
    T1        = Color3.fromRGB(228, 228, 238),
    T2        = Color3.fromRGB(110, 110,  138),
    T3        = Color3.fromRGB(52,  52,  72 ),

    -- Accent
    ACC       = Color3.fromRGB(98,  148, 255),
    ACCD      = Color3.fromRGB(36,  56,  130),
    ACCG      = Color3.fromRGB(68,  108, 210),

    -- Status
    GRN       = Color3.fromRGB(68,  200, 120),
    YLW       = Color3.fromRGB(230, 170,  50),
    RED       = Color3.fromRGB(230,  68,  60),

    -- Toggle
    TOFF      = Color3.fromRGB(32,  32,  44 ),
    TON       = Color3.fromRGB(40,  82,  200),
    THM       = Color3.fromRGB(228, 228, 238),
}

-- ─────────────────────────────────────────────────────────────
--  HELPERS
-- ─────────────────────────────────────────────────────────────
local function tw(o,p,t,es,ed)
    TweenSvc:Create(o, TweenInfo.new(t or .16,
        es or Enum.EasingStyle.Quint,
        ed or Enum.EasingDirection.Out), p):Play()
end
local function new(cls,props,par)
    local o = Instance.new(cls)
    for k,v in pairs(props or {}) do o[k]=v end
    if par then o.Parent=par end
    return o
end
local function crn(r,p)  return new("UICorner",{CornerRadius=UDim.new(0,r)},p) end
local function stk(c,t,p) return new("UIStroke",{Color=c,Thickness=t or 1,
    ApplyStrokeMode=Enum.ApplyStrokeMode.Border},p) end
local function pad(tp,rt,bt,lt,p)
    return new("UIPadding",{
        PaddingTop=UDim.new(0,tp), PaddingRight=UDim.new(0,rt),
        PaddingBottom=UDim.new(0,bt), PaddingLeft=UDim.new(0,lt)},p)
end
local function lst(fd,ha,sp,p)
    local l = new("UIListLayout",{
        FillDirection=fd or Enum.FillDirection.Vertical,
        HorizontalAlignment=ha or Enum.HorizontalAlignment.Left,
        SortOrder=Enum.SortOrder.LayoutOrder,
        Padding=UDim.new(0,sp or 0)},p)
    return l
end
local function hline(parent, topOffset)
    local f = new("Frame",{
        AnchorPoint=Vector2.new(0, topOffset and 0 or 0),
        Position=topOffset and UDim2.new(0,0,0,topOffset) or UDim2.new(0,0,0,0),
        Size=UDim2.new(1,0,0,1),
        BackgroundColor3=C.LN, BorderSizePixel=0}, parent)
    return f
end

-- ─────────────────────────────────────────────────────────────
--  DRAG
-- ─────────────────────────────────────────────────────────────
local function mkDrag(handle, frame)
    local dn,ds,sp = false,nil,nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dn=true; ds=i.Position; sp=frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dn and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ds
            frame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dn=false end
    end)
end

-- ─────────────────────────────────────────────────────────────
--  NOTIFICATIONS
-- ─────────────────────────────────────────────────────────────
local _nsg = new("ScreenGui",{
    Name="FlowNotifs", IgnoreGuiInset=true,
    DisplayOrder=99999, ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling}, GUIP)
if protectgui then pcall(protectgui,_nsg) end

local _nstack = new("Frame",{
    AnchorPoint=Vector2.new(1,1),
    Position=UDim2.new(1,-14,1,-14),
    Size=UDim2.new(0,290,1,-28),
    BackgroundTransparency=1}, _nsg)
local _nl = lst(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right, 8, _nstack)
_nl.VerticalAlignment = Enum.VerticalAlignment.Bottom

local function Notify(opts)
    opts = opts or {}
    local ttl = opts.Title    or "Flow"
    local bod = opts.Body     or opts.Content or ""
    local dur = opts.Duration or 4
    local col = opts.Color    or C.ACC

    local card = new("Frame",{
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundColor3=C.CARD, BackgroundTransparency=1}, _nstack)
    crn(9,card); stk(C.LNB,1,card)

    new("Frame",{Size=UDim2.new(0,3,1,0), BackgroundColor3=col, BorderSizePixel=0}, card)

    local inner = new("Frame",{
        Position=UDim2.new(0,11,0,0), Size=UDim2.new(1,-14,1,0),
        BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y}, card)
    pad(10,10,10,0,inner)
    lst(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 3, inner)

    new("TextLabel",{
        Size=UDim2.new(1,0,0,16), BackgroundTransparency=1,
        Text=ttl, TextColor3=C.T1, TextSize=13, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left}, inner)

    if bod ~= "" then
        new("TextLabel",{
            Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1, Text=bod, TextColor3=C.T2,
            TextSize=12, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true}, inner)
    end

    local pb = new("Frame",{
        AnchorPoint=Vector2.new(0,1), Position=UDim2.new(0,0,1,0),
        Size=UDim2.new(1,0,0,2), BackgroundColor3=col, BorderSizePixel=0}, card)

    tw(card,{BackgroundTransparency=0},0.18)
    tw(pb,{Size=UDim2.new(0,0,0,2)},dur,Enum.EasingStyle.Linear)
    task.delay(dur, function()
        tw(card,{BackgroundTransparency=1},0.22)
        task.wait(0.25); card:Destroy()
    end)
end

-- ─────────────────────────────────────────────────────────────
--  ELEMENT BUILDERS
-- ─────────────────────────────────────────────────────────────

local function Row(par, h)
    local r = new("Frame",{
        Size=UDim2.new(1,0,0,h or 42),
        BackgroundColor3=C.CARD}, par)
    crn(8,r); pad(0,14,0,14,r)
    return r
end

local function RowFx(row, base)
    row.MouseEnter:Connect(function() tw(row,{BackgroundColor3=C.CARDH},0.1) end)
    row.MouseLeave:Connect(function() tw(row,{BackgroundColor3=base or C.CARD},0.1) end)
end

local function LblBlk(par, name, desc)
    local blk = new("Frame",{
        AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,0,0.5,0),
        Size=UDim2.new(0,0,0,0), AutomaticSize=Enum.AutomaticSize.XY,
        BackgroundTransparency=1}, par)
    lst(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 2, blk)
    if name and name ~= "" then
        new("TextLabel",{
            Size=UDim2.new(0,210,0,15), BackgroundTransparency=1,
            Text=name, TextColor3=C.T1, TextSize=13, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left}, blk)
    end
    if desc and desc ~= "" then
        new("TextLabel",{
            Size=UDim2.new(0,210,0,12), BackgroundTransparency=1,
            Text=desc, TextColor3=C.T2, TextSize=11, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left}, blk)
    end
    return blk
end

-- DIVIDER
local function MkDiv(par)
    new("Frame",{Name="Div",
        Size=UDim2.new(1,0,0,1), BackgroundColor3=C.LN, BorderSizePixel=0}, par)
end

-- LABEL
local function MkLabel(par, o)
    o=o or {}
    local r = new("Frame",{
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundColor3=C.CARD}, par)
    crn(8,r); pad(10,14,10,14,r)
    new("TextLabel",{
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1, Text=o.Text or "",
        TextColor3=o.Color or C.T2, TextSize=o.TextSize or 12,
        Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,
        TextWrapped=true}, r)
end

-- PARAGRAPH (like WindUI — title + body)
local function MkParagraph(par, o)
    o=o or {}
    local r = new("Frame",{
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundColor3=C.CARD}, par)
    crn(8,r); pad(12,14,12,14,r)
    lst(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 5, r)
    if o.Title and o.Title ~= "" then
        new("TextLabel",{
            Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1, Text=o.Title, TextColor3=C.T1,
            TextSize=14, Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true}, r)
    end
    if o.Desc and o.Desc ~= "" then
        new("TextLabel",{
            Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1, Text=o.Desc, TextColor3=C.T2,
            TextSize=12, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true}, r)
    end
end

-- SPACE  (empty gap between elements)
local function MkSpace(par, h)
    new("Frame",{Size=UDim2.new(1,0,0,h or 8), BackgroundTransparency=1}, par)
end

-- TOGGLE
local function MkToggle(par, o)
    o=o or {}
    local name    = o.Name or o.Title or ""
    local desc    = o.Desc or ""
    local state   = o.Default or o.Value or false
    local cb      = o.Callback or function() end
    local TW,TH,TP = 42,22,3

    local row = Row(par, desc~="" and 52 or 42)
    RowFx(row)
    LblBlk(row,name,desc)

    local track = new("Frame",{
        AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,0,0.5,0),
        Size=UDim2.fromOffset(TW,TH),
        BackgroundColor3=state and C.TON or C.TOFF}, row)
    crn(99,track); stk(C.LNB,1,track)

    local thumb = new("Frame",{
        AnchorPoint=Vector2.new(0,0.5),
        Position=state and UDim2.new(0,TW-TH+TP,0.5,0) or UDim2.new(0,TP,0.5,0),
        Size=UDim2.fromOffset(TH-TP*2,TH-TP*2),
        BackgroundColor3=C.THM}, track)
    crn(99,thumb)

    new("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text=""},row)
        .MouseButton1Click:Connect(function()
            state = not state
            tw(track,{BackgroundColor3=state and C.TON or C.TOFF},.18)
            tw(thumb,{Position=state and UDim2.new(0,TW-TH+TP,0.5,0) or UDim2.new(0,TP,0.5,0)},.18)
            cb(state)
        end)

    return {
        Set=function(_,v)
            state=v
            tw(track,{BackgroundColor3=v and C.TON or C.TOFF},.18)
            tw(thumb,{Position=v and UDim2.new(0,TW-TH+TP,0.5,0) or UDim2.new(0,TP,0.5,0)},.18)
        end,
        Get=function(_) return state end,
    }
end

-- BUTTON
local function MkButton(par, o)
    o=o or {}
    local name  = o.Name or o.Title or "Button"
    local desc  = o.Desc or ""
    local cb    = o.Callback or function() end
    local base  = o.Color or C.CARD

    local row = Row(par, desc~="" and 52 or 42)
    row.BackgroundColor3 = base
    RowFx(row, base)

    local nl = new("TextLabel",{
        AnchorPoint=Vector2.new(0,0.5),
        Position=desc~="" and UDim2.new(0,0,0.3,0) or UDim2.new(0,0,0.5,0),
        Size=UDim2.new(1,-26,0,16), BackgroundTransparency=1,
        Text=name, TextColor3=o.Color and C.WIN or C.T1,
        TextSize=13, Font=Enum.Font.GothamSemibold,
        TextXAlignment=Enum.TextXAlignment.Left}, row)

    if desc~="" then
        new("TextLabel",{
            AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,0,0.69,0),
            Size=UDim2.new(1,-26,0,12), BackgroundTransparency=1,
            Text=desc, TextColor3=o.Color and Color3.fromRGB(185,185,185) or C.T2,
            TextSize=11, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left}, row)
    end

    new("TextLabel",{
        AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,0,0.5,0),
        Size=UDim2.fromOffset(20,20), BackgroundTransparency=1,
        Text="›", TextColor3=o.Color and C.WIN or C.T3,
        TextSize=22, Font=Enum.Font.GothamBold}, row)

    local btn = new("TextButton",{
        Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text=""}, row)
    btn.MouseButton1Click:Connect(function()
        tw(row,{BackgroundColor3=C.CARDP},.07)
        task.delay(.13,function() tw(row,{BackgroundColor3=base},.12) end)
        cb()
    end)

    return {SetName=function(_,n) nl.Text=n end}
end

-- SLIDER
local function MkSlider(par, o)
    o=o or {}
    local name  = o.Name or o.Title or ""
    local mn    = o.Min or (o.Value and o.Value.Min) or 0
    local mx    = o.Max or (o.Value and o.Value.Max) or 100
    local def   = o.Default or (o.Value and o.Value.Default) or mn
    local step  = o.Step or 1
    local suf   = o.Suffix or ""
    local cb    = o.Callback or function() end
    local val   = math.clamp(def,mn,mx)

    local row = new("Frame",{Size=UDim2.new(1,0,0,60),BackgroundColor3=C.CARD},par)
    crn(8,row); pad(9,14,9,14,row)
    lst(Enum.FillDirection.Vertical,Enum.HorizontalAlignment.Left,5,row)

    local top = new("Frame",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1},row)
    new("TextLabel",{Size=UDim2.new(0.65,0,1,0),BackgroundTransparency=1,
        Text=name,TextColor3=C.T1,TextSize=13,Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left},top)
    local vl=new("TextLabel",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),
        Size=UDim2.new(0.35,0,1,0),BackgroundTransparency=1,
        Text=tostring(val)..suf,TextColor3=C.ACC,TextSize=12,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Right},top)

    local trk = new("Frame",{Size=UDim2.new(1,0,0,5),BackgroundColor3=C.TOFF},row)
    crn(99,trk)
    local fill=new("Frame",{Size=UDim2.new((val-mn)/(mx-mn),0,1,0),
        BackgroundColor3=C.ACC,BorderSizePixel=0},trk)
    crn(99,fill)
    -- thumb dot on fill end
    local dot=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(1,0,0.5,0),Size=UDim2.fromOffset(13,13),
        BackgroundColor3=C.THM,ZIndex=3},fill)
    crn(99,dot)

    local held=false
    local function setV(v)
        v=math.clamp(math.round((v-mn)/step)*step+mn,mn,mx); val=v
        local pct=(v-mn)/(mx-mn)
        tw(fill,{Size=UDim2.new(pct,0,1,0)},.07)
        vl.Text=tostring(v)..suf; cb(v)
    end
    local function fromMouse()
        local px=trk.AbsolutePosition.X; local pw=trk.AbsoluteSize.X
        setV(mn+math.clamp((UIS:GetMouseLocation().X-px)/pw,0,1)*(mx-mn))
    end
    trk.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then held=true;fromMouse() end
    end)
    UIS.InputChanged:Connect(function(i)
        if held and i.UserInputType==Enum.UserInputType.MouseMovement then fromMouse() end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then held=false end
    end)

    return {Set=function(_,v) setV(v) end, Get=function(_) return val end}
end

-- INPUT
local function MkInput(par, o)
    o=o or {}
    local name = o.Name or o.Title or ""
    local ph   = o.Placeholder or "Type here..."
    local def  = o.Default or o.Value or ""
    local cb   = o.Callback or function() end
    local live = o.LiveUpdate or false

    local h = name~="" and 62 or 44
    local row = new("Frame",{Size=UDim2.new(1,0,0,h),BackgroundColor3=C.CARD},par)
    crn(8,row); pad(8,14,8,14,row)
    lst(Enum.FillDirection.Vertical,Enum.HorizontalAlignment.Left,5,row)

    if name~="" then
        new("TextLabel",{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,
            Text=name,TextColor3=C.T1,TextSize=12,Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left},row)
    end
    local box=new("Frame",{Size=UDim2.new(1,0,0,28),BackgroundColor3=C.INP},row)
    crn(7,box); local sk=stk(C.LN,1,box); pad(0,10,0,10,box)
    local tb=new("TextBox",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        PlaceholderText=ph,PlaceholderColor3=C.T3,Text=def,TextColor3=C.T1,
        TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,
        ClearTextOnFocus=false},box)
    tb.Focused:Connect(function() tw(box,{BackgroundColor3=C.CARDH},.12); sk.Color=C.ACC end)
    tb.FocusLost:Connect(function() tw(box,{BackgroundColor3=C.INP},.12); sk.Color=C.LN; cb(tb.Text) end)
    if live then tb:GetPropertyChangedSignal("Text"):Connect(function() cb(tb.Text) end) end

    return {Set=function(_,v) tb.Text=v end, Get=function(_) return tb.Text end}
end

-- DROPDOWN
local function MkDropdown(par, sgp, o)
    o=o or {}
    local name    = o.Name or o.Title or ""
    local options = o.Options or o.Values or {}
    local multi   = o.Multi or false
    local cb      = o.Callback or function() end
    local def     = o.Default or o.Value

    -- normalise options (WindUI supports {Title=...} tables)
    local function optStr(opt)
        return type(opt)=="table" and (opt.Title or tostring(opt)) or tostring(opt)
    end

    local selected
    if multi then
        selected = (type(def)=="table") and def or (def and {def} or {})
    else
        selected = def or (options[1] and optStr(options[1])) or ""
    end

    local isOpen=false

    local row=Row(par,42); RowFx(row)
    LblBlk(row,name,"")

    local valLbl=new("TextLabel",{
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-22,0.5,0),
        Size=UDim2.new(0.5,0,0,15),BackgroundTransparency=1,
        TextColor3=C.T2,TextSize=12,Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Right,
        TextTruncate=Enum.TextTruncate.AtEnd},row)

    local arr=new("TextLabel",{
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,2,0.5,0),
        Size=UDim2.fromOffset(18,18),BackgroundTransparency=1,
        Text="⌄",TextColor3=C.T2,TextSize=15,Font=Enum.Font.GothamBold},row)

    local panel=new("Frame",{
        BackgroundColor3=C.SIDE,ZIndex=100,Visible=false,
        Size=UDim2.fromOffset(200,8),AutomaticSize=Enum.AutomaticSize.Y},sgp)
    crn(9,panel); stk(C.LNB,1,panel)

    local pInner=new("Frame",{
        Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1},panel)
    pad(5,6,5,6,pInner)
    lst(Enum.FillDirection.Vertical,Enum.HorizontalAlignment.Left,3,pInner)

    local function disp()
        if multi then
            if #selected==0 then valLbl.Text="None"
            else
                local ss={}
                for _,v in ipairs(selected) do table.insert(ss,optStr(v)) end
                valLbl.Text=table.concat(ss,", ")
            end
        else valLbl.Text=optStr(selected) end
    end
    disp()

    local function buildItems()
        for _,c in ipairs(pInner:GetChildren()) do
            if c:IsA("TextButton") or c:IsA("Frame") then c:Destroy() end
        end
        for _,opt in ipairs(options) do
            local os=optStr(opt)
            local isSel
            if multi then
                isSel=false
                for _,s in ipairs(selected) do
                    if optStr(s)==os then isSel=true;break end
                end
            else isSel=(optStr(selected)==os) end

            local item=new("TextButton",{
                Size=UDim2.new(1,0,0,32),
                BackgroundColor3=isSel and C.ACCD or C.CARD,
                AutoButtonColor=false,Text=""},pInner)
            crn(7,item); pad(0,10,0,10,item)

            new("TextLabel",{Size=UDim2.new(1,-20,1,0),BackgroundTransparency=1,
                Text=os,TextColor3=isSel and C.ACC or C.T1,
                TextSize=12,Font=isSel and Enum.Font.GothamBold or Enum.Font.Gotham,
                TextXAlignment=Enum.TextXAlignment.Left},item)
            if isSel then
                new("TextLabel",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),
                    Size=UDim2.fromOffset(16,16),BackgroundTransparency=1,
                    Text="✓",TextColor3=C.ACC,TextSize=11,Font=Enum.Font.GothamBold},item)
            end

            -- divider type support
            if type(opt)=="table" and opt.Type=="Divider" then
                item:Destroy()
                new("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=C.LN,BorderSizePixel=0},pInner)
            else
                item.MouseEnter:Connect(function() tw(item,{BackgroundColor3=C.CARDH},.08) end)
                item.MouseLeave:Connect(function() tw(item,{BackgroundColor3=isSel and C.ACCD or C.CARD},.08) end)
                item.MouseButton1Click:Connect(function()
                    if multi then
                        local found=false
                        for i,s in ipairs(selected) do
                            if optStr(s)==os then table.remove(selected,i);found=true;break end
                        end
                        if not found then table.insert(selected,opt) end
                        cb(selected); disp(); buildItems()
                    else
                        selected=opt; cb(opt); disp()
                        isOpen=false; panel.Visible=false
                        tw(arr,{Rotation=0},.14); buildItems()
                    end
                end)
                if type(opt)=="table" and opt.Callback then
                    item.MouseButton1Click:Connect(opt.Callback)
                end
            end
        end
    end
    buildItems()

    local obtn=new("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",ZIndex=3},row)
    obtn.MouseButton1Click:Connect(function()
        isOpen=not isOpen
        if isOpen then
            local rp=row.AbsolutePosition; local rs=row.AbsoluteSize
            panel.Position=UDim2.fromOffset(rp.X,rp.Y+rs.Y+4)
            panel.Size=UDim2.fromOffset(rs.X,0)
            panel.AutomaticSize=Enum.AutomaticSize.Y
            buildItems()
        end
        panel.Visible=isOpen
        tw(arr,{Rotation=isOpen and 180 or 0},.14)
    end)
    UIS.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 and isOpen then
            task.defer(function()
                local mp=UIS:GetMouseLocation()
                local pp=panel.AbsolutePosition; local ps=panel.AbsoluteSize
                if mp.X<pp.X or mp.X>pp.X+ps.X or mp.Y<pp.Y or mp.Y>pp.Y+ps.Y then
                    isOpen=false; panel.Visible=false; tw(arr,{Rotation=0},.14)
                end
            end)
        end
    end)

    local api = {
        Set=function(_,v) selected=v;disp();buildItems() end,
        Get=function(_) return selected end,
        Refresh=function(_,newOpts) options=newOpts;buildItems() end,
        Select=function(_,v)
            if multi then selected=v
            else selected=v[1] or v end
            disp();buildItems()
        end,
    }
    return api
end

-- KEYBIND
local function MkKeybind(par, o)
    o=o or {}
    local name  = o.Name or o.Title or "Keybind"
    local def   = o.Default or (o.Value and Enum.KeyCode[o.Value]) or Enum.KeyCode.Unknown
    local cb    = o.Callback or function() end
    local bound = def; local waiting=false

    local row=Row(par,42); RowFx(row); LblBlk(row,name,"")
    local kb=new("TextButton",{
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),
        Size=UDim2.fromOffset(80,26),BackgroundColor3=C.INP,AutoButtonColor=false,
        Text=bound.Name,TextColor3=C.ACC,TextSize=11,Font=Enum.Font.GothamBold},row)
    crn(6,kb); stk(C.LN,1,kb)

    kb.MouseButton1Click:Connect(function()
        if waiting then return end; waiting=true
        kb.Text="..."; tw(kb,{BackgroundColor3=C.ACCD},.12)
    end)
    UIS.InputBegan:Connect(function(i)
        if not waiting then return end
        if i.UserInputType==Enum.UserInputType.Keyboard then
            bound=i.KeyCode; kb.Text=bound.Name; waiting=false
            tw(kb,{BackgroundColor3=C.INP},.12); cb(bound)
        end
    end)
    UIS.InputBegan:Connect(function(i,gpe)
        if gpe or waiting then return end
        if i.KeyCode==bound then cb(bound) end
    end)

    return {Set=function(_,k) bound=k;kb.Text=k.Name end, Get=function(_) return bound end}
end

-- COLORPICKER
local function MkColorpicker(par, o)
    o=o or {}
    local name = o.Name or o.Title or "Color"
    local def  = o.Default or Color3.fromRGB(98,148,255)
    local cb   = o.Callback or function() end

    local row=Row(par,42); RowFx(row); LblBlk(row,name,"")

    local swatch=new("Frame",{
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),
        Size=UDim2.fromOffset(60,26),BackgroundColor3=def},row)
    crn(7,swatch); stk(C.LNB,1,swatch)

    local hexL=new("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        Text=string.format("#%02X%02X%02X",def.R*255,def.G*255,def.B*255),
        TextColor3=Color3.new(1,1,1),TextSize=10,Font=Enum.Font.GothamBold},swatch)

    local popen=false
    local pf=new("Frame",{
        AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,1,6),
        Size=UDim2.fromOffset(200,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundColor3=C.SIDE,Visible=false,ZIndex=20},row)
    crn(9,pf); stk(C.LNB,1,pf); pad(10,12,12,12,pf)
    lst(Enum.FillDirection.Vertical,Enum.HorizontalAlignment.Left,8,pf)

    local r2,g2,b2=def.R*255,def.G*255,def.B*255
    local function upCol()
        local c=Color3.fromRGB(math.floor(r2),math.floor(g2),math.floor(b2))
        swatch.BackgroundColor3=c
        hexL.Text=string.format("#%02X%02X%02X",math.floor(r2),math.floor(g2),math.floor(b2))
        cb(c)
    end

    for _,ch in ipairs({{"R",Color3.fromRGB(220,80,80)},{"G",Color3.fromRGB(70,200,110)},{"B",Color3.fromRGB(80,140,255)}}) do
        local lbl,col=ch[1],ch[2]
        local iv=(lbl=="R" and r2) or (lbl=="G" and g2) or b2
        local row2=new("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1},pf)
        new("TextLabel",{Size=UDim2.fromOffset(12,22),BackgroundTransparency=1,
            Text=lbl,TextColor3=col,TextSize=11,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left},row2)
        local sbg=new("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,18,0.5,0),
            Size=UDim2.new(1,-46,0,4),BackgroundColor3=C.TOFF},row2)
        crn(99,sbg)
        local sf=new("Frame",{Size=UDim2.new(iv/255,0,1,0),BackgroundColor3=col,BorderSizePixel=0},sbg)
        crn(99,sf)
        local nl2=new("TextLabel",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),
            Size=UDim2.fromOffset(24,22),BackgroundTransparency=1,
            Text=tostring(math.floor(iv)),TextColor3=C.T2,TextSize=10,Font=Enum.Font.GothamBold},row2)
        local hd=false
        sbg.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then hd=true end
        end)
        UIS.InputChanged:Connect(function(i)
            if hd and i.UserInputType==Enum.UserInputType.MouseMovement then
                local v=math.clamp((UIS:GetMouseLocation().X-sbg.AbsolutePosition.X)/sbg.AbsoluteSize.X,0,1)*255
                if lbl=="R" then r2=v elseif lbl=="G" then g2=v else b2=v end
                sf.Size=UDim2.new(v/255,0,1,0); nl2.Text=tostring(math.floor(v)); upCol()
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then hd=false end
        end)
    end

    new("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",ZIndex=3},swatch)
        .MouseButton1Click:Connect(function() popen=not popen; pf.Visible=popen end)

    return {
        Set=function(_,c)
            swatch.BackgroundColor3=c; r2=c.R*255; g2=c.G*255; b2=c.B*255
            hexL.Text=string.format("#%02X%02X%02X",math.floor(r2),math.floor(g2),math.floor(b2))
        end,
        Get=function(_) return swatch.BackgroundColor3 end,
    }
end

-- ─────────────────────────────────────────────────────────────
--  SECTION (in-content grouper — like WindUI's inline sections)
-- ─────────────────────────────────────────────────────────────
local function MkInlineSection(page, sgp, title)
    local wrap=new("Frame",{
        Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1},page)
    lst(Enum.FillDirection.Vertical,Enum.HorizontalAlignment.Left,0,wrap)

    -- header
    local hdr=new("Frame",{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1},wrap)
    local hl=lst(Enum.FillDirection.Horizontal,Enum.HorizontalAlignment.Left,6,hdr)
    hl.VerticalAlignment=Enum.VerticalAlignment.Center

    new("Frame",{Size=UDim2.fromOffset(3,3),BackgroundColor3=C.ACC,
        BorderSizePixel=0},hdr)
    new("TextLabel",{Size=UDim2.new(0,0,0,13),AutomaticSize=Enum.AutomaticSize.X,
        BackgroundTransparency=1,Text=string.upper(title),TextColor3=C.T3,
        TextSize=9,Font=Enum.Font.GothamBold},hdr)

    hline(wrap)

    new("Frame",{Size=UDim2.new(1,0,0,3),BackgroundTransparency=1},wrap)

    local cont=new("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1},wrap)
    lst(Enum.FillDirection.Vertical,Enum.HorizontalAlignment.Left,5,cont)

    local S={}
    function S:Toggle(o)      return MkToggle(cont,o) end
    function S:Button(o)      return MkButton(cont,o) end
    function S:Slider(o)      return MkSlider(cont,o) end
    function S:Input(o)       return MkInput(cont,o) end
    function S:Dropdown(o)    return MkDropdown(cont,sgp,o) end
    function S:Keybind(o)     return MkKeybind(cont,o) end
    function S:Colorpicker(o) return MkColorpicker(cont,o) end
    function S:Label(o)       return MkLabel(cont,o) end
    function S:Paragraph(o)   return MkParagraph(cont,o) end
    function S:Divider()      return MkDiv(cont) end
    function S:Space(h)       return MkSpace(cont,h) end
    return S
end

-- ─────────────────────────────────────────────────────────────
--  TAB CONTENT BUILDER  (returns a tab API)
-- ─────────────────────────────────────────────────────────────
local function mkTabContent(page, sgp)
    local T={}
    function T:Section(name)    return MkInlineSection(page,sgp,name) end
    function T:Toggle(o)        return MkToggle(page,o) end
    function T:Button(o)        return MkButton(page,o) end
    function T:Slider(o)        return MkSlider(page,o) end
    function T:Input(o)         return MkInput(page,o) end
    function T:Dropdown(o)      return MkDropdown(page,sgp,o) end
    function T:Keybind(o)       return MkKeybind(page,o) end
    function T:Colorpicker(o)   return MkColorpicker(page,o) end
    function T:Label(o)         return MkLabel(page,o) end
    function T:Paragraph(o)     return MkParagraph(page,o) end
    function T:Divider()        return MkDiv(page) end
    function T:Space(h)         return MkSpace(page,h) end
    return T
end

-- ─────────────────────────────────────────────────────────────
--  FLOW  (main library table)
-- ─────────────────────────────────────────────────────────────
local Flow={}
Flow.__index=Flow

Flow.Notify = Notify

-- ─────────────────────────────────────────────────────────────
--  WINDOW
-- ─────────────────────────────────────────────────────────────
function Flow:Window(opts)
    opts=opts or {}
    local title   = opts.Title    or "Flow"
    local sub     = opts.Sub      or ""
    local togKey  = opts.ToggleKey or Enum.KeyCode.RightShift
    local wSize   = opts.Size     or Vector2.new(640,448)

    local Win={}; Win._tabs={}; Win._active=nil
    Win._visible=true; Win._key=togKey; Win.Notify=Notify

    -- ScreenGui
    local sg=new("ScreenGui",{
        Name="FlowUI",ResetOnSpawn=false,IgnoreGuiInset=true,
        DisplayOrder=100,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},GUIP)
    if protectgui then pcall(protectgui,sg) end
    Win._sg=sg

    -- Root
    local root=new("Frame",{
        Name="Root",AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.fromOffset(wSize.X,wSize.Y),
        BackgroundColor3=C.WIN,ClipsDescendants=true},sg)
    crn(12,root); stk(C.LN,1,root); Win._root=root

    root.BackgroundTransparency=1
    tw(root,{BackgroundTransparency=0},.2)

    -- ── TOPBAR ──────────────────────────────────────────────
    local topbar=new("Frame",{
        Name="Topbar",Size=UDim2.new(1,0,0,44),
        BackgroundColor3=C.SIDE,ZIndex=2},root)
    pad(0,16,0,16,topbar)
    hline(topbar,44)

    -- Mac dots
    local dotRow=new("Frame",{
        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),
        Size=UDim2.new(0,56,0,12),BackgroundTransparency=1},topbar)
    lst(Enum.FillDirection.Horizontal,Enum.HorizontalAlignment.Left,8,dotRow)
    dotRow.UIListLayout.VerticalAlignment=Enum.VerticalAlignment.Center

    for i,dc in ipairs({C.RED,C.YLW,C.GRN}) do
        local dot=new("Frame",{Size=UDim2.fromOffset(11,11),BackgroundColor3=dc},dotRow)
        crn(99,dot)
        local db=new("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text=""},dot)
        if i==1 then db.MouseButton1Click:Connect(function() Win:Destroy() end) end
        if i==2 then db.MouseButton1Click:Connect(function() Win:Toggle() end) end
    end

    -- Title centred
    new("TextLabel",{
        AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,
        BackgroundTransparency=1,Text=title,TextColor3=C.T1,
        TextSize=14,Font=Enum.Font.GothamBold},topbar)

    if sub~="" then
        new("TextLabel",{
            AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),
            Size=UDim2.new(0,130,0,14),BackgroundTransparency=1,
            Text=sub,TextColor3=C.T3,TextSize=11,Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Right},topbar)
    end

    mkDrag(topbar,root)

    -- ── BODY ────────────────────────────────────────────────
    local body=new("Frame",{
        Position=UDim2.new(0,0,0,44),Size=UDim2.new(1,0,1,-44),
        BackgroundTransparency=1},root)

    -- ── SIDEBAR ─────────────────────────────────────────────
    local SIDEBAR_W = 168
    local sidebar=new("Frame",{
        Name="Sidebar",Size=UDim2.new(0,SIDEBAR_W,1,0),
        BackgroundColor3=C.SIDE},body)
    new("Frame",{
        AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),
        Size=UDim2.new(0,1,1,0),BackgroundColor3=C.LN,BorderSizePixel=0},sidebar)

    -- Sidebar scrollable list
    local sideScroll=new("ScrollingFrame",{
        Name="SideList",
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        ScrollBarThickness=0,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ElasticBehavior=Enum.ElasticBehavior.Never},sidebar)
    pad(6,7,10,7,sideScroll)
    lst(Enum.FillDirection.Vertical,Enum.HorizontalAlignment.Left,2,sideScroll)
    Win._sideScroll=sideScroll

    -- ── CONTENT AREA ────────────────────────────────────────
    local content=new("Frame",{
        Name="Content",
        Position=UDim2.new(0,SIDEBAR_W,0,0),
        Size=UDim2.new(1,-SIDEBAR_W,1,0),
        BackgroundColor3=C.SURF,ClipsDescendants=true},body)
    Win._content=content

    -- ── TOGGLE KEY ──────────────────────────────────────────
    UIS.InputBegan:Connect(function(i,gpe)
        if gpe then return end
        if i.KeyCode==Win._key then Win:Toggle() end
    end)

    function Win:Toggle()
        self._visible=not self._visible; self._root.Visible=self._visible
    end
    function Win:Destroy()
        tw(root,{BackgroundTransparency=1},.18)
        task.delay(.2,function() sg:Destroy() end)
    end
    function Win:SetKey(k) self._key=k end

    -- ── INTERNAL: register + activate tab ───────────────────
    local allTabs={}

    local function mkTabBtn(name, icon, parent)
        local sbtn=new("TextButton",{
            Size=UDim2.new(1,0,0,34),
            BackgroundColor3=C.SIDE,
            AutoButtonColor=false,Text=""},parent)
        crn(8,sbtn)

        -- left indicator
        local ind=new("Frame",{
            Position=UDim2.new(0,0,0.15,0),
            Size=UDim2.new(0,3,0.7,0),
            BackgroundColor3=C.ACC,BackgroundTransparency=1,
            BorderSizePixel=0},sbtn)
        crn(99,ind)

        local inner=new("Frame",{
            Position=UDim2.new(0,10,0,0),Size=UDim2.new(1,-10,1,0),
            BackgroundTransparency=1},sbtn)
        local il=lst(Enum.FillDirection.Horizontal,Enum.HorizontalAlignment.Left,7,inner)
        il.VerticalAlignment=Enum.VerticalAlignment.Center

        if icon and icon~="" then
            new("TextLabel",{Size=UDim2.fromOffset(16,34),BackgroundTransparency=1,
                Text=icon,TextColor3=C.T2,TextSize=14,Font=Enum.Font.GothamBold},inner)
        end
        local nl=new("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
            Text=name,TextColor3=C.T2,TextSize=12,Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left},inner)

        return sbtn,ind,nl
    end

    local function mkPage()
        return new("ScrollingFrame",{
            Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
            ScrollBarThickness=3,ScrollBarImageColor3=C.LNB,
            CanvasSize=UDim2.new(0,0,0,0),
            AutomaticCanvasSize=Enum.AutomaticSize.Y,
            ElasticBehavior=Enum.ElasticBehavior.Never,
            Visible=false},content)
    end

    local function activateTab(T)
        for _,t in ipairs(allTabs) do
            t._page.Visible=false
            tw(t._sbtn,{BackgroundColor3=C.SIDE},.13)
            tw(t._nl,{TextColor3=C.T2},.13)
            tw(t._ind,{BackgroundTransparency=1},.13)
        end
        T._page.Visible=true
        tw(T._sbtn,{BackgroundColor3=C.CARD},.13)
        tw(T._nl,{TextColor3=C.T1},.13)
        tw(T._ind,{BackgroundTransparency=0},.13)
        Win._active=T
    end

    local function registerTab(T)
        table.insert(allTabs,T)
        if #allTabs==1 then activateTab(T) end
    end

    -- ── PUBLIC: Win:Tab() — top-level (no section) ──────────
    function Win:Tab(o)
        o=o or {}
        local name=o.Name or o.Title or "Tab"
        local icon=o.Icon or ""

        local page=mkPage(); pad(14,16,16,16,page)
        lst(Enum.FillDirection.Vertical,Enum.HorizontalAlignment.Left,7,page)

        local sbtn,ind,nl=mkTabBtn(name,icon,sideScroll)
        local T=mkTabContent(page,sg)
        T._page=page; T._sbtn=sbtn; T._ind=ind; T._nl=nl

        sbtn.MouseButton1Click:Connect(function() activateTab(T) end)
        sbtn.MouseEnter:Connect(function()
            if Win._active~=T then tw(sbtn,{BackgroundColor3=C.CARDH},.1) end
        end)
        sbtn.MouseLeave:Connect(function()
            if Win._active~=T then tw(sbtn,{BackgroundColor3=C.SIDE},.1) end
        end)

        registerTab(T)
        return T
    end

    -- ── PUBLIC: Win:Section() — collapsible sidebar section ─
    function Win:Section(o)
        o=o or {}
        local secName  = o.Name or o.Title or "Section"
        local opened   = o.Opened ~= false  -- default open

        -- Section header button in sidebar
        local secFrame=new("Frame",{
            Size=UDim2.new(1,0,0,32),
            BackgroundTransparency=1},sideScroll)

        local hdrBtn=new("TextButton",{
            Size=UDim2.new(1,0,1,0),
            BackgroundColor3=C.SIDE,
            AutoButtonColor=false,Text=""},secFrame)

        pad(0,8,0,8,hdrBtn)
        local hil=lst(Enum.FillDirection.Horizontal,Enum.HorizontalAlignment.Left,6,hdrBtn)
        hil.VerticalAlignment=Enum.VerticalAlignment.Center

        -- chevron
        local chev=new("TextLabel",{
            Size=UDim2.fromOffset(12,32),BackgroundTransparency=1,
            Text=opened and "▾" or "▸",TextColor3=C.T3,
            TextSize=10,Font=Enum.Font.GothamBold},hdrBtn)

        new("TextLabel",{
            Size=UDim2.new(1,-18,1,0),BackgroundTransparency=1,
            Text=string.upper(secName),TextColor3=C.T3,
            TextSize=9,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left},hdrBtn)

        -- Tab container inside section (collapses/expands)
        local tabContainer=new("Frame",{
            Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1,Visible=opened},sideScroll)
        pad(0,0,4,0,tabContainer)
        lst(Enum.FillDirection.Vertical,Enum.HorizontalAlignment.Left,2,tabContainer)

        local isOpen=opened
        local function setOpen(v)
            isOpen=v; tabContainer.Visible=v
            chev.Text=v and "▾" or "▸"
        end
        hdrBtn.MouseButton1Click:Connect(function() setOpen(not isOpen) end)

        -- Thin separator under section header
        new("Frame",{
            Size=UDim2.new(1,0,0,1),BackgroundColor3=C.LN,BorderSizePixel=0},sideScroll)

        local Sec={}

        function Sec:Tab(o2)
            o2=o2 or {}
            local name=o2.Name or o2.Title or "Tab"
            local icon=o2.Icon or ""

            local page=mkPage(); pad(14,16,16,16,page)
            lst(Enum.FillDirection.Vertical,Enum.HorizontalAlignment.Left,7,page)

            local sbtn,ind,nl=mkTabBtn(name,icon,tabContainer)
            local T=mkTabContent(page,sg)
            T._page=page; T._sbtn=sbtn; T._ind=ind; T._nl=nl

            sbtn.MouseButton1Click:Connect(function() activateTab(T) end)
            sbtn.MouseEnter:Connect(function()
                if Win._active~=T then tw(sbtn,{BackgroundColor3=C.CARDH},.1) end
            end)
            sbtn.MouseLeave:Connect(function()
                if Win._active~=T then tw(sbtn,{BackgroundColor3=C.SIDE},.1) end
            end)

            registerTab(T)
            return T
        end

        Sec.Open  = function() setOpen(true) end
        Sec.Close = function() setOpen(false) end

        return Sec
    end

    return Win
end

return Flow
