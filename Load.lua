-- Aimbot & ESP por atl4z (atlas) - Versão Simplificada
-- Apenas Aimbot + ESP | Rayfield UI | Multilíngue

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Sistema de Idiomas
local Idiomas = {
    Turco = {
        WindowName = "Aimbot & ESP por atl4z",
        LoadingTitle = "atl4z Yükleyici",
        LoadingSubtitle = "tarafından atl4z",
        AimbotTab = "🎯 Nişangah",
        ESPTab = "👁️ ESP",
        SettingsTab = "⚙️ Ayarlar",
        AimbotSettings = "Nişangah Ayarları",
        AimbotActive = "Nişangah Aktif",
        TeamCheck = "Takım Kontrolü",
        WallCheck = "Duvar Kontrolü",
        FOVSize = "FOV Boyutu",
        FOVColor = "FOV Rengi",
        ESPSettings = "ESP Ayarları",
        ESPActive = "ESP Aktif",
        RGBESP = "RGB ESP",
        LanguageSettings = "Dil Ayarları",
        SelectLanguage = "Dil Seç",
        Sucesso = "Başarılı",
        Erro = "Hata"
    },
    Inglês = {
        WindowName = "Aimbot & ESP by atl4z",
        LoadingTitle = "atl4z Loader",
        LoadingSubtitle = "by atl4z",
        AimbotTab = "🎯 Aimbot",
        ESPTab = "👁️ ESP",
        SettingsTab = "⚙️ Settings",
        AimbotSettings = "Aimbot Settings",
        AimbotActive = "Aimbot Active",
        TeamCheck = "Team Check",
        WallCheck = "Wall Check",
        FOVSize = "FOV Size",
        FOVColor = "FOV Color",
        ESPSettings = "ESP Settings",
        ESPActive = "ESP Active",
        RGBESP = "RGB ESP",
        LanguageSettings = "Language Settings",
        SelectLanguage = "Select Language",
        Sucesso = "Success",
        Erro = "Error"
    }
}

-- Idioma Padrão
local CurrentLanguage = "Inglês"
local Lang = Idiomas[CurrentLanguage]

-- Janela
local Window = Rayfield:CreateWindow({
    Name = Lang.WindowName,
    LoadingTitle = Lang.LoadingTitle,
    LoadingSubtitle = Lang.LoadingSubtitle,
    ConfigurationSaving = { Enabled = true, FolderName = nil, FileName = "atl4z_AimbotESP" },
    KeySystem = false
})

-- Configurações
local Settings = {
    Aimbot = { Enabled = false, TeamCheck = false, WallCheck = false, FOV = 100, FOVColor = Color3.fromRGB(255,255,255) },
    ESP = { Enabled = false, RGB = false }
}

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 50
FOVCircle.Radius = Settings.Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.Visible = true
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 1
FOVCircle.Color = Settings.Aimbot.FOVColor

-- Função RGB
local function updateRGB()
    local hue = tick() % 5 / 5
    return Color3.fromHSV(hue, 1, 1)
end

-- Encontrar Alvo
local function getClosestPlayer()
    local closest, shortest = nil, Settings.Aimbot.FOV
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if Settings.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then continue end
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < shortest then
                    if Settings.Aimbot.WallCheck then
                        local ray = Ray.new(Camera.CFrame.Position, (player.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Unit * 500)
                        local part = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
                        if part and part:IsDescendantOf(player.Character) then
                            closest, shortest = player, dist
                        end
                    else
                        closest, shortest = player, dist
                    end
                end
            end
        end
    end
    return closest
end

-- ESP
local ESPObjects = {}

local function createESP(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text")
    }
    esp.Box.Visible = false; esp.Box.Filled = false; esp.Box.Thickness = 2; esp.Box.Transparency = 1
    esp.Name.Visible = false; esp.Name.Center = true; esp.Name.Outline = true; esp.Name.Font = 2; esp.Name.Size = 13
    esp.Health.Visible = false; esp.Health.Center = true; esp.Health.Outline = true; esp.Health.Font = 2; esp.Health.Size = 13; esp.Health.Color = Color3.fromRGB(0,255,0)
    ESPObjects[player] = esp
end

local function removeESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do obj:Remove() end
        ESPObjects[player] = nil
    end
end

local function updateESP()
    for player, esp in pairs(ESPObjects) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local hrp = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen and Settings.ESP.Enabled then
                local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
                local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
                local height = math.abs(headPos.Y - legPos.Y)
                local width = height / 2
                local color = Settings.ESP.RGB and updateRGB() or Color3.fromRGB(255,255,255)

                esp.Box.Size = Vector2.new(width, height)
                esp.Box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                esp.Box.Color = color
                esp.Box.Visible = true

                esp.Name.Text = player.Name
                esp.Name.Position = Vector2.new(pos.X, pos.Y - height/2 - 15)
                esp.Name.Color = color
                esp.Name.Visible = true

                local health = math.floor(player.Character.Humanoid.Health)
                esp.Health.Text = health .. " HP"
                esp.Health.Position = Vector2.new(pos.X, pos.Y + height/2 + 5)
                esp.Health.Visible = true
            else
                esp.Box.Visible = false; esp.Name.Visible = false; esp.Health.Visible = false
            end
        else
            esp.Box.Visible = false; esp.Name.Visible = false; esp.Health.Visible = false
        end
    end
end

-- Criar ESP para jogadores existentes
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        createESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function() createESP(player) end)
end)

Players.PlayerRemoving:Connect(function(player) removeESP(player) end)

-- GUI: Aimbot Tab
local AimbotTab = Window:CreateTab(Lang.AimbotTab, 4483362458)
local AimbotSection = AimbotTab:CreateSection(Lang.AimbotSettings)

AimbotTab:CreateToggle({
    Name = Lang.AimbotActive,
    CurrentValue = false,
    Callback = function(v) Settings.Aimbot.Enabled = v end
})

AimbotTab:CreateToggle({
    Name = Lang.TeamCheck,
    CurrentValue = false,
    Callback = function(v) Settings.Aimbot.TeamCheck = v end
})

AimbotTab:CreateToggle({
    Name = Lang.WallCheck,
    CurrentValue = false,
    Callback = function(v) Settings.Aimbot.WallCheck = v end
})

AimbotTab:CreateSlider({
    Name = Lang.FOVSize,
    Range = {10, 500},
    Increment = 5,
    CurrentValue = 100,
    Callback = function(v)
        Settings.Aimbot.FOV = v
        FOVCircle.Radius = v
    end
})

AimbotTab:CreateDropdown({
    Name = Lang.FOVColor,
    Options = {"RGB", "White", "Red", "Blue", "Green", "Yellow", "Purple", "Cyan"},
    CurrentOption = {"White"},
    Callback = function(opt)
        local colors = {
            Red = Color3.fromRGB(255,0,0), Blue = Color3.fromRGB(0,0,255),
            Green = Color3.fromRGB(0,255,0), Yellow = Color3.fromRGB(255,255,0),
            Purple = Color3.fromRGB(128,0,128), Cyan = Color3.fromRGB(0,255,255),
            White = Color3.fromRGB(255,255,255)
        }
        Settings.Aimbot.FOVColor = opt[1] == "RGB" and nil or colors[opt[1]]
    end
})

-- GUI: ESP Tab
local ESPTab = Window:CreateTab(Lang.ESPTab, 4483362458)
local ESPSection = ESPTab:CreateSection(Lang.ESPSettings)

ESPTab:CreateToggle({
    Name = Lang.ESPActive,
    CurrentValue = false,
    Callback = function(v) Settings.ESP.Enabled = v end
})

ESPTab:CreateToggle({
    Name = Lang.RGBESP,
    CurrentValue = false,
    Callback = function(v) Settings.ESP.RGB = v end
})

-- GUI: Configurações
local SettingsTab = Window:CreateTab(Lang.SettingsTab, 4483362458)
local LangSection = SettingsTab:CreateSection(Lang.LanguageSettings)

SettingsTab:CreateDropdown({
    Name = Lang.SelectLanguage,
    Options = {"Inglês", "Turco"},
    CurrentOption = {"Inglês"},
    Callback = function(opt)
        CurrentLanguage = opt[1]
        Lang = Idiomas[CurrentLanguage]
        Rayfield:Notify({
            Title = Lang.Sucesso,
            Content = "Language changed to " .. CurrentLanguage,
            Duration = 3
        })
    end
})

-- Loop Principal
RunService.RenderStepped:Connect(function()
    -- FOV Circle
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Color = Settings.Aimbot.FOVColor or updateRGB()

    -- Aimbot
    if Settings.Aimbot.Enabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end

    -- ESP Update
    updateESP()
end)

-- Carregar Config
Rayfield:LoadConfiguration()

print("Aimbot & ESP por atl4z - Carregado com sucesso!")
print("Recursos: Aimbot + ESP | UI: Rayfield | Idioma: Multilíngue")
