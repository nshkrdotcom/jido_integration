defmodule Jido.Integration.V2.Contracts.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/nshkrdotcom/jido_integration"

  def project do
    [
      app: :jido_integration_contracts,
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
      name: "Jido Integration Contracts",
      description: "Greenfield public contracts for runs, attempts, capabilities, and credentials"
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  defp deps do
    [
      provider_classification_dep(),
      {:jido, "~> 2.2"},
      {:jido_action, "~> 2.2"},
      {:jido_signal, "~> 2.1"},
      {:jason, "~> 1.4"},
      {:jcs, "~> 0.2.0"},
      {:zoi, "~> 0.17"},
      {:credo, "~> 1.7.17", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4.7", only: [:dev, :test], runtime: false},
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
      extras: [
        "README.md",
        "guides/inference_contracts.md",
        {"examples/README.md", filename: "examples_readme"},
        "CHANGELOG.md",
        "LICENSE"
      ],
      groups_for_extras: [
        Overview: ["README.md"],
        Inference: ["guides/inference_contracts.md"],
        Examples: ["examples/README.md"],
        Release: ["CHANGELOG.md", "LICENSE"]
      ]
    ]
  end

  defp package do
    [
      name: "jido_integration_contracts",
      licenses: ["MIT"],
      maintainers: ["nshkrdotcom"],
      links: %{
        "Changelog" => "#{@source_url}/blob/main/core/contracts/CHANGELOG.md",
        "GitHub" => @source_url
      },
      files: [
        "lib",
        "guides",
        "examples",
        "mix.exs",
        "README.md",
        "CHANGELOG.md",
        "LICENSE"
      ]
    ]
  end

  defp provider_classification_dep do
    source_path = Path.expand("../provider_classification", __DIR__)

    if source_checkout?() and not package_task?() do
      {:jido_integration_provider_classification, path: source_path}
    else
      {:jido_integration_provider_classification, "~> 0.1.0"}
    end
  end

  defp source_checkout? do
    File.dir?(Path.expand("../provider_classification", __DIR__)) and
      "deps" not in Path.split(__DIR__)
  end

  defp package_task? do
    System.argv()
    |> Enum.map(&String.trim_leading(&1, "-"))
    |> Enum.any?(&(&1 in ["hex.build", "hex.publish"]))
  end
end
