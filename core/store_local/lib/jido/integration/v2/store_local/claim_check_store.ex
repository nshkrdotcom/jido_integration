defmodule Jido.Integration.V2.StoreLocal.ClaimCheckStore do
  @moduledoc false

  @behaviour Jido.Integration.V2.ControlPlane.ClaimCheckStore

  alias Jido.Integration.V2.Contracts
  alias Jido.Integration.V2.ControlPlane.ClaimCheckTelemetry
  alias Jido.Integration.V2.StoreLocal.State
  alias Jido.Integration.V2.StoreLocal.Storage

  @impl true
  def stage_blob(payload_ref, encoded, metadata) when is_binary(encoded) and is_map(metadata) do
    Storage.mutate(&State.stage_claim_check_blob(&1, payload_ref, encoded, metadata))
  end

  @impl true
  def fetch_blob(payload_ref) do
    Storage.read(&State.fetch_claim_check_blob(&1, payload_ref))
  end

  @impl true
  def register_reference(payload_ref, attrs) when is_map(attrs) do
    Storage.mutate(&State.register_claim_check_reference(&1, payload_ref, attrs))
  end

  @impl true
  def fetch_blob_metadata(payload_ref) do
    Storage.read(&State.fetch_claim_check_blob_metadata(&1, payload_ref))
  end

  @impl true
  def count_live_references(payload_ref) do
    Storage.read(&State.count_live_claim_check_references(&1, payload_ref))
  end

  @impl true
  def sweep_staged_payloads(opts \\ []) do
    cutoff = cutoff(opts)

    {result, swept} =
      Storage.mutate(fn state ->
        {result, next_state, swept} = State.sweep_staged_claim_check_payloads(state, cutoff)
        {{result, swept}, next_state}
      end)

    Enum.each(swept, fn blob ->
      ClaimCheckTelemetry.orphaned_staged_payload(
        blob.payload_ref,
        blob.metadata,
        source_component: :store_local,
        store_backend: :store_local
      )
    end)

    result
  end

  @impl true
  def garbage_collect(opts \\ []) do
    cutoff = cutoff(opts)

    {result, deleted, skipped} =
      Storage.mutate(fn state ->
        {result, next_state, deleted, skipped} =
          State.garbage_collect_claim_check_payloads(state, cutoff)

        {{result, deleted, skipped}, next_state}
      end)

    Enum.each(deleted, &emit_deleted/1)
    Enum.each(skipped, &emit_skipped/1)
    result
  end

  def reset! do
    Storage.mutate(&State.reset_claim_checks/1)
  end

  defp cutoff(opts) do
    DateTime.add(Contracts.now(), -Keyword.get(opts, :older_than_s, 0), :second)
  end

  defp emit_deleted(blob) do
    ClaimCheckTelemetry.blob_gc_deleted(
      blob.payload_ref,
      blob.metadata,
      source_component: :store_local,
      store_backend: :store_local
    )
  end

  defp emit_skipped(blob) do
    ClaimCheckTelemetry.blob_gc_skipped_live_reference(
      blob.payload_ref,
      blob.metadata,
      source_component: :store_local,
      store_backend: :store_local,
      live_reference_count: blob.live_refs
    )
  end
end
