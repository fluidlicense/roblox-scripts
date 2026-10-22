-- Arena de Snipers — Full Hack v1.1 (fixed)
-- Real Executor | loadstring compatible
-- fix: Drawing.Fonts fallback · mouse1click pcall · F10 keybind · GUI parent robusto
-- ══════════════════════════════════════════════════════════
-- BOOT GUARD — trava erros silenciosos na inicialização
-- ══════════════════════════════════════════════════════════
local ok, err = pcall(function()
-- ══════════════════════════════════════════════════════════
-- SERVIÇOS
-- ══════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local StarterGui       = game:GetService("StarterGui")
local lp  = Players.LocalPlayer
local cam = workspace.CurrentCamera
local RNG = Random.new()
-- ══════════════════════════════════════════════════════════
-- EVASÃO SAFE
-- ══════════════════════════════════════════════════════════
local function jitter(base, pct)
    pct = pct or 0.2
    local noise = math.abs(base * pct)
    return base + RNG:NextNumber(-noise, noise)
end
local function humanWait(base)
    local t = jitter(math.abs(base), 0.3)
    if RNG:NextNumber() < 0.07 then t = t + RNG:NextNumber(0.2, 0.8) end
    task.wait(math.max(t, 0.01))
end
-- ══════════════════════════════════════════════════════════
-- CONFIG
-- ══════════════════════════════════════════════════════════
local CFG = {
    AimbotOn   = false,
    SilentAim  = false,
    AutoShoot  = false,
    NoRecoil   = false,
    ESPOn      = false,
    ShowBoxes  = true,
    ShowHealth = true,
    ShowName   = true,
    ShowDist   = true,
    ShowSkel   = false,
    NoclipOn   = false,
    TeamCheck  = true,
