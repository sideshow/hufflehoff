defmodule Hufflehoff.MixProject do
  use Mix.Project

  def project do
    [
      app: :hufflehoff,
      version: "0.0.1",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Hufflehoff",
      source_url: "https://github.com/sideshow/hufflehoff"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
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
    [
      maintainers: ["Adam Jones"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/sideshow/hufflehoff"}
    ]
  end
end
