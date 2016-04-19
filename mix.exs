defmodule Nomad.Mixfile do
  use Mix.Project

  def project do
    [
     app:             :nomad,
     version:         "0.4.0",
     elixir:          "~> 1.2",
     build_embedded:  Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps:            deps
   ]
  end

  def application do
    case System.get_env("PROVIDER") do 
      "AWS" ->
        [
          applications: [:logger, :httpoison, :nomad_aws, :table_rex],
          mod: {Nomad, []}
        ]

      "GCL" ->
        [
          applications: [:logger, :httpoison, :nomad_gcl, :table_rex],
          mod: {Nomad, []}
        ]
    end
  end

  defp deps do
    case System.get_env("PROVIDER") do 
      "AWS" ->
        [
          {:exrm,             "~> 1.0.1"},
          {:credo,            "~> 0.3",  only: [:dev, :test]},
          {:ex_doc,           "~> 0.11", only: [:dev]},
          {:httpoison,        "~> 0.8.1"},
          {:table_rex,        "~> 0.8.0"},
         # {:nomad_aws, git: "git@github.com:sashaafm/nomad_aws.git"}
          {:nomad_aws,        path: "/home/sashaafm/Documents/nomad_aws"},
          {:nomad_behaviours, path: "/home/sashaafm/Documents/nomad_behaviours"}
        ]

      "GCL" ->
        [
          {:exrm,             "~> 1.0.1"},
          {:credo,            "~> 0.3",  only: [:dev, :test]},
          {:ex_doc,           "~> 0.11", only: [:dev]},
          {:httpoison,        "~> 0.8.1"},
          {:table_rex,        "~> 0.8.0"},
        #  {:nomad_gcl, git: "git@github.com:sashaafm/nomad_gcl.git"}
          {:nomad_gcl,        path: "/home/sashaafm/Documents/nomad_gcl"},
          {:nomad_behaviours, path: "/home/sashaafm/Documents/nomad_behaviours"}
        ]        
    end    
  end
end
