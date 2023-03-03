local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

function getEmptyFarm()
    for i, Farm in pairs(workspace.Farms:GetChildren()) do
        if Farm.Owner.Value == nil then
            return Farm
        end
    end
end

function getFarm()
    for i, Farm in pairs(workspace.Farms:GetChildren()) do
        if Farm.Owner.Value == LocalPlayer then
            return Farm
        end
    end
    return nil
end

function teleportToFarm(Farm)
    local Door = Farm.Door
    Character.HumanoidRootPart.CFrame = Door.CFrame + Door.CFrame.LookVector * 120
end

function assignFarm()
    local Farm = getFarm()
    if not Farm then 
        Farm = getEmptyFarm()

        firetouchinterest(Character.HumanoidRootPart, Farm.Door, 0)
    end
    
    teleportToFarm(Farm)
    
    return Farm
end

local Farm = assignFarm()
local DiamondsFolder = Farm.Diamonds

for i, Diamond in pairs(DiamondsFolder:GetChildren()) do
    while Diamond.Parent == DiamondsFolder do
        task.wait(0.1)
        Diamond.CFrame = Character.LowerTorso.CFrame
    end
end


DiamondsFolder.ChildAdded:Connect(function(Diamond)
    while Diamond.Parent == DiamondsFolder do
        task.wait(0.1)
        Diamond.CFrame = Character.LowerTorso.CFrame
    end
end)
