-- Carregar a biblioteca
local TuxRay = loadstring(game:HttpGet("https://raw.githubusercontent.com/OreOFDev/TuxRay/main/main.lua"))()

-- Criar janela com cor personalizada
local Window = TuxRay:CreateWindow({
    Name = "Menu Principal",
    Color = "DarkBlue" -- Cor pré-definida
})

-- Criar aba
local MainTab = Window:CreateTab({
    Name = "Recursos"
})

-- Criar elementos - o sistema agora garante que serão criados
MainTab:CreateButton({
    Name = "Ativar Sistema",
    Callback = function()
        print("Sistema ativado com sucesso!")
    end
})

MainTab:CreateToggle({
    Name = "Modo Noturno",
    Default = true,
    Callback = function(State)
        print("Modo noturno:", State and "ATIVADO" or "DESATIVADO")
    end
})

MainTab:CreateLabel({
    Name = "Configurações avançadas:"
})
