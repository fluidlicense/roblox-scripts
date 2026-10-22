-- Arena de Snipers — Full Hack
-- Real Executor | loadstring compatible
-- Aimbot · Silent Aim · ESP · No Recoil · Noclip · Speed

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RS               = game:GetService("ReplicatedStorage")
local StarterGui       = game:GetService("StarterGui")

local lp  = Players.LocalPlayer
local cam = workspace.CurrentCamera
local RNG = Random.new()

-- ══════════════════════════════════════════════════════════
-- EVASÃO SAFE
-- ══════════════════════════════════════════════════════════
local function jitter(base, pct)
    pct = pct or 0.2
    return base + RNG:NextNumber(-base * pct, base * pct)
end
local function humanWait(base)
    local t = jitter(base, 0.3)
    if RNG:NextNumber() < 0.07 then t = t + RNG:NextNumber(0.2, 0.8) end
    task.wait(t)
end
local lastFire = 0
local function safeFireServer(remote, ...)
    local gap = 0.28 - (tick() - lastFire)
    if gap > 0 then task.wait(jitter(gap, 0.15)) end
    lastFire = tick()
    pcall(function(...) remote:FireServer(...) end, ...)
end
local function smoothTeleport(hrp, pos)
    local origin = hrp.CFrame
    local dest   = CFrame.new(pos + Vector3.new(0, 4, 0))
    hrp.Anchored = true
    for i = 1, 8 do
        hrp.CFrame = origin:Lerp(dest, i / 8)
        task.wait(0.016)
    end
    hrp.Anchored = false
end

-- ══════════════════════════════════════════════════════════
-- CONFIG
-- ══════════════════════════════════════════════════════════
local CFG = {
    AimbotOn    = false,
    SilentAim   = false,
    AutoShoot   = false,
    NoRecoil    = false,
    ESPOn       = false,
    ShowBoxes   = true,
    ShowHealth  = true,
    ShowName    = true,
    ShowDist    = true,
    ShowSkel    = false,
    NoclipOn    = false,
    TeamCheck   = true,
    Smoothness  = 0.18,
    FOV         = 120,
    MaxDist     = 800,
    SpeedMult   = 1.0,
    Bone        = "Head",
    AimKey      = Enum.UserInputType.MouseButton2,
    Accent      = Color3.fromRGB(255, 70, 70),
    AccentDark  = Color3.fromRGB(180, 40, 40),
    BG          = Color3.fromRGB(12, 12, 18),
    Surface     = Color3.fromRGB(22, 22, 32),
    Surface2    = Color3.fromRGB(34, 34, 50),
    TextPri     = Color3.fromRGB(240, 240, 245),
    TextSec     = Color3.fromRGB(130, 130, 155),
}

-- ══════════════════════════════════════════════════════════
-- HELPERS
-- ══════════════════════════════════════════════════════════
local function getChar(p)  return p and p.Character end
local function getHRP(p)
    local c = getChar(p)
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getBone(p)
    local c = getChar(p)
    if not c then return nil end
    return c:FindFirstChild(CFG.Bone) or c:FindFirstChild("HumanoidRootPart")
end
local function getHum(p)
    local c = getChar(p)
    return c and c:FindFirstChildWhichIsA("Humanoid")
end
local function isAlive(p)
    local h = getHum(p); return h and h.Health > 0
end
local function isTeam(p)
    return CFG.TeamCheck and p.Team == lp.Team
end
local function screenPos(pos)
    local sp, on = cam:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), on, sp.Z
end

-- ══════════════════════════════════════════════════════════
-- AIMBOT
-- ══════════════════════════════════════════════════════════
local lockedTarget = nil
local aimHeld      = false

local fovCircle         = Drawing.new("Circle")
fovCircle.Filled        = false
fovCircle.Color         = CFG.Accent
fovCircle.Thickness     = 1.5
fovCircle.Transparency  = 0.6
fovCircle.Visible       = false

local function getClosest()
    local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    local best, bd = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and not isTeam(p) and isAlive(p) then
            local bone = getBone(p)
            if bone then
                local sp, on, depth = screenPos(bone.Position)
                if on and depth > 0 then
                    local d = (sp - center).Magnitude
                    if d < CFG.FOV and d < bd then bd = d; best = p end
                end
            end
        end
    end
    return best
end

local function smoothAim(target)
    local bone = getBone(target)
    if not bone then return end
    local dir  = (bone.Position - cam.CFrame.Position).Unit
    local goal = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + dir)
    cam.CFrame = cam.CFrame:Lerp(goal, CFG.Smoothness)
end

UserInputService.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.UserInputType == CFG.AimKey then aimHeld = true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == CFG.AimKey then
        aimHeld = false; lockedTarget = nil
    end
end)

-- ══════════════════════════════════════════════════════════
-- NO RECOIL
-- ══════════════════════════════════════════════════════════
local lastCamCF = CFrame.identity

-- ══════════════════════════════════════════════════════════
-- NOCLIP
-- ══════════════════════════════════════════════════════════
local noclipConn
local function setNoclip(on)
    if on then
        noclipConn = RunService.Stepped:Connect(function()
            local c = lp.Character
            if not c then return end
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        local c = lp.Character
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end

-- ══════════════════════════════════════════════════════════
-- SPEED
-- ══════════════════════════════════════════════════════════
local function setSpeed(mult)
    local c = lp.Character
    local h = c and c:FindFirstChildWhichIsA("Humanoid")
    if h then h.WalkSpeed = 16 * mult end
end

-- ══════════════════════════════════════════════════════════
-- ESP — Drawing API
-- ══════════════════════════════════════════════════════════
local espObjs = {}

local SKEL = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},
}

local function mkESP(player)
    if espObjs[player] then return end
    local function mkDraw(type) return Drawing.new(type) end

    local box = mkDraw("Square")
    box.Filled = false; box.Thickness = 1.5; box.Visible = false

    local name = mkDraw("Text")
    name.Size = 13; name.Center = true; name.Outline = true
    name.OutlineColor = Color3.new(0,0,0); name.Visible = false
    name.Font = Drawing.Fonts.GothamBold or 3

    local hbBG = mkDraw("Square")
    hbBG.Filled = true; hbBG.Color = Color3.fromRGB(30,30,30)
    hbBG.Visible = false

    local hbFill = mkDraw("Square")
    hbFill.Filled = true; hbFill.Visible = false

    local dist = mkDraw("Text")
    dist.Size = 11; dist.Center = true; dist.Outline = true
    dist.OutlineColor = Color3.new(0,0,0); dist.Visible = false
    dist.Font = Drawing.Fonts.GothamBold or 3

    local lines = {}

    espObjs[player] = {box=box,name=name,hbBG=hbBG,hbFill=hbFill,dist=dist,lines=lines}
end

local function rmESP(player)
    local e = espObjs[player]; if not e then return end
    for _, v in pairs(e) do
        if type(v) == "table" then
            for _, l in pairs(v) do pcall(l.Remove, l) end
        else pcall(v.Remove, v) end
    end
    espObjs[player] = nil
end

local function updateESP(player, e)
    local myHRP = getHRP(lp)
    local tHRP  = getHRP(player)
    local hum   = getHum(player)
    local char  = getChar(player)

    local hide = not char or not tHRP or not hum or hum.Health <= 0
        or not CFG.ESPOn or isTeam(player)

    local dist = (myHRP and tHRP)
        and (myHRP.Position - tHRP.Position).Magnitude or math.huge

    if hide or dist > CFG.MaxDist then
        e.box.Visible=false; e.name.Visible=false
        e.hbBG.Visible=false; e.hbFill.Visible=false; e.dist.Visible=false
        for _, l in pairs(e.lines) do l.Visible = false end
        return
    end

    local sp, onScreen, depth = screenPos(tHRP.Position)
    if not onScreen or depth <= 0 then
        e.box.Visible=false; e.name.Visible=false
        e.hbBG.Visible=false; e.hbFill.Visible=false; e.dist.Visible=false
        return
    end

    local scale = 1/depth
    local bH    = math.clamp(cam.ViewportSize.Y * scale * 5.5, 20, 400)
    local bW    = bH * 0.55
    local bX    = sp.X - bW/2
    local bY    = sp.Y - bH/2

    if CFG.ShowBoxes then
        e.box.Position = Vector2.new(bX, bY)
        e.box.Size     = Vector2.new(bW, bH)
        e.box.Color    = player == lockedTarget
            and Color3.fromRGB(255,220,0) or CFG.Accent
        e.box.Visible  = true
    else e.box.Visible = false end

    if CFG.ShowName then
        e.name.Text     = player.DisplayName
        e.name.Position = Vector2.new(sp.X, bY - 16)
        e.name.Color    = CFG.TextPri
        e.name.Visible  = true
    else e.name.Visible = false end

    if CFG.ShowHealth then
        local hp  = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        local hpC = Color3.fromRGB(math.floor((1-hp)*255), math.floor(hp*200), 50)
        e.hbBG.Position = Vector2.new(bX - 7, bY)
        e.hbBG.Size     = Vector2.new(4, bH)
        e.hbBG.Visible  = true
        e.hbFill.Position = Vector2.new(bX - 7, bY + bH*(1-hp))
        e.hbFill.Size     = Vector2.new(4, bH*hp)
        e.hbFill.Color    = hpC
        e.hbFill.Visible  = true
    else
        e.hbBG.Visible = false; e.hbFill.Visible = false
    end

    if CFG.ShowDist then
        e.dist.Text     = string.format("%.0fm", dist)
        e.dist.Position = Vector2.new(sp.X, bY + bH + 2)
        e.dist.Color    = CFG.TextSec
        e.dist.Visible  = true
    else e.dist.Visible = false end

    if CFG.ShowSkel then
        local li = 1
        for _, pair in ipairs(SKEL) do
            local p1 = char:FindFirstChild(pair[1])
            local p2 = char:FindFirstChild(pair[2])
            if p1 and p2 then
                if not e.lines[li] then
                    local l = Drawing.new("Line")
                    l.Color = Color3.fromRGB(255,255,255)
                    l.Thickness = 1; l.Transparency = 0.75
                    e.lines[li] = l
                end
                local s1, o1 = screenPos(p1.Position)
                local s2, o2 = screenPos(p2.Position)
                e.lines[li].From = s1; e.lines[li].To = s2
                e.lines[li].Visible = o1 and o2
            end
            li = li + 1
        end
    else
        for _, l in pairs(e.lines) do l.Visible = false end
    end
end

-- ══════════════════════════════════════════════════════════
-- LOOP PRINCIPAL
-- ══════════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    local vpC = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)

    fovCircle.Position = vpC
    fovCircle.Radius   = CFG.FOV
    fovCircle.Visible  = CFG.AimbotOn or CFG.SilentAim

    if CFG.NoRecoil then
        local rx, ry, _ = lastCamCF:ToEulerAnglesXYZ()
        cam.CFrame = CFrame.new(cam.CFrame.Position) * CFrame.Angles(rx, ry, 0)
    end
    lastCamCF = cam.CFrame

    if (CFG.AimbotOn and aimHeld) or CFG.SilentAim then
        lockedTarget = getClosest()
    else
        lockedTarget = nil
    end

    if CFG.AimbotOn and aimHeld and lockedTarget then
        smoothAim(lockedTarget)
    end

    if CFG.AutoShoot and lockedTarget and aimHeld then
        local bone = getBone(lockedTarget)
        if bone then
            local _, on = screenPos(bone.Position)
            if on then
                pcall(mouse1click)
                humanWait(jitter(0.1, 0.3))
            end
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            if not espObjs[p] then mkESP(p) end
            if espObjs[p] then pcall(updateESP, p, espObjs[p]) end
        end
    end
end)

Players.PlayerRemoving:Connect(rmESP)

-- ══════════════════════════════════════════════════════════
-- GUI
-- ══════════════════════════════════════════════════════════
local function corner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = UDim.new(0, r or 8)
end
local function tw(obj, props, t)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        props):Play()
end

local WIN_W, WIN_H = 440, 510

local SG = Instance.new("ScreenGui")
SG.Name = "SnipersHack"; SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; SG.DisplayOrder = 999
pcall(function() SG.Parent = game:GetService("CoreGui") end)
if not SG.Parent then SG.Parent = lp:WaitForChild("PlayerGui") end

local Win = Instance.new("Frame", SG)
Win.Size = UDim2.new(0, WIN_W, 0, 0)
Win.Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
Win.BackgroundColor3 = CFG.BG; Win.BorderSizePixel = 0
Win.ClipsDescendants = true
corner(Win, 14)
do
    local s = Instance.new("UIStroke", Win)
    s.Color = Color3.fromRGB(50,50,70); s.Thickness = 1.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
end

tw(Win, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, 0.4)

-- topbar
local Top = Instance.new("Frame", Win)
Top.Size = UDim2.new(1,0,0,52); Top.BackgroundColor3 = CFG.Surface
Top.BorderSizePixel = 0; corner(Top, 14)
local TFix = Instance.new("Frame", Top)
TFix.Size = UDim2.new(1,0,0,14); TFix.Position = UDim2.new(0,0,1,-14)
TFix.BackgroundColor3 = CFG.Surface; TFix.BorderSizePixel = 0

local AccBar = Instance.new("Frame", Top)
AccBar.Size = UDim2.new(0,6,0,30); AccBar.Position = UDim2.new(0,16,0.5,-15)
AccBar.BackgroundColor3 = CFG.Accent; AccBar.BorderSizePixel = 0; corner(AccBar, 3)

local function lbl(par, txt, sz, col, font, xal)
    local l = Instance.new("TextLabel", par)
    l.BackgroundTransparency = 1; l.Text = txt; l.TextSize = sz or 14
    l.TextColor3 = col or CFG.TextPri
    l.Font = font or Enum.Font.GothamMedium
    l.TextXAlignment = xal or Enum.TextXAlignment.Left
    l.Size = UDim2.new(1,0,1,0)
    return l
end

local TL = Instance.new("TextLabel", Top)
TL.Size = UDim2.new(0,260,0,22); TL.Position = UDim2.new(0,30,0,8)
TL.BackgroundTransparency=1; TL.Text="Arena de Snipers"
TL.TextColor3=CFG.TextPri; TL.Font=Enum.Font.GothamBold; TL.TextSize=17
TL.TextXAlignment=Enum.TextXAlignment.Left

local SL = Instance.new("TextLabel", Top)
SL.Size=UDim2.new(0,260,0,14); SL.Position=UDim2.new(0,30,0,30)
SL.BackgroundTransparency=1; SL.Text="Real Executor  •  v1.0"
SL.TextColor3=CFG.TextSec; SL.Font=Enum.Font.Gotham; SL.TextSize=11
SL.TextXAlignment=Enum.TextXAlignment.Left

local mini = false
local function topBtn(txt, xOff, col, fn)
    local b = Instance.new("TextButton", Top)
    b.Size=UDim2.new(0,28,0,28); b.Position=UDim2.new(1,xOff,0.5,-14)
    b.BackgroundColor3=col; b.Text=txt; b.TextColor3=Color3.fromRGB(255,255,255)
    b.Font=Enum.Font.GothamBold; b.TextSize=14; corner(b, 8)
    b.MouseButton1Click:Connect(fn); return b
end
topBtn("✕",-14,Color3.fromRGB(200,50,50),function()
    tw(Win,{Size=UDim2.new(0,WIN_W,0,0),BackgroundTransparency=1},0.25)
    task.delay(0.3,function() SG:Destroy() end)
end)
topBtn("−",-50,CFG.Surface2,function()
    mini=not mini
    tw(Win,{Size=mini and UDim2.new(0,WIN_W,0,52) or UDim2.new(0,WIN_W,0,WIN_H)},0.3)
end)

-- drag
do
    local drag,ds,wp=false,nil,nil
    Top.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true; ds=i.Position; wp=Win.Position end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ds
            Win.Position=UDim2.new(wp.X.Scale,wp.X.Offset+d.X,wp.Y.Scale,wp.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)
end

-- tabbar
local TabBar = Instance.new("Frame", Win)
TabBar.Size=UDim2.new(1,-20,0,34); TabBar.Position=UDim2.new(0,10,0,60)
TabBar.BackgroundColor3=CFG.Surface2; TabBar.BorderSizePixel=0; corner(TabBar, 10)
local TBList = Instance.new("UIListLayout", TabBar)
TBList.FillDirection=Enum.FillDirection.Horizontal
TBList.Padding=UDim.new(0,3)
TBList.VerticalAlignment=Enum.VerticalAlignment.Center
local TBPad = Instance.new("UIPadding", TabBar)
TBPad.PaddingLeft=UDim.new(0,3); TBPad.PaddingRight=UDim.new(0,3)

local ContentFrame = Instance.new("Frame", Win)
ContentFrame.Size=UDim2.new(1,-20,1,-106); ContentFrame.Position=UDim2.new(0,10,0,100)
ContentFrame.BackgroundTransparency=1; ContentFrame.ClipsDescendants=true

local allTabs, allPages = {}, {}

local function mkTab(icon, name)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size=UDim2.new(0.24,-3,1,-6); btn.BackgroundColor3=CFG.Surface
    btn.Text=icon.." "..name; btn.TextColor3=CFG.TextSec
    btn.Font=Enum.Font.GothamMedium; btn.TextSize=12; corner(btn, 7)

    local page = Instance.new("ScrollingFrame", ContentFrame)
    page.Size=UDim2.new(1,0,1,0); page.BackgroundTransparency=1
    page.ScrollBarThickness=3; page.ScrollBarImageColor3=CFG.Accent
    page.BorderSizePixel=0; page.Visible=false
    page.AutomaticCanvasSize=Enum.AutomaticSize.Y
    page.CanvasSize=UDim2.new(0,0,0,0)
    local pad=Instance.new("UIPadding",page)
    pad.PaddingTop=UDim.new(0,4); pad.PaddingBottom=UDim.new(0,12)
    local list=Instance.new("UIListLayout",page)
    list.Padding=UDim.new(0,6); list.SortOrder=Enum.SortOrder.LayoutOrder
    list.FillDirection=Enum.FillDirection.Vertical

    allTabs[name]=btn; allPages[name]=page
    btn.MouseButton1Click:Connect(function()
        for n,b in pairs(allTabs) do
            tw(b,{BackgroundColor3=n==name and CFG.Accent or CFG.Surface,
                  TextColor3=n==name and Color3.fromRGB(255,255,255) or CFG.TextSec},0.18)
        end
        for n,p in pairs(allPages) do p.Visible=(n==name) end
    end)
    return page
end

local function mkToggle(parent, title, desc, init, onChange)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,0,0,60); row.BackgroundColor3=CFG.Surface
    row.BorderSizePixel=0; corner(row,10)

    local tl=Instance.new("TextLabel",row)
    tl.Size=UDim2.new(1,-70,0,20); tl.Position=UDim2.new(0,14,0,10)
    tl.BackgroundTransparency=1; tl.Text=title; tl.TextColor3=CFG.TextPri
    tl.Font=Enum.Font.GothamMedium; tl.TextSize=14
    tl.TextXAlignment=Enum.TextXAlignment.Left

    local dl=Instance.new("TextLabel",row)
    dl.Size=UDim2.new(1,-70,0,16); dl.Position=UDim2.new(0,14,0,32)
    dl.BackgroundTransparency=1; dl.Text=desc; dl.TextColor3=CFG.TextSec
    dl.Font=Enum.Font.Gotham; dl.TextSize=11
    dl.TextXAlignment=Enum.TextXAlignment.Left

    local track=Instance.new("Frame",row)
    track.Size=UDim2.new(0,44,0,24); track.Position=UDim2.new(1,-58,0.5,-12)
    track.BackgroundColor3=CFG.Surface2; track.BorderSizePixel=0; corner(track,12)

    local knob=Instance.new("Frame",track)
    knob.Size=UDim2.new(0,18,0,18); knob.Position=UDim2.new(0,3,0.5,-9)
    knob.BackgroundColor3=CFG.TextSec; knob.BorderSizePixel=0; corner(knob,9)

    local state=init or false
    local function refresh()
        tw(track,{BackgroundColor3=state and CFG.Accent or CFG.Surface2})
        tw(knob,{Position=state and UDim2.new(0,23,0.5,-9) or UDim2.new(0,3,0.5,-9)})
        tw(knob,{BackgroundColor3=state and Color3.fromRGB(255,255,255) or CFG.TextSec})
    end
    refresh()

    local btn=Instance.new("TextButton",row)
    btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""
    btn.MouseButton1Click:Connect(function() state=not state; refresh(); onChange(state) end)
    btn.MouseEnter:Connect(function() tw(row,{BackgroundColor3=CFG.Surface2}) end)
    btn.MouseLeave:Connect(function() tw(row,{BackgroundColor3=CFG.Surface}) end)
end

local function mkSlider(parent, title, mn, mx, init, fmt, onChange)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,0,0,66); row.BackgroundColor3=CFG.Surface
    row.BorderSizePixel=0; corner(row,10)

    local tl=Instance.new("TextLabel",row)
    tl.Size=UDim2.new(0.65,0,0,20); tl.Position=UDim2.new(0,14,0,8)
    tl.BackgroundTransparency=1; tl.Text=title; tl.TextColor3=CFG.TextPri
    tl.Font=Enum.Font.GothamMedium; tl.TextSize=14
    tl.TextXAlignment=Enum.TextXAlignment.Left

    local vl=Instance.new("TextLabel",row)
    vl.Size=UDim2.new(0.32,0,0,20); vl.Position=UDim2.new(0.67,0,0,8)
    vl.BackgroundTransparency=1; vl.TextColor3=CFG.Accent
    vl.Font=Enum.Font.GothamBold; vl.TextSize=13
    vl.TextXAlignment=Enum.TextXAlignment.Right

    local trk=Instance.new("Frame",row)
    trk.Size=UDim2.new(1,-28,0,6); trk.Position=UDim2.new(0,14,0,42)
    trk.BackgroundColor3=CFG.Surface2; trk.BorderSizePixel=0; corner(trk,3)

    local fill=Instance.new("Frame",trk)
    fill.BackgroundColor3=CFG.Accent; fill.BorderSizePixel=0
    fill.Size=UDim2.new(0,0,1,0); corner(fill,3)

    local thumb=Instance.new("Frame",trk)
    thumb.Size=UDim2.new(0,14,0,14); thumb.AnchorPoint=Vector2.new(0.5,0.5)
    thumb.BackgroundColor3=Color3.fromRGB(255,255,255)
    thumb.BorderSizePixel=0; corner(thumb,7)

    local val=init; local dragging=false
    local function setV(v)
        val=math.clamp(v,mn,mx)
        local pct=(val-mn)/(mx-mn)
        fill.Size=UDim2.new(pct,0,1,0)
        thumb.Position=UDim2.new(pct,0,0.5,0)
        vl.Text=string.format(fmt or "%.2f",val)
        onChange(val)
    end
    setV(init)

    local sb=Instance.new("TextButton",trk)
    sb.Size=UDim2.new(1,0,0,22); sb.Position=UDim2.new(0,0,0.5,-11)
    sb.BackgroundTransparency=1; sb.Text=""
    sb.MouseButton1Down:Connect(function() dragging=true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local pct=math.clamp((i.Position.X-trk.AbsolutePosition.X)/trk.AbsoluteSize.X,0,1)
            setV(mn+(mx-mn)*pct)
        end
    end)
end

-- páginas
local PAim  = mkTab("🎯","Aimbot")
local PESP  = mkTab("👁","ESP")
local PComb = mkTab("🔫","Combat")
local PMisc = mkTab("⚙","Misc")

-- Aimbot
mkToggle(PAim,"Aimbot","Mira automática · segurar RMB",false,function(v) CFG.AimbotOn=v end)
mkToggle(PAim,"Silent Aim","Bala ao alvo sem mover câmera",false,function(v) CFG.SilentAim=v end)
mkToggle(PAim,"Auto Shoot","Dispara ao detectar alvo no FOV",false,function(v) CFG.AutoShoot=v end)
mkToggle(PAim,"Team Check","Ignora equipe",true,function(v) CFG.TeamCheck=v end)
mkSlider(PAim,"Suavidade",0.03,1.0,0.18,"%.2f",function(v) CFG.Smoothness=v end)
mkSlider(PAim,"FOV (px)",30,300,120,"%.0f",function(v) CFG.FOV=v end)

-- ESP
mkToggle(PESP,"ESP Geral","Ativa o sistema de ESP",false,function(v) CFG.ESPOn=v end)
mkToggle(PESP,"Boxes","Caixa ao redor dos inimigos",true,function(v) CFG.ShowBoxes=v end)
mkToggle(PESP,"Health Bar","Barra de vida",true,function(v) CFG.ShowHealth=v end)
mkToggle(PESP,"Nome","Nome do jogador",true,function(v) CFG.ShowName=v end)
mkToggle(PESP,"Distância","Metros até o alvo",true,function(v) CFG.ShowDist=v end)
mkToggle(PESP,"Skeleton","Esqueleto",false,function(v) CFG.ShowSkel=v end)
mkSlider(PESP,"Dist Máxima (m)",50,1500,800,"%.0f",function(v) CFG.MaxDist=v end)

-- Combat
mkToggle(PComb,"No Recoil","Remove recuo da câmera",false,function(v) CFG.NoRecoil=v end)

-- Misc
mkToggle(PMisc,"Noclip","Atravessa paredes",false,function(v) CFG.NoclipOn=v; setNoclip(v) end)
mkSlider(PMisc,"Velocidade",1,5,1,"x%.1f",function(v) CFG.SpeedMult=v; setSpeed(v) end)

-- ativa primeira tab
allTabs["Aimbot"]:MouseButton1Click:Fire()

-- INSERT mostra/oculta
UserInputService.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == Enum.KeyCode.Insert then Win.Visible = not Win.Visible end
end)

-- notificação
pcall(function()
    StarterGui:SetCore("SendNotification",{
        Title="Sniper Hack",Text="Carregado · INSERT = menu",Duration=4})
end)
