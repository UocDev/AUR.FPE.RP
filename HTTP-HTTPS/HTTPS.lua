-- Client-side script (LocalScript in StarterPlayerScripts)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local YeyEvents = ReplicatedStorage:WaitForChild("YeyPackageManager")
local InstallEvent = YeyEvents:WaitForChild("InstallPackage")
local PackageStatus = YeyEvents:WaitForChild("GetPackageStatus")

-- Enhanced command handler with feedback
local function handleCommand(input)
    if string.sub(input, 1, 4) == "yey " then
        local command = string.sub(input, 5)
        
        -- Basic client-side validation
        if string.sub(command, 1, 8) == "install " then
            local parts = string.split(command, " ")
            if #parts < 4 or parts[2] ~= "AUR" or parts[3] ~= "OOBE/RNS" then
                warn("[Yey] Invalid command format. Use: yey install AUR OOBE/RNS <package>")
                return true
            end
            
            local packageName = parts[4]
            if not packageName or #packageName == 0 then
                warn("[Yey] Please specify a package name")
                return true
            end
        end
        
        -- Send to server
        InstallEvent:FireServer(command)
        return true
    end
    return false
end

-- Enhanced chat handler
local function onChatMessage(message, recipient, speaker)
    if speaker == player then
        handleCommand(message)
    end
end

game:GetService("Chat").Chatted:Connect(onChatMessage)

-- Improved installation feedback
InstallEvent.OnClientEvent:Connect(function(success, message)
    if success then
        print("[Yey] " .. message)
        
        -- Show success notification
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Package Installed",
            Text = message,
            Icon = "rbxassetid://4483345998",
            Duration = 5
        })
    else
        warn("[Yey Error] " .. message)
        
        -- Show error notification
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Installation Failed",
            Text = message,
            Icon = "rbxassetid://4483345998",
            Duration = 5
        })
    end
end)

-- Public API for other scripts to check packages
local YeyAPI = {}

function YeyAPI.isPackageInstalled(packageName)
    local status = PackageStatus:InvokeServer(packageName)
    return status.installed
end

function YeyAPI.getPackageVersion(packageName)
    local status = PackageStatus:InvokeServer(packageName)
    return status.installed and status.version or nil
end

-- Expose the API
_G.YeyPackageManager = YeyAPI
