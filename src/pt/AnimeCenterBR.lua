-- Anime Center BR Extension for Shosetsu
local AnimeCenterBR = {}

local id = 123456 -- ID único para a extensão
local baseURL = "https://animecenterbr.com"
local name = "Anime Center BR"

local function shrinkURL(url)
    return url:gsub("^" .. baseURL, "")
end

local function expandURL(path)
    return baseURL .. path
end

-- Função para buscar o conteúdo de um capítulo
function AnimeCenterBR.getPassage(url)
    local response = http:get(url)

    if response then
        local html = response:html()

        -- Seleciona o conteúdo principal do capítulo
        local content = html:select("div.post-text-content.my-3") -- Substitua pelo seletor correto da página

        if content then
            return content:html() -- Retorna o HTML do capítulo
        end
    end

    return nil -- Retorna nil se o conteúdo não for encontrado
end

-- Função para buscar capítulos de uma novel
local function getChapterList(novelID)
    local url = expandURL("/wp-json/wp/v2/posts/" .. novelID)
    local data = http:get(url):json()
    local chapters = {}

    if data and data.content and data.content.rendered then
        local contentHTML = data.content.rendered

        -- Aqui você precisa extrair os links e títulos dos capítulos manualmente
        for link, title in contentHTML:gmatch('<a href="(.-)".->(.-)</a>') do
            table.insert(chapters, {
                name = title,
                url = expandURL(link)
            })
        end
    end

    return chapters
end

-- Função para processar uma novel
local function parseNovel(novelID)
    local url = expandURL("/wp-json/wp/v2/posts/" .. novelID)
    local data = http:get(url):json()

    if data then
        return NovelInfo {
            title = data.title.rendered,
            imageURL = data.featured_media_url or "",
            description = data.content.rendered,
            chapters = getChapterList(novelID)
        }
    end

    return nil -- Retorna nil se a novel não for encontrada
end

-- Função para processar a lista de novels
local function parseList()
    local url = expandURL("/wp-json/wp/v2/pages/17073")
    local data = http:get(url):json()
    local novels = {}

    if data and data.content and data.content.rendered then
        local contentHTML = data.content.rendered

        -- Extrai títulos e links de novels
        for link, title in contentHTML:gmatch('<a href="(.-)".->(.-)</a>') do
            table.insert(novels, {
                name = title,
                url = expandURL(link)
            })
        end
    end

    return novels
end

-- Retorna a extensão no formato esperado pelo Shosetsu
return {
    id = id,
    name = name,
    baseURL = baseURL,
    hasSearch = false,
    listings = {
        Listing("Lista de Novels", true, function()
            return parseList()
        end)
    },
    parseNovel = parseNovel
}
