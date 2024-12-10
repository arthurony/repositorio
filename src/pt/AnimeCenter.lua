-- Anime Center BR Extension for Shosetsu
local id = 1234567  -- ID único para a extensão
local baseURL = "https://animecenterbr.com"
local name = "Anime Center"

-- Função para buscar a lista de novels
local function getNovelList()
    local url = "https://animecenterbr.com/wp-json/wp/v2/pages/17073"
    local data = GETJson(url)  -- Requisição JSON para obter a lista de páginas
    local contentHTML = data.content.rendered

    local novels = {}
    -- Parse simples para pegar títulos e links das novels
    for link in contentHTML:gmatch('<a href="(https?://[a-zA-Z0-9./_-]+)">([%w%s]+)</a>') do
        local url, title = link
        table.insert(novels, {title = title, url = url})  -- Insere o título e URL da novel
    end

    return novels  -- Retorna a lista de novels
end

return {
    id = id,
    name = name,
    baseURL = baseURL,
    hasSearch = false,
    listings = {
        Listing("Lista de Novels", true, function()
            return getNovelList()  -- Chama a função que retorna a lista de novels
        end)
    }
}
