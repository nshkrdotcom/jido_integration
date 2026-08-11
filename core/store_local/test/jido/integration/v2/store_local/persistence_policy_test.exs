defmodule Jido.Integration.V2.StoreLocal.PersistencePolicyTest do
  use Jido.Integration.V2.StoreLocal.Case

  alias Jido.Integration.V2.Auth
  alias Jido.Integration.V2.ControlPlane
  alias Jido.Integration.V2.StoreLocal
  alias Jido.Integration.V2.StoreLocal.CredentialStore
  alias Jido.Integration.V2.StoreLocal.RecoveryTaskStore
  alias Jido.Integration.V2.StoreLocal.RunStore

  test "configures local restart safe stores through explicit persistence policy" do
    assert {:ok, capability} = StoreLocal.store_capability()
    assert capability.tier == :local_restart_safe
    assert capability.restart_safe?
    assert capability.durable?

    assert :ok = StoreLocal.configure_defaults!(persistence_profile: :local_restart_safe)

    assert Auth.Stores.credential_store() == CredentialStore
    assert ControlPlane.Stores.run_store() == RunStore
    assert ControlPlane.Stores.recovery_task_store() == RecoveryTaskStore
  end

  test "configures local stores when persistence owner applications are not already started", %{
    storage_dir: storage_dir
  } do
    :ok = stop_application(:jido_integration_v2_store_local)
    :ok = stop_application(:jido_integration_v2_control_plane)
    :ok = stop_application(:jido_integration_v2_auth)

    assert :ok = StoreLocal.configure_defaults!(storage_dir: storage_dir)

    assert Process.whereis(Jido.Integration.V2.Auth.Persistence.Owner)
    assert Process.whereis(Jido.Integration.V2.ControlPlane.Persistence.Owner)
    assert Auth.Stores.credential_store() == CredentialStore
    assert ControlPlane.Stores.run_store() == RunStore

    assert auth_boot = Application.fetch_env!(:jido_integration_v2_auth, :persistence)
    assert auth_boot[:profile] == :local_restart_safe
    assert [boot_capability] = auth_boot[:capabilities]
    assert boot_capability.tier == :local_restart_safe
    assert auth_boot[:store_modules].credential_store == CredentialStore

    assert control_plane_boot =
             Application.fetch_env!(:jido_integration_v2_control_plane, :persistence)

    assert control_plane_boot[:profile] == :local_restart_safe
    assert control_plane_boot[:capabilities] == auth_boot[:capabilities]
    assert control_plane_boot[:store_modules].run_store == RunStore
    assert control_plane_boot[:store_modules].recovery_task_store == RecoveryTaskStore

    refute Jido.Integration.V2.ControlPlane.RunLedger in Map.values(
             control_plane_boot[:store_modules]
           )
  end

  defp stop_application(app) when is_atom(app) do
    case Application.stop(app) do
      :ok -> :ok
      {:error, {:not_started, ^app}} -> :ok
      {:error, {:not_started, _dependency}} -> :ok
      {:error, reason} -> raise "unable to stop #{inspect(app)}: #{inspect(reason)}"
    end
  end
end
