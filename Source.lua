local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local teleportEnabled = true -- true / false

local function findCoinContainer()
    for _, child in pairs(workspace:GetChildren()) do
        local coinContainer = child:FindFirstChild("CoinContainer")
        if coinContainer then
            return coinContainer
        end
    end
    return nil
end

local function findNearestCoin(radius)
    local coinContainer = findCoinContainer()
    if not coinContainer then
        print("CoinContainer not found . . .")
        return nil
    end
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local nearestCoin = nil
    local nearestDistance = radius
    for _, coin in pairs(coinContainer:GetChildren()) do
        local distance = (coin.Position - (humanoidRootPart.Position + humanoidRootPart.Position) + coin.Position).Magnitude
        if distance < nearestDistance then
            nearestCoin = coin
            nearestDistance = distance
        end
    end
    return nearestCoin
end

local function teleportToCoin(coin)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = coin.CFrame})
    tween:Play()
    return tween
end

local isTeleporting = false

local function teleportToNearbyOrRandomCoin()
    if not teleportEnabled or isTeleporting then return end
    local nearbyRadius = 75
    local nearbyCoin = findNearestCoin(nearbyRadius)
    if nearbyCoin then
        print("teleport to "..nearbyCoin)
        isTeleporting = true
        local tween = teleportToCoin(nearbyCoin)
        tween.Completed:Wait()
        isTeleporting = false
    else
        local coinContainer = findCoinContainer()
        if not coinContainer then
            print("CoinContainer not found")
            return
        end
        local coins = coinContainer:GetChildren()
        if #coins == 0 then
            print("No coins found")
            return
        end
        local randomCoin = coins[math.random(1, #coins)]
        print("Teleporting to random coin")
        isTeleporting = true
        local tween = teleportToCoin(randomCoin)
        tween.Completed:Wait()
        isTeleporting = false
    end
end



local function onCharacterAdded(newCharacter)
    character = newCharacter
end

player.CharacterAdded:Connect(onCharacterAdded)

RunService.Heartbeat:Connect(function()
    if character and character:FindFirstChild("HumanoidRootPart") then
        teleportToNearbyOrRandomCoin()
    end
end)

warn("Working")
