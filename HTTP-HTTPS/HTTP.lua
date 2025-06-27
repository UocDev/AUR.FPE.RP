-- Server-side script (Script in ServerScriptService)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")

-- Create remote events/functions
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
local AUR_REPO_URL = "https://api.github.com/repos/UocDev/AUR.FPE.RP/contents/"
local PACKAGE_PATH = "OOBE/RNS/"
local HTTPS_CALLBACK_URL = "https://your-callback-service.com/install" -- Replace with your HTTPS callback
local API_KEY = "your-secure-api-key" -- Should be stored securely

-- Package cache and security
local installedPackages = {}
local rateLimits = {}
local SECURITY_GROUP_ID = 123456 -- Your security group ID
local MIN_RANK = 10 -- Minimum rank to install packages

-- Enable HTTP requests
HttpService.HttpEnabled = true

-- Secure HTTP request function with error handling
local function secureHttpGet(url)
    local success, response = pcall(function()
        return HttpService:GetAsync(url, true, {
            ["Authorization"] = "token " .. API_KEY,
            ["User-Agent"] = "RobloxAURPackageManager"
        })
    end)
    
    if not success then
        warn("[HTTP Error] " .. response)
        return nil
    end
    return response
end

-- Secure HTTPS POST for callbacks
local function secureHttpsPost(url, data)
    local success, response = pcall(function()
        return HttpService:PostAsync(url, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson, false, {
            ["Authorization"] = "Bearer " .. API_KEY,
            ["User-Agent"] = "RobloxAURPackageManager"
        })
    end)
    
    if not success then
        warn("[HTTPS Callback Error] " .. response)
        return false
    end
    return true
end

-- Validate package names
local function isValidPackageName(name)
    return string.match(name, "^[%w%-_]+$") ~= nil and #name <= 64
end

-- Rate limiting
local function checkRateLimit(player)
    local now = os.time()
    rateLimits[player.UserId] = rateLimits[player.UserId] or {count = 0, time = now}
    
    if rateLimits[player.UserId].time ~= now then
        rateLimits[player.UserId] = {count = 0, time = now}
    end
    
    rateLimits[player.UserId].count = rateLimits[player.UserId].count + 1
    return rateLimits[player.UserId].count <= 5 -- 5 requests per second
end

-- Fetch package info from GitHub
local function getPackageInfo(packageName)
    local url = AUR_REPO_URL .. PACKAGE_PATH .. packageName .. "/package.json"
    local response = secureHttpGet(url)
    
    if not response then return nil end
    
    local success, packageInfo = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    
    if not success or not packageInfo.name then
        warn("Invalid package JSON for " .. packageName)
        return nil
    end
    
    -- Validate package structure
    if packageInfo.name ~= packageName then
        warn("Package name mismatch: " .. packageInfo.name .. " vs " .. packageName)
        return nil
    end
    
    return {
        name = packageInfo.name,
        version = packageInfo.version or "1.0.0",
        dependencies = packageInfo.dependencies or {},
        description = packageInfo.description or "No description provided",
        mainModule = packageInfo.mainModule or "Main",
        assets = packageInfo.assets or {}
    }
end

-- Download and install package assets
local function installPackageAssets(packageName, packageInfo)
    -- Create package folder in ServerStorage
    local packageFolder = Instance.new("Folder")
    packageFolder.Name = packageName
    packageFolder.Parent = ServerStorage
    
    -- Download main module
    local moduleUrl = AUR_REPO_URL .. PACKAGE_PATH .. packageName .. "/" .. packageInfo.mainModule .. ".lua"
    local moduleResponse = secureHttpGet(moduleUrl)
    
    if moduleResponse then
        local moduleScript = Instance.new("ModuleScript")
        moduleScript.Name = packageInfo.mainModule
        moduleScript.Source = moduleResponse
        moduleScript.Parent = packageFolder
    end
    
    -- Download additional assets
    for _, asset in ipairs(packageInfo.assets) do
        local assetUrl = AUR_REPO_URL .. PACKAGE_PATH .. packageName .. "/assets/" .. asset
        local assetResponse = secureHttpGet(assetUrl)
        
        if assetResponse then
            -- This is simplified - you'd need proper asset type detection
            local assetScript = Instance.new("Script")
            assetScript.Name = asset
            assetScript.Source = assetResponse
            assetScript.Parent = packageFolder
        end
    end
    
    return packageFolder
end

-- Install package with dependencies
local function installPackage(packageName, installer)
    -- Rate limiting check
    if not checkRateLimit(installer) then
        return false, "Rate limit exceeded. Please wait a moment."
    end
    
    -- Security check
    if not isValidPackageName(packageName) then
        return false, "Invalid package name"
    end
    
    -- Check if already installed
    if installedPackages[packageName] then
        return false, "Package already installed"
    end
    
    -- Get package info from GitHub
    local packageInfo = getPackageInfo(packageName)
    if not packageInfo then
        return false, "Package not found in repository"
    end
    
    -- Install dependencies first
    for depName, depVersion in pairs(packageInfo.dependencies) do
        local success, err = installPackage(depName, installer)
        if not success then
            return false, "Dependency failed: " .. depName .. " - " .. err
        end
    end
    
    -- Install the package
    local packageFolder = installPackageAssets(packageName, packageInfo)
    
    -- Record installation
    installedPackages[packageName] = {
        version = packageInfo.version,
        installedBy = installer.Name,
        installTime = os.time(),
        folder = packageFolder
    }
    
    -- Send HTTPS callback
    local callbackData = {
        package = packageName,
        version = packageInfo.version,
        player = installer.Name,
        userId = installer.UserId,
        serverId = game.JobId,
        timestamp = os.time()
    }
    
    secureHttpsPost(HTTPS_CALLBACK_URL, callbackData)
    
    print(string.format("[Yey] Installed %s v%s for %s", packageName, packageInfo.version, installer.Name))
    
    return true, "Successfully installed " .. packageName
end

-- Handle installation requests
InstallEvent.OnServerEvent:Connect(function(player, command)
    if string.sub(command, 1, 8) == "install " then
        local parts = string.split(command, " ")
        if #parts >= 4 and parts[2] == "AUR" and parts[3] == "OOBE/RNS" then
            local packageName = parts[4]
            
            -- Verify permissions
            if player:GetRankInGroup(SECURITY_GROUP_ID) < MIN_RANK then
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

print("Yey Package Manager with HTTP/HTTPS support initialized")
