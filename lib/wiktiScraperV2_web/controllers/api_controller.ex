defmodule WiktiScraperV2Web.ApiController do
  use WiktiScraperV2Web, :controller

  def langlist(conn, _params) do
    # HTTPoison.start

    langs = case HTTPoison.get("https://en.wiktionary.org/wiki/Wiktionary:List_of_languages") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, document} = Floki.parse_document(body)
        table = Floki.find(document, ".wikitable")
        table = Enum.at(table, 0)
        tbody = Floki.find(table, "tbody")
        trs = Floki.find(tbody, "tr")

        build_lang_list = fn tr ->
          tds = Floki.find(tr, "td")
          Floki.text(Enum.at(tds, 1))
        end

        #return
        Enum.map(trs, build_lang_list)

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Error trying to fetch language list html"
      {:error, %HTTPoison.Error{reason: _reason}} ->
        IO.puts "Error trying to fetch language list html"
    end

    json(conn, %{langs: langs})
  end

  defp lang_2_lemma_link(lang) do
    "https://en.wiktionary.org/wiki/Category:" <> lang <> "_lemmas"
  end

  defp lemma_link_2_pos_links(link) do
    partsOfSpeech = case HTTPoison.get(link) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, document} = Floki.parse_document(body)
        uls = Floki.find(document, "ul")
        ul = Enum.at(uls, 0)
        lis = Floki.find(ul, "li")

        build_pos_list = fn li ->
          a = Floki.find(li, "a")
          "https://en.wiktionary.org" <> Enum.at(Floki.attribute(Enum.at(a, 0), "href"), 0) #I think Floki.find always returns an array even if only 1 element is found, so need Enum.at
        end

        #return
        Enum.map(lis, build_pos_list)

        {:ok, %HTTPoison.Response{status_code: 404}} ->
          IO.puts "Error trying to fetch pos list html"
        {:error, %HTTPoison.Error{reason: _reason}} ->
          IO.puts "Error trying to fetch pos list html"
    end

    #return
    partsOfSpeech
  end

  def getPOSLinks(conn, %{"lang" => lang}) do
    lemmaLink = lang_2_lemma_link(lang)

    json(conn, %{POSLinks: lemma_link_2_pos_links(lemmaLink)})
  end

  defp page2section(pageLink, lang) do
    page = case HTTPoison.get(pageLink) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, document} = Floki.parse_document(body)
        pageContent = Floki.children(Enum.at(Floki.find(document, ".mw-parser-output"), 0))
        sectionHtml = ""

        indexes = Enum.map(pageContent, fn el ->
          case elem(el, 0) do
            "h2" ->
              span = Enum.at(Floki.find(el, "span"), 0)
              id = Enum.at(Floki.attribute(span, "id"), 0)

              case id do
                ^lang -> 1
                _ -> -1
              end
            _ -> 0
          end
        end)

        startIndex = Enum.find_index(indexes, fn i -> i == 1 end)
        endIndex = startIndex + Enum.find_index(Enum.slice(indexes, startIndex, length(indexes)), fn i -> i == -1 end)

        startIndex = startIndex + 1
        endIndex = endIndex - 1

        sectionArray = Enum.map(startIndex..endIndex, fn i -> Floki.raw_html(Enum.at(pageContent, i)) end)

        sectionHtml = Enum.join(sectionArray, "")

        IO.puts sectionHtml
        sectionHtml

        {:ok, %HTTPoison.Response{status_code: 404}} ->
          IO.puts "Error trying to fetch page html"
        {:error, %HTTPoison.Error{reason: _reason}} ->
          IO.puts "Error trying to fetch page html"
    end
  end
end
