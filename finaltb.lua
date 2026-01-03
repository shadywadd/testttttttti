
--[[
getgenv().TBSettings = {
    LoadTB = true,
    SilentMode = false, 

    Keybinds = {
        HostHold          = Enum.KeyCode.B,
        ResetHostAndLock  = Enum.KeyCode.C,
        Toggle            = Enum.KeyCode.B, -- even while disabled, still listen to host shooting
        SilentMode        = Enum.KeyCode.P, -- switches silent mode on and off
    },

    Delays = {
        TBDelay     = nil, 
        TBDelay2    = nil, -- if a 2nd value, then it chooses random numb between val1 and val2
        HostDelay   = nil, -- complete pause (not just a skip) before continuing with tb logic
        HostDelay2  = nil,
    },

    Modes = {
        Tryouts = {
            Enabled      = true,
            KOCheck      = true,
            LOCK         = true, -- only shoot the player ure locked on until lock reset (lock reset can be auto)

            HoldKeybind  = false, -- make it equal a key, not "true". e.g HoldKeybind = Enum.UserInputType.MouseButton2
        },                        -- otherwise leave it false to stay with toggle logic. hold just adds extra check

        Generic = {
            Enabled     = false,
            KOCheck     = true,
            LOCK        = false,
            Whitelist   = true,

            HoldKeybind = nil,
        },
    },

    Settings = {
        KOCheck = {
            DontShootKOd   = true,
            DisableTB      = false,
            ResetLock      = true,
            ResetHostShot  = true,
        },
        
        SelfKOCheck = {
            DisableTB      = false,
            ResetLock      = true,
            ResetHostShot  = true,
        }
    }
}
-- help with settings: https://pastebin.com/raw/07dWyiyD

--]]


_G.Settings = getgenv().TBSettings

_G.RESETSETTINGS = function()
    _G.Settings = getgenv().TBSettings
end

if _G.Settings.LoadTB then


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local toggled = false
local connection = nil



local player = Players.LocalPlayer
local mouse = player:GetMouse()

local UserInputService = game:GetService("UserInputService")

local StarterGui = game:GetService("StarterGui")
local localPlayer = Players.LocalPlayer

local oldPrint = print
function print(text)
  if _G.Settings.SilentMode then return end
  oldPrint(text)
end

--[[
THESE ARE THE ONLY STUFF YOU SHOULD EDIT UNDER HERE

_G._G.Settings.SilentMode = false
_G.holdkeybind = Enum.KeyCode.B
_G.bruteforcekeybind = Enum.KeyCode.C
_G.disablekeybind = Enum.KeyCode.B
_G.modekeybind = Enum.KeyCode.P
--]]





local hostshot = false
local bruteforce = false -- we can make true to use a keybind to stop host

local canselecthost = false
local UserInputService = game:GetService("UserInputService")

local hosts = {}
function notify(title, text, time)
  if _G.Settings.SilentMode then return end
  StarterGui:SetCore("SendNotification", {
      Title = title,
      Text = text,
      Duration = time
  })
end



function connect(player3)
    notify("New Host", tostring(player3), 1)
end



local targetting
local targetmode = false
local disabled = false



local lastshot = 0
local KBHeld = true

local Whitelisted = {
    ["HalfDevilHalfGodWaad"] = true,
}

RunService.RenderStepped:Connect(function()
    --print("host:", host)

    if player.Character.BodyEffects["K.O"].Value == true then
        if _G.Settings.Settings.SelfKOCheck.DisableTB then
            disabled = true
        end
        if _G.Settings.Settings.SelfKOCheck.ResetLock then
            targetmode = false
        end
        if _G.Settings.Settings.SelfKOCheck.ResetHostShot then
            hostshot = false
        end
        return
    end

    if _G.Settings.Modes.Tryouts.Enabled then
        if #hosts > 0 and not hostshot and not disabled then
            for _, host in ipairs(hosts) do
                local plr = Players:FindFirstChild(host)
                --print(plr)
                local val = plr.Character.BodyEffects.GunFiring
                if val.Value == true then
                    hostshot = true
                    break
                end
            end
            if _G.Settings.Delays.HostDelay and hostshot then
                if _G.Settings.Delays.HostDelay2 then
                    task.wait(math.random(_G.Settings.Delays.HostDelay, _G.Settings.Delays.HostDelay2))
                else
                    task.wait(_G.Settings.Delays.HostDelay)
                end
            end
        end
    end

    local target = mouse.Target
    local parent = target.Parent
    local grandparentName = target.Parent.Parent.Parent and tostring(target.Parent.Parent.Parent)
    if target and target.Name == "Hitbox" then
        if Players[grandparentName].Character.BodyEffects["K.O"].Value == true then
            if _G.Settings.Modes.Tryouts.KOCheck or _G.Settings.Modes.Generic.KOCheck then
                if _G.Settings.Settings.KOCheck.DisableTB then
                    disabled = true
                end
                if _G.Settings.Settings.KOCheck.ResetLock then
                    targetmode = false
                end
                if _G.Settings.Settings.KOCheck.ResetHostShot then
                    hostshot = false
                end
                if _G.Settings.Settings.KOCheck.DontShootKOd then
                    return
                end
            end
        end

        if hostshot and KBHeld then

            if _G.Settings.Delays.TBDelay and hostshot then
                local cooldown = _G.Settings.Delays.TBDelay2 and math.random(_G.Settings.Delays.TBDelay, _G.Settings.Delays.TBDelay2) or _G.Settings.Delays.TBDelay
                if tick() - lastshot < cooldown then
                    return
                end
            end    

            if parent and parent.Name == "RootAttachment" and not targetmode or (targetmode and grandparentName == targetting) then
                --print("hi1")
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool and tool.Name ~= "[Knife]" then
                    tool:Activate()
                    lastshot = tick()
                    --print("activatedwotarget")

                    if _G.Settings.Modes.Tryouts.LOCK then
                        targetting = grandparentName
                        targetmode = true
                    end
                end
            end
        end

        if _G.Settings.Modes.Generic.Enabled then

            if KBHeld and not disabled then

                if _G.Settings.Delays.TBDelay then
                    local cooldown = _G.Settings.Delays.TBDelay2 and math.random(_G.Settings.Delays.TBDelay, _G.Settings.Delays.TBDelay2) or _G.Settings.Delays.TBDelay
                    if tick() - lastshot < cooldown then
                        return
                    end
                end
                if _G.Settings.Modes.Generic.Whitelist and not Whitelisted[grandparentName] then return end

                if parent and parent.Name == "RootAttachment" and not targetmode or (targetmode and grandparentName == targetting) then
                    --print("hi1")
                    local tool = player.Character:FindFirstChildOfClass("Tool")
                    if tool and tool.Name ~= "[Knife]" then
                        tool:Activate()
                        lastshot = tick()
                        --print("activatedwotarget")

                        if _G.Settings.Modes.Generic.LOCK then
                            targetting = grandparentName
                            targetmode = true
                        end
                    end
                end
            end
        end
    end
end)


function isHost(name)
    for _, host in ipairs(hosts) do
        if host == name then
            return true
        end
    end
    return false
end
function removeHost(name)
    for i, host in ipairs(hosts) do
        if host == name then
            table.remove(hosts, i)
            return true
        end
    end
    return false
end

function addHost(name)
    table.insert(hosts, name)
end

local globalupdate, globalupdate2
local refreshList, refreshList2

local function createWhitelistTool()
    local tool = Instance.new("Tool")
    tool.Name = "HostWhitelist"
    tool.RequiresHandle = false

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "roaxe"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
    screenGui.Enabled = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 350)
    frame.Position = UDim2.new(0, 20, 0.5, -175)
    frame.BackgroundTransparency = 0.2
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.Parent = screenGui
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, -10, 0, 40)
    topBar.Position = UDim2.new(0, 5, 0, 5)
    topBar.BackgroundTransparency = 1
    topBar.Parent = frame

    local uiLayout = Instance.new("UIListLayout")
    uiLayout.FillDirection = Enum.FillDirection.Horizontal
    uiLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    uiLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiLayout.Parent = topBar

    local minusBtn = Instance.new("TextButton")
    minusBtn.Text = "-"
    minusBtn.Font = Enum.Font.SourceSansBold
    minusBtn.TextSize = 28
    minusBtn.Size = UDim2.new(0, 40, 0, 30)
    minusBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    minusBtn.TextColor3 = Color3.new(1, 1, 1)
    minusBtn.Parent = topBar

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -55)
    scroll.Position = UDim2.new(0, 5, 0, 45)
    scroll.CanvasSize = UDim2.new(0, 0, 2, 0)
    scroll.ScrollBarThickness = 6
    scroll.BackgroundTransparency = 1
    scroll.Parent = frame

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scroll

    refreshList = function()
        for _, child in pairs(scroll:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("Frame") then
                child:Destroy()
            end
        end
        globalupdate = function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer then
                    local button = Instance.new("TextButton")
                    button.Size = UDim2.new(1, -10, 0, 40)
                    button.BackgroundColor3 = isHost(player.Name) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                    button.TextColor3 = Color3.new(1, 1, 1)
                    button.AutoButtonColor = false
                    button.Parent = scroll
                    button.Text = ""

                    local avatar = Instance.new("ImageLabel")
                    avatar.Size = UDim2.new(0, 36, 0, 36)
                    avatar.Position = UDim2.new(0, 5, 0, 2)
                    avatar.BackgroundTransparency = 1
                    avatar.Parent = button
                    local success, thumbnail = pcall(function()
                        return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                    end)
                    if success and thumbnail then
                        avatar.Image = thumbnail
                    else
                        avatar.Image = ""
                    end

                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, -50, 1, 0)
                    label.Position = UDim2.new(0, 46, 0, 0)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.new(1,1,1)
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Font = Enum.Font.SourceSansBold
                    label.TextSize = 18
                    label.Text = string.format("%s (%s)", player.DisplayName, player.Name)
                    label.Parent = button

                    button.MouseButton1Click:Connect(function()
                        if isHost(player.Name) then
                            removeHost(player.Name)
                            button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                        else
                            addHost(player.Name)
                            button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                        end
                    end)
                end
            end
        end
        globalupdate()
    end

    refreshList()

    Players.PlayerAdded:Connect(refreshList)
    Players.PlayerRemoving:Connect(refreshList)

    tool.Equipped:Connect(function()
        screenGui.Enabled = true
        --notify("bot", "whitelist a player by making them green with the tool", 5)
        --notify("bot", "increase/decrease the amount of stomps per frame. higher = louder but can also spike your ping if you stay over them for too long", 7)
    end)

    tool.Unequipped:Connect(function()
        screenGui.Enabled = false
    end)
    --[[
    minusBtn.MouseButton1Click:Connect(function()
        local newVal = tonumber(stompCountBox.Text) or stompCount
        newVal = math.max(1, newVal - 1)
        stompCount = newVal
        stompCountBox.Text = tostring(stompCount)
    end)

    plusBtn.MouseButton1Click:Connect(function()
        local newVal = tonumber(stompCountBox.Text) or stompCount
        newVal = math.min(100, newVal + 1)
        stompCount = newVal
        stompCountBox.Text = tostring(stompCount)
    end)

    stompCountBox.FocusLost:Connect(function(enterPressed)
        local val = tonumber(stompCountBox.Text)
        if val == nil or val < 1 then
            stompCountBox.Text = tostring(stompCount)
        else
            stompCount = math.clamp(math.floor(val), 1, 100)
            stompCountBox.Text = tostring(stompCount)
        end
    end)
    --]]

    tool.Parent = localPlayer:WaitForChild("Backpack")
end

local function createWhitelistTool2()
    local tool = Instance.new("Tool")
    tool.Name = "TBWhitelist"
    tool.RequiresHandle = false

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "roaxe3"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
    screenGui.Enabled = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 350)
    frame.Position = UDim2.new(0, 20, 0.5, -175)
    frame.BackgroundTransparency = 0.2
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.Parent = screenGui
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, -10, 0, 40)
    topBar.Position = UDim2.new(0, 5, 0, 5)
    topBar.BackgroundTransparency = 1
    topBar.Parent = frame

    local uiLayout = Instance.new("UIListLayout")
    uiLayout.FillDirection = Enum.FillDirection.Horizontal
    uiLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    uiLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiLayout.Parent = topBar

    local minusBtn = Instance.new("TextButton")
    minusBtn.Text = "-"
    minusBtn.Font = Enum.Font.SourceSansBold
    minusBtn.TextSize = 28
    minusBtn.Size = UDim2.new(0, 40, 0, 30)
    minusBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    minusBtn.TextColor3 = Color3.new(1, 1, 1)
    minusBtn.Parent = topBar

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -55)
    scroll.Position = UDim2.new(0, 5, 0, 45)
    scroll.CanvasSize = UDim2.new(0, 0, 2, 0)
    scroll.ScrollBarThickness = 6
    scroll.BackgroundTransparency = 1
    scroll.Parent = frame

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scroll

    refreshList2 = function()
        for _, child in pairs(scroll:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("Frame") then
                child:Destroy()
            end
        end
        globalupdate2 = function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer then
                    local button = Instance.new("TextButton")
                    button.Size = UDim2.new(1, -10, 0, 40)
                    button.BackgroundColor3 = Whitelisted[player.Name] == true and  Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                    button.TextColor3 = Color3.new(1, 1, 1)
                    button.AutoButtonColor = false
                    button.Parent = scroll
                    button.Text = ""

                    local avatar = Instance.new("ImageLabel")
                    avatar.Size = UDim2.new(0, 36, 0, 36)
                    avatar.Position = UDim2.new(0, 5, 0, 2)
                    avatar.BackgroundTransparency = 1
                    avatar.Parent = button
                    local success, thumbnail = pcall(function()
                        return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                    end)
                    if success and thumbnail then
                        avatar.Image = thumbnail
                    else
                        avatar.Image = ""
                    end

                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, -50, 1, 0)
                    label.Position = UDim2.new(0, 46, 0, 0)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.new(1,1,1)
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Font = Enum.Font.SourceSansBold
                    label.TextSize = 18
                    label.Text = string.format("%s (%s)", player.DisplayName, player.Name)
                    label.Parent = button

                    button.MouseButton1Click:Connect(function()
                        if Whitelisted[player.Name] == true then
                            Whitelisted[player.Name] = nil
                            print(player.Name .. "no longer whitelisted")
                            button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                        else
                            Whitelisted[player.Name] = true
                            print(player.Name .. "is now whitelisted")
                            button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                        end
                    end)
                end
            end
        end
        globalupdate2()
    end

    refreshList2()

    Players.PlayerAdded:Connect(refreshList2)
    Players.PlayerRemoving:Connect(refreshList2)

    tool.Equipped:Connect(function()
        screenGui.Enabled = true
        --notify("bot", "whitelist a player by making them green with the tool", 5)
        --notify("bot", "increase/decrease the amount of stomps per frame. higher = louder but can also spike your ping if you stay over them for too long", 7)
    end)

    tool.Unequipped:Connect(function()
        screenGui.Enabled = false
    end)
    --[[
    minusBtn.MouseButton1Click:Connect(function()
        local newVal = tonumber(stompCountBox.Text) or stompCount
        newVal = math.max(1, newVal - 1)
        stompCount = newVal
        stompCountBox.Text = tostring(stompCount)
    end)

    plusBtn.MouseButton1Click:Connect(function()
        local newVal = tonumber(stompCountBox.Text) or stompCount
        newVal = math.min(100, newVal + 1)
        stompCount = newVal
        stompCountBox.Text = tostring(stompCount)
    end)

    stompCountBox.FocusLost:Connect(function(enterPressed)
        local val = tonumber(stompCountBox.Text)
        if val == nil or val < 1 then
            stompCountBox.Text = tostring(stompCount)
        else
            stompCount = math.clamp(math.floor(val), 1, 100)
            stompCountBox.Text = tostring(stompCount)
        end
    end)
    --]]

    tool.Parent = localPlayer:WaitForChild("Backpack")
end


localPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    createWhitelistTool()
    createWhitelistTool2()
end)

createWhitelistTool()
createWhitelistTool2()



if _G.Settings.Modes.Tryouts.HoldKeybind or _G.Settings.Modes.Generic.HoldKeybind then
    KBHeld = false
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
    local h1 = _G.Settings.Modes.Tryouts.HoldKeybind
    local h2 = _G.Settings.Modes.Generic.HoldKeybind
    
    if h1 or h2 then
        if input.KeyCode == h1 or input.UserInputType == h1 or input.KeyCode == h2 or input.UserInputType == h2 then
            KBHeld = true
            return
        end
    end
    
	if input.UserInputType == Enum.UserInputType.MouseButton1 and canselecthost then
		local target = mouse.Target
        local x = target.Parent.Parent.Parent
        if x then
            table.insert(hosts, tostring(x))
            refreshList()
            connect(host)
            return
        end
	end


	if input.KeyCode == _G.Settings.Keybinds.HostHold then
		canselecthost = true
        return
	end


    if input.KeyCode == _G.Settings.Keybinds.ResetHosts then
        hostshot = false
        notify("Reset Host", "we resetted the host doofus", 2)
        return
	end

    if input.KeyCode == _G.Settings.Keybinds.Toggle then
        hostshot = false
        disabled = not disabled
        if disabled then
            notify("TB STATUS", "COMPLETELY DISABLED AND HOSTS HAVE BEEN RESET", 2)
            hosts = {}
            refreshList()
        else
            notify("TB STATUS", "enabled - waiting for hostshot", 2)
        end
        return
	end    

	if input.KeyCode == _G.Settings.Keybinds.SilentMode then
        _G.Settings.SilentMode = not _G.Settings.SilentMode
        notify("SILENT MODE STATUS", tostring(_G.Settings.SilentMode), 1)
        return
	end


end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local h1 = _G.Settings.Modes.Tryouts.HoldKeybind
    local h2 = _G.Settings.Modes.Generic.HoldKeybind
    
    if h1 or h2 then
        if input.KeyCode == h1 or input.UserInputType == h1 or input.KeyCode == h2 or input.UserInputType == h2 then
            KBHeld = true
            return
        end
    end

    if input.KeyCode == _G.Settings.Keybinds.HostHold then
		canselecthost = false
        return
	end

end)

warn("macrox didnt load")



notify('EXECTUED VERSION PROGAMING', 'I MADE THIS PUSSY', 1)
end
