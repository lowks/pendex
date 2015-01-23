defmodule Pendex.Mixfile do
  use Mix.Project

  def project do
    [ app: :pendex,
      version: String.strip(File.read!("VERSION")),
      elixir: "~> 1.0",
      deps: deps,
      description: description,
      package: package,
      escript: escript
    ]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:exjsx, :inets, :ssl]]
  end

  # Escript definition
  def escript do
    [main_module: Pendex]
  end

  defp description do
    """
    Google's URL Shortener API for Elixir.
    """
  end

  defp package do
    [contributors: ["Low Kian Seong"],
     licenses: ["MIT"],
     links: %{"Github" => "https://github.com/lowks/pendex"}]
  end

  # Returns the list of dependencies in the format:
  defp deps do
    [{ :exjsx, "3.1.0", github: "talentdeficit/exjsx" }]
  end
end