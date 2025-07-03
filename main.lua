-- TuxRay UI Library
-- By oRee Scripter

local TuxRay = {}
TuxRay.__index = TuxRay

-- Serviços necessários
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Constantes
local ACCENT_COLOR = Color3.fromRGB(110, 200, 255)
local BACKGROUND_COLOR = Color3.fromRGB(28, 28, 38)
local ELEMENT_COLOR = Color3.fromRGB(46, 46, 66)
local TEXT_COLOR = Color3.fromRGB(220, 220, 255)

-- Função para criar elementos com propriedades comuns
local function createElement(className, properties)
    local element = Instance.new(className)
    for prop, value in pairs(properties) do
        element[prop] = value
    end
    return element
end

-- Função para criar cantos arredondados
local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

-- Função para criar sombra
local function createShadow(parent)
    local shadow = createElement("ImageLabel", {
        Name = "Shadow",
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.8,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0, -5, 0, -5),
        BackgroundTransparency = 1,
        ZIndex = -1
    })
    shadow.Parent = parent
    return shadow
end

-- Cria uma nova janela TuxRay
function TuxRay.new(options)
    options = options or {}
    
    local self = setmetatable({}, TuxRay)
    
    self.Name = options.Name or "TuxRay UI"
    self.Size = options.Size or UDim2.new(0, 500, 0, 400)
    self.Position = options.Position or UDim2.new(0.5, 0, 0.5, 0)
    self.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Theme = options.Theme or "Dark"
    self.ToggleKey = options.ToggleKey or Enum.KeyCode.Insert
    
    -- Cria a GUI principal
    self.ScreenGui = createElement("ScreenGui", {
        Name = "TuxRay_"..tostring(math.random(10000, 99999)),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Parent = CoreGui
    })
    
    -- Frame principal
    self.MainFrame = createElement("Frame", {
        Name = "MainFrame",
        Size = self.Size,
        Position = self.Position,
        AnchorPoint = self.AnchorPoint,
        BackgroundColor3 = BACKGROUND_COLOR,
        BorderSizePixel = 0,
        Parent = self.ScreenGui
    })
    createCorner(self.MainFrame, 12)
    createShadow(self.MainFrame)
    
    -- Barra de título
    self.TitleBar = createElement("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = ELEMENT_COLOR,
        BorderSizePixel = 0,
        Parent = self.MainFrame
    })
    createCorner(self.TitleBar, 12)
    
    -- Título
    self.TitleLabel = createElement("TextLabel", {
        Name = "TitleLabel",
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Name,
        TextColor3 = ACCENT_COLOR,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar
    })
    
    -- Botão de fechar
    self.CloseButton = createElement("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -40, 0.5, -16),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = ELEMENT_COLOR,
        Text = "X",
        TextColor3 = TEXT_COLOR,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = self.TitleBar
    })
    createCorner(self.CloseButton, 8)
    
    -- Container para tabs
    self.TabContainer = createElement("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(1, -24, 0, 36),
        Position = UDim2.new(0, 12, 0, 44),
        BackgroundTransparency = 1,
        Parent = self.MainFrame
    })
    
    -- Container para conteúdo
    self.ContentFrame = createElement("ScrollingFrame", {
        Name = "ContentFrame",
        Size = UDim2.new(1, -24, 1, -96),
        Position = UDim2.new(0, 12, 0, 88),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = ACCENT_COLOR,
        Parent = self.MainFrame
    })
    
    -- Lista para elementos de UI
    self.UIListLayout = createElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = self.ContentFrame
    })
    
    -- Configurar arrastar a janela
    local dragging, dragInput, dragStart, startPos
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    self.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Configurar tecla de toggle
    self.ToggleConnection = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == self.ToggleKey then
            self.ScreenGui.Enabled = not self.ScreenGui.Enabled
        end
    end)
    
    -- Fechar a janela
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    self.Tabs = {}
    self.CurrentTab = nil
    
    return self
end

-- Adicionar uma nova aba
function TuxRay:AddTab(name)
    local tab = {
        Name = name,
        Buttons = {},
        Toggles = {},
        Sections = {}
    }
    
    -- Criar botão da aba
    local tabButton = createElement("TextButton", {
        Name = name.."TabButton",
        Size = UDim2.new(0, 100, 1, 0),
        BackgroundColor3 = ELEMENT_COLOR,
        Text = name,
        TextColor3 = TEXT_COLOR,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        LayoutOrder = #self.Tabs + 1,
        Parent = self.TabContainer
    })
    createCorner(tabButton, 8)
    
    -- Configurar clique na aba
    tabButton.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Selecionar a primeira aba por padrão
    if #self.Tabs == 1 then
        self:SwitchTab(tab)
    end
    
    return tab
end

-- Mudar para uma aba específica
function TuxRay:SwitchTab(tab)
    if self.CurrentTab == tab then return end
    
    -- Atualizar botões de abas
    for _, t in ipairs(self.Tabs) do
        local button = self.TabContainer:FindFirstChild(t.Name.."TabButton")
        if button then
            if t == tab then
                button.BackgroundColor3 = ACCENT_COLOR
                button.TextColor3 = Color3.new(1, 1, 1)
            else
                button.BackgroundColor3 = ELEMENT_COLOR
                button.TextColor3 = TEXT_COLOR
            end
        end
    end
    
    -- Limpar conteúdo atual
    for _, child in ipairs(self.ContentFrame:GetChildren()) do
        if child:IsA("Frame") then
            child.Visible = false
        end
    end
    
    -- Mostrar conteúdo da nova aba
    if not tab.ContentFrame then
        -- Criar frame de conteúdo se não existir
        tab.ContentFrame = createElement("Frame", {
            Name = tab.Name.."Content",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Parent = self.ContentFrame
        })
        
        local listLayout = createElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12),
            Parent = tab.ContentFrame
        })
    end
    
    tab.ContentFrame.Visible = true
    self.CurrentTab = tab
end

-- CORREÇÃO DO ERRO: Função AddSection corrigida
function TuxRay:AddSection(tab, name)
    if not tab then return end
    
    local section = {
        Name = name,
        Elements = {}
    }
    
    local sectionFrame = createElement("Frame", {
        Name = name.."Section",
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        LayoutOrder = #tab.Sections + 1,
        Parent = tab.ContentFrame
    })
    
    local sectionTitle = createElement("TextLabel", {
        Name = "SectionTitle",
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = ACCENT_COLOR,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sectionFrame
    })
    
    local sectionElements = createElement("Frame", {
        Name = "Elements",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 28),
        BackgroundTransparency = 1,
        Parent = sectionFrame
    })
    
    local listLayout = createElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = sectionElements
    })
    
    section.Frame = sectionFrame
    section.ElementsFrame = sectionElements
    table.insert(tab.Sections, section)
    
    return section
end

-- Adicionar um botão à seção
function TuxRay:AddButton(section, name, callback)
    if not section then return end
    
    local button = createElement("TextButton", {
        Name = name,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = ELEMENT_COLOR,
        Text = name,
        TextColor3 = TEXT_COLOR,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        LayoutOrder = #section.Elements + 1,
        Parent = section.ElementsFrame
    })
    createCorner(button, 8)
    
    button.MouseButton1Click:Connect(callback)
    
    table.insert(section.Elements, button)
    
    return button
end

-- Adicionar um toggle à seção
function TuxRay:AddToggle(section, name, default, callback)
    if not section then return end
    
    local toggle = {
        Name = name,
        State = default or false,
        Callback = callback
    }
    
    local toggleFrame = createElement("Frame", {
        Name = name.."Toggle",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        LayoutOrder = #section.Elements + 1,
        Parent = section.ElementsFrame
    })
    
    local toggleButton = createElement("TextButton", {
        Name = "ToggleButton",
        Size = UDim2.new(0, 80, 1, 0),
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = toggle.State and ACCENT_COLOR or Color3.fromRGB(80, 80, 100),
        Text = toggle.State and "ON" or "OFF",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        Parent = toggleFrame
    })
    createCorner(toggleButton, 8)
    
    local toggleLabel = createElement("TextLabel", {
        Name = "ToggleLabel",
        Size = UDim2.new(1, -90, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = TEXT_COLOR,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toggleFrame
    })
    
    toggleButton.MouseButton1Click:Connect(function()
        toggle.State = not toggle.State
        toggleButton.Text = toggle.State and "ON" or "OFF"
        toggleButton.BackgroundColor3 = toggle.State and ACCENT_COLOR or Color3.fromRGB(80, 80, 100)
        
        if callback then
            callback(toggle.State)
        end
    end)
    
    toggle.Frame = toggleFrame
    toggle.Button = toggleButton
    table.insert(section.Elements, toggle)
    
    return toggle
end

-- Adicionar um slider à seção
function TuxRay:AddSlider(section, name, min, max, default, callback)
    if not section then return end
    
    local slider = {
        Name = name,
        Value = default or min,
        Min = min,
        Max = max,
        Callback = callback
    }
    
    local sliderFrame = createElement("Frame", {
        Name = name.."Slider",
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        LayoutOrder = #section.Elements + 1,
        Parent = section.ElementsFrame
    })
    
    local sliderLabel = createElement("TextLabel", {
        Name = "SliderLabel",
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = name..": "..tostring(slider.Value),
        TextColor3 = TEXT_COLOR,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sliderFrame
    })
    
    local sliderTrack = createElement("Frame", {
        Name = "SliderTrack",
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(60, 60, 80),
        Parent = sliderFrame
    })
    createCorner(sliderTrack, 4)
    
    local sliderFill = createElement("Frame", {
        Name = "SliderFill",
        Size = UDim2.new((slider.Value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = ACCENT_COLOR,
        Parent = sliderTrack
    })
    createCorner(sliderFill, 4)
    
    local sliderButton = createElement("TextButton", {
        Name = "SliderButton",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new((slider.Value - min) / (max - min), -8, 0.5, -8),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        AutoButtonColor = false,
        Text = "",
        Parent = sliderTrack
    })
    createCorner(sliderButton, 8)
    
    -- Configurar interação do slider
    local dragging = false
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    sliderTrack.MouseButton1Down:Connect(function(x, y)
        dragging = true
        local percent = math.clamp((x - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
        slider.Value = math.floor(min + (max - min) * percent)
        updateSlider()
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
            slider.Value = math.floor(min + (max - min) * percent)
            updateSlider()
        end
    end)
    
    local function updateSlider()
        sliderLabel.Text = name..": "..tostring(slider.Value)
        sliderFill.Size = UDim2.new((slider.Value - min) / (max - min), 0, 1, 0)
        sliderButton.Position = UDim2.new((slider.Value - min) / (max - min), -8, 0.5, -8)
        
        if callback then
            callback(slider.Value)
        end
    end
    
    slider.Frame = sliderFrame
    table.insert(section.Elements, slider)
    
    return slider
end

-- Adicionar um dropdown à seção
function TuxRay:AddDropdown(section, name, options, default, callback)
    if not section then return end
    
    local dropdown = {
        Name = name,
        Options = options,
        Selected = default or options[1],
        Callback = callback,
        Open = false
    }
    
    local dropdownFrame = createElement("Frame", {
        Name = name.."Dropdown",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        LayoutOrder = #section.Elements + 1,
        Parent = section.ElementsFrame
    })
    
    local dropdownButton = createElement("TextButton", {
        Name = "DropdownButton",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = ELEMENT_COLOR,
        Text = name..": "..dropdown.Selected,
        TextColor3 = TEXT_COLOR,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        Parent = dropdownFrame
    })
    createCorner(dropdownButton, 8)
    
    local dropdownList = createElement("Frame", {
        Name = "DropdownList",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = ELEMENT_COLOR,
        Visible = false,
        Parent = dropdownFrame
    })
    createCorner(dropdownList, 8)
    
    local listLayout = createElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = dropdownList
    })
    
    dropdownButton.MouseButton1Click:Connect(function()
        dropdown.Open = not dropdown.Open
        dropdownList.Visible = dropdown.Open
        
        if dropdown.Open then
            -- Criar itens do dropdown
            for i, option in ipairs(dropdown.Options) do
                local optionButton = createElement("TextButton", {
                    Name = option.."Option",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = ELEMENT_COLOR,
                    Text = option,
                    TextColor3 = TEXT_COLOR,
                    TextSize = 14,
                    Font = Enum.Font.GothamMedium,
                    LayoutOrder = i,
                    Parent = dropdownList
                })
                
                optionButton.MouseButton1Click:Connect(function()
                    dropdown.Selected = option
                    dropdownButton.Text = name..": "..option
                    dropdownList.Visible = false
                    dropdown.Open = false
                    
                    if callback then
                        callback(option)
                    end
                end)
            end
            
            -- Atualizar tamanho da lista
            dropdownList.Size = UDim2.new(1, 0, 0, #dropdown.Options * 30 + 4)
        end
    end)
    
    dropdown.Frame = dropdownFrame
    table.insert(section.Elements, dropdown)
    
    return dropdown
end

-- Adicionar um label à seção
function TuxRay:AddLabel(section, text)
    if not section then return end
    
    local label = createElement("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = TEXT_COLOR,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = #section.Elements + 1,
        Parent = section.ElementsFrame
    })
    
    table.insert(section.Elements, label)
    
    return label
end

-- Destruir a UI
function TuxRay:Destroy()
    if self.ToggleConnection then
        self.ToggleConnection:Disconnect()
    end
    
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

return TuxRay
