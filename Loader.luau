-- // @Neverlose
local Game: DataModel = game
if not (Game:IsLoaded()) then Game.Loaded:Wait() end

local write_file, read_file, is_file, is_folder, make_folder = writefile, readfile, isfile, isfolder, makefolder

local table_insert, table_concat = table.insert, table.concat
local string_gmatch, string_char, string_byte, string_format, math_random = string.gmatch, string.char, string.byte, string.format, math.random
local os_clock, os_time, loadstring, tostring, warn = os.clock, os.time, loadstring, tostring, warn

-- // @Files
local Files = {
    ["Murder Mystery 2"] = { File = "MM2/File.luau", Universe = 66654135, UUID = 142823291 },
    ["Random Game"] = { File = "Random/File.luau", Universe = 9271746647, UUID = 123974602339071 },
}
local Repo, Point = ("https://raw.githubusercontent.com/FlamesW/Neverlose/home/Games/"), (Game.GameId)

local function Log(...)
    warn("[NeverLose]:", ...)
end

local function Create_Folder(Path)
    if is_folder(Path) then return end

    local Segments = {}
    for Part in string_gmatch(Path, "[^/]+") do
        table_insert(Segments, Part)
    end

    for i = 1, #Segments do
        local Sub = table_concat(Segments, "/", 1, i)
        if not is_folder(Sub) then make_folder(Sub) end
    end
end

-- // @Shift
local Key = 21

local function Simple_Encode(Data)
    local Out = {}
    for i = 1, #Data do
        Out[i] = string_char((string_byte(Data, i) + Key) % 256)
    end
    return table_concat(Out)
end

local function Simple_Decode(Data)
    local Out = {}
    for i = 1, #Data do
        Out[i] = string_char((string_byte(Data, i) - Key) % 256)
    end
    return table_concat(Out)
end

local function Load_Game(Url, Cache, Name)
    local Source

    if is_file(Cache) then
        Source = Simple_Decode(read_file(Cache))

        task.spawn(function()
            local Success, Remote = pcall(function()
                return Game:HttpGet(Url .. "?nocache=" .. tostring(os_clock() * 10000))
            end)

            if Success and Remote and Remote ~= Source then
                pcall(write_file, Cache, Simple_Encode(Remote))
            end
        end)
    else
        Source = Game:HttpGet(Url .. "?nocache=" .. tostring(os_clock() * 10000))
        pcall(write_file, Cache, Simple_Encode(Source))
    end

    local fn, Err = loadstring(Source)
    if not fn then
        Log("Compile error:", Err)
        return nil
    end

    local ok, Response = pcall(fn)
    if not ok then
        Log("Runtime error:", Response)
    end

    return Response
end

local function From_GameToFile()
    for File, Info in pairs(Files) do
        if Info.Universe == Point then
            return File, Info
        end
    end
    return nil, nil
end

-- // @Setup
local cloneref: (Instance) -> Instance = (cloneref or clonereference or function(instance: Instance)
    return instance
end)

local Tween_Service = cloneref(Game:GetService("TweenService"))
local CoreGui = (gethui and gethui()) or (get_hidden_gui and get_hidden_gui()) or Game:FindFirstChild("CoreGui")
local Protect_Gui = protect_gui or protectgui or (syn and syn.protect_gui) or function(s) return s end

local Main_Color = Color3.fromRGB(8, 8, 13)
local Stroke_Color = Color3.fromRGB(45, 48, 58)
local Text_Color = Color3.fromRGB(255, 255, 255)
local Muted_Color = Color3.fromRGB(186, 186, 186)
local Accent_Color = Color3.fromRGB(78, 127, 252)

local function Play(Instance, Info, Props)
    local Tween = Tween_Service:Create(Instance, Info, Props)
    Tween:Play()
    return Tween
end

local function Random_Name()
    return string_format("LA_%d_%d", math_random(1e6), math_random(1e6))
end

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
        table_insert(Layers, S)
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

-- // @Main Loader
local Supported, Game_Info = From_GameToFile()

if not Supported then
    Log("Unsupported Game")

    local Success_Color = Color3.fromRGB(76, 175, 80)
    local Danger_Color = Color3.fromRGB(220, 53, 69)

    local Do_Not_Disturb = "NeverLose/Assets/Policy"

    if is_file(Do_Not_Disturb) then
        local Success, Data = pcall(read_file, Do_Not_Disturb)
        if Success and Data then
            local Times_tamp = tonumber(Data)
            if Times_tamp and (os_time() - Times_tamp) < 3600 then
                return
            end
        end
    end

    local Game_List = {}
    for Display_Name, Info in pairs(Files) do
        table_insert(Game_List, {
            Name = Display_Name,
            Universe = Info.Universe,
            UUID = Info.UUID,
        })
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = Random_Name()
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.DisplayOrder = 9999

    Protect_Gui(ScreenGui)
    ScreenGui.Parent = CoreGui

    local Row_Height = 62
    local Row_Spacing = 8
    local Padding = 18
    local Header_Height = 78
    local Footer_Height = 34
    local Row_Count = #Game_List
    local Root_Height = Header_Height + (Row_Height * Row_Count) + (Row_Spacing * (Row_Count - 1)) + Footer_Height

    local Root = Instance.new("Frame")
    local Root_Corner = Instance.new("UICorner")
    local Root_Stroke = Instance.new("UIStroke")

    Root.Name = Random_Name()
    Root.Parent = ScreenGui
    Root.AnchorPoint = Vector2.new(0.5, 0.5)
    Root.BackgroundColor3 = Main_Color
    Root.BackgroundTransparency = 1
    Root.BorderSizePixel = 0
    Root.Position = UDim2.fromScale(0.5, 0.5)
    Root.Size = UDim2.fromOffset(360, Root_Height)
    Root.ZIndex = 999
    Root.ClipsDescendants = true

    Root_Corner.CornerRadius = UDim.new(0, 12)
    Root_Corner.Parent = Root

    Root_Stroke.Transparency = 1
    Root_Stroke.Color = Stroke_Color
    Root_Stroke.Parent = Root

    local Shadow = Make_Shadow(Root)
    Shadow:Render(true)

    local Header_Dot = Instance.new("Frame")
    local Header_Dot_Corner = Instance.new("UICorner")

    Header_Dot.Name = Random_Name()
    Header_Dot.Parent = Root
    Header_Dot.AnchorPoint = Vector2.new(1, 0)
    Header_Dot.BackgroundColor3 = Accent_Color
    Header_Dot.BorderSizePixel = 0
    Header_Dot.Position = UDim2.new(1, -Padding, 0, 24)
    Header_Dot.Size = UDim2.fromOffset(6, 6)
    Header_Dot.ZIndex = 1000

    Header_Dot_Corner.CornerRadius = UDim.new(1, 0)
    Header_Dot_Corner.Parent = Header_Dot

    local Dot_Thread = task.spawn(function()
        while Root.Parent do
            Play(Header_Dot, TweenInfo.new(0.6, Enum.EasingStyle.Quad), { BackgroundTransparency = 0.7 })
            task.wait(0.6)
            Play(Header_Dot, TweenInfo.new(0.6, Enum.EasingStyle.Quad), { BackgroundTransparency = 0 })
            task.wait(0.6)
        end
    end)

    local Title_Icon = Instance.new("TextLabel")
    Title_Icon.Name = Random_Name()
    Title_Icon.Parent = Root
    Title_Icon.BackgroundTransparency = 1
    Title_Icon.Position = UDim2.fromOffset(Padding, 16)
    Title_Icon.Size = UDim2.fromOffset(20, 20)
    Title_Icon.Font = Enum.Font.GothamBold
    Title_Icon.Text = "❖"
    Title_Icon.TextColor3 = Accent_Color
    Title_Icon.TextSize = 21
    Title_Icon.TextTransparency = 0.05
    Title_Icon.ZIndex = 1000

    local Title = Instance.new("TextLabel")
    Title.Name = Random_Name()
    Title.Parent = Root
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.fromOffset(Padding + 26, 14)
    Title.Size = UDim2.new(1, -(Padding * 2) - 26, 0, 22)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Supported Games"
    Title.TextColor3 = Text_Color
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 1000

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = Random_Name()
    Subtitle.Parent = Root
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.fromOffset(Padding, 42)
    Subtitle.Size = UDim2.new(1, -(Padding * 2), 0, 16)
    Subtitle.Font = Enum.Font.GothamMedium
    Subtitle.Text = "This game isn't supported yet, try one of these games:"
    Subtitle.TextColor3 = Muted_Color
    Subtitle.TextSize = 12
    Subtitle.TextTransparency = 0.35
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.ZIndex = 1000

    local Rows = {}
    local Row_Height_Inner = 46

    for Index, Entry in ipairs(Game_List) do
        local Row = Instance.new("Frame")
        local Row_Corner = Instance.new("UICorner")

        Row.Name = Random_Name()
        Row.Parent = Root
        Row.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        Row.BackgroundTransparency = 1
        Row.BorderSizePixel = 0
        Row.Position = UDim2.fromOffset(Padding, Header_Height + ((Index - 1) * (Row_Height + Row_Spacing)))
        Row.Size = UDim2.new(1, -(Padding * 2), 0, Row_Height)
        Row.ZIndex = 1000

        Row_Corner.CornerRadius = UDim.new(0, 10)
        Row_Corner.Parent = Row

        local Thumb_Frame = Instance.new("Frame")
        local Thumb_Corner = Instance.new("UICorner")
        local Thumb_Image = Instance.new("ImageLabel")
        local Thumb_Image_Corner = Instance.new("UICorner")

        Thumb_Frame.Name = Random_Name()
        Thumb_Frame.Parent = Row
        Thumb_Frame.AnchorPoint = Vector2.new(0, 0.5)
        Thumb_Frame.BackgroundColor3 = Color3.fromRGB(30, 29, 36)
        Thumb_Frame.BorderSizePixel = 0
        Thumb_Frame.Position = UDim2.new(0, 10, 0.5, 0)
        Thumb_Frame.Size = UDim2.fromOffset(Row_Height_Inner, Row_Height_Inner)
        Thumb_Frame.ZIndex = 1001

        Thumb_Corner.CornerRadius = UDim.new(0, 8)
        Thumb_Corner.Parent = Thumb_Frame

        Thumb_Image.Name = Random_Name()
        Thumb_Image.Parent = Thumb_Frame
        Thumb_Image.BackgroundTransparency = 1
        Thumb_Image.Size = UDim2.fromScale(1, 1)
        Thumb_Image.Image = "rbxthumb://type=GameIcon&id=" .. tostring(Entry.Universe) .. "&w=150&h=150"
        Thumb_Image.ScaleType = Enum.ScaleType.Crop
        Thumb_Image.ZIndex = 1002

        Thumb_Image_Corner.CornerRadius = UDim.new(0, 8)
        Thumb_Image_Corner.Parent = Thumb_Image

        local Name_Label = Instance.new("TextLabel")
        Name_Label.Name = Random_Name()
        Name_Label.Parent = Row
        Name_Label.BackgroundTransparency = 1
        Name_Label.Position = UDim2.new(0, Row_Height_Inner + 22, 0, 10)
        Name_Label.Size = UDim2.new(1, -(Row_Height_Inner + 70), 0, 20)
        Name_Label.Font = Enum.Font.GothamBold
        Name_Label.Text = Entry.Name
        Name_Label.TextColor3 = Text_Color
        Name_Label.TextSize = 14
        Name_Label.TextXAlignment = Enum.TextXAlignment.Left
        Name_Label.TextTruncate = Enum.TextTruncate.AtEnd
        Name_Label.ZIndex = 1001

        local UUID_Label = Instance.new("TextLabel")
        UUID_Label.Name = Random_Name()
        UUID_Label.Parent = Row
        UUID_Label.BackgroundTransparency = 1
        UUID_Label.Position = UDim2.new(0, Row_Height_Inner + 22, 0, 30)
        UUID_Label.Size = UDim2.new(1, -(Row_Height_Inner + 70), 0, 16)
        UUID_Label.Font = Enum.Font.Gotham
        UUID_Label.Text = "UUID: " .. tostring(Entry.UUID)
        UUID_Label.TextColor3 = Muted_Color
        UUID_Label.TextSize = 11
        UUID_Label.TextTransparency = 0.4
        UUID_Label.TextXAlignment = Enum.TextXAlignment.Left
        UUID_Label.ZIndex = 1001

        local TP_Button = Instance.new("TextButton")
        local TP_Button_Corner = Instance.new("UICorner")

        TP_Button.Name = Random_Name()
        TP_Button.Parent = Row
        TP_Button.AnchorPoint = Vector2.new(1, 0.5)
        TP_Button.BackgroundColor3 = Success_Color
        TP_Button.BackgroundTransparency = 0
        TP_Button.BorderSizePixel = 0
        TP_Button.Position = UDim2.new(1, -12, 0.5, 0)
        TP_Button.Size = UDim2.fromOffset(58, 22)
        TP_Button.Font = Enum.Font.GothamBold
        TP_Button.Text = "Teleport"
        TP_Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        TP_Button.TextSize = 11
        TP_Button.AutoButtonColor = false
        TP_Button.ZIndex = 1002

        TP_Button_Corner.CornerRadius = UDim.new(0, 6)
        TP_Button_Corner.Parent = TP_Button

        TP_Button.MouseEnter:Connect(function()
            Play(TP_Button, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(96, 200, 104),
            })
        end)

        TP_Button.MouseLeave:Connect(function()
            Play(TP_Button, TweenInfo.new(0.15), {
                BackgroundColor3 = Success_Color,
            })
        end)

        TP_Button.MouseButton1Click:Connect(function()
            Close()
            Game:GetService("TeleportService"):Teleport(Entry.UUID, Game.Players.LocalPlayer)
        end)

        table_insert(Rows, {
            Frame = Row,
            Name_Label = Name_Label,
            Entry = Entry,
        })
    end

    local PushAway_Button = Instance.new("TextButton")
    local PushAway_Button_Corner = Instance.new("UICorner")

    PushAway_Button.Name = Random_Name()
    PushAway_Button.Parent = Root
    PushAway_Button.AnchorPoint = Vector2.new(1, 1)
    PushAway_Button.BackgroundColor3 = Danger_Color
    PushAway_Button.BackgroundTransparency = 1
    PushAway_Button.BorderSizePixel = 0
    PushAway_Button.Position = UDim2.new(1, -Padding, 1, -8)
    PushAway_Button.Size = UDim2.fromOffset(110, 20)
    PushAway_Button.Font = Enum.Font.GothamBold
    PushAway_Button.Text = "Do not disturb"
    PushAway_Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    PushAway_Button.TextSize = 11
    PushAway_Button.AutoButtonColor = false
    PushAway_Button.ZIndex = 1002

    PushAway_Button_Corner.CornerRadius = UDim.new(0, 6)
    PushAway_Button_Corner.Parent = PushAway_Button

    PushAway_Button.MouseEnter:Connect(function()
        Play(PushAway_Button, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(240, 70, 85),
            BackgroundTransparency = 0,
        })
    end)

    PushAway_Button.MouseLeave:Connect(function()
        Play(PushAway_Button, TweenInfo.new(0.15), {
            BackgroundColor3 = Danger_Color,
            BackgroundTransparency = 0.1,
        })
    end)

    PushAway_Button.MouseButton1Click:Connect(function()
        Create_Folder("NeverLose")
        write_file(Do_Not_Disturb, tostring(os_time()))

        Close()
    end)

    local Footer = Instance.new("TextLabel")
    Footer.Name = Random_Name()
    Footer.Parent = Root
    Footer.BackgroundTransparency = 1
    Footer.Position = UDim2.new(0, Padding, 1, -Footer_Height + 6)
    Footer.Size = UDim2.new(1, -(Padding * 2 + 120), 0, 18)
    Footer.Font = Enum.Font.GothamMedium
    Footer.Text = "NeverLose · One Step Ahead. Always~"
    Footer.TextColor3 = Muted_Color
    Footer.TextSize = 11
    Footer.TextTransparency = 0.5
    Footer.TextXAlignment = Enum.TextXAlignment.Left
    Footer.ZIndex = 1000

    Close = function()
        local Fade = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        for _, Obj in ipairs({ Title_Icon, Title, Subtitle, Footer, Header_Dot, PushAway_Button }) do
            if Obj:IsA("TextLabel") then
                Play(Obj, Fade, { TextTransparency = 1 })
            elseif Obj:IsA("TextButton") then
                Play(Obj, Fade, {
                    BackgroundTransparency = 1,
                    TextTransparency = 1,
                })
            else
                Play(Obj, Fade, { BackgroundTransparency = 1 })
            end
        end

        for _, Row in ipairs(Rows) do
            Play(Row.Frame, Fade, { BackgroundTransparency = 1 })
        end

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

    task.wait(0.05)

    Play(Root, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.055,
    })
    Play(Root_Stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 0.650,
    })
    for _, Row in ipairs(Rows) do
        Play(Row.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.4,
        })
    end
    Play(PushAway_Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.1,
    })

    task.delay(15, function()
        if not ScreenGui or not ScreenGui.Parent then return end
        Close()
    end)

    return
end

local File = Repo .. Game_Info.File
local Cache = "NeverLose/Assets/Caches/" .. Supported:gsub("%s+", "") .. ".File"

local function Load_Script()
    Load_Game(File, Cache, Supported)
end

if is_folder("NeverLose/Games") then
    Load_Script()
    return
end

local Neverlose_Downloader = (function()
    local Track_Color = Color3.fromRGB(30, 29, 36)

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
    Title_Icon.TextSize = 21
    Title_Icon.TextTransparency = 0.05
    Title_Icon.ZIndex = 1000

    local Title = Instance.new("TextLabel")
    Title.Name = Random_Name()
    Title.Parent = Root
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.fromOffset(46, 13)
    Title.Size = UDim2.new(1, -60, 0, 22)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Neverlose Downloader"
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

        Percent.Text = string_format("%d%%", math.floor(Alpha * 100 + 0.5))

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

                local Start = tick()

                if Step.Run then
                    local Done = false
                    Step.Run(function() Done = true end)

                    while not Done and tick() - Start < (Step.Timeout or 5) do
                        task.wait(0.05)
                    end
                end

                local Remaining = (Step.Time or 0.2) - (tick() - Start)
                if Remaining > 0 then
                    task.wait(Remaining)
                end

                Elapsed = Elapsed + (Step.Time or 0.2)
                Loader:SetProgress(Elapsed / Total)
            end

            Loader:SetProgress(1, "Done!")
            task.wait(0.5)
            Loader:Close()
        end)
    end

    return Loader
end)()

Neverlose_Downloader:Run({
    {
        Label = "Initializing...",
        Time = 0.35,
        Run = function(Done)
            Create_Folder("NeverLose/Assets/Caches")
            Done()
        end,
    },
    { Label = "Downloading Framework...", Time = 0.55 },
    { Label = "Downloading Library...", Time = 0.45 },
    { Label = "Downloading Files...", Time = 0.65 },
    { Label = "Downloading Dashboard...", Time = 0.55 },
    { Label = "Downloading Changelogs...", Time = 0.65 },
    { Label = "Caching Assets...", Time = 0.55 },
    { Label = "Verifying Resources...", Time = 0.75 },
    { Label = "Building Interface...", Time = 0.55 },
    {
        Label = "Loading Dependencies...",
        Time = 0.35,
        Run = function(Done)
            Load_Script()
            Done()
        end,
    },
})
