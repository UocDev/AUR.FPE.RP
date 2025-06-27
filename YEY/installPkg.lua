-- Package Manager Script for AUR OOBE/RNS
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Create remote events/functions for communication
local YeyEvents = Instance.new("Folder")
YeyEvents.Name = "YeyPackageManager"
YeyEvents.Parent = ReplicatedStorage

local InstallEvent = Instance.new("RemoteEvent")
InstallEvent.Name = "InstallPackage"
InstallEvent.Parent = YeyEvents

local PackageStatus = Instance.new("RemoteFunction")
PackageStatus.Name = "GetPackageStatus"
PackageStatus.Parent = YeyEvents

-- Configuration
local AUR_REPO_URL = "https://github.com/UocDev/AUR.FPE.RP"
local PACKAGE_PATH = "OOBE/RNS/" -- Subpath for OOBE/RNS packages

-- Package cache
local installedPackages = {}

-- Function to validate package names
local function isValidPackageName(name)
    return string.match(name, "^[%w%-_]+$") ~= nil
end

-- Function to simulate downloading package info from AUR
local function getPackageInfo(packageName)
    -- In a real implementation, this would make an HTTP request to the repository
    -- For this example, we'll simulate some packages
    
    local mockPackages = {
        ["RNS-Core"] = {
            version = "1.2.0",
            dependencies = {},
            description = "Roblox Notification System Core"
        },
        ["RNS-UI"] = {
            version = "1.1.3",
            dependencies = {"RNS-Core"},
            description = "UI Components for RNS"
        },
        ["OOBE-Tutorial"] = {
            version = "2.0.1",
            dependencies = {},
            description = "Out-of-box experience tutorial system"
        }
    }
    
    return mockPackages[packageName]
end

-- Function to install a package and its dependencies
local function installPackage(packageName, installer)
    if not isValidPackageName(packageName) then
        return false, "Invalid package name"
    end
    
    -- Check if already installed
    if installedPackages[packageName] then
        return false, "Package already installed"
    end
    
    -- Get package info
    local packageInfo = getPackageInfo(packageName)
    if not packageInfo then
        return false, "Package not found in repository"
    end
    
    -- Install dependencies first
    for _, dep in ipairs(packageInfo.dependencies) do
        local success, err = installPackage(dep, installer)
        if not success then
            return false, "Dependency failed: " .. dep .. " - " .. err
        end
    end
    
    -- Simulate package installation
    -- In a real implementation, this would download and install the actual package
    installedPackages[packageName] = {
        version = packageInfo.version,
        installedBy = installer.Name,
        installTime = os.time()
    }
    
    print(string.format("[Yey] Installed %s v%s for %s", packageName, packageInfo.version, installer.Name))
    
    return true, "Successfully installed " .. packageName
end

-- Handle installation requests
InstallEvent.OnServerEvent:Connect(function(player, command)
    if string.sub(command, 1, 8) == "install " then
        local parts = string.split(command, " ")
        if #parts >= 4 and parts[2] == "AUR" and parts[3] == "OOBE/RNS" then
            local packageName = parts[4]
            
            -- Verify player has permission (you might want to add more checks)
            if player:GetRankInGroup(123456) < 10 then -- Example group ID and rank check
                player:Kick("Unauthorized package installation attempt")
                return
            end
            
            local success, message = installPackage(packageName, player)
            InstallEvent:FireClient(player, success, message)
        else
            InstallEvent:FireClient(player, false, "Invalid command format. Use: yey install AUR OOBE/RNS <package>")
        end
    end
end)

-- Handle package status requests
PackageStatus.OnServerInvoke = function(player, packageName)
    if installedPackages[packageName] then
        return {
            installed = true,
            version = installedPackages[packageName].version,
            installedBy = installedPackages[packageName].installedBy
        }
    else
        return {installed = false}
    end
end

print("Yey Package Manager initialized")
