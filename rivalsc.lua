local view = game:GetService("Players").LocalPlayer.PlayerScripts.Assets.ViewModels


_G.changeskin = function(skintochangeto, currentskin)
    local a
    local b
    local currentskin1
    print(currentskin)
    print(skintochangeto)

    if not currentskin then
        for _, instance in ipairs(workspace:GetChildren()) do
            if instance:IsA("Model") and instance:FindFirstChild("Body") and instance:FindFirstChild("Bolt") then
                print(instance.Name)
                currentskin = tostring(instance)
            end
        end
    end
    if not currentskin then warn("COULD NOT FIND CURRENT SKIN") return end
    for _, instance in ipairs(view:GetDescendants()) do
        if instance.Name == currentskin or instance.Name == skintochangeto then
            if instance.Name == currentskin then
                a = instance
            end
            if instance.Name == skintochangeto then
                b = instance
            end
        end
    end

    if a and b then
        print(a, b)

        local c = #a:GetChildren()
        if c ~= 0 then
            print(c)
            a:ClearAllChildren()

            for _, d in pairs(b:GetChildren()) do
                local new = d:Clone()
                new.Parent = a
            end
        end
        local z = #a:GetChildren()
        print(z)
    end
end

warn('reset')




