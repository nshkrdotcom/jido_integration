defmodule Jido.Integration.V2.StoreLocal.RecoveryTaskStore do
  @moduledoc false

  @behaviour Jido.Integration.V2.ControlPlane.RecoveryTaskStore

  alias Jido.Integration.V2.Auth.SecretGuard
  alias Jido.Integration.V2.RecoveryTask
  alias Jido.Integration.V2.StoreLocal.State
  alias Jido.Integration.V2.StoreLocal.Storage

  @impl true
  def put_task(%RecoveryTask{} = task) do
    with :ok <- SecretGuard.validate_durable(task) do
      Storage.mutate(&State.put_recovery_task(&1, task))
    end
  end

  @impl true
  def fetch_task(task_id) do
    Storage.read(&State.fetch_recovery_task(&1, task_id))
  end

  @impl true
  def list_tasks(filters) when is_map(filters) do
    Storage.read(&State.list_recovery_tasks(&1, filters))
  end

  @impl true
  def list_due(%DateTime{} = now, limit) when is_integer(limit) and limit > 0 do
    Storage.read(&State.list_due_recovery_tasks(&1, now, limit))
  end

  @impl true
  def claim_task(task_id, claim_ref, %DateTime{} = now, %DateTime{} = claim_expires_at)
      when is_binary(task_id) and is_binary(claim_ref) do
    Storage.mutate(&State.claim_recovery_task(&1, task_id, claim_ref, now, claim_expires_at))
  end

  @impl true
  def transition_task(
        task_id,
        claim_ref,
        status,
        %DateTime{} = due_at,
        metadata,
        %DateTime{} = now
      )
      when status in [:pending, :resolved, :quarantined] and is_map(metadata) do
    with :ok <- SecretGuard.validate_durable(metadata) do
      Storage.mutate(
        &State.transition_recovery_task(
          &1,
          task_id,
          claim_ref,
          status,
          due_at,
          metadata,
          now
        )
      )
    end
  end

  def reset! do
    Storage.mutate(&State.reset_recovery_tasks/1)
  end
end
