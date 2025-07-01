-- TuxRay Library v1.0
-- Com Splash Screen, Sistema de Bolinha e Personalização de Cores

local TuxRay = {}
TuxRay.__index = TuxRay

-- Serviços
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Variáveis internas
local library = {
    Windows = {},
    CurrentTab = nil,
    Minimized = false,
    Config = {
        Color = Color3.fromRGB(28, 28, 38) -- Cor padrão
    }
}

-- Métodos públicos
function TuxRay:CreateWindow(options)
    local window = {
        Tabs = {},
        Options = options or {Name = "TuxRay"}
    }
    
    table.insert(library.Windows, window)
    
    -- Aplicar configurações de cor se fornecidas
    if options and options.Color then
        library.Config.Color = options.Color
    end
    
    self:InitializeUI()
    
    return setmetatable({
        CreateTab = function(_, tabOptions)
            return self:CreateTab(window, tabOptions)
        end
    }, self)
end

function TuxRay:CreateTab(window, options)
    if not options.Name then
        warn("[TuxRay] Tab precisa de um nome!")
        return
    end
    
    local tab = {
        Elements = {},
        Options = options
    }
    
    table.insert(window.Tabs, tab)
    library.CurrentTab = tab
    
    -- Criar botão de aba
    self:CreateTabButton(tab.Options.Name)
    
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
    -- Criar splash screen
    self:CreateSplashScreen()
    
    -- Após 3 segundos, criar a bolinha e a UI principal
    task.delay(3, function()
        self:DestroySplashScreen()
        self:CreateMainUI()
        self:CreateMiniButton()
    end)
end

function TuxRay:CreateSplashScreen()
    library.Splash = Instance.new("ScreenGui")
    library.Splash.Name = "TuxRaySplash"
    library.Splash.Parent = CoreGui
    library.Splash.ResetOnSpawn = false
    library.Splash.IgnoreGuiInset = true

    -- Fundo preto
    local background = Instance.new("Frame", library.Splash)
    background.Size = UDim2.new(1, 0, 1, 0)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.BackgroundColor3 = Color3.new(0, 0, 0)
    background.ZIndex = 10

    -- Label central
    local splashLabel = Instance.new("TextLabel", background)
    splashLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    splashLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    splashLabel.Size = UDim2.new(0, 300, 0, 100)
    splashLabel.BackgroundTransparency = 1
    splashLabel.Text = "TuxRay!"
    splashLabel.TextColor3 = Color3.new(1, 1, 1)
    splashLabel.Font = Enum.Font.GothamBold
    splashLabel.TextSize = 48
    splashLabel.ZIndex = 11
    
    -- Animação de entrada
    splashLabel.TextTransparency = 1
    local fadeIn = TweenService:Create(
        splashLabel,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad),
        {TextTransparency = 0}
    )
    fadeIn:Play()
    
    -- Animação de saída (após 2.5 segundos)
    task.delay(2.5, function()
        local fadeOut = TweenService:Create(
            splashLabel,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad),
            {TextTransparency = 1}
        )
        fadeOut:Play()
    end)
end

function TuxRay:DestroySplashScreen()
    if library.Splash and library.Splash.Parent then
        library.Splash:Destroy()
        library.Splash = nil
    end
end

function TuxRay:CreateMiniButton()
    -- Criar bolinha flutuante
    library.MiniButton = Instance.new("TextButton")
    library.MiniButton.Name = "MiniBtn"
    library.MiniButton.Size = UDim2.new(0, 56, 0, 56)
    library.MiniButton.Position = UDim2.new(0.5, -28, 0.5, -28)
    library.MiniButton.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
    library.MiniButton.BorderSizePixel = 0
    library.MiniButton.Text = ""
    library.MiniButton.Parent = library.MainUI
    library.MiniButton.ZIndex = 20
    Instance.new("UICorner", library.MiniButton).CornerRadius = UDim.new(1, 0)

    -- Ícone da bolinha
    local icon = Instance.new("ImageLabel", library.MiniButton)
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.new(1, -8, 1, -8)
    icon.Position = UDim2.new(0, 4, 0, 4)
    icon.Image = "rbxassetid://138110497553919"
    icon.ZIndex = 21

    -- Funcionalidade de arrastar
    local dragging, startPos, startGui
    library.MiniButton.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = library.MiniButton.Position
            startGui = i.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            library.MiniButton.Position = startPos + UDim2.new(0, i.Position.X - startGui.X, 0, i.Position.Y - startGui.Y)
        end
    end)

    -- Alternar UI principal
    library.MiniButton.MouseButton1Click:Connect(function()
        library.MainWindow.Visible = not library.MainWindow.Visible
    end)
    
    -- Animação de entrada da bolinha
    library.MiniButton.BackgroundTransparency = 1
    icon.ImageTransparency = 1
    
    local fadeIn = TweenService:Create(
        library.MiniButton,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad),
        {BackgroundTransparency = 0}
    )
    
    local iconFadeIn = TweenService:Create(
        icon,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad),
        {ImageTransparency = 0}
    )
    
    fadeIn:Play()
    iconFadeIn:Play()
end

function TuxRay:CreateMainUI()
    -- Criação da UI principal (inicialmente invisível)
    library.MainUI = Instance.new("ScreenGui")
    library.MainUI.Name = "TuxRayUI"
    library.MainUI.Parent = CoreGui
    library.MainUI.ResetOnSpawn = false
    library.MainUI.Enabled = true

    -- Janela principal
    library.MainWindow = Instance.new("Frame", library.MainUI)
    library.MainWindow.Name = "MainWindow"
    library.MainWindow.Size = UDim2.new(0, 500, 0, 400)
    library.MainWindow.Position = UDim2.new(0.5, -250, 0.5, -200)
    library.MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
    library.MainWindow.BackgroundColor3 = library.Config.Color
    library.MainWindow.BorderSizePixel = 0
    library.MainWindow.ClipsDescendants = true
    library.MainWindow.Visible = false -- Inicialmente oculta
    Instance.new("UICorner", library.MainWindow).CornerRadius = UDim.new(0, 12)

    -- Barra de título (arrastável)
    library.TitleBar = Instance.new("Frame", library.MainWindow)
    library.TitleBar.Name = "TitleBar"
    library.TitleBar.Size = UDim2.new(1, 0, 0, 36)
    library.TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    library.TitleBar.BorderSizePixel = 0
    Instance.new("UICorner", library.TitleBar).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", library.TitleBar)
    title.Size = UDim2.new(1, -12, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "TuxRay"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.TextColor3 = Color3.fromRGB(200, 200, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- Botão de fechar
    local closeButton = Instance.new("TextButton", library.TitleBar)
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 1, 0)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    closeButton.Text = "X"
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.GothamBold
    
    closeButton.MouseButton1Click:Connect(function()
        library.MainWindow.Visible = false
    end)

    -- Área de abas
    library.TabContainer = Instance.new("Frame", library.MainWindow)
    library.TabContainer.Name = "TabContainer"
    library.TabContainer.Size = UDim2.new(1, -20, 0, 40)
    library.TabContainer.Position = UDim2.new(0, 10, 0, 40)
    library.TabContainer.BackgroundTransparency = 1

    -- Área de conteúdo
    library.ContentArea = Instance.new("ScrollingFrame", library.MainWindow)
    library.ContentArea.Name = "ContentArea"
    library.ContentArea.Size = UDim2.new(1, -20, 1, -80)
    library.ContentArea.Position = UDim2.new(0, 10, 0, 80)
    library.ContentArea.BackgroundTransparency = 1
    library.ContentArea.ClipsDescendants = true
    library.ContentArea.ScrollBarThickness = 5
    library.ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
    library.ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local uiListLayout = Instance.new("UIListLayout", library.ContentArea)
    uiListLayout.Padding = UDim.new(0, 10)
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Funcionalidade de arrastar a janela
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        library.MainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    library.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = library.MainWindow.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    library.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function TuxRay:CreateTabButton(name)
    if not library.TabContainer then return end
    
    local tabButton = Instance.new("TextButton", library.TabContainer)
    tabButton.Name = name.."Tab"
    tabButton.Size = UDim2.new(0.3, 0, 1, 0)
    tabButton.Position = UDim2.new(#library.TabContainer:GetChildren() * 0.3, 0, 0, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 255)
    tabButton.Text = name
    tabButton.Font = Enum.Font.GothamMedium
    tabButton.TextSize = 14
    Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 6)
    
    -- Funcionalidade de seleção de aba
    tabButton.MouseButton1Click:Connect(function()
        -- Atualizar todas as abas
        for _, child in ipairs(library.TabContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            end
        end
        
        -- Destacar aba selecionada
        tabButton.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
    end)
    
    -- Selecionar primeira aba por padrão
    if #library.TabContainer:GetChildren() == 1 then
        tabButton.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
    end
end

-- Métodos para criar elementos
function TuxRay:CreateButton(tab, options)
    if not options.Name then
        warn("[TuxRay] Button precisa de um nome!")
        return
    end
    
    local button = Instance.new("TextButton")
    button.Name = options.Name
    button.Text = options.Name
    button.Size = UDim2.new(1, 0, 0, 32)
    button.LayoutOrder = #library.ContentArea:GetChildren()
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
    
    -- Efeito hover
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(80, 100, 140)
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
    end)
    
    table.insert(tab.Elements, button)
    return button
end

function TuxRay:CreateToggle(tab, options)
    if not options.Name then
        warn("[TuxRay] Toggle precisa de um nome!")
        return
    end
    
    local toggle = Instance.new("TextButton")
    toggle.Name = options.Name
    toggle.Text = (options.Default and "ON  | " or "OFF | ") .. options.Name
    toggle.Size = UDim2.new(1, 0, 0, 32)
    toggle.LayoutOrder = #library.ContentArea:GetChildren()
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
        toggle.Text = (state and "ON  | " or "OFF | ") .. options.Name
        toggle.TextColor3 = state and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(255, 100, 100)
        toggle.BackgroundColor3 = state and Color3.fromRGB(36, 56, 46) or Color3.fromRGB(56, 36, 36)
        
        if options.Callback then
            options.Callback(state)
        end
    end)
    
    table.insert(tab.Elements, toggle)
    return toggle
end

function TuxRay:CreateLabel(tab, options)
    if not options.Name then
        warn("[TuxRay] Label precisa de um texto!")
        return
    end
    
    local label = Instance.new("TextLabel")
    label.Name = "Label_"..options.Name
    label.Text = options.Name
    label.Size = UDim2.new(1, 0, 0, 24)
    label.LayoutOrder = #library.ContentArea:GetChildren()
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(170, 205, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = library.ContentArea
    
    table.insert(tab.Elements, label)
    return label
end

-- Função de inicialização
local function Initialize()
    return TuxRay
end

return Initialize()
