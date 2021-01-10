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
    Floki.find(
      document,
      "ul#ad-list a > div > div:nth-child(2) > div:first-child"
    )
  end

  def get_rent_cost(node) do
    rent_cost =
      node
      |> Floki.find("div > div:nth-child(2) > div:nth-child(2) span[color=graphite]")
      |> Floki.text()
      |> String.replace("R$", "")
      |> String.replace(".", "")
      |> String.trim()

    case rent_cost do
      "" ->
        {:error, "Item is not available"}

      _ ->
        {:ok, String.to_integer(rent_cost)}
    end
  end

  def is_within_the_budget?(node) do
    budget = System.get_env("BUDGET") |> String.to_integer()

    case get_rent_cost(node) do
      {:ok, rent_cost} ->
        rent_cost < budget

      {:error, _} ->
        false
    end
  end

  def filter_houses_within_the_budget(document) do
    Enum.filter(document, fn node -> is_within_the_budget?(node) end)
  end

  def get_houses do
    System.get_env("OLX_URL")
    |> fetch_page
    |> parse_html
    |> find_items_info
    |> filter_houses_within_the_budget
  end
end
