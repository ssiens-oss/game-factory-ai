local Config = require(game.ReplicatedStorage.Config)
local Players = game:GetService("Players")

local function part(size, pos, color, name)
    local p = Instance.new("Part")
    p.Size, p.Position, p.Anchored = size, pos, true
    p.Color = color or Color3.fromRGB(220,220,220)
    p.Name  = name or "Block"
    p.Parent = workspace
    return p
end

local function killBrick(pos)
    local h = part(Vector3.new(10,1,10), pos, Color3.fromRGB(255,50,50), "KillBrick")
    h.Touched:Connect(function(hit)
        local hum = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end)
end

local function checkpoint(pos, i)
    local c = part(Vector3.new(10,2,10), pos, Color3.fromRGB(0,200,100), "Checkpoint")
    c.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if player and _G.SetCheckpoint then _G.SetCheckpoint(player, pos) end
    end)
end

local function generateWorld()
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("BasePart") or v:IsA("Model") then v:Destroy() end
    end

    -- spawn pad
    part(Vector3.new(20,1,20), Vector3.new(0,4,0), Color3.fromRGB(0,255,100), "SpawnPad")

    local pos = Vector3.new(0, 5, 0)
    local gap = Config.PlatformGap

    for i = 1, Config.Length do
        pos = pos + Vector3.new(0, math.random(0,2) * Config.Difficulty, gap * 10)

        if math.random() < Config.HazardChance then
            killBrick(pos + Vector3.new(0, 1, 0))
        else
            part(Vector3.new(10,1,10), pos)
        end

        -- checkpoint every N segments
        if i % Config.CheckpointSpacing == 0 then
            checkpoint(pos + Vector3.new(0, 3, 0), i)
        end
    end

    -- win zone
    local winPos = pos + Vector3.new(0, 5, 20)
    local w = part(Vector3.new(15,5,15), winPos, Color3.fromRGB(255,215,0), "WinZone")
    w.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if player then
            print("🏆 WIN:", player.Name)
            player:LoadCharacter()
        end
    end)
end

generateWorld()

-- Hot-reload loop (picks up Config changes from Python RL)
while true do
    task.wait(10)
    generateWorld()
end
