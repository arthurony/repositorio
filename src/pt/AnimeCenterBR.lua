-- Anime Center BR Extension for Shosetsu
local id = 123456 -- ID único para a extensão
local baseURL = "https://animecenterbr.com"
local name = "Anime Center BR"

local function shrinkURL(url)
    return url:gsub("^" .. baseURL, "")
end

local function expandURL(path)
    return baseURL .. path
end

-- Função para buscar capítulos de uma novel
local function getChapterList(novelID)
    local url = expandURL("/wp-json/wp/v2/posts/" .. novelID)
    local data = GETJson(url)
    local chapters = {}
    local contentHTML = data.content.rendered
    -- Parse manual da lista de capítulos se necessário
    -- Inserir capítulos na tabela chapters
    return chapters
end

-- Função para processar uma novel
local function parseNovel(novelID)
    local url = expandURL("/wp-json/wp/v2/posts/" .. novelID)
    local data = GETJson(url)
    return NovelInfo {
        title = data.title.rendered,
        imageURL = data.featured_media_url or "",
        description = data.content.rendered,
        chapters = getChapterList(novelID)
    }
end

-- Função para processar a lista de novels
local function parseList()
    local url = expandURL("/wp-json/wp/v2/pages/17073")
    local data = GETJson(url)
    local contentHTML = data.content.rendered
    local novels = {}
    -- Parse manual do HTML para extrair títulos e links
    return novels
end

function getPassage(url)
    -- Extrai o ID do post do URL (pode ser necessário ajustar dependendo do formato do URL)
    local id = url:match("posts/(%d+)")
    if not id then return nil end

    -- Monta o endpoint da API com o ID do post
    local apiUrl = "https://animecenterbr.com/wp-json/wp/v2/posts/" .. id

    -- Faz uma requisição HTTP para a API
    local response = http:get(apiUrl)
    if response then
        -- Faz o parse do JSON retornado
        local json = response:json()
        if json and json.content and json.content.rendered then
            -- Retorna o conteúdo do capítulo
            return json.content.rendered
        end
    end

    return nil -- Retorna nil caso algo dê errado
end


return {
    id = id,
    name = name,
    baseURL = baseURL,
    hasSearch = false,
    listings = {
        Listing("Lista de Novels", true, function(data)
            return parseList()
        end)
    },
    parseNovel = parseNovel
}
