local g = getgenv()

-- default values
g.AutoFarm = false
g.AutoTalk = true

-- session variables
local fetchingPumpkins = false;

-- make sure game is loaded
repeat task.wait() until game:IsLoaded()

--
local RStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService") -- TweenService for smooth movement
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local RS = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")


local RouterClient = RStorage.ClientModules.Core.RouterClient.RouterClient
local minigame = RStorage.SharedModules.ContentPacks.Halloween2024.Minigames.TileSkipMinigameClient

local API = RStorage.API

local plr = Players.LocalPlayer

-- exploits
local getconstants = getconstants or debug.getconstants
local getgc = getgc or get_gc_objects or debug.getgc
local get_thread_context = get_thread_context or getthreadcontext or getidentity or syn.get_thread_identity
local get_thread_identity = get_thread_context
local set_thread_context = set_thread_context or setthreadcontext or setidentity or syn.set_thread_identity
local set_thread_identity = set_thread_context

-- ANTI AFK
plr.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

for i,v in pairs(getconnections(plr.Idled)) do
    v:Disable()
end

for i, v in next, getconnections(game:GetService("Players").LocalPlayer.Idled) do
    v:Disable();
end;

repeat task.wait() until plr.PlayerGui:FindFirstChild("PlayButton",true)

-- Translate Remotes retardly
for i, v in pairs(getupvalue(require(game.ReplicatedStorage.Fsys).load("RouterClient").init, 4)) do
    v.Name = i
end

-- Helper function to anchor/unanchor the player
function setPlayerAnchored(isAnchored)
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        plr.Character.HumanoidRootPart.Anchored = isAnchored
    end
end

-- setup
local Location = nil
for i, v in pairs(getgc()) do
    if type(v) == "function" then
        if getfenv(v).script == RStorage.ClientModules.Core.InteriorsM.InteriorsM then
            if table.find(getconstants(v), "LocationAPI/SetLocation") then
                Location = v
                break
            end
        end
    end
end
local function SetLocation(A, B, C)
    if Location then
        local O = get_thread_identity()
        set_thread_identity(2)
        local success, err = pcall(function()
            Location(A, B, C)
        end)
        set_thread_identity(O)
        if not success then
            warn("Failed to set location: " .. err)
        end
        return A, B, C
    else
        warn("Location function not set")
    end
end


-- Check Current State Positioning
function MainMap()
    if Workspace.Interiors:FindFirstChildWhichIsA("Model") then
        if string.find(Workspace.Interiors:FindFirstChildWhichIsA("Model").Name,"MainMap") then
            return Workspace.Interiors:FindFirstChildWhichIsA("Model").Name
        else
            return false
        end
    else
        return false
    end
end
function Neighborhood()
    if Workspace.Interiors:FindFirstChildWhichIsA("Model") then
        if string.find(Workspace.Interiors:FindFirstChildWhichIsA("Model").Name,"Neighborhood") then
            return Workspace.Interiors:FindFirstChildWhichIsA("Model").Name
        else
            return false
        end
    else
        return false
    end
end

-- Go to functions
function GoToMainMap()
    SetLocation("MainMap", "Neighborhood/MainDoor", {})
    while not MainMap() do
        task.wait()
    end
    if MainMap() then
        return true
    end
    return false
end
function GoToNeighborhood()
    SetLocation("Neighborhood", "MainDoor", {})
    while not Neighborhood() do
        task.wait()
    end
    if Neighborhood() then
        return true
    end
    return false
end
-- custom function
function getEventCircle()
    local success, result = pcall(function()
        return workspace.Interiors.Halloween2024Shop.TileSkip.JoinZone.Collider
    end)

    if success then
        return result
    else
        return false
    end
end

--

function GoToEvent()
    SetLocation("Halloween2024Shop", "MainDoor", {})
    while not getEventCircle() do
        task.wait()
    end
    if getEventCircle() then
        return true
    end
    return false
end

-- CUSTOM FUNCTIONS
local ground;
function buildInvisGround()
    if ground then
        ground:Destroy()
    end

    ground = Instance.new("Part", workspace)
    ground.Name = "TempGround"
    ground.Size = Vector3.new(10,.25,10)
    ground.Transparency = 0
    ground.Anchored = true
    ground.Position = plr.Character.PrimaryPart.Position - Vector3.new(0,4,0)

    local ground2 = ground

    -- Automatically clean up if needed
    task.delay(5, function()
        if ground2 then
            ground2:Destroy()
        end
    end)
end

-- Fetch Pumpkins
function CollectPumpkins()
    local char = plr.Character

    if workspace:FindFirstChild("Collectables") and char and char.PrimaryPart then
        while #workspace.Collectables:GetChildren() > 0 do
            task.wait(0.1)
            print("ran while loop")

            for i, pumpkin in pairs(workspace.Collectables:GetChildren()) do
                if firetouchinterest and pumpkin:FindFirstChild("Collider") then -- if not shitty executor
                    print("firetouchinterst("..pumpkin.Collider.Name..i..", "..char.PrimaryPart.Name..", true")
                    firetouchinterest(pumpkin.Collider, char.PrimaryPart, true)
                    task.wait(.25)
                    firetouchinterest(pumpkin.Collider, char.PrimaryPart, false)
                    task.wait(.1)
                else
                    print("broski's executor does not have firetouchinterest :'(")
                end
            end
        end
    end
end

function getMinigameTable()
    for name, func in pairs(require(minigame)) do
        if type(func) == "function" then
            if name == "create_rig_for_collectible" then
                return debug.getupvalues(func)[2]
            end
        end
    end
end

-- Check if the minigame is active
local function checkMinigame()
    print("checking Minigame..")
    local success, result = pcall(function()
        -- find something to check if the event is already on color of circle?
        if workspace.Interiors.TileSkipMinigame.Minigame.StartingPlatform.CheckpointCollider then
            return true
        end
    end)

    if success then
        print("Minigame is on?")
        return result
    else
        print("MINIGAME IS NOT ON")
        return false
    end
end

-- MAIN AutoFarm
function mainAutoFarm()
    if not getEventCircle() and not checkMinigame() and g.AutoFarm --[[and not miniGameLoaded]] then
        setPlayerAnchored(true)
        GoToEvent()
        setPlayerAnchored(false)
    end

    while g.AutoFarm and not fetchingPumpkins do
        print("AutoFarm is On!")
        if checkMinigame() then
            setPlayerAnchored(false)
            local args = {
                [1] = "tile_skip_minigame",
                [2] = "reached_goal"
            }
            print("Collecting Pumpkins in event? maybe wait to check if pumpkins load?")
            CollectPumpkins()
            print("Firing event!")
            game:GetService("ReplicatedStorage").API:FindFirstChild("MinigameAPI/MessageServer"):FireServer(unpack(args))
        else
            setPlayerAnchored(true)
            local circle = getEventCircle()

            if not circle then
                GoToEvent()
            end
            circle = getEventCircle()

            plr.Character.HumanoidRootPart.CFrame = CFrame.new(circle.Position + Vector3.new(0, 5, 0))
            task.wait(5)
        end
        task.wait(1)
    end
end

--
task.spawn(mainAutoFarm)

-- Setup UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Adopt Me Minigame by BoredScripterYT",
    LoadingTitle = "Adopt Me Minigame",
    LoadingSubtitle = "by BoredScripter",
    --[[ConfigurationSaving = {
        Enabled = false,
    },]]
})

local Tab = Window:CreateTab("Autofarm") -- Title

local Section = Tab:CreateSection("Autofarm Section")

local AutofarmToggle = Tab:CreateToggle({
    Name = "Autofarm",
    CurrentValue = g.AutoFarm,
    Flag = "AutofarmToggle", -- A flag is the identifier for the configuration file
    Callback = function(Value)
        g.AutoFarm = Value
        if Value then
            task.spawn(mainAutoFarm)
        end
    end,
})

local GetPumpkinBtn = Tab:CreateButton({
    Name = "Fetch Pumpkins",
    Callback = function()
        local char = plr.Character
        local startCF = char.PrimaryPart.CFrame

        fetchingPumpkins = true
        print("Fetching pumpkins started")

        CollectPumpkins()
        buildInvisGround()

        -- Check other world too
        if MainMap() then
            GoToNeighborhood()
            CollectPumpkins()

            GoToMainMap()
            char.PrimaryPart.CFrame = startCF
        elseif Neighborhood() then
            GoToMainMap()
            CollectPumpkins()

            GoToNeighborhood()
            char.PrimaryPart.CFrame = startCF
        elseif getEventCircle() then -- in event world
            GoToMainMap()
            CollectPumpkins()

            GoToNeighborhood()
            CollectPumpkins()

            GoToEvent()
            char.PrimaryPart.CFrame = startCF
        else
            GoToNeighborhood()
            CollectPumpkins()

            GoToMainMap()
            CollectPumpkins()
            char.PrimaryPart.CFrame = CFrame.new(workspace:WaitForChild("StaticMap"):WaitForChild("Campsite"):WaitForChild("CampsiteOrigin").Position + Vector3.new(0, 5, 0))
        end

        fetchingPumpkins = false
        print("Fetching pumpkins completed")
    end
})

loadstring(game:HttpGet("https://raw.githubusercontent.com/BoredScripter/AdoptMeHalloweenPublic/refs/heads/main/fuck.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
