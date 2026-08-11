defmodule Jido.Integration.V2.Auth.Application do
  @moduledoc false

  use Application

  alias Jido.Integration.V2.Auth.Persistence
  alias Jido.Integration.V2.Auth.Store

  @impl true
  def start(_type, _args) do
    persistence = persistence_boot_attrs()

    children =
      [
        {Jido.Integration.V2.Auth.Persistence.Owner, persistence},
        {Jido.Integration.V2.Auth.RuntimeConfig, []},
        {Task.Supervisor, name: Jido.Integration.V2.Auth.MaterializationSupervisor}
      ] ++ memory_store_children(persistence)

    opts = [strategy: :one_for_one, name: Jido.Integration.V2.Auth.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp persistence_boot_attrs,
    do: Application.fetch_env!(:jido_integration_v2_auth, :persistence)

  defp memory_store_children(persistence) do
    if Store in Map.values(Persistence.resolve!(persistence).store_modules),
      do: [{Store, []}],
      else: []
  end
end
