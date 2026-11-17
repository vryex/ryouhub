local function testNeoAssets(loadLibrary, sizes, revision)
    local storage, folders, requests, missing = {}, {}, {}, {}
    local downloads, writes, queue, delays = 0, 0, {}, 0
    local signature = "\137PNG\r\n\26\n"
    local cache = "RyouUI/Cache/" .. revision:sub(1,12) .. "/"
    local logo = "R_FACETADA_VECTOR_512.png"
    local launcher = "LAUNCHER_GENERADO_RGBA_1254.png"
    local alternate = "LAUNCHER_CIRCULAR_VECTOR_512.png"
    local function chunkFor(url)
        local directory = "https://raw.githubusercontent.com/vryex/ryouhub/" .. revision .. "/ryou-ui-v14/assets/neo/"
        local filename = url:sub(#directory+1)
        assert(url:sub(1,#directory) == directory and sizes[filename], "Asset URL must point at the pinned registry")
        if missing[filename] then return "Not found" end
        return signature .. "\0\0\0\rIHDR" .. string.rep("\0", sizes[filename]-24) .. "IEND\0\0\0\0"
    end
    function game:HttpGet(url)
        downloads += 1
        local filename = url:match("/([^/]+)$")
        requests[filename] = (requests[filename] or 0) + 1
        return chunkFor(url)
    end
    function task.defer(fn) table.insert(queue, fn) end
    function task.wait() delays += 1 end
    local function flush()
        while #queue > 0 do table.remove(queue, 1)() end
    end
    local function host(withFolders)
        return {
            getsynasset = function(path)
                assert(storage[path] and storage[path]:sub(1,8) == signature)
                return "local://" .. path
            end,
            isfolder = function(folder) return folders[folder] == true end,
            makefolder = withFolders and function(folder) folders[folder] = true end or nil,
            isfile = function(path) return storage[path] ~= nil end,
            readfile = function(path) return assert(storage[path]) end,
            writefile = function(path, data)
                local dir = path:match("^(.+)/")
                assert(not dir or folders[dir])
                writes += 1
                storage[path] = data
            end,
        }
    end
    local inherited = getfenv(loadLibrary)
    local function newSession(withFolders)
        setfenv(loadLibrary, setmetatable(host(withFolders), {__index=inherited}))
        return loadLibrary():CreateWindow({Open=false,Motion="Off"})
    end

    local window = newSession(true)
    local banner = window:Tab("Inicio"):Banner({})
    local headerLogo = window.brand:FindFirstChild("RyouMark"):FindFirstChild("Logo")
    assert(downloads == 0 and writes == 0 and not headerLogo.Image, "Window creation must not wait on transport")
    flush()
    assert(requests[logo] == 1 and requests[launcher] == 1 and writes == 8 and downloads == 8)
    assert(headerLogo.Image == "local://" .. cache .. logo)
    assert(window.launcherImage.Image == "local://" .. cache .. launcher)
    assert(banner:FindFirstChild("hero_orbits").Image:match("^local://"))
    assert(window.launcher:FindFirstChild("LauncherFallback").Visible ~= false)
    window.launcherImage.IsLoaded = true
    assert(not window.launcher:FindFirstChild("LauncherFallback").Visible)
    window:SetOpenButtonGhosted(true)
    assert(window.launcherImage.ImageTransparency == .38)
    window:SetTheme("Light")
    assert(not banner:FindFirstChild("hero_orbits").Visible)
    window:Open()
    window:Close()
    flush()
    assert(downloads == 8 and writes == 8)
    window:Destroy()

    storage[cache .. logo] = string.rep("x", sizes[logo])
    window = newSession(true)
    flush()
    assert(downloads == 9 and writes == 9 and requests[logo] == 2, "Only corrupt cached PNG is downloaded again")
    window:Destroy()

    table.clear(storage)
    missing[launcher] = true
    window = newSession(false)
    flush()
    assert(requests[launcher] == 3 and delays == 1 and requests[alternate] == 1)
    assert(window.launcherImage.Image == "local://RyouUI-" .. revision:sub(1,12) .. "-" .. alternate)
    window:Destroy()
    setfenv(loadLibrary, inherited)
    print("Neo Sidebar assets: nonblocking loading, reuse, cache repair and launcher fallback OK")
end
