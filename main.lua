-- TuxRay Library v2.1
-- Solução definitiva para o problema da área de conteúdo
-- GitHub: https://github.com/OreOFDev/TuxRay/

local TuxRay = {}
TuxRay.__index = TuxRay

-- Serviços
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Mapeamento de cores
local COLOR_PALETTE = {
    White = Color3.fromRGB(255, 255, 255),
    Black = Color3.fromRGB(0, 0, 0),
    DarkPurple = Color3.fromRGB(64, 0, 64),
    DarkBlue = Color3.fromRGB(0, 0, 100),
    DarkRed = Color3.fromRGB(100, 0, 0),
    Default = Color3.fromRGB(28, 28, 38),
    Accent = Color3.fromRGB(80, 120, 200),
    SliderTrack = Color3.fromRGB(40, 40, 50),
    SliderFill = Color3.fromRGB(60, 80, 120)
}

-- Variáveis internas
local library = {
    Windows = {},
    CurrentTab = nil,
    Minimized = false,
    Config = {
        Color = COLOR_PALETTE.Default
    }
}

-- Método para garantir que a UI está pronta
function TuxRay:EnsureUIReady()
    if not library.MainUI then
        self:CreateMainUI()
    end
    if not library.ContentArea then
        self:CreateContentArea()
    end
    return true
end

-- Métodos públicos
function TuxRay:CreateWindow(options)
    local window = {
        Tabs = {},
        Options = options or {Name = "TuxRay"}
    }
    
    table.insert(library.Windows, window)
    
    -- Aplicar configurações de cor se fornecidas
    if options and options.Color then
        if type(options.Color) == "string" then
            library.Config.Color = COLOR_PALETTE[options.Color] or COLOR_PALETTE.Default
        else
            library.Config.Color = options.Color
        end
    end
    
    -- Criar splash screen
    self:CreateSplashScreen()
    
    -- Criar UI principal após 3 segundos
    task.delay(3, function()
        self:DestroySplashScreen()
        self:CreateMiniButton()
        self:EnsureUIReady() -- Garantir que a UI está pronta
    end)
    
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
            return self:CreateButton(tab, buttonOptions)
        end,
        CreateToggle = function(_, toggleOptions)
            return self:CreateToggle(tab, toggleOptions)
        end,
        CreateLabel = function(_, labelOptions)
            return self:CreateLabel(tab, labelOptions)
        end,
        CreateSlider = function(_, sliderOptions)
            return self:CreateSlider(tab, sliderOptions)
        end
    }, self)
end

-- Métodos internos
function TuxRay:CreateSplashScreen()
    library.Splash = Instance.new("ScreenGui")
    library.Splash.Name = "TuxRaySplash"
    library.Splash.Parent = CoreGui
    library.Splash.ResetOnSpawn = false
    library.Splash.IgnoreGuiInset = true

    -- Fundo centralizado
    local background = Instance.new("Frame", library.Splash)
    background.AnchorPoint = Vector2.new(0.5, 0.5)
    background.Size = UDim2.new(0, 300, 0, 200)
    background.Position = UDim2.new(0.5, 0, 0.5, 0)
    background.BackgroundColor3 = Color3.new(0, 0, 0)
    background.ZIndex = 10
    Instance.new("UICorner", background).CornerRadius = UDim.new(0, 12)

    -- Label central
    local splashLabel = Instance.new("TextLabel", background)
    splashLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    splashLabel.Position = UDim2.new(0.5, 0, 0.4, 0)
    splashLabel.Size = UDim2.new(0, 280, 0, 60)
    splashLabel.BackgroundTransparency = 1
    splashLabel.Text = "TuxRay!"
    splashLabel.TextColor3 = Color3.new(1, 1, 1)
    splashLabel.Font = Enum.Font.GothamBold
    splashLabel.TextSize = 48
    splashLabel.ZIndex = 11
    
    -- Link do GitHub
    local githubLabel = Instance.new("TextLabel", background)
    githubLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    githubLabel.Position = UDim2.new(0.5, 0, 0.65, 0)
    githubLabel.Size = UDim2.new(0, 280, 0, 30)
    githubLabel.BackgroundTransparency = 1
    githubLabel.Text = "https://github.com/OreOFDev/TuxRay/"
    githubLabel.TextColor3 = Color3.fromRGB(170, 205, 255)
    githubLabel.Font = Enum.Font.Gotham
    githubLabel.TextSize = 14
    githubLabel.ZIndex = 11
    
    -- Animação de entrada
    splashLabel.TextTransparency = 1
    githubLabel.TextTransparency = 1
    
    local fadeIn = TweenService:Create(
        splashLabel,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad),
        {TextTransparency = 0}
    )
    
    local githubFadeIn = TweenService:Create(
        githubLabel,
        TweenInfo.new(0.7, Enum.EasingStyle.Quad),
        {TextTransparency = 0}
    )
    
    fadeIn:Play()
    githubFadeIn:Play()
    
    -- Animação de saída (após 2.5 segundos)
    task.delay(2.5, function()
        local fadeOut = TweenService:Create(
            splashLabel,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad),
            {TextTransparency = 1}
        )
        
        local githubFadeOut = TweenService:Create(
            githubLabel,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad),
            {TextTransparency = 1}
        )
        
        fadeOut:Play()
        githubFadeOut:Play()
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
    library.MiniButton.BackgroundColor3 = COLOR_PALETTE.Accent
    library.MiniButton.BorderSizePixel = 0
    library.MiniButton.Text = ""
    
    -- Se a UI principal ainda não existe, crie-a
    if not library.MainUI then
        self:CreateMainUI()
    end
    
    library.MiniButton.Parent = library.MainUI
    Instance.new("UICorner", library.MiniButton).CornerRadius = UDim.new(1, 0)

    -- Ícone da bolinha
    local icon = Instance.new("ImageLabel", library.MiniButton)
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.new(1, -8, 1, -8)
    icon.Position = UDim2.new(0, 4, 0, 4)
    icon.Image = "rbxassetid://138110497553919"

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

    -- Alternar UI principal e centralizar
    library.MiniButton.MouseButton1Click:Connect(function()
        if library.MainWindow then
            library.MainWindow.Visible = not library.MainWindow.Visible
            
            -- CORREÇÃO: Centralizar a janela quando aberta
            if library.MainWindow.Visible then
                library.MainWindow.Position = UDim2.new(0.5, -250, 0.5, -200)
            end
        end
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
    -- Criação da UI principal
    library.MainUI = Instance.new("ScreenGui")
    library.MainUI.Name = "TuxRayUI"
    library.MainUI.Parent = CoreGui
    library.MainUI.ResetOnSpawn = false
    library.MainUI.Enabled = true

    -- Criar a janela principal
    self:CreateMainWindow()
    
    -- Criar a área de conteúdo
    self:CreateContentArea()
end

function TuxRay:CreateMainWindow()
    -- Janela principal (inicialmente invisível)
    library.MainWindow = Instance.new("Frame", library.MainUI)
    library.MainWindow.Name = "MainWindow"
    library.MainWindow.Size = UDim2.new(0, 500, 0, 450)
    library.MainWindow.Position = UDim2.new(0.5, -250, 0.5, -225)
    library.MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
    library.MainWindow.BackgroundColor3 = library.Config.Color
    library.MainWindow.BorderSizePixel = 0
    library.MainWindow.ClipsDescendants = true
    library.MainWindow.Visible = false
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

function TuxRay:CreateContentArea()
    -- Área de conteúdo
    library.ContentArea = Instance.new("ScrollingFrame", library.MainWindow)
    library.ContentArea.Name = "ContentArea"
    library.ContentArea.Size = UDim2.new(1, -20, 1, -90)
    library.ContentArea.Position = UDim2.new(0, 10, 0, 85)
    library.ContentArea.BackgroundTransparency = 1
    library.ContentArea.ClipsDescendants = true
    library.ContentArea.ScrollBarThickness = 5
    library.ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
    library.ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local uiListLayout = Instance.new("UIListLayout", library.ContentArea)
    uiListLayout.Padding = UDim.new(0, 10)
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
end

function TuxRay:CreateTabButton(name)
    if not library.TabContainer then
        task.spawn(function()
            wait(0.5)
            self:CreateTabButton(name)
        end)
        return
    end
    
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
        for _, child in ipairs(library.TabContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            end
        end
        
        tabButton.BackgroundColor3 = COLOR_PALETTE.Accent
    end)
    
    if #library.TabContainer:GetChildren() == 1 then
        tabButton.BackgroundColor3 = COLOR_PALETTE.Accent
    end
end

-- Métodos para criar elementos
function TuxRay:CreateButton(tab, options)
    if not options.Name then return end
    
    if not self:EnsureUIReady() or not library.ContentArea then
        task.spawn(function()
            wait(0.1)
            self:CreateButton(tab, options)
        end)
        return
    end
    
    local button = Instance.new("TextButton")
    button.Name = options.Name
    button.Text = options.Name
    button.Size = UDim2.new(1, 0, 0, 32)
    button.LayoutOrder = #library.ContentArea:GetChildren()
    button.BackgroundColor3 = COLOR_PALETTE.Accent
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
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(100, 140, 200)
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = COLOR_PALETTE.Accent
    end)
    
    table.insert(tab.Elements, button)
    return button
end

function TuxRay:CreateToggle(tab, options)
    if not options.Name then return end
    
    if not self:EnsureUIReady() or not library.ContentArea then
        task.spawn(function()
            wait(0.1)
            self:CreateToggle(tab, options)
        end)
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
    if not options.Name then return end
    
    if not self:EnsureUIReady() or not library.ContentArea then
        task.spawn(function()
            wait(0.1)
            self:CreateLabel(tab, options)
        end)
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

function TuxRay:CreateSlider(tab, options)
    if not options.Name then return end
    if not options.Min or not options.Max then return end
    
    if not self:EnsureUIReady() or not library.ContentArea then
        task.spawn(function()
            wait(0.1)
            self:CreateSlider(tab, options)
        end)
        return
    end
    
    local defaultValue = options.Default or options.Min
    local precision = options.Precision or 0
    
    -- Container do slider
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Name = options.Name .. "SliderContainer"
    sliderContainer.Size = UDim2.new(1, 0, 0, 60)
    sliderContainer.LayoutOrder = #library.ContentArea:GetChildren()
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = library.ContentArea
    
    -- Label do nome e valor
    local label = Instance.new("TextLabel", sliderContainer)
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = string.format("%s: [%.*f]", options.Name, precision, defaultValue)
    label.TextColor3 = Color3.fromRGB(170, 205, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Barra de fundo
    local track = Instance.new("Frame", sliderContainer)
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 30)
    track.BackgroundColor3 = COLOR_PALETTE.SliderTrack
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    
    -- Barra de preenchimento
    local fill = Instance.new("Frame", track)
    fill.Name = "Fill"
    fill.Size = UDim2.new((defaultValue - options.Min) / (options.Max - options.Min), 0, 1, 0)
    fill.BackgroundColor3 = COLOR_PALETTE.SliderFill
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    -- Thumb (botão de arrasto)
    local thumb = Instance.new("TextButton", track)
    thumb.Name = "Thumb"
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
    thumb.BackgroundColor3 = Color3.new(1, 1, 1)
    thumb.Text = ""
    thumb.ZIndex = 2
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
    
    -- Função para atualizar o valor do slider
    local function setValue(value)
        value = math.clamp(value, options.Min, options.Max)
        value = tonumber(string.format("%."..precision.."f", value))
        
        fill.Size = UDim2.new((value - options.Min) / (options.Max - options.Min), 0, 1, 0)
        thumb.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
        label.Text = string.format("%s: [%.*f]", options.Name, precision, value)
        
        if options.Callback then
            options.Callback(value)
        end
    end
    
    -- Interação
    local dragging = false
    local function updateSlider(input)
        local relativeX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
        local value = options.Min + (options.Max - options.Min) * math.clamp(relativeX, 0, 1)
        setValue(value)
    end
    
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    thumb.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    -- Inicializar com o valor padrão
    setValue(defaultValue)
    
    table.insert(tab.Elements, sliderContainer)
    return sliderContainer
end

-- Função de inicialização
local function Initialize()
    return TuxRay
end

return Initialize()
