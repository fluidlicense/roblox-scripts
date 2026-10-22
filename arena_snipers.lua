-- Arena de Snipers — Full Hack v1.2
-- Real Executor | sem Drawing API | BillboardGui ESP | F10 = menu
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local StarterGui       = game:GetService("StarterGui")
local lp  = Players.LocalPlayer
local cam = workspace.CurrentCamera
local RNG = Random.new()
-- ══════════════════════════════════════════════════════════
-- EVASÃO
-- ══════════════════════════════════════════════════════════
local function jitter(base, pct)
    pct = pct or 0.2
    local n = math.abs(base * pct)
    return base + RNG:NextNumber(-n, n)
end
local function humanWait(base)
    local t = jitter(math.abs(base), 0.3)
    if RNG:NextNumber() < 0.07 then t = t + RNG:NextNumber(0.2, 0.7) end
    task.wait(math.max(t, 0.01))
end
-- ══════════════════════════════════════════════════════════
-- CONFIG
-- ══════════════════════════════════════════════════════════
local CFG = {
    AimbotOn   = false,
    AutoShoot  = false,
    NoRecoil   = false,
    ESPOn      = false,
    NoclipOn   = false,
    TeamCheck  = true,
    Smoothness = 0.18,
    FOV        = 120,
    MaxDist    = 800,
    SpeedMult  = 1.0,
    Bone       = "Head",
    AimKey     = Enum.UserInputType.MouseButton2,
    ToggleKey  = Enum.KeyCode.F10,
    Accent     = Color3.fromRGB(255, 70, 70),
    AccentDark = Color3.fromRGB(180, 40, 40),
    BG         = Color3.fromRGB(12, 12, 18),
    Surface    = Color3.fromRGB(22, 22, 32),
