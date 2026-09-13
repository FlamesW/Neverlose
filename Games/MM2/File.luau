-- // Neverlose - Murder Mystery 2
local Game, os_clock, loadstring, tostring, match, warn, task_wait = game, os.clock, loadstring, tostring, match, warn, task.wait
local write_file, read_file, is_file, make_folder, is_folder = writefile, readfile, isfile, makefolder, isfolder
local globalEnv = (getgenv and getgenv() or _G) :: any;

local function Load_Module()
    local Source = "https://github.com/FlamesW/FunctionManager/releases/latest/download/Module.luau"
    local Repo = "https://raw.githubusercontent.com/FlamesW/FunctionManager"

    if not is_folder("@File_Caches") then
        make_folder("@File_Caches")
    end

    local File = "@File_Caches/Module.luau"

    local function Execute(Content)
        local Chunk, Error = loadstring(Content)

        if not Chunk then
            warn("[FunctionManager]: Failed to compile module:\n" .. tostring(Error))
        end

        local Success, Result = pcall(Chunk)

        if not Success then
            warn("[FunctionManager]: Failed to execute module:\n" .. tostring(Result))
        end

        return Result
    end

    if is_file(File) then
        local Content = read_file(File)

        if Content then
            local Current_Version = Content:match('Build%s*=%s*"@([%d%.]+)"')
            local Latest_Version

            local Success, Response = pcall(function()
                return Game:HttpGet(Repo .. "/home/%40Version.cfg?nocache=" .. tostring(os_clock()))
            end)

            if Success and Response then
                Latest_Version = Response:match("@([%d%.]+)")
            end

            if Latest_Version and Current_Version and Latest_Version ~= Current_Version then
                local FreshContent = Game:HttpGet(Source .. "?nocache=" .. tostring(os_clock()))
                pcall(write_file, File, FreshContent)

                return Execute(FreshContent)
            end

            return Execute(Content)
        end
    end

    local Content = Game:HttpGet(Source .. "?nocache=" .. tostring(os_clock()))

    pcall(write_file, File, Content)
    return Execute(Content)
end

local Function_Manager = Load_Module()
local Script = Function_Manager.Launch({})

local NeverLose, Notification, Logging, Files, NeverKeybind, Window
local Days, Created, Watermark, Fps, Ping, Time, UI_Toggle, StartTime

function Create_Window()
    NeverLose = Script:Load_NeverLose()
    Notification = NeverLose:CreateNotification()
    Logging = NeverLose:CreateLogger()

    Files = "NeverLose/Games/MurderMystery2"
    NeverKeybind = Script:LoadData("NeverLose/Assets/Keybind.json") or "V"

    Window = NeverLose:CreateWindow({
        Logo = NeverLose.GlobalLogo,
        Name = "Neverlose",
        Content = "Murder Mystery2",
        Size = Script.IsPC and NeverLose.Scales.Default or NeverLose.Scales.Mobile,
        ConfigFolder = (globalEnv.Multi_Support == true) and Files .. "/Configs"
            or Files .. "/" .. Script.LocalPlayer.Name .. "/Configs",
        Keybind = NeverKeybind
    })

    Days = Script.LocalPlayer.AccountAge or 0
    Created = os.date("*t", os.time() - (Days * 86400))

    Window:SetAccount({
        Expires = string.format("Joined: %02d/%02d/%04d", Created.day, Created.month, Created.year),
    })

    Script:AntiAFK()
    Script:SetCameraOcclusion("Invisicam")

    Watermark = Window:Watermark()

    Fps = Watermark:AddBlock("chart-scatter-plot", "...")
    Ping = Watermark:AddBlock("chart-four-vertical-bars", "...")
    Time = Watermark:AddBlock("clock", "00:00:00")
    UI_Toggle = Watermark:AddBlock("cube-vertexes", "Neverlose")

    UI_Toggle:Input(function()
        Window:ToggleInterface()
    end)

    StartTime = tick()

    Notification.new({
        Title = "Good " .. Script:GetTimeOfDay() .. ", " .. Script.LocalPlayer.DisplayName .. " <3",
        Content = 'Your current keybind is "' .. NeverKeybind .. '"~',
        Duration = 10,
    })

    Script:WhileLoop(0.4, function(self)
        if self:SmartTimer("Refresh_Rate", 1.15) then
            Ping:SetText(self:GetPing() .. " Ping")
        end

        Fps:SetText(self:GetFps() .. " Fps")

        local Elapsed = math.floor(tick() - StartTime)
        local H, M, S = math.floor(Elapsed / 3600), math.floor((Elapsed % 3600) / 60), Elapsed % 60

        Time:SetText(string.format("%02d:%02d:%02d", H, M, S))
    end, "Statistics_Manager", false)
end
Create_Window()

Script:Inject(
    "https://raw.githubusercontent.com/FlamesW/Neverlose/home/Assets/Dashboard.luau",
    {
        Script = Script,
        NeverLose = NeverLose,
        Window = Window,
        Logging = Logging,
    },
    ("NeverLose/Assets/Dashboard.luau")
)
-- // Scripts here


function Create_Interface()
    if Script.IsPC then
        Window.UserSettings:AddLabel('Menu Keybind'):AddKeybind({
            Default = NeverKeybind,
            Blacklist = { "M1B", "M2B", "F9", "Period", "RightShift", "LeftShift", "Tab" },
            Callback = function(Value)
                Window.Keybind = Value

                Script:SaveData("NeverLose/Assets/Keybind.json", Value)
                Logging.new("ps4-touchpad", 'Changed keybind to ' .. tostring(Value), 5)
            end,
        })
    end

    Window.UserSettings:AddLabel('Menu Scale'):AddDropdown({
        Default = Script.IsPC and "Default" or "Mobile",
        Flag = "Menu_Scale",
        Values = {"Default", 'Large', 'Mobile', 'Small'},
        Callback = function(Value)
            Window:SetSize(NeverLose.Scales[Value]);

            Logging.new("crop", 'Changed size to ' .. tostring(Value), 3)
        end,
    })

    Window.UserSettings:AddLabel('Accent Color'):AddColorPicker({
        Default = NeverLose.AccentColor,
        Flag = "Accent_Color",
        OnColor = function(Value)
            NeverLose:SetAccent(Value);
        end,
        Callback = function(Value)
            Logging.new("paint-bucket", "Accent updated!", 3);
        end,
    })

    Window.UserSettings:AddLabel('3D Render'):AddToggle({
        Default = false,
        Flag = "3D_Render",
        Callback = function(Value)
            Script:Set3DRendering(Value)
        end,
    })

    local FpsSlider = Window.UserSettings:AddLabel("FPS Cap"):AddSlider({
        Default = 0,
        Min = 0,
        Max = 360,
        Type = " FPS",
        Rounding = 0,
        Nums = {
            [0] = "Unlimited",
        },
        Flag = "Fps_Cap",
        Size = 140,
        Callback = function(Value)
            Script:SetFpsCap(Value)
        end,
    })
    FpsSlider:SetValue(0)

    Window.UserSettings:AddButton({
        Icon = 'discord',
        Name = 'Discord',
        Callback = function()
            setclipboard('https://discord.com/users/1197974090519158974')
            Logging.new("discord", 'Copied discord user link', 5)
        end,
    })

    Window.UserSettings:AddButton({
        Icon = 'door-open-arrow-to-bottom-right',
        Name = 'Unload Neverlose',
        Callback = function()
            local TPTool = NeverLose.Flags["Movement_TPTool"]
            if TPTool and TPTool:GetValue() then
                TPTool:SetValue(false)
            end

            local HipHeight = NeverLose.Flags["Movement_HipHeight"]
            if HipHeight and HipHeight:GetValue() then
                HipHeight:SetValue(false)
            end

            local Fullbright = NeverLose.Flags["Vision_Fullbright"]
            if Fullbright and Fullbright:GetValue() then
                Fullbright:SetValue(false)
            end

            NeverLose:Unload()

            Script:SetCameraOcclusion("Zoom")
            Script:ThirdPerson(false)
            Script:SetGravity(196.2)
            Script:SetFOV(70)
            Script:Unload()

            if globalEnv.Multi_Support then
                globalEnv.Multi_Support = nil;
            end
        end,
    })
end

Create_Interface()
