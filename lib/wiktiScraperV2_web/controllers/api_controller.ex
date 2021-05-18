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

  defp page2Section(pageLink, lang) do
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
        endIndex = Enum.find_index(Enum.slice(indexes, startIndex, length(indexes)), fn i -> i == -1 end)

        noEnd = endIndex == nil

        endIndex = if endIndex != nil do
          startIndex + endIndex
        else
          startIndex
        end

        startIndex = startIndex + 1
        endIndex = endIndex - 1

        endIndex = if noEnd == true do
          length(pageContent) - startIndex - 1
        else
          endIndex
        end

        sectionArray = Enum.map(startIndex..endIndex, fn i -> Floki.raw_html(Enum.at(pageContent, i)) end)

        sectionHtml = Enum.join(sectionArray, "")

        "<div>" <> sectionHtml <> "</div>"

        {:ok, %HTTPoison.Response{status_code: 404}} ->
          IO.puts "Error trying to fetch page html"
        {:error, %HTTPoison.Error{reason: _reason}} ->
          IO.puts "Error trying to fetch page html"
    end
    #return
    page
  end

  defp getWikiHeaders(document) do
    pageContent = Floki.children(Enum.at(Floki.find(document, "div"), 0))

    headerChunks = Enum.chunk_by(pageContent, fn el -> elem(el, 0) != "h3" && elem(el, 0) != "h4" && elem(el, 0) != "h5" end)

    headerChunks = Enum.map(1..length(headerChunks) - 1, fn index ->
      chunk = Enum.at(headerChunks, index)
      lastChunk = Enum.at(headerChunks, index - 1)

      case elem(Enum.at(lastChunk, 0), 0) do
        "h3" -> [Enum.at(lastChunk, 0) | chunk]
        "h4" -> [Enum.at(lastChunk, 0) | chunk]
        "h5" -> [Enum.at(lastChunk, 0) | chunk]
        _ -> []
      end
    end)

    headerChunks = Enum.filter(headerChunks, fn c -> !Enum.empty?(c) end)

    headerChunks
  end

  defp section2Content(section) do
    {:ok, document} = Floki.parse_fragment(section)
    headers = getWikiHeaders(document)

    contentMapArr = Enum.map(headers, fn hr ->
      contentMap = %{:title => Floki.text(Enum.at(hr, 0), sep: " "), :content => []}

      Map.put(contentMap, :content, Enum.filter(Enum.map(Enum.slice(hr, 1, length(hr)), fn s ->
        case elem(s, 0) do
          "p" -> %{:tag => "p", :innerContent => Floki.text(s, sep: " ")}
          x when x in ["ol", "ul"] -> %{:tag => x, :innerContent => Enum.map(Floki.children(s), fn li -> Floki.text(li, sep: " ") end)}
          "div" -> case Floki.find(s, ".wikitable") do
            [] -> %{:tag => elem(s, 0), :innerContent => "filter me out"}
            [table] ->
              thead = Floki.find(table, "thead")
              tbody = Floki.find(table, "tbody")
              rowArray = []

              rowArray = rowArray ++ if thead != [] do
                [Enum.map(Floki.find(thead, "th"), fn th -> %{"text" => Floki.text(th, sep: " "),
                "rowspan" => if length(Floki.attribute(th, "rowspan")) > 0 do String.to_integer(Enum.at(Floki.attribute(th, "rowspan"), 0)) else 1 end,
                "colspan" => if length(Floki.attribute(th, "colspan")) > 0 do String.to_integer(Enum.at(Floki.attribute(th, "colspan"), 0)) else 1 end
                } end)]
              else
                []
              end

              cellArrs = Enum.map(Floki.find(tbody, "tr"), fn row -> Floki.find(row, "td,th") end)
              cells = Enum.map(cellArrs, fn cellArr -> Enum.map(cellArr, fn cell -> %{"text" => Floki.text(cell, sep: " "),
              "rowspan" => if length(Floki.attribute(cell, "rowspan")) > 0 do String.to_integer(Enum.at(Floki.attribute(cell, "rowspan"), 0)) else 1 end,
              "colspan" => if length(Floki.attribute(cell, "colspan")) > 0 do String.to_integer(Enum.at(Floki.attribute(cell, "colspan"), 0)) else 1 end
              } end) end)

              %{:tag => "table", :innerContent => rowArray ++ cells}
              [head | tail] -> %{:tag => "tables", :innerContent => Enum.map([head | tail], fn tbl ->
                thead = Floki.find(tbl, "thead")
                tbody = Floki.find(tbl, "tbody")
                rowArray = []

                rowArray = rowArray ++ if thead != [] do
                  [Enum.map(Floki.find(thead, "th"), fn th -> %{"text" => Floki.text(th, sep: " "),
                  "rowspan" => if length(Floki.attribute(th, "rowspan")) > 0 do String.to_integer(Enum.at(Floki.attribute(th, "rowspan"), 0)) else 1 end,
                  "colspan" => if length(Floki.attribute(th, "colspan")) > 0 do String.to_integer(Enum.at(Floki.attribute(th, "colspan"), 0)) else 1 end
                } end)]
                else
                  []
                end

                cellArrs = Enum.map(Floki.find(tbody, "tr"), fn row -> Floki.find(row, "td,th") end)
                cells = Enum.map(cellArrs, fn cellArr -> Enum.map(cellArr, fn cell -> %{"text" => Floki.text(cell, sep: " "),
                "rowspan" => if length(Floki.attribute(cell, "rowspan")) > 0 do String.to_integer(Enum.at(Floki.attribute(cell, "rowspan"), 0)) else 1 end,
                "colspan" => if length(Floki.attribute(cell, "colspan")) > 0 do String.to_integer(Enum.at(Floki.attribute(cell, "colspan"), 0)) else 1 end
              } end) end)

                rowArray ++ cells
              end)}
          end
          _ -> %{:tag => elem(s, 0), :innerContent => Floki.text(s, sep: " ")}
        end
      end), fn cont -> Map.get(cont, :innerContent, "filter me out") != "filter me out" end))
    end)

    contentMapArr

  end

  defp scrubHtml(html) do #gets rid of all particular data in an html section and returns a scrubbed html with only important content
    {:ok, document} = Floki.parse_fragment(html)
    pageContent = Floki.children(Enum.at(Floki.find(document, "div"), 0))

    scrubbedHtml = Enum.join(Enum.map(pageContent, fn tag ->
      case elem(tag, 0) do
        x when x in ["h1", "h2", "h3", "h4", "h5", "h6"] -> "<" <> x <> ">" <> Floki.text(tag) <> "</" <> x <> ">"
        x when x in ["ul", "ol", "p", "span"] -> "<" <> x <> ">" <> "</" <> x <> ">"
        "div" -> case Floki.find(tag, ".wikitable") do
          [] -> ""
          [table] ->
            thead = Floki.find(table, "thead")
            tbody = Floki.find(table, "tbody")

            tableString = "<table>"

            tableString = tableString <> if thead != [] do
              subString = "<thead>"
              subString <> Enum.join(Enum.map(Floki.find(thead, "tr"), fn tr ->
                "<tr>" <> Enum.join(Enum.map(Floki.children(tr), fn child ->
                  case elem(child, 0) do
                    "th" -> "<th>" <> Floki.text(child) <> "</th>"
                    "td" -> "<td></td>"
                  end
                end), "") <> "</tr>"
              end), "") <> "</thead>"
            else
              ""
            end

            tableString = tableString <> if tbody != [] do
              subString = "<tbody>"
              subString <> Enum.join(Enum.map(Floki.find(tbody, "tr"), fn tr ->
                "<tr>" <> Enum.join(Enum.map(Floki.children(tr), fn child ->
                  case elem(child, 0) do
                    "th" -> "<th>" <> Floki.text(child) <> "</th>"
                    "td" -> "<td></td>"
                  end
                end), "") <> "</tr>"
              end), "") <> "</tbody>"
            else
              ""
            end

            tableString <> "</table>"
        end
        _ -> "<" <> elem(tag, 0) <> ">" <> "</" <> elem(tag, 0) <> ">"
      end

    end), "")
  end

  defp normalizeHtml(html) do #format html from wiktionary to match how the system expects
    {:ok, document} = Floki.parse_fragment(html)
    pageContent = Floki.children(Enum.at(Floki.find(document, "div"), 0))

    scrubbedHtml = Enum.join(Enum.map(pageContent, fn tag ->
      case elem(tag, 0) do
        x when x in ["h1", "h2", "h3", "h4", "h5", "h6"] -> "<" <> x <> ">" <> Floki.text(tag) <> "</" <> x <> ">"
        x when x in ["p", "span"] -> "<" <> x <> ">" <> Floki.text(tag, sep: " ") <> "</" <> x <> ">"
        x when x in ["ol", "ul"] -> "<" <> x <> ">" <> Enum.join(Enum.map(Floki.children(tag), fn li -> "<li>" <> Floki.text(li, sep: " ") <> "</li>" end), "") <> "</" <> x <> ">"
        "div" -> case Floki.find(tag, ".wikitable") do
          [] -> ""
          [table] ->
            thead = Floki.find(table, "thead")
            tbody = Floki.find(table, "tbody")

            tableString = "<table><tbody>"

            tableString = tableString <> if thead != [] do
              subString = ""
              subString <> Enum.join(Enum.map(Floki.find(thead, "tr"), fn tr ->
                "<tr>" <> Enum.join(Enum.map(Floki.children(tr), fn child ->
                  case elem(child, 0) do
                    x when x in ["th", "td"] -> "<td>" <> Floki.text(child) <> "</td>"
                  end
                end), "") <> "</tr>"
              end), "")
            else
              ""
            end

            tableString = tableString <> if tbody != [] do
              subString = ""
              subString <> Enum.join(Enum.map(Floki.find(tbody, "tr"), fn tr ->
                "<tr>" <> Enum.join(Enum.map(Floki.children(tr), fn child ->
                  case elem(child, 0) do
                    x when x in ["th", "td"] -> "<td>" <> Floki.text(child) <> "</td>"
                  end
                end), "") <> "</tr>"
              end), "")
            else
              ""
            end

            tableString <> "</tbody></table>"
        end
        _ -> ""
      end

    end), "")
  end

  def testPage(conn, %{"lang" => lang, "word" => word}) do #a controller for testing new features during development
    section = page2Section("https://en.wiktionary.org/wiki/" <> word, lang)
    content = scrubHtml(section)
    json(conn, %{:stuff => content})
  end

  def wordInfo(conn, %{"lang" => lang, "word" => word}) do #probably will only be used during testing, get info for a single word in a language
    section = page2Section("https://en.wiktionary.org/wiki/" <> word, lang)
    content = section2Content(section)
    json(conn, content)
  end

  defp wordInfoCreator(%{"lang" => lang, "word" => word}) do
    section = page2Section("https://en.wiktionary.org/wiki/" <> word, lang)
    content = section2Content(section)
    content
  end

  def testPageJsonHandler(conn, %{"selectors" => selectors, "lang" => lang, "word" => word}) do
    wordData = wordInfoCreator(%{"lang" => lang, "word" => word})

    selected = Enum.map(selectors, fn s ->
      selectKeys = String.split(s, ":")
      {index1, _} = Integer.parse(Enum.at(selectKeys, 0))
      {index2, _} = Integer.parse(Enum.at(selectKeys, 1))

      obj = Enum.at(wordData, index1)
      content = Map.get(obj, :content)
      content = Enum.at(content, index2)
      content
    end)

    json(conn, selected)
  end

end
