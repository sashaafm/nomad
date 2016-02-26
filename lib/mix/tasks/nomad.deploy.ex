defmodule Mix.Tasks.Nomad.Deploy do
	use Mix.Task
	
	def run(args) do
		setup_config args
		
		IO.inspect Application.get_env(:nomad, :target_host)
		IO.inspect Application.get_env(:nomad, :target_port)		
	end

	defp setup_config(args) do 
		{:ok, host} = Enum.fetch(args, 0)		
		{:ok, port} = Enum.fetch(args, 1)

		Application.put_env :nomad, :target_host, host
		Application.put_env :nomad, :target_port, port
	end
end