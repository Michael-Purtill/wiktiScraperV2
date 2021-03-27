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
          "https://en.wiktionary.org" <> Enum.at(Floki.attribute(Enum.at(a, 0), "href"), 0) #I think Floki.find always returns a array even if only 1 element is found, so need Enum.at
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
end
