-- 🔧 Replace with your actual Dev Product IDs
local PRODUCTS = { REVIVE = 0000000001, SKIP = 0000000002 }

local Players           = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local savedCheckpoints = {}

_G.SetCheckpoint = _G.SetCheckpoint or function(player, pos)
    savedCheckpoints[player.UserId] = pos
end

local function revive(player)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hrp and hum then
        local cp = savedCheckpoints[player.UserId]
        if cp then hrp.CFrame = CFrame.new(cp + Vector3.new(0,5,0)) end
        hum.Health = hum.MaxHealth
    end
end

local function skip(player)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 0, -100)
        _G.BRAIN_TrackProgress(player, 5)
    end
end

MarketplaceService.ProcessReceipt = function(receipt)
    local player = Players:GetPlayerByUserId(receipt.PlayerId)
    if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end

    if receipt.ProductId == PRODUCTS.REVIVE then revive(player) end
    if receipt.ProductId == PRODUCTS.SKIP   then skip(player)   end

    if _G.BRAIN_TrackPurchase then _G.BRAIN_TrackPurchase(player) end

    return Enum.ProductPurchaseDecision.PurchaseGranted
end
