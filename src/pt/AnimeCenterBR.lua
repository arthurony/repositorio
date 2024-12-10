local json = require("cjson")

-- Função para obter a lista de novels
local function getNovelsList()
    local url = "https://animecenterbr.com/wp-json/wp/v2/pages/17073"
    local response_body = {}
    local res, code = http.request{
        url = url,
        sink = ltn12.sink.table(response_body)
    }

    if res then
        local data = json.decode(table.concat(response_body))
        local contentHTML = data.content.rendered
        local novels = {}

        for link, title in contentHTML:gmatch('<a href="(.-)".->(.-)</a>') do
            table.insert(novels, {
                title = title,
                url = link
            })
        end

        return novels
    end

    return {}
end

-- Função para obter detalhes de uma novel
local function getNovelDetails(postID)
    local url = "https://animecenterbr.com/wp-json/wp/v2/posts/" .. postID
    local response_body = {}
    local res, code = http.request{
        url = url,
        sink = ltn12.sink.table(response_body)
    }

    if res then
        local data = json.decode(table.concat(response_body))
        return {
            title = data.title.rendered,
            description = data.content.rendered,
            imageURL = data.featured_media_url or "",
        }
    end

    return nil
end

-- Função para obter o conteúdo de um capítulo
local function getChapterContent(chapterURL)
    local encodedURL = http.escape(chapterURL)
    local url = "https://animecenterbr.com/wp-json/oembed/1.0/embed?url=https%3A%2F%2F" .. encodedURL .. "&format=json"
    
    local response_body = {}
    local res, code = http.request{
        url = url,
        sink = ltn12.sink.table(response_body)
    }

    if res then
        local data = json.decode(table.concat(response_body))
        return data.html
    end

    return nil
end

-- Exemplo de uso
local novels = getNovelsList() -- Pega a lista de novels
for _, novel in ipairs(novels) do
    print("Novel: " .. novel.title)
    local details = getNovelDetails("3211") -- Exemplo usando o ID 3211 (DanMachi)
    print("Descrição: " .. details.description)

    -- Pega os capítulos
    local chapters = getChapterContent("https://animecenterbr.com/danmachi-light-novel-prologo-vol-01/")
    print("Capítulo 1 conteúdo: " .. chapters)
end
