-- Client-side script (LocalScript in StarterPlayerScripts)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local YeyEvents = ReplicatedStorage:WaitForChild("YeyPackageManager")
local InstallEvent = YeyEvents:WaitForChild("InstallPackage")
local PackageStatus = YeyEvents:WaitForChild("GetPackageStatus")

-- Command handler
local function handleCommand(input)
    if string.sub(input, 1, 4) == "yey " then
        local command = string.sub(input, 5)
        InstallEvent:FireServer(command)
        return true -- Command was handled
    end
    return false -- Not our command
end

-- Connect to chat events
local function onChatMessage(message, recipient, speaker)
    if speaker == player then
        handleCommand(message)
    end
end

game:GetService("Chat").Chatted:Connect(onChatMessage)

-- Handle installation responses
InstallEvent.OnClientEvent:Connect(function(success, message)
    if success then
        print("[Yey] " .. message)
    else
        warn("[Yey Error] " .. message)
    end
end)

-- Example: Check if a package is installed
local function isPackageInstalled(packageName)
    local status = PackageStatus:InvokeServer(packageName)
    return status.installed
end
