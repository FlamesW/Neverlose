-- // @Neverlose
local Game: DataModel = game;
if not (Game:IsLoaded()) then Game.Loaded:Wait() end

local write_file, read_file, is_file, is_folder, make_folder = writefile, readfile, isfile, isfolder, makefolder

local table_insert, table_concat = table.insert, table.concat
local string_gmatch, string_char, string_byte = string.gmatch, string.char, string.byte
local os_clock, loadstring, tostring, warn = os.clock, loadstring, tostring, warn

-- // @Files
local Files = {
    ["Murder Mystery 2"] = { File = "MM2/File.luau", Universe = 66654135 },
    ["Random Game"] = { File = "Random/File.luau", Universe = 9271746647 },
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
Create_Folder("NeverLose/Assets/Caches")

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
                -- // Log(Name, "got updated!")
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
    for File, Game in pairs(Files) do
        if Game.Universe == Point then
            return File, Game
        end
    end
    return nil, nil
end

-- // @Main Loader
local Supported, Game = From_GameToFile()

if Supported then
    local File = Repo .. Game.File
    Load_Game(File, "NeverLose/Assets/Caches/" .. Supported:gsub("%s+", "") .. ".File", Supported)
    Log(Supported)
else
    Log("Unsupported Game")
end
