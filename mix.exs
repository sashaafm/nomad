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
    case System.get_env("PROVIDER") do 
      "AWS" ->
        [applications: [:logger, :httpoison, :nomad_aws]]

      "GCL" ->
        [applications: [:logger, :httpoison, :nomad_gcl]]
    end
  end

  defp deps do
    case System.get_env("PROVIDER") do 
      "AWS" ->
        [
          {:exrm,      "~> 1.0.1"},
          {:credo,     "~> 0.3",  only: [:dev, :test]},
          {:ex_doc,    "~> 0.11", only: [:dev]},
          {:httpoison, "~> 0.8.1"},
          {:nomad_aws, git: "git@github.com:sashaafm/nomad_aws.git"}
         # {:nomad_aws, path: "/home/sashaafm/Documents/nomad_aws"}
        ]

      "GCL" ->
        [
          {:exrm,      "~> 1.0.1"},
          {:credo,     "~> 0.3",  only: [:dev, :test]},
          {:ex_doc,    "~> 0.11", only: [:dev]},
          {:httpoison, "~> 0.8.1"},
          {:nomad_gcl, git: "git@github.com:sashaafm/nomad_gcl.git"}
         # {:nomad_gcl, path: "/home/sashaafm/Documents/nomad_gcl"}
        ]        
    end

#    Mix.Task.run "deps.clean", ["--unused"]
  end
end
