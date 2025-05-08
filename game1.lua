if script_loaded then warn("Script is already loaded, please rejoin the game to load it again.") return end pcall(function() getgenv().script_loaded = true end)
warn("Loading...")
local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

local w = Library:CreateWindow{
    Title = "Smoke Hub",
    SubTitle = "by sa Boll di va",
    TabWidth = 160,
    Size = UDim2.fromOffset(830, 525),
    Resize = true,
    MinSize = Vector2.new(470, 380),
    Acrylic = true,
    Theme = "Abyss",
    MinimizeKey = Enum.KeyCode.LeftControl
}

local Tabs = {
    Main = w:CreateTab{
        Title = "หน้าหลัก",
        Icon = "house"
    },
    Farm = w:CreateTab{
        Title = "ฟาม",
        Icon = "tractor"
    },
    Settings = w:CreateTab{
        Title = "ตั้งค่า",
        Icon = "settings"
    }
}

local Options = Library.Options

local players = game:GetService("Players")
local plr = players.LocalPlayer
local sellPart = workspace:FindFirstChild("Scripted"):FindFirstChild("Sell")
local drillsUi = plr.PlayerGui:FindFirstChild("Menu"):FindFirstChild("CanvasGroup").Buy
local handdrillsUi = plr.PlayerGui:FindFirstChild("Menu"):FindFirstChild("CanvasGroup").HandDrills
local plot = nil

-- // Get Player Plot
if plr then
    for _, p in ipairs(workspace.Plots:GetChildren()) do
        if p:FindFirstChild("Owner") and p.Owner.Value == plr then
            plot = p
            break
        end
    end
end

-- // Sell Logic
local function sell()
    local wasDrillsUiOpen = drillsUi.Visible
    local wasHandDrillsUiOpen = handdrillsUi.Visible

    drillsUi.Visible = false
    handdrillsUi.Visible = false
    
    lastPos = plr.Character:FindFirstChild("HumanoidRootPart").CFrame
    plr.Character:FindFirstChild("HumanoidRootPart").CFrame = sellPart.CFrame
    task.wait(0.2)

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Knit = require(ReplicatedStorage.Packages:WaitForChild("Knit"))
    local OreService = Knit.GetService("OreService")

    OreService.SellAll:Fire()
    task.wait(0.2)

    if lastPos and lastPos ~= nil then
        plr.Character:FindFirstChild("HumanoidRootPart").CFrame = lastPos
    end

    if wasDrillsUiOpen then
        drillsUi.Visible = true
        Options.drillsUI:SetValue(true)
    end

    if wasHandDrillsUiOpen then
        handdrillsUi.Visible = true
        Options.handdrillsUI:SetValue(true)
    end
end
-- // Player List

local function updatePlayerList()
    playerList = {}
    for _, v in ipairs(players:GetPlayers()) do
        if v ~= plr then
            table.insert(playerList, v.Name)
        end
    end
    Options.players:SetValues(playerList)
end

players.PlayerAdded:Connect(function()
    updatePlayerList()
end)

players.PlayerRemoving:Connect(function()
    updatePlayerList()
end)

--// Main
local drillsUI = Tabs.Main:CreateToggle("drillsUI", {Title = "เปิดร้านค้าเครื่องขุด", Default = false })
local handdrillsUI = Tabs.Main:CreateToggle("handdrillsUI", {Title = "เปิดร้านค้าหัวเครื่องขุด", Default = false })
drillsUI:OnChanged(function()
    if Options.drillsUI.Value then
        Options.handdrillsUI:SetValue(false)
    end
    drillsUi.Visible = Options.drillsUI.Value
end)
drillsUi:GetPropertyChangedSignal("Visible"):Connect(function()
    if not drillsUi.Visible then
        Options.drillsUI:SetValue(false)
    end
end)
handdrillsUI:OnChanged(function()
    if Options.handdrillsUI.Value then
        Options.drillsUI:SetValue(false)
    end
    handdrillsUi.Visible = Options.handdrillsUI.Value
end)
handdrillsUi:GetPropertyChangedSignal("Visible"):Connect(function()
    if not handdrillsUi.Visible then
        Options.handdrillsUI:SetValue(false)
    end
end)
local choosenPlayer = nil
local playersDropdown = Tabs.Main:CreateDropdown("players", {
    Title = "เลือกผู้เล่น",
    Values = {},
    Multi = false
})
playersDropdown:OnChanged(function(Value)
    choosenPlayer = Value
end)
updatePlayerList()
Tabs.Main:CreateButton{
    Title = "เทเลพอร์ตไปยังผู้เล่น",
    Description = "เทเลพอร์ตไปยังผู้เล่นที่เลือก",
    Callback = function()
        if choosenPlayer then
            local targetPlayer = players:FindFirstChild(choosenPlayer)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetPosition = targetPlayer.Character.HumanoidRootPart.CFrame
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    plr.Character.HumanoidRootPart.CFrame = targetPosition
                else
                    Library:Notify{Title = "Error", Content = "ตัวละครของคุณขาด HumanoidRootPart", Duration = 5}
                end
            else
                Library:Notify{Title = "Error", Content = "ไม่พบผู้เล่นเป้าหมายหรือไม่ถูกต้อง", Duration = 5}
            end
        else
            Library:Notify{Title = "Error", Content = "ไม่ได้เลือกผู้เล่น", Duration = 5}
        end
    end
}
Tabs.Main:CreateButton{
    Title = "เทเลพอร์ตไปยังเเปลงผู้เล่น",
    Description = "เทเลพอร์ตไปยังเเปลงของผู้เล่นที่เลือก",
    Callback = function()
        if choosenPlayer then
            local targetPlayer = players:FindFirstChild(choosenPlayer)
            if targetPlayer then
                local targetPlot = nil
                for _, p in ipairs(workspace.Plots:GetChildren()) do
                    if p:FindFirstChild("Owner") and p.Owner.Value == targetPlayer then
                        targetPlot = p
                        break
                    end
                end

                if targetPlot and targetPlot:FindFirstChild("PlotSpawn") then
                    local plotCenter = targetPlot.PlotSpawn.CFrame
                    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        plr.Character.HumanoidRootPart.CFrame = plotCenter
                    else
                        Library:Notify{Title = "Error", Content = "Your character is missing HumanoidRootPart", Duration = 5}
                    end
                else
                    Library:Notify{Title = "Error", Content = "Target player's plot not found or invalid", Duration = 5}
                end
            else
                Library:Notify{Title = "Error", Content = "Target player not found", Duration = 5}
            end
        else
            Library:Notify{Title = "Error", Content = "No player selected", Duration = 5}
        end
    end
}
Tabs.Main:CreateButton{
    Title = "กันโดน AFK",
    Description = "คุณจะไม่ถูกเตะภายใน 20 นาทีด้วย afk",
    Callback = function()
        local bb = game:GetService("VirtualUser")
        plr.Idled:Connect(
            function()
                bb:CaptureController()
                bb:ClickButton2(Vector2.new())
            end
        )
    end
}

-- // Farm
local delay = 10
local autodrill = Tabs.Farm:CreateToggle("autodrill", {Title = "ขุดอัตโนมัติ", Default = false })
local autopickup = Tabs.Farm:CreateToggle("autopickup", {Title = "ถือที่ขุดอัตโนมัติ", Default = false })
Tabs.Farm:CreateButton{ Title = "ขายเเร่", Description = "ขาดเเร่หมดทั้งตัว", Callback = function() sell() end } 
Tabs.Farm:CreateInput("selldelay", {Title="ขายอัตโนมัติ ดีเล", Default=tostring(delay), Placeholder=tostring(delay), Numeric=true, Finished=true, Callback=function(Value)local num=tonumber(Value) if num and num>=1 then delay=num else Library:Notify{Title="Warning", Content="Only numbers (1+)", Duration=5} end end})
local autosell = Tabs.Farm:CreateToggle("autosell", {Title = "ขายออโต้", Default = false })
local autorebith = Tabs.Farm:CreateToggle("autorebith", {Title = "ออโต้ รีเบิร์ด", Default = false })
Tabs.Farm:CreateParagraph("Paragraph", { Title = "ออโต้เก็บ", })
local collectdrills = Tabs.Farm:CreateToggle("collectdrills", {Title = "เก็บจากเครื่องขุด", Default = false })
local collectstorages = Tabs.Farm:CreateToggle("collectstorage", {Title = "รวบรวมพื้นที่เก็บข้อมูลอัตโนมัติ", Default = false })
Tabs.Farm:CreateParagraph("Paragraph", { Title = "  ตั้งค่า  ", })
local drillsfull = Tabs.Farm:CreateToggle("drillsfull", {Title = "ถ้าเจาะเต็ม", Default = false })
local drillsdelay = Tabs.Farm:CreateToggle("drillsdelay", {Title = "ใน...วินาที", Default = false })
local delayDrills = 10
Tabs.Farm:CreateInput("collectdrillsdelay", {Title="เก็บจากเครื่อง ดีเล", Default=delayDrills, Placeholder=delayDrills, Numeric=true, Finished=true, Callback=function(Value) local num=tonumber(Value) if num and num>=1 then delayDrills=num else Library:Notify{Title="Warning", Content="Only numbers (1+)", Duration=5} end end})
local storagesfull = Tabs.Farm:CreateToggle("storagesfull", {Title = "หากพื้นที่จัดเก็บเต็ม", Default = false })
local storagesdelay = Tabs.Farm:CreateToggle("storagesdelay", {Title = "ใน...วินาที", Default = false })
local storDelay = 10
Tabs.Farm:CreateInput("collectstoragesdelay", {Title="ความล่าช้าในการจัดเก็บ", Default=storDelay, Placeholder=storDelay, Numeric=true, Finished=true, Callback=function(Value) local num=tonumber(Value) if num and num>=1 then storDelay=num else Library:Notify{Title="Warning", Content="Only numbers (1+)", Duration=5} end end})

autopickup:OnChanged(function() -- Options.autopickup.Value
    if Options.autopickup.Value then
        task.spawn(function ()
            while Options.autopickup.Value do
                local drill = (function ()
                    for _, obj in pairs(plr.Character:GetChildren()) do
                        if obj:GetAttribute("Type") == "HandDrill" then
                            return obj
                        end
                    end
                end)()
                if not drill then
                    for _, obj in pairs(plr.Backpack:GetChildren()) do
                        if obj:GetAttribute("Type") == "HandDrill" then
                            obj.Parent = plr.Character
                            break
                        end
                    end
                end
                task.wait(2)
            end
        end)
    end
end)

autodrill:OnChanged(function() -- Options.autodrill.Value
    if Options.autodrill.Value then
        task.spawn(function ()
            while Options.autodrill.Value do
                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild(
                    "Services"
                ):WaitForChild("OreService"):WaitForChild("RE"):WaitForChild("RequestRandomOre"):FireServer()
                task.wait(.01)
            end
        end)
    end
end)
autosell:OnChanged(function() -- Options.autosell.Value
    if Options.autosell.Value then
        task.spawn(function ()
            while Options.autosell.Value do
                sell()
                task.wait(delay)
            end
        end)
    end
end)
autorebith:OnChanged(function() -- Options.autorebith.Value
    if Options.autorebith.Value then
        task.spawn(function ()
            while Options.autorebith.Value do
                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild(
                    "RebirthService"
                ):WaitForChild("RE"):WaitForChild("RebirthRequest"):FireServer()
                task.wait(1)
            end
        end)
    end
end)
collectdrills:OnChanged(function() -- Options.collectdrills.Value
    if Options.collectdrills.Value then
        task.spawn(function()
            while Options.collectdrills.Value do
                if plot and plot:FindFirstChild("Drills") then
                    for _, drill in pairs(plot.Drills:GetChildren()) do
                        if not Options.collectdrills.Value then break end

                        local drillData = drill:FindFirstChild("DrillData")
                        local ores = drill:FindFirstChild("Ores")
                        if drillData and ores then
                            local capacity = drillData:FindFirstChild("Capacity")
                            if capacity then
                                local val = 0
                                for _, ore in pairs(ores:GetChildren()) do
                                    if ore:IsA("IntValue") or ore:IsA("NumberValue") then
                                        val += ore.Value
                                    end
                                end
                                if Options.drillsdelay.Value or not Options.drillsfull.Value or val >= capacity.Value then
                                    game:GetService("ReplicatedStorage").Packages.Knit.Services.PlotService.RE.CollectDrill:FireServer(drill)
                                end
                            end
                        end
                    end
                end
                task.wait(Options.drillsdelay.Value and delayDrills or 2)
            end
        end)
    end
end)
collectstorages:OnChanged(function() -- Options.collectstorage.Value
    if Options.collectstorage.Value then
        task.spawn(function()
            while Options.collectstorage.Value do
                if plot and plot:FindFirstChild("Storage") then
                    for _, storage in pairs(plot.Storage:GetChildren()) do
                        if not Options.collectstorage.Value then break end

                        local storageData = storage:FindFirstChild("DrillData")
                        local storageOres = storage:FindFirstChild("Ores")
                        if storageData and storageOres then
                            local storageCapacity = storageData:FindFirstChild("Capacity")
                            if storageCapacity then
                                local storVal = 0
                                for _, ore in pairs(storageOres:GetChildren()) do
                                    if ore:IsA("IntValue") or ore:IsA("NumberValue") then
                                        storVal += ore.Value
                                    end
                                end
                                if (Options.storagesfull.Value and storVal >= storageCapacity.Value) or not Options.storagesfull.Value then
                                    game:GetService("ReplicatedStorage").Packages.Knit.Services.PlotService.RE.CollectDrill:FireServer(storage)
                                end
                            end
                        end
                    end
                end
                task.wait(Options.storagesdelay.Value and storDelay or 2)
            end
        end)
    end
end)
storagesfull:OnChanged(function()
    if Options.storagesfull.Value and Options.storagesdelay.Value then
        Options.storagesdelay:SetValue(false)
    end
end)
storagesdelay:OnChanged(function()
    if Options.storagesdelay.Value and Options.storagesfull.Value then
        Options.storagesfull:SetValue(false)
    end
end)
drillsfull:OnChanged(function()
    if Options.drillsfull.Value and Options.drillsdelay.Value then
        Options.drillsdelay:SetValue(false)
    end
end)
drillsdelay:OnChanged(function()
    if Options.drillsdelay.Value and Options.drillsfull.Value then
        Options.drillsfull:SetValue(false)
    end
end)

-- // Settings
SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
InterfaceManager:SetFolder("untitleddrillgame")
SaveManager:SetFolder("untitleddrillgame/game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
w:SelectTab(1)
SaveManager:LoadAutoloadConfig()
warn("Loaded!")

-- // Support me pls OwO
local PATH, DIR, URL = "untitleddrillgame/support.txt", "untitleddrillgame", "https://www.roblox.com/games/136351251810923/Thailand-Forest-Voice-OpenBeta"
local state = isfile(PATH) and readfile(PATH) or "false"

if state ~= "true" then
    task.wait(math.random(600, 1200))

    w:Dialog{
        Title = "สนับสนุน",
        Content = "คุณต้องการสนับสนุนฉันไหม? (ลิงก์เกมจะถูกคัดลอกไปยังคลิปบอร์ดของคุณ)",
        Buttons = {
            {
                Title = "ยืนยัน",
                Callback = function()
                    setclipboard(URL)
                    if not isfolder(DIR) then makefolder(DIR) end
                    writefile(PATH, "true")
                end,
            },
            {
                Title = "ยกเลิก",
                Callback = function()
                    if not isfolder(DIR) then makefolder(DIR) end
                    writefile(PATH, "true")
                end,
            },
        },
    }
end
