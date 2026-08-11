defmodule Jido.Integration.V2.StoreLocal.LeaseStoreTest do
  use Jido.Integration.V2.StoreLocal.Case

  alias Jido.Integration.V2.Auth.LeaseRecord
  alias Jido.Integration.V2.StoreLocal.LeaseStore
  alias Jido.Integration.V2.StoreLocal.TestSupport

  test "durably records lease redemption and materialization" do
    issued_at = ~U[2026-07-25 12:00:00Z]

    lease =
      LeaseRecord.new!(%{
        lease_id: "lease-local-callbacks",
        tenant_id: "tenant-local",
        credential_ref_id: "credential-ref-local",
        credential_id: "credential-local",
        connection_id: "connection-local",
        subject: "operator-local",
        scopes: ["repo"],
        payload_keys: ["access_token"],
        issued_at: issued_at,
        expires_at: DateTime.add(issued_at, 60, :second)
      })

    redeemed_at = DateTime.add(issued_at, 10, :second)
    materialized_at = DateTime.add(issued_at, 11, :second)

    assert :ok = LeaseStore.store_lease(lease)

    assert {:ok, redeemed} = LeaseStore.record_redemption(lease.lease_id, redeemed_at, 1)
    assert redeemed.redemption_count == 1
    assert redeemed.last_redeemed_at == redeemed_at

    assert {:error, :max_calls_exceeded} =
             LeaseStore.record_redemption(lease.lease_id, materialized_at, 1)

    assert {:ok, materialized} =
             LeaseStore.record_materialization(
               lease.lease_id,
               "materialization-local-1",
               materialized_at
             )

    assert materialized.last_materialization_ref == "materialization-local-1"
    assert materialized.metadata.last_materialized_at == materialized_at

    assert :ok = TestSupport.restart_store!()
    assert {:ok, ^materialized} = LeaseStore.fetch_lease(lease.lease_id)
  end
end
