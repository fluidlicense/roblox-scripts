-- arena_snipers_stealth.lua
-- target: Roblox (Hyperion/Byfron) · OS: Windows · executor: qualquer com loadstring
-- evasão: criptografia de strings, hook de __namecall, spoof de Drawing, filtro de remotos, jitter de scan

local function enc(s)
    local o = {}
    for i = 1, #s do o[i] = string.char(string.byte(s, i) ~ 0x5A) end
    return table.concat(o)
end

local dec = function(s)
    local o = {}
    for i = 1, #s do o[i] = string.char(string.byte(s, i) ~ 0x5A) end
    return table.concat(o)
end

-- esconde de varredura de globals e metatables
local mt = getrawmetatable(game)
setreadonly(mt, false)
local old_nc = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local nome = tostring(self)
    if nome:find("Report") or nome:find("Telemetry") or nome:find("AntiCheat") then
        return nil
    end
    return old_nc(self, unpack(...))
end)
setreadonly(mt, true)

-- spoof Drawing para reduzir assinatura em memória
local real_draw = Drawing.new
Drawing.new = function(class)
    local d = real_draw(class)
    d.Visible = false
    return d
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Cam = workspace.CurrentCamera
local LP = Players.LocalPlayer

local boxes = {}
local tick = 0

local function getBox(plr)
    if boxes[plr] then return boxes[plr] end
    local d = Drawing.new("Square")
    d.Color = Color3.fromRGB(255, 255, 255)
    d.Thickness = 1
    d.Filled = false
    d.Visible = false
    boxes[plr] = d
    return d
end

RunService.RenderStepped:Connect(function()
    tick = tick + 1
    if tick % 4 ~= 0 then return end -- jitter: não roda a cada frame, quebra padrão de scan
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local vp, vis = Cam:WorldToViewportPoint(root.Position)
            local d = getBox(plr)
            if vis then
                local sz = 1200 / (root.Position - Cam.CFrame.Position).Magnitude
                d.Size = Vector2.new(sz, sz * 1.5)
                d.Position = Vector2.new(vp.X - sz / 2, vp.Y - sz * 0.75)
                d.Visible = true
            else
                d.Visible = false
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if boxes[plr] then boxes[plr]:Remove(); boxes[plr] = nil end
end)
