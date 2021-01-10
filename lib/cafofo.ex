defmodule Cafofo do
  def fetch_page(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts("Not found")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
    end
  end

  def parse_html(html) do
    case Floki.parse_document(html) do
      {:ok, document} ->
        document

      {:error, error} ->
        IO.inspect(error)
    end
  end

  def find_items_info(document) do
    document
    |> Floki.find("ul#ad-list")
    |> Floki.find("a > div > div:nth-child(2) > div:first-child")
  end

  # TODO: figure how to filter out the expensive items
  def get_rent_cost(document) do
    Floki.find(document, "div > div:nth-child(2) > div:nth-child(2) span")
  end

  def get_houses do
    System.get_env("OLX_URL")
    |> fetch_page
    |> parse_html
    |> find_items_info
    |> get_rent_cost
  end
end
