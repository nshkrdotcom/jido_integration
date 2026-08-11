import Config

config :jido_integration_v2_auth, :persistence,
  profile: :mickey_mouse,
  store_modules: %{
    credential_store: Jido.Integration.V2.Auth.Store,
    lease_store: Jido.Integration.V2.Auth.Store,
    connection_store: Jido.Integration.V2.Auth.Store,
    install_store: Jido.Integration.V2.Auth.Store
  }

config :jido_integration_v2_control_plane, :persistence,
  profile: :mickey_mouse,
  store_modules: %{
    run_store: Jido.Integration.V2.ControlPlane.RunLedger,
    attempt_store: Jido.Integration.V2.ControlPlane.RunLedger,
    recovery_task_store: Jido.Integration.V2.ControlPlane.RunLedger,
    event_store: Jido.Integration.V2.ControlPlane.RunLedger,
    artifact_store: Jido.Integration.V2.ControlPlane.RunLedger,
    claim_check_store: Jido.Integration.V2.ControlPlane.RunLedger,
    target_store: Jido.Integration.V2.ControlPlane.RunLedger,
    ingress_store: Jido.Integration.V2.ControlPlane.RunLedger,
    profile_registry_store: Jido.Integration.V2.ControlPlane.RunLedger
  }

config :jido_integration_v2_store_postgres,
  ecto_repos: [Jido.Integration.V2.StorePostgres.Repo]

config :jido_integration_v2_store_postgres, Jido.Integration.V2.StorePostgres.Repo,
  username: "postgres",
  password: "postgres",
  database: "jido_integration_v2_test",
  hostname: "127.0.0.1",
  port: 5432,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10,
  queue_target: 5_000,
  queue_interval: 1_000,
  timeout: 15_000,
  ownership_timeout: 60_000
