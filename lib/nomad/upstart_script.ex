defmodule Nomad.UpstartScript do

  @moduledoc """
  
  """

  def build_script do 
    {:ok, script} = File.open "#{System.get_env("APP_NAME")}.conf", [:write]

    :ok = IO.binwrite script, bs(System.get_env("APP_NAME"), System.get_env("PORT"))
    File.close script    
  end

  defp bs(app_name, port) do 
    """
    description "#{app_name}"

    ## Uncomment the following two lines to run the
    ## application as www-data:www-data
    #setuid www-data
    #setgid www-data

    start on runlevel [2345]
    stop on runlevel [016]

    expect stop
    respawn

    env MIX_ENV=prod
    export MIX_ENV

    ## Uncomment the following two lines if we configured
    ## our port with an environment variable.
    #env PORT=#{port}
    #export PORT

    ## Add app HOME directory.
    env HOME=/app
    export HOME


    pre-start exec /bin/sh /app/bin/#{app_name} start

    post-stop exec /bin/sh /app/bin/#{app_name} stop
    """
  end

  def delete_script do 
    File.rm "#{System.get_env("APP_NAME")}.conf"
  end
end