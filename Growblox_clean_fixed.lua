-- Recovered Luau source by ZeroVector
local function __store_list(t, start, ...)
    for i = 1, select("#", ...) do
        t[start + i - 1] = (select(i, ...))
    end
end

local v = LIMEHUB_ScriptVersion
local str = v or "Dev Version"
local v2 = getgenv
local genv = v2 and getgenv() or _G

if type(genv.GBX_STOP) == "function" then
    pcall(genv.GBX_STOP)
end

if type(genv.MineHubGBX) == "function" then
    pcall(genv.MineHubGBX)
end

local function fn(arg)
    local ok, result = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/" .. arg)
    end)

    if not ok or type(result) ~= "string" or result == "" then
        error("Mine Hub: cannot download " .. arg, 0)
    end

    -- Compatibility patch: some executors fail in TextService:GetTextBoundsAsync.
    -- Keep the modern API when it works, and fall back to GetTextSize when it does not.
    if arg == "Library.lua" then
        local target = "    local Bounds = TextService:GetTextBoundsAsync(Params)\\n    return math.ceil(Bounds.X / Scale), math.ceil(Bounds.Y / Scale)"
        local replacement = [[    local Success, Bounds = pcall(function()
        return TextService:GetTextBoundsAsync(Params)
    end)

    if not Success or not Bounds then
        local PlainText = Params.Text:gsub("<[^>]->", "")
        local LegacyFont = Enum.Font.Code
        local Width = Params.Width or (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X - 32 or 1920)
        Bounds = TextService:GetTextSize(PlainText, Params.Size, LegacyFont, Vector2.new(Width, math.huge))
    end

    return math.ceil(Bounds.X / Scale), math.ceil(Bounds.Y / Scale)]]
        local patched
        result, patched = result:gsub(target, replacement, 1)
        if patched == 0 then
            warn("Mine Hub: Obsidian text-bounds patch pattern not found; using original library.")
        end
    end

    local chunk, v3 = loadstring(result, "Obsidian/" .. arg)

    if not chunk then
        error("Mine Hub: " .. arg .. " did not compile. " .. tostring(v3), 0)
    end

    return chunk()
end

local lua = fn("Library.lua")
local lua2 = fn("addons/ThemeManager.lua")
local lua3 = fn("addons/SaveManager.lua")

local tbl = {
    Players = game:GetService("Players"),
    Storage = game:GetService("ReplicatedStorage"),
    Run = game:GetService("RunService"),
    Input = game:GetService("UserInputService"),
    Http = game:GetService("HttpService"),
}

local localPlayer = tbl.Players.LocalPlayer

if game.PlaceId ~= 112863874972771 then
    error("Mine Hub: this script supports Growblox", 0)
end

local tbl2 = {
    Items = {},
    Assets = {},
    Net = {},
    Codec = {},
    Recipes = {},
    RecipeByResult = {},
}

local function fn2()
    if next(tbl2.RecipeByResult) ~= nil or next(tbl2.Recipes) == nil then
        return
    end

    for i, recipe in ipairs(tbl2.Recipes) do
        if type(recipe) == "table" and type(recipe[1]) == "number" and type(recipe[2]) == "number" and type(recipe[3]) == "number" and not tbl2.RecipeByResult[recipe[3]] then
            tbl2.RecipeByResult[recipe[3]] = {A = recipe[1], B = recipe[2], Result = recipe[3]}
        end
    end
end

local function fn3(items)
    if type(items) ~= "table" then
        return
    end
    local value = rawget(items, 2)
    local value2 = rawget(items, 18)
    local value3 = rawget(items, 1)
    local value4 = rawget(items, 2)

    if next(tbl2.Items) == nil and type(value) == "table" and type(rawget(value, "name")) == "string" and type(value2) == "table" and type(rawget(value2, "name")) == "string" then
        tbl2.Items = items
    elseif next(tbl2.Assets) == nil and type(rawget(items, "TileSize")) == "number" and type(rawget(items, "Atlas")) == "table" then
        tbl2.Assets = items
    elseif next(tbl2.Net) == nil and type(rawget(items, "move")) == "table" and type(rawget(items, "act")) == "table" and type(rawget(items, "take")) == "table" then
        tbl2.Net = items
    elseif next(tbl2.Recipes) == nil and type(value3) == "table" and type(value4) == "table" and rawget(value3, 1) == 3 and rawget(value3, 2) == 15 and rawget(value3, 3) == 13 then
        tbl2.Recipes = items
        fn2()
    end
end

local shared = tbl.Storage:FindFirstChild("Shared")

if shared then
    pcall(function()
        if shared:FindFirstChild("ItemDB") then
            tbl2.Items = require(shared.ItemDB)
        end

        if shared:FindFirstChild("Assets") then
            tbl2.Assets = require(shared.Assets)
        end

        if shared:FindFirstChild("Net") then
            tbl2.Net = require(shared.Net)
        end

        if shared:FindFirstChild("WorldCodec") then
            tbl2.Codec = require(shared.WorldCodec)
        end

        if shared:FindFirstChild("SpliceRecipes") then
            tbl2.Recipes = require(shared.SpliceRecipes)
            fn2()
        end
    end)
end

if (next(tbl2.Items) == nil or next(tbl2.Assets) == nil or next(tbl2.Net) == nil or next(tbl2.Recipes) == nil) and getconnections and debug.getupvalues then
    local ok, result = pcall(getconnections, tbl.Run.RenderStepped)

    if ok and type(result) == "table" then
        local v3, v4, v5 = ipairs(result)
        local v6 = v5
        local v7 = v3
        local v8 = v4

        while true do
            local v9, v10 = v7(v8, v6)
            if v9 == nil then
                break
            end
            v6 = v9

            if type(v10.Function) == "function" then
                local ok2, result2 = pcall(debug.getupvalues, v10.Function)

                if ok2 and type(result2) == "table" then
                    local v11, v12, v13 = pairs(result2)
                    local v14 = v9
                    local v15 = v7
                    local v16 = v8
                    local v17 = v13
                    local v18 = v11
                    local v19 = v12

                    while true do
                        local v20, v21 = v18(v19, v17)
                        if v20 == nil then
                            break
                        end
                        v17 = v20

                        if type(v21) == "table" then
                            fn3(v21)
                        elseif type(v21) == "function" then
                            local ok3, result3 = pcall(debug.getupvalues, v21)

                            if ok3 and type(result3) == "table" then
                                for k, v22 in pairs(result3) do
                                    fn3(v22)
                                end

                                v17 = v20
                            end
                        end
                    end

                    v6 = v14
                    v7 = v15
                    v8 = v16
                end
            end
        end
    end
end

if (next(tbl2.Items) == nil or next(tbl2.Assets) == nil or next(tbl2.Net) == nil or next(tbl2.Recipes) == nil) and getgc then
    local ok, result = pcall(getgc, true)

    if ok and type(result) == "table" then
        local v3, v4, v5 = ipairs(result)
        local v6 = v5
        local v7 = v3
        local v8 = v4
        local v9, v10, ok2, result2

        repeat
            v9, v10 = v7(v8, v6)
            if v9 == nil then
                break
            end
            v6 = v9
            fn3(v10)

            if next(tbl2.Recipes) == nil and type(v10) == "table" then
                for k, v11 in pairs(v10) do
                    if type(k) == "string" and k:find("SpliceRecipes", 1, true) and typeof(v11) == "Instance" and v11:IsA("ModuleScript") then
                        ok2, result2 = pcall(require, v11)

                        if ok2 and type(result2) == "table" then
                            fn3(result2)
                        end
                    end
                end

                v6 = v9
            end
        until next(tbl2.Items) ~= nil and next(tbl2.Assets) ~= nil and next(tbl2.Net) ~= nil and next(tbl2.Recipes) ~= nil
    end
end

fn2()

local tbl3 = {
    hidup = true,
    scene = nil,
    bindAt = 0,
    worldName = "",
    error = nil,
    errorCount = 0,
    esp = {
        Players = false,
        Floating = false,
        Trees = false,
        Providers = false,
        Doors = false,
        Locks = false,
        Displays = false,
    },
    fruit = false,
    doorInfo = false,
    espLines = true,
    antiLag = false,
    noParticle = false,
    maxLabels = 120,
    labelSize = 12,
    connections = {},
    tasks = {},
    labels = {},
    markers = {},
    ui = {},
    controls = {},
    flags = {},
    configName = "default",
    selectedConfig = nil,
    folder = "MineHub/Growblox",
    configLoading = false,
}

local tbl4 = {}
local v3 = setthreadidentity
local setThreadIdentity = v3 or setidentity or set_thread_identity

if not setThreadIdentity then
    local v4 = syn
    setThreadIdentity = v4 and syn.set_thread_identity
end

tbl4.setIdentity = setThreadIdentity
local v4 = nil

tbl4.elevate = function()
    if tbl4.setIdentity then
        pcall(tbl4.setIdentity, 8)
    end
end

tbl4.notice = function(arg, arg2)
    tbl4.elevate()

    if tbl3.hidup then
        local notify = lua.Notify
        local tbl5 = {}
        local title = arg2 or "Mine Hub"
        tbl5.Title = title
        tbl5.Description = tostring(arg)
        tbl5.Time = 4
        notify(lua, tbl5)
    end
end

tbl4.failure = function(arg)
    tbl3.error = tostring(arg)
    tbl3.errorCount = tbl3.errorCount + 1
end

tbl4.spawn = function(arg)
    local thread = coroutine.create(function()
        tbl4.elevate()
        local ok, result = pcall(arg)
        tbl3.tasks[coroutine.running()] = nil

        if not ok and tbl3.hidup then
            tbl4.failure(result)
            tbl4.notice(result, "Growblox")
        end
    end)

    tbl3.tasks[thread] = true
    task.spawn(thread)
    return thread
end

tbl4.connect = function(arg, arg2)
    local connection = arg:Connect(function(...)
        if tbl3.hidup then
            tbl4.elevate()
            local ok, result = pcall(arg2, ...)

            if not ok then
                tbl4.failure(result)
            end
        end
    end)

    tbl3.connections[#tbl3.connections + 1] = connection
    return connection
end

tbl4.upvalues = function(arg)
    if type(arg) ~= "function" or not debug.getupvalues then
        return nil
    end
    local ok, result = pcall(debug.getupvalues, arg)
    local flag = ok and type(result) == "table" and result or nil
    return flag
end

tbl4.tile = function(arg, arg2, arg3)
    local value = type(arg) == "table" and rawget(arg, arg3)
    local value2 = type(value) == "table" and rawget(value, arg2) or nil
    return value2
end

tbl4.item = function(arg)
    local value = type(arg) == "number" and rawget(tbl2.Items, arg) or nil
    return value
end

tbl4.itemName = function(arg, arg2)
    local v5 = tbl4.item(arg)
    local str2 = v5 and rawget(v5, "name") or "Item #" .. tostring(arg)

    if arg2 then
        str2 = str2:gsub(" Seed$", "") .. " Tree"
    end

    return str2
end

tbl4.coords = function(arg)
    local value = rawget(arg.world, "treeNear")

    if type(value) == "function" and debug.getupvalue then
        local v5 = debug.getupvalue(value, 1)
        local v6 = debug.getupvalue(value, 2)
        local v7 = debug.getupvalue(value, 3)
        if v5 == arg.world and type(v6) == "number" and type(v7) == "number" then
            return v6, v7
        end
    end

    if type(arg.frameFn) == "function" and debug.getupvalue then
        local v5 = debug.getupvalue(arg.frameFn, 1)
        local v6 = debug.getupvalue(arg.frameFn, 20)
        local v7 = debug.getupvalue(arg.frameFn, 21)
        if v5 == arg.world and type(v6) == "number" and type(v7) == "number" then
            return v6, v7
        end
    end

    local v5 = tbl4.upvalues(value)
    if v5 and v5[1] == arg.world and type(v5[2]) == "number" and type(v5[3]) == "number" then
        return v5[2], v5[3]
    end
    return nil
end

tbl4.isDead = function(arg)
    if type(arg.frameFn) == "function" and debug.getupvalue then
        local v5 = debug.getupvalue(arg.frameFn, 1)
        local v6 = debug.getupvalue(arg.frameFn, 7)
        if v5 == arg.world and type(v6) == "boolean" then
            return v6
        end
    end

    local value = rawget(arg.world, "deadSince")
    local value2 = rawget(arg.world, "respawnedAt")
    local flag = type(value) == "number" and (type(value2) ~= "number" or value2 < value)
    return flag
end

tbl4.restorePerformance = function()
    local performance = tbl3.performance
    if not performance then
        return
    end

    if performance.world and rawget(performance.world, "lowGfx") == true then
        performance.world.lowGfx = performance.oldLow
    end

    pcall(function()
        settings().Rendering.QualityLevel = 0
    end)

    tbl3.performance = nil
end

tbl4.restoreParticles = function()
    local particleEffect = tbl3.particleEffect
    if not particleEffect then
        return
    end

    if rawget(particleEffect.instance, "parent") == particleEffect.holder then
        particleEffect.instance.parent = particleEffect.original
    end

    if particleEffect.holder.Parent then
        for i, child in ipairs(particleEffect.holder:GetChildren()) do
            child.Parent = particleEffect.original
        end

        particleEffect.holder:Destroy()
    end

    tbl3.particleEffect = nil
end

tbl4.clearOverlay = function()
    if tbl3.overlay then
        tbl3.overlay:Destroy()
    end

    tbl3.overlay = nil
    table.clear(tbl3.labels)
    table.clear(tbl3.markers)
end

tbl4.resetScene = function()
    if tbl3.farm then
        tbl4.farmReset("World changed")
    end

    tbl4.restorePerformance()
    tbl4.restoreParticles()

    if tbl4.restoreDropMagnet then
        tbl4.restoreDropMagnet()
    end

    if tbl4.restoreWalk then
        tbl4.restoreWalk()
    end

    tbl4.clearOverlay()
    tbl3.scene = nil
end

tbl4.bind = function()
    local playerGui = localPlayer:FindFirstChild("PlayerGui")
    local gameGui = playerGui and playerGui:FindFirstChild("GameGui")
    if not gameGui or not getconnections then
        return nil, "Waiting for Growblox client"
    end
    gameGui:FindFirstChild("Game")
    local ok, result = pcall(getconnections, tbl.Run.RenderStepped)
    if not ok then
        return nil, "Client connection inspection is unavailable"
    end
    local n = os.clock() + 0.3

    for i, v5 in ipairs(result) do
        if i > 150 or n < os.clock() then
            break
        end

        local ok2, result2 = pcall(function()
            local function_ = v5.Function
            if type(function_) ~= "function" then
                return nil
            end
            local v6 = tbl4.upvalues(function_)
            if not v6 then
                return nil
            end
            local v7 = nil
            local v8 = nil
            local v9 = nil
            local v10 = nil
            local v11 = nil
            local v12 = nil
            local v13 = nil
            local v14, v15, v16 = pairs(v6)
            local v17 = v16
            local v18 = v14
            local v19 = v15

            while true do
                local v20, v21 = v18(v19, v17)
                if v20 == nil then
                    break
                end
                v17 = v20

                if type(v21) == "table" then
                    fn3(v21)

                    if type(rawget(v21, "fg")) == "table" and type(rawget(v21, "bg")) == "table" and type(rawget(v21, "w")) == "number" then
                        v7 = v21
                    elseif type(rawget(v21, "slots")) == "table" and type(rawget(v21, "capacity")) == "number" then
                        v8 = v21
                    elseif type(rawget(v21, "punchRange")) == "function" and type(rawget(v21, "buildRange")) == "function" then
                        v9 = v21
                    elseif type(rawget(v21, "where")) == "function" and type(rawget(v21, "list")) == "function" then
                        v10 = v21
                        local v22 = tbl4.upvalues(rawget(v21, "update"))
                        local v23 = v22 and tbl4.upvalues(v22[1])

                        if v23 then
                            for k, v24 in pairs(v23) do
                                fn3(v24)
                            end

                            v17 = v20
                        end
                    elseif type(rawget(v21, "openPicker")) == "function" and type(rawget(v21, "blocking")) == "function" then
                        v12 = v21
                    elseif type(rawget(v21, "live")) == "table" and rawget(v21, "parent") and type(rawget(v21, "px")) == "number" then
                        v11 = v21
                    end
                elseif type(v21) == "function" and debug.info(v21, "n") == "tileLabel" then
                    local v22 = tbl4.upvalues(v21)

                    if v22 and typeof(v22[3]) == "Instance" then
                        v13 = v22[3]
                    end
                end
            end

            if not v7 or not v8 or not v9 then
                return nil
            end
            local world = gameGui:FindFirstChild("World")
            local camera = world and world:FindFirstChild("Camera")
            local tiles = camera and camera:FindFirstChild("Tiles") or v13
            local parent = camera or tiles and tiles.Parent
            local v20 = parent
            if not tiles or not tiles.Parent then
                return nil
            end

            local tbl5 = {
                world = v7,
                inventory = v8,
                controller = v9,
                others = v10,
                particles = v11,
                menu = v12,
                gui = gameGui,
                camera = v20,
                tiles = tiles,
                frameFn = function_,
            }

            local value = rawget(tbl2.Assets, "TileSize")
            local n2 = value or 32
            tbl5.px = n2 * 2

            for k, v21 in pairs(v6) do
                if type(v21) == "function" then
                    local v22 = debug.info(v21, "n")

                    if v22 == "updateTrees" then
                        local v23 = tbl4.upvalues(v21)

                        if v23 and type(v23[2]) == "table" and v23[2] ~= v7 then
                            tbl5.treeStates = v23[2]
                        end
                    elseif v22 == "updateDrops" then
                        tbl5.updateDrops = v21
                    elseif v22 == "act" then
                        tbl5.actFn = v21
                    end
                elseif type(v21) == "table" and type(rawget(v21, "dir")) == "function" and type(rawget(v21, "jumping")) == "function" then
                    tbl5.controls = v21
                end
            end

            if v10 and type(rawget(v10, "update")) == "function" then
                local v21 = tbl4.upvalues(rawget(v10, "update"))
                local v22 = v21 and v21[1]

                if type(v22) == "function" and debug.info(v22, "n") == "sendState" then
                    tbl5.sendState = v22
                    local v23 = tbl4.upvalues(v22)

                    if v23 and type(v23[1]) == "table" then
                        tbl5.stateOwner = v23[1]
                    end
                end
            end

            return tbl5
        end)

        if ok2 and result2 then
            return result2
        end
    end

    return nil, "Growblox client state is not ready"
end

tbl4.scene = function()
    local scene = tbl3.scene

    if scene and scene.tiles.Parent and scene.gui.Parent then
        local value = rawget(scene.world, "name")
        local worldName = value or ""

        if worldName ~= tbl3.worldName then
            tbl4.restorePerformance()
            tbl4.restoreParticles()
            tbl4.clearOverlay()
            tbl3.worldName = worldName

            if tbl3.onWorldChanged then
                tbl3.onWorldChanged(worldName)
            end
        end

        local flag = worldName ~= "" and scene or nil
        return flag
    end

    if os.clock() < tbl3.bindAt then
        return nil
    end
    tbl3.bindAt = os.clock() + 1
    tbl4.resetScene()
    local v5 = tbl4.bind()
    tbl3.scene = v5
    if not v5 then
        return nil
    end
    local value = rawget(v5.world, "name")
    local worldName = value or ""
    tbl3.worldName = worldName
    local flag = tbl3.worldName ~= "" and v5 or nil
    return flag
end

tbl4.performance = function(arg)
    if tbl3.antiLag and arg then
        if not tbl3.performance or tbl3.performance.world ~= arg.world then
            tbl4.restorePerformance()
            tbl3.performance = {world = arg.world, oldLow = rawget(arg.world, "lowGfx")}
            arg.world.lowGfx = true

            pcall(function()
                settings().Rendering.QualityLevel = 1
            end)
        end
    else
        tbl4.restorePerformance()
    end

    if tbl3.noParticle and arg and arg.particles then
        if not tbl3.particleEffect or tbl3.particleEffect.instance ~= arg.particles then
            tbl4.restoreParticles()
            local parent = rawget(arg.particles, "parent")
            if typeof(parent) ~= "Instance" or not parent.Parent then
                return
            end
            local frame = Instance.new("Frame")
            frame.Name = "MineHubParticlePool"
            frame.BackgroundTransparency = 1
            frame.Size = UDim2.fromOffset(0, 0)
            frame.Visible = false
            frame.Parent = parent
            tbl3.particleEffect = {instance = arg.particles, original = parent, holder = frame}
            arg.particles.parent = frame
            local v5 = ipairs
            local tbl5 = {}
            local value = rawget(arg.particles, "live")
            local tbl6 = value or {}
            local value2 = rawget(arg.particles, "free")
            local tbl7 = value2 or {}
            tbl5[1] = tbl6
            tbl5[2] = tbl7
            local v6, v7, v8 = v5(tbl5)
            local v9 = v8
            local v10 = v6
            local v11 = v7

            while true do
                local v12, v13 = v10(v11, v9)
                if v12 == nil then
                    break
                end

                for k, v14 in pairs(v13) do
                    local value3 = typeof(v14) == "Instance" and v14 or type(v14) == "table" and rawget(v14, "l")

                    if typeof(value3) == "Instance" and value3.Parent == parent then
                        value3.Parent = frame
                    end
                end

                v9 = v12
            end
        end
    else
        tbl4.restoreParticles()
    end
end

tbl4.stop = function(arg)
    if not tbl3.hidup then
        return
    end
    tbl3.hidup = false

    for i, connection in ipairs(tbl3.connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    for k in pairs(tbl3.tasks) do
        if k ~= coroutine.running() then
            pcall(task.cancel, k)
        end
    end

    table.clear(tbl3.tasks)
    tbl4.resetScene()

    if arg and lua and not lua.Unloaded then
        pcall(function()
            lua:Unload()
        end)
    end

    if genv.GBX_STOP == tbl3.stop then
        genv.GBX_STOP = nil
    end

    if genv.MineHubGBX == tbl3.stop then
        genv.MineHubGBX = nil
    end
end

tbl3.stop = function()
    tbl4.stop(true)
end

genv.GBX_STOP = tbl3.stop
genv.MineHubGBX = tbl3.stop

tbl4.method = function(arg, arg2)
    local value = rawget(arg, arg2)
    if value ~= nil then
        return value
    end
    local v5 = getmetatable(arg)
    local value2 = type(v5) == "table" and rawget(v5, "__index")
    local value3 = type(value2) == "table" and rawget(value2, arg2) or nil
    return value3
end

tbl4.nativeCall = function(arg, ...)
    local v5 = table.pack(...)

    local thread = coroutine.create(function()
        if tbl4.setIdentity then
            pcall(tbl4.setIdentity, 2)
        end

        return pcall(arg, table.unpack(v5, 1, v5.n))
    end)

    local v6 = table.pack(coroutine.resume(thread))
    tbl4.elevate()
    if not v6[1] then
        return false, tostring(v6[2])
    end

    if coroutine.status(thread) == "dead" then
        return table.unpack(v6, 2, v6.n)
    end
    pcall(task.cancel, thread)
    return false, "Native call yielded; retry after the game finishes loading"
end

tbl4.inventoryCount = function(arg, arg2)
    local v5 = ipairs
    local value = rawget(arg.inventory, "slots")
    local tbl5 = value or {}

    for k, v6 in v5(tbl5) do
        if rawget(v6, "id") == arg2 then
            local value2 = rawget(v6, "n")
            local n = value2 or 0
            return n
        end
    end

    return 0
end

tbl4.nativeActions = function(arg)
    if arg.nativeActionCache then
        return arg.nativeActionCache
    end
    local actFn = arg.actFn
    local v5 = actFn

    if not actFn then
        local v6 = pairs
        local v7 = tbl4.upvalues(arg.frameFn)
        local tbl5 = v7 or {}

        for k, v8 in v6(tbl5) do
            if type(v8) == "function" and debug.info(v8, "n") == "act" then
                v5 = v8
                arg.actFn = v8
                break
            end
        end
    end

    if not v5 then
        return nil, "Native action signature changed"
    end
    local v6 = tbl4.upvalues(v5)
    if not v6 then
        return nil, "Native action signature changed"
    end

    local function fn4(arg2, arg3)
        for i = 1, 64 do
            if arg2[i] == arg3 then
                return i
            end
        end

        return nil
    end

    local v7 = fn4(v6, arg.world)
    local v8 = v7
    local v9 = fn4(v6, arg.inventory)
    local v10 = v9
    local v11 = fn4(v6, arg.controller)
    local v12 = v11

    if not v7 or not v9 or not v11 then
        local v13 = pairs
        local v14 = tbl4.upvalues(arg.frameFn)
        local tbl5 = v14 or {}

        for k, v15 in v13(tbl5) do
            if type(v15) == "function" and v15 ~= v5 then
                local v16 = tbl4.upvalues(v15)

                if v16 and fn4(v16, arg.world) and fn4(v16, arg.inventory) and fn4(v16, arg.controller) then
                    v5 = v15
                    arg.actFn = v15
                    v6 = v16
                    v8 = fn4(v6, arg.world)
                    v10 = fn4(v6, arg.inventory)
                    v12 = fn4(v6, arg.controller)
                    break
                end
            end
        end
    end

    if v8 and v10 and v12 then
        local n = v8 - 6

        local function fn5(arg2)
            local flag = type(v6[arg2]) == "function" and v6[arg2] or nil
            return flag
        end

        local v13 = fn5(22 + n)
        local v14 = v13 or fn5(22)
        local v15 = fn5(36 + n)
        local v16 = v15 or fn5(36)

        if not v14 or not v16 then
            for i = 1, 64 do
                local v17 = v6[i]

                if type(v17) == "function" and debug.info then
                    local v18 = debug.info(v17, "n")
                    local str2 = v18 or ""

                    if not v14 and str2:lower():find("place") then
                        v14 = v17
                    end

                    if not v16 and str2:lower():find("hit") then
                        v16 = v17
                    end
                end
            end
        end

        if not v14 then
            return nil, "Native tile helpers are unavailable"
        end
        local n2 = v8 - 4
        local n3 = v8 - 3
        local n4 = v8 - 2
        local n5 = v8 - 1
        local v17 = nil

        for i = v10 + 1, 40 do
            if type(v6[i]) == "boolean" and type(v6[i + 1]) == "number" then
                v17 = i
                break
            end
        end

        local n6 = v17 or 16
        local n7 = n6

        local function fn6()
            local v18 = v6[3]
            local flag = type(v6[2]) == "number" and (v18 == nil or typeof(v18) == "Vector2") and type(v6[4]) == "number" and type(v6[5]) == "number" and type(v6[16]) == "boolean" and type(v6[17]) == "number"
            return flag
        end

        if not fn6() then
            n2 = 2
            n3 = 3
            n4 = 4
            n5 = 5
            n7 = 16
            if not fn6() then
                return nil, "Native aim signature changed"
            end
        end

        arg.nativeActionCache = {
            Act = v5,
            Up = v6,
            CanPlace = v14,
            Hit = v16,
            CamXIdx = n2,
            AimIdx = n3,
            TileIdx = n4,
            CamYIdx = n5,
            ReadyIdx = n7,
            TimerIdx = n7 + 1,
            WorldIdx = v8,
            InvIdx = v10,
            CtrlIdx = v12,
        }

        return arg.nativeActionCache
    end

    local tbl5 = {}

    for i = 1, 64 do
        local v13 = v6[i]

        if v13 ~= nil then
            tbl5[#tbl5 + 1] = i .. ":" .. type(v13)
        end
    end

    return nil, "Native action signature changed (world@" .. tostring(v8) .. ", inv@" .. tostring(v10) .. ", ctrl@" .. tostring(v12) .. "; " .. table.concat(tbl5, " ") .. ")"
end

tbl4.protectedTile = function(arg)
    if not arg then
        return true
    end

    for i, v5 in ipairs({"lock", "area", "door", "entrance", "display", "vend"}) do
        if rawget(arg, v5) then
            return true
        end
    end

    return false
end

tbl4.breakTarget = function(arg, arg2, arg3, arg4)
    local v5 = tbl4.tile(rawget(arg.world, "fg"), arg2, arg3)
    local n = v5 or 0

    if arg4 == "Background" then
        local v6 = tbl4.tile(rawget(arg.world, "bg"), arg2, arg3)
        local n2 = v6 or 0
        local str2 = n ~= 0 and n2 ~= 0 and "Foreground blocks background" or nil
        return n2, "bg", str2
    end

    if arg4 ~= "Both" or n ~= 0 then
        return n, "fg"
    end
    local v6 = tbl4.tile(rawget(arg.world, "bg"), arg2, arg3)
    local n2 = v6 or 0
    return n2, "bg"
end

tbl4.inReach = function(arg, arg2, arg3, arg4)
    local v5, v6 = tbl4.coords(arg)
    local controller = arg.controller
    local v7 = controller

    if controller then
        local v8 = rawget
        local controller2 = arg.controller
        local str2 = (arg2 == "Break" or arg2 == "Harvest") and "punchRange" or "buildRange"
        v7 = v8(controller2, str2)
    end

    local n = type(v7) == "function" and v7() or 0
    local flag = v5 ~= nil and v6 ~= nil and math.abs(arg3 + 0.5 - v5) <= n and math.abs(arg4 + 0.5 - (v6 - 0.475)) <= n
    return flag, n
end

tbl4.action = function(arg, arg2, arg3, arg4, arg5, arg6)
    local n = arg5
    if not tbl3.hidup or tbl4.scene() ~= arg then
        return false, "World changed"
    end

    if type(arg3) ~= "number" or type(arg4) ~= "number" then
        return false, "Pick a tile first"
    end
    local world = arg.world
    if arg3 % 1 ~= 0 or arg4 % 1 ~= 0 or arg3 < 0 or arg4 < 0 or rawget(world, "w") <= arg3 or rawget(world, "h") <= arg4 then
        return false, "Tile is outside this world"
    end

    if localPlayer:GetAttribute("Frozen") then
        return false, "Player is frozen"
    end

    if tbl4.isDead(arg) then
        return false, "Waiting for respawn"
    end

    if rawget(world, "ghost") then
        return false, "Leave ghost mode before farming"
    end
    local value = rawget(world, "areas")
    local value2 = value and rawget(value, "mayBuild")
    if type(value2) ~= "function" or not value2(rawget(world, "lock"), arg3, arg4) then
        return false, "No build permission at this tile"
    end
    local controller = arg.controller
    local value3 = controller and rawget(arg.controller, "blocked")
    if type(value3) == "function" and value3() then
        return false, "Close the game's menu first"
    end
    local v5, v6 = tbl4.nativeActions(arg)
    if not v5 then
        return false, v6
    end

    if not tbl4.inReach(arg, arg2, arg3, arg4) then
        return false, "Target is outside native reach"
    end
    local v7 = tbl4.tile(rawget(world, "fg"), arg3, arg4)
    local n2 = v7 or 0

    if arg2 == "Break" then
        local breakTarget = tbl4.breakTarget
        local str2 = arg6 == "bg" and "Background" or "Foreground"
        local v8, v9, v10 = breakTarget(arg, arg3, arg4, str2)
        n2 = v8
        if v10 then
            return false, v10
        end

        if v8 == 0 then
            return false, "Target layer changed"
        end
    end

    if arg2 == "Break" then
        if not tbl4.breakable(n2) then
            return false, "Protected or unsupported tile"
        end
        n = 18
    elseif arg2 == "Harvest" then
        if not tbl4.ripeTree(arg, arg3, arg4) then
            return false, "Tree is still growing"
        end
        n = 18
    elseif arg2 == "Splice" then
        local v8 = tbl4.item(n)
        local v9 = tbl4.item(n2)
        local v10 = tbl4.treeState(arg, arg4 * rawget(world, "w") + arg3)
        if not v8 or rawget(v8, "kind") ~= "seed" or tbl4.inventoryCount(arg, n) < 1 then
            return false, "Splice seed is not in your inventory"
        end

        if not v9 or rawget(v9, "kind") ~= "seed" then
            return false, "Base seed is not planted on this tile"
        end

        if tbl4.ripeTree(arg, arg3, arg4) or v10 and rawget(v10, "s") then
            return false, "This tree cannot be spliced"
        end
    else
        local v8 = tbl4.item(n)
        if not v8 or tbl4.inventoryCount(arg, n) < 1 then
            return false, "Selected item is not in your inventory"
        end
        local value4 = rawget(v8, "kind")
        local flag = arg2 == "Plant"
        local flag2 = value4 == "seed"
        if flag ~= flag2 or arg2 == "Place" and (value4 == "seed" or value4 == "cloth" or value4 == "tool" or value4 == "consumable" or value4 == "gem") and n ~= tbl3.farm.remote or rawget(v8, "lock") or rawget(v8, "area") then
            return false, "Select an ordinary building block"
        end

        if not v5.CanPlace(v8, arg3, arg4) then
            return false, "This tile is not placeable"
        end
    end

    if not debug.setupvalue then
        return false, "Native input binding is unavailable"
    end
    local v8 = tbl4.method(arg.inventory, "select")
    if type(v8) ~= "function" then
        return false, "Inventory selection is unavailable"
    end
    local value4 = rawget(arg.inventory, "selected")
    local getupvalue = debug.getupvalue
    local aimIdx = v5.AimIdx
    local n3 = aimIdx or 3
    local readyIdx = v5.ReadyIdx
    local n4 = readyIdx or 16
    local camXIdx = v5.CamXIdx
    local n5 = camXIdx or 2
    local tileIdx = v5.TileIdx
    local n6 = tileIdx or 4
    local camYIdx = v5.CamYIdx
    local n7 = camYIdx or 5
    local v9 = getupvalue and getupvalue(v5.Act, n3) or v5.Up[n3]
    local v10 = getupvalue and getupvalue(v5.Act, n4)

    if v10 == nil then
        v10 = v5.Up[n4]
    end

    local v11 = getupvalue and getupvalue(v5.Act, n5) or v5.Up[n5]
    local v12 = getupvalue and getupvalue(v5.Act, n6) or v5.Up[n6]
    local v13 = getupvalue and getupvalue(v5.Act, n7) or v5.Up[n7]
    if type(v11) ~= "number" or type(v13) ~= "number" or type(v12) ~= "number" or type(v10) ~= "boolean" then
        return false, "Native aim signature changed"
    end
    local hit = v5.Hit
    local v14 = hit or v5.Up[36]

    local v15, v16 = tbl4.nativeCall(function()
        local ok, result = pcall(function()
            v8(arg.inventory, n)
            arg.world.punchReady = 0
            arg.world.placedAt = nil
            arg.world.actAt = nil
            local value5 = rawget(arg.world, "seedHeld")

            if type(value5) == "table" then
                value5[arg4 * rawget(world, "w") + arg3] = nil
            end

            if type(v14) == "function" then
                pcall(debug.setupvalue, v14, 5, 0)
            end

            debug.setupvalue(v5.Act, n3, Vector2.new((arg3 + 0.5 - v11) * v12, (arg4 + 0.5 - v13) * v12))
            debug.setupvalue(v5.Act, n4, true)
            debug.setupvalue(v5.Act, n4 + 1, 0)
            v5.Act(os.clock())
        end)

        pcall(debug.setupvalue, v5.Act, n3, v9)
        pcall(debug.setupvalue, v5.Act, n4, v10)

        if value4 ~= nil then
            pcall(v8, arg.inventory, value4)
        end

        if not ok then
            error(result, 0)
        end
    end)

    if v15 then
        return true
    end
    pcall(debug.setupvalue, v5.Act, n3, v9)
    pcall(debug.setupvalue, v5.Act, n4, v10)

    if value4 ~= nil then
        tbl4.nativeCall(v8, arg.inventory, value4)
    end

    return false, tostring(v16)
end

tbl4.openGrowScan = function()
    local v5 = tbl4.scene()
    local value = v5 and rawget(v5.world, "growScan")
    local value2 = type(value) == "table" and rawget(value, "open")

    if type(value2) == "function" then
        local n = 0

        for k, item in pairs(tbl2.Items) do
            if type(item) == "table" and rawget(item, "growscan") then
                n = k
                break
            end
        end

        local v6, v7 = tbl4.nativeCall(value2, {
            item = n,
            owner = false,
            blocksPublic = true,
            floatingPublic = true,
        })

        if not v6 and v7 then
            tbl4.notice(v7, "GrowScan")
            return
        end

        if v4 and lua.Toggled then
            v4:Toggle(false)
        end

        return
    end

    tbl4.notice("Enter a world first.")
end

local tbl5 = {
    Players = Color3.fromRGB(80, 170, 255),
    Hidden = Color3.fromRGB(190, 120, 255),
    Floating = Color3.fromRGB(255, 220, 60),
    Trees = Color3.fromRGB(90, 220, 90),
    Providers = Color3.fromRGB(0, 225, 225),
    Doors = Color3.fromRGB(255, 150, 40),
    Locks = Color3.fromRGB(255, 70, 70),
    Displays = Color3.fromRGB(255, 105, 200),
}

tbl4.inView = function(arg, arg2, arg3)
    local value = rawget(arg.world, "view")
    if type(value) ~= "table" or type(rawget(value, 1)) ~= "number" then
        return true
    end
    local flag = value[1] - 2 <= arg2 and value[2] - 2 <= arg3 and arg2 <= value[1] + value[3] + 2 and arg3 <= value[2] + value[4] + 2
    return flag
end

tbl4.overlay = function(arg)
    if not tbl3.overlay or tbl3.overlay.Parent ~= arg.tiles then
        tbl4.clearOverlay()
        local frame = Instance.new("Frame")
        frame.Name = "MineHubESP"
        frame.AutoLocalize = false
        frame.BackgroundTransparency = 1
        frame.Size = UDim2.fromOffset(0, 0)
        frame.ZIndex = 1100
        frame.Parent = arg.tiles
        tbl3.overlay = frame
    end

    return tbl3.overlay
end

tbl4.marker = function(arg, arg2, x, y, arg3, arg4, arg5)
    tbl4.elevate()
    local espLines = tbl3.espLines
    local visible = espLines and tbl3.lineFrom ~= nil
    if tbl3.maxLabels <= #tbl3.markers or not visible and not tbl4.inView(arg, x, y) then
        return
    end
    local n = #tbl3.markers + 1
    local v5 = tbl3.labels[n]
    local v6 = v5

    if not v5 then
        local frame = Instance.new("Frame")
        frame.Name = "Marker"
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0
        frame.ZIndex = 1101
        local uiStroke = Instance.new("UIStroke")
        uiStroke.Thickness = 1
        uiStroke.Transparency = 0.12
        uiStroke.Parent = frame
        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "Label"
        textLabel.AnchorPoint = Vector2.new(0.5, 1)
        textLabel.Position = UDim2.new(0.5, 0, 0, -3)
        textLabel.Size = UDim2.fromOffset(220, 32)
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.BuilderSansBold
        textLabel.TextStrokeTransparency = 0.15
        textLabel.TextTruncate = Enum.TextTruncate.AtEnd
        textLabel.ZIndex = 1102
        textLabel.Parent = frame
        frame.Parent = tbl4.overlay(arg)
        local frame2 = Instance.new("Frame")
        frame2.Name = "Line"
        frame2.AnchorPoint = Vector2.new(0.5, 0.5)
        frame2.BorderSizePixel = 0
        frame2.BackgroundTransparency = 0.25
        frame2.ZIndex = 1100
        frame2.Parent = tbl4.overlay(arg)
        local tbl6 = {Frame = frame, Label = textLabel, Stroke = uiStroke, Line = frame2}
        v6 = tbl6
        tbl3.labels[n] = tbl6
    end

    local v7 = tbl5[arg2]
    v6.Frame.Visible = true
    v6.Frame.Position = UDim2.fromOffset(x * arg.px, y * arg.px)
    local frame = v6.Frame
    local udim2 = UDim2.fromOffset
    local px = arg.px
    local n2 = arg5 or 0.8
    local n3 = px * n2
    local px2 = arg.px
    local n4 = arg5 or 0.8
    frame.Size = udim2(n3, px2 * n4)
    local label = v6.Label
    local str2 = arg4 and arg4 ~= "" and "\n" .. arg4 or ""
    label.Text = arg3 .. str2
    v6.Label.TextSize = tbl3.labelSize
    v6.Label.TextColor3 = v7
    v6.Stroke.Color = v7
    v6.Line.Visible = visible
    v6.Line.BackgroundColor3 = v7
    v6.X = x
    v6.Y = y

    if visible then
        tbl4.placeLine(arg, v6)
    end

    tbl3.markers[n] = v6
end

tbl4.placeLine = function(arg, arg2)
    local n = tbl3.lineFrom.X * arg.px
    local n2 = tbl3.lineFrom.Y * arg.px
    local n3 = arg2.X * arg.px - n
    local n4 = arg2.Y * arg.px - n2
    arg2.Line.Position = UDim2.fromOffset(n + n3 / 2, n2 + n4 / 2)
    arg2.Line.Size = UDim2.fromOffset(math.sqrt(n3 * n3 + n4 * n4), 2)
    arg2.Line.Rotation = math.deg(math.atan2(n4, n3))
end

tbl4.updateLines = function()
    local scene = tbl3.scene
    if not scene or not tbl3.espLines or not tbl3.overlay or not tbl3.overlay.Visible or #tbl3.markers == 0 then
        return
    end
    local now = os.clock()
    local lastLinesAt = tbl3.lastLinesAt
    local n = lastLinesAt or 0
    if now - n < 0.033 then
        return
    end
    local v5, v6 = tbl4.coords(scene)
    if not v5 then
        return
    end

    if tbl3.lastLinePx and math.abs(v5 - tbl3.lastLinePx) < 0.05 and math.abs(v6 - tbl3.lastLinePy) < 0.05 and tbl3.lastMarkerCount == #tbl3.markers then
        return
    end
    tbl3.lastLinesAt = now
    tbl3.lastLinePx = v5
    tbl3.lastLinePy = v6
    tbl3.lastMarkerCount = #tbl3.markers
    tbl3.lineFrom = {X = v5, Y = v6 - 0.5}

    for i, marker in ipairs(tbl3.markers) do
        if marker.Line.Visible then
            tbl4.placeLine(scene, marker)
        end
    end
end

tbl4.treeState = function(arg, arg2)
    local treeStates = arg.treeStates
    local value = treeStates and rawget(arg.treeStates, arg2)
    local flag = type(value) == "table" and value or nil
    return flag
end

tbl4.drawESP = function(arg)
    table.clear(tbl3.markers)
    local fruit = tbl3.fruit
    local doorInfo = fruit or tbl3.doorInfo

    for k, v5 in pairs(tbl3.esp) do
        local v6 = doorInfo or v5
        doorInfo = v6
    end

    if arg and doorInfo then
        tbl4.overlay(arg).Visible = true
        local v5, v6 = tbl4.coords(arg)
        local v7 = v5

        if v5 then
            local tbl6 = {}
            v7 = tbl6
            tbl6.X = v5
            tbl6.Y = v6 - 0.5
        end

        if not v7 then
            v7 = nil
        end

        tbl3.lineFrom = v7
        local world = arg.world
        local value = rawget(arg.world, "w")
        local value2 = rawget(arg.world, "h")

        if arg.others and tbl3.esp.Players then
            local value3 = rawget(arg.others, "where")
            local value4 = rawget(arg.others, "list")
            local v8 = ipairs
            local tbl6 = type(value4) == "function" and value4() or {}

            for k, v9 in v8(tbl6) do
                local playerByUserId = tbl.Players:GetPlayerByUserId(v9[1])
                local flag = playerByUserId and (playerByUserId:GetAttribute("Ghost") == true or playerByUserId:GetAttribute("Invisible") == true)
                local v10, v11 = value3(v9[1])

                if type(v10) == "number" and type(v11) == "number" then
                    local marker = tbl4.marker
                    local str2 = flag and "Hidden" or "Players"
                    local n = v11 - 0.5
                    local str3 = tostring(v9[2])
                    local str4 = flag and "Ghost / Invisible" or "Player"
                    marker(arg, str2, v10, n, str3, str4, 0.65)
                end
            end
        end

        if tbl3.esp.Floating then
            local value3 = rawget(world, "dropList")
            local v8 = ipairs
            local tbl6 = type(value3) == "function" and value3() or {}

            for k, v9 in v8(tbl6) do
                local value4 = rawget(v9, "id")
                local value5 = rawget(v9, "n")
                local value6 = rawget(v9, "x")
                local value7 = rawget(v9, "y")

                if not rawget(v9, "pending") and not rawget(v9, "display") and type(value5) == "number" and value5 > 0 and type(value6) == "number" and type(value7) == "number" then
                    local marker = tbl4.marker
                    local str2 = value4 == 112 and "Gems" or tbl4.itemName(value4)
                    marker(arg, "Floating", value6, value7, str2, "x" .. value5, 0.5)
                end
            end
        end

        local value3 = rawget(world, "view")
        local n = 0
        local n2 = 0
        local n3 = value - 1
        local n4 = n3
        local n5 = value2 - 1
        local n6 = n5

        if type(value3) == "table" and type(rawget(value3, 1)) == "number" then
            n = math.max(0, math.floor(value3[1]) - 2)
            n2 = math.max(0, math.floor(value3[2]) - 2)
            n4 = math.min(n3, math.ceil(value3[1] + value3[3]) + 2)
            n6 = math.min(n5, math.ceil(value3[2] + value3[4]) + 2)
        end

        local now = os.clock()
        local n7 = 0
        local n8 = n2 - 1
        local n9 = n6 + 0
        local n10, n11, v8, v9, str2, str3, v10, fruit2, value4, value5, n12, str4, str5, value6, str6, value7, value8, value9, flag, v11, value10, value11, value12, flag2, v12, value13, str7, marker, n13, n14, itemName, flag3

        repeat
            n10 = n8 + 1
            if n10 > n9 then
                break
            end

            for i = n, n4 do
                n11 = n7 + 1
                n7 = n11
                if tbl3.maxLabels <= #tbl3.markers or n11 > 3000 or os.clock() - now > 0.007 then
                    break
                end
                v8 = tbl4.tile(rawget(world, "fg"), i, n10)
                v9 = tbl4.item(v8)

                if v9 then
                    str2 = nil
                    str3 = nil

                    if rawget(v9, "kind") == "seed" and (tbl3.esp.Trees or tbl3.fruit) then
                        str2 = "Trees"
                        v10 = tbl4.treeState(arg, n10 * value + i)
                        fruit2 = v10 and rawget(v10, "f")
                        value4 = v10 and rawget(v10, "p")
                        value5 = rawget(v9, "grow")

                        if tbl3.fruit and type(fruit2) == "number" then
                            str3 = "Fruit: " .. fruit2
                        end

                        if type(value4) == "number" and type(value5) == "number" then
                            n12 = math.max(0, math.ceil(value4 + value5 - workspace:GetServerTimeNow()))
                            str4 = str3 and str3 .. " | " or ""
                            str5 = n12 == 0 and "Ready" or n12 .. "s"
                            str3 = str4 .. str5
                        end
                    elseif rawget(v9, "provider") and tbl3.esp.Providers then
                        str2 = "Providers"
                        value6 = rawget(world, "providerStage")
                        str6 = type(value6) == "function" and (value6(i, n10) == 2 and "Ready" or "Growing") or nil
                        str3 = str6
                    elseif (rawget(v9, "lock") or rawget(v9, "area")) and tbl3.esp.Locks then
                        str2 = "Locks"
                        value7 = rawget(v9, "lock")
                        value8 = value7 and rawget(world, "lock")
                        value9 = rawget(world, "areas")

                        if not value8 and value9 and type(rawget(value9, "lockAt")) == "function" then
                            value8 = value9.lockAt(i, n10)
                        end

                        flag = type(value8) == "table"

                        if flag then
                            v11 = tostring
                            value10 = rawget(value8, "ownerName")
                            value11 = value10 or rawget(value8, "owner")
                            flag = v11(value11)
                        end

                        if not flag then
                            flag = nil
                        end

                        str3 = flag
                    elseif (rawget(v9, "door") or rawget(v9, "entrance")) and (tbl3.esp.Doors or tbl3.doorInfo) then
                        str2 = "Doors"
                        value12 = rawget(world, "doors")
                        flag2 = value12 and type(rawget(value12, "get")) == "function" and value12.get(i, n10)

                        if tbl3.doorInfo and type(flag2) == "table" then
                            v12 = tostring
                            value13 = rawget(flag2, "label")
                            str7 = value13 or rawget(flag2, "name") or "Door"
                            str3 = v12(str7)
                        end
                    elseif rawget(v9, "display") and tbl3.esp.Displays then
                        str2 = "Displays"
                    end

                    if str2 then
                        marker = tbl4.marker
                        n13 = i + 0.5
                        n14 = n10 + 0.5
                        itemName = tbl4.itemName
                        flag3 = str2 == "Trees"
                        marker(arg, str2, n13, n14, itemName(v8, flag3), str3)
                    end
                end
            end

            n8 = n10
        until tbl3.maxLabels <= #tbl3.markers or n7 > 6000 or os.clock() - now > 0.012

        for i = #tbl3.markers + 1, #tbl3.labels do
            tbl3.labels[i].Frame.Visible = false
            tbl3.labels[i].Line.Visible = false
        end

        return
    end

    if tbl3.overlay then
        tbl3.overlay.Visible = false
    end
end

tbl4.safeLanding = function(arg, arg2, arg3, arg4, arg5)
    local world = arg.world
    if arg2 < 0 or arg3 < 0 or rawget(world, "w") <= arg2 or rawget(world, "h") <= arg3 + 1 then
        return false
    end
    local item = tbl4.item
    local v5 = tbl4.tile(rawget(world, "fg"), arg2, arg3)
    local n = v5 or 0
    local v6 = item(n)
    local item2 = tbl4.item
    local v7 = tbl4.tile(rawget(world, "fg"), arg2, arg3 + 1)
    local n2 = v7 or 0
    local v8 = item2(n2)
    if v6 and (rawget(v6, "solid") or rawget(v6, "platform") or rawget(v6, "combiner") or rawget(v6, "vip") or tbl4.protectedTile(v6) or rawget(v6, "hurts") or rawget(v6, "deadly")) then
        return false
    end

    if not v8 or not rawget(v8, "solid") and not rawget(v8, "platform") or tbl4.protectedTile(v8) then
        return false
    end

    if rawget(v8, "hurts") or rawget(v8, "deadly") or rawget(v8, "bouncy") or rawget(v8, "slippery") or rawget(v8, "combiner") or rawget(v8, "vip") then
        return false
    end

    if (arg5 == "Place" or arg5 == "Plant") and arg4 and arg4.X == arg2 and arg4.Y == arg3 then
        return false
    end

    if arg5 == "Break" and arg4 and arg4.X == arg2 and arg4.Y == arg3 + 1 then
        return false
    end

    if arg5 == "Break" and tbl3.farm and tbl3.farm.template == "Auto DF" and (arg2 <= 0 or not tbl4.openCell(arg, arg2 - 1, arg3)) and (rawget(world, "w") <= arg2 + 1 or not tbl4.openCell(arg, arg2 + 1, arg3)) and (arg3 <= 0 or not tbl4.openCell(arg, arg2, arg3 - 1)) then
        return false
    end
    return true
end

tbl4.findLanding = function(arg, arg2, arg3)
    local v5, v6 = tbl4.inReach(arg, arg3, arg2.X, arg2.Y)
    local v7, v8 = tbl4.coords(arg)
    if not v7 or v6 < 1 then
        return nil
    end
    local farm = tbl3.farm
    local flag = farm.template == "Auto DF"
    local tbl6 = {}
    local n = #farm.targets

    for i = 0, math.min(n, 16) - 1 do
        local n2 = (farm.index + i - 1) % n + 1
        local v9 = farm.records[n2]

        if not v9 or not v9.done then
            tbl6[#tbl6 + 1] = farm.targets[n2]
        end
    end

    local flag2 = arg3 == "Place" or arg3 == "Plant"
    local n2 = math.min(4, math.floor(v6))
    local tbl7 = {}
    local n3 = arg2.Y - n2 - 1
    local n4 = arg2.Y + n2 + 0

    while true do
        local n5 = n3 + 1
        if n5 > n4 then
            break
        end
        n3 = n5

        if not flag or math.abs(arg2.Y - n5) <= 1 then
            local v9 = n4
            local v10 = n5
            local n6 = arg2.X - n2 - 1
            local n7 = arg2.X + n2 + 0

            while true do
                local n8 = n6 + 1
                if n8 > n7 then
                    break
                end
                n6 = n8

                if math.abs(arg2.X - n8) <= v6 and math.abs(arg2.Y + 0.5 - (n5 + 0.525)) <= v6 and tbl4.safeLanding(arg, n8, n5, arg2, arg3) then
                    local n9 = 0

                    if math.abs(arg2.Y - n5) <= 1 then
                        for i, v11 in ipairs(tbl6) do
                            if v6 < math.abs(v11.X - n8) or math.abs(v11.Y - n5) > 1 or v6 < math.abs(v11.Y + 0.5 - (n5 + 0.525)) or flag2 and v11.X == n8 and v11.Y == n5 then
                                break
                            end
                            n9 = n9 + 1
                        end

                        n6 = n8
                    end

                    local n10 = math.abs(arg2.Y - n5) > 1 and 20000 or flag and arg3 == "Place" and (n5 == arg2.Y + 1 and 0 or n5 == arg2.Y and 200 or 5000) or math.abs(arg2.Y - n5) * 50

                    tbl7[#tbl7 + 1] = {
                        X = n8,
                        Y = n5,
                        Cost = (n8 + 0.5 - v7) ^ 2 + (n5 + 1 - v8) ^ 2 + n10 - n9 * 1000,
                    }
                end
            end

            n3 = v10
            n4 = v9
        end
    end

    table.sort(tbl7, function(arg4, arg5)
        local flag3 = arg4.Cost < arg5.Cost
        return flag3
    end)

    local flag3 = #tbl7 > 0 and tbl7 or nil
    return flag3
end

tbl4.lastMoveSend = function(arg)
    local sendState = arg.sendState
    local v5 = sendState

    if not sendState then
        local upvalues = tbl4.upvalues
        local others = arg.others
        local value = others and rawget(arg.others, "update")
        local v6 = upvalues(value)
        local v7 = v6 and v6[1]
        v5 = v7
        if type(v5) ~= "function" or debug.info(v5, "n") ~= "sendState" then
            return nil
        end
        arg.sendState = v5
    end

    if not debug.getupvalue then
        local v6 = tbl4.upvalues(v5)
        local flag = v6 and type(v6[2]) == "number" and v6[2] or nil
        return flag
    end

    local v6 = debug.getupvalue(v5, 2)
    local flag = type(v6) == "number" and v6 or nil
    return flag
end

tbl4.facing = function(arg)
    local stateOwner = arg.stateOwner
    local v5 = stateOwner

    if not stateOwner then
        local sendState = arg.sendState
        local v6 = sendState and tbl4.upvalues(sendState)
        local stateOwner2 = v6 and type(v6[1]) == "table" and v6[1] or nil
        v5 = stateOwner2
        arg.stateOwner = stateOwner2
    end

    local value = v5 and rawget(v5, "state")

    if type(value) == "function" and debug.getupvalue then
        local v6 = debug.getupvalue(value, 1)
        local v7 = debug.getupvalue(value, 7)
        if v6 == arg.world and (v7 == 1 or v7 == -1) then
            return v7, value
        end
    end

    local v6 = tbl4.upvalues(value)
    if v6 and v6[1] == arg.world and (v6[7] == 1 or v6[7] == -1) then
        return v6[7], value
    end
    return nil
end

tbl4.pushPosition = function(arg)
    local v5, v6 = tbl4.facing(arg)

    if v5 then
        debug.setupvalue(v6, 7, -v5)
    end
end

tbl4.settle = function(arg, arg2)
    local farm = tbl3.farm
    local travel = farm.travel
    if not travel then
        return true
    end
    local v5 = tbl4.lastMoveSend(arg)
    if not v5 then
        return nil, "Native position sync changed"
    end

    if arg2 < travel.Until and (v5 <= travel.Sent or arg2 < v5 + travel.Margin) then
        return false, "Syncing position"
    end
    local v6, v7 = tbl4.coords(arg)
    if v6 and math.abs(v6 - travel.X) <= 0.4 and math.abs(v7 - travel.Y) <= 0.4 then
        farm.travel = nil
        return true
    end

    if arg2 < travel.Until then
        return false, "Landing"
    end
    farm.travel = nil
    return nil, "Teleport was moved or rejected"
end

tbl4.hop = function(arg, arg2, arg3, arg4, arg5)
    local farm = tbl3.farm
    local world = arg.world
    local value = rawget(world, "goTo")
    if type(value) ~= "function" then
        return nil, "Native teleport signature changed"
    end

    if debug.getupvalue then
        local v5 = debug.getupvalue(value, 1)
        local v6 = debug.getupvalue(value, 2)
        if debug.getupvalue(value, 3) ~= world or type(v5) ~= "number" or type(v6) ~= "number" then
            return nil, "Native teleport signature changed"
        end
    else
        local v5 = tbl4.upvalues(value)
        if not v5 or v5[3] ~= world or type(v5[1]) ~= "number" or type(v5[2]) ~= "number" then
            return nil, "Native teleport signature changed"
        end
    end

    local v5 = tbl4.lastMoveSend(arg)
    if not v5 then
        return nil, "Native position sync changed"
    end

    if arg5 - v5 > 3 then
        return nil, "Game stopped sending your position; rejoin before farming"
    end

    if not farm.route then
        local v6, v7 = arg4()
        local v8 = v7
        if not v6 then
            return "skip", v7
        end
        local v9 = nil
        local n = math.min(#v6, 5) + 0
        local n2 = 0
        local n3, v10, v11

        repeat
            n3 = n2 + 1
            if n3 > n then
                break
            end
            n2 = n3
            v10, v11 = tbl4.teleportRoute(arg, v6[n3], arg2, arg3)
            v9 = v10
            v8 = v11
        until v10

        if not v9 then
            return "skip", v8
        end
        farm.route = v9
        farm.routeIndex = 1
    end

    local v6 = farm.route[farm.routeIndex]
    if not v6 then
        farm.route = nil
        return false, "Updating route"
    end

    if not tbl4.safeLanding(arg, v6.X, v6.Y, arg2, arg3) then
        farm.route = nil
        return false, "Landing changed; updating route"
    end
    local v7, v8 = tbl4.coords(arg)
    local dropY = v6.DropY
    local y = dropY or v6.Y
    local v9 = v7 and math.sqrt((v6.X + 0.5 - v7) ^ 2 + (y + 1 - v8) ^ 2)
    if not v9 then
        farm.route = nil
        return false, "Position changed; updating route"
    end

    if not v6.DropY then
        local flag = farm.routeIndex == #farm.route
        local n = arg2 and ((arg3 == "Place" or arg3 == "Plant") and 0.2 or flag and 0.4) or 0.7
        local flag2 = math.abs(v8 - v6.Y - 1) < 0.05
        if flag2 and math.abs(v7 - v6.X - 0.5) <= n then
            farm.routeIndex = farm.routeIndex + 1
            return false, "Running"
        end
        local v10 = tbl4.runDirection(arg, v6, "Collect", v7, v8, arg5, n)
        if v10 then
            tbl4.setWalk(arg, v10)
            return false, "Running"
        end

        if flag2 and math.abs(v7 - v6.X - 0.5) <= 1.2 then
            tbl4.nudge(arg, v6.X + 0.5, v7)
            return false, "Running"
        end
    end

    tbl4.setWalk(arg, nil)
    if v9 > 4.5 then
        farm.route = nil
        return false, "Position changed; updating route"
    end

    if arg5 - v5 < v9 / 5 then
        return false, "Pacing teleport"
    end
    local v10, v11 = tbl4.nativeCall(value, v6.X, y)
    if not v10 then
        return nil, tostring(v11)
    end
    tbl4.pushPosition(arg)

    farm.travel = {
        X = v6.X + 0.5,
        Y = v6.Y + 1,
        Sent = v5,
        Margin = math.clamp(localPlayer:GetNetworkPing() * 2, 0.08, 0.3),
        Until = arg5 + 1.5 + (v6.Y - y) * 0.2,
    }

    farm.teleports = farm.teleports + 1
    farm.routeIndex = farm.routeIndex + 1
    return false, "Teleporting"
end

tbl4.inputControls = function(arg)
    if arg.controls then
        return arg.controls
    end
    local v5 = pairs
    local v6 = tbl4.upvalues(arg.frameFn)
    local tbl6 = v6 or {}

    for k, v7 in v5(tbl6) do
        if type(v7) == "table" and type(rawget(v7, "dir")) == "function" and type(rawget(v7, "jumping")) == "function" then
            arg.controls = v7
            return v7
        end
    end

    return nil
end

tbl4.restoreWalk = function()
    tbl3.walkDir = nil
    tbl3.walkSince = nil
    local walkHook = tbl3.walkHook
    tbl3.walkHook = nil

    if walkHook and rawget(walkHook.Controls, "dir") == walkHook.Wrapped then
        walkHook.Controls.dir = walkHook.Original
    end

    if walkHook and rawget(walkHook.Controls, "jumping") == walkHook.WrappedJump then
        walkHook.Controls.jumping = walkHook.OriginalJump
    end
end

tbl4.setWalk = function(arg, walkDir, arg2)
    if walkDir and not tbl3.walkHook then
        local v5 = tbl4.inputControls(arg)
        if not v5 then
            return false
        end
        local value = rawget(v5, "dir")
        local value2 = rawget(v5, "jumping")

        local function dir(...)
            if tbl3.walkDir and tbl3.hidup and os.clock() - tbl3.walkAt < 0.15 then
                return tbl3.walkDir
            end
            return value(...)
        end

        local function jumping(...)
            if tbl3.walkJump and tbl3.hidup and os.clock() - tbl3.walkAt < 0.15 then
                return true
            end
            return value2(...)
        end

        v5.dir = dir
        v5.jumping = jumping

        tbl3.walkHook = {
            Controls = v5,
            Original = value,
            Wrapped = dir,
            OriginalJump = value2,
            WrappedJump = jumping,
        }
    end

    if walkDir ~= tbl3.walkDir then
        local now = walkDir and os.clock() or nil
        tbl3.walkSince = now
        tbl3.walkX = nil
    end

    local now = os.clock()
    local v5 = walkDir and arg2 or nil
    tbl3.walkDir = walkDir
    tbl3.walkAt = now
    tbl3.walkJump = v5
    return true
end

tbl4.runDirection = function(arg, arg2, arg3, walkX, arg4, walkSince, arg5)
    local n = math.floor(walkX)
    local n2 = math.floor(arg4 - 0.001)
    if math.abs(arg4 - n2 - 1) > 0.05 or arg2.X == n or arg5 and math.abs(walkX - arg2.X - 0.5) <= arg5 then
        return nil
    end

    if arg5 and arg2.Y ~= n2 or not arg5 and math.abs(arg2.Y - n2) > 2 then
        return nil
    end
    local walkBlockedUntil = tbl3.walkBlockedUntil
    local n3 = walkBlockedUntil or 0
    if walkSince < n3 then
        return nil
    end

    if tbl3.walkDir and tbl3.walkSince then
        if tbl3.walkX and math.abs(walkX - tbl3.walkX) < 0.5 then
            if walkSince - tbl3.walkSince > 1.5 then
                tbl3.walkBlockedUntil = walkSince + 3
                return nil
            end
        else
            tbl3.walkX = walkX
            tbl3.walkSince = walkSince
        end
    end

    if not tbl4.inputControls(arg) then
        return nil
    end
    local n4 = n < arg2.X and 1 or -1
    local n5 = n + n4
    local x = arg5 and arg2.X or arg2.X - n4
    local n6 = n4 + 0
    local n7 = x + 0
    local n8 = n5 - n6
    local n9, v5

    repeat
        n9 = n8 + n6

        if n6 <= 0 then
            if n7 > n9 then
                return n4
            end
            v5 = n9
            n8 = n9
        else
            if n9 > n7 then
                return n4
            end
            v5 = n9
            n8 = n9
        end
    until not tbl4.safeLanding(arg, v5, n2, arg2, arg3)

    return nil
end

tbl4.nudge = function(arg, arg2, arg3)
    local n = arg2 - arg3
    local setWalk = tbl4.setWalk
    local flag = math.abs(n) > 0.5

    if not flag then
        if tbl3.walkDir then
            flag = false
        else
            flag = true
        end
    end

    if flag then
        flag = n > 0 and 1 or -1
    end

    if not flag then
        flag = nil
    end

    setWalk(arg, flag)
end

tbl4.climbOut = function(arg, arg2, arg3, arg4)
    local n = arg3 and math.floor(arg3)
    local n2 = arg4 and math.floor(arg4 - 0.001)
    if not arg3 or math.abs(arg4 - n2 - 1) >= 0.05 or not tbl4.openCell(arg, n, n2 - 1) or arg2.X == n then
        return false
    end
    local flag

    if tbl4.openCell(arg, n - 1, n2) then
        flag = false
    else
        flag = true
    end

    if not flag then
        local v5 = tbl4.openCell(arg, n - 1, n2 - 1)
        flag = v5

        if v5 then
            if tbl4.openCell(arg, n - 2, n2) then
                flag = false
            else
                flag = true
            end
        end
    end

    local flag2

    if tbl4.openCell(arg, n + 1, n2) then
        flag2 = false
    else
        flag2 = true
    end

    if not flag2 then
        local v5 = tbl4.openCell(arg, n + 1, n2 - 1)
        flag2 = v5

        if v5 then
            if tbl4.openCell(arg, n + 2, n2) then
                flag2 = false
            else
                flag2 = true
            end
        end
    end

    if not flag or not flag2 then
        return false
    end
    tbl3.farm.route = nil
    local setWalk = tbl4.setWalk
    local n3 = n < arg2.X and 1 or -1
    setWalk(arg, n3, true)
    return true
end

tbl4.approach = function(arg, arg2, arg3)
    local now = os.clock()
    local v5, v6 = tbl4.settle(arg, now)
    if v5 ~= true then
        return v5, v6
    end
    local v7, v8 = tbl4.coords(arg)
    local flag = (arg3 == "Place" or arg3 == "Plant") and v7 and v7 - 0.3 < arg2.X + 1 and arg2.X < v7 + 0.3 and v8 - 0.95 < arg2.Y + 1 and arg2.Y < v8

    if v7 then
        math.floor(v7)
    end

    local n = v8 and math.floor(v8 - 0.001)
    local flag2 = (arg3 == "Harvest" or arg3 == "Plant") and n ~= arg2.Y
    local flag3 = false
    local flag4

    if flag2 then
        flag4 = false
    else
        flag4 = true
    end

    if flag4 then
        flag4 = n
    end

    if flag4 then
        flag4 = math.abs(n - arg2.Y) > 1
    end

    local flag5 = false

    if flag2 then
        for i = arg2.X - 2, arg2.X + 2 do
            if tbl4.safeLanding(arg, i, arg2.Y, arg2, arg3) then
                flag5 = true
                break
            end
            continue
        end
    elseif tbl3.farm.template == "Auto DF" and arg3 == "Place" and n and n ~= arg2.Y + 1 then
        for i = arg2.X - 2, arg2.X + 2 do
            if tbl4.safeLanding(arg, i, arg2.Y + 1, arg2, arg3) then
                flag3 = true
                flag5 = true
                break
            end

            continue
        end
    end

    if not flag5 and flag4 then
        if tbl3.farm.template == "Auto DF" then
            flag5 = true
        else
            local n2 = arg2.Y - 1 - 1
            local n3 = arg2.Y + 1 + 0
            local n4

            repeat
                n4 = n2 + 1
                if n4 > n3 then
                    break
                end

                for i = arg2.X - 2, arg2.X + 2 do
                    if tbl4.safeLanding(arg, i, n4, arg2, arg3) then
                        flag5 = true
                        break
                    end
                    continue
                end

                n2 = n4
            until flag5
        end
    end

    if tbl4.inReach(arg, arg3, arg2.X, arg2.Y) and not flag and not flag5 then
        tbl3.farm.route = nil
        tbl4.setWalk(arg, nil)
        return true
    end

    local flag6

    if flag5 then
        flag6 = false
    else
        flag6 = true
    end

    if flag6 then
        flag6 = tbl4.runDirection(arg, arg2, arg3, v7, v8, now)
    end

    if not flag6 then
        if flag and math.abs(v8 - n - 1) < 0.05 then
            for i, v9 in ipairs({-1, 1}) do
                local n2 = arg2.X + v9

                if tbl4.safeLanding(arg, n2, n, arg2, arg3) then
                    tbl3.farm.route = nil
                    tbl4.nudge(arg, n2 + 0.5, v7)
                    return false, "Running"
                end

                continue
            end
        end

        tbl4.setWalk(arg, nil)

        if not tbl4.climbOut(arg, arg2, v7, v8) then
            return tbl4.hop(arg, arg2, arg3, function()
                local v9 = tbl4.findLanding(arg, arg2, arg3)
                local v10 = v9

                if flag5 and v9 then
                    local tbl6 = {}

                    for i, v11 in ipairs(v9) do
                        if flag2 and v11.Y == arg2.Y or flag3 and v11.Y == arg2.Y + 1 or not flag2 and not flag3 and math.abs(v11.Y - arg2.Y) <= 1 then
                            tbl6[#tbl6 + 1] = v11
                        end
                    end

                    if #tbl6 > 0 then
                        v10 = tbl6
                    end
                end

                return v10, "No safe landing near this tile"
            end, now)
        end

        return false, "Climbing out"
    end

    tbl3.farm.route = nil
    tbl4.setWalk(arg, flag6)
    return false, "Running"
end

local tbl6 = {{-0.1, -0.1}, {0.1, -0.1}, {-0.1, 0.1}, {0.1, 0.1}}

tbl4.clearPath = function(arg, arg2, arg3, arg4, arg5)
    local value = rawget(arg.world, "fg")
    local v5 = math.ceil(math.max(math.abs(arg4 - arg2), math.abs(arg5 - arg3)) * 8)

    for i = 1, v5 - 1 do
        local n = i / v5
        local n2 = arg2 + 0.5 + (arg4 - arg2) * n
        local n3 = arg3 + 0.5 + (arg5 - arg3) * n

        for i2, v6 in ipairs(tbl6) do
            local item = tbl4.item
            local v7 = tbl4.tile(value, math.floor(n2 + v6[1]), math.floor(n3 + v6[2]))
            local n4 = v7 or 0
            local v8 = item(n4)
            if v8 and (rawget(v8, "solid") or rawget(v8, "platform")) then
                return false
            end
        end
    end

    return true
end

tbl4.openCell = function(arg, arg2, arg3)
    local item = tbl4.item
    local v5 = tbl4.tile(rawget(arg.world, "fg"), arg2, arg3)
    local n = v5 or 0
    local v6 = item(n)
    local flag

    if v6 then
        flag = false
    else
        flag = true
    end

    if not flag then
        local value = rawget(v6, "solid")
        local value2 = value or rawget(v6, "platform") or rawget(v6, "combiner") or rawget(v6, "vip") or tbl4.protectedTile(v6) or rawget(v6, "hurts") or rawget(v6, "deadly")

        if value2 then
            flag = false
        else
            flag = true
        end
    end

    return flag
end

tbl4.fallTo = function(arg, arg2, arg3, arg4, arg5)
    if not tbl4.openCell(arg, arg2, arg3) then
        return nil
    end

    for i = arg3 + 1, math.min(arg3 + 6, rawget(arg.world, "h") - 2) do
        if not tbl4.openCell(arg, arg2, i) then
            return nil
        end

        if tbl4.safeLanding(arg, arg2, i, arg4, arg5) then
            return i
        end
    end

    return nil
end

tbl4.teleportRoute = function(arg, arg2, arg3, arg4)
    local world = arg.world
    local value = rawget(world, "w")
    local value2 = rawget(world, "h")
    local value3 = rawget(world, "name")
    local v5, v6 = tbl4.coords(arg)
    if not v5 then
        return nil, "Player position unavailable"
    end
    local n = math.floor(v5)
    local n2 = math.floor(v6 - 0.001)
    if n < 0 or n2 < 0 or value <= n or value2 <= n2 then
        return nil, "Player is outside this world"
    end
    local n3 = n2 * value + n
    local n4 = arg2.Y * value + arg2.X
    if n3 == n4 and math.abs(v5 - arg2.X - 0.5) > 0.2 then
        return {{X = arg2.X, Y = arg2.Y}}
    end
    local tbl7 = {{X = n, Y = n2, Key = n3}}
    local tbl8 = {}
    tbl8[n3] = true
    local tbl9 = {}
    local n5 = 1
    local tbl10 = {}
    local tbl11 = {}
    local n6 = os.clock() + 0.35

    while n5 <= #tbl7 and n5 <= 2048 and os.clock() < n6 do
        if not tbl3.hidup or rawget(world, "name") ~= value3 then
            return nil, "World changed during route planning"
        end
        local v7 = tbl7[n5]

        if v7.Key == n4 then
            local tbl12 = {}
            local v8 = v7

            while v8 and v8.Key ~= n3 and #tbl12 < 128 do
                tbl12[#tbl12 + 1] = {X = v8.X, Y = v8.Y, DropY = v8.DropY}
                v8 = tbl9[v8.Key]
            end

            if not v8 or v8.Key ~= n3 then
                return nil, "Teleport route is too long"
            end
            local tbl13 = {}

            for i = #tbl12, 1, -1 do
                tbl13[#tbl13 + 1] = tbl12[i]
            end

            if #tbl13 == 0 then
                return nil, "No separate landing for this target"
            end
            return tbl13
        end

        for i = -4, 4 do
            for i2 = -4, 4 do
                if i2 * i2 + i * i <= 16 and (i2 ~= 0 or i ~= 0) then
                    local n7 = v7.X + i2
                    local n8 = v7.Y + i

                    if n7 >= 0 and n8 >= 0 and value > n7 and value2 > n8 then
                        local n9 = n8 * value + n7

                        if not tbl8[n9] then
                            local v8 = tbl10[n9]
                            local v9 = v8

                            if v8 == nil then
                                local v10 = tbl4.safeLanding(arg, n7, n8, arg3, arg4)
                                v9 = v10
                                tbl10[n9] = v10
                            end

                            if v9 then
                                if tbl4.clearPath(arg, v7.X, v7.Y, n7, n8) then
                                    tbl8[n9] = true
                                    tbl7[#tbl7 + 1] = {X = n7, Y = n8, Key = n9}
                                    tbl9[n9] = v7
                                end
                            else
                                tbl8[n9] = true
                                local v10 = tbl11[n9]
                                local v11 = v10

                                if v10 == nil then
                                    local v12 = tbl4.fallTo(arg, n7, n8, arg3, arg4)
                                    local flag = v12 or false
                                    v11 = flag
                                    tbl11[n9] = flag
                                end

                                local n10 = v11 and v11 * value + n7

                                if n10 and not tbl8[n10] and tbl4.clearPath(arg, v7.X, v7.Y, n7, n8) then
                                    tbl8[n10] = true
                                    tbl7[#tbl7 + 1] = {X = n7, Y = v11, Key = n10, DropY = n8}
                                    tbl9[n10] = v7
                                end
                            end
                        end
                    end
                end
            end
        end

        n5 = n5 + 1
    end

    return nil, "No supported teleport route; target skipped"
end

tbl3.farm = {
    enabled = false,
    template = "Auto Clear World",
    breakLayer = "Both",
    dirt = 2,
    seed = 3,
    door = 6,
    remote = 5640,
    phase = "Plant",
    interval = 0.015,
    targets = {},
    records = {},
    skip = {},
    index = 1,
    message = "Stopped",
    completed = 0,
    skipped = 0,
    actions = 0,
    teleports = 0,
    left = 0,
    autoRecycle = false,
    pnbOffsets = {{DX = 1, DY = 0}, {DX = 2, DY = 0}},
}

tbl3.factory = {
    enabled = false,
    seed = 3,
    activeSeed = nil,
    spliceRecipe = nil,
    autoSplice = true,
    phase = "Plant",
    cycles = 0,
    message = "Stopped",
    breakX = nil,
    breakY = nil,
    autoBreakX = nil,
    autoBreakY = nil,
    breakOffsets = {{DX = 1, DY = 0}, {DX = 2, DY = 0}},
    allSeeds = nil,
    seedMapping = nil,
}

tbl4.factoryStop = function(arg, arg2)
    local factory = tbl3.factory
    local farm = tbl3.farm
    factory.enabled = false
    farm.travel = nil
    farm.route = nil
    farm.waitUntil = nil
    tbl3.walkDir = nil
    tbl3.walkSince = nil

    if tbl3.collect then
        tbl3.collect.drop = nil
    end

    if not arg2 and tbl3.controls.FactoryEnabled and tbl3.flags.FactoryEnabled ~= false then
        tbl4.set("FactoryEnabled", false)
    end

    local message = arg or "Stopped"
    factory.message = message
end

tbl4.factoryReset = function(arg, arg2)
    tbl4.factoryStop(arg, arg2)
    local factory = tbl3.factory
    local farm = tbl3.farm
    factory.activeSeed = nil
    factory.spliceRecipe = nil
    factory.phase = "Plant"
    factory.autoBreakX = nil
    factory.autoBreakY = nil
    farm.targets = {}
    farm.records = {}
    farm.skip = {}
    farm.index = 1
    farm.left = 0
    farm.completed = 0
    farm.skipped = 0
    farm.batchSize = 0
    farm.pnbTarget = nil
    farm.pnbDropSince = nil
    farm.pnbPlaced = nil
    farm.pnbRemoteBlock = nil
    farm.pnbStage = "Place"
end

tbl4.farmStop = function(arg, arg2)
    local farm = tbl3.farm
    farm.enabled = false
    farm.travel = nil
    farm.route = nil
    farm.waitUntil = nil
    tbl3.walkDir = nil
    tbl3.walkSince = nil

    if tbl3.collect then
        tbl3.collect.drop = nil
    end

    if not arg2 and tbl3.controls.FarmEnabled and tbl3.flags.FarmEnabled ~= false then
        tbl4.set("FarmEnabled", false)
    end

    local message = arg or "Stopped"
    farm.message = message
end

tbl4.farmReset = function(arg, arg2)
    tbl4.farmStop(arg, arg2)

    if tbl3.factory and tbl3.factory.enabled then
        tbl4.factoryReset(arg)
    end

    local farm = tbl3.farm
    farm.targets = {}
    farm.records = {}
    farm.skip = {}
    farm.index = 1
    farm.left = 0
    farm.needDirt = false
    farm.harvestingSupply = false
    farm.nursery = nil
    farm.supplyY = nil
    farm.ignoredTrees = nil
    farm.dfTop = nil
    farm.dfBottom = nil
    farm.dfParity = nil
    farm.storing = nil
    farm.recycling = nil
    farm.phase = "Plant"
    farm.pnbTarget = nil
    farm.pnbDropSince = nil
    farm.pnbPlaced = nil
    farm.pnbRemoteBlock = nil
    farm.pnbStage = "Place"
end

tbl4.rebuildPnbTarget = function(arg, arg2, arg3)
    local farm = tbl3.farm

    if arg and arg2 and arg3 then
        local value = rawget(arg.world, "w")
        local value2 = rawget(arg.world, "h")
        local factory = tbl3.factory
        local breakOffsets = factory and tbl3.factory.enabled and tbl3.factory.breakOffsets or farm.pnbOffsets or {}
        local pnbTarget = {OriginX = arg2, OriginY = arg3}

        for i, breakOffset in ipairs(breakOffsets) do
            local n = arg2 + breakOffset.DX
            local n2 = arg3 + breakOffset.DY

            if n >= 0 and n2 >= 0 and n < value and n2 < value2 then
                pnbTarget[#pnbTarget + 1] = {X = n, Y = n2, DX = breakOffset.DX, DY = breakOffset.DY}
            end
        end

        farm.pnbTarget = pnbTarget
        farm.pnbPlaced = {}
        farm.pnbStage = "Place"
        return
    end

    farm.pnbTarget = nil
    farm.pnbPlaced = nil
    farm.pnbStage = "Place"
end

tbl4.inventoryOptions = function(arg, arg2, arg3)
    local v5 = tbl4.scene()
    if not v5 or not arg then
        return nil
    end
    local tbl7 = {}
    local tbl8 = {}
    local v6 = ipairs
    local value = rawget(v5.inventory, "slots")
    local tbl9 = value or {}

    for k, v7 in v6(tbl9) do
        local value2 = rawget(v7, "id")
        local v8 = tbl4.item(value2)
        local str2 = v8 and tbl4.itemName(value2) .. " [#" .. tostring(value2) .. "]"

        if str2 then
            local value3 = rawget(v7, "n")
            local n = value3 or 0

            if n > 0 and not tbl8[str2] and (not arg3 or arg3(value2, v8)) then
                tbl7[#tbl7 + 1] = str2
                tbl8[str2] = value2
            end
        end
    end

    table.sort(tbl7)
    local refresh = arg.Refresh
    local flag = #tbl7 > 0 and tbl7

    if not flag then
        local tbl10 = {}
        flag = tbl10
        tbl10[1] = "None in your inventory"
    end

    refresh(arg, flag)

    for k, v7 in pairs(tbl8) do
        if v7 == arg2 then
            arg:SetValue(k)
            break
        end
    end

    return tbl8
end

tbl4.dropOptions = function()
    if not tbl3.ui.dropItem then
        return
    end

    if tbl3.drop.allLabels and #tbl3.drop.allLabels > 0 then
        return
    end
    local allLabels = {}
    local mapping = {}
    local v5 = pairs
    local items = tbl2.Items
    local tbl7 = items or {}

    for k, v6 in v5(tbl7) do
        if type(k) == "number" and type(v6) == "table" and k ~= 18 and k ~= 112 and not rawget(v6, "untradeable") and not rawget(v6, "worldKey") then
            local value = rawget(v6, "name")

            if type(value) == "string" and value ~= "" then
                local str2 = value .. " [#" .. tostring(k) .. "]"

                if not mapping[str2] then
                    allLabels[#allLabels + 1] = str2
                    mapping[str2] = k
                end
            end
        end
    end

    table.sort(allLabels)
    tbl3.drop.allLabels = allLabels
    tbl3.drop.mapping = mapping
    local dropItem = tbl3.ui.dropItem
    local refresh = dropItem.Refresh
    local flag = #allLabels > 0 and allLabels

    if not flag then
        local tbl8 = {}
        flag = tbl8
        tbl8[1] = "No items loaded"
    end

    refresh(dropItem, flag)
end

tbl4.farmOptions = function()
    local farm = tbl3.farm

    local v5 = tbl4.inventoryOptions(tbl3.ui.pthtSeed, farm.pthtSeed, function(arg, arg2)
        local flag = rawget(arg2, "kind") == "seed"
        return flag
    end)

    local seedMapping = v5 or farm.seedMapping
    farm.seedMapping = seedMapping

    local v6 = tbl4.inventoryOptions(tbl3.ui.pnbBlock, farm.pnbBlock, function(arg, arg2)
        local value = rawget(arg2, "kind")
        local flag = arg == farm.remote

        if not flag then
            flag = value == nil or value == "misc"

            if flag then
                local value2 = rawget(arg2, "hits")
                local n = value2 or 0
                flag = n > 0
            end

            if flag then
                if tbl4.protectedTile(arg2) then
                    flag = false
                else
                    flag = true
                end
            end
        end

        return flag
    end)

    local blockMapping = v6 or farm.blockMapping
    farm.blockMapping = blockMapping
end

tbl4.breakable = function(arg)
    local flag = arg ~= 0 and tbl4.item(arg) or nil
    local flag2 = flag ~= nil

    if flag2 then
        if tbl4.protectedTile(flag) then
            flag2 = false
        else
            flag2 = true
        end
    end

    if flag2 then
        flag2 = rawget(flag, "kind") ~= "seed"
    end

    if flag2 then
        local value = rawget(flag, "hits")
        local n = value or 0
        flag2 = n > 0
    end

    return flag2
end

tbl4.dfBounds = function(arg)
    local world = arg.world
    local value = rawget(world, "w")
    local v5 = nil
    local v6 = nil
    local v7 = nil

    for i = 0, rawget(world, "h") - 1 do
        local n = 0
        local n2 = 0

        for i2 = 0, value - 1 do
            local v8 = tbl4.tile(rawget(world, "fg"), i2, i)
            local n3 = v8 or 0

            if n3 == tbl3.farm.door then
                v7 = i
            end

            if tbl4.breakable(n3) then
                n = n + 1
            elseif n3 ~= 0 then
                n2 = n2 + 1
            end
        end

        if not v5 and value / 2 <= n then
            v5 = i
        end

        if v5 and n2 < value / 2 then
            v6 = i
        end
    end

    local n = v7 and v7 + 1 or v5
    return v5, v6, n
end

tbl4.templateWork = function(arg, arg2, arg3, arg4)
    local farm = tbl3.farm
    local world = arg.world
    local breakLayer = farm.breakLayer

    if farm.template == "PTHT" then
        local v5 = tbl4.tile(rawget(world, "fg"), arg2, arg3)
        local n = v5 or 0

        if farm.phase == "Harvest" then
            if n == farm.pthtSeed and tbl4.ripeTree(arg, arg2, arg3) then
                return "Harvest", "fg", n
            end
        elseif n == 0 and (arg4 or arg4 == nil and farm.pthtSeed and tbl4.inventoryCount(arg, farm.pthtSeed) > 0) and tbl4.safeLanding(arg, arg2, arg3, nil, "Plant") then
            return "Plant", "fg", 0
        end

        return nil
    end

    if farm.template == "Auto DF" then
        local v5 = tbl4.tile(rawget(world, "fg"), arg2, arg3)
        local n = v5 or 0
        local value = rawget(world, "w")

        if (arg3 - farm.dfParity) % 2 == 0 and arg2 ~= 1 and arg2 ~= 2 and arg2 ~= value - 3 and arg2 ~= value - 2 then
            if n == 0 then
                return "Place", "fg", 0
            end

            if n ~= farm.dirt and tbl4.breakable(n) then
                return "Break", "fg", n
            end
            return nil
        end

        breakLayer = "Both"
    end

    local v5, v6, v7 = tbl4.breakTarget(arg, arg2, arg3, breakLayer)
    if not v7 and v5 ~= 0 and tbl4.breakable(v5) then
        return "Break", v6, v5
    end
    return nil
end

tbl4.farmOrder = function(arg)
    local farm = tbl3.farm
    local world = arg.world
    local value = rawget(world, "w")
    local value2 = rawget(world, "h")

    if farm.template == "Auto DF" then
        local tbl7 = {}
        local n = value - 1

        for i = farm.dfTop, farm.dfBottom do
            local flag = (i - farm.dfParity) % 2 == 0

            if flag then
                local tbl8 = {}
                flag = tbl8
                tbl8[1] = 1
                tbl8[2] = 2
            end

            if not flag then
                local tbl8 = {}
                flag = tbl8
                tbl8[1] = 0
                tbl8[2] = 1
                tbl8[3] = 2
                tbl8[4] = 3
            end

            for i2, v5 in ipairs(flag) do
                tbl7[#tbl7 + 1] = {v5, i}
            end
        end

        local function fn4(arg2)
            if arg2 < 0 or farm.dfBottom < arg2 then
                return nil
            end
            local v5 = nil
            local v6 = nil

            for i = 0, n do
                if not farm.skip[arg2 * value + i] and tbl4.templateWork(arg, i, arg2) then
                    local v7 = v5 or i
                    v5 = v7
                    v6 = i
                end
            end

            return v5, v6
        end

        local v5 = tbl4.coords(arg)
        local n2 = v5 or 0
        local n3 = n2 - 0.5
        local n4 = farm.dfBottom - -1
        local n5 = farm.dfTop + 0

        while true do
            local n6 = n4 + -1
            if n5 > n6 then
                break
            end
            n4 = n6

            if (n6 - farm.dfParity) % 2 == 1 then
                local v6, v7 = fn4(n6)
                local v8 = v6
                local v9 = v7
                local v10, v11 = fn4(n6 + 1)

                if v10 then
                    local min = math.min
                    local v12 = v6 or v10
                    v8 = min(v12, v10)
                    local max = math.max
                    local v13 = v7 or v11
                    v9 = max(v13, v11)
                end

                if v8 then
                    local flag

                    if v6 then
                        flag = false
                    else
                        flag = true
                    end

                    if not flag then
                        flag = v6 > 0 and tbl4.openCell(arg, 0, n6)
                    end

                    local flag2

                    if v7 then
                        flag2 = false
                    else
                        flag2 = true
                    end

                    if not flag2 then
                        flag2 = v7 < n - 3 and tbl4.openCell(arg, n, n6)
                    end

                    local flag3 = flag ~= flag2 and flag or math.abs(n3 - v8) <= math.abs(n3 - v9)
                    local n7 = v8 <= 4 and 0 or v8 - 2
                    local n8 = n - 4 <= v9 and n or v9 + 2
                    local tbl8 = {}

                    for i = n7, n8 do
                        local n9 = flag3 and i or n7 + n8 - i

                        if farm.dfTop < n6 and tbl4.templateWork(arg, n9, n6 - 1) == "Place" then
                            tbl7[#tbl7 + 1] = {n9, n6 - 1}
                        end

                        if n6 >= 0 and n6 <= farm.dfBottom then
                            tbl7[#tbl7 + 1] = {n9, n6}
                        end

                        if n6 + 1 >= 0 and n6 + 1 <= farm.dfBottom then
                            if (not flag3 or n9 ~= n - 2 and n9 ~= n - 1) and (flag3 or n9 ~= 1 and n9 ~= 2) then
                                tbl7[#tbl7 + 1] = {n9, n6 + 1}
                            else
                                tbl8[#tbl8 + 1] = {n9, n6 + 1}
                            end
                        end
                    end

                    for i = #tbl8, 1, -1 do
                        tbl7[#tbl7 + 1] = tbl8[i]
                    end

                    n4 = n6
                    local v12 = flag3 and v9 or v8
                    n3 = v12
                end
            end
        end

        local n6 = farm.dfBottom - -1

        while true do
            local n7 = n6 + -1
            if n7 < 0 then
                break
            end
            n6 = n7
            local v6, v7 = fn4(n7)

            if v6 then
                local flag = math.abs(n3 - v6) <= math.abs(n3 - v7)

                for i = v6, v7 do
                    local n8 = #tbl7 + 1
                    local tbl8 = {}
                    local n9 = flag and i or v6 + v7 - i
                    tbl8[1] = n9
                    tbl8[2] = n7
                    tbl7[n8] = tbl8
                end

                n6 = n7
                local v8 = flag and v7 or v6
                n3 = v8
            end
        end

        return tbl7
    end

    local flag = farm.template == "PTHT"
    local cachedOrderKey = string.format("%d:%d:%s", value, value2, tostring(flag))
    if farm.cachedOrderKey == cachedOrderKey and farm.cachedOrder then
        return farm.cachedOrder
    end
    local cachedOrder = {}

    for i = 0, value2 - 1 do
        local n = flag and value2 - 1 - i or i

        for i2 = 0, value - 1 do
            local n2 = #cachedOrder + 1
            local tbl7 = {}
            local n3 = i % 2 == 0 and i2 or value - 1 - i2
            tbl7[1] = n3
            tbl7[2] = n
            cachedOrder[n2] = tbl7
        end
    end

    farm.cachedOrderKey = cachedOrderKey
    farm.cachedOrder = cachedOrder
    return cachedOrder
end

tbl4.farmBatch = function(arg)
    local farm = tbl3.farm
    local world = arg.world
    local value = rawget(world, "w")
    local value2 = rawget(world, "areas")
    local value3 = value2 and rawget(value2, "mayBuild")
    if type(value3) ~= "function" then
        return nil, "Native build permission check changed"
    end
    local value4 = rawget(world, "lock")
    local tbl7 = {}
    local n = 0
    local tbl8 = {}
    local flag = farm.template == "PTHT" and farm.phase == "Plant" and (farm.pthtSeed ~= nil and tbl4.inventoryCount(arg, farm.pthtSeed) > 0) or false
    farm.breaksLeft = 0
    if farm.template == "PTHT" and farm.phase == "Plant" and not flag then
        return tbl7, 0
    end

    for i, v5 in ipairs(tbl4.farmOrder(arg)) do
        local v6 = v5[1]
        local v7 = v5[2]
        local n2 = v7 * value + v6

        if not tbl8[n2] and not farm.skip[n2] then
            local v8 = tbl4.templateWork(arg, v6, v7, flag)

            if v8 and value3(value4, v6, v7) then
                tbl8[n2] = true
                n = n + 1

                if v8 == "Break" then
                    farm.breaksLeft = farm.breaksLeft + 1
                end

                if #tbl7 < 64 then
                    tbl7[#tbl7 + 1] = {X = v6, Y = v7, Key = n2}
                end
            end
        end
    end

    if #tbl7 ~= 0 or not farm.waitingDirt then
        return tbl7, n
    end
    farm.waitingDirt = false
    farm.skip = {}
    return tbl4.farmBatch(arg)
end

tbl4.ripeTree = function(arg, arg2, arg3)
    local v5 = tbl4.tile(rawget(arg.world, "fg"), arg2, arg3)
    local n = v5 or 0
    local v6 = tbl4.item(n)
    local flag = v6 and rawget(v6, "kind") == "seed" and tbl4.treeState(arg, arg3 * rawget(arg.world, "w") + arg2)
    local value = flag and rawget(flag, "p")
    local flag2 = type(value) == "number"

    if flag2 then
        local value2 = rawget(v6, "grow")
        local n2 = value2 or 0
        flag2 = value + n2 <= workspace:GetServerTimeNow()
    end

    local flag3 = type(value) == "number"

    if flag3 then
        local value2 = rawget(v6, "grow")
        local n2 = value2 or 0
        flag3 = value + n2 - workspace:GetServerTimeNow()
    end

    if not flag3 then
        flag3 = nil
    end

    return flag2, flag3
end

tbl4.nurseryCells = function(arg, arg2)
    local farm = tbl3.farm
    local world = arg.world
    local value = rawget(world, "w")
    local v5 = tbl4.coords(arg)
    if not v5 then
        return {}
    end
    local n = math.floor(v5)
    local tbl7 = {}

    for i = math.max(0, arg2 - 2), arg2 + 2 do
        for i2 = 3, value - 4 do
            local v6 = tbl4.tile(rawget(world, "fg"), i2, i)
            local n2 = v6 or 0

            if n2 == farm.seed or n2 == 0 and i == arg2 and math.abs(i2 - n) <= 8 and tbl4.safeLanding(arg, i2, arg2, nil, "Plant") then
                tbl7[#tbl7 + 1] = {
                    X = i2,
                    Y = i,
                    Distance = math.abs(i2 - n) + math.abs(i - arg2) * 4,
                }
            end
        end
    end

    table.sort(tbl7, function(arg3, arg4)
        local flag = arg3.Distance < arg4.Distance
        return flag
    end)

    return tbl7
end

tbl4.nearestTree = function(arg, arg2)
    local farm = tbl3.farm
    local world = arg.world
    local v5, v6 = tbl4.coords(arg)
    local tbl7 = nil
    local v7 = nil

    for i = 0, rawget(world, "h") - 1 do
        for i2 = 0, rawget(world, "w") - 1 do
            local v8 = tbl4.tile(rawget(world, "fg"), i2, i)
            local n = v8 or 0

            if n == farm.seed then
                local ignoredTrees = farm.ignoredTrees
                local tbl8 = ignoredTrees or {}

                if not tbl8[i * rawget(world, "w") + i2] and (not arg2 or tbl4.ripeTree(arg, i2, i)) then
                    local n2 = i2 + 0.5
                    local n3 = v5 or 0
                    local n4 = (n2 - n3) ^ 2
                    local n5 = i + 1
                    local n6 = v6 or 0
                    local n7 = n4 + (n5 - n6) ^ 2

                    if not tbl7 or n7 < v7 then
                        tbl7 = {X = i2, Y = i}
                        v7 = n7
                    end
                end
            end
        end
    end

    return tbl7
end

tbl4.dirtSupply = function(arg, arg2)
    local farm = tbl3.farm
    local v5, v6 = tbl4.coords(arg)
    local supplyY = farm.supplyY
    local supplyY2 = supplyY or v6 and math.floor(v6 - 0.001)
    farm.supplyY = supplyY2
    local supplyY3 = farm.supplyY
    tbl4.inventoryCount(arg, farm.dirt)
    local tbl7 = {}
    local v7 = tbl4.inventoryCount(arg, farm.seed)
    tbl7[farm.dirt] = true
    local seed = farm.seed
    local flag = v7 < 20 or nil
    tbl7[seed] = flag

    local function fn4()
        farm.needDirt = false
        farm.harvestingSupply = false
        farm.nursery = nil
        farm.skip = {}
        farm.batchSize = 0
        farm.supplyY = nil
        tbl3.collect.drop = nil

        if not farm.travel then
            farm.route = nil
        end

        return false
    end

    local function fn5()
        local enabled = tbl3.collect.enabled
        local radius = enabled and tbl3.collect.radius or 20
        if not tbl4.takePassing(arg, arg2, tbl7, radius) and not tbl3.collect.taking then
            return false
        end
        return true, "Collecting dirt"
    end

    local function fn6(arg3, arg4)
        local v8, v9 = tbl4.approach(arg, arg3, arg4)
        if v8 == nil then
            return nil, v9
        end

        if v8 == "skip" then
            farm.nursery = nil
            return true, v9
        end

        if not v8 then
            return true, v9
        end
        local v10, v11 = tbl4.action(arg, arg4, arg3.X, arg3.Y, farm.seed, "fg")
        if not v10 and v11 ~= "Tree is still growing" then
            farm.nursery = nil
            return true, v11
        end
        farm.actions = farm.actions + 1
        farm.waitUntil = arg2 + 0.25
        local str2 = arg4 == "Plant" and "Planting dirt seeds" or "Harvesting dirt trees"
        return true, str2
    end

    tbl4.takePassing(arg, arg2, tbl7)
    local v8 = tbl4.inventoryCount(arg, farm.dirt)
    local v9 = tbl4.inventoryCount(arg, farm.seed)
    if v8 >= 200 then
        return fn4()
    end
    local nursery = farm.nursery
    local v10 = nursery or tbl4.nurseryCells(arg, supplyY3)
    local flag2 = false
    local huge = math.huge
    farm.nursery = v10
    local v11 = nil

    for i, v12 in ipairs(v10) do
        local v13 = tbl4.tile(rawget(arg.world, "fg"), v12.X, v12.Y)
        local n = v13 or 0

        if n == farm.seed then
            local v14, v15 = tbl4.ripeTree(arg, v12.X, v12.Y)

            if not v14 then
                if v15 then
                    flag2 = true
                    huge = math.min(huge, v15)
                end

                continue
            end

            farm.harvestingSupply = true
            if not tbl3.collect.drop then
                return fn6(v12, "Harvest")
            end
            continue
        end

        if n == 0 and v9 > 0 and v8 == 0 and not farm.harvestingSupply and not v11 then
            v11 = v12
        end
    end

    local flag3

    if tbl3.collect.drop then
        flag3 = false
    else
        flag3 = true
    end

    if flag3 then
        flag3 = tbl4.nearestTree(arg, true)
    end

    if not flag3 then
        if v11 and not tbl3.collect.drop then
            return fn6(v11, "Plant")
        end

        if flag2 then
            farm.harvestingSupply = true
        end

        local v12, v13 = fn5()
        if v12 ~= false then
            return v12, v13
        end

        if v8 > 0 then
            return fn4()
        end

        if flag2 then
            return true, string.format("Growing dirt trees: %ds", math.max(0, math.ceil(huge)))
        end
        farm.nursery = nil
        if v9 > 0 then
            return nil, "No empty tile in this row to plant Dirt Seeds"
        end
        local v14 = tbl4.nearestTree(arg)
        if not v14 then
            return nil, "Out of Dirt and Dirt Seeds"
        end
        local v15, v16 = tbl4.ripeTree(arg, v14.X, v14.Y)
        if v15 then
            return fn6(v14, "Harvest")
        end

        if v16 then
            return true, string.format("Waiting for a dirt tree: %ds", math.max(0, math.ceil(v16)))
        end
        local v17, v18 = tbl4.approach(arg, v14, "Harvest")
        if v17 == nil then
            return nil, v18
        end

        if v17 == true or v17 == "skip" then
            local ignoredTrees = farm.ignoredTrees
            local ignoredTrees2 = ignoredTrees or {}
            farm.ignoredTrees = ignoredTrees2
            farm.ignoredTrees[v14.Y * rawget(arg.world, "w") + v14.X] = true
        end

        local str2 = v17 == true and "Checking a dirt tree" or v18
        return true, str2
    end

    farm.harvestingSupply = true
    return fn6(flag3, "Harvest")
end

tbl4.farmPlan = function(arg, arg2, arg3)
    local v5, v6, v7 = tbl4.templateWork(arg, arg2.X, arg2.Y)
    if not v5 then
        return "done"
    end
    local previous = v6 .. ":" .. v7

    if previous ~= arg3.previous then
        arg3.previous = previous
        arg3.attempts = 0
        arg3.actionStarted = nil
    end

    if v5 ~= "Place" or tbl4.inventoryCount(arg, tbl3.farm.dirt) >= 1 then
        return "action", v5, v6
    end
    local breaksLeft = tbl3.farm.breaksLeft
    local n = breaksLeft or 0
    if n > 0 then
        tbl3.farm.waitingDirt = true
        return "skip", "Waiting for dirt until digging is done"
    end
    tbl3.farm.needDirt = true
    return "skip", "Out of dirt"
end

tbl4.pthtWait = function(arg)
    local world = arg.world
    local v5 = nil

    for i = 0, rawget(world, "h") - 1 do
        for i2 = 0, rawget(world, "w") - 1 do
            local v6 = tbl4.tile(rawget(world, "fg"), i2, i)
            local n = v6 or 0

            if n == tbl3.farm.pthtSeed then
                local v7, v8 = tbl4.ripeTree(arg, i2, i)

                if not v7 and v8 then
                    local max = math.max
                    local n2 = v5 or 0
                    v5 = max(n2, v8)
                end
            end
        end
    end

    return v5
end

tbl4.pnbStep = function(arg, arg2)
    local farm = tbl3.farm
    local pnbBlock = farm.pnbBlock
    if not pnbBlock then
        return nil, "Select a block for Break Block"
    end

    if not farm.pnbOffsets or #farm.pnbOffsets == 0 then
        return nil, "Select at least 1 tile in the 7x7 grid"
    end
    tbl4.takePassing(arg, arg2)
    local v5, v6 = tbl4.coords(arg)
    if not v5 then
        return true, "Waiting for your position"
    end

    if not farm.pnbTarget then
        local n = math.floor(v5)
        local n2 = math.floor(v6 - 0.001)
        tbl4.rebuildPnbTarget(arg, n, n2)
    end

    if not farm.pnbTarget or #farm.pnbTarget == 0 then
        return nil, "Selected 7x7 tiles are outside this world"
    end

    for i, v7 in ipairs(farm.pnbTarget) do
        local v8 = tbl4.dropInCell(arg, v7.X, v7.Y)

        if v8 and not tbl3.collect.taking then
            tbl4.takeDrop(arg, v8)
        end
    end

    local v7 = tbl4.item(pnbBlock)
    local str2 = v7 and rawget(v7, "background") and "bg" or "fg"
    local pnbStage = farm.pnbStage
    local pnbStage2 = pnbStage or "Place"
    farm.pnbStage = pnbStage2

    if farm.pnbStage == "Place" then
        local n = 0
        local n2 = 0
        local str3 = nil

        for i, v8 in ipairs(farm.pnbTarget) do
            local v9 = tbl4.tile(rawget(arg.world, "fg"), v8.X, v8.Y)
            local n3 = v9 or 0
            local pnbRemoteBlock = str2 == "bg"

            if pnbRemoteBlock then
                local v10 = tbl4.tile(rawget(arg.world, "bg"), v8.X, v8.Y)
                pnbRemoteBlock = v10 or 0
            end

            if not pnbRemoteBlock then
                pnbRemoteBlock = n3
            end

            if str2 == "bg" and n3 ~= 0 then
                str3 = string.format("Tile (%d, %d) foreground holds %s", v8.X, v8.Y, tbl4.itemName(n3))
                continue
            end

            if pnbRemoteBlock == 0 then
                local v10 = farm.pnbPlaced[i]
                if type(v10) == "number" and arg2 - v10 < 0.6 then
                    n2 = n2 + 1
                    continue
                end
                farm.pnbPlaced[i] = nil

                if pnbBlock ~= farm.remote and tbl4.inventoryCount(arg, pnbBlock) < 1 then
                    if n <= 0 and n2 <= 0 then
                        return nil, "Out of " .. tbl4.itemName(pnbBlock)
                    end
                    break
                end

                local flag = str2 == "fg" and v5 - 0.3 < v8.X + 1 and v8.X < v5 + 0.3 and v6 - 0.95 < v8.Y + 1 and v8.Y < v6

                if flag or not tbl4.inReach(arg, "Place", v8.X, v8.Y) then
                    local n4 = flag and farm.pnbTarget.OriginX + 0.5

                    if not n4 then
                        local n5 = farm.pnbTarget.OriginX + 0.5
                        local n6 = v8.DX > 0 and 0.55 or v8.DX < 0 and -0.55 or 0
                        n4 = n5 + n6
                    end

                    if math.abs(v5 - n4) > 0.12 then
                        tbl4.nudge(arg, n4, v5)
                        return true, "Moving in reach to place"
                    end
                end

                tbl4.setWalk(arg, nil)
                local v11, v12 = tbl4.action(arg, "Place", v8.X, v8.Y, pnbBlock, str2)
                if not v11 then
                    return nil, v12
                end
                farm.pnbPlaced[i] = arg2
                farm.actions = farm.actions + 1
                farm.waitUntil = arg2 + 0.06
                return true, string.format("Placing %s (%d/%d)", tbl4.itemName(pnbBlock), i, #farm.pnbTarget)
            end

            if pnbBlock == farm.remote and farm.pnbPlaced[i] and not farm.pnbRemoteBlock then
                farm.pnbRemoteBlock = pnbRemoteBlock
            end

            local pnbRemoteBlock2 = pnbBlock == farm.remote and farm.pnbRemoteBlock or pnbBlock

            if pnbRemoteBlock == pnbRemoteBlock2 then
                n = n + 1
            else
                local format = string.format
                local x = v8.X
                local y = v8.Y
                local v10 = tbl4.itemName(pnbRemoteBlock)
                local itemName = tbl4.itemName
                local v11 = pnbRemoteBlock2 or pnbBlock
                str3 = format("Tile (%d, %d) holds %s instead of selected %s", x, y, v10, itemName(v11))
            end
        end

        if n2 > 0 then
            return true, "Waiting for placed blocks"
        end

        if n == 0 then
            tbl4.setWalk(arg, nil)
            local str4 = str3 or "The selected tiles hold a different block"
            return nil, str4
        end

        farm.pnbStage = "Break"
        farm.pnbBreakCursor = 0
    end

    local tbl7 = {}
    local str3 = nil

    for i, v8 in ipairs(farm.pnbTarget) do
        local v9 = tbl4.tile(rawget(arg.world, "fg"), v8.X, v8.Y)
        local n = v9 or 0
        local pnbRemoteBlock = str2 == "bg"

        if pnbRemoteBlock then
            local v10 = tbl4.tile(rawget(arg.world, "bg"), v8.X, v8.Y)
            pnbRemoteBlock = v10 or 0
        end

        if not pnbRemoteBlock then
            pnbRemoteBlock = n
        end

        if pnbRemoteBlock == 0 then
            farm.pnbPlaced[i] = nil
        elseif str2 == "bg" and n ~= 0 then
            str3 = string.format("Tile (%d, %d) foreground holds %s", v8.X, v8.Y, tbl4.itemName(n))
        else
            if pnbBlock == farm.remote and farm.pnbPlaced[i] and not farm.pnbRemoteBlock then
                farm.pnbRemoteBlock = pnbRemoteBlock
            end

            local pnbRemoteBlock2 = pnbBlock == farm.remote and farm.pnbRemoteBlock or pnbBlock

            if pnbRemoteBlock == pnbRemoteBlock2 then
                tbl7[#tbl7 + 1] = {Point = v8, Index = i}
            else
                local format = string.format
                local x = v8.X
                local y = v8.Y
                local v10 = tbl4.itemName(pnbRemoteBlock)
                local itemName = tbl4.itemName
                local v11 = pnbRemoteBlock2 or pnbBlock
                str3 = format("Tile (%d, %d) holds %s instead of selected %s", x, y, v10, itemName(v11))
            end
        end
    end

    if #tbl7 == 0 then
        if not str3 then
            farm.pnbStage = "Place"
            return tbl4.pnbStep(arg, arg2)
        end
        tbl4.setWalk(arg, nil)
        return nil, str3
    end

    local pnbBreakCursor = farm.pnbBreakCursor
    local n = pnbBreakCursor or 0
    farm.pnbBreakCursor = n % #tbl7 + 1
    local v8 = tbl7[farm.pnbBreakCursor]
    local point = v8.Point
    local index = v8.Index
    local v9 = farm.pnbPlaced[index]

    if type(v9) == "number" and arg2 - v9 < 0.2 then
        farm.pnbBreakCursor = farm.pnbBreakCursor - 1
        farm.waitUntil = v9 + 0.2
        return true, "Breaking " .. tbl4.itemName(pnbBlock)
    end

    local v10 = tbl4.tile(rawget(arg.world, str2), point.X, point.Y)
    local n2 = v10 or 0
    local pnbRemoteBlock = pnbBlock == farm.remote and farm.pnbRemoteBlock or pnbBlock

    if n2 == pnbRemoteBlock then
        if not tbl4.breakable(n2) then
            return nil, "The selected tile cannot be broken"
        end

        if not tbl4.inReach(arg, "Break", point.X, point.Y) then
            local n3 = farm.pnbTarget.OriginX + 0.5
            local n4 = point.DX > 0 and 0.55 or point.DX < 0 and -0.55 or 0
            local n5 = n3 + n4
            if math.abs(v5 - n5) > 0.12 then
                tbl4.nudge(arg, n5, v5)
                return true, "Moving in reach to break"
            end
        end

        tbl4.setWalk(arg, nil)
        local v11, v12 = tbl4.action(arg, "Break", point.X, point.Y, pnbRemoteBlock, str2)

        if not v11 then
            if v12 == "Target layer changed" then
                return true, "Breaking"
            end
            return nil, v12
        end

        farm.actions = farm.actions + 1
        local max = math.max
        local n3 = #tbl7 == 1 and 0.145 or 0.2 / #tbl7
        farm.waitUntil = arg2 + max(0.06, n3)
        return true, string.format("Breaking %s (%d/%d)", tbl4.itemName(n2), index, #farm.pnbTarget)
    end

    local format = string.format
    local x = point.X
    local y = point.Y
    local v11 = tbl4.itemName(n2)
    local itemName = tbl4.itemName
    local v12 = pnbRemoteBlock or pnbBlock
    return nil, format("Tile (%d, %d) holds %s instead of selected %s", x, y, v11, itemName(v12))
end

tbl4.finishFarmTile = function(arg, arg2, lastSkip)
    local farm = tbl3.farm
    arg2.done = true
    farm.left = math.max(0, farm.left - 1)

    if lastSkip then
        farm.skipped = farm.skipped + 1
        farm.totalSkipped = farm.totalSkipped + 1
        farm.lastSkip = lastSkip
        farm.message = string.format("Skipped (%d, %d): %s", arg.X, arg.Y, lastSkip)
        farm.skip[arg.Key] = true
    else
        farm.completed = farm.completed + 1
    end

    farm.travel = nil
    farm.route = nil
end

tbl4.moveBlocked = function(arg)
    if not arg then
        return "Enter a world first"
    end

    if tbl4.isDead(arg) or rawget(arg.world, "ghost") or localPlayer:GetAttribute("Frozen") then
        return "Stopped: respawn, ghost mode, or frozen"
    end
    local controller = arg.controller
    local value = controller and rawget(arg.controller, "blocked")
    if (type(value) ~= "function" or not value()) and not tbl.Input:GetFocusedTextBox() then
        return nil
    end
    return "Close the game's menu or text input first"
end

tbl4.farmStep = function()
    local farm = tbl3.farm
    local now = os.clock()
    local v5 = now

    if farm.enabled then
        local waitUntil = farm.waitUntil
        local n = waitUntil or 0

        if now >= n then
            local v6 = tbl4.scene()

            if v6 and farm.world == rawget(v6.world, "name") then
                local v7 = tbl4.moveBlocked(v6)

                if not v7 then
                    if not farm.storing and not farm.travel then
                        local v8, v9 = tbl4.recycleStep(v6, now)

                        if v8 == nil then
                            tbl4.farmStop(v9)
                            tbl4.notice(v9, "Auto Farm")
                            return
                        end

                        if v8 then
                            farm.message = v9
                            return
                        end
                    end

                    if farm.template == "Break Block" then
                        local v8, v9 = tbl4.pnbStep(v6, now)

                        if v8 == nil then
                            tbl4.farmStop(v9)
                            tbl4.notice(v9, "Auto Farm")
                            return
                        end

                        farm.message = v9
                        return
                    end

                    if not farm.storing then
                        if farm.template == "PTHT" and farm.phase == "Wait" then
                            local v8 = tbl4.pthtWait(v6)

                            if v8 then
                                farm.message = string.format("Waiting for trees: %ds", math.ceil(v8))
                                farm.waitUntil = now + 1
                                return
                            end

                            farm.phase = "Harvest"
                            farm.batchSize = 0
                            farm.skip = {}
                        end

                        local flag = #farm.targets < farm.index or farm.batchSize <= farm.completed + farm.skipped

                        if farm.needDirt and farm.template == "Auto DF" then
                            local v8, v9 = tbl4.dirtSupply(v6, now)

                            if v8 == nil then
                                tbl4.farmStop(v9)
                                tbl4.notice(v9, "Auto Farm")
                                return
                            end

                            if v8 then
                                farm.message = v9
                                return
                            end
                        end

                        if flag then
                            if farm.completed > 0 then
                                farm.skip = {}
                            end

                            local v8, v9 = tbl4.farmBatch(v6)
                            if not v8 then
                                tbl4.farmStop(v9)
                                return
                            end

                            if #v8 == 0 then
                                if farm.template == "PTHT" and farm.phase == "Plant" then
                                    farm.phase = "Wait"
                                    farm.message = "Waiting for trees"
                                    return
                                end

                                farm.storing = true
                                farm.message = "Collecting items"
                                return
                            end

                            farm.targets = v8
                            farm.records = {}
                            farm.index = 1
                            farm.left = v9
                            farm.completed = 0
                            farm.skipped = 0
                            farm.batchSize = #v8
                        end

                        tbl4.takePassing(v6, now)
                        local tbl7 = {}
                        local v8, v9, v10 = ipairs(farm.targets)
                        local v11 = v10

                        while true do
                            local v12, v13 = v8(v9, v11)
                            if v12 == nil then
                                break
                            end
                            v11 = v12
                            local v14 = farm.records[v12]
                            local v15 = v14

                            if not v14 then
                                local tbl8 = {attempts = 0}
                                v15 = tbl8
                                farm.records[v12] = tbl8
                            end

                            if not v15.done then
                                local now2 = os.clock()
                                v5 = now2

                                if v15.deferUntil then
                                    if now2 < v15.deferUntil then
                                        tbl7[#tbl7 + 1] = {v13, v15, v15.deferReason}
                                        continue
                                    end

                                    if v15.deferSince and now2 - v15.deferSince >= 3 then
                                        tbl4.finishFarmTile(v13, v15, v15.deferReason)
                                        continue
                                    end
                                end

                                farm.index = v12
                                local v16, v17, v18 = tbl4.farmPlan(v6, v13, v15)

                                if v16 ~= "done" and v16 ~= "skip" then
                                    local item = tbl4.item
                                    local v19 = tbl4.tile(rawget(v6.world, v18), v13.X, v13.Y)
                                    local n2 = v19 or 0
                                    local v20 = item(n2)

                                    if v15.actionStarted then
                                        local n3 = now2 - v15.actionStarted
                                        local max = math.max
                                        local n4 = v20 and rawget(v20, "hits") or 3
                                        if max(15, n4 * 0.4 + 8) < n3 then
                                            tbl4.finishFarmTile(v13, v15, "No tile progress; timed out")
                                            continue
                                        end
                                    end

                                    local flag2 = v17 == "Place" and tbl4.dropInCell(v6, v13.X, v13.Y)

                                    if not flag2 then
                                        local v21, v22 = tbl4.approach(v6, v13, v17)
                                        local now3 = os.clock()
                                        v5 = now3

                                        if v21 == nil then
                                            tbl4.farmStop(v22)
                                            tbl4.notice(v22, "Auto Farm")
                                            return
                                        end

                                        if v21 == "skip" then
                                            if v15.deferSince and now3 - v15.deferSince >= 3 then
                                                tbl4.finishFarmTile(v13, v15, v22)
                                                continue
                                            end
                                            v15.deferUntil = now3 + 3
                                            v15.deferReason = v22
                                            local deferSince = v15.deferSince
                                            local v23 = deferSince or now3
                                            v15.deferSince = v23
                                            tbl7[#tbl7 + 1] = {v13, v15, v22}

                                            while true do
                                                local v24, v25 = v8(v9, v11)
                                                if v24 == nil then
                                                    break
                                                end
                                                v11 = v24
                                                local v26 = farm.records[v24]
                                                local v27 = v26

                                                if not v26 then
                                                    local tbl8 = {attempts = 0}
                                                    v27 = tbl8
                                                    farm.records[v24] = tbl8
                                                end

                                                if not v27.done then
                                                    local now4 = os.clock()
                                                    v5 = now4

                                                    if v27.deferUntil then
                                                        if now4 < v27.deferUntil then
                                                            tbl7[#tbl7 + 1] = {v25, v27, v27.deferReason}
                                                            continue
                                                        end

                                                        if v27.deferSince and now4 - v27.deferSince >= 3 then
                                                            tbl4.finishFarmTile(v25, v27, v27.deferReason)
                                                            continue
                                                        end
                                                    end

                                                    farm.index = v24
                                                    local v28, v29, v30 = tbl4.farmPlan(v6, v25, v27)

                                                    if v28 ~= "done" and v28 ~= "skip" then
                                                        local item2 = tbl4.item
                                                        local v31 = tbl4.tile(rawget(v6.world, v30), v25.X, v25.Y)
                                                        local n3 = v31 or 0
                                                        local v32 = item2(n3)

                                                        if v27.actionStarted then
                                                            local n4 = now4 - v27.actionStarted
                                                            local max = math.max
                                                            local n5 = v32 and rawget(v32, "hits") or 3
                                                            if max(15, n5 * 0.4 + 8) < n4 then
                                                                tbl4.finishFarmTile(v25, v27, "No tile progress; timed out")
                                                                continue
                                                            end
                                                        end

                                                        local flag3 = v29 == "Place" and tbl4.dropInCell(v6, v25.X, v25.Y)

                                                        if not flag3 then
                                                            local v33, v34 = tbl4.approach(v6, v25, v29)
                                                            local now5 = os.clock()
                                                            v5 = now5

                                                            if v33 == nil then
                                                                tbl4.farmStop(v34)
                                                                tbl4.notice(v34, "Auto Farm")
                                                                return
                                                            end

                                                            if v33 == "skip" then
                                                                if v27.deferSince and now5 - v27.deferSince >= 3 then
                                                                    tbl4.finishFarmTile(v25, v27, v34)
                                                                    continue
                                                                end
                                                                v27.deferUntil = now5 + 3
                                                                v27.deferReason = v34
                                                                local deferSince2 = v27.deferSince
                                                                local v35 = deferSince2 or now5
                                                                v27.deferSince = v35
                                                                tbl7[#tbl7 + 1] = {v25, v27, v34}
                                                                farm.waitUntil = now5 + 0.05
                                                                return
                                                            end

                                                            if not v33 then
                                                                farm.message = v34
                                                                return
                                                            end
                                                            local v35 = tbl4.tile(rawget(v6.world, v30), v25.X, v25.Y)
                                                            local n4 = v35 or 0
                                                            local v36 = tbl4.item(n4)
                                                            local action = tbl4.action
                                                            local x = v25.X
                                                            local y = v25.Y
                                                            local pthtSeed = v29 == "Plant" and farm.pthtSeed or farm.dirt
                                                            local v37, v38 = action(v6, v29, x, y, pthtSeed, v30)

                                                            if not v37 then
                                                                if v38 == "Target layer changed" then
                                                                    farm.waitUntil = now5 + 0.1
                                                                    return
                                                                end

                                                                if v38 ~= "This tile is not placeable" and v38 ~= "Protected or unsupported tile" and v38 ~= "Foreground blocks background" then
                                                                    tbl4.farmStop(v38)
                                                                    tbl4.notice(v38, "Auto Farm")
                                                                    return
                                                                end

                                                                tbl4.finishFarmTile(v25, v27, v38)
                                                                continue
                                                            end

                                                            local actionStarted = v27.actionStarted
                                                            local v39 = actionStarted or now5
                                                            v27.actionStarted = v39
                                                            v27.attempts = v27.attempts + 1
                                                            farm.actions = farm.actions + 1
                                                            local waitUntil2 = v29 == "Break" and now5 + 0.15 or now5 + 0.08
                                                            farm.waitUntil = waitUntil2
                                                            local format = string.format
                                                            local str2 = v29 == "Break" and (v30 == "bg" and "background" or "foreground") or v29 == "Plant" and tbl4.itemName(farm.pthtSeed) or v29 == "Harvest" and "tree" or "dirt"
                                                            farm.message = format("%s %s (%d, %d)", v29, str2, v25.X, v25.Y)
                                                            local v40 = tbl4.tile(rawget(v6.world, v30), v25.X, v25.Y)
                                                            local n5 = v40 or 0

                                                            if n4 == n5 then
                                                                local attempts = v27.attempts
                                                                local max = math.max
                                                                local n6 = v36 and rawget(v36, "hits") or 3

                                                                if max(15, n6 * 2 + 8) < attempts then
                                                                    tbl4.finishFarmTile(v25, v27, "No tile progress; target skipped")
                                                                end
                                                            end

                                                            return
                                                        end

                                                        local cellSince = v27.cellSince
                                                        local v33 = cellSince or now4
                                                        v27.cellSince = v33
                                                        if now4 - v27.cellSince > 3 then
                                                            tbl4.finishFarmTile(v25, v27, "Item inside this tile was not picked up")
                                                            continue
                                                        end

                                                        if not tbl3.collect.taking and not tbl3.farm.travel then
                                                            tbl4.setWalk(v6, nil)
                                                            tbl4.takeDrop(v6, flag3)
                                                        end

                                                        farm.message = "Collecting " .. tbl4.itemName(rawget(flag3, "id"))
                                                        return
                                                    end

                                                    local finishFarmTile = tbl4.finishFarmTile
                                                    local flag3 = v28 == "skip" and v29 or nil
                                                    finishFarmTile(v25, v27, flag3)
                                                end
                                            end

                                            local flag3 = false

                                            for i, v24 in ipairs(tbl7) do
                                                if v5 - v24[2].deferSince >= 3 then
                                                    tbl4.finishFarmTile(v24[1], v24[2], v24[3])
                                                else
                                                    flag3 = true
                                                end
                                            end

                                            if flag3 then
                                                farm.waitUntil = v5 + 0.25
                                            end

                                            return
                                        end

                                        if not v21 then
                                            farm.message = v22
                                            return
                                        end
                                        local v23 = tbl4.tile(rawget(v6.world, v18), v13.X, v13.Y)
                                        local n3 = v23 or 0
                                        local v24 = tbl4.item(n3)
                                        local action = tbl4.action
                                        local x = v13.X
                                        local y = v13.Y
                                        local pthtSeed = v17 == "Plant" and farm.pthtSeed or farm.dirt
                                        local v25, v26 = action(v6, v17, x, y, pthtSeed, v18)

                                        if not v25 then
                                            if v26 == "Target layer changed" then
                                                farm.waitUntil = now3 + 0.1
                                                return
                                            end

                                            if v26 ~= "This tile is not placeable" and v26 ~= "Protected or unsupported tile" and v26 ~= "Foreground blocks background" then
                                                tbl4.farmStop(v26)
                                                tbl4.notice(v26, "Auto Farm")
                                                return
                                            end

                                            tbl4.finishFarmTile(v13, v15, v26)
                                            continue
                                        end

                                        local actionStarted = v15.actionStarted
                                        local v27 = actionStarted or now3
                                        v15.actionStarted = v27
                                        v15.attempts = v15.attempts + 1
                                        farm.actions = farm.actions + 1
                                        local waitUntil2 = v17 == "Break" and now3 + 0.15 or now3 + 0.08
                                        farm.waitUntil = waitUntil2
                                        local format = string.format
                                        local str2 = v17 == "Break" and (v18 == "bg" and "background" or "foreground") or v17 == "Plant" and tbl4.itemName(farm.pthtSeed) or v17 == "Harvest" and "tree" or "dirt"
                                        farm.message = format("%s %s (%d, %d)", v17, str2, v13.X, v13.Y)
                                        local v28 = tbl4.tile(rawget(v6.world, v18), v13.X, v13.Y)
                                        local n4 = v28 or 0

                                        if n3 == n4 then
                                            local attempts = v15.attempts
                                            local max = math.max
                                            local n5 = v24 and rawget(v24, "hits") or 3

                                            if max(15, n5 * 2 + 8) < attempts then
                                                tbl4.finishFarmTile(v13, v15, "No tile progress; target skipped")
                                            end
                                        end

                                        return
                                    end

                                    local cellSince = v15.cellSince
                                    local v21 = cellSince or now2
                                    v15.cellSince = v21
                                    if now2 - v15.cellSince > 3 then
                                        tbl4.finishFarmTile(v13, v15, "Item inside this tile was not picked up")
                                        continue
                                    end

                                    if not tbl3.collect.taking and not tbl3.farm.travel then
                                        tbl4.setWalk(v6, nil)
                                        tbl4.takeDrop(v6, flag2)
                                    end

                                    farm.message = "Collecting " .. tbl4.itemName(rawget(flag2, "id"))
                                    return
                                end

                                local finishFarmTile = tbl4.finishFarmTile
                                local flag2 = v16 == "skip" and v17 or nil
                                finishFarmTile(v13, v15, flag2)
                            end
                        end

                        local flag2 = false

                        for i, v12 in ipairs(tbl7) do
                            if v5 - v12[2].deferSince >= 3 then
                                tbl4.finishFarmTile(v12[1], v12[2], v12[3])
                            else
                                flag2 = true
                            end
                        end

                        if flag2 then
                            farm.waitUntil = v5 + 0.25
                        end

                        return
                    end

                    local v8, v9 = tbl4.storeStep(v6, now)

                    if v8 == nil then
                        tbl4.farmStop(v9)
                        tbl4.notice(v9, "Auto Farm")
                        return
                    end

                    if not v8 then
                        if farm.template == "PTHT" and farm.repeatCycle and tbl4.inventoryCount(v6, farm.pthtSeed) > 0 then
                            farm.storing = nil
                            farm.phase = "Plant"
                            farm.batchSize = 0
                            farm.skip = {}
                            farm.message = "Starting the next PTHT cycle"
                            return
                        end

                        local farmStop = tbl4.farmStop
                        local format = string.format
                        local template = farm.template
                        local totalSkipped = farm.totalSkipped
                        local recycled = farm.recycled
                        local lastSkip = farm.lastSkip
                        local str2 = lastSkip and " | " .. farm.lastSkip or ""
                        farmStop(format("%s complete | Skipped: %d | Recycled: %d%s", template, totalSkipped, recycled, str2))
                        return
                    end

                    farm.message = v9
                    return
                end

                tbl4.farmStop(v7)
                return
            end

            tbl4.farmReset("World changed")
            return
        end
    end
end

tbl4.farmUI = function(arg)
    local v5 = tbl4.section(arg, "Auto Farm", "package")

    tbl4.control(v5, "Dropdown", "FarmTemplate", {
        Title = "Template",
        Desc = "Auto Clear World breaks every breakable block. Auto DF digs a stair shaft on the left, then builds dirt rows with empty rows between them from the bottom to the top of the world. PTHT plants the selected seed on every free tile from the bottom up, waits until every tree is ready, then harvests from the bottom up. Break Block places and breaks the selected block next to you. Stacks that reach 200 are recycled while farming, and every item left in the world is collected at the end. Auto DF keeps Dirt, and keeps Dirt Seeds until the farm is built; PTHT keeps the selected seed and Break Block keeps the selected block; untradeable items are always kept.",
        Values = {"Auto Clear World", "Auto DF", "PTHT", "Break Block"},
        Value = "Auto Clear World",
        Callback = function(template)
            if table.find({"Auto Clear World", "Auto DF", "PTHT", "Break Block"}, template) then
                tbl4.farmReset("Template changed")
                tbl3.farm.template = template
            end
        end,
    })

    tbl4.control(v5, "Dropdown", "FarmBreakLayer", {
        Title = "Break Layer",
        Desc = "Auto Clear World only. Both clears foreground first, then background.",
        Values = {"Both", "Foreground", "Background"},
        Value = "Both",
        Callback = function(breakLayer)
            if table.find({"Both", "Foreground", "Background"}, breakLayer) then
                tbl4.farmReset("Break layer changed")
                tbl3.farm.breakLayer = breakLayer
            end
        end,
    })

    tbl4.toggle(v5, "FarmAutoRecycle", "Auto Recycle (200 Stack)", function(autoRecycle)
        tbl3.farm.autoRecycle = autoRecycle

        if not autoRecycle then
            tbl3.farm.recycling = nil
        end
    end, "Recycles 200-item stacks of Dirt, Cave Background, Lava, Rock, and their Seeds during Auto Clear World and Auto DF")

    tbl4.toggle(v5, "FarmEnabled", "Auto Farm", function(arg2)
        local farm = tbl3.farm
        if not arg2 then
            tbl4.farmStop("Stopped")
            return
        end
        local v6 = tbl4.scene()

        if not v6 then
            tbl4.set("FarmEnabled", false)
            tbl4.notice("Enter a world first.")
            return
        end

        if tbl3.factory and tbl3.factory.enabled then
            tbl4.factoryReset("Switched to Auto Farm")
        end

        local v7, v8 = tbl4.nativeActions(v6)

        if not v7 then
            tbl4.set("FarmEnabled", false)
            tbl4.notice(v8)
            return
        end

        if (farm.template ~= "PTHT" or farm.pthtSeed) and (farm.template ~= "Break Block" or farm.pnbBlock) then
            if farm.template == "Break Block" and (not farm.pnbOffsets or #farm.pnbOffsets == 0) then
                tbl4.set("FarmEnabled", false)
                tbl4.notice("Select at least 1 tile in the 7x7 grid first.")
                return
            end

            tbl4.farmReset("Starting", true)

            if farm.template == "Auto DF" then
                local v9, v10, v11 = tbl4.dfBounds(v6)
                farm.dfTop = v9
                farm.dfBottom = v10
                farm.dfParity = v11

                if not farm.dfTop or not farm.dfBottom then
                    tbl4.set("FarmEnabled", false)
                    tbl4.notice("No ground rows found for a dirt farm.")
                    return
                end
            end

            local world = rawget(v6.world, "name")
            farm.enabled = true
            farm.world = world
            farm.completed = 0
            farm.skipped = 0
            farm.batchSize = 0
            farm.totalSkipped = 0
            farm.actions = 0
            farm.teleports = 0
            farm.lastSkip = nil
            farm.recycled = 0
            farm.message = "Starting " .. farm.template
            return
        end

        tbl4.set("FarmEnabled", false)
        local notice = tbl4.notice
        local str2 = farm.template == "PTHT" and "Select a seed for PTHT first." or "Select a block for Break Block first."
        notice(str2)
    end)

    tbl3.ui.farmStatus = v5:Paragraph({Title = "Status", Body = "Stopped"})
    local v6 = tbl4.section(arg, "PTHT", "star")

    tbl3.ui.pthtSeed = tbl4.control(v6, "Dropdown", "PTHTSeed", {
        Title = "Seed",
        Desc = "Seed to plant across the whole world",
        Values = {"Refresh items first"},
        SearchBarEnabled = true,
        Callback = function(arg2)
            local farm = tbl3.farm
            local seedMapping = tbl3.farm.seedMapping
            local v7 = seedMapping and tbl3.farm.seedMapping[arg2] or nil
            farm.pthtSeed = v7
        end,
    })

    tbl4.toggle(v6, "PTHTRepeat", "Repeat", function(repeatCycle)
        tbl3.farm.repeatCycle = repeatCycle
    end, "Start a new cycle after every harvest while seeds are left")

    tbl4.button(v6, "Refresh Seeds", tbl4.farmOptions)
    local v7 = tbl4.section(arg, "Break Block", "target")

    tbl3.ui.pnbBlock = tbl4.control(v7, "Dropdown", "BreakBlock", {
        Title = "Block",
        Desc = "Block to place and break. MAGPLANT 5000 Remote is listed when you carry it.",
        Values = {"Refresh items first"},
        SearchBarEnabled = true,
        Callback = function(arg2)
            local farm = tbl3.farm
            local blockMapping = tbl3.farm.blockMapping
            local v8 = blockMapping and tbl3.farm.blockMapping[arg2] or nil
            farm.pnbBlock = v8
            tbl3.farm.pnbRemoteBlock = nil
        end,
    })

    tbl3.ui.pnbTiles = tbl4.control(v7, "TileGrid7x7", "BreakBlockTiles", {
        Title = "Place & Break Tiles (7x7)",
        Default = "1,0;2,0",
        Callback = function(arg2, arg3)
            local v8 = arg3

            if type(arg3) ~= "table" and type(arg2) == "string" then
                local tbl7 = {}
                v8 = tbl7

                for match in arg2:gmatch("[^;%s]+") do
                    local match2, v9 = match:match("^([%-]?%d+),([%-]?%d+)$")
                    local num = tonumber(match2)
                    local num2 = tonumber(v9)

                    if num and num2 and (num ~= 0 or num2 ~= 0) then
                        tbl7[#tbl7 + 1] = {DX = num, DY = num2}
                    end
                end
            end

            if type(v8) == "table" then
                tbl3.farm.pnbOffsets = v8

                if tbl3.farm.pnbTarget and tbl3.farm.pnbTarget.OriginX then
                    tbl4.rebuildPnbTarget(tbl4.scene(), tbl3.farm.pnbTarget.OriginX, tbl3.farm.pnbTarget.OriginY)
                else
                    tbl3.farm.pnbTarget = nil
                    tbl3.farm.pnbPlaced = nil
                end
            end
        end,
    })

    tbl4.button(v7, "Clear Selected Tiles", function()
        if tbl3.ui.pnbTiles then
            tbl3.ui.pnbTiles:SetValue("")
        end
    end)

    tbl4.button(v7, "Reset Default (2 Right)", function()
        if tbl3.ui.pnbTiles then
            tbl3.ui.pnbTiles:SetValue("1,0;2,0")
        end
    end)

    tbl4.button(v7, "Refresh Blocks", tbl4.farmOptions)
    local v8 = tbl4.section(arg, "Items", "backpack")

    tbl4.toggle(v8, "ItemCollect", "Auto Collect", function(enabled)
        local collect = tbl3.collect
        collect.enabled = enabled
        collect.drop = nil
        local message = enabled and "Searching" or "Off"
        collect.message = message

        if not tbl3.farm.enabled then
            local farm = tbl3.farm
            tbl3.farm.route = nil
            farm.travel = nil
        end

        tbl4.updateDropMagnet(tbl4.scene())
    end, "Auto collects floating items and gems within the radius in-place.")

    tbl4.control(v8, "Slider", "ItemCollectRadius", {
        Title = "Collect Radius",
        Desc = "Tiles",
        Min = 1,
        Max = 60,
        Default = 10,
        Step = 1,
        Callback = function(radius)
            tbl3.collect.radius = radius
            tbl4.updateDropMagnet(tbl4.scene())
        end,
    })

    tbl3.ui.collectStatus = v8:Paragraph({Title = "Collect Status", Body = "Off"})

    tbl3.ui.dropItem = tbl4.control(v8, "Dropdown", "DropItem", {
        Title = "Drop Item",
        Desc = "All droppable items in Growblox (searchable)",
        Values = {"Loading items..."},
        SearchBarEnabled = true,
        Callback = function(arg2)
            local drop = tbl3.drop
            local mapping = tbl3.drop.mapping
            local v9 = mapping and tbl3.drop.mapping[arg2] or nil
            drop.item = v9
        end,
    })

    tbl4.toggle(v8, "AutoDrop200", "Auto Drop (200 Stack)", function(auto)
        tbl3.drop.auto = auto
    end, "Automatically drops the selected Drop Item whenever its stack reaches 200 in your inventory")

    tbl4.control(v8, "Textbox", "DropAmount", {
        Title = "Drop Amount",
        Placeholder = "200",
        Default = "200",
        Callback = function(arg2)
            local num = tonumber(arg2)
            local drop = tbl3.drop
            local amount = num and num >= 1 and math.floor(num) or 200
            drop.amount = amount
        end,
    })

    tbl4.button(v8, "Fast Drop", tbl4.fastDrop)
    tbl3.ui.dropStatus = v8:Paragraph({Title = "Drop Status", Body = "Select an item"})
    tbl4.dropOptions()

    tbl4.spawn(function()
        local n = 0
        local n2 = 0

        while tbl3.hidup do
            tbl4.elevate()

            if n2 <= os.clock() then
                n2 = os.clock() + tbl3.farm.interval

                if tbl3.drop.auto then
                    pcall(tbl4.autoDropStep)
                end

                local enabled = tbl3.farm.enabled
                local farmStep = enabled and tbl4.farmStep

                if not farmStep then
                    local enabled2 = tbl3.factory.enabled
                    farmStep = enabled2 and tbl4.factoryStep
                end

                if not farmStep then
                    local enabled2 = tbl3.collect.enabled
                    farmStep = enabled2 and tbl4.collectOnly
                end

                local v9 = pcall
                local fn4 = farmStep or function() end
                local v10, v11 = v9(fn4)

                if not v10 then
                    tbl4.failure(v11)
                    tbl4.farmStop(tostring(v11))
                    tbl4.factoryStop(tostring(v11))
                    tbl4.set("ItemCollect", false)
                end
            end

            if n <= os.clock() then
                tbl4.elevate()
                n = os.clock() + 0.5
                local farm = tbl3.farm
                local lastFarmDesc = farm.message .. string.format("\nActions: %d | Teleports: %d | Tiles left: %d", farm.actions, farm.teleports, farm.left)

                if lastFarmDesc ~= tbl3.lastFarmDesc then
                    tbl3.lastFarmDesc = lastFarmDesc
                    tbl3.ui.farmStatus:SetDesc(lastFarmDesc)
                end

                if tbl3.ui.factoryStatus then
                    local factory = tbl3.factory
                    local lastFactoryDesc = string.format("%s\nPhase: %s | Cycles: %d | Actions: %d | Teleports: %d", factory.message, factory.phase, factory.cycles, farm.actions, farm.teleports)

                    if lastFactoryDesc ~= tbl3.lastFactoryDesc then
                        tbl3.lastFactoryDesc = lastFactoryDesc
                        tbl3.ui.factoryStatus:SetDesc(lastFactoryDesc)
                    end
                end

                if tbl3.ui.factoryInfo then
                    local v9 = tbl4.factoryInfoText()

                    if v9 ~= tbl3.lastFactoryInfo then
                        tbl3.lastFactoryInfo = v9
                        tbl3.ui.factoryInfo:SetDesc(v9)
                    end
                end

                local enabled = tbl3.collect.enabled
                local message = enabled and tbl3.collect.message or "Off"
                local lastCollectDesc = message .. string.format("\nCollected: %d", tbl3.collect.collected)

                if lastCollectDesc ~= tbl3.lastCollectDesc then
                    tbl3.lastCollectDesc = lastCollectDesc
                    tbl3.ui.collectStatus:SetDesc(lastCollectDesc)
                end

                if tbl3.drop.message ~= tbl3.lastDropDesc then
                    tbl3.lastDropDesc = tbl3.drop.message
                    tbl3.ui.dropStatus:SetDesc(tbl3.drop.message)
                end

                if not tbl3.farm.seedMapping and tbl4.scene() then
                    tbl4.farmOptions()
                end

                if not tbl3.factory.seedMapping then
                    tbl4.factoryOptions()
                end

                if not tbl3.drop.mapping then
                    tbl4.dropOptions()
                end
            end

            local wait = task.wait
            local enabled = tbl3.farm.enabled
            local n3 = (enabled or tbl3.factory.enabled or tbl3.collect.enabled or tbl3.drop.auto) and math.clamp(n2 - os.clock(), 0.01, 0.05) or 0.25
            wait(n3)
        end
    end)
end

tbl4.seedBlockId = function(arg)
    if type(arg) ~= "number" then
        return nil
    end
    local n = arg - 1
    local v5 = tbl4.item(n)
    local v6 = v5 and tbl4.breakable(n) and n or nil
    return v6
end

tbl4.factoryOptions = function()
    if not tbl3.ui.factorySeed then
        return
    end

    if tbl3.factory.allSeeds and #tbl3.factory.allSeeds > 0 then
        return
    end
    local allSeeds = {}
    local seedMapping = {}
    local v5 = pairs
    local items = tbl2.Items
    local tbl7 = items or {}

    for k, v6 in v5(tbl7) do
        if type(k) == "number" and type(v6) == "table" and rawget(v6, "kind") == "seed" then
            local value = rawget(v6, "name")

            if type(value) == "string" and value ~= "" then
                local str2 = value .. " [#" .. tostring(k) .. "]"

                if not seedMapping[str2] then
                    allSeeds[#allSeeds + 1] = str2
                    seedMapping[str2] = k
                end
            end
        end
    end

    table.sort(allSeeds)
    tbl3.factory.allSeeds = allSeeds
    tbl3.factory.seedMapping = seedMapping
    local factorySeed = tbl3.ui.factorySeed
    local refresh = factorySeed.Refresh
    local flag = #allSeeds > 0 and allSeeds

    if not flag then
        local tbl8 = {}
        flag = tbl8
        tbl8[1] = "No seeds loaded"
    end

    refresh(factorySeed, flag)

    for k, v6 in pairs(seedMapping) do
        if v6 == tbl3.factory.seed then
            tbl3.ui.factorySeed:SetValue(k)
            break
        end
    end
end

tbl4.countWorldTrees = function(arg, arg2)
    if not arg or not arg2 then
        return 0, 0
    end
    local world = arg.world
    local value = rawget(world, "fg")
    local n = 0
    local n2 = 0

    for i = 0, rawget(world, "h") - 1 do
        for i2 = 0, rawget(world, "w") - 1 do
            local v5 = tbl4.tile(value, i2, i)
            local n3 = v5 or 0

            if n3 == arg2 then
                n = n + 1

                if tbl4.ripeTree(arg, i2, i) then
                    n2 = n2 + 1
                end
            end
        end
    end

    return n, n2
end

tbl4.factoryInfoText = function()
    local seed = tbl3.factory.seed
    if not seed then
        return "Select a seed"
    end
    local v5 = tbl4.scene()
    local v6 = tbl4.seedBlockId(seed)
    local n = v5 and tbl4.inventoryCount(v5, seed) or 0
    local n2 = v5 and v6 and tbl4.inventoryCount(v5, v6) or 0
    local n3 = v5 and tbl4.countWorldTrees(v5, seed) or 0
    local tbl7 = {}
    local format = string.format
    local v7 = tbl4.itemName(seed)
    local str2 = v6 and tbl4.itemName(v6) or "None"
    local v8 = format("Target: %s | Block: %s", v7, str2)
    local v9 = table.pack(string.format("Inventory Seeds: %d | Blocks: %d | World Trees: %d", n, n2, n3))
    tbl7[1] = v8
    __store_list(tbl7, 2, table.unpack(v9, 1, v9.n))
    local recipeByResult = tbl2.RecipeByResult
    local v10 = recipeByResult and tbl2.RecipeByResult[seed]

    if v10 then
        local n4 = v5 and tbl4.inventoryCount(v5, v10.A) or 0
        local n5 = v5 and tbl4.inventoryCount(v5, v10.B) or 0
        tbl7[#tbl7 + 1] = string.format("Splice Recipe: %s (%d) + %s (%d)", tbl4.itemName(v10.A), n4, tbl4.itemName(v10.B), n5)
    else
        tbl7[#tbl7 + 1] = "Splice Recipe: None (requires seed or block in inventory/world)"
    end

    return table.concat(tbl7, "\n")
end

tbl4.hasSeedSource = function(arg, arg2, arg3)
    if not arg or not arg3 then
        return false
    end

    if tbl4.inventoryCount(arg, arg3) > 0 then
        return true
    end

    if tbl4.countWorldTrees(arg, arg3) > 0 then
        return true
    end
    local v5 = tbl4.seedBlockId(arg3)
    if v5 and tbl4.inventoryCount(arg, v5) > 0 then
        return true
    end
    local tbl7 = {}
    tbl7[arg3] = true

    if v5 then
        tbl7[v5] = true
    end

    local flag = tbl4.nextDrop(arg, arg2, math.huge, tbl7) ~= nil
    return flag
end

tbl4.hasUnsplicedBaseTree = function(arg, arg2)
    local world = arg.world
    local value = rawget(world, "fg")
    local value2 = rawget(world, "w")

    for i = 0, rawget(world, "h") - 1 do
        for i2 = 0, value2 - 1 do
            local v5 = tbl4.tile(value, i2, i)
            local n = v5 or 0

            if n == arg2 and not tbl4.ripeTree(arg, i2, i) then
                local v6 = tbl4.treeState(arg, i * value2 + i2)
                if not v6 or not rawget(v6, "s") then
                    return true
                end
            end
        end
    end

    return false
end

tbl4.resolveFactoryTarget = function(arg, arg2, arg3, arg4)
    local tbl7, v5, enabled, n, tbl8, nextDrop, v6, tbl9, nextDrop2, autoSplice, recipeByResult, flag, tbl10, nextDrop3, flag2, tbl11, nextDrop4, flag3, tbl12, nextDrop5
    local v7, v8, v9, str2, v10, v11, v12, str3, n2
    n2 = 1

    while true do
        if n2 <= 33 then
            if n2 <= 16 then
                if n2 == 1 then
                    if arg3 then
                        n2 = 2
                    else
                        n2 = 66
                    end
                elseif n2 == 2 then
                    tbl7 = arg4

                    if arg4 then
                        n2 = 4
                    else
                        n2 = 3
                    end
                elseif n2 == 3 then
                    tbl7 = {}
                    n2 = 4
                elseif n2 == 4 then
                    v5 = tbl7

                    if tbl7[arg3] then
                        n2 = 5
                    else
                        n2 = 6
                    end
                elseif n2 == 5 then
                    return nil, nil, "Circular splice recipe detected"
                elseif n2 == 6 then
                    v5[arg3] = true
                    enabled = tbl3.collect.enabled
                    n = enabled

                    if enabled then
                        n2 = 7
                    else
                        n2 = 8
                    end
                elseif n2 == 7 then
                    n = math.max(tbl3.collect.radius, 30)
                    n2 = 8
                elseif n2 == 8 then
                    if n then
                        n2 = 10
                    else
                        n2 = 9
                    end
                elseif n2 == 9 then
                    n = 30
                    n2 = 10
                elseif n2 == 10 then
                    if tbl4.inventoryCount(arg, arg3) > 0 then
                        n2 = 65
                    else
                        n2 = 11
                    end
                elseif n2 == 11 then
                    tbl8 = {}
                    nextDrop = tbl4.nextDrop
                    tbl8[arg3] = true

                    if nextDrop(arg, arg2, n, tbl8) == nil then
                        n2 = 12
                    else
                        n2 = 65
                    end
                elseif n2 == 12 then
                    v6 = tbl4.seedBlockId(arg3)

                    if v6 then
                        n2 = 13
                    else
                        n2 = 16
                    end
                elseif n2 == 13 then
                    if tbl4.inventoryCount(arg, v6) > 0 then
                        n2 = 15
                    else
                        n2 = 14
                    end
                elseif n2 == 14 then
                    tbl9 = {}
                    nextDrop2 = tbl4.nextDrop
                    tbl9[v6] = true

                    if nextDrop2(arg, arg2, n, tbl9) == nil then
                        n2 = 16
                    else
                        n2 = 15
                    end
                elseif n2 == 15 then
                    return arg3, nil
                elseif n2 == 16 then
                    autoSplice = tbl3.factory.autoSplice
                    recipeByResult = autoSplice

                    if autoSplice then
                        n2 = 17
                    else
                        n2 = 18
                    end
                end
            elseif n2 == 17 then
                recipeByResult = tbl2.RecipeByResult
                n2 = 18
            elseif n2 == 18 then
                if recipeByResult then
                    n2 = 19
                else
                    n2 = 20
                end
            elseif n2 == 19 then
                recipeByResult = tbl2.RecipeByResult[arg3]
                n2 = 20
            elseif n2 == 20 then
                if recipeByResult then
                    n2 = 22
                else
                    n2 = 21
                end
            elseif n2 == 21 then
                recipeByResult = nil
                n2 = 22
            elseif n2 == 22 then
                if recipeByResult then
                    n2 = 23
                else
                    n2 = 41
                end
            elseif n2 == 23 then
                if tbl4.inventoryCount(arg, recipeByResult.B) > 0 then
                    n2 = 25
                else
                    n2 = 24
                end
            elseif n2 == 24 then
                flag = false
                n2 = 26
            elseif n2 == 25 then
                flag = true
                n2 = 26
            elseif n2 == 26 then
                if flag then
                    n2 = 30
                else
                    n2 = 27
                end
            elseif n2 == 27 then
                tbl10 = {}
                nextDrop3 = tbl4.nextDrop
                tbl10[recipeByResult.B] = true

                if nextDrop3(arg, arg2, n, tbl10) == nil then
                    n2 = 29
                else
                    n2 = 28
                end
            elseif n2 == 28 then
                flag = true
                n2 = 30
            elseif n2 == 29 then
                flag = false
                n2 = 30
            elseif n2 == 30 then
                if flag and tbl4.hasUnsplicedBaseTree(arg, recipeByResult.A) then
                    n2 = 40
                else
                    n2 = 31
                end
            elseif n2 == 31 then
                if tbl4.inventoryCount(arg, recipeByResult.A) > 0 then
                    n2 = 33
                else
                    n2 = 32
                end
            elseif n2 == 32 then
                flag2 = false
                n2 = 34
            elseif n2 == 33 then
                flag2 = true
                n2 = 34
            end
        elseif n2 <= 49 then
            if n2 == 34 then
                if flag2 then
                    n2 = 38
                else
                    n2 = 35
                end
            elseif n2 == 35 then
                tbl11 = {}
                nextDrop4 = tbl4.nextDrop
                tbl11[recipeByResult.A] = true

                if nextDrop4(arg, arg2, n, tbl11) == nil then
                    n2 = 37
                else
                    n2 = 36
                end
            elseif n2 == 36 then
                flag2 = true
                n2 = 38
            elseif n2 == 37 then
                flag2 = false
                n2 = 38
            elseif n2 == 38 then
                if flag2 and flag then
                    n2 = 39
                else
                    n2 = 41
                end
            elseif n2 == 39 then
                return arg3, recipeByResult
            elseif n2 == 40 then
                return arg3, recipeByResult
            elseif n2 == 41 then
                if tbl4.countWorldTrees(arg, arg3) > 0 then
                    n2 = 64
                else
                    n2 = 42
                end
            elseif n2 == 42 then
                if tbl3.factory.autoSplice then
                    n2 = 43
                else
                    n2 = 63
                end
            elseif n2 == 43 then
                if recipeByResult then
                    n2 = 44
                else
                    n2 = 62
                end
            elseif n2 == 44 then
                if tbl4.inventoryCount(arg, recipeByResult.A) > 0 then
                    n2 = 46
                else
                    n2 = 45
                end
            elseif n2 == 45 then
                flag3 = false
                n2 = 47
            elseif n2 == 46 then
                flag3 = true
                n2 = 47
            elseif n2 == 47 then
                if flag3 then
                    n2 = 51
                else
                    n2 = 48
                end
            elseif n2 == 48 then
                tbl12 = {}
                nextDrop5 = tbl4.nextDrop
                tbl12[recipeByResult.A] = true

                if nextDrop5(arg, arg2, n, tbl12) == nil then
                    n2 = 50
                else
                    n2 = 49
                end
            elseif n2 == 49 then
                flag3 = true
                n2 = 51
            end
        elseif n2 == 50 then
            flag3 = false
            n2 = 51
        elseif n2 == 51 then
            if flag3 then
                n2 = 52
            else
                n2 = 57
            end
        elseif n2 == 52 then
            v7, v8, v9 = tbl4.resolveFactoryTarget(arg, arg2, recipeByResult.B, table.clone(v5))

            if v7 then
                n2 = 53
            else
                n2 = 54
            end
        elseif n2 == 53 then
            return v7, v8
        elseif n2 == 54 then
            str2 = v9

            if v9 then
                n2 = 56
            else
                n2 = 55
            end
        elseif n2 == 55 then
            str2 = "Missing ingredient: " .. tbl4.itemName(recipeByResult.B)
            n2 = 56
        elseif n2 == 56 then
            return nil, nil, str2
        elseif n2 == 57 then
            v10, v11, v12 = tbl4.resolveFactoryTarget(arg, arg2, recipeByResult.A, table.clone(v5))

            if v10 then
                n2 = 58
            else
                n2 = 59
            end
        elseif n2 == 58 then
            return v10, v11
        elseif n2 == 59 then
            str3 = v12

            if v12 then
                n2 = 61
            else
                n2 = 60
            end
        elseif n2 == 60 then
            str3 = "Missing ingredient: " .. tbl4.itemName(recipeByResult.A)
            n2 = 61
        elseif n2 == 61 then
            return nil, nil, str3
        elseif n2 == 62 then
            return nil, nil, "No " .. tbl4.itemName(arg3) .. " in inventory/world and no splice recipe exists"
        elseif n2 == 63 then
            return nil, nil, "Out of " .. tbl4.itemName(arg3) .. " (enable Auto Splice Recipe or add seeds)"
        elseif n2 == 64 then
            return arg3, nil
        elseif n2 == 65 then
            return arg3, nil
        elseif n2 == 66 then
            return nil, nil, "Select a seed first"
        end
    end
end

tbl4.isFactoryBreakCell = function(arg, arg2)
    local factory = tbl3.factory
    local breakX = factory.breakX
    local autoBreakX = breakX or factory.autoBreakX
    local breakY = factory.breakY
    local autoBreakY = breakY or factory.autoBreakY
    if not autoBreakX or not autoBreakY then
        return false
    end

    if arg == autoBreakX and arg2 == autoBreakY then
        return true
    end
    local v5 = ipairs
    local breakOffsets = factory.breakOffsets
    local tbl7 = breakOffsets or {}

    for k, v6 in v5(tbl7) do
        if arg == autoBreakX + v6.DX and arg2 == autoBreakY + v6.DY then
            return true
        end
    end

    return false
end

tbl4.factoryWork = function(arg, arg2, arg3)
    local factory = tbl3.factory
    local world = arg.world
    local value = rawget(world, "w")
    local v5 = tbl4.tile(rawget(world, "fg"), arg2, arg3)
    local n = v5 or 0

    if factory.phase == "Harvest" then
        if n == factory.activeSeed and tbl4.ripeTree(arg, arg2, arg3) then
            return "Harvest", "fg", n, factory.activeSeed
        end
        return nil
    end

    if factory.phase ~= "Plant" then
        return nil
    end

    if tbl4.isFactoryBreakCell(arg2, arg3) or arg2 < 3 or value - 3 <= arg2 then
        return nil
    end
    local spliceRecipe = factory.spliceRecipe

    if not spliceRecipe then
        if n == 0 and factory.activeSeed and tbl4.inventoryCount(arg, factory.activeSeed) > 0 and tbl4.safeLanding(arg, arg2, arg3, nil, "Plant") then
            return "Plant", "fg", 0, factory.activeSeed
        end
        return nil
    end

    if n == spliceRecipe.A and not tbl4.ripeTree(arg, arg2, arg3) and tbl4.inventoryCount(arg, spliceRecipe.B) > 0 then
        local v6 = tbl4.treeState(arg, arg3 * value + arg2)
        if not v6 then
            return "WaitTree", "fg", n, spliceRecipe.B
        end

        if not rawget(v6, "s") then
            return "Splice", "fg", n, spliceRecipe.B
        end
    elseif n == 0 and tbl4.inventoryCount(arg, spliceRecipe.A) > 0 and tbl4.inventoryCount(arg, spliceRecipe.B) > 0 and tbl4.safeLanding(arg, arg2, arg3, nil, "Plant") then
        return "Plant", "fg", 0, spliceRecipe.A
    end

    return nil
end

tbl4.factoryBatch = function(arg)
    local farm = tbl3.farm
    local world = arg.world
    local value = rawget(world, "w")
    local value2 = rawget(world, "h")
    local value3 = rawget(world, "areas")
    local value4 = value3 and rawget(value3, "mayBuild")
    if type(value4) ~= "function" then
        return nil, "Native build permission check changed"
    end
    local value5 = rawget(world, "lock")
    local tbl7 = {}
    local n = 0

    for i = 0, value2 - 1 do
        local n2 = value2 - 1 - i

        for i2 = 0, value - 1 do
            local n3 = i % 2 == 0 and i2 or value - 1 - i2
            local n4 = n2 * value + n3

            if not farm.skip[n4] and tbl4.factoryWork(arg, n3, n2) and value4(value5, n3, n2) then
                n = n + 1

                if #tbl7 < 64 then
                    tbl7[#tbl7 + 1] = {X = n3, Y = n2, Key = n4}
                end
            end
        end
    end

    return tbl7, n
end

tbl4.factoryWait = function(arg, arg2)
    local world = arg.world
    local v5 = nil
    local n = 0
    local n2 = 0

    for i = 0, rawget(world, "h") - 1 do
        for i2 = 0, rawget(world, "w") - 1 do
            local v6 = tbl4.tile(rawget(world, "fg"), i2, i)
            local n3 = v6 or 0

            if n3 == arg2 then
                n = n + 1
                local v7, v8 = tbl4.ripeTree(arg, i2, i)

                if v7 then
                    n2 = n2 + 1
                elseif v8 then
                    local max = math.max
                    local n4 = v5 or 0
                    v5 = max(n4, v8)
                else
                    local max = math.max
                    local n4 = v5 or 0
                    v5 = max(n4, 1)
                end
            end
        end
    end

    return v5, n, n2
end

tbl4.validFactoryBreakOrigin = function(arg, arg2, arg3, arg4)
    if not tbl4.safeLanding(arg, arg2, arg3, nil, "Collect") then
        return false
    end
    local world = arg.world
    local value = rawget(world, "w")
    local value2 = rawget(world, "h")
    local value3 = rawget(world, "areas")
    local value4 = value3 and rawget(value3, "mayBuild")
    local value5 = rawget(world, "lock")
    local v5 = tbl4.item(arg4)
    local value6 = v5 and rawget(v5, "background")
    local n = 0
    local v6 = ipairs
    local breakOffsets = tbl3.factory.breakOffsets
    local tbl7 = breakOffsets or {}

    for k, v7 in v6(tbl7) do
        local n2 = arg2 + v7.DX
        local n3 = arg3 + v7.DY

        if n2 >= 0 and n3 >= 0 and n2 < value and n3 < value2 then
            if type(value4) == "function" and not value4(value5, n2, n3) then
                return false
            end
            local v8 = tbl4.tile(rawget(world, "fg"), n2, n3)
            local n4 = v8 or 0
            local v9 = tbl4.tile(rawget(world, "bg"), n2, n3)
            local n5 = v9 or 0

            if value6 then
                if n4 ~= 0 or n5 ~= 0 and n5 ~= arg4 then
                    return false
                end
            elseif n4 ~= 0 and n4 ~= arg4 then
                return false
            end

            n = n + 1
        end
    end

    local flag = n > 0
    return flag
end

tbl4.findFactoryBreakOrigin = function(arg, arg2)
    local factory = tbl3.factory
    if factory.breakX and factory.breakY then
        return factory.breakX, factory.breakY
    end

    if factory.autoBreakX and factory.autoBreakY and tbl4.validFactoryBreakOrigin(arg, factory.autoBreakX, factory.autoBreakY, arg2) then
        return factory.autoBreakX, factory.autoBreakY
    end
    local v5, v6 = tbl4.coords(arg)
    local autoBreakX = v5 and math.floor(v5) or 50
    local autoBreakY = v6 and math.floor(v6 - 0.001) or 36

    if not tbl4.validFactoryBreakOrigin(arg, autoBreakX, autoBreakY, arg2) then
        local world = arg.world
        local value = rawget(world, "w")
        local v7 = nil
        local v8 = nil
        local v9 = nil

        for i = 0, rawget(world, "h") - 2 do
            for i2 = 3, value - 4 do
                if tbl4.validFactoryBreakOrigin(arg, i2, i, arg2) then
                    local n = (i2 - autoBreakX) ^ 2 + (i - autoBreakY) ^ 2 * 16

                    if not v9 or n < v9 then
                        v7 = i2
                        v8 = i
                        v9 = n
                    end
                end
            end
        end

        local v10 = v7 or autoBreakX
        local v11 = v8 or autoBreakY
        factory.autoBreakX = v10
        factory.autoBreakY = v11
        return factory.autoBreakX, factory.autoBreakY
    end

    factory.autoBreakX = autoBreakX
    factory.autoBreakY = autoBreakY
    return autoBreakX, autoBreakY
end

tbl4.factoryStep = function()
    local factory, farm, now, v5, waitUntil, n, v6, v7, v8, v9, v10, result, spliceRecipe, result2, activeSeed, n2, v11, spliceRecipe2, n3, v12
    local v13, v14, enabled, n4, tbl7, flag, v15, v16, v17, v18, v19, tbl8, a, flag2, b, flag3, tbl9, flag4, tbl10, nextDrop
    local tbl11, v20, v21, v22, v23, v24, v25, v26, v27, tbl12, now2, v28, v29, v30, v31, str2, waitTreeSince, v32, previous, approach
    local flag5, v33, v34, now3, v35, n5, v36, v37, actionStarted, v38, waitUntil2, v39, n6, deferSince, v40, v41, v42, v43, v44, tbl13
    local now4, v45, v46, v47, v48, str3, waitTreeSince2, v49, previous2, approach2, flag6, v50, v51, now5, v52, n7, v53, v54, actionStarted2, v55
    local waitUntil3, v56, n8, deferSince2, v57, flag7, v58, v59, v60, v61, v62, v63, flag8, v64, v65, v66, v67, v68, v69, flag9
    local v70, value, v71, v72, v73, v74, v75, v76, v77, n9, v78, v79, v80, v81, v82, v83, n10, n11, flag10, v84
    local v85, message, v86, v87, tbl14, flag11, n12
    n12 = 1

    while true do
        if n12 <= 145 then
            if n12 <= 72 then
                if n12 <= 36 then
                    if n12 <= 18 then
                        if n12 == 1 then
                            factory = tbl3.factory
                            farm = tbl3.farm
                            now = os.clock()
                            v5 = now

                            if factory.enabled then
                                n12 = 2
                            else
                                n12 = 291
                            end
                        elseif n12 == 2 then
                            waitUntil = farm.waitUntil
                            n = waitUntil

                            if waitUntil then
                                n12 = 4
                            else
                                n12 = 3
                            end
                        elseif n12 == 3 then
                            n = 0
                            n12 = 4
                        elseif n12 == 4 then
                            if now < n then
                                n12 = 291
                            else
                                n12 = 5
                            end
                        elseif n12 == 5 then
                            v6 = tbl4.scene()

                            if v6 and factory.world == rawget(v6.world, "name") then
                                n12 = 7
                            else
                                n12 = 6
                            end
                        elseif n12 == 6 then
                            tbl4.factoryReset("World changed")
                            return
                        elseif n12 == 7 then
                            v7 = tbl4.moveBlocked(v6)

                            if v7 then
                                n12 = 8
                            else
                                n12 = 9
                            end
                        elseif n12 == 8 then
                            tbl4.factoryStop(v7)
                            return
                        elseif n12 == 9 then
                            if factory.seed then
                                n12 = 10
                            else
                                n12 = 290
                            end
                        elseif n12 == 10 then
                            if factory.activeSeed and factory.phase ~= "Plant" then
                                n12 = 20
                            else
                                n12 = 11
                            end
                        elseif n12 == 11 then
                            v8, v9, v10 = tbl4.resolveFactoryTarget(v6, now, factory.seed)

                            if v8 then
                                n12 = 12
                            else
                                n12 = 19
                            end
                        elseif n12 == 12 then
                            if v8 == factory.activeSeed then
                                n12 = 13
                            else
                                n12 = 18
                            end
                        elseif n12 == 13 then
                            result = v9

                            if v9 then
                                n12 = 14
                            else
                                n12 = 15
                            end
                        elseif n12 == 14 then
                            result = v9.Result
                            n12 = 15
                        elseif n12 == 15 then
                            spliceRecipe = factory.spliceRecipe
                            result2 = spliceRecipe

                            if spliceRecipe then
                                n12 = 16
                            else
                                n12 = 17
                            end
                        elseif n12 == 16 then
                            result2 = factory.spliceRecipe.Result
                            n12 = 17
                        elseif n12 == 17 then
                            if result == result2 then
                                n12 = 20
                            else
                                n12 = 18
                            end
                        elseif n12 == 18 then
                            factory.activeSeed = v8
                            factory.spliceRecipe = v9
                            farm.batchSize = 0
                            farm.skip = {}
                            farm.route = nil
                            n12 = 20
                        end
                    elseif n12 == 19 then
                        tbl4.factoryStop(v10)
                        tbl4.notice(v10, "Factory")
                        return
                    elseif n12 == 20 then
                        activeSeed = factory.activeSeed
                        n2 = 449967929
                        v11 = tbl4.seedBlockId(activeSeed)
                        spliceRecipe2 = factory.spliceRecipe
                        n3 = 86230827

                        if factory.phase == "Wait" then
                            n12 = 21
                        else
                            n12 = 24
                        end
                    elseif n12 == 21 then
                        tbl4.takePassing(v6, now)
                        v12, v13, v14 = tbl4.factoryWait(v6, activeSeed)

                        if v13 == 0 then
                            n12 = 289
                        else
                            n12 = 22
                        end
                    elseif n12 == 22 then
                        if v12 and v12 > 0 then
                            n12 = 288
                        else
                            n12 = 23
                        end
                    elseif n12 == 23 then
                        factory.phase = "Harvest"
                        farm.batchSize = 0
                        farm.skip = {}
                        farm.route = nil
                        n12 = 24
                    elseif n12 == 24 then
                        enabled = tbl3.collect.enabled
                        n4 = enabled

                        if enabled then
                            n12 = 25
                        else
                            n12 = 26
                        end
                    elseif n12 == 25 then
                        n4 = math.max(tbl3.collect.radius, 30)
                        n12 = 26
                    elseif n12 == 26 then
                        if n4 then
                            n12 = 28
                        else
                            n12 = 27
                        end
                    elseif n12 == 27 then
                        n4 = 30
                        n12 = 28
                    elseif n12 == 28 then
                        if factory.phase == "Collect" then
                            n12 = 29
                        else
                            n12 = 34
                        end
                    elseif n12 == 29 then
                        tbl7 = {}
                        tbl7[activeSeed] = true
                        tbl7[112] = true

                        if v11 then
                            n12 = 30
                        else
                            n12 = 31
                        end
                    elseif n12 == 30 then
                        tbl7[v11] = true
                        n12 = 31
                    elseif n12 == 31 then
                        if not tbl4.takePassing(v6, now, tbl7, n4) and not tbl3.collect.taking then
                            n12 = 33
                        else
                            n12 = 32
                        end
                    elseif n12 == 32 then
                        factory.message = "Collecting " .. tbl4.itemName(activeSeed)
                        return
                    elseif n12 == 33 then
                        factory.phase = "Break"
                        farm.pnbTarget = nil
                        farm.pnbStage = "Place"
                        farm.route = nil
                        n12 = 34
                    elseif n12 == 34 then
                        if factory.phase == "Break" then
                            n12 = 227
                        else
                            n12 = 35
                        end
                    elseif n12 == 35 then
                        if #farm.targets < farm.index then
                            n12 = 37
                        else
                            n12 = 36
                        end
                    elseif n12 == 36 then
                        flag = false
                        n12 = 38
                    end
                elseif n12 <= 54 then
                    if n12 == 37 then
                        flag = true
                        n12 = 38
                    elseif n12 == 38 then
                        if flag then
                            n12 = 42
                        else
                            n12 = 39
                        end
                    elseif n12 == 39 then
                        if farm.batchSize <= farm.completed + farm.skipped then
                            n12 = 41
                        else
                            n12 = 40
                        end
                    elseif n12 == 40 then
                        flag = false
                        n12 = 42
                    elseif n12 == 41 then
                        flag = true
                        n12 = 42
                    elseif n12 == 42 then
                        if flag then
                            n12 = 43
                        else
                            n12 = 82
                        end
                    elseif n12 == 43 then
                        if farm.completed > 0 then
                            n12 = 44
                        else
                            n12 = 45
                        end
                    elseif n12 == 44 then
                        farm.skip = {}
                        n12 = 45
                    elseif n12 == 45 then
                        v15, v16 = tbl4.factoryBatch(v6)

                        if v15 then
                            n12 = 46
                        else
                            n12 = 81
                        end
                    elseif n12 == 46 then
                        if #v15 == 0 then
                            n12 = 48
                        else
                            n12 = 47
                        end
                    elseif n12 == 47 then
                        farm.targets = v15
                        farm.records = {}
                        farm.index = 1
                        farm.left = v16
                        farm.completed = 0
                        farm.skipped = 0
                        farm.batchSize = #v15
                        n12 = 82
                    elseif n12 == 48 then
                        if factory.phase == "Plant" then
                            n12 = 53
                        else
                            n12 = 49
                        end
                    elseif n12 == 49 then
                        v18, v17 = tbl4.factoryWait(v6, activeSeed)

                        if v17 > 0 and (not v11 or tbl4.inventoryCount(v6, v11) < 200) then
                            n12 = 51
                        else
                            n12 = 50
                        end
                    elseif n12 == 50 then
                        factory.phase = "Collect"
                        farm.batchSize = 0
                        farm.skip = {}
                        n12 = 52
                    elseif n12 == 51 then
                        factory.phase = "Wait"
                        farm.batchSize = 0
                        farm.skip = {}
                        n12 = 52
                    elseif n12 == 52 then
                        return
                    elseif n12 == 53 then
                        v19 = spliceRecipe2

                        if spliceRecipe2 then
                            n12 = 54
                        else
                            n12 = 65
                        end
                    elseif n12 == 54 then
                        tbl8 = {}
                        v19 = tbl8
                        a = spliceRecipe2.A

                        if tbl4.inventoryCount(v6, spliceRecipe2.A) == 0 then
                            n12 = 56
                        else
                            n12 = 55
                        end
                    end
                elseif n12 == 55 then
                    flag2 = false
                    n12 = 57
                elseif n12 == 56 then
                    flag2 = true
                    n12 = 57
                elseif n12 == 57 then
                    if flag2 then
                        n12 = 59
                    else
                        n12 = 58
                    end
                elseif n12 == 58 then
                    flag2 = nil
                    n12 = 59
                elseif n12 == 59 then
                    tbl8[a] = flag2
                    b = spliceRecipe2.B

                    if tbl4.inventoryCount(v6, spliceRecipe2.B) == 0 then
                        n12 = 61
                    else
                        n12 = 60
                    end
                elseif n12 == 60 then
                    flag3 = false
                    n12 = 62
                elseif n12 == 61 then
                    flag3 = true
                    n12 = 62
                elseif n12 == 62 then
                    if flag3 then
                        n12 = 64
                    else
                        n12 = 63
                    end
                elseif n12 == 63 then
                    flag3 = nil
                    n12 = 64
                elseif n12 == 64 then
                    tbl8[b] = flag3
                    n12 = 65
                elseif n12 == 65 then
                    if v19 then
                        n12 = 72
                    else
                        n12 = 66
                    end
                elseif n12 == 66 then
                    tbl9 = {}
                    v19 = tbl9

                    if tbl4.inventoryCount(v6, activeSeed) == 0 then
                        n12 = 68
                    else
                        n12 = 67
                    end
                elseif n12 == 67 then
                    flag4 = false
                    n12 = 69
                elseif n12 == 68 then
                    flag4 = true
                    n12 = 69
                elseif n12 == 69 then
                    if flag4 then
                        n12 = 71
                    else
                        n12 = 70
                    end
                elseif n12 == 70 then
                    flag4 = nil
                    n12 = 71
                elseif n12 == 71 then
                    tbl9[activeSeed] = flag4
                    n12 = 72
                elseif n12 == 72 then
                    if next(v19) and (tbl4.takePassing(v6, now, v19, n4) or tbl3.collect.taking) then
                        n12 = 80
                    else
                        n12 = 73
                    end
                end
            elseif n12 <= 108 then
                if n12 <= 90 then
                    if n12 == 73 then
                        if tbl4.countWorldTrees(v6, activeSeed) > 0 then
                            n12 = 79
                        else
                            n12 = 74
                        end
                    elseif n12 == 74 then
                        if v11 then
                            n12 = 75
                        else
                            n12 = 78
                        end
                    elseif n12 == 75 then
                        if tbl4.inventoryCount(v6, v11) > 0 then
                            n12 = 77
                        else
                            n12 = 76
                        end
                    elseif n12 == 76 then
                        tbl10 = {}
                        nextDrop = tbl4.nextDrop
                        tbl10[v11] = true

                        if nextDrop(v6, now, n4, tbl10) then
                            n12 = 77
                        else
                            n12 = 78
                        end
                    elseif n12 == 77 then
                        factory.phase = "Collect"
                        farm.batchSize = 0
                        farm.skip = {}
                        factory.message = "Collecting blocks"
                        return
                    elseif n12 == 78 then
                        tbl4.factoryStop("No empty farm tiles or seeds available")
                        return
                    elseif n12 == 79 then
                        factory.spliceRecipe = nil
                        factory.phase = "Wait"
                        farm.batchSize = 0
                        farm.skip = {}
                        factory.message = "Waiting for trees"
                        return
                    elseif n12 == 80 then
                        factory.message = "Collecting floating seeds"
                        return
                    elseif n12 == 81 then
                        tbl4.factoryStop(v16)
                        return
                    elseif n12 == 82 then
                        tbl4.takePassing(v6, now)
                        tbl11 = {}
                        v20, v21, v22 = ipairs(farm.targets)
                        v23 = v22
                        n12 = 83
                    elseif n12 == 83 then
                        v24, v25 = v20(v21, v23)

                        if v24 == nil then
                            n12 = 219
                        else
                            n12 = 84
                        end
                    elseif n12 == 84 then
                        v23 = v24
                        v26 = farm.records[v24]
                        v27 = v26

                        if v26 then
                            n12 = 86
                        else
                            n12 = 85
                        end
                    elseif n12 == 85 then
                        tbl12 = {attempts = 0}
                        v27 = tbl12
                        farm.records[v24] = tbl12
                        n12 = 86
                    elseif n12 == 86 then
                        if v27.done then
                            n12 = 83
                        else
                            n12 = 87
                        end
                    elseif n12 == 87 then
                        now2 = os.clock()
                        v5 = now2

                        if v27.deferUntil then
                            n12 = 88
                        else
                            n12 = 92
                        end
                    elseif n12 == 88 then
                        if now2 < v27.deferUntil then
                            n12 = 91
                        else
                            n12 = 89
                        end
                    elseif n12 == 89 then
                        if v27.deferSince and now2 - v27.deferSince >= 3 then
                            n12 = 90
                        else
                            n12 = 92
                        end
                    elseif n12 == 90 then
                        tbl4.finishFarmTile(v25, v27, v27.deferReason)
                        n12 = 83
                    end
                elseif n12 == 91 then
                    tbl11[#tbl11 + 1] = {v25, v27, v27.deferReason}
                    n12 = 83
                elseif n12 == 92 then
                    farm.index = v24
                    v28, v29, v30, v31 = tbl4.factoryWork(v6, v25.X, v25.Y)
                    str2 = v28

                    if v28 then
                        n12 = 93
                    else
                        n12 = 218
                    end
                elseif n12 == 93 then
                    if v28 == "WaitTree" then
                        n12 = 94
                    else
                        n12 = 98
                    end
                elseif n12 == 94 then
                    waitTreeSince = v27.waitTreeSince
                    v32 = waitTreeSince

                    if waitTreeSince then
                        n12 = 96
                    else
                        n12 = 95
                    end
                elseif n12 == 95 then
                    v32 = now2
                    n12 = 96
                elseif n12 == 96 then
                    v27.waitTreeSince = v32

                    if now2 - v27.waitTreeSince < 2 then
                        n12 = 217
                    else
                        n12 = 97
                    end
                elseif n12 == 97 then
                    str2 = "Splice"
                    n12 = 98
                elseif n12 == 98 then
                    previous = str2 .. ":" .. tostring(v30) .. ":" .. tostring(v31)

                    if previous == v27.previous then
                        n12 = 100
                    else
                        n12 = 99
                    end
                elseif n12 == 99 then
                    v27.previous = previous
                    v27.attempts = 0
                    v27.actionStarted = nil
                    n12 = 100
                elseif n12 == 100 then
                    approach = tbl4.approach

                    if str2 == "Splice" then
                        n12 = 102
                    else
                        n12 = 101
                    end
                elseif n12 == 101 then
                    flag5 = false
                    n12 = 103
                elseif n12 == 102 then
                    flag5 = true
                    n12 = 103
                elseif n12 == 103 then
                    if flag5 then
                        n12 = 104
                    else
                        n12 = 105
                    end
                elseif n12 == 104 then
                    flag5 = "Plant"
                    n12 = 105
                elseif n12 == 105 then
                    if flag5 then
                        n12 = 107
                    else
                        n12 = 106
                    end
                elseif n12 == 106 then
                    flag5 = str2
                    n12 = 107
                elseif n12 == 107 then
                    v33, v34 = approach(v6, v25, flag5)
                    now3 = os.clock()
                    v5 = now3

                    if v33 == nil then
                        n12 = 216
                    else
                        n12 = 108
                    end
                elseif n12 == 108 then
                    if v33 == "skip" then
                        n12 = 139
                    else
                        n12 = 109
                    end
                end
            elseif n12 <= 126 then
                if n12 == 109 then
                    if v33 then
                        n12 = 110
                    else
                        n12 = 138
                    end
                elseif n12 == 110 then
                    v35 = tbl4.tile(rawget(v6.world, v29), v25.X, v25.Y)
                    n5 = v35

                    if v35 then
                        n12 = 112
                    else
                        n12 = 111
                    end
                elseif n12 == 111 then
                    n5 = 0
                    n12 = 112
                elseif n12 == 112 then
                    v36, v37 = tbl4.action(v6, str2, v25.X, v25.Y, v31, v29)

                    if v36 then
                        n12 = 113
                    else
                        n12 = 133
                    end
                elseif n12 == 113 then
                    actionStarted = v27.actionStarted
                    v38 = actionStarted

                    if actionStarted then
                        n12 = 115
                    else
                        n12 = 114
                    end
                elseif n12 == 114 then
                    v38 = now3
                    n12 = 115
                elseif n12 == 115 then
                    v27.actionStarted = v38
                    v27.attempts = v27.attempts + 1
                    farm.actions = farm.actions + 1

                    if str2 == "Splice" then
                        n12 = 117
                    else
                        n12 = 116
                    end
                elseif n12 == 116 then
                    waitUntil2 = false
                    n12 = 118
                elseif n12 == 117 then
                    waitUntil2 = true
                    n12 = 118
                elseif n12 == 118 then
                    if waitUntil2 then
                        n12 = 119
                    else
                        n12 = 120
                    end
                elseif n12 == 119 then
                    waitUntil2 = now3 + 0.35
                    n12 = 120
                elseif n12 == 120 then
                    if waitUntil2 then
                        n12 = 126
                    else
                        n12 = 121
                    end
                elseif n12 == 121 then
                    if str2 == "Harvest" then
                        n12 = 123
                    else
                        n12 = 122
                    end
                elseif n12 == 122 then
                    waitUntil2 = false
                    n12 = 124
                elseif n12 == 123 then
                    waitUntil2 = true
                    n12 = 124
                elseif n12 == 124 then
                    if waitUntil2 then
                        n12 = 125
                    else
                        n12 = 126
                    end
                elseif n12 == 125 then
                    waitUntil2 = now3 + 0.22
                    n12 = 126
                elseif n12 == 126 then
                    if waitUntil2 then
                        n12 = 128
                    else
                        n12 = 127
                    end
                end
            elseif n12 == 127 then
                waitUntil2 = now3 + 0.15
                n12 = 128
            elseif n12 == 128 then
                farm.waitUntil = waitUntil2
                factory.message = string.format("%s %s (%d, %d)", str2, tbl4.itemName(v31), v25.X, v25.Y)
                v39 = tbl4.tile(rawget(v6.world, v29), v25.X, v25.Y)
                n6 = v39

                if v39 then
                    n12 = 130
                else
                    n12 = 129
                end
            elseif n12 == 129 then
                n6 = 0
                n12 = 130
            elseif n12 == 130 then
                if n5 == n6 and v27.attempts > 12 then
                    n12 = 131
                else
                    n12 = 132
                end
            elseif n12 == 131 then
                tbl4.finishFarmTile(v25, v27, "No tile progress; target skipped")
                n12 = 132
            elseif n12 == 132 then
                return
            elseif n12 == 133 then
                if v37 ~= "Tree is still growing" and v37 ~= "Target layer changed" then
                    n12 = 135
                else
                    n12 = 134
                end
            elseif n12 == 134 then
                farm.waitUntil = now3 + 0.15
                return
            elseif n12 == 135 then
                if v37 ~= "This tile is not placeable" and v37 ~= "This tree cannot be spliced" and v37 ~= "Base seed is not planted on this tile" then
                    n12 = 137
                else
                    n12 = 136
                end
            elseif n12 == 136 then
                tbl4.finishFarmTile(v25, v27, v37)
                n12 = 83
            elseif n12 == 137 then
                tbl4.factoryStop(v37)
                tbl4.notice(v37, "Factory")
                return
            elseif n12 == 138 then
                factory.message = v34
                return
            elseif n12 == 139 then
                if v27.deferSince and now3 - v27.deferSince >= 3 then
                    n12 = 215
                else
                    n12 = 140
                end
            elseif n12 == 140 then
                v27.deferUntil = now3 + 3
                v27.deferReason = v34
                deferSince = v27.deferSince
                v40 = deferSince

                if deferSince then
                    n12 = 142
                else
                    n12 = 141
                end
            elseif n12 == 141 then
                v40 = now3
                n12 = 142
            elseif n12 == 142 then
                v27.deferSince = v40
                tbl11[#tbl11 + 1] = {v25, v27, v34}
                n12 = 143
            elseif n12 == 143 then
                v41, v42 = v20(v21, v23)

                if v41 == nil then
                    n12 = 207
                else
                    n12 = 144
                end
            elseif n12 == 144 then
                v23 = v41
                v43 = farm.records[v41]
                v44 = v43

                if v43 then
                    n12 = 146
                else
                    n12 = 145
                end
            elseif n12 == 145 then
                tbl13 = {attempts = 0}
                v44 = tbl13
                farm.records[v41] = tbl13
                n12 = 146
            end
        elseif n12 <= 218 then
            if n12 <= 181 then
                if n12 <= 163 then
                    if n12 == 146 then
                        if v44.done then
                            n12 = 143
                        else
                            n12 = 147
                        end
                    elseif n12 == 147 then
                        now4 = os.clock()
                        v5 = now4

                        if v44.deferUntil then
                            n12 = 148
                        else
                            n12 = 152
                        end
                    elseif n12 == 148 then
                        if now4 < v44.deferUntil then
                            n12 = 151
                        else
                            n12 = 149
                        end
                    elseif n12 == 149 then
                        if v44.deferSince and now4 - v44.deferSince >= 3 then
                            n12 = 150
                        else
                            n12 = 152
                        end
                    elseif n12 == 150 then
                        tbl4.finishFarmTile(v42, v44, v44.deferReason)
                        n12 = 143
                    elseif n12 == 151 then
                        tbl11[#tbl11 + 1] = {v42, v44, v44.deferReason}
                        n12 = 143
                    elseif n12 == 152 then
                        farm.index = v41
                        v45, v46, v47, v48 = tbl4.factoryWork(v6, v42.X, v42.Y)
                        str3 = v45

                        if v45 then
                            n12 = 153
                        else
                            n12 = 206
                        end
                    elseif n12 == 153 then
                        if v45 == "WaitTree" then
                            n12 = 154
                        else
                            n12 = 158
                        end
                    elseif n12 == 154 then
                        waitTreeSince2 = v44.waitTreeSince
                        v49 = waitTreeSince2

                        if waitTreeSince2 then
                            n12 = 156
                        else
                            n12 = 155
                        end
                    elseif n12 == 155 then
                        v49 = now4
                        n12 = 156
                    elseif n12 == 156 then
                        v44.waitTreeSince = v49

                        if now4 - v44.waitTreeSince < 2 then
                            n12 = 205
                        else
                            n12 = 157
                        end
                    elseif n12 == 157 then
                        str3 = "Splice"
                        n12 = 158
                    elseif n12 == 158 then
                        previous2 = str3 .. ":" .. tostring(v47) .. ":" .. tostring(v48)

                        if previous2 == v44.previous then
                            n12 = 160
                        else
                            n12 = 159
                        end
                    elseif n12 == 159 then
                        v44.previous = previous2
                        v44.attempts = 0
                        v44.actionStarted = nil
                        n12 = 160
                    elseif n12 == 160 then
                        approach2 = tbl4.approach

                        if str3 == "Splice" then
                            n12 = 162
                        else
                            n12 = 161
                        end
                    elseif n12 == 161 then
                        flag6 = false
                        n12 = 163
                    elseif n12 == 162 then
                        flag6 = true
                        n12 = 163
                    elseif n12 == 163 then
                        if flag6 then
                            n12 = 164
                        else
                            n12 = 165
                        end
                    end
                elseif n12 == 164 then
                    flag6 = "Plant"
                    n12 = 165
                elseif n12 == 165 then
                    if flag6 then
                        n12 = 167
                    else
                        n12 = 166
                    end
                elseif n12 == 166 then
                    flag6 = str3
                    n12 = 167
                elseif n12 == 167 then
                    v50, v51 = approach2(v6, v42, flag6)
                    now5 = os.clock()
                    v5 = now5

                    if v50 == nil then
                        n12 = 204
                    else
                        n12 = 168
                    end
                elseif n12 == 168 then
                    if v50 == "skip" then
                        n12 = 199
                    else
                        n12 = 169
                    end
                elseif n12 == 169 then
                    if v50 then
                        n12 = 170
                    else
                        n12 = 198
                    end
                elseif n12 == 170 then
                    v52 = tbl4.tile(rawget(v6.world, v46), v42.X, v42.Y)
                    n7 = v52

                    if v52 then
                        n12 = 172
                    else
                        n12 = 171
                    end
                elseif n12 == 171 then
                    n7 = 0
                    n12 = 172
                elseif n12 == 172 then
                    v53, v54 = tbl4.action(v6, str3, v42.X, v42.Y, v48, v46)

                    if v53 then
                        n12 = 173
                    else
                        n12 = 193
                    end
                elseif n12 == 173 then
                    actionStarted2 = v44.actionStarted
                    v55 = actionStarted2

                    if actionStarted2 then
                        n12 = 175
                    else
                        n12 = 174
                    end
                elseif n12 == 174 then
                    v55 = now5
                    n12 = 175
                elseif n12 == 175 then
                    v44.actionStarted = v55
                    v44.attempts = v44.attempts + 1
                    farm.actions = farm.actions + 1

                    if str3 == "Splice" then
                        n12 = 177
                    else
                        n12 = 176
                    end
                elseif n12 == 176 then
                    waitUntil3 = false
                    n12 = 178
                elseif n12 == 177 then
                    waitUntil3 = true
                    n12 = 178
                elseif n12 == 178 then
                    if waitUntil3 then
                        n12 = 179
                    else
                        n12 = 180
                    end
                elseif n12 == 179 then
                    waitUntil3 = now5 + 0.35
                    n12 = 180
                elseif n12 == 180 then
                    if waitUntil3 then
                        n12 = 186
                    else
                        n12 = 181
                    end
                elseif n12 == 181 then
                    if str3 == "Harvest" then
                        n12 = 183
                    else
                        n12 = 182
                    end
                end
            elseif n12 <= 199 then
                if n12 == 182 then
                    waitUntil3 = false
                    n12 = 184
                elseif n12 == 183 then
                    waitUntil3 = true
                    n12 = 184
                elseif n12 == 184 then
                    if waitUntil3 then
                        n12 = 185
                    else
                        n12 = 186
                    end
                elseif n12 == 185 then
                    waitUntil3 = now5 + 0.22
                    n12 = 186
                elseif n12 == 186 then
                    if waitUntil3 then
                        n12 = 188
                    else
                        n12 = 187
                    end
                elseif n12 == 187 then
                    waitUntil3 = now5 + 0.15
                    n12 = 188
                elseif n12 == 188 then
                    farm.waitUntil = waitUntil3
                    factory.message = string.format("%s %s (%d, %d)", str3, tbl4.itemName(v48), v42.X, v42.Y)
                    v56 = tbl4.tile(rawget(v6.world, v46), v42.X, v42.Y)
                    n8 = v56

                    if v56 then
                        n12 = 190
                    else
                        n12 = 189
                    end
                elseif n12 == 189 then
                    n8 = 0
                    n12 = 190
                elseif n12 == 190 then
                    if n7 == n8 and v44.attempts > 12 then
                        n12 = 191
                    else
                        n12 = 192
                    end
                elseif n12 == 191 then
                    tbl4.finishFarmTile(v42, v44, "No tile progress; target skipped")
                    n12 = 192
                elseif n12 == 192 then
                    return
                elseif n12 == 193 then
                    if v54 ~= "Tree is still growing" and v54 ~= "Target layer changed" then
                        n12 = 195
                    else
                        n12 = 194
                    end
                elseif n12 == 194 then
                    farm.waitUntil = now5 + 0.15
                    return
                elseif n12 == 195 then
                    if v54 ~= "This tile is not placeable" and v54 ~= "This tree cannot be spliced" and v54 ~= "Base seed is not planted on this tile" then
                        n12 = 197
                    else
                        n12 = 196
                    end
                elseif n12 == 196 then
                    tbl4.finishFarmTile(v42, v44, v54)
                    n12 = 143
                elseif n12 == 197 then
                    tbl4.factoryStop(v54)
                    tbl4.notice(v54, "Factory")
                    return
                elseif n12 == 198 then
                    factory.message = v51
                    return
                elseif n12 == 199 then
                    if v44.deferSince and now5 - v44.deferSince >= 3 then
                        n12 = 203
                    else
                        n12 = 200
                    end
                end
            elseif n12 == 200 then
                v44.deferUntil = now5 + 3
                v44.deferReason = v51
                deferSince2 = v44.deferSince
                v57 = deferSince2

                if deferSince2 then
                    n12 = 202
                else
                    n12 = 201
                end
            elseif n12 == 201 then
                v57 = now5
                n12 = 202
            elseif n12 == 202 then
                v44.deferSince = v57
                tbl11[#tbl11 + 1] = {v42, v44, v51}
                farm.waitUntil = now5 + 0.05
                return
            elseif n12 == 203 then
                tbl4.finishFarmTile(v42, v44, v51)
                n12 = 143
            elseif n12 == 204 then
                tbl4.factoryStop(v51)
                tbl4.notice(v51, "Factory")
                return
            elseif n12 == 205 then
                factory.message = string.format("Syncing planted seed (%d, %d)", v42.X, v42.Y)
                farm.waitUntil = now4 + 0.1
                return
            elseif n12 == 206 then
                tbl4.finishFarmTile(v42, v44)
                n12 = 143
            elseif n12 == 207 then
                flag7 = false
                v58, v59, v60 = ipairs(tbl11)
                v61 = v60
                n12 = 208
            elseif n12 == 208 then
                v62, v63 = v58(v59, v61)

                if v62 == nil then
                    n12 = 212
                else
                    n12 = 209
                end
            elseif n12 == 209 then
                v61 = v62

                if v5 - v63[2].deferSince >= 3 then
                    n12 = 211
                else
                    n12 = 210
                end
            elseif n12 == 210 then
                flag7 = true
                n12 = 208
            elseif n12 == 211 then
                tbl4.finishFarmTile(v63[1], v63[2], v63[3])
                n12 = 208
            elseif n12 == 212 then
                if flag7 then
                    n12 = 213
                else
                    n12 = 214
                end
            elseif n12 == 213 then
                farm.waitUntil = v5 + 0.25
                n12 = 214
            elseif n12 == 214 then
                return
            elseif n12 == 215 then
                tbl4.finishFarmTile(v25, v27, v34)
                n12 = 83
            elseif n12 == 216 then
                tbl4.factoryStop(v34)
                tbl4.notice(v34, "Factory")
                return
            elseif n12 == 217 then
                factory.message = string.format("Syncing planted seed (%d, %d)", v25.X, v25.Y)
                farm.waitUntil = now2 + 0.1
                return
            elseif n12 == 218 then
                tbl4.finishFarmTile(v25, v27)
                n12 = 83
            end
        elseif n12 <= 254 then
            if n12 <= 236 then
                if n12 == 219 then
                    flag8 = false
                    v64, v65, v66 = ipairs(tbl11)
                    v67 = v66
                    n12 = 220
                elseif n12 == 220 then
                    v68, v69 = v64(v65, v67)

                    if v68 == nil then
                        n12 = 224
                    else
                        n12 = 221
                    end
                elseif n12 == 221 then
                    v67 = v68

                    if v5 - v69[2].deferSince >= 3 then
                        n12 = 223
                    else
                        n12 = 222
                    end
                elseif n12 == 222 then
                    flag8 = true
                    n12 = 220
                elseif n12 == 223 then
                    tbl4.finishFarmTile(v69[1], v69[2], v69[3])
                    n12 = 220
                elseif n12 == 224 then
                    if flag8 then
                        n12 = 225
                    else
                        n12 = 226
                    end
                elseif n12 == 225 then
                    farm.waitUntil = v5 + 0.25
                    n12 = 226
                elseif n12 == 226 then
                    return
                elseif n12 == 227 then
                    flag9 = false

                    if farm.pnbTarget then
                        n12 = 228
                    else
                        n12 = 242
                    end
                elseif n12 == 228 then
                    v70 = v11

                    if v11 then
                        n12 = 229
                    else
                        n12 = 230
                    end
                elseif n12 == 229 then
                    v70 = tbl4.item(v11)
                    n12 = 230
                elseif n12 == 230 then
                    value = v70

                    if v70 then
                        n12 = 231
                    else
                        n12 = 232
                    end
                elseif n12 == 231 then
                    value = rawget(v70, "background")
                    n12 = 232
                elseif n12 == 232 then
                    if value then
                        n12 = 233
                    else
                        n12 = 234
                    end
                elseif n12 == 233 then
                    value = "bg"
                    n12 = 234
                elseif n12 == 234 then
                    if value then
                        n12 = 236
                    else
                        n12 = 235
                    end
                elseif n12 == 235 then
                    value = "fg"
                    n12 = 236
                elseif n12 == 236 then
                    v71, v72, v73 = ipairs(farm.pnbTarget)
                    v74 = v73
                    n12 = 237
                end
            elseif n12 == 237 then
                v75, v76 = v71(v72, v74)

                if v75 == nil then
                    n12 = 242
                else
                    n12 = 238
                end
            elseif n12 == 238 then
                v74 = v75
                v77 = tbl4.tile(rawget(v6.world, value), v76.X, v76.Y)
                n9 = v77

                if v77 then
                    n12 = 240
                else
                    n12 = 239
                end
            elseif n12 == 239 then
                n9 = 0
                n12 = 240
            elseif n12 == 240 then
                if n9 == v11 then
                    n12 = 241
                else
                    n12 = 237
                end
            elseif n12 == 241 then
                flag9 = true
                n12 = 242
            elseif n12 == 242 then
                if v11 and (tbl4.inventoryCount(v6, v11) >= 1 or flag9) and (tbl4.inventoryCount(v6, activeSeed) < 200 or flag9) then
                    n12 = 253
                else
                    n12 = 243
                end
            elseif n12 == 243 then
                farm.pnbTarget = nil
                tbl14 = {}

                if tbl4.inventoryCount(v6, activeSeed) < 200 then
                    n12 = 245
                else
                    n12 = 244
                end
            elseif n12 == 244 then
                flag11 = false
                n12 = 246
            elseif n12 == 245 then
                flag11 = true
                n12 = 246
            elseif n12 == 246 then
                if flag11 then
                    n12 = 248
                else
                    n12 = 247
                end
            elseif n12 == 247 then
                flag11 = nil
                n12 = 248
            elseif n12 == 248 then
                tbl14[activeSeed] = flag11

                if v11 and tbl4.inventoryCount(v6, v11) < 200 then
                    n12 = 249
                else
                    n12 = 250
                end
            elseif n12 == 249 then
                tbl14[v11] = true
                n12 = 250
            elseif n12 == 250 then
                if next(tbl14) and tbl4.nextDrop(v6, now, n4, tbl14) then
                    n12 = 252
                else
                    n12 = 251
                end
            elseif n12 == 251 then
                factory.cycles = factory.cycles + 1
                factory.activeSeed = nil
                factory.spliceRecipe = nil
                factory.phase = "Plant"
                farm.batchSize = 0
                farm.skip = {}
                farm.route = nil
                factory.message = "Starting cycle #" .. tostring(factory.cycles + 1)
                return
            elseif n12 == 252 then
                factory.phase = "Collect"
                farm.route = nil
                return
            elseif n12 == 253 then
                v78, v79 = tbl4.findFactoryBreakOrigin(v6, v11)
                v80, v81 = tbl4.settle(v6, now)

                if v80 == nil then
                    n12 = 287
                else
                    n12 = 254
                end
            elseif n12 == 254 then
                if v80 then
                    n12 = 255
                else
                    n12 = 286
                end
            end
        elseif n12 <= 272 then
            if n12 == 255 then
                v82, v83 = tbl4.coords(v6)
                n10 = v82

                if v82 then
                    n12 = 256
                else
                    n12 = 257
                end
            elseif n12 == 256 then
                n10 = math.floor(v82)
                n12 = 257
            elseif n12 == 257 then
                n11 = v83

                if v83 then
                    n12 = 258
                else
                    n12 = 259
                end
            elseif n12 == 258 then
                n11 = math.floor(v83 - 0.001)
                n12 = 259
            elseif n12 == 259 then
                if farm.pnbTarget and farm.pnbTarget.OriginX == v78 and farm.pnbTarget.OriginY == v79 then
                    n12 = 279
                else
                    n12 = 260
                end
            elseif n12 == 260 then
                if n10 == v78 and n11 == v79 and math.abs(v83 - v79 - 1) < 0.05 and math.abs(v82 - v78 - 0.5) <= 0.35 then
                    n12 = 278
                else
                    n12 = 261
                end
            elseif n12 == 261 then
                if n11 == v79 then
                    n12 = 263
                else
                    n12 = 262
                end
            elseif n12 == 262 then
                flag10 = false
                n12 = 264
            elseif n12 == 263 then
                flag10 = true
                n12 = 264
            elseif n12 == 264 then
                if flag10 then
                    n12 = 265
                else
                    n12 = 266
                end
            elseif n12 == 265 then
                flag10 = tbl4.runDirection(v6, {X = v78, Y = v79}, "Collect", v82, v83, now, 0.3)
                n12 = 266
            elseif n12 == 266 then
                if flag10 then
                    n12 = 267
                else
                    n12 = 268
                end
            elseif n12 == 267 then
                farm.route = nil
                tbl4.setWalk(v6, flag10)
                factory.message = string.format("Running to break pos (%d, %d)", v78, v79)
                return
            elseif n12 == 268 then
                if n11 == v79 and math.abs(v83 - v79 - 1) < 0.05 and math.abs(v82 - v78 - 0.5) <= 1.2 then
                    n12 = 277
                else
                    n12 = 269
                end
            elseif n12 == 269 then
                tbl4.setWalk(v6, nil)

                v84, v85 = tbl4.hop(v6, nil, "Collect", function()
                    return {{X = v78, Y = v79}}, "Break position has no safe landing"
                end, now)

                if v84 == nil then
                    n12 = 276
                else
                    n12 = 270
                end
            elseif n12 == 270 then
                if v84 == "skip" then
                    n12 = 271
                else
                    n12 = 273
                end
            elseif n12 == 271 then
                factory.autoBreakX = nil
                factory.autoBreakY = nil

                if factory.breakX then
                    n12 = 272
                else
                    n12 = 273
                end
            elseif n12 == 272 then
                tbl4.factoryStop(v85)
                tbl4.notice(v85, "Factory")
                return
            end
        elseif n12 == 273 then
            message = v85

            if v85 then
                n12 = 275
            else
                n12 = 274
            end
        elseif n12 == 274 then
            message = string.format("Moving to break pos (%d, %d)", v78, v79)
            n12 = 275
        elseif n12 == 275 then
            factory.message = message
            return
        elseif n12 == 276 then
            tbl4.factoryStop(v85)
            tbl4.notice(v85, "Factory")
            return
        elseif n12 == 277 then
            farm.route = nil
            tbl4.nudge(v6, v78 + 0.5, v82)
            factory.message = string.format("Aligning at break pos (%d, %d)", v78, v79)
            return
        elseif n12 == 278 then
            tbl4.setWalk(v6, nil)
            farm.route = nil
            tbl4.rebuildPnbTarget(v6, v78, v79)
            n12 = 279
        elseif n12 == 279 then
            farm.pnbBlock = v11
            v86, v87 = tbl4.pnbStep(v6, now)

            if v86 == nil then
                n12 = 281
            else
                n12 = 280
            end
        elseif n12 == 280 then
            factory.message = v87
            return
        elseif n12 == 281 then
            if v87 and v87:find("^Out of ") then
                n12 = 285
            else
                n12 = 282
            end
        elseif n12 == 282 then
            if not factory.breakX and v87 and v87:find("holds ") then
                n12 = 284
            else
                n12 = 283
            end
        elseif n12 == 283 then
            tbl4.factoryStop(v87)
            tbl4.notice(v87, "Factory")
            return
        elseif n12 == 284 then
            factory.autoBreakX = nil
            factory.autoBreakY = nil
            farm.pnbTarget = nil
            return
        elseif n12 == 285 then
            farm.pnbTarget = nil
            return
        elseif n12 == 286 then
            factory.message = v81
            return
        elseif n12 == 287 then
            tbl4.factoryStop(v81)
            tbl4.notice(v81, "Factory")
            return
        elseif n12 == 288 then
            factory.message = string.format("Waiting for %s (%d/%d ripe): %ds", tbl4.itemName(activeSeed, true), v14, v13, math.ceil(v12))
            farm.waitUntil = now + 1
            return
        elseif n12 == 289 then
            factory.phase = "Collect"
            farm.batchSize = 0
            farm.skip = {}
            return
        elseif n12 == 290 then
            tbl4.factoryStop("Select a seed first")
            tbl4.notice("Select a seed first.", "Factory")
            return
        elseif n12 == 291 then
            return
        end
    end
end

tbl4.factoryUI = function(arg)
    local v5 = tbl4.section(arg, "Seed Factory", "factory")

    tbl3.ui.factorySeed = tbl4.control(v5, "Dropdown", "FactorySeed", {
        Title = "Selected Seed",
        Desc = "All seeds in Growblox (searchable). Splices automatically if recipe ingredients are available.",
        Values = {"Loading seeds..."},
        SearchBarEnabled = true,
        Callback = function(arg2)
            local seedMapping = tbl3.factory.seedMapping
            local v6 = seedMapping and tbl3.factory.seedMapping[arg2] or nil

            if v6 then
                if tbl3.factory.enabled and tbl3.factory.seed ~= v6 then
                    tbl4.factoryReset("Selected seed changed")
                end

                tbl3.factory.seed = v6
            end
        end,
    })

    tbl3.ui.factoryInfo = v5:Paragraph({Title = "Seed & Recipe Info", Body = "Select a seed"})

    tbl4.control(v5, "Toggle", "FactoryAutoSplice", {
        Title = "Auto Splice Recipe",
        Desc = "When you have 0 of the selected seed, automatically splices its recipe ingredients (e.g. Dirt Seed + Rock Seed = Grass Seed)",
        Default = true,
        Callback = function(autoSplice)
            tbl3.factory.autoSplice = autoSplice
        end,
    })

    tbl4.toggle(v5, "FactoryEnabled", "Start Factory", function(arg2)
        local factory = tbl3.factory
        local farm = tbl3.farm
        if not arg2 then
            tbl4.factoryStop("Stopped")
            return
        end
        local v6 = tbl4.scene()

        if not v6 then
            tbl4.set("FactoryEnabled", false)
            tbl4.notice("Enter a world first.", "Factory")
            return
        end

        local v7, v8 = tbl4.nativeActions(v6)

        if not v7 then
            tbl4.set("FactoryEnabled", false)
            tbl4.notice(v8, "Factory")
            return
        end

        if not factory.seed then
            tbl4.set("FactoryEnabled", false)
            tbl4.notice("Select a seed first.", "Factory")
            return
        end

        if factory.breakOffsets and #factory.breakOffsets ~= 0 then
            if farm.enabled then
                tbl4.farmReset("Switched to Factory")
            end

            tbl4.factoryReset("Starting", true)
            local world = rawget(v6.world, "name")
            factory.enabled = true
            factory.world = world
            factory.cycles = 0
            farm.actions = 0
            farm.teleports = 0
            factory.message = "Starting Factory: " .. tbl4.itemName(factory.seed)
            return
        end

        tbl4.set("FactoryEnabled", false)
        tbl4.notice("Select at least 1 tile in the 7x7 Break Tiles grid first.", "Factory")
    end, "Cycles: Plant All -> Collect Floating Seeds -> Wait Ready -> Harvest All -> Collect All -> Break Blocks -> Repeat")

    tbl3.ui.factoryStatus = v5:Paragraph({Title = "Status", Body = "Stopped"})
    local v6 = tbl4.section(arg, "Break Position & Tiles", "target")

    tbl3.ui.factoryPosStatus = v6:Paragraph({
        Title = "Break Position",
        Body = "Auto (uses nearest clear tile in your farm row)",
    })

    local function fn4()
        if tbl3.ui.factoryPosStatus then
            if tbl3.factory.breakX and tbl3.factory.breakY then
                tbl3.ui.factoryPosStatus:SetDesc(string.format("Saved Position: (%d, %d)", tbl3.factory.breakX, tbl3.factory.breakY))
            else
                tbl3.ui.factoryPosStatus:SetDesc("Auto (uses nearest clear tile in your farm row)")
            end
        end
    end

    tbl4.button(v6, "Select Break Position (Current Pos)", function()
        local v7 = tbl4.scene()
        if not v7 then
            tbl4.notice("Enter a world first.", "Factory")
            return
        end
        local v8, v9 = tbl4.coords(v7)

        if v8 and v9 then
            local breakX = math.floor(v8)
            local breakY = math.floor(v9 - 0.001)
            local factory = tbl3.factory
            tbl3.factory.breakX = breakX
            factory.breakY = breakY

            if tbl3.factory.enabled and tbl3.factory.phase == "Break" then
                tbl3.farm.pnbTarget = nil
            end

            fn4()
            tbl4.notice(string.format("Factory break position set to (%d, %d).", breakX, breakY), "Factory")
            return
        end

        tbl4.notice("Player position is unavailable.", "Factory")
    end)

    tbl4.button(v6, "Reset Break Position (Auto)", function()
        local factory = tbl3.factory
        tbl3.factory.breakX = nil
        factory.breakY = nil
        local factory2 = tbl3.factory
        tbl3.factory.autoBreakX = nil
        factory2.autoBreakY = nil
        fn4()
        tbl4.notice("Factory break position reset to Auto.", "Factory")
    end)

    tbl3.ui.factoryTiles = tbl4.control(v6, "TileGrid7x7", "FactoryBreakTiles", {
        Title = "Break Tiles Around Break Pos (7x7)",
        Default = "1,0;2,0",
        Callback = function(arg2, arg3)
            local v7 = arg3

            if type(arg3) ~= "table" and type(arg2) == "string" then
                local tbl7 = {}
                v7 = tbl7

                for match in arg2:gmatch("[^;%s]+") do
                    local match2, v8 = match:match("^([%-]?%d+),([%-]?%d+)$")
                    local num = tonumber(match2)
                    local num2 = tonumber(v8)

                    if num and num2 and (num ~= 0 or num2 ~= 0) then
                        tbl7[#tbl7 + 1] = {DX = num, DY = num2}
                    end
                end
            end

            if type(v7) == "table" then
                tbl3.factory.breakOffsets = v7

                if tbl3.factory.enabled and tbl3.factory.phase == "Break" then
                    tbl3.farm.pnbTarget = nil
                end
            end
        end,
    })

    tbl4.button(v6, "Clear Selected Tiles", function()
        if tbl3.ui.factoryTiles then
            tbl3.ui.factoryTiles:SetValue("")
        end
    end)

    tbl4.button(v6, "Reset Default (2 Right)", function()
        if tbl3.ui.factoryTiles then
            tbl3.ui.factoryTiles:SetValue("1,0;2,0")
        end
    end)

    tbl4.factoryOptions()
end

tbl3.collect = {
    enabled = false,
    radius = 10,
    drop = nil,
    skip = setmetatable({}, {__mode = "k"}),
    mine = setmetatable({}, {__mode = "k"}),
    recent = {},
    collected = 0,
    message = "Off",
}

tbl4.dropList = function(arg)
    local value = arg and arg.world and rawget(arg.world, "dropList")

    if type(value) == "function" then
        local ok, result = pcall(value)
        if ok and type(result) == "table" then
            return result
        end
    end

    if arg and type(arg.updateDrops) == "function" then
        local v5 = tbl4.upvalues(arg.updateDrops)
        if v5 and type(v5[1]) == "table" then
            return v5[1]
        end
    end

    local value2 = arg and arg.controller and rawget(arg.controller, "onDrop")
    local v5 = pairs
    local v6 = tbl4.upvalues(value2)
    local tbl7 = v6 or {}
    local v7, v8, v9 = v5(tbl7)
    local v10 = v9
    local v11 = v7
    local v12 = v8

    while true do
        local v13, v14 = v11(v12, v10)
        if v13 == nil then
            break
        end
        v10 = v13

        if type(v14) == "function" and debug.info(v14, "n") == "putDown" then
            local v15 = tbl4.upvalues(v14)
            if not v15 then
                continue
            end

            for k, v16 in pairs(v15) do
                if type(v16) == "table" then
                    return v16
                end
            end

            v10 = v13
        end
    end

    return nil
end

tbl4.restoreDropMagnet = function()
    local sendStateHook = tbl3.sendStateHook
    tbl3.sendStateHook = nil

    if sendStateHook and debug.setupvalue and debug.getupvalue and debug.getupvalue(sendStateHook.Update, 1) == sendStateHook.Wrapped then
        pcall(debug.setupvalue, sendStateHook.Update, 1, sendStateHook.Original)
    end
end

tbl4.updateDropMagnet = function(arg)
    if not arg or not arg.others or not debug.getupvalue or not debug.setupvalue then
        return
    end
    local value = rawget(arg.others, "update")
    if type(value) ~= "function" then
        return
    end

    if tbl3.sendStateHook and tbl3.sendStateHook.Update == value then
        return
    end
    tbl4.restoreDropMagnet()
    local sendState = arg.sendState
    local v5 = sendState or debug.getupvalue(value, 1)
    if type(v5) ~= "function" or debug.info(v5, "n") ~= "sendState" then
        return
    end
    arg.sendState = v5

    local function fn4(...)
        if tbl3.collect and tbl3.collect.taking and tbl3.hidup then
            return
        end
        return v5(...)
    end

    pcall(debug.setupvalue, value, 1, fn4)
    tbl3.sendStateHook = {Update = value, Original = v5, Wrapped = fn4}
end

tbl4.ownDrop = function(arg, arg2)
    local collect = tbl3.collect
    if collect.mine[arg] then
        return true
    end
    local value = rawget(arg, "x")
    local value2 = rawget(arg, "y")
    local value3 = rawget(arg, "born")
    local n = value3 or 0

    for i, v5 in ipairs(collect.recent) do
        if arg2 - v5.T < 3 and v5.T - 0.1 <= n and math.abs(value - v5.X) < 1.5 and math.abs(value2 - v5.Y) < 1.5 then
            collect.mine[arg] = true
            return true
        end
    end

    return false
end

tbl4.dropLanding = function(arg, arg2)
    local value = rawget(arg2, "x")
    local value2 = rawget(arg2, "y")
    local n = math.floor(value)

    for i, v5 in ipairs({
        math.floor(value2),
        math.floor(value2) - 1,
        math.floor(value2) + 1,
    }) do
        if v5 + 0.05 < value2 + 0.3 and value2 - 0.3 < v5 + 1 and tbl4.safeLanding(arg, n, v5, nil, "Collect") then
            return {X = n, Y = v5}
        end
    end

    return nil, "No safe landing under this item"
end

tbl4.nextDrop = function(arg, arg2, arg3, arg4)
    local collect = tbl3.collect
    local v5 = tbl4.dropList(arg)
    local v6, v7 = tbl4.coords(arg)
    if not v5 or not v6 then
        return nil
    end
    local v8 = tbl4.method(arg.inventory, "room")
    local v9 = nil
    local radius = arg3 or collect.radius
    local n = radius ^ 2
    local enabled = tbl3.farm.enabled
    local n2 = enabled and tbl3.farm.template == "Auto DF" and rawget(arg.world, "w") - 3

    for i, v10 in ipairs(v5) do
        local value = rawget(v10, "x")
        local value2 = rawget(v10, "y")
        local value3 = rawget(v10, "id")

        if type(value) == "number" and (not n2 or value >= 3 and n2 > value) and type(value2) == "number" and rawget(v10, "uid") and not rawget(v10, "pending") and not rawget(v10, "display") and not rawget(v10, "shut") then
            local v11 = collect.skip[v10]
            local n3 = v11 or 0

            if n3 < arg2 and (not arg4 or arg4[value3]) and not tbl4.ownDrop(v10, arg2) then
                local n4 = (value - v6) ^ 2 + (value2 - v7 + 0.5) ^ 2

                if n4 <= n and (value3 == 112 or type(v8) == "function" and v8(arg.inventory, value3) > 0) then
                    v9 = v10
                    n = n4
                end
            end
        end
    end

    return v9
end

tbl4.dropInCell = function(arg, arg2, arg3)
    local v5 = ipairs
    local v6 = tbl4.dropList(arg)
    local tbl7 = v6 or {}

    for k, v7 in v5(tbl7) do
        local value = rawget(v7, "x")
        local value2 = rawget(v7, "y")
        if type(value) == "number" and type(value2) == "number" and math.floor(value) == arg2 and math.floor(value2) == arg3 and rawget(v7, "uid") and not rawget(v7, "display") then
            return v7
        end
    end

    return nil
end

tbl4.applyTakenDrop = function(arg, arg2, arg3)
    if type(arg3) ~= "number" or arg3 <= 0 or not tbl3.hidup then
        return false
    end
    local collect = tbl3.collect
    collect.collected = collect.collected + 1
    local v5 = tbl4.method(arg.inventory, "add")
    local value = rawget(arg2, "id") == 112 and arg.controller and rawget(arg.controller, "addGems")

    if value then
        pcall(value, arg3)
    elseif type(v5) == "function" then
        pcall(v5, arg.inventory, rawget(arg2, "id"), arg3)
    end

    pcall(function()
        local value2 = rawget(arg2, "n")
        local n = value2 or 0
        local n2 = n - arg3
        arg2.n = n2

        if n2 > 0 then
            if type(rawget(arg2, "setGem")) == "function" then
                arg2.setGem(n2)
            elseif type(rawget(arg2, "count")) == "table" then
                local count = arg2.count
                local set = count.set
                local str2 = n2 > 1 and tostring(n2) or ""
                set(count, str2)
            end

            return
        end

        local v6 = tbl4.dropList(arg)
        local v7 = v6 and table.find(v6, arg2)

        if v7 then
            table.remove(v6, v7)
        end

        local value3 = rawget(arg2, "frame")

        if typeof(value3) == "Instance" then
            value3:Destroy()
        end
    end)

    return true
end

tbl4.takeDrop = function(arg, arg2)
    local collect = tbl3.collect
    local value = rawget(arg.world, "takeDrop")
    if type(value) ~= "function" or rawget(arg2, "taking") then
        return
    end
    collect.taking = true
    arg2.taking = true

    task.spawn(function()
        if tbl4.setIdentity then
            pcall(tbl4.setIdentity, 2)
        end

        local ok, result = pcall(value, rawget(arg2, "uid"), rawget(arg2, "n"))

        if tbl4.setIdentity then
            pcall(tbl4.setIdentity, 8)
        end

        arg2.taking = nil

        if ok and type(result) == "number" and result > 0 and tbl3.hidup then
            tbl4.applyTakenDrop(arg, arg2, result)
        else
            collect.skip[arg2] = os.clock() + 1.5
        end

        collect.taking = false
    end)
end

tbl4.takePassing = function(arg, arg2, arg3, arg4)
    local v5, v6 = tbl4.coords(arg)
    local v7 = v5 and tbl4.dropList(arg)
    if not v7 then
        return nil
    end
    local collect = tbl3.collect
    local v8 = tbl4.method(arg.inventory, "room")
    local n = math.floor(v5)
    local n2 = math.floor(v6 - 0.001)
    local enabled = tbl3.farm.enabled
    local n3 = enabled and tbl3.farm.template == "Auto DF" and rawget(arg.world, "w") - 3
    local radius = arg4

    if not arg4 then
        local enabled2 = tbl3.collect.enabled
        radius = enabled2 and tbl3.collect.radius or 1.2
    end

    local n4 = math.min(radius, 1.35) ^ 2
    local v9 = nil

    for i, v10 in ipairs(v7) do
        local value = rawget(v10, "x")
        local value2 = rawget(v10, "y")
        local value3 = rawget(v10, "id")

        if type(value) == "number" and (not n3 or value >= 3 and n3 > value) and type(value2) == "number" and not rawget(v10, "taking") and rawget(v10, "uid") and not rawget(v10, "pending") and not rawget(v10, "display") and not rawget(v10, "shut") then
            local v11 = collect.skip[v10]
            local n5 = v11 or 0

            if n5 < arg2 and (not arg3 or arg3[value3]) and not tbl4.ownDrop(v10, arg2) and (value - v5) ^ 2 + (value2 - v6 + 0.5) ^ 2 <= n4 and tbl4.clearPath(arg, n, n2, math.floor(value), math.floor(value2)) and (value3 == 112 or type(v8) == "function" and v8(arg.inventory, value3) > 0) then
                tbl4.takeDrop(arg, v10)
                local v12 = v9 or v10
                v9 = v12
            end
        end
    end

    return v9
end

tbl4.collectStep = function(arg, arg2, arg3, arg4)
    local collect = tbl3.collect
    local farm = tbl3.farm
    if tbl4.takePassing(arg, arg2, arg4, 1.35) or collect.taking then
        return true, "Collecting items"
    end
    local nextDrop = tbl4.nextDrop
    local radius = arg3 or collect.radius
    local v5 = nextDrop(arg, arg2, radius, arg4)
    if not v5 then
        tbl4.setWalk(arg, nil)
        return false
    end
    local v6, v7 = tbl4.coords(arg)

    if v6 then
        math.floor(v6)
    end

    local n = v7 and math.floor(v7 - 0.001)
    local v8 = tbl4.dropLanding(arg, v5)

    if v8 and v6 and n and v8.Y == n then
        local v9 = tbl4.runDirection(arg, v8, "Collect", v6, v7, arg2, 0.4)
        if v9 then
            tbl4.setWalk(arg, v9)
            return true, "Walking to " .. tbl4.itemName(rawget(v5, "id"))
        end
    end

    tbl4.setWalk(arg, nil)
    return false
end

local tbl7 = {
    Dirt = true,
    ["Dirt Seed"] = true,
    ["Cave Background"] = true,
    ["Cave Background Seed"] = true,
    Lava = true,
    ["Lava Seed"] = true,
    Rock = true,
    ["Rock Seed"] = true,
}

local tbl8 = {
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [10] = true,
    [11] = true,
    [14] = true,
    [15] = true,
}

tbl4.recyclable = function(arg, arg2)
    local farm = tbl3.farm
    local v5 = ipairs
    local value = rawget(arg.inventory, "slots")
    local tbl9 = value or {}

    for k, v6 in v5(tbl9) do
        local value2 = rawget(v6, "id")
        local value3 = rawget(v6, "n")
        local n = value3 or 0
        local v7 = tbl4.item(value2)
        local value4 = v7 and rawget(v7, "name")
        if n >= 200 and value2 ~= arg2 and v7 and (tbl8[value2] or type(value4) == "string" and tbl7[value4]) and (farm.template ~= "Auto DF" or value2 ~= farm.dirt and (value2 ~= farm.seed or farm.storing)) and not rawget(v7, "untradeable") and not rawget(v7, "worldKey") then
            return value2, n
        end
    end

    return nil
end

tbl4.recycleStep = function(arg, arg2)
    local farm = tbl3.farm

    if farm.autoRecycle and (farm.template == "Auto Clear World" or farm.template == "Auto DF") then
        local recycling = farm.recycling
        local v5 = recycling
        local id = nil
        local v6 = nil
        local n = nil

        if recycling then
            local v7 = tbl4.inventoryCount(arg, recycling.Id)

            if v7 < recycling.From then
                farm.recycled = farm.recycled + (recycling.From - v7)
                farm.recycling = nil
                v5 = nil
            elseif recycling.Until < arg2 then
                if recycling.Tries >= 2 then
                    return nil, "Recycle was refused by the game"
                end
                id = recycling.Id
                n = recycling.Tries + 1
                v6 = v7
            end
        end

        if not id then
            local recyclable = tbl4.recyclable
            local id2 = v5 and v5.Id
            local v7, v8 = recyclable(arg, id2)
            id = v7
            v6 = v8
            n = 1
        end

        if not id or v5 and v5.Id ~= id then
            return false
        end
        local controller = arg.controller
        local value = controller and rawget(arg.controller, "onRecycle")
        if type(value) ~= "function" then
            return nil, "Native recycle is unavailable"
        end
        local v7, v8 = tbl4.nativeCall(value, id, v6)
        if not v7 and v8 then
            return nil, v8
        end
        farm.recycling = {Id = id, From = v6, Until = arg2 + 20, Tries = n}
        return true, "Recycling " .. tbl4.itemName(id)
    end

    farm.recycling = nil
    return false
end

tbl4.storeStep = function(arg, arg2)
    local farm = tbl3.farm
    local v5, v6 = tbl4.recycleStep(arg, arg2)
    if v5 ~= false then
        return v5, v6
    end

    if tbl3.collect.enabled and (tbl4.takePassing(arg, arg2, nil, tbl3.collect.radius) or tbl3.collect.taking) then
        return true, "Collecting items"
    end

    if not farm.recycling then
        return false
    end
    return true, "Waiting for recycle of " .. tbl4.itemName(farm.recycling.Id)
end

tbl4.collectOnly = function()
    local collect = tbl3.collect
    local now = os.clock()
    local v5 = tbl4.scene()
    if not v5 then
        collect.message = "Enter a world first"
        return
    end
    local v6 = tbl4.moveBlocked(v5)

    if not v6 then
        local v7, v8 = tbl4.collectStep(v5, now, collect.radius)

        if v7 then
            collect.message = v8
        else
            tbl4.setWalk(v5, nil)
            collect.message = "Scanning radius (" .. tostring(collect.radius) .. " tiles)"
        end

        return
    end

    tbl4.setWalk(v5, nil)
    collect.message = v6
end

tbl4.fastDrop = function()
    local v5 = tbl4.scene()
    local item = tbl3.drop.item
    local amount = tbl3.drop.amount

    if v5 and item then
        local controller = v5.controller
        local value = controller and rawget(v5.controller, "onDrop")

        if type(value) == "function" then
            local v6 = tbl4.inventoryCount(v5, item)
            local n = math.min(amount, v6, 65535)
            if n < 1 then
                tbl4.notice("You do not have this item.")
                return
            end
            local v7, v8 = tbl4.coords(v5)
            local recent = tbl3.collect.recent

            for i = #recent, 1, -1 do
                if os.clock() - recent[i].T > 3 then
                    table.remove(recent, i)
                end
            end

            local n2 = #recent + 1
            local tbl9 = {}
            local x = v7 or 0
            tbl9.X = x
            local n3 = v8 or 0
            tbl9.Y = n3 - 0.45
            tbl9.T = os.clock()
            recent[n2] = tbl9
            local v9, v10 = tbl4.nativeCall(value, item, n)
            if not v9 and v10 then
                tbl4.notice(v10, "Fast Drop")
                return
            end

            task.delay(2, function()
                if tbl3.hidup and tbl4.scene() == v5 then
                    local v11 = tbl4.inventoryCount(v5, item)
                    local drop = tbl3.drop
                    local message = v11 < v6 and string.format("Dropped %d %s | Left: %d", v6 - v11, tbl4.itemName(item), v11) or "Drop refused by the game; check its message"
                    drop.message = message
                    tbl4.dropOptions()
                end
            end)

            return
        end

        tbl4.notice("Native drop is unavailable.")
        return
    end

    tbl4.notice("Select an item to drop.")
end

tbl4.autoDropStep = function()
    if not tbl3.drop.auto or not tbl3.drop.item then
        return
    end
    local now = os.clock()
    local cooldownUntil = tbl3.drop.cooldownUntil
    local n = cooldownUntil or 0
    if now < n then
        return
    end
    local v5 = tbl4.scene()
    if not v5 or tbl4.moveBlocked(v5) then
        return
    end
    local item = tbl3.drop.item
    local v6 = tbl4.inventoryCount(v5, item)
    if v6 < 200 then
        return
    end
    local controller = v5.controller
    local value = controller and rawget(v5.controller, "onDrop")
    if type(value) ~= "function" then
        return
    end
    tbl3.drop.cooldownUntil = now + 2.2
    local v7, v8 = tbl4.coords(v5)
    local recent = tbl3.collect.recent

    for i = #recent, 1, -1 do
        if now - recent[i].T > 3 then
            table.remove(recent, i)
        end
    end

    local n2 = #recent + 1
    local tbl9 = {}
    local x = v7 or 0
    tbl9.X = x
    local n3 = v8 or 0
    tbl9.Y = n3 - 0.45
    tbl9.T = now
    recent[n2] = tbl9
    local v9 = tbl4.nativeCall(value, item, v6)

    if v9 then
        tbl3.drop.message = string.format("Auto dropping %d %s...", v6, tbl4.itemName(item))

        task.delay(2, function()
            if tbl3.hidup and tbl4.scene() == v5 then
                local v10 = tbl4.inventoryCount(v5, item)

                if v10 < v6 then
                    tbl3.drop.message = string.format("Auto dropped %d %s | Left: %d", v6 - v10, tbl4.itemName(item), v10)
                end
            end
        end)
    end
end

tbl4.leaveWorld = function(arg)
    local v5 = tbl4.scene()
    if not v5 then
        return
    end

    if tbl3.farm and tbl3.farm.enabled then
        local farmStop = tbl4.farmStop
        local str2 = arg or "Left world"
        farmStop(str2)
    end

    if tbl3.factory and tbl3.factory.enabled then
        local factoryStop = tbl4.factoryStop
        local str2 = arg or "Left world"
        factoryStop(str2)
    end

    local menu = v5.menu
    local value = menu and rawget(v5.menu, "openPicker")

    if type(value) == "function" then
        tbl4.nativeCall(value, true)
    else
        local net = tbl2.Net
        local value2 = net and rawget(tbl2.Net, "leave")
        local value3 = type(value2) == "table" and rawget(value2, "send")

        if type(value3) == "function" then
            tbl4.nativeCall(value3)
        end
    end

    if arg then
        tbl4.notice(arg, "Auto Leave")
    end
end

tbl4.checkAutoLeave = function(arg)
    if not tbl3.autoLeave or not arg or not arg.others then
        return
    end
    local value = rawget(arg.others, "list")
    local flag = type(value) == "function" and value() or nil

    if type(flag) == "table" and #flag > 0 then
        local v5 = flag[1]
        local flag2 = type(v5) == "table"

        if flag2 then
            local v6 = tostring
            local v7 = v5[2]
            local str2 = v7 or v5[1] or "Player"
            flag2 = v6(str2)
        end

        if not flag2 then
            flag2 = "Player"
        end

        local now = os.clock()
        local lastLeaveAt = tbl3.lastLeaveAt
        local n = lastLeaveAt or 0

        if now - n > 2 then
            tbl3.lastLeaveAt = os.clock()
            tbl4.leaveWorld("Left world: " .. flag2 .. " entered")
        end
    end
end

tbl3.drop = {
    item = nil,
    amount = 200,
    auto = false,
    cooldownUntil = 0,
    message = "Select an item",
}

v4 = lua:CreateWindow({
    Title = "Mine Hub",
    Icon = 116040372913018,
    Footer = "Growblox - " .. str,
    Center = true,
    AutoShow = true,
    Resizable = true,
    ToggleKeybind = Enum.KeyCode.RightShift,
    NotifySide = "Right",
    ShowCustomCursor = false,
})

if typeof(lua.ScreenGui) == "Instance" then
    lua.ScreenGui.AutoLocalize = false
end

lua2:SetLibrary(lua)
lua2:SetFolder(tbl3.folder)
lua3:SetLibrary(lua)
lua3:SetFolder(tbl3.folder)
lua3:IgnoreThemeSettings()

lua:OnUnload(function()
    tbl4.stop(false)
end)

local n = 0

v4.Confirm = function(arg, arg2)
    n = n + 1

    if type(v4.AddDialog) == "function" then
        local v5 = nil
        local v6 = v4
        local addDialog = v6.AddDialog
        local str2 = "GBX_Dialog_" .. tostring(n)
        local tbl9 = {}
        local title = arg2.Title
        local title2 = title or "Confirm"
        tbl9.Title = title2
        local content = arg2.Content
        local description = content or ""
        tbl9.Description = description

        tbl9.FooterButtons = {
            ["1"] = {
                Text = "Confirm",
                Variant = "Primary",
                Callback = function()
                    if arg2.OnConfirm then
                        arg2.OnConfirm()
                    end

                    if v5 and type(v5.Close) == "function" then
                        v5:Close()
                    end
                end,
            },
            ["2"] = {
                Text = "Cancel",
                Variant = "Secondary",
                Callback = function()
                    if v5 and type(v5.Close) == "function" then
                        v5:Close()
                    end
                end,
            },
        }

        v5 = addDialog(v6, str2, tbl9)
        return v5
    end

    if arg2.OnConfirm then
        arg2.OnConfirm()
    end
end

local tbl9 = {}
local n2 = 0

local function fn4(arg)
    if arg and arg.Flag then
        return arg.Flag
    end
    n2 = n2 + 1
    return "GBX_Widget_" .. tostring(n2)
end

local index = {}
index.__index = index

index.Paragraph = function(arg, arg2)
    local title = arg2.Title
    local str2 = title or ""
    local body = arg2.Body
    local desc = body or arg2.Desc or ""
    local box = arg.box
    local addLabel = box.AddLabel
    local str3 = str2 ~= "" and str2 .. "\n" or ""
    local v5 = addLabel(box, str3 .. tostring(desc), true)

    return {
        SetDesc = function(arg3, arg4)
            local setText = v5.SetText
            local str4 = str2 ~= "" and str2 .. "\n" or ""
            local v6 = tostring
            local str5 = arg4 or ""
            setText(v5, str4 .. v6(str5))
        end,
    }
end

index.Toggle = function(arg, arg2)
    local v5 = fn4(arg2)
    local default = arg2.Default
    local value = default

    if default == nil then
        value = arg2.Value
    end

    local box = arg.box
    local addToggle = box.AddToggle
    local tbl10 = {}
    local title = arg2.Title
    local v6 = title or v5
    tbl10.Text = v6
    tbl10.Tooltip = arg2.Desc
    local default2 = value == true
    tbl10.Default = default2
    local v7 = addToggle(box, v5, tbl10)

    if arg2.Callback then
        v7:OnChanged(function(arg3)
            local callback = arg2.Callback
            local value2 = arg3 == nil and v7.Value or arg3
            callback(value2)
        end)
    end

    return v7
end

index.Dropdown = function(arg, arg2)
    local v5 = fn4(arg2)
    local default = arg2.Default
    local default2 = default

    if default == nil then
        default2 = arg2.Value
    end

    local values = arg2.Values
    local values2 = values or {}
    local box = arg.box
    local addDropdown = box.AddDropdown
    local tbl10 = {}
    local title = arg2.Title
    local v6 = title or v5
    tbl10.Text = v6
    tbl10.Tooltip = arg2.Desc
    tbl10.Values = values2
    tbl10.Default = default2
    tbl10.AllowNull = true
    local searchable = arg2.SearchBarEnabled == true
    tbl10.Searchable = searchable
    local v7 = addDropdown(box, v5, tbl10)

    v7.Refresh = function(arg3, arg4)
        local setValues = arg3.SetValues
        local tbl11 = arg4 or {}
        setValues(arg3, tbl11)
    end

    if arg2.Callback then
        v7:OnChanged(function(arg3)
            local callback = arg2.Callback
            local value = arg3 == nil and v7.Value or arg3
            callback(value)
        end)
    end

    return v7
end

index.Slider = function(arg, arg2)
    local v5 = fn4(arg2)
    local default = arg2.Default
    local value = default

    if default == nil then
        value = arg2.Value
    end

    local step = arg2.Step
    local n3 = step or 1
    local rounding = n3 < 1 and math.ceil(-math.log10(n3)) or 0
    local box = arg.box
    local addSlider = box.AddSlider
    local tbl10 = {}
    local title = arg2.Title
    local v6 = title or v5
    tbl10.Text = v6
    tbl10.Tooltip = arg2.Desc
    local min = value or arg2.Min or 0
    tbl10.Default = min
    local min2 = arg2.Min
    local min3 = min2 or 0
    tbl10.Min = min3
    local max = arg2.Max
    local max2 = max or 100
    tbl10.Max = max2
    tbl10.Rounding = rounding
    local v7 = addSlider(box, v5, tbl10)

    if arg2.Callback then
        v7:OnChanged(function(arg3)
            local callback = arg2.Callback
            local value2 = arg3 == nil and v7.Value or arg3
            callback(value2)
        end)
    end

    return v7
end

index.Textbox = function(arg, arg2)
    local v5 = fn4(arg2)
    local default = arg2.Default
    local value = default

    if default == nil then
        value = arg2.Value
    end

    local box = arg.box
    local addInput = box.AddInput
    local tbl10 = {}
    local title = arg2.Title
    local v6 = title or v5
    tbl10.Text = v6
    tbl10.Tooltip = arg2.Desc
    local v7 = tostring
    local str2 = value or ""
    tbl10.Default = v7(str2)
    local placeholder = arg2.Placeholder
    local placeholder2 = placeholder or ""
    tbl10.Placeholder = placeholder2
    tbl10.Finished = true
    local v8 = addInput(box, v5, tbl10)

    if arg2.Callback then
        v8:OnChanged(function(arg3)
            local callback = arg2.Callback
            local value2 = arg3 == nil and v8.Value or arg3
            callback(value2)
        end)
    end

    return v8
end

index.Keybind = function(arg, arg2)
    local v5 = fn4(arg2)
    local default = arg2.Default
    local rightShift = default or Enum.KeyCode.RightShift
    local name = typeof(rightShift) == "EnumItem" and rightShift.Name or tostring(rightShift)
    local box = arg.box
    local addLabel = box.AddLabel
    local title = arg2.Title
    local str2 = title or "Keybind"
    local v6 = addLabel(box, str2)
    local addKeyPicker = v6.AddKeyPicker
    local tbl10 = {Default = name}
    local title2 = arg2.Title
    local text = title2 or "Keybind"
    tbl10.Text = text
    tbl10.NoUI = false

    tbl10.ChangedCallback = function(arg3)
        if arg2.Callback then
            arg2.Callback(arg3)
        end
    end

    local v7 = addKeyPicker(v6, v5, tbl10)

    v7.SetValue = function(arg3, arg4)
        local name2 = typeof(arg4) == "EnumItem" and arg4.Name or tostring(arg4)

        if type(v7.Set) == "function" then
            pcall(v7.Set, v7, name2)
        end

        if arg2.Callback then
            arg2.Callback(arg4)
        end
    end

    return v7
end

index.Button = function(arg, arg2)
    local box = arg.box
    local addButton = box.AddButton
    local tbl10 = {}
    local title = arg2.Title
    local text = title or "Button"
    tbl10.Text = text

    tbl10.Func = function()
        if arg2.Callback then
            arg2.Callback()
        end
    end

    return addButton(box, tbl10)
end

index.TileGrid7x7 = function(arg, arg2)
    local container = arg.box.Container
    local frame = Instance.new("Frame")
    frame.Name = "TileGrid7x7"
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.fromScale(1, 0)
    frame.Parent = container
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 6)
    uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Parent = frame
    local textLabel = Instance.new("TextLabel")
    textLabel.LayoutOrder = 1
    textLabel.Size = UDim2.new(1, 0, 0, 18)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamMedium
    textLabel.TextSize = 13
    textLabel.TextColor3 = Color3.fromRGB(220, 224, 235)
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    local title = arg2.Title
    local text = title or "Select Tiles (7x7)"
    textLabel.Text = text
    textLabel.Parent = frame
    local frame2 = Instance.new("Frame")
    frame2.LayoutOrder = 2
    frame2.Size = UDim2.fromOffset(226, 226)
    frame2.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
    frame2.BorderSizePixel = 0
    frame2.Parent = frame
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 6)
    uiCorner.Parent = frame2
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(50, 54, 66)
    uiStroke.Thickness = 1
    uiStroke.Parent = frame2
    local uiPadding = Instance.new("UIPadding")
    uiPadding.PaddingTop = UDim.new(0, 6)
    uiPadding.PaddingBottom = UDim.new(0, 6)
    uiPadding.PaddingLeft = UDim.new(0, 6)
    uiPadding.PaddingRight = UDim.new(0, 6)
    uiPadding.Parent = frame2
    local uiGridLayout = Instance.new("UIGridLayout")
    uiGridLayout.CellSize = UDim2.fromOffset(27, 27)
    uiGridLayout.CellPadding = UDim2.fromOffset(4, 4)
    uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiGridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    uiGridLayout.Parent = frame2
    local textLabel2 = Instance.new("TextLabel")
    textLabel2.LayoutOrder = 3
    textLabel2.Size = UDim2.new(1, 0, 0, 16)
    textLabel2.BackgroundTransparency = 1
    textLabel2.Font = Enum.Font.Gotham
    textLabel2.TextSize = 12
    textLabel2.TextColor3 = Color3.fromRGB(165, 172, 188)
    textLabel2.TextTruncate = Enum.TextTruncate.AtEnd
    textLabel2.TextXAlignment = Enum.TextXAlignment.Center
    textLabel2.Parent = frame
    local tbl10 = {}
    local tbl11 = {}

    local function fn5(arg3)
        local tbl12 = {}
        local tbl13 = {}

        if type(arg3) == "string" then
            for match in arg3:gmatch("[^;%s]+") do
                local match2, v5 = match:match("^([%-]?%d+),([%-]?%d+)$")
                local num = tonumber(match2)
                local num2 = tonumber(v5)

                if num and num2 and num >= -3 and num <= 3 and num2 >= -3 and num2 <= 3 and (num ~= 0 or num2 ~= 0) then
                    local str2 = num .. "," .. num2

                    if not tbl13[str2] then
                        tbl13[str2] = true
                        tbl12[#tbl12 + 1] = {DX = num, DY = num2, Key = str2}
                    end
                end
            end
        end

        return tbl12
    end

    local function fn6()
        local tbl12 = {}
        local tbl13 = {}

        for i, v5 in ipairs(tbl10) do
            tbl12[#tbl12 + 1] = v5.Key
            tbl13[#tbl13 + 1] = {DX = v5.DX, DY = v5.DY}
        end

        return table.concat(tbl12, ";"), tbl13
    end

    local function fn7()
        local tbl12 = {}

        for i, v5 in ipairs(tbl10) do
            tbl12[v5.Key] = i
        end

        for k, v5 in pairs(tbl11) do
            local v6 = tbl12[k]

            if v6 then
                v5.Button.BackgroundColor3 = Color3.fromRGB(46, 185, 95)
                v5.Stroke.Color = Color3.fromRGB(120, 255, 165)
                v5.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                v5.Button.Text = "#" .. tostring(v6)
            else
                v5.Button.BackgroundColor3 = Color3.fromRGB(34, 37, 46)
                v5.Stroke.Color = Color3.fromRGB(58, 63, 76)
                v5.Button.TextColor3 = Color3.fromRGB(120, 126, 145)
                v5.Button.Text = v5.CoordText
            end
        end

        if #tbl10 == 0 then
            textLabel2.Text = "No tile selected (click tiles around ME)"
        else
            local tbl13 = {}

            for i, v5 in ipairs(tbl10) do
                tbl13[#tbl13 + 1] = "(" .. v5.Key .. ")"
            end

            textLabel2.Text = string.format("Selected: %d tile(s) | %s", #tbl10, table.concat(tbl13, " "))
        end
    end

    local function fn8()
        local v5, v6 = fn6()
        fn7()

        if arg2.Callback then
            arg2.Callback(v5, v6)
        end
    end

    for i = -3, 3 do
        for i2 = -3, 3 do
            local textButton = Instance.new("TextButton")
            textButton.LayoutOrder = (i + 3) * 7 + (i2 + 3) + 1
            textButton.AutoButtonColor = false
            textButton.BorderSizePixel = 0
            textButton.Font = Enum.Font.GothamBold
            textButton.Parent = frame2
            local uiCorner2 = Instance.new("UICorner")
            uiCorner2.CornerRadius = UDim.new(0, 4)
            uiCorner2.Parent = textButton
            local uiStroke2 = Instance.new("UIStroke")
            uiStroke2.Thickness = 1
            uiStroke2.Parent = textButton

            if i2 == 0 and i == 0 then
                textButton.Name = "Cell_ME"
                textButton.BackgroundColor3 = Color3.fromRGB(55, 130, 245)
                textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                textButton.TextSize = 10
                textButton.Text = "ME"
                uiStroke2.Color = Color3.fromRGB(115, 180, 255)
            else
                local str2 = i2 .. "," .. i
                textButton.Name = "Cell_" .. str2
                textButton.TextSize = 9

                tbl11[str2] = {
                    Button = textButton,
                    Stroke = uiStroke2,
                    CoordText = string.format("%d,%d", i2, i),
                }

                textButton.Activated:Connect(function()
                    local v5 = nil

                    for i3, v6 in ipairs(tbl10) do
                        if v6.Key == str2 then
                            v5 = i3
                            break
                        end
                    end

                    if v5 then
                        table.remove(tbl10, v5)
                    else
                        tbl10[#tbl10 + 1] = {DX = i2, DY = i, Key = str2}
                    end

                    fn8()
                end)
            end
        end
    end

    local tbl12 = {
        SetValue = function(arg3, arg4)
            local v5 = tostring
            local str2 = arg4 or ""
            tbl10 = fn5(v5(str2))
            fn8()
        end,
        GetValue = function(arg3)
            return fn6()
        end,
    }

    local default = arg2.Default
    local str2 = default or "1,0;2,0"
    tbl10 = fn5(str2)
    fn8()

    task.defer(function()
        pcall(function()
            arg.box:Resize()
        end)
    end)

    return tbl12
end

tbl4.section = function(arg, arg2)
    local v5 = tbl9[arg]
    local n3 = v5 or 0
    local n4 = n3 + 1
    tbl9[arg] = n4
    local str2 = n4 % 2 == 1 and "Left" or "Right"
    local v6 = arg:AddGroupbox({Name = arg2, Side = str2})
    return setmetatable({box = v6, tab = arg, title = arg2}, index)
end

tbl4.control = function(arg, arg2, arg3, arg4)
    arg4.Flag = "GBX_" .. arg3
    local callback = arg4.Callback
    local default = arg4.Default
    local value = default

    if default == nil then
        value = arg4.Value
    end

    local flags = tbl3.flags
    local name = typeof(value) == "EnumItem" and value.Name or value
    flags[arg3] = name

    arg4.Callback = function(arg5, ...)
        if not tbl3.hidup then
            return
        end
        local v5 = table.pack(...)
        local flags2 = tbl3.flags
        local name2 = typeof(arg5) == "EnumItem" and arg5.Name or type(arg5) == "table" and table.clone(arg5) or arg5
        flags2[arg3] = name2

        local ok, result = pcall(function()
            if callback then
                callback(arg5, table.unpack(v5, 1, v5.n))
            end
        end)

        if not ok then
            tbl4.failure(result)
            tbl4.notice(result)
        end
    end

    local v5 = arg[arg2](arg, arg4)
    tbl3.controls[arg3] = {Kind = arg2, Widget = v5}
    return v5
end

tbl4.set = function(arg, arg2)
    tbl4.elevate()
    local flags = tbl3.flags
    local name = typeof(arg2) == "EnumItem" and arg2.Name or arg2
    flags[arg] = name
    local v5 = tbl3.controls[arg]
    local widget = v5 and v5.Widget

    if widget and type(widget.SetValue) == "function" then
        widget:SetValue(arg2)
    end
end

tbl4.toggle = function(arg, arg2, arg3, arg4, arg5)
    return tbl4.control(arg, "Toggle", arg2, {
        Title = arg3,
        Desc = arg5,
        Default = false,
        Callback = arg4,
    })
end

tbl4.button = function(arg, arg2, arg3)
    return arg:Button({
        Title = arg2,
        Callback = function()
            if tbl3.hidup then
                tbl4.spawn(arg3)
            end
        end,
    })
end

local tbl10 = {
    Farm = v4:AddTab("Farm", "warehouse"),
    Factory = v4:AddTab("Factory", "factory"),
    World = v4:AddTab("World", "compass"),
    ESP = v4:AddTab("ESP", "map-pin"),
    Misc = v4:AddTab("Misc", "shield"),
    Config = v4:AddTab("Config", "file-cog"),
    UI = v4:AddTab("UI", "settings"),
}

tbl4.farmUI(tbl10.Farm)
tbl4.factoryUI(tbl10.Factory)
local v5 = tbl4.section(tbl10.World, "GrowScan", "scan")
tbl4.button(v5, "Open GrowScan", tbl4.openGrowScan)
local v6 = tbl4.section(tbl10.Misc, "World Safety", "shield")

tbl4.toggle(v6, "AutoLeaveOnPlayer", "Auto Leave When Player Joins", function(autoLeave)
    tbl3.autoLeave = autoLeave

    if autoLeave then
        tbl4.checkAutoLeave(tbl4.scene())
    end
end, "Immediately leaves the current world when another player is detected in the world")

tbl4.button(v6, "Leave World Now", function()
    tbl4.leaveWorld("Left world manually")
end)

local v7 = tbl4.section(tbl10.ESP, "Layers", "map-pin")

for i, v8 in ipairs({
    "Players",
    "Floating",
    "Trees",
    "Providers",
    "Doors",
    "Locks",
    "Displays",
}) do
    local toggle = tbl4.toggle
    local str2 = "ESP" .. v8
    local str3 = v8 == "Floating" and "Floating Items and Gems" or v8

    toggle(v7, str2, str3, function(arg)
        tbl3.esp[v8] = arg
    end)
end

local v8 = tbl4.section(tbl10.ESP, "Labels", "filter")

tbl4.control(v8, "Toggle", "ESPLines", {
    Title = "Show Lines",
    Desc = "Draws a line from your character to each label, colored by type",
    Default = true,
    Callback = function(espLines)
        tbl3.espLines = espLines
    end,
})

tbl4.control(v8, "Slider", "MaxLabels", {
    Title = "Maximum Labels",
    Min = 20,
    Max = 250,
    Default = 120,
    Step = 10,
    Callback = function(maxLabels)
        tbl3.maxLabels = maxLabels
    end,
})

tbl4.control(v8, "Slider", "LabelSize", {
    Title = "Text Size",
    Min = 10,
    Max = 18,
    Default = 12,
    Step = 1,
    Callback = function(labelSize)
        tbl3.labelSize = labelSize
    end,
})

tbl4.button(v8, "Disable All ESP", function()
    for k in pairs(tbl3.esp) do
        tbl4.set("ESP" .. k, false)
    end

    for i, v9 in ipairs({"SeeFruit", "SeeLockedDoor"}) do
        tbl4.set(v9, false)
    end
end)

local v9 = tbl4.section(tbl10.World, "Vision", "star")

tbl4.toggle(v9, "SeeFruit", "See Fruit", function(fruit)
    tbl3.fruit = fruit
end, "Shows available fruit counts and growth time")

tbl4.toggle(v9, "SeeLockedDoor", "See Locked Door Labels", function(doorInfo)
    tbl3.doorInfo = doorInfo
end, "Displays door labels available to this client")

local v10 = tbl4.section(tbl10.World, "Performance", "zap")

tbl4.toggle(v10, "AntiLag", "Anti Lag", function(antiLag)
    tbl3.antiLag = antiLag
    tbl4.performance(tbl4.scene())
end, "Uses Growblox's low graphics mode")

tbl4.toggle(v10, "NoParticle", "No Particle", function(noParticle)
    tbl3.noParticle = noParticle
    tbl4.performance(tbl4.scene())
end, "Hides native particle sprites and restores them when disabled")

tbl4.validName = function(arg)
    local flag = type(arg) == "string" and #arg > 0 and #arg <= 64 and arg:match("^[%w_%- ]+$") ~= nil
    return flag
end

tbl4.ensureConfig = function()
    if not isfolder or not makefolder or not writefile then
        error("Config file access is unavailable")
    end

    for i, v11 in ipairs({"MineHub", tbl3.folder, tbl3.folder .. "/configs"}) do
        if not isfolder(v11) then
            makefolder(v11)
        end
    end
end

tbl4.configPath = function(arg)
    if not tbl4.validName(arg) then
        error("Use 1-64 letters, numbers, spaces, hyphens, or underscores for the config name")
    end

    return tbl3.folder .. "/configs/" .. arg .. ".json"
end

tbl4.configList = function()
    local tbl11 = {}

    if listfiles and isfolder and isfolder(tbl3.folder .. "/configs") then
        for i, v11 in ipairs(listfiles(tbl3.folder .. "/configs")) do
            local match = v11:match("([^/\\]+)%.json$")

            if tbl4.validName(match) then
                tbl11[#tbl11 + 1] = match
            end
        end
    end

    table.sort(tbl11)
    return tbl11
end

tbl4.configRefresh = function()
    local v11 = tbl4.configList()
    local configList = tbl3.ui.configList
    local refresh = configList.Refresh
    local flag = #v11 > 0 and v11

    if not flag then
        local tbl11 = {}
        flag = tbl11
        tbl11[1] = "No configs"
    end

    refresh(configList, flag)

    if tbl3.selectedConfig and not table.find(v11, tbl3.selectedConfig) then
        tbl3.selectedConfig = nil
    end
end

tbl4.loadConfig = function(arg)
    if tbl3.configLoading then
        return
    end

    if tbl3.farm then
        tbl4.farmStop("Loading config")
    end

    if tbl3.factory then
        tbl4.factoryStop("Loading config")
    end

    local v11 = tbl4.configPath(arg)

    if not isfile or not readfile or not isfile(v11) then
        error("Config was not found")
    end

    local data = tbl.Http:JSONDecode(readfile(v11))

    if type(data) ~= "table" or rawget(data, "Game") ~= "Growblox" or type(rawget(data, "Flags")) ~= "table" then
        error("Invalid Growblox config")
    end

    tbl3.configLoading = true

    local ok, result = pcall(function()
        local v12, v13, v14 = ipairs({false, true})
        local v15 = v14
        local v16 = v12
        local v17 = v13

        while true do
            local v18, v19 = v16(v17, v15)
            if v18 == nil then
                break
            end

            for k, flag in pairs(data.Flags) do
                local v20 = tbl3.controls[k]

                if v20 and k ~= "FarmEnabled" and k ~= "FactoryEnabled" then
                    local flag2 = type(flag) == "boolean"

                    if flag2 == v19 then
                        local kind = v20.Kind
                        local flag3 = kind == "Toggle" and type(flag) == "boolean" or kind == "Slider" and type(flag) == "number" and flag == flag and math.abs(flag) < math.huge or (kind == "Textbox" or kind == "Dropdown" or kind == "Keybind" or kind == "TileGrid7x7") and type(flag) == "string"

                        if flag3 then
                            tbl4.set(k, flag)
                        end
                    end
                end
            end

            v15 = v18
        end
    end)

    tbl3.configLoading = false

    if not ok then
        error(result)
    end

    tbl4.notice("Loaded " .. arg, "Config")
end

local v11 = tbl4.section(tbl10.Config, "Saved Configs", "file-cog")

tbl4.control(v11, "Textbox", "ConfigName", {
    Title = "Config Name",
    Default = "default",
    Callback = function(configName)
        tbl3.configName = configName
    end,
})

tbl3.ui.configList = v11:Dropdown({
    Title = "Select Config",
    Values = {"No configs"},
    Callback = function(arg)
        local selectedConfig = arg ~= "No configs" and arg or nil
        tbl3.selectedConfig = selectedConfig
    end,
})

tbl4.button(v11, "Save Config", function()
    local v12 = tbl4.configPath(tbl3.configName)
    tbl4.ensureConfig()
    local v13 = table.clone(tbl3.flags)
    v13.FarmEnabled = false
    v13.FactoryEnabled = false
    writefile(v12, tbl.Http:JSONEncode({Brand = "MineHub", Game = "Growblox", Flags = v13}))
    tbl4.configRefresh()
    tbl4.notice("Saved " .. tbl3.configName, "Config")
end)

tbl4.button(v11, "Load Config", function()
    if not tbl3.selectedConfig then
        tbl4.notice("Select a config first.")
        return
    end
    tbl4.loadConfig(tbl3.selectedConfig)
end)

tbl4.button(v11, "Refresh Config List", tbl4.configRefresh)

tbl4.button(v11, "Delete Config", function()
    local selectedConfig = tbl3.selectedConfig
    if not selectedConfig then
        tbl4.notice("Select a config first.")
        return
    end

    v4:Confirm({
        Title = "Delete " .. selectedConfig .. "?",
        Content = "This removes the saved config.",
        Danger = true,
        OnConfirm = function()
            tbl4.spawn(function()
                if not delfile then
                    error("File deletion is unavailable")
                end

                delfile(tbl4.configPath(selectedConfig))
                tbl3.selectedConfig = nil
                tbl4.configRefresh()
                tbl4.notice("Config deleted.")
            end)
        end,
    })
end)

pcall(function()
    lua3:BuildConfigSection(tbl10.Config)
end)

local v12 = tbl4.section(tbl10.UI, "Keybind", "settings")

tbl4.button(v12, "Toggle Menu", function()
    v4:Toggle()
end)

tbl4.control(v12, "Keybind", "ToggleKey", {
    Title = "Toggle UI",
    Default = Enum.KeyCode.RightShift,
    Callback = function(arg)
        local flag = typeof(arg) == "EnumItem" and arg or type(arg) == "string" and Enum.KeyCode[arg] or nil

        if flag then
            local options = lua.Options
            local gbxToggleKey = options and lua.Options.GBX_ToggleKey or flag
            lua.ToggleKeybind = gbxToggleKey
        end
    end,
})

if lua.Options and lua.Options.GBX_ToggleKey then
    lua.ToggleKeybind = lua.Options.GBX_ToggleKey
end

pcall(function()
    lua2:ApplyToTab(tbl10.UI)
end)

local v13 = lua:AddDraggableImageButton({
    Icon = 116040372913018,
    IconSize = 44,
    Callback = function()
        v4:Toggle()
    end,
})

if v13 and v13.Button then
    v13.Button.Name = "MineHubMenuToggle"
    v13.Button.Position = UDim2.fromOffset(20, 100)
    local imageLabel = v13.Button:FindFirstChildWhichIsA("ImageLabel")

    if imageLabel then
        imageLabel.ImageColor3 = Color3.new(1, 1, 1)

        if lua.Registry and lua.Registry[imageLabel] then
            lua.Registry[imageLabel].ImageColor3 = nil
        end
    end
end

tbl4.onWorldChanged = function()
    if tbl3.farm then
        tbl4.farmReset("World changed")
    end

    if tbl3.factory then
        tbl4.factoryReset("World changed")
    end
end

tbl3.onWorldChanged = tbl4.onWorldChanged
tbl4.connect(tbl.Run.RenderStepped, tbl4.updateLines)
local ok, result = pcall(tbl4.configRefresh)

if not ok then
    tbl4.failure(result)
end

tbl4.spawn(function()
    while tbl3.hidup do
        tbl4.elevate()

        local ok2, result2 = pcall(function()
            local v14 = tbl4.scene()
            tbl4.checkAutoLeave(v14)
            tbl4.performance(v14)
            tbl4.drawESP(v14)
        end)

        if not ok2 then
            tbl4.failure(result2)
        end

        task.wait(0.4)
    end
end)

tbl4.notice("GrowScan, ESP, vision, and performance controls loaded.", "Growblox")

return {
    Window = v4,
    State = tbl3,
    Functions = tbl4,
    UI = lua,
    Data = tbl2,
}
