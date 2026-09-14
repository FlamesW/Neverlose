-- // @Neverlose Assetloader
if (isfolder and isfolder("Neverlose")) then
    return
end

local Neverlose_Loader = (function()
    local cloneref: (Instance) -> Instance = (cloneref or clonereference or function(instance: Instance)
        return instance
    end)

    local Game: DataModel = game;
    local Tween_Service = cloneref(Game:GetService("TweenService"))

    local CoreGui = (gethui and gethui()) or (get_hidden_gui and get_hidden_gui()) or Game:FindFirstChild("CoreGui")
    local Protect_Gui = protect_gui or protectgui or (syn and syn.protect_gui) or function(s) return s end

    local Main_Color = Color3.fromRGB(8, 8, 13)
    local Stroke_Color = Color3.fromRGB(45, 48, 58)
    local Track_Color = Color3.fromRGB(30, 29, 36)
    local Text_Color = Color3.fromRGB(255, 255, 255)
    local Muted_Color = Color3.fromRGB(186, 186, 186)
    local Accent_Color = Color3.fromRGB(78, 127, 252)

    local function Play(Instance, Info, Props)
        local Tween = Tween_Service:Create(Instance, Info, Props)
        Tween:Play()
        return Tween
    end

    local function Random_Name()
        return string.format("LA_%d_%d", math.random(1e6), math.random(1e6))
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = Random_Name()
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.DisplayOrder = 9999

    Protect_Gui(ScreenGui)
    ScreenGui.Parent = CoreGui

    local Root = Instance.new("Frame")
    local Root_Corner = Instance.new("UICorner")
    local Root_Stroke = Instance.new("UIStroke")

    Root.Name = Random_Name()
    Root.Parent = ScreenGui
    Root.AnchorPoint = Vector2.new(0.5, 0.5)
    Root.BackgroundColor3 = Main_Color
    Root.BackgroundTransparency = 0.055
    Root.BorderSizePixel = 0
    Root.Position = UDim2.fromScale(0.5, 0.5)
    Root.Size = UDim2.fromOffset(340, 110)
    Root.ZIndex = 999

    Root_Corner.CornerRadius = UDim.new(0, 12)
    Root_Corner.Parent = Root

    Root_Stroke.Transparency = 0.650
    Root_Stroke.Color = Stroke_Color
    Root_Stroke.Parent = Root

    local function Make_Shadow(Parent)
        local Layers = {}
        for _, cfg in ipairs({
            { Thickness = 6, Transparency = 0.94 },
            { Thickness = 5, Transparency = 0.93 },
            { Thickness = 4, Transparency = 0.92 },
            { Thickness = 3, Transparency = 0.91 },
        }) do
            local S = Instance.new("UIStroke")
            S.Thickness = cfg.Thickness
            S.Transparency = 1
            S.Color = Color3.new(0, 0, 0)
            S.Parent = Parent
            table.insert(Layers, S)
        end

        return {
            Render = function(_, On)
                for _, S in ipairs(Layers) do
                    Play(S, TweenInfo.new(0.175), {
                        Transparency = On and (1 - (S.Thickness / 40)) or 1,
                    })
                end
            end,
        }
    end

    local Shadow = Make_Shadow(Root)
    Shadow:Render(true)

    local Title_Icon = Instance.new("TextLabel")
    Title_Icon.Name = Random_Name()
    Title_Icon.Parent = Root
    Title_Icon.BackgroundTransparency = 1
    Title_Icon.Position = UDim2.fromOffset(18, 14)
    Title_Icon.Size = UDim2.fromOffset(20, 20)
    Title_Icon.Font = Enum.Font.GothamBold
    Title_Icon.Text = "⬇"
    Title_Icon.TextColor3 = Accent_Color
    Title_Icon.TextSize = 18
    Title_Icon.TextTransparency = 0.05
    Title_Icon.ZIndex = 1000

    local Title = Instance.new("TextLabel")
    Title.Name = Random_Name()
    Title.Parent = Root
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.fromOffset(46, 13)
    Title.Size = UDim2.new(1, -60, 0, 22)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Neverlose Loader"
    Title.TextColor3 = Text_Color
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 1000

    local Title_Dot = Instance.new("Frame")
    local Title_Dot_Corner = Instance.new("UICorner")

    Title_Dot.Name = Random_Name()
    Title_Dot.Parent = Root
    Title_Dot.AnchorPoint = Vector2.new(1, 0.5)
    Title_Dot.BackgroundColor3 = Accent_Color
    Title_Dot.BorderSizePixel = 0
    Title_Dot.Position = UDim2.new(1, -18, 0, 24)
    Title_Dot.Size = UDim2.fromOffset(6, 6)
    Title_Dot.ZIndex = 1000

    Title_Dot_Corner.CornerRadius = UDim.new(1, 0)
    Title_Dot_Corner.Parent = Title_Dot

    local Status = Instance.new("TextLabel")
    Status.Name = Random_Name()
    Status.Parent = Root
    Status.BackgroundTransparency = 1
    Status.Position = UDim2.fromOffset(18, 40)
    Status.Size = UDim2.new(1, -36, 0, 16)
    Status.Font = Enum.Font.GothamMedium
    Status.Text = "Preparing..."
    Status.TextColor3 = Muted_Color
    Status.TextSize = 12
    Status.TextTransparency = 0.35
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.ZIndex = 1000

    local Track = Instance.new("Frame")
    local Track_Corner = Instance.new("UICorner")

    Track.Name = Random_Name()
    Track.Parent = Root
    Track.AnchorPoint = Vector2.new(0, 1)
    Track.BackgroundColor3 = Track_Color
    Track.BorderSizePixel = 0
    Track.Position = UDim2.new(0, 18, 1, -22)
    Track.Size = UDim2.new(1, -36, 0, 6)
    Track.ZIndex = 1000

    Track_Corner.CornerRadius = UDim.new(1, 0)
    Track_Corner.Parent = Track

    local Fill = Instance.new("Frame")
    local Fill_Corner = Instance.new("UICorner")

    Fill.Name = Random_Name()
    Fill.Parent = Track
    Fill.BackgroundColor3 = Accent_Color
    Fill.BorderSizePixel = 0
    Fill.Size = UDim2.fromScale(0, 1)
    Fill.ZIndex = 1001

    Fill_Corner.CornerRadius = UDim.new(1, 0)
    Fill_Corner.Parent = Fill

    local Percent = Instance.new("TextLabel")
    Percent.Name = Random_Name()
    Percent.Parent = Root
    Percent.AnchorPoint = Vector2.new(1, 1)
    Percent.BackgroundTransparency = 1
    Percent.Position = UDim2.new(1, -18, 1, -30)
    Percent.Size = UDim2.fromOffset(50, 14)
    Percent.Font = Enum.Font.GothamBold
    Percent.Text = "0%"
    Percent.TextColor3 = Muted_Color
    Percent.TextSize = 11
    Percent.TextTransparency = 0.4
    Percent.TextXAlignment = Enum.TextXAlignment.Right
    Percent.ZIndex = 1000

    local Dot_Thread = task.spawn(function()
        while Root.Parent do
            Play(Title_Dot, TweenInfo.new(0.6, Enum.EasingStyle.Quad), { BackgroundTransparency = 0.7 })
            task.wait(0.6)
            Play(Title_Dot, TweenInfo.new(0.6, Enum.EasingStyle.Quad), { BackgroundTransparency = 0 })
            task.wait(0.6)
        end
    end)

    local Loader = { Root = Root, ScreenGui = ScreenGui }

    function Loader:SetAccent(Color)
        Accent_Color = Color
        Fill.BackgroundColor3 = Color
        Title_Dot.BackgroundColor3 = Color
        Title_Icon.TextColor3 = Color
    end

    function Loader:SetStatus(Text)
        Status.Text = tostring(Text or "")
    end

    function Loader:SetProgress(Alpha, Label)
        Alpha = math.clamp(Alpha or 0, 0, 1)

        Play(Fill, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = UDim2.fromScale(Alpha, 1),
        })

        Percent.Text = string.format("%d%%", math.floor(Alpha * 100 + 0.5))

        if Label then
            Loader:SetStatus(Label)
        end
    end

    function Loader:Close()
        if Dot_Thread then
            pcall(task.cancel, Dot_Thread)
            Dot_Thread = nil
        end

        local Fade = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        for _, Obj in ipairs({ Title_Icon, Title, Title_Dot, Status, Track, Percent }) do
            if Obj:IsA("TextLabel") then
                Play(Obj, Fade, { TextTransparency = 1 })
            else
                Play(Obj, Fade, { BackgroundTransparency = 1 })
            end
        end

        Play(Fill, Fade, { BackgroundTransparency = 1 })

        task.wait(0.22)
        local Collapse = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

        Play(Root, Collapse, {
            Size = UDim2.fromOffset(300, 0),
            BackgroundTransparency = 1,
        })

        Play(Root_Stroke, Collapse, { Transparency = 1 })

        Shadow:Render(false)

        task.delay(0.3, function()
            if ScreenGui then
                ScreenGui:Destroy()
            end
        end)
    end

    function Loader:Run(Steps)
        task.spawn(function()
            Steps = Steps or {{ Label = "Label", Time = 0.45 }}

            local Total = 0
            for _, S in ipairs(Steps) do
                Total = Total + (S.Time or 0.2)
            end

            local Elapsed = 0

            for _, Step in ipairs(Steps) do
                Loader:SetStatus(Step.Label or "...")

                if Step.Run then
                    local Done = false
                    Step.Run(function() Done = true end)

                    local Start = tick()
                    while not Done and tick() - Start < (Step.Timeout or 5) do
                        task.wait(0.05)
                    end
                else
                    task.wait(Step.Time or 0.2)
                end

                Elapsed = Elapsed + (Step.Time or 0.2)
                Loader:SetProgress(Elapsed / Total)
            end

            Loader:SetProgress(1, "Done!")
            task.wait(1.25)
            Loader:Close()
        end)
    end

    return Loader
end)()

Neverlose_Loader:Run({
    { Label = "Initializing...", Time = 0.45 },
    { Label = "Downloading Framework...", Time = 0.75 },
    { Label = "Downloading Library...", Time = 0.45 },
    { Label = "Downloading Files...", Time = 0.55 },
    { Label = "Downloading Dashboard...", Time = 0.55 },
    { Label = "Downloading Changelogs...", Time = 0.75 },
    { Label = "Caching Assets...", Time = 0.55 },
    { Label = "Verifying Resources...", Time = 0.75 },
    { Label = "Building Interface...", Time = 0.55 },
    { Label = "Loading Dependencies...", Time = 0.75 },
})
