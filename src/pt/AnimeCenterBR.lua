-- {"id":93083,"ver":"3.0.0","libVer":"1.0.0","author":"MechTechnology"}
local baseURL = "https://animecenterbr.com/"

local function text(v)
    return v:text()
end

local function shrinkURL(url)
    return url:gsub("^.-animecenterbr%.com/?", "")
end

local function expandURL(url)
    return baseURL .. url
end

return {
    id = 93083,
    name = "AnimeCenterBR",
    baseURL = baseURL,
    imageURL = "https://raw.githubusercontent.com/arthurony/repositorio/refs/heads/main/icons/animecenterbr.png",
    hasSearch = false,
    chapterType = ChapterType.HTML,
    shrinkURL = shrinkURL,
    expandURL = expandURL,

    listings = {
        Listing("Light Novels", false, function()
            local doc = GETDocument(baseURL .. "light-novels-2/")
            return map(doc:select("div.post-text-content.my-5 ul li a"), function(v)
                return Novel {
                    title = v:text(),
                    link = shrinkURL(v:attr("href")),
                    imageURL = "https://raw.githubusercontent.com/arthurony/repositorio/refs/heads/main/icons/animecenterbr.png", -- Imagem padrão
                }
            end)
        end)
    },

    parseNovel = function(url, loadChapters)
        local doc = GETDocument(expandURL(url))
        local info = NovelInfo {
            title = doc:selectFirst("div.post-text-content.my-3 h3"):text(),
            imageURL = "https://raw.githubusercontent.com/arthurony/repositorio/refs/heads/main/icons/animecenterbr.png", -- Imagem padrão
            description = doc:selectFirst("div.post-text-content.my-3 p"):text(),
        }

        if loadChapters then
            --- @param novelDoc Document
            local function parseChapters(novelDoc)
                return mapNotNil(novelDoc:select("div.post-text-content.my-3 ul li a"), function(v)
                    return NovelChapter {
                        title = v:text(),
                        link = shrinkURL(v:attr("href")),
                    }
                end)
            end

            local chapters = { parseChapters(doc) }
            chapters = flatten(chapters)

            local o = 1
            for i = #chapters, 1, -1 do
                chapters[i]:setOrder(o)
                o = o + 1
            end

            local chaptersList = AsList(chapters)
            Reverse(chaptersList)
            info:setChapters(chaptersList)
        end

        return info
    end,

    getPassage = function(chapterURL)
        local htmlElement = GETDocument(expandURL(chapterURL))
        local title = htmlElement:selectFirst("div.post-text-content.my-3 h1"):text()
        htmlElement = htmlElement:selectFirst("div.post-text-content.my-3")
        -- Capítulo título inserido antes do texto do capítulo
        htmlElement:child(0):before("<h1>" .. title .. "</h1>");

        return pageOfElem(htmlElement, true)
    end
}
