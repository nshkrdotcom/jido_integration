defmodule Jido.Integration.V2.ProviderClassification.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/nshkrdotcom/jido_integration"

  def project do
    [
      app: :jido_integration_provider_classification,
      version: @version,
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: false,
      deps: deps(),
      dialyzer: dialyzer(),
      docs: docs(),
      package: package(),
      source_url: @source_url,
      homepage_url: @source_url,
      name: "Jido Integration Provider Classification",
      description: "No-dependency canonical provider and adapter classification vocabulary"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def cli do
    [preferred_envs: [ci: :test]]
  end

  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.40.1", only: :dev, runtime: false}
    ]
  end

  defp dialyzer do
    [plt_add_deps: :apps_direct]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      extras: ["README.md", "CHANGELOG.md", "LICENSE"]
    ]
  end

  defp package do
    [
      name: "jido_integration_provider_classification",
      licenses: ["MIT"],
      maintainers: ["nshkrdotcom"],
      links: %{
        "Changelog" => "#{@source_url}/blob/main/core/provider_classification/CHANGELOG.md",
        "GitHub" => @source_url
      },
      files: ["lib", "mix.exs", "README.md", "CHANGELOG.md", "LICENSE"]
    ]
  end
end
