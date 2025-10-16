--// 🌈 XRNL HUB - Sistema de Key con Diseño Rainbow
if game.CoreGui:FindFirstChild("XRNL_KeyUI") then
    game.CoreGui.XRNL_KeyUI:Destroy()
end

local keyCorrecta = "XRNL-HUB-KEY2025" -- 🔹 Cambia esto por tu key actual

-- Crear elementos
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "XRNL_KeyUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 380, 0, 260)
frame.Position = UDim2.new(0.5, -190, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active, frame.Draggable = true, true
frame.ClipsDescendants = true

-- Efecto rainbow dinámico
local UIStroke = Instance.new("UIStroke", frame)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255, 0, 255)
task.spawn(function()
    while frame do
        for i = 0, 1, 0.005 do
            UIStroke.Color = Color3.fromHSV(i, 1, 1)
            task.wait(0.02)
        end
    end
end)

-- Esquinas redondeadas
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- Título
local titulo = Instance.new("TextLabel", frame)
titulo.Text = "🔐 XRNL HUB - Sistema de Key"
titulo.Size = UDim2.new(1, 0, 0, 45)
titulo.BackgroundTransparency = 1
titulo.Font = Enum.Font.GothamBold
titulo.TextScaled = true
titulo.TextColor3 = Color3.fromRGB(0, 255, 255)

-- Caja de texto (input)
local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0.8, 0, 0, 40)
input.Position = UDim2.new(0.1, 0, 0.4, 0)
input.PlaceholderText = "🔑 Ingresa tu key aquí..."
input.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
input.TextColor3 = Color3.fromRGB(255, 255, 255)
input.Font = Enum.Font.Gotham
input.TextScaled = true
Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)

-- Texto de estado
local estado = Instance.new("TextLabel", frame)
estado.Size = UDim2.new(1, 0, 0, 30)
estado.Position = UDim2.new(0, 0, 0.9, 0)
estado.BackgroundTransparency = 1
estado.Font = Enum.Font.GothamBold
estado.TextScaled = true
estado.TextColor3 = Color3.fromRGB(255, 255, 255)
estado.Text = ""

-- Botón "Obtener Key"
local btnGet = Instance.new("TextButton", frame)
btnGet.Size = UDim2.new(0.4, 0, 0, 40)
btnGet.Position = UDim2.new(0.08, 0, 0.7, 0)
btnGet.Text = "🌐 Obtener Key"
btnGet.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
btnGet.TextColor3 = Color3.fromRGB(255, 255, 255)
btnGet.Font = Enum.Font.GothamBold
btnGet.TextScaled = true
Instance.new("UICorner", btnGet).CornerRadius = UDim.new(0, 8)

-- Botón "Entrar"
local btnEnter = Instance.new("TextButton", frame)
btnEnter.Size = UDim2.new(0.4, 0, 0, 40)
btnEnter.Position = UDim2.new(0.52, 0, 0.7, 0)
btnEnter.Text = "Entrar"
btnEnter.BackgroundColor3 = Color3.fromRGB(0, 255, 140)
btnEnter.TextColor3 = Color3.fromRGB(255, 255, 255)
btnEnter.Font = Enum.Font.GothamBold
btnEnter.TextScaled = true
Instance.new("UICorner", btnEnter).CornerRadius = UDim.new(0, 8)

-- Animación hover botones
local function hover(btn, color)
	btn.MouseEnter:Connect(function()
		btn:TweenSize(UDim2.new(btn.Size.X.Scale + 0.05, 0, btn.Size.Y.Scale + 0.05, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
	end)
	btn.MouseLeave:Connect(function()
		btn:TweenSize(UDim2.new(0.4, 0, 0, 40), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
	end)
end
hover(btnGet)
hover(btnEnter)

-- Acción Obtener Key
btnGet.MouseButton1Click:Connect(function()
    setclipboard("https://workink.net/25Tz/wsxs7qah") -- 🔹 Cambia por tu página
    estado.TextColor3 = Color3.fromRGB(0, 255, 255)
    estado.Text = "🔗 Key copiada, visita la página para obtenerla."
end)

-- Acción Entrar
btnEnter.MouseButton1Click:Connect(function()
    local key = input.Text
    if key == keyCorrecta then
        estado.TextColor3 = Color3.fromRGB(0, 255, 0)
        estado.Text = "✅ Key válida. Cargando XRNL HUB..."
        task.wait(1.5)
        gui:Destroy()
        -- 🔹 Aquí cargas tu script real:
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xrnlhub-source/XRNL.hub-INKGAME/a4198887958e669755f7b5def71cf10627eefa41/main.lua", true))()
    else
        estado.TextColor3 = Color3.fromRGB(255, 50, 50)
        estado.Text = "❌ Key inválida o incorrecta"
    end
end)
