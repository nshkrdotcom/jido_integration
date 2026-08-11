defmodule Jido.Integration.V2.ControlPlane.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Jido.Integration.V2.ControlPlane.Persistence
  alias Jido.Integration.V2.ControlPlane.RunLedger

  @impl true
  def start(_type, _args) do
    persistence = persistence_boot_attrs()

    children =
      [
        {Jido.Integration.V2.ControlPlane.Persistence.Owner, persistence},
        {Jido.Integration.V2.ControlPlane.RuntimeConfig, []},
        {Jido.Integration.V2.ControlPlane.Registry, []}
      ] ++
        memory_store_children(persistence) ++
        [{Jido.Integration.V2.ControlPlane.AttemptReconciler, []}]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Jido.Integration.V2.ControlPlane.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp persistence_boot_attrs,
    do: Application.fetch_env!(:jido_integration_v2_control_plane, :persistence)

  defp memory_store_children(persistence) do
    if RunLedger in Map.values(Persistence.resolve!(persistence).store_modules),
      do: [{RunLedger, []}],
      else: []
  end
end
