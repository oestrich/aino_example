defmodule Example.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Example.Config

  @impl true
  def start(_type, _args) do
    config = Vapor.load!(Config)

    children = [
      {Example.Repo, []}
      | aino(config.application)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Example.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp aino(config) do
    case config.environment != "test" do
      true ->
        simple_config = %{
          session_salt: config.session_salt
        }

        [
          {Aino,
           callback: Example.Web.Handler,
           otp_app: :example,
           port: config.port,
           host: config.host,
           environment: config.environment,
           config: simple_config},
          {Aino.Watcher, name: Example.Web.Watcher, watchers: watchers(config.environment)}
        ]

      false ->
        []
    end
  end

  defp watchers("development") do
    [
      [
        command: "node_modules/yarn/bin/yarn",
        args: ["build:css:watch"],
        directory: "assets/"
      ]
    ]
  end

  defp watchers(_), do: []
end
