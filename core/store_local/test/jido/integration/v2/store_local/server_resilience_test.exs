defmodule Jido.Integration.V2.StoreLocal.ServerResilienceTest do
  use Jido.Integration.V2.StoreLocal.Case

  alias Jido.Integration.V2.StoreLocal
  alias Jido.Integration.V2.StoreLocal.Application, as: StoreLocalApplication
  alias Jido.Integration.V2.StoreLocal.Server
  alias Jido.Integration.V2.StoreLocal.State

  test "startup recovers from an unsafe persisted state file" do
    path = StoreLocal.storage_path()

    assert :ok == Supervisor.terminate_child(StoreLocalApplication, Server)
    File.write!(path, <<131, 80, 0, 0, 0, 0>>)

    assert {:ok, _pid} = Supervisor.restart_child(StoreLocalApplication, Server)
    assert Server.snapshot() == State.new()
    assert :erlang.binary_to_term(File.read!(path), [:safe]) == State.new()
  end

  test "startup upgrades an older state struct without discarding persisted truth" do
    path = StoreLocal.storage_path()
    legacy_state = State.new() |> Map.delete(:recovery_tasks) |> Map.delete(:claim_check_blobs)
    legacy_state = Map.delete(legacy_state, :claim_check_references)

    assert :ok == Supervisor.terminate_child(StoreLocalApplication, Server)
    File.write!(path, :erlang.term_to_binary(legacy_state), [:binary])

    assert {:ok, _pid} = Supervisor.restart_child(StoreLocalApplication, Server)
    assert Server.snapshot() == State.new()
    assert :erlang.binary_to_term(File.read!(path), [:safe]) == State.new()
  end
end
