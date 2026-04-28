
local Workspace = game:GetService("Workspace")

for i = 1, 20 do
    local p = Instance.new("Part")
    p.Size = Vector3.new(10,1,10)
    p.Position = Vector3.new(i*10, 5, 0)
    p.Anchored = true
    p.Parent = Workspace
end
