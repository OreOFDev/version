-- TuxRay UI Library
local TuxRay = {}
TuxRay.__index = TuxRay
TuxRay.ElementsPerPage = 3 -- 3 elementos por página

-- Cores e temas baseado no estilo "oRee Scripter X Brainrot"
local Theme = {
    Background = Color3.fromRGB(28, 28, 38),
    Header = Color3.fromRGB(20, 20, 30),
    TextColor = Color3.fromRGB(200, 200, 255),
    ElementBackground = Color3.fromRGB(35, 35, 45),
    ToggleOn = Color3.fromRGB(36, 56, 46),
    ToggleOff = Color3.fromRGB(56, 36, 36),
    PageNumber = Color3.fromRGB(60, 60, 80),
    PageNumberActive = Color3.fromRGB(0, 170, 255),
    Separator = Color3.fromRGB(100, 100, 120)
}

-- Funções utilitárias
local function CreateElement(className, properties)
    local element = Instance.new(className)
    for prop, value in pairs(properties) do
        element[prop] = value
    end
    return element
end

local function Roundify(element, cornerRadius)
    local corner = CreateElement("UICorner", {
        CornerRadius = UDim.new(0, cornerRadius or 8),
        Parent = element
    })
    return element
end

-- Métodos para páginas
local PageMethods = {}

function PageMethods:AddToggle(info)
    info.Type = "Toggle"
    info.State = info.StartingState or false
    table.insert(self.Elements, info)
    
    if self.Gui.CurrentPage == self then
        self.Gui:RenderPage(self)
    end
end

function TuxRay.new()
    local self = setmetatable({}, TuxRay)
    self.Pages = {}
    self.CurrentPage = nil
    self.Gui = nil
    self.Title = "oRee Scripter X Brainrot" -- Título padrão
    return self
end

function TuxRay:CreateWindow(options)
    options = options or {}
    self.Title = options.Title or self.Title -- Permite customização do título
    
    -- ScreenGui principal
    self.Gui = CreateElement("ScreenGui", {
        Name = "TuxRayUI",
        ResetOnSpawn = false,
        Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    })
    
    -- Splash Screen
    self:SplashScreen()
    
    return self
end

function TuxRay:SplashScreen()
    local splash = CreateElement("Frame", {
        Name = "SplashScreen",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Header,
        ZIndex = 10
    })
    Roundify(splash, 0)
    splash.Parent = self.Gui

    local title = CreateElement("TextLabel", {
        Text = "TuxRay",
        TextSize = 48,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.TextColor,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.4, 0),
        AnchorPoint = Vector2.new(0.5, 0.5)
    })
    title.Parent = splash

    local website = CreateElement("TextLabel", {
        Text = "https://oreofdev.github.io/Sw1ftSync/tuxray",
        TextSize = 18,
        Font = Enum.Font.Gotham,
        TextColor3 = Theme.TextColor,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.55, 0),
        AnchorPoint = Vector2.new(0.5, 0.5)
    })
    website.Parent = splash

    -- Fechar splash após 3 segundos
    task.delay(3, function()
        local tween = game:GetService("TweenService"):Create(
            splash,
            TweenInfo.new(0.5),
            {BackgroundTransparency = 1}
        )
        tween:Play()
        tween.Completed:Wait()
        splash:Destroy()
        self:CreateMainUI()
    end)
end

function TuxRay:CreateMainUI()
    -- Janela principal
    self.MainWindow = CreateElement("Frame", {
        Name = "MainWindow",
        Size = UDim2.new(0, 330, 0, 220), -- Tamanho exato do script original
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        ClipsDescendants = true
    })
    Roundify(self.MainWindow, 12)
    self.MainWindow.Parent = self.Gui

    -- Header
    local header = CreateElement("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme.Header
    })
    Roundify(header, {topLeft = 12, topRight = 12})
    header.Parent = self.MainWindow

    -- Título da janela
    local windowTitle = CreateElement("TextLabel", {
        Text = self.Title,
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.TextColor,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    windowTitle.Parent = header

    -- Sistema de arraste
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainWindow.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.MainWindow.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Container de conteúdo
    self.ContentFrame = CreateElement("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -20, 1, -70),
        Position = UDim2.new(0, 10, 0, 46),
        BackgroundTransparency = 1
    })
    self.ContentFrame.Parent = self.MainWindow

    -- Controles de paginação
    self.PaginationFrame = CreateElement("Frame", {
        Name = "Pagination",
        Size = UDim2.new(1, -20, 0, 32),
        Position = UDim2.new(0, 10, 1, -40),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = 1
    })
    self.PaginationFrame.Parent = self.MainWindow

    -- Criar abas para as páginas
    self:UpdateTabs()
end

function TuxRay:createPage(name)
    local newPage = {
        Name = name,
        Elements = {},
        CurrentPage = 1
    }
    
    setmetatable(newPage, {__index = PageMethods})
    table.insert(self.Pages, newPage)
    
    -- Se for a primeira página, definimos como atual
    if #self.Pages == 1 then
        self:SetPage(newPage)
    end
    
    return newPage
end

function TuxRay:SetPage(page)
    if self.CurrentPage == page then return end
    self.CurrentPage = page
    self:RenderPage(page)
end

function TuxRay:RenderPage(page)
    if not self.ContentFrame then return end
    
    -- Limpar elementos anteriores
    for _, child in ipairs(self.ContentFrame:GetChildren()) do
        child:Destroy()
    end
    
    -- Calcular elementos para a página atual
    local startIndex = (page.CurrentPage - 1) * self.ElementsPerPage + 1
    local endIndex = math.min(#page.Elements, startIndex + self.ElementsPerPage - 1)
    
    -- Renderizar elementos
    local yOffset = 0
    for i = startIndex, endIndex do
        local element = page.Elements[i]
        if element.Type == "Toggle" then
            local toggleFrame = self:CreateToggleElement(element)
            toggleFrame.Position = UDim2.new(0, 0, 0, yOffset)
            toggleFrame.Parent = self.ContentFrame
            yOffset += 40 -- Espaçamento entre elementos
        end
    end
    
    -- Atualizar controles de paginação
    self:UpdatePagination(page)
end

function TuxRay:UpdatePagination(page)
    if not self.PaginationFrame then return end
    
    -- Limpar paginação anterior
    for _, child in ipairs(self.PaginationFrame:GetChildren()) do
        child:Destroy()
    end
    
    local totalPages = math.ceil(#page.Elements / self.ElementsPerPage)
    if totalPages <= 1 then return end
    
    -- Container para números de página
    local pageNumbers = CreateElement("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = self.PaginationFrame
    })
    
    -- Calcular posição inicial para centralizar
    local totalWidth = totalPages * 32
    local startX = (self.PaginationFrame.AbsoluteSize.X - totalWidth) / 2
    
    for i = 1, totalPages do
        local numBtn = CreateElement("TextButton", {
            Text = tostring(i),
            Size = UDim2.new(0, 32, 1, 0),
            Position = UDim2.new(0, startX + (i-1)*32, 0, 0),
            BackgroundColor3 = (i == page.CurrentPage) and Theme.PageNumberActive or Theme.PageNumber,
            TextColor3 = Theme.TextColor,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            Parent = pageNumbers
        })
        Roundify(numBtn, 8)
        
        numBtn.MouseButton1Click:Connect(function()
            if i ~= page.CurrentPage then
                page.CurrentPage = i
                self:RenderPage(page)
            end
        end)
    end
end

-- Elementos da UI no estilo exato do script
function TuxRay:CreateToggleElement(elementInfo)
    local frame = CreateElement("TextButton", {
        Name = "Toggle_"..elementInfo.Name,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = elementInfo.State and Theme.ToggleOn or Theme.ToggleOff,
        Text = "",
        AutoButtonColor = false
    })
    Roundify(frame, 8)
    
    -- Estado (ON/OFF)
    local stateLabel = CreateElement("TextLabel", {
        Text = elementInfo.State and "ON" or "OFF",
        Size = UDim2.new(0, 35, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = elementInfo.State and Color3.fromRGB(80,255,120) or Color3.fromRGB(255,100,100),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    
    -- Separador "|"
    local separator = CreateElement("TextLabel", {
        Text = "|",
        Size = UDim2.new(0, 10, 1, 0),
        Position = UDim2.new(0, 50, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Separator,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        Parent = frame
    })
    
    -- Nome do toggle
    local nameLabel = CreateElement("TextLabel", {
        Text = elementInfo.Name,
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 65, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.TextColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        Parent = frame
    })
    
    -- Atualizar quando o estado mudar
    local function updateToggle(state)
        elementInfo.State = state
        stateLabel.Text = state and "ON" or "OFF"
        stateLabel.TextColor3 = state and Color3.fromRGB(80,255,120) or Color3.fromRGB(255,100,100)
        frame.BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
        
        if elementInfo.Callback then
            pcall(elementInfo.Callback, state)
        end
    end
    
    -- Toggle ao clicar
    frame.MouseButton1Click:Connect(function()
        updateToggle(not elementInfo.State)
    end)
    
    return frame
end

return TuxRay
