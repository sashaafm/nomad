defmodule Nomad.Mixfile do
  use Mix.Project

  @version "0.5.0"

  def project do
    [
     app:             :nomad,
     version:         @version,
     elixir:          "~> 1.2",
     build_embedded:  Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps:            deps
   ]
  end

  def application do
    [
      applications: [:logger, :httpoison, :friendly, :goth, :table_rex],
      mod: {Nomad, []}
    ]
  end

  defp deps do
    [
      {:exrm,             "~> 1.0.1"},
      {:credo,            "~> 0.3",  only: [:dev, :test]},
      {:ex_doc,           "~> 0.11", only: [:dev]},
      {:httpoison,        "~> 0.8.1"},
      {:table_rex,        "~> 0.8.0"},
      {:friendly,         "~> 1.0.0"},
      {:goth,             "~> 0.0.1"},
      {:ex_aws,           github: "sashaafm/ex_aws", branch: "merge-rds-and-ec2-for-testing", optional: true},
      {:gcloudex,         "~> 0.4.3", optional: true}     
    ]        
  end
end
