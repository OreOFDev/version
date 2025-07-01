--!strict
-- TuxRay Library v1.0
-- Estilo Rayfield com sistema de key

local TuxRay = {}
TuxRay.__index = TuxRay

-- Serviços
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Variáveis internas
local library = {
    Windows = {},
    CurrentTab = nil,
    KeyVerified = false,
    Minimized = false
}

-- Métodos públicos
function TuxRay:CreateWindow(options)
    local window = {
        Tabs = {},
        Options = options
    }
    
    table.insert(library.Windows, window)
    self:InitializeUI()
    
    return setmetatable({
        CreateTab = function(_, tabOptions)
            return self:CreateTab(window, tabOptions)
        end
    }, self)
end

function TuxRay:CreateTab(window, options)
    local tab = {
        Elements = {},
        Options = options
    }
    
    table.insert(window.Tabs, tab)
    library.CurrentTab = tab
    
    return setmetatable({
        CreateButton = function(_, buttonOptions)
            self:CreateButton(tab, buttonOptions)
        end,
        CreateToggle = function(_, toggleOptions)
            self:CreateToggle(tab, toggleOptions)
        end,
        CreateLabel = function(_, labelOptions)
            self:CreateLabel(tab, labelOptions)
        end
    }, self)
end

-- Métodos internos
function TuxRay:InitializeUI()
    -- Splash Screen
    self:CreateSplashScreen()
    
    -- Verificação de Key
    task.spawn(function()
        task.wait(3)
        self:DestroySplashScreen()
        
        if not library.KeyVerified then
            self:CreateKeyVerification()
        else
            self:CreateMainUI()
        end
    end)
end

function TuxRay:CreateSplashScreen()
    library.Splash = Instance.new("ScreenGui")
    library.Splash.Name = "TuxRaySplash"
    library.Splash.Parent = CoreGui
    library.Splash.ResetOnSpawn = false
    library.Splash.IgnoreGuiInset = true

    local splashFrame = Instance.new("Frame", library.Splash)
    splashFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    splashFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    splashFrame.Size = UDim2.new(0, 330, 0, 160)
    splashFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    splashFrame.BorderSizePixel = 0
    Instance.new("UICorner", splashFrame).CornerRadius = UDim.new(0, 12)

    -- Title bar
    local titleBar = Instance.new("Frame", splashFrame)
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    titleBar.BorderSizePixel = 0

    local title = Instance.new("TextLabel", titleBar)
    title.Size = UDim2.new(1, -12, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "TuxRay"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.TextColor3 = Color3.fromRGB(200, 200, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- Conteúdo principal
    local splashContent = Instance.new("Frame", splashFrame)
    splashContent.Size = UDim2.new(1, 0, 1, -36)
    splashContent.Position = UDim2.new(0, 0, 0, 36)
    splashContent.BackgroundTransparency = 1

    local loadingText = Instance.new("TextLabel", splashContent)
    loadingText.Text = "CARREGANDO..."
    loadingText.Size = UDim2.new(1, -20, 0.5, 0)
    loadingText.Position = UDim2.new(0, 10, 0.25, 0)
    loadingText.BackgroundTransparency = 1
    loadingText.Font = Enum.Font.GothamBold
    loadingText.TextSize = 20
    loadingText.TextColor3 = Color3.fromRGB(110, 200, 255)
    loadingText.TextXAlignment = Enum.TextXAlignment.Center

    local authorText = Instance.new("TextLabel", splashContent)
    authorText.Text = "por oRee Scripter"
    authorText.Size = UDim2.new(1, -20, 0, 30)
    authorText.Position = UDim2.new(0, 10, 0.75, 0)
    authorText.BackgroundTransparency = 1
    authorText.Font = Enum.Font.GothamMedium
    authorText.TextSize = 16
    authorText.TextColor3 = Color3.fromRGB(170, 205, 255)
    authorText.TextXAlignment = Enum.TextXAlignment.Center
end

function TuxRay:DestroySplashScreen()
    if library.Splash and library.Splash.Parent then
        library.Splash:Destroy()
        library.Splash = nil
    end
end

function TuxRay:CreateKeyVerification()
    -- Implementação do sistema de key (simplificado para exemplo)
    library.KeyScreen = Instance.new("ScreenGui")
    library.KeyScreen.Name = "TuxRayKeyVerification"
    library.KeyScreen.Parent = CoreGui
    library.KeyScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    library.KeyScreen.ResetOnSpawn = false

    -- Interface de verificação de key aqui...
    
    -- Ao verificar com sucesso:
    library.KeyVerified = true
    self:CreateMainUI()
end

function TuxRay:CreateMainUI()
    -- Criação da UI principal
    library.MainUI = Instance.new("ScreenGui")
    library.MainUI.Name = "TuxRayUI"
    library.MainUI.Parent = CoreGui
    library.MainUI.ResetOnSpawn = false
    library.MainUI.Enabled = true

    -- Botão minimizado
    self:CreateMiniButton()

    -- Janela principal
    self:CreateMainWindow()
end

function TuxRay:CreateMiniButton()
    library.MiniButton = Instance.new("TextButton")
    library.MiniButton.Name = "MiniBtn"
    library.MiniButton.Size = UDim2.new(0, 56, 0, 56)
    library.MiniButton.Position = UDim2.new(0.5, -28, 0.5, -28)
    library.MiniButton.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
    library.MiniButton.BorderSizePixel = 0
    library.MiniButton.Text = ""
    library.MiniButton.Parent = library.MainUI
    Instance.new("UICorner", library.MiniButton).CornerRadius = UDim.new(1, 0)

    -- Ícone do botão
    local icon = Instance.new("ImageLabel", library.MiniButton)
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.new(1, -8, 1, -8)
    icon.Position = UDim2.new(0, 4, 0, 4)
    icon.Image = "rbxassetid://138110497553919"

    -- Funcionalidade de arrastar
    local drag, startPos, startGui
    library.MiniButton.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            startPos = library.MiniButton.Position
            startGui = i.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            library.MiniButton.Position = startPos + UDim2.new(0, i.Position.X - startGui.X, 0, i.Position.Y - startGui.Y)
        end
    end)

    -- Alternar UI principal
    library.MiniButton.MouseButton1Click:Connect(function()
        library.MainWindow.Visible = not library.MainWindow.Visible
    end)
end

function TuxRay:CreateMainWindow()
    library.MainWindow = Instance.new("Frame", library.MainUI)
    library.MainWindow.Name = "MainWindow"
    library.MainWindow.Size = UDim2.new(0, 500, 0, 400)
    library.MainWindow.Position = UDim2.new(0.5, -250, 0.5, -200)
    library.MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
    library.MainWindow.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    library.MainWindow.BorderSizePixel = 0
    library.MainWindow.ClipsDescendants = true
    Instance.new("UICorner", library.MainWindow).CornerRadius = UDim.new(0, 12)

    -- Barra de título
    local titleBar = Instance.new("Frame", library.MainWindow)
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    titleBar.BorderSizePixel = 0
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", titleBar)
    title.Size = UDim2.new(1, -12, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "TuxRay"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.TextColor3 = Color3.fromRGB(200, 200, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- Área de abas
    local tabContainer = Instance.new("Frame", library.MainWindow)
    tabContainer.Size = UDim2.new(1, 0, 0, 40)
    tabContainer.Position = UDim2.new(0, 0, 0, 36)
    tabContainer.BackgroundTransparency = 1

    -- Área de conteúdo
    library.ContentArea = Instance.new("Frame", library.MainWindow)
    library.ContentArea.Size = UDim2.new(1, -20, 1, -80)
    library.ContentArea.Position = UDim2.new(0, 10, 0, 80)
    library.ContentArea.BackgroundTransparency = 1
    library.ContentArea.ClipsDescendants = true

    -- Implementar abas e elementos aqui...
end

-- Métodos para criar elementos
function TuxRay:CreateButton(tab, options)
    -- Implementação do botão
    local button = Instance.new("TextButton")
    button.Name = options.Name or "Button"
    button.Text = options.Name or "Button"
    button.Size = UDim2.new(1, -20, 0, 32)
    button.Position = UDim2.new(0, 10, 0, #tab.Elements * 40 + 10)
    button.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 14
    button.Parent = library.ContentArea
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    
    button.MouseButton1Click:Connect(function()
        if options.Callback then
            options.Callback()
        end
    end)
    
    table.insert(tab.Elements, button)
end

function TuxRay:CreateToggle(tab, options)
    -- Implementação do toggle
    local toggle = Instance.new("TextButton")
    toggle.Name = options.Name or "Toggle"
    toggle.Text = (options.Default and "ON  | " or "OFF | ") .. (options.Name or "Toggle")
    toggle.Size = UDim2.new(1, -20, 0, 32)
    toggle.Position = UDim2.new(0, 10, 0, #tab.Elements * 40 + 10)
    toggle.BackgroundColor3 = options.Default and Color3.fromRGB(36, 56, 46) or Color3.fromRGB(56, 36, 36)
    toggle.TextColor3 = options.Default and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(255, 100, 100)
    toggle.Font = Enum.Font.GothamMedium
    toggle.TextSize = 14
    toggle.AutoButtonColor = false
    toggle.Parent = library.ContentArea
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 8)
    
    local state = options.Default or false
    
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = (state and "ON  | " or "OFF | ") .. (options.Name or "Toggle")
        toggle.TextColor3 = state and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(255, 100, 100)
        toggle.BackgroundColor3 = state and Color3.fromRGB(36, 56, 46) or Color3.fromRGB(56, 36, 36)
        
        if options.Callback then
            options.Callback(state)
        end
    end)
    
    table.insert(tab.Elements, toggle)
end

-- Função de inicialização
local function Initialize()
    -- Notificação inicial
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "TuxRay Iniciado",
            Text = "Biblioteca carregada com sucesso!",
            Duration = 5
        })
    end)
    
    return TuxRay
end

return Initialize()
