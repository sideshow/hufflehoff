defmodule Hufflehoff.Mixfile do
  use Mix.Project

  def project do
    [app: :hufflehoff,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps,]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    []
  end

  defp description do
    """
    A Huffman encoder/decoder for HTTP/2 headers.
    """
  end

  defp package do
    [maintainers: ["Adam Jones"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/sideshow/hufflehoff"}]
  end
end
