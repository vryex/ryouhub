-- El host provee una lectura HTTPS y un compilador Luau, por ejemplo su loadstring.
-- El chunk se ejecuta en un cliente Roblox con PlayerGui.
return function(fetchSource, compile, pinnedSourceURL)
    assert(type(fetchSource) == "function" and type(compile) == "function")
    assert(type(pinnedSourceURL) == "string" and pinnedSourceURL:match(
        "^https://raw%.githubusercontent%.com/vryex/ryouhub/[0-9a-f]+/ryou%-ui%-v14/RyouUI%.lua$"),
        "Se requiere una URL oficial fijada al commit")
    local revision = pinnedSourceURL:match("/ryouhub/([0-9a-f]+)/")
    assert(#revision == 40, "Se requiere el SHA completo")
    local source = fetchSource(pinnedSourceURL)
    assert(type(source) == "string" and source ~= "", "No se recibió el código fuente")
    local chunk, err = compile(source)
    assert(type(chunk) == "function", err or "No se pudo compilar Ryou UI")
    local ok, library = pcall(chunk)
    assert(ok, library)
    assert(type(library) == "table" and library.Version == "14.0.0", "Versión de Ryou UI inesperada")
    return library
end
