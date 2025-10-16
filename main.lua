-- XRNL Key System (LocalScript)
-- Muestra GUI "Ingrese la key" con botones "Obtener Key" y "Entrar".
-- CONFIGURA: keyWebURL (si quieres obtener la key desde una web /current-key),
--           keyStatic (si prefieres usar una key fija),
--           panelURL (raw URL de tu panel/hub para cargar cuando la key sea correcta).
-- Si panelURL == "" pega tu código dentro de onKeyAccepted().

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- ================== CONFIG ==================
local keyWebURL  = "https://workink.net/25Tz/wsxs7qah" -- ejemplo: ""  (si vacío se usa keyStatic)
local keyStatic  = "XRNL-HUB-KEY2025"     -- key fija (si no usas web)
local panelURL   = "loadstring(game:HttpGet("https://raw.githubusercontent.com/xrnlhub-source/XRNL.hub-INKGAME/a4198887958e669755f7b5def71cf10627eefa41/main.lua", true))()" -- ejemplo: "https://raw.githubusercontent.com/tuuser/tu-repo/main/main.lua"
local enableLocalSave = true -- guarda key localmente si executor soporta writefile/isfile/readfile
local localFile = "XRNL_KeyCache.json"
local keyDurationSeconds = 12 * 60 * 60 -- (si guardas local) duración esperada
-- ============================================

-- Executor helpers (no obligatorios)
local hasWriteFile  = type(writefile) == "function"
local hasIsFile     = type(isfile) == "function"
local hasReadFile   = type(readfile) == "function"
local hasClipboard  = type(setclipboard) == "function"

local function now() return os.time() end

local function saveLocal(data)
    if not enableLocalSave or not hasWriteFile then return end
    pcall(function() writefile(localFile, HttpService:JSONEncode(data)) end)
end

local function loadLocal()
    if not enableLocalSave or not (hasIsFile and hasReadFile and isfile(localFile)) then return nil end
    local ok, content = pcall(function() return readfile(localFile) end)
    if not ok or not content then return nil end
    local suc, decoded = pcall(function() return HttpService:JSONDecode(content) end)
    if not suc or type(decoded) ~= "table" then return nil end
    return decoded
end

local function expired(ts)
    if not ts then return true end
    return (now() - ts) >= keyDurationSeconds
end

-- Obtiene la key desde la web (espera respuesta de texto plano o la extrae del HTML)
local function fetchKeyFromWeb()
    if keyWebURL == "" then return nil, "No hay URL configurada" end
    local ok, res = pcall(function() return game:HttpGet(keyWebURL) end)
    if not ok or not res or res == "" then
        return nil, "Error al obtener key desde la web"
    end
    -- limpiar/rescatar token: buscar "XRNL-HUB-XXXX" si existe, si no devolver res limpio
    local found = res:match("(XRNL%-HUB%-%S+)")
    if found then
        -- quitar espacios/etiquetas si las hubiera
        return found:gsub("%s+",""), nil
    end
    -- si la respuesta es solo la key (texto plano)
    local cleaned = tostring(res):gsub("%s+","")
    if cleaned ~= "" then return cleaned, nil end
    return nil, "No se pudo extraer la key de la respuesta"
end

-- Obtiene la key válida (prefiere web si configurada; usa local cache si no expired)
local function getValidKey()
    -- si hay cache local válida, usarla
    local localData = loadLocal()
    if localData and localData.Key and localData.Timestamp and (not expired(localData.Timestamp)) then
        return localData.Key
    end

    -- si hay URL, intentar obtener
    if keyWebURL and keyWebURL ~= "" then
        local k, err = fetchKeyFromWeb()
        if k then
            saveLocal({ Key = k, Timestamp = now() })
            return k
        else
            -- fallback: si existe local expired devolverlo (aunque expirado) para permitir intento
            if localData and localData.Key then return localData.Key end
            return nil, err
        end
    end

    -- usar key estática como último recurso
    if keyStatic and keyStatic ~= "" then
        saveLocal({ Key = keyStatic, Timestamp = now() })
        return keyStatic
    end

    return nil, "No hay key configurada"
end

-- Acción cuando la key es correcta: pega tu código aquí o carga panelURL
local function onKeyAccepted(key)
    -- >>> AQUI PEGA TU SCRIPT PRINCIPAL O CARGA EL PANEL <<<
    -- Ejemplo: si quieres cargar desde panelURL (raw), descomenta esto:
    if panelURL and panelURL ~= "" then
        local ok, err = pcall(function()
            local s = game:HttpGet(panelURL)
            local f = loadstring(s)
            if type(f) == "function" then f() end
        end)
        if not ok then
            warn("Error cargando panel desde panelURL:", err)
        end
    else
        -- Si no usas panelURL, pega aquí el código que necesites ejecutar.
        print("Key aceptada:", key, "- pega tu script dentro de onKeyAccepted()")
    end
end

-- ======= Construcción GUI =======
-- eliminar GUI previa
for _,v in ipairs(PlayerGui:GetChildren()) do
    if v.Name == "XRNL_KeySystemGUI" then v:Destroy() end
end

local gui = Instance.new("ScreenGui")
gui.Name = "XRNL_KeySystemGUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 480, 0, 260)
frame.Position = UDim2.new(0.5, -240, 0.5, -130)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2
task.spawn(function()
    local h = 0
    while stroke and stroke.Parent do
        stroke.Color = Color3.fromHSV(h%1, 1, 1)
        h = h + 0.008
        task.wait(0.03)
    end
end)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -20, 0, 36)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Text = "🔐 INGRESE LA KEY"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255,255,255)

local info = Instance.new("TextLabel", frame)
info.Size = UDim2.new(1, -20, 0, 20)
info.Position = UDim2.new(0, 10, 0, 50)
info.BackgroundTransparency = 1
info.Text = "Obtén la key en la web oficial y pégala aquí. Válida por 12 horas (si aplica)."
info.Font = Enum.Font.Gotham
info.TextSize = 14
info.TextColor3 = Color3.fromRGB(200,200,200)
info.TextWrapped = true

local keyBox = Instance.new("TextBox", frame)
keyBox.Size = UDim2.new(1, -20, 0, 44)
keyBox.Position = UDim2.new(0, 10, 0, 80)
keyBox.PlaceholderText = "Pega aquí la key..."
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 18
keyBox.TextColor3 = Color3.fromRGB(255,255,255)
keyBox.BackgroundColor3 = Color3.fromRGB(36,36,36)
keyBox.BorderSizePixel = 0
keyBox.ClearTextOnFocus = false

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 18)
status.Position = UDim2.new(0, 10, 0, 132)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextColor3 = Color3.fromRGB(255,120,120)
status.TextXAlignment = Enum.TextXAlignment.Left
status.Text = ""
status.Parent = frame

local btnFrame = Instance.new("Frame", frame)
btnFrame.Size = UDim2.new(1, -20, 0, 48)
btnFrame.Position = UDim2.new(0, 10, 1, -70)
btnFrame.BackgroundTransparency = 1

local getBtn = Instance.new("TextButton", btnFrame)
getBtn.Size = UDim2.new(0.5, -6, 1, 0)
getBtn.Position = UDim2.new(0, 0, 0, 0)
getBtn.Text = "Obtener Key"
getBtn.Font = Enum.Font.Gotham
getBtn.TextSize = 18
getBtn.BackgroundColor3 = Color3.fromRGB(65,65,65)
getBtn.BorderSizePixel = 0

local enterBtn = Instance.new("TextButton", btnFrame)
enterBtn.Size = UDim2.new(0.5, -6, 1, 0)
enterBtn.Position = UDim2.new(0.5, 12, 0, 0)
enterBtn.Text = "Entrar"
enterBtn.Font = Enum.Font.GothamBold
enterBtn.TextSize = 18
enterBtn.BackgroundColor3 = Color3.fromRGB(30,150,80)
enterBtn.BorderSizePixel = 0

-- helper status
local function setStatus(txt, color)
    status.Text = txt or ""
    if color then status.TextColor3 = color end
end

-- Obtener Key behavior
getBtn.MouseButton1Click:Connect(function()
    if keyWebURL and keyWebURL ~= "" then
        if hasClipboard then
            pcall(function() setclipboard(keyWebURL) end)
            setStatus("URL copiada al portapapeles. Abrela y copia la key.", Color3.fromRGB(120,220,120))
        else
            setStatus("Visita: "..keyWebURL.." y copia la key.", Color3.fromRGB(200,200,255))
        end
    else
        -- si no hay web, mostramos la key estática (si existe)
        if keyStatic and keyStatic ~= "" then
            setStatus("Key fija: "..keyStatic, Color3.fromRGB(120,220,120))
            if hasClipboard then pcall(function() setclipboard(keyStatic) end) end
        else
            setStatus("No hay URL ni key fija configurada.", Color3.fromRGB(255,120,120))
        end
    end
end)

-- Entrar behavior: valida typed vs key válida (getValidKey())
enterBtn.MouseButton1Click:Connect(function()
    setStatus("Validando key...", Color3.fromRGB(220,220,160))
    local typed = tostring(keyBox.Text or ""):gsub("%s+","")
    if typed == "" then
        setStatus("Ingresa la key antes de Entrar.", Color3.fromRGB(255,120,120))
        return
    end

    local valid, err = getValidKey()
    if not valid then
        setStatus("No se pudo obtener la key: "..tostring(err), Color3.fromRGB(255,100,100))
        return
    end

    if typed == valid then
        setStatus("Key válida. Iniciando script...", Color3.fromRGB(120,220,130))
        -- guardar timestamp local (renueva 12h)
        saveLocal({ Key = valid, Timestamp = now() })
        task.delay(0.8, function()
            pcall(function() gui:Destroy() end)
            pcall(function() onKeyAccepted(valid) end)
        end)
    else
        setStatus("Key incorrecta ❌", Color3.fromRGB(255,100,100))
    end
end)

-- permitir presionar Enter en TextBox
keyBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        enterBtn:CaptureFocus()
        enterBtn.MouseButton1Click:Wait()
    end
end)

-- Mensaje inicial
local initialKey, initialErr = getValidKey()
if initialKey then
    setStatus("Key cargada. Pulsa Obtener Key para copiar/abrir la fuente.", Color3.fromRGB(200,200,200))
else
    setStatus("No se pudo cargar la key automáticamente. Pulsa Obtener Key.", Color3.fromRGB(255,160,80))
end

-- FIN
