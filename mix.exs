defmodule Nomad.Mixfile do
  use Mix.Project

  def project do
    [
     app:             :nomad,
     version:         "0.1.0",
     elixir:          "~> 1.1-dev",
     build_embedded:  Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps:            deps
   ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:exrm,   "~> 1.0.1"},
      {:credo,  "~> 0.3",  only: [:dev, :test]},
      {:ex_doc, "~> 0.11", only: [:dev]}
    ]
  end
end
